resource "aws_instance" "example1"{
ami = var.ami_id
instance_type = var.instance_type
subnet_id = var.subnet_id["us-east-1a"]
vpc_security_group_ids = [aws_security_group.sg.id]
availability_zone = "us-east-1a"
key_name = aws_key_pair.my_key_pair.key_name

user_data = base64encode(file("userdata.sh"))

tags ={
Name = "application_lb-1"
}
}

resource "aws_instance" "example2"{
ami = var.ami_id
instance_type = var.instance_type
subnet_id = var.subnet_id["us-east-1b"]
vpc_security_group_ids = [aws_security_group.sg.id]
availability_zone = "us-east-1b"
key_name = aws_key_pair.my_key_pair.key_name

user_data = base64encode(file("userdata1.sh"))

tags ={
Name = "application_lb-2"
}

}




#application loadbalancer


resource "aws_lb" "myalb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [var.subnet_id["us-east-1a"],var.subnet_id["us-east-1b"]]


  }


resource "aws_lb_target_group" "mytg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = "vpc-0b04440c69226540a"

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id        = aws_instance.example1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id        = aws_instance.example2.id
  port             = 80
}

resource "aws_lb_listener" "mylis" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mytg.arn
  }
}

