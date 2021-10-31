
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance-type" {
  type    = string
  default = "t2.micro"
}





variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

#Add the variable webserver-port to variables.tf
variable "webserver-port" {
  type    = number
  default = 80
}
