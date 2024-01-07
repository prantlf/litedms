module routes

pub const docs = '<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>LiteDMS REST API</title>
    <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@5.10.5/swagger-ui.css">
    <script src="https://unpkg.com/swagger-ui-dist@5.10.5/swagger-ui-standalone-preset.js"></script>
    <script src="https://unpkg.com/swagger-ui-dist@5.10.5/swagger-ui-bundle.js"></script>
	</head>
  <body>
    <div id="swagger-ui"></div>
    <script>
			window.onload = function () {
				window.ui = SwaggerUIBundle({
					url: "/openapi", dom_id: "#swagger-ui", deepLinking: true, layout: "StandaloneLayout",
					presets: [SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset],
					plugins: [SwaggerUIBundle.plugins.DownloadUrl]
				})
			}
    </script>
  </body>
</html>'
