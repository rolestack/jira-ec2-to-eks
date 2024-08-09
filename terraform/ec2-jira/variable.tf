variable "atlassian-node" {
  type                            = map(string)
  default = {           
    "ami"                         = "ami-062cf18d655c0b1e8" # Ubuntu 24.04 LTS
    "instance_type"               = "t3.large"
    "root-volume-size"            = "50" # GiB
    "root-volume-type"            = "gp2"
    "additional-volume-size"      = "100" # GiB
    "additional-volume-type"      = "gp2"
  }
}