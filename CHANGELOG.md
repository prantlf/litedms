# Changes

## [0.3.0](https://github.com/prantlf/litedms/compare/v0.2.0...v0.3.0) (2024-05-10)

### Features

* Move mappable storage volume from /litedms/storage to /storage ([4c501aa](https://github.com/prantlf/litedms/commit/4c501aa7b90a3d686f5137237ea3708370b3a76d))
* Support method HEAD for /ping ([d2e4250](https://github.com/prantlf/litedms/commit/d2e42502999970fc4a4a7dc84a96902cc0fc3922))
* Add healthcheck to docker-compose example ([4879aec](https://github.com/prantlf/litedms/commit/4879aec97fa807d12787371c7fe5ae215b349c25))

### BREAKING CHANGES

Replace the target volume mapping `/litedms/storage`
with the new value `/storage`. (Internally, the executable moved from
`/litedms/litedms` to `/litedms`.

## [0.2.0](https://github.com/prantlf/litedms/compare/v0.1.1...v0.2.0) (2024-05-07)

### Features

* Let storage directory set by LITEDMS_STORAGE ([cae9d3a](https://github.com/prantlf/litedms/commit/cae9d3a8f9b0b724fa326ee85e9525a3adf12a91))

## [0.1.1](https://github.com/prantlf/litedms/compare/v0.1.0...v0.1.1) (2024-05-06)

### Bug Fixes

* Publish packages and docker image ([82b86f1](https://github.com/prantlf/litedms/commit/82b86f1e3f6748cc378726dd4944662d22d7a6c0))

## [0.1.0](https://github.com/prantlf/litedms/compare/v0.0.1...v0.1.0) (2024-02-05)

### Features

* Add more debug logging ([788477a](https://github.com/prantlf/litedms/commit/788477affb0e50e3f2b0121be31ada3e5204dd1a))
* Shut down gracefully on SIGINT and SIGTERM ([f38febe](https://github.com/prantlf/litedms/commit/f38febe7622cd9337469d5ef5707b86f09ef3bd3))

### Bug Fixes

* Switch from picoev to net.http ([de652d3](https://github.com/prantlf/litedms/commit/de652d3c0a7bff2b0c0e2dfb4b0a29e48e17ff5e))

## [0.0.1](https://github.com/prantlf/litedms/compare/v0.0.0...v0.0.1) (2024-01-07)

### Bug Fixes

* Initial release ([53b25b3](https://github.com/prantlf/litedms/commit/53b25b3e4ad285623d45ae1390f45093cee886c4))

## 0.0.0 (2024-01-07)

Prepare a new project.
