provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

locals {
      instance_type_map = {
          stage = "t3.micro"
          prod = "t3.small"
      }
      instance_count_map = {
        stage = 1
        prod = 2
      }
      instances = {
          "t3.micro" = data.aws_ami.ubuntu.id
          "t3.small" = data.aws_ami.ubuntu.id
      }
    }

resource "aws_instance" "test2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type_map[terraform.workspace]
  network_interface {
    network_interface_id = aws_network_interface.test_if.id
    device_index         = 0
  }
  count = local.instance_count_map[terraform.workspace]
  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_instance" "web" {
    for_each = local.instances

    ami           = each.value
    instance_type = each.key

    lifecycle {
    create_before_destroy = true
    }
  }

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "test_if" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

terraform {
  backend "s3" {
    bucket = "netology-config"
    key    = "terraform-state"
    region = "us-east-1"
    dynamodb_table="terraform-state-locks"
  }
}

