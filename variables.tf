variable "profile" {
  type    = string
  default = "default"
}

variable "region-master" {
  type    = string
  default = "us-east-1"
}

variable "region-worker" {
  type    = string
  default = "us-west-2"
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
