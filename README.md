# Lightweight Document Storage

A tiny service for storing text documents via REST API.

* Runs in memory for great speed.
* Saves documents to a directory for simplicity.
* Little code for sustainable  maintenance.
* Easy to integrate to prototypes or small products.

There's a [demo example] included. This storage is integrated in the lightweight AI RAG solution [literag].

## Getting Started

Using Docker is easier than running the services built from the scratch. But building is easy too.

### Using Docker

For example, run a container for testing purposes exposing the port 8020 which will be deleted on exit:

    docker run -p 8020:8020 --rm -it ghcr.io/prantlf/litedms

For example, run a container named `litedms` in the background, persisting the data in `./litedms-storage` via the volume `/litedms/storage`:

    docker run -p 8020:8020 -v $PWD/litedms-storage:/litedms/storage \
      -dt --name litedms ghcr.io/prantlf/litedms

### Building from Scratch

Make sure that you have [V] and a C/C++ compiler installed before you continue. Clone this repository, build the binary executable and run it:

    git clone https://github.com/prantlf/litedms.git
    cd litedms
    v -enable-globals -o litedms .
    ./litedms

The `storage` directory will be created in the current directory as needed.

And the same task as above, only using Docker Compose (place [docker-compose.yml] to the current directory) to make it easier:

    docker-compose up -d

### Configuration

Runtime parameters of the service can be customised using the process environment variables below:

| Name                      | Default | Description                                 |
|:--------------------------|:--------|:--------------------------------------------|
| LITEDMS_COMPRESSION_LIMIT | 1024    | minimum response size to get compressed [b] |
| LITEDMS_CORS_MAXAGE       | 86400   | how long stays CORS preflighting valid [s]  |
| LITEDMS_HOST              | 0.0.0.0 | IP address to bind the server to            |
| LITEDMS_PORT              | 8020    | port number to bind the server to           |

A `.env` file with environment variables will be loaded and processed automatically.

## API

See the summary of the endpoints below, [API details] on a separate page. Run `litedms` and open http://localhost:8020/docs to inspect and try the available REST API endpoints live.

System endpoints:

| Method | Path      | Description                                                 |
|:-------|:----------|:------------------------------------------------------------|
| GET    | /         | obtain API metadata                                         |
| GET    | /ping     | check that the service is running                           |
| POST   | /shutdown | shut the service down (sending SIGTERM or SIGINT works too) |

Documentation endpoints:

| Method | Path     | Description                                     |
|:-------|:---------|:------------------------------------------------|
| GET    | /docs    | web page with the API documentation             |
| GET    | /openapi | API description according to the OpenAPI schema |

Endpoints for text documents:

| Method | Path              | Description                       |
|:-------|:------------------|:----------------------------------|
| GET    | /texts            | list text documents               |
| PUT    | /texts/:text_name | create a text document            |
| HEAD   | /texts/:text_name | check presence of a text document |
| GET    | /texts/:text_name | get a text document               |
| DELETE | /texts/:text_name | delete a text document            |

## License

Copyright (c) 2024 Ferdinand Prantl

Licensed under the MIT license.

[literag]: https://github.com/prantlf/literag
[demo example]: ./docs/DEMO.md
[V]: https://vlang.io
[docker-compose.yml]: ./docker-compose.yml
[API details]: ./docs/API.md
