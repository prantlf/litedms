# Demo Example

This example shows how to upload, list and get texts from [Dungeons and Dragons]. Selected 12 character classes ([data/classes]) and 4 guilds ([data/guilds]) are used as testing data. Helpful scripts runnable with [Node.js] or [Bun] ([scripts]) can be used instead of `curl`.

- [Upload Documents](#upload-documents)
- [List Documents](#list-documents)
- [Get a Document](#get-a-document)

## Upload Documents

Documents should be textual and nicely prepared, for example:

    Barbarian
    =========

    A tall human tribesman strides through a blizzard, ... who dared poach his people’s elk herd.

    ...

    Primal Instinct
    ---------------

    People of towns and cities take pride in their settled ways, ... where their tribes live and hunt.

* Title, subtitles and paragraphs are separated by two line breaks.
* A line starting and ending with a letter is considered a title. The first one is a document title, the others are chapter titles.
* Each chapter is considered to start on a new page.

Perform:

    node scripts/upload-documents.js

Behind:

This script loads filed `data/classes/*.txt` and `data/guilds/*.txt` and splits them to paragraphs according to rules above. Vectors are computed using [ollama] like this:

    curl -X PUT -s -w "%{http_code}" http://localhost:8020/texts/classes%2Fbarbarian \
      --data-binary @data/classes/barbarian.txt

    201

## List Documents

Print names of documents, which are available in the storage.

Perform:

    node scripts/list-documents.js

Behind:

The response will be formatted according to the `Accept` header in JSON, HTML or a plain text (default):

    curl -X GET -s http://localhost:8020/texts

    * classes/barbarian

## Get a Document

Print contents of a document, identified by its name in the storage.

Perform:

    node scripts/get-document.js classes barbarian

Behind:

The document name is the group and file names separated by a slash and that all URL-encoded:

    curl -X GET -s http://localhost:8020/texts/classes%2Fbarbarian

    Barbarian
    =========

    A tall human tribesman strides through a blizzard, ... who dared poach his people’s elk herd.

    ...

## Other Scripts

Remaining [scripts] demonstrate other use cases for the REST API. They have no parameters. They work with the embedding collection `dnd` and the LLM model `mistral`. The common configuration is in [scripts/shared/settings.js].

| Path                              | Description                                |
|:----------------------------------|:-------------------------------------------|
| delete-document.js <group> <file> | delete a document                          |
| delete-documents.js               | delete all documents found on the disk     |
| get-document.js <group> <file>    | print contents of a document               |
| list-documents.js                 | list names of all documents in hte storage |
| shutdown.js                       | shuts down the service                     |
| upload-document.js <group> <file> | uploads a document                         |
| upload-documents.js               | uploads all documents found on the disk    |
| shared/documents.js               | iterate over all documents on the disk     |
| shared/safe-fetch.js              | wrappers for network requests              |
| shared/settings.js                | common parameters for all scripts          |

### Configuration

The scripts recognise the following environment variables:

| Name        | Default                    | Description                      |
|:------------|:---------------------------|:---------------------------------|
| LITEDMS_URL | http://127.0.0.1:8020      | base URL of the document service |

[Dungeons and Dragons]: https://www.dndbeyond.com
[data/classes]: ../data/classes
[data/guilds]: ../data/guilds
[scripts]:  ../scripts
[Node.js]: https://nodejs.org
[Bun]: https://bun.sh
[ollama]: https://ollama.ai
[scripts/shared/settings.js]: ../scripts/shared/settings.js
