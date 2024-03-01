provider "aws" {
    region = "us-east-2"
}

variable "cidr_block" {
    default = "10.0.0.0/16"
}

resource "aws_vpc" "terraform_project_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "terraform_project_vpc"
  }
}

resource "aws_key_pair" "terraform_key_pair" {
    key_name = "terraform_key_pair"
    public_key = file("~/.ssh/id_rsa.pub")  
}
resource "aws_subnet" "terraform_project_subnet" {
  vpc_id     = aws_vpc.terraform_project_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform_project_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.terraform_project_vpc.id
  
}

resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.terraform_project_vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.terraform_project_subnet.id
    route_table_id = aws_route_table.rt.id
  
}

resource "aws_security_group" "sg_terraform" {
    name = "sg_terraform"
    vpc_id = aws_vpc.terraform_project_vpc.id
    
    ingress {
      from_port = "80"
      to_port = "80"
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }    
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [ "0.0.0.0/0" ]
    } 
    tags = {
      name = "sg_terraform"
    }
}

resource "aws_instance" "appliacation_instance" {
    ami = "ami-0f5daaa3a7fb3378b"
    instance_type = "t2.micro"
    key_name = aws_key_pair.terraform_key_pair.id
    vpc_security_group_ids = [aws_security_group.sg_terraform.id]
    subnet_id = aws_subnet.terraform_project_subnet.id

    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = file("~/.ssh/id_rsa")
    }

    provisioner "file" {
      source = "C:/Users/17033/Desktop/terraform_practice/Day_05/app.py"
      destination = "/home/ubuntu/app.py"
    }

    provisioner "remote-exec" {
        inline = [ 
            "sudo apt update -y",
            "sudo apt-get install -y python3-pip",
            "cd ~/",
            "sudo pip3 install flask",
            "sudo python3 app.py"

         ]
      
    }
}