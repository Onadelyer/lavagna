variable "vpc-id" {
  type = string
}

variable "public-subnets" {
  type = list(string)
}

variable "lb-security-group" {
  type = string
}

variable "beanstalk-instance-sg" {
  type = string
}

variable "bucket" {
  type = string
}

# variable "bucket-key"{
#   type = string
# }

variable "rds-endpoint"{
  type = string
}

variable "rds-db-name"{
  type = string
}

variable "rds-db-username" {
  type = string
}

variable "rds-db-password" {
  type = string
}