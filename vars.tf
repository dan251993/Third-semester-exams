#variable "ssh_key" {
 # description = "dankey"
  #type = string
#}

#variable "domain_names" {
 # type        = map(string)
  #description = "My Domain name and Subdomain name"
#}

variable "subnet"{
  type = list
  default = ["aws_subnet.pub1.id", "aws_subnet.pub2.id", "aws_subnet.pub3.id"]
}


