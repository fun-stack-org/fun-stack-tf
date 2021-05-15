variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "domain" {
  type = string
}

variable "catch_all_forward_to" {
  type    = string
  default = null
}

variable "prod_workspace" {
  type    = string
  default = "default"
}
variable "dev_workspaces" {
  type    = list(string)
  default = ["default"]
}

variable "dev_setup" {
  type = object({
    local_website_url = string
    config_output_dir = string
  })
  default = null
}

variable "auth" {
  type = object({
  })
  default = null
}

variable "website" {
  type = object({
    source_dir          = string
    index_file          = optional(string)
    error_file          = optional(string)
    cache_files_regex   = optional(string)
    cache_files_max_age = optional(number)
  })
}

variable "api" {
  type = object({
    source_dir            = string
    handler               = string
    runtime               = string
    timeout               = number
    memory_size           = number
    allow_unauthenticated = optional(bool)
  })
  default = null
}

variable "budget" {
  type = object({
    limit_dollar = number
    notify_email = string
  })
  default = null
}

locals {
  module_name = basename(abspath(path.module))

  website = var.website == null ? null : defaults(var.website, {
    index_file          = "index.html"
    error_file          = "error.html"
    cache_files_regex   = ""
    cache_files_max_age = 31536000
  })

  api = var.api == null ? null : defaults(var.api, {
    allow_unauthenticated = false
  })

  prefix = "${local.module_name}-${terraform.workspace}"

  api_allow_unauthenticated = local.api == null ? true : local.api.allow_unauthenticated

  is_dev = var.dev_setup != null && contains(var.dev_workspaces, terraform.workspace)

  domain         = terraform.workspace == var.prod_workspace ? var.domain : "${terraform.workspace}.env.${var.domain}"
  domain_website = local.domain
  domain_auth    = "auth.${local.domain}"
  domain_ws      = "api.${local.domain}"
  redirect_urls = concat(
    ["https://${local.domain_website}"],
    local.is_dev ? [var.dev_setup.local_website_url] : []
  )

  api_zip_file        = "${path.module}/api.zip"
  authorizer_zip_file = "${path.module}/authorizer.zip"

  content_type_map = {
    html = "text/html",
    js   = "application/javascript",
    css  = "text/css",
    svg  = "image/svg+xml",
    jpg  = "image/jpeg",
    ico  = "image/x-icon",
    png  = "image/png",
    gif  = "image/gif",
    pdf  = "application/pdf"
  }

  app_config = <<EOF
window.AppConfig = {
  "environment": "${terraform.workspace}",
  "domain": "${local.domain_website}",
  "domainAuth": "${local.domain_auth}",
  "domainWS": "${local.domain_ws}",
  "region": "${data.aws_region.current.name}",
  "clientIdAuth": "${concat(module.auth[*].user_pool_client.id, [""])[0]}",
  "identityPoolId": "${concat(module.auth[*].identity_pool.id, [""])[0]}",
  "cognitoEndpoint": "${concat(module.auth[*].user_pool.endpoint, [""])[0]}",
  "allowUnauthenticated": ${local.api_allow_unauthenticated}
};
EOF
}
