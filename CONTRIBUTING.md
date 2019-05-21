# Contributing Guidelines

## Releasing Gate

> Gate uses semantic versioning, check [this page](https://semver.org/) for more details on how to bump the version number.

Steps on releasing Gate.

1. Bump version on [VERSION](VERSION) file.
2. Add appropriate changelogs on [CHANGELOG.md](CHANGELOG.md) file. Please follow existing format.
3. Tag the commit by the new version number and push it, travis will automatically build and release Gate.
