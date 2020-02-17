# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.8] - 2020-02-17
- Securing organisations configuration page

## [1.1.7] - 2020-02-24
### Fixed
- Fix audit trail when user removed from group

## [1.1.6] - 2020-01-14
### Changed
- Store session to db using active record instead of using cookies

## [1.1.5] - 2019-10-20
### Changed
- User API now also return `id`

## [1.1.4] - 2019-10-05
### Added
- API to add user to group (POST /api/v1/groups/:group_id/users)

## [1.1.3] - 2019-09-17
### Changed
- Update devise to version `4.7.1`.

## [1.1.2] - 2019-09-17
### Added
- Show email of group admin on group detail
- Show users join date to group on group detail

## [1.1.1] - 2019-09-02
### Changed
- Update nokogiri to version `1.10.4`.

## [1.1.0] - 2019-09-02
### Fixed
- Ensure that 'deactivated_at' on user is automatically set when we make user inactive
### Changed
- Improve access policy for actions on resources including profile, user, api resource, host machine, organisation
### Added
- Add endpoint entity to represent gate endpoint. Group will own endpoints, this mechanism will be used as an authorization for gate.
- Add api to deactivate user in gate (PATCH /api/v1/users/:id/deactivate).

## [1.0.5] - 2019-08-06
### Fixed
- Improve loading time when opening group and user show page

## [1.0.4] - 2019-07-17
### Fixed
- If a user don't have any VPNs, they should still be able to click download VPN without incurring exception
- Create missing tests for user model
- Optimize queries when fetching sysadmins

## [1.0.3] - 2019-07-16
### Fixed
- Fix nil pointer exception when group members response is nil

## [1.0.2] - 2019-07-15
### Fixed
- Optimize slow queries on vpn model

## [1.0.1] - 2019-07-15
### Added
- Add the ability to only fetch active user for `/api/v1/users/profile` API

## [1.0.0] - 2019-07-15
### Changed
- Use dotenv instead of figaro. This is a breaking change and warrant a major version release.
- All spiders are banned by default now in `robots.txt`
- When admin account become inactive, the admin status will automatically revoked.
- Admin can set expiration date on group assignment. This expiration date is optional, when not specified then it's a permanent assignment.

## [0.1.0] - 2019-05-20
### Changed
- Gate now uses semantic versioning.
