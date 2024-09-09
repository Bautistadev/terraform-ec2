#CREAMOS VPC
resource "aws_vpc" "terraform-vpc"{
    cidr_block = "10.0.0.0/16" #rango de direcciones de ip
    
    tags = {
        Name = "terraformvpc"
    }
}

#CREACION DE SUBNET 
resource "aws_subnet" "terraform-subnet-public"{
    #for_each                            = var.subnets
    vpc_id                              = aws_vpc.terraform-vpc.id    #ID DE LA VPC
    cidr_block                          = "10.0.1.0/24"        #rango de direcciones ip para la subred
    availability_zone                   = "us-east-1a"  #zona de disponibilidad
    map_public_ip_on_launch             = true

    tags = {
        Name    = "Subnet1"
        owner   = "Bautista Basilio"
    }
}

#CREACION DEL INTERNET GATEWAY
resource "aws_internet_gateway" "terraform-internet-gateway" {
    vpc_id          = aws_vpc.terraform-vpc.id #ID DE LA VPC

    tags = {
          Name = "terraformgateway"
    }
}


#CREACION DE TABLA DE ENRUTAMIENTO
resource "aws_route_table" "terraform-route-table" {
    vpc_id          = aws_vpc.terraform-vpc.id #ID DE LA VPC

    route {
        cidr_block = "0.0.0.0/0"                                            #RUTA PREDETERMINADA PARA TODO TRAFICO
        gateway_id = aws_internet_gateway.terraform-internet-gateway.id     #ID DE LA PUERTA DE ENLACE A INTERNET
    }

    tags = {
          Name = "terraformroutetable"
    }
}   

#ASOCIAMOS TABLA DE ENRRUTAMIENTO CON LAS VPC
resource "aws_route_table_association" "terraform-route-table-association" {
    subnet_id       = aws_subnet.terraform-subnet-public.id
    route_table_id  = aws_route_table.terraform-route-table.id

}

#CREAMOS GRUPO DE SEGURIDAD
resource "aws_security_group" "terraform-ec2-security-group" {
    name            = "terraform-ec2-security-group"
    description     = "GRUPO DE SEGURIDAD CORRESPONDIENTE A LA VPC CREADA"
    vpc_id          = aws_vpc.terraform-vpc.id

    tags = {
          Name = "terraformsecuritygroup"
    }

    #DEFECTO
    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     =  ["0.0.0.0/0"]
    }


    #DEFECTO
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks      =  ["0.0.0.0/0"]
    }
 
}

#CREAMOS LA INSTANCIA DE EC2
resource "aws_instance" "terraform_ec2" {
    ami            = "ami-0e86e20dae9224db8"
    instance_type       = "t2.micro"
    subnet_id            = aws_subnet.terraform-subnet-public.id
    key_name            = "AWS_BOOTCAMP"

    vpc_security_group_ids = [aws_security_group.terraform-ec2-security-group.id]

    tags = {
        Name = "Ec2 PRUEBA"
    }

    user_data = <<-EOF
                    #!/bin/bash
                    apt update -y
                    apt install -y apache2
                    systemctl enable apache2

                EOF
}