# These are the terraform variables we will require
# Creating reusable variables to use in main.tf

# These are where are our access and secret keys to access the AWS is stored
# However we are going to set these in our local computers environment variables as this is secure and prevents us from revealing our confidential credentials to the world on GitHub.

variable "cidr_block" {
	type = string
	default = "166.66.0.0/16"
}

variable "pub_subnet_cidr_block" {
	type = string
	default = "166.66.1.0/24" 
}

variable "priv_subnet_cidr_block" {
	type = string
	default = "166.66.2.0/24" 
}

variable "avail_zone" {
	type = string
	default = "eu-west-1a" 
}

# Connection

variable "region" {
	type = string
	default = "eu-west-1" 
}

# CIDR blocks

variable "zero_cidr_block" {
	type = list
	default = ["0.0.0.0/0"]
}

variable "AMI" {
	type = "map"

	default = {
		ew-west-1 = "ami-04364f406bd3c73f0"
	} 
}

variable "PRIVATE_KEY_PATH" {
	type = string
	default = "london-region-key-pair"
}

variable "PUBLIC_KEY_PATH" {
	type = string
	default = "london-region-key-pair.pub"
}

variable "EC2_USER" {
	type = string
	default = "john_byrne"
}