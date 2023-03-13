# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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
