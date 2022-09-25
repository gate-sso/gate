# Gate

![Build Status](https://api.travis-ci.org/gate-sso/gate.svg?branch=master)
[![Open Source Helpers](https://www.codetriage.com/gate-sso/gate/badges/users.svg)](https://www.codetriage.com/gate-sso/gate)

#### Please note that we are upgrading gate RAILS version, and it will have breaking changes
#### New RAILS 7 version will not be backward compatible and will not have many features
#### We are removing many features, just to support API TOKENS and VPN functionality

#### Please use [RAILS 5 Branch](https://github.com/gate-sso/gate/tree/RAILS_5_RELEASE) for backward compatibilty

> Gate now uses semantic versioning to add more visibility on breaking changes. For users, you might want to check [CHANGELOG.md](CHANGELOG.md). For contributors, check [CONTRIBUTING.md](CONTRIBUTING.md).

Gate is a single sign-on (SSO) platform for centralised authentication across Linux, OpenVPN and CAS.

Gate works by automating OpenVPN profile creation for you and also providing you with google multi-factor authentication (MFA) integration. Gate provides single MFA Token authorisation across your organisation. Following scenarios can be handled by Gate:

1. Setup OpenVPN with Gate authentication.
2. Automatically create VPN profiles for each users.
3. Provide you with JaSig CAS Custom Authentication Handler to authenticate with Gate SSO and in turn enabling MFA for JaSig CAS.
4. Enable Linux authentication with [pam_gate](https://github.com/gate-sso/pam_gate), which sits like a small module with Linux and allow authentication.
5. Enable Name Service Switch (NSS) on Linux, so that Gate users can be discovered and authenticated on Linux.
6. **Access Control on Linux** Gate also allows you to control access to specific machines, like which hosts a user can login. And that can be controlled by reg-ex pattern on host name or IP addresses. (Note: pattern * matches everything).

> The entry point for self sign-in is Google mail authentication. If you don't use Google mail authentication, you can point gate to any OAuth provider and it should work.

> Gate provides you with single sign-on solution plus centralised user management across your applications and services. Not only it helps in controlling users access but it also helps in making most of it automated.

### Modules

* [pam_gate](https://github.com/gate-sso/pam_gate) - Gate module for Linux PAM
* [nss_gate](https://github.com/gate-sso/nss_gate) - Gate module for Linux Name Server Switch (NSS)
* [cas_gate](https://github.com/gate-sso/cas_gate) - CAS Customer MFA authentication handler for Gate
* open_vpn_gate - for OpenVPN setup, it is not extracted yet.

## Development Setup

> We are in the process of improving Gate setup process, please check back for updated instructions.

### Manual Setup

#### Initializing Your Application

* Ensure that ruby is installed (>= 2.4) and `bundler` gem is installed.
* Clone [Gate repository](https://github.com/gate-sso/gate)
* Run `bundle install`
* Run `rake app:init` to create environment file based on sample (we use dotenv to manage environment variables).

#### Setting up OAuth (Optional)

> If you setup Gate for development purpose and you want to avoid setting up OAuth, you can fill `SIGN_IN_TYPE` environment variable with `form`. This option will provide you with sign-in form in Gate homepage that you can fill with e-mail and name to sign-in.

> Note that you still need to update `GATE_HOSTED_DOMAINS` to serve your e-mail domain.

Check [this guide](docs/oauth_setup.md) For detailed information on how to setup OAuth.

#### Setting up Database and Cache

* Install and setup database (mysql) and update the following values (`GATE_DB_HOST`, `GATE_DB_PORT`, `GATE_DB_USER`, `GATE_DB_PASSWORD`) on `.env`.
* Install and setup cache (redis) and update the following values (`CACHE_DB`, `CACHE_HOST`).

#### Finishing Steps

To finalize your setup you just need to run `rake app:setup`. This command will setup your database and also run inital set of tests to make sure you have a successful setup.

Once Gate is setup, sign-in with your user and you should see welcome page with VPN profile download and VPN MFA Scanning.

If you want Gate to setup VPN for you then just install OpenVPN with easy rsa. Gate should just work fine with it.

> **NOTE** We will be putting more effort to automate VPN setup using Gate as well. Or you can send a pull request to help us with this.

### Docker Setup

* Build docker image using `docker build -t gate .`
* Create and update `.env` file according to `.env.example` with appropriate values
* Run the image using `docker run -p 3000:3000 --env-file=.env -it gate`
* If you want use docker-compose run using `docker-compose up`

## Additional Topics

* [API Blueprint Test](docs/dredd_setup.md)
* [Additional Setup](docs/additional_setup.md)
* [Administration](docs/administration.md)
* [Newrelic Integration](docs/newrelic.md)

### Changelog

See [CHANGELOG.md](CHANGELOG.md)

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

### License

MIT License, See [LICENSE](LICENSE).
