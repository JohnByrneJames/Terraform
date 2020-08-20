# These are the terraform variables we will require
# Creating reusable variables to use in main.tf

# These are where are our access and secret keys to access the AWS is stored
# However we are going to set these in our local computers environment variables as this is secure and prevents us from revealing our confidential credentials to the world on GitHub.

variable "vpc_id" {
	type = string
	default = "vpc-07e47e9d90d2076da"
}

