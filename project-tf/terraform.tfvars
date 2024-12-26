aws_region         = "us-west-2"
environment       = "production"
vpc_cidr          = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]
private_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
instance_type     = "t3.micro"