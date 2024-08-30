resource "aws_instance" "mulani-webserver" { 
  instance_type   = local.instance_type[var.environment] 
  ami             = "ami-066784287e358dad1" # Replace with a desired AMI 
  subnet_id       = aws_subnet.websubnet.id 
  security_groups = [aws_security_group.web_sg.id] 
  tags = { 
    Name = "mulani-webserver" 
  } 
} 
 
 
resource "aws_vpc" "mulani-vpc" { 
  cidr_block = "10.0.0.0/16" 
  tags = { 
    "name" = "mulani-vpc" 
  } 
} 
resource "aws_s3_bucket" "mulaniS3_1" { 
    count = length(var.bucket) 
  bucket = "appdev-${element(var.bucket, count.index)}" 
} 
variable "bucket" { 
    type = list(string) 
    default = [ "bucket151" , "bucket152" , "bucket153" ] 
   
} 
resource "aws_subnet" "websubnet" { 
 
  vpc_id            = aws_vpc.mulani-vpc.id 
  cidr_block        = "10.0.0.0/24" 
  availability_zone = "us-east-1a" 
  map_public_ip_on_launch = true 
} 
 
resource "aws_subnet" "dbsubnet" { 
  vpc_id            = aws_vpc.mulani-vpc.id 
  cidr_block        = "10.0.1.0/24" 
  availability_zone = "us-east-1b" 
} 
resource "aws_security_group" "web_sg" { 
  vpc_id = aws_vpc.mulani-vpc.id 
  description = "Security group for web server" 
 
  ingress { 
    from_port   = 80 
    to_port     = 80 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
  } 
 
  ingress { 
    from_port   = 22 
    to_port     = 22 
    protocol    = "tcp" 
    cidr_blocks = ["122.13.0.55/32"] 
  } 
 
  egress { 
    from_port   = 0 
    to_port     = 0 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
  } 
} 
output "public_ip" { 
  value = aws_instance.mulani-webserver.public_ip 
} 
 
output "private_ip" { 
  value = aws_instance.mulani-webserver.private_ip 
} 
 
resource "local_file" "ec2_instance_info" { 
content = "Instance name: ${aws_instance.mulani-webserver.tags["Name"]}\nPublic IP:${aws_instance.mulani-webserver.public_ip}\nPrivate IP: ${aws_instance.mulani-webserver.private_ip}" 
filename = "ec2_${aws_instance.mulani-webserver.tags["Name"]}.txt"   
} 