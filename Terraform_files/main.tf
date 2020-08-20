# This is to launch an AMI on AWS using Terraform

# What do we want to do any where would we like to create the instance

# Syntax for terraform is similar to json - we use { to write block of code} 

provider "aws" {
# Which region do we have the AMI available - [Ireland | eu-west-1] 
	region = "eu-west-1"
}

# Create a instance - launch an instance from the AMI we have provided
resource "aws_instance" "app_instance" {
	ami = "ami-04364f406bd3c73f0"

# What kind of Instance do we want to create [t2.micro]
	instance_type = "t2.micro"

# Assign the instance a public ip
	associate_public_ip_address = true

# Assign the instance a tag E.G. a name
	tags = {
		Name = "Eng67.John.Terraform"
	}
} 