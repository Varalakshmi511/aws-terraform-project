variable "region" {
  description = "The AWS region to create resources in"
  default     = "us-west-2"
}

variable "ami" {
  description = "AMI ID for EC2 instances"
  default     = "ami-093a4ad9a8cc370f4"  # Example Amazon Linux AMI
}

variable "instance_type" {
  description = "EC2 Instance type"
  default     = "t2.micro"
}

variable "bucket_name" {
  description = "S3 bucket name"
  default     = "mine-terraform-bucket"
}
