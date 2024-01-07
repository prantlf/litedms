module routes

import config

pub const root = '{
  "docs_url": "/docs",
	"openapi_url": "/openapi",
	"version": "${config.version}"
}'
