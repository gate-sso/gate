# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Use dotenv instead of figaro. This is a breaking change and warrant a major version release.
- All spiders are banned by default now in `robots.txt`
- When admin account become inactive, the admin status will automatically revoked.
- Admin can set expiration date on group assignment. This expiration date is optional, when not specified then it's a permanent assignment.

## [0.1.0] - 2019-05-20
### Changed
- Gate now uses semantic versioning.
