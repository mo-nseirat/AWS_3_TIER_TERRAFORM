variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "public_subnets" {
  description = "Public Subnets CIDRs"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "private_subnets" {
  description = "private Subnets CIDRs"
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.200.0/24"]
}
variable "privaterds_subnets" {
  description = "private rds Subnets CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.201.0/24"]
}

variable "instance_type" {
    description = "The type of instance we will use"
    type = string 
    default = "t3.micro"
}

variable "db_username" {
  description = "RDS Username"
  type        = string
}

variable "db_password" {
  description = "RDS Password"
  type        = string
  sensitive   = true
  }
