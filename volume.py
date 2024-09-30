import boto3

ec2 = boto3.client('ec2')

volume_res = ec2.describe_volumes()

volumes = volume_res['Volumes']
for volume in volumes:
    state = (volume['State'])
    volume_id = (volume['VolumeId'])
    if state == 'available':
                 ec2.delete_volume(VolumeId=volume_id)
    else:
                 print(volume['State'])
        
