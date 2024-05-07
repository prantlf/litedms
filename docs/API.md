# REST API Endpoints

- [System](#system) - control the server
- [Texts](#texts) - maintain text documents

## System

| Method | Path | Description         |
|:-------|:-----|:--------------------|
| GET    | /    | obtain API metadata |

Example:

    curl -X GET -s http://localhost:8020

    { "docs_url": "/docs", "openapi_url": "/openapi",
      "version": { "semver": "0.0.1", "rev": "7c20d76",
                   "compile_time": "2023-12-28T20:16:35.888568+00:00" } }

| Method | Path  | Description                    |
|:-------|:------|:-------------------------------|
| GET    | /ping | check if the server is running |

Example:

    curl -s -w "%{http_code}" http://localhost:8020/ping

    204

| Method | Path      | Description           |
|:-------|:----------|:----------------------|
| POST   | /shutdown | shut the service down |

Example:

    curl -X POST -s -w "%{http_code}" http://localhost:8020/shutdown

    204

## Texts

| Method | Path   | Description         |
|:-------|:-------|:--------------------|
| GET    | /texts | list text documents |

Example:

    curl -X GET -s http://localhost:8020/texts

    * classes/barbarian

| Method | Path              | Description            |
|:-------|:------------------|:-----------------------|
| PUT    | /texts/:text_name | create a text document |

Example:

    curl -X PUT -s -w "%{http_code}" http://localhost:8020/texts/classes%2Fbarbarian \
      --data-binary @data/classes/barbarian.txt

    201

| Method | Path              | Description                       |
|:-------|:------------------|:----------------------------------|
| HEAD   | /texts/:text_name | check presence of a text document |

Example:

    curl -X HEAD -s -w "%{http_code}" http://localhost:8020/texts/classes%2Fbarbarian

    204

| Method | Path              | Description         |
|:-------|:------------------|:--------------------|
| GET    | /texts/:text_name | get a text document |

Example:

    curl -X GET -s http://localhost:8020/texts/classes%2Fbarbarian

    Barbarian
    =========

    A tall human tribesman strides through a blizzard, ...

| Method | Path              | Description            |
|:-------|:------------------|:-----------------------|
| DELETE | /texts/:text_name | delete a text document |

Example:

    curl -X DELETE -s -w "%{http_code}" http://localhost:8020/texts/classes%2Fbarbarian

    204
