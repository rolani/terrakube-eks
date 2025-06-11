# cert_manager
variable "email_address" {
    type = string
    description = "email address for cert manager"
}

# external_dns
variable "hosted_zone_arn" {
    type = string
    description = "route 53 hosted zone arn"
}