# These are the terraform variables we will require
# Creating reusable variables to use in main.tf

# These are where are our access and secret keys to access the AWS is stored
# However we are going to set these in our local computers environment variables as this is secure and prevents us from revealing our confidential credentials to the world on GitHub.

variable "vpc_id" {
	type = string
	default = "vpc-07e47e9d90d2076da"
}

variable "public_subnet_cidr_block" {
	type = string
	default = "172.31.13.0/24"
}

variable "private_subnet_cidr_block" {
	type = string
	default = "172.31.12.0/24"
}

variable "public_subnet_ID" {
	type = list
    default = ["subnet-0dffdeaac45707f43"] 
}

variable "private_subnet_ID" {
	type = list
    default = ["subnet-0dccbbc92f01965dd"] 
}

# EC2 Variables

variable "instance_type" {
	type = string
	default = "t2.micro"
}

variable "ami_id" {
	type = string
	default = "ami-04364f406bd3c73f0"
}

# Connection

variable "region" {
	type = string
	default = "eu-west-1" 
}

