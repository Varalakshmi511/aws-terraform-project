# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create Subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

# Create Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Attach Internet Gateway to Route Table
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Create S3 Bucket
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"
}

# IAM Role for EC2 Instance
resource "aws_iam_role" "ec2_role" {
  name = "ec2_s3_access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Policy for S3 Access
resource "aws_iam_policy" "s3_policy" {
  name        = "EC2S3AccessPolicy"
  description = "Allow EC2 to access S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      },
    ]
  })
}

# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

# Create IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# Create EC2 Instance with User Data (fetch data from S3)
resource "aws_instance" "web" {
  ami                   = var.ami
  instance_type         = var.instance_type
  subnet_id             = aws_subnet.main.id
  iam_instance_profile  = aws_iam_instance_profile.ec2_instance_profile.name # Attach IAM Instance Profile

  # EC2 Instance fetching data from S3
  user_data = <<-EOF
                #!/bin/bash
                aws s3 cp s3://${var.bucket_name}/myfile.txt /home/ec2-user/myfile.txt
              EOF

  tags = {
    Name = "WebServer"
  }
}
