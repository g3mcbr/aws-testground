# aws-testground
Basic Terreform AWS environment

## What does it do
  - Creates VPC
  - Creates Public and Private subnets using NAT gateway for private subnets
  - Creates ECS cluster (one node per Availability Zone, depends on how many AZ's are listed)
  - Creates 1 https service and 1 http service that redirects to https
