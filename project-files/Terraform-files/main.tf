provider "aws" {
    region ="ca-central-1"
}

locals{
    name = "home-lab"
}

#create vpc
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"


    tags = {
      Name = "${local.name}-vpc"

    }  
}

#create kepair
resource "aws_key_pair" "lab" {
    key_name = var.keypair_name
    public_key = file(var.path_to_keypair) 
}

#create public subnet
resource "aws_subnet" "public-subnet1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.az1
    
    tags = {
      Name = "${local.name}-public-subnet"

    }
}

#create private subnet 
resource "aws_subnet" "private-subnet1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private_subnet1_cidr
    availability_zone = var.az1

    tags = {
      Name = "${local.name}-private-subnet1"

    }
}

#create public subnet2
resource "aws_subnet" "public-subnet2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.az1
    
    tags = {
      Name = "${local.name}-public-subnet2"

    }
}

#create private subnet 2
resource "aws_subnet" "private-subnet2" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.private_subnet1_cidr
    availability_zone = var.az1

    tags = {
      Name = "${local.name}-private-subnet1"

    }
}

#create internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name ="${local.name}-igw"
    }
  
}

#create elastic ip
resource "aws_eip" "eip" {
    domain = "vpc"
    tags = {
      Name = "${local.name}-eip"
    }
}

#create natgateway
resource "aws_nat_gateway" "ngw" {
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.public-subnet1.id
    depends_on = [ aws_internet_gateway.igw ]

    tags = {
      Name = "${local.name}-ngw"
    }
  
}

#create route table
resource "aws_route_table" "pubrt" {
    vpc_id = aws_vpc.vpc.id
    
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#create route table
resource "aws_route_table" "privrt" {
    vpc_id = aws_vpc.vpc.id
    
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
}

#create public subnet route table association for public subnet1 
resource "aws_route_table_association" "public-subrt-asso" {
    subnet_id = aws_subnet.public-subnet1.id
    route_table_id = aws_route_table.pubrt.id
}

#create private subnet route table association privatesubnet1
resource "aws_route_table_association" "private-subrt-asso" {
    subnet_id = aws_subnet.private-subnet1.id
    route_table_id = aws_route_table.privrt.id
}


#create private subnet route table association privatesubnet2
resource "aws_route_table_association" "private-subrt-asso" {
    subnet_id = aws_subnet.private-subnet2.id
    route_table_id = aws_route_table.privrt.id
}


#create security group
resource "aws_security_group" "frontend-sg" {
    name = "frontend"
    description = "frontend_security_group"
    vpc_id = aws_vpc.vpc.id

    ingress = {
        description = "ssh access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]    
    }
    ingress {
        description = "HTTPS from vpc"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        description = "rds acess"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0" ]

    }
    egress = {
        from_port = 0
        to_port = 0
        protocol ="-1"
        cidr_block = ["0.0.0.0/0"]
    }
    tags = {
      Name ="${local.name}-frontend-sg"
    }

}

#create security groups for jenkins 
resource "aws_security_group" "jenkins-sg" {
    name = "jenkins"
    description = "jenkins_security_group"
    vpc_id = aws_vpc.vpc.id

    ingress = {
        description = "ssh access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]    
    }
    ingress {
        description = "HTTPS from vpc"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress {
        description = "tomcat acess"
        from_port = 8085
        to_port = 8085
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0" ]

    }
    egress = {
        from_port = 0
        to_port = 0
        protocol ="-1"
        cidr_block = ["0.0.0.0/0"]
    }
    tags = {
      Name ="${local.name}-jekins-sg"
    }

}

#create security groups for bastion
resource "aws_security_group" "bastion-sg" {
    name = "bastion"
    description = "bastion_security_group"
    vpc_id = aws_vpc.vpc.id

    ingress = {
        description = "ssh access"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]    
    }
    
    egress = {
        from_port = 0
        to_port = 0
        protocol ="-1"
        cidr_block = ["0.0.0.0/0"]
    }
    tags = {
      Name ="${local.name}-bastion-sg"
    }

}

#create security groups for backend
resource "aws_security_group" "backend-sg" {
    name = "backend"
    description = "backend_security_group"
    vpc_id = aws_vpc.vpc.id


    ingress {
        description = "mysql acess"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0" ]

    }
    egress = {
        from_port = 0
        to_port = 0
        protocol ="-1"
        cidr_block = ["0.0.0.0/0"]
    }
    tags = {
      Name ="${local.name}-backend-sg"
    }

}

#create jenkins server 
resource "aws_instance" "jenkins" {
  ami = var.ami_webserver
  instance_type = var.instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.public-subnet1.id
  key_name = aws_key_pair.lab.id
  vpc_security_group_ids = [ aws_security_group.jenkins-sg.id ]
  user_data = file("./jenkins.sh")

  tags = {
    Name ="${local.name}-jenkins"
  }
  
}

#create bastion server 
resource "aws_instance" "bastion" {
  ami = var.ami_webserver
  instance_type = var.instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.public-subnet1.id
  key_name = aws_key_pair.lab.id
  vpc_security_group_ids = [ aws_security_group.bastion-sg.id ]
  user_data = file("./bastion.sh")

  tags = {
    Name ="${local.name}-bastion"
  }
  
}

#create tomcat server 
resource "aws_instance" "tomcat" {
  ami = var.ami_webserver
  instance_type = var.instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.public-subnet1.id
  key_name = aws_key_pair.lab.id
  vpc_security_group_ids = [ aws_security_group.jenkins-sg.id ]
  user_data = file("./tomcat.sh")

  tags = {
    Name ="${local.name}-tomcat"
  }
  
}


#create database grp
resource "aws_db_subnet_group" "home-lab"{
  name = "home-lab_db_subnet_group"
  subnet_ids = [aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id]

  tags = {
    Name ="${local.name}-db-grp"
  }
  
}

#create mysql wordpress database 

resource "aws_db_instance" "logindash" {
  identifier = "logindash"
  db_subnet_group_name = aws_db_subnet_group.home-lab.id
  vpc_security_group_ids = [ aws_security_group.backend-sg.id ]
  allocated_storage = 10
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t3.micro"
  parameter_group_name = "default.msql.7"
  db_name = var.db_name
  username = var.db_password
  skip_final_snapshot = true
  publicly_accessible = false


  
}