import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')

    response = ec2.describe_snapshots(OwnerIds=['self'])
    snapshots = response['Snapshots']

    server = ec2.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    active_instance_ids = set()

    reservation = server['Reservations']
    for inst in reservation:
        for instance in inst['Instances']:
            active_instance_ids.add(instance['InstanceId'])

    print("Active Instance IDs:", active_instance_ids)

    for snapshot in snapshots:
        snapshot_id = snapshot['SnapshotId']
        volume_id = snapshot.get('VolumeId')
        
        if not volume_id:
            ec2.delete_snapshot(SnapshotId=snapshot_id)
            print(f"Deleted snapshot {snapshot_id} with no associated volume.")

        else:
            try:
                volume_response = ec2.describe_volumes(VolumeIds=[volume_id])
                attachments = volume_response['Volumes'][0]['Attachments']
                
                if not attachments:
                    ec2.delete_snapshot(SnapshotId=snapshot_id)
                    print(f"Deleted snapshot {snapshot_id} because volume {volume_id} has no attachments.")
            
            except ec2.exceptions.ClientError as e:
                if e.response['Error']['Code'] == 'InvalidVolume.NotFound':
                    ec2.delete_snapshot(SnapshotId=snapshot_id)
                    print(f"Deleted snapshot {snapshot_id} because volume {volume_id} was not found.")
                else:
                    print(f"Error describing volume {volume_id}: {e}")

