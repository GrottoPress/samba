# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.4.1] - 2026-02-12

### Fixed
- Fix potential authorization bypass in `Samba::Api::BearerLoginPipes`

## [1.4.0] - 2025-09-24

### Fixed
- Client: Consider valid tokens as logged in even if user is not in the database

### Added
- Add `Samba::LoginPipes#authorize?` callback

### Changed
- Do not create user when authenticating with `Samba::HttpClient`

## [1.3.2] - 2025-06-05

### Fixed
- Fix compile error calling `.compare_versions` with `Samba::VERSION`

## [1.3.1] - 2025-01-22

### Fixed
- Skip default validations in `Samba::ValidateUser` operation mixin

## [1.3.0] - 2024-12-18

### Added
- Add `OauthToken` server utility

## [1.2.0] - 2024-10-23

### Fixed
- Fix CI issues with Lucky v1.2
- Add support for Lucky v1.3
- Add support for Crystal v1.13
- Add support for Crystal v1.14

## [1.1.0] - 2023-12-18

### Added
- Add support for Lucky v1.1

### Changed
- Upgrade `GrottoPress/shield` shard to v1.1

## [1.0.2] - 2023-09-27

### Fixed
- Fix `could not determine data type of placeholder $3` error in Cockroach DB

## [1.0.0] - 2023-06-01

### Changed
- Upgrade `GrottoPress/shield` shard to v1.0

## [0.2.0] - 2022-03-13

### Added
- Add support for nilable `User#remote_id` columns

### Changed
- Upgrade to support *Lucky* v1.0
- Remove `client_id` parameter from `Samba::HttpClient#api_auth` methods
- Remove `client_id` parameter from `Samba::HttpClient#browser_auth` methods

### Changed
- Remove the explicit dependency on [Shield](https://github.com/GrottoPress/shield)

## [0.1.0] - 2023-01-06

### Added
- Add *Samba* Server
- Add *Samba* Client
