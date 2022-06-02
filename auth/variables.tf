variable "prefix" {
  type = string
}

variable "log_retention_in_days" {
  type = number
}

variable "domain" {
  type = string
}

variable "css_file" {
  type = string
}

variable "image_file" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "redirect_urls" {
  type = list(string)
}

variable "post_authentication_trigger" {
  type = object({
    source_dir    = string
    source_bucket = optional(string)
    handler       = string
    runtime       = string
    timeout       = number
    memory_size   = number
    environment   = optional(map(string))
  })
}

variable "post_confirmation_trigger" {
  type = object({
    source_dir    = string
    source_bucket = optional(string)
    handler       = string
    runtime       = string
    timeout       = number
    memory_size   = number
    environment   = optional(map(string))
  })
}

variable "pre_authentication_trigger" {
  type = object({
    source_dir    = string
    source_bucket = optional(string)
    handler       = string
    runtime       = string
    timeout       = number
    memory_size   = number
    environment   = optional(map(string))
  })
}

variable "pre_sign_up_trigger" {
  type = object({
    source_dir    = string
    source_bucket = optional(string)
    handler       = string
    runtime       = string
    timeout       = number
    memory_size   = number
    environment   = optional(map(string))
  })
}

locals {
  module_name = basename(abspath(path.module))
  prefix      = "${var.prefix}-${local.module_name}"
}
