module routes

pub const openapi = 'openapi: 3.1.0
info:
  title: LiteDMS API
  description: A tiny service for storing text documents via REST API.
  version: 0.0.1
servers:
- url: /
tags:
- name: LiteDMS
  description: manage the service, maintain text documents
paths:
  /:
    get:
      summary: obtain API metadata
      responses:
        "200":
          description: successful result
          content:
            application/json:
              schema:
                type: object
                description: API metadata
                properties:
                  docs_url:
                    type: string
                    description: URL of the API documentation page
                  openapi_url:
                    type: string
                    description: URL of the API machine decription
                  version:
                    type: object
                    description: version information of the service
                    properties:
                      semver:
                        type: string
                        description: version number
                      rev:
                        type: string
                        description: git commit reference
                      compile_time:
                        type: string
                        description: date and time of the build
              examples:
                classes:
                  value:
                    docs_url: /docs
                    openapi_url: /openapi
                    version:
                      semver: 0.0.1
                      rev: 7c20d76
                      compile_time: 2023-12-28T20:16:35.888568+00:00
      tags:
      - LiteDMS
      operationId: apiRoot
      x-swagger-router-controller: LiteDMS
  /docs:
    get:
      summary: web page with the API documentation
      responses:
        "200":
          description: successful result
          content:
            taxt/html:
              examples:
                api:
                  value: |-
                    <!DOCTYPE html>
                    <html lang="en">
                      <head>
                        <meta charset="UTF-8">
                        <title>LiteDMS REST API</title>
      tags:
      - LiteDMS
      operationId: openAPI
      x-swagger-router-controller: LiteDMS
  /openapi:
    get:
      summary: API description according to the OpenAPI schema
      responses:
        "200":
          description: successful result
          content:
            application/json:
              schema:
                type: object
                description: API description
                properties:
                  openapi:
                    type: string
                    description: version of the OpenAPI format
              examples:
                classes:
                  value:
                    openapi: 3.1.0
      tags:
      - LiteDMS
      operationId: openAPI
      x-swagger-router-controller: LiteDMS
  /ping:
    get:
      summary: check that the service is running
      responses:
        "204":
          description: successful result
      tags:
      - LiteDMS
      operationId: ping
      x-swagger-router-controller: LiteDMS
    head:
      summary: check that the service is running
      responses:
        "204":
          description: successful result
      tags:
      - LiteDMS
      operationId: ping
      x-swagger-router-controller: LiteDMS
  /shutdown:
    post:
      summary: shut the service down (sending SIGTERM or SIGINT works too)
      responses:
        "204":
          description: successful result
      tags:
      - LiteDMS
      operationId: shutdown
      x-swagger-router-controller: LiteDMS
  /texts:
    get:
      summary: list text documents
      responses:
        "200":
          description: successful result
          content:
            application/json:
              schema:
                type: array
                description: list of document names
                items:
                  type: string
                  description: document names
              examples:
                classes:
                  value:
                    - classes/barbarian
                    - classes/wizard
            text/html:
              schema:
                type: array
                description: list of document names
                items:
                  type: string
                  description: document names
              examples:
                classes:
                  value: |-
                    <ul>
                      <li><a href="/texts/classes%2Fbarbarian">classes/barbarian</a></li>
                      <li><a href="/texts/classes%2Fwizard">classes/wizard</a></li>
                    </ul>
            text/plain:
              examples:
                classes:
                  value: |-
                    * classes/barbarian
                    * classes/wizard
      tags:
      - LiteDMS
      operationId: listTexts
      x-swagger-router-controller: LiteDMS
  /texts/{text_name}:
    head:
      summary: check presence of a text document
      parameters:
      - in: path
        name: text_name
        required: true
        type: string
        description: identifier of a text document
      responses:
        "204":
          description: text found
      tags:
      - LiteDMS
      operationId: checkText
      x-swagger-router-controller: LiteDMS
    get:
      summary: get a text document
      parameters:
      - in: path
        name: text_name
        required: true
        type: string
        description: identifier of a text document
      responses:
        "200":
          description: text sent
          content:
            text/plain:
              examples:
                classes:
                  value: |-
                    Barbarian
                    =========

                    A tall human tribesman strides through a blizzard, ...
      tags:
      - LiteDMS
      operationId: getText
      x-swagger-router-controller: LiteDMS
    put:
      summary: create a text document
      parameters:
      - in: path
        name: text_name
        required: true
        type: string
        description: identifier of a text document
      requestBody:
        description: contents of the text document
        content:
          text/plain:
            examples:
              classes:
                value: |-
                  Barbarian
                  =========

                  A tall human tribesman strides through a blizzard, ...
      responses:
        "201":
          description: text created
        "204":
          description: text updated
      tags:
      - LiteDMS
      operationId: createText
      x-swagger-router-controller: LiteDMS
    delete:
      summary: delete a text document
      parameters:
      - in: path
        name: text_name
        required: true
        type: string
        description: identifier of a text document
      responses:
        "204":
          description: text deleted
      tags:
      - LiteDMS
      operationId: deleteText
      x-swagger-router-controller: LiteDMS
'
