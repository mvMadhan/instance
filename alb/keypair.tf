resource "aws_key_pair" "key_pair"{
key_name ="new_keypair"
public_key = file("~/.ssh/id_rsa.pub")
}
