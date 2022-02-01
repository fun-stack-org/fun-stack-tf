module "http" {
  count  = local.http == null ? 0 : 1
  source = "./http"

  prefix                = local.prefix
  domain                = local.domain_http
  allow_origins         = local.redirect_urls
  hosted_zone_id        = concat(data.aws_route53_zone.domain[*].zone_id, [null])[0]
  auth_module           = concat(module.auth, [null])[0]
  allow_unauthenticated = local.http.allow_unauthenticated

  source_dir    = local.http.source_dir
  source_bucket = local.http.source_bucket
  timeout       = local.http.timeout
  memory_size   = local.http.memory_size
  runtime       = local.http.runtime
  handler       = local.http.handler

  environment = merge(
    local.http.environment == null ? {} : local.http.environment,
    length(module.ws) == 0 ? {} : {
      FUN_WEBSOCKET_CONNECTIONS_DYNAMODB_TABLE = module.ws[0].connections_table
      FUN_WEBSOCKET_API_GATEWAY_ENDPOINT       = replace(module.ws[0].url, "wss://", "")
    },
    length(module.auth) == 0 ? {} : {
      FUN_AUTH_COGNITO_POOL_ID = module.auth[0].user_pool.id
    }
  )

  providers = {
    aws    = aws
    aws.us = aws.us
  }
}

resource "aws_iam_role_policy_attachment" "lambda_http_ws_connections" {
  count      = length(module.ws) == 0 || length(module.http) == 0 ? 0 : 1
  role       = module.http[0].http_role.name
  policy_arn = module.ws[0].connections_policy_arn
}

resource "aws_iam_role_policy_attachment" "lambda_http_auth_get_info" {
  count      = module.auth == null || module.http == null ? 0 : 1
  role       = module.http[0].http_role.name
  policy_arn = module.auth[0].get_info_policy_arn
}
