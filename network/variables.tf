variable resourcegroup_name {
    type = "string"
    default = "tfresourcegrpdev"
}
variable vnet_name {
    type = "string"
    default = "myVnet"
}
variable subnet_name1 {
    type = "string"
    default = "frontend"
}
variable subnet_name2 {
    type = "string"
    default = "backend"
}
variable networksecuritygrp_name1 {
    type = "string"
    default = "front_nsg"
}

variable networksecuritygrp_name2 {
    type = "string"
    default = "back_nsg"
}