# gate

Gate is Single Sign On platform for centralised authentication across Linux, OpenVPN and CAS.

Gate works by automating OpenVPN profile creation for you and also providing you with google multi factor authentication(MFA) integration. Gate provides single MFA Token authorisation across your organisation for following services.

> The entry point for self-signin is Google Email authentication. If you don't use Google Email authentication, you can point gate to any existing oAuth provider and it should straight forward.

1. Setup OpenVPN with Gate's authentication.
2. Automatically create VPN profiles for each of the users.
3. Provide you with JaSig CAS Custom Authentication Handler to authenticate with Gate SSO and in turn enabliing MFA for JaSig CAS.
4. Enable Linux authentication with gate-pam - which sits like small module with Linux and allow authentication.
5. Enable Name Service Switch on Linux - so that Gate User's can be discovered and authenticated on Linux.
6. **Access Control on Linux** Gate also allows you to control access to specific machines, like which hosts a user can login. And that can be controlled by reg-ex pattern on host name or IP addresses. Please note pattern * matches everything.

> Gate provides you with single sign on solution plus centralised user managment across your applications. It not only helps you control user's access but also makes most of it automated.

### Setup

Gate is a Rails application, compatible with JRuby.

#### Local

* Checkout gate
* Run `bundle install`
* Update database.yml
* Setup 5 environment variables

```
GATE_OAUTH_SECRET       - Your OAuth key
GATE_OAUTH_CLIENT_KEY   - Your client secret key
GATE_OAUTH_API_KEY      - Your API key
GATE_HOSTED_DOMAIN      - The hosted domain for gmail
GATE_SERVER_URL         - Gate server FQDN
GATE_CONFIG_SECRET      - Ruby required config secret key in production environment
GATE_EMAIL_DOMAIN       - Your company's domain for email address
```

* Run bundle exec rake db:create db:migrate db:seed
* Run bundle exec rake spec
* Setup gate with ruby/jruby in your favorite way, we recommend puma/nginx
* We will be including installation script or packages for this soon

Once Gate is setup, sign up with your user and you should see welcome page with a VPN profile download and VPN MFA Scanning.

If you want gate to setup VPN for your, then just install OpenVPN with easy rsa, Gate should just work fine with it.

> **NOTE** We will be putting some more effort to automate VPN setup using Gate as well. Or you can start creating pull request to help us with this.

#### Local dockerised setup

* Checkout gate
* Run `make init` to setup `.env` file.
* Setup proper env variable values in `.env` file.
* Run `make all` to build, run and run migrations
* Run `make rpsec` for running specs

### Modules

* pam_gate - for Linux/Unix
* nss_gate - for Linux Name Service Switch
* cas_gate - for JaSig CAS Server
* open_vpn_gate - for OpenVPN setup, it's not extracted yet.
* ssh_gate

### Setting up public key lookup

Given user has uploaded public key into gate

* Add following lines to your sshd_config - It's located at `/etc/ssh/sshd_config` on most linux distros

```
AuthorizedKeysCommand /usr/bin/gate_ssh.sh
AuthorizedKeysCommandUser nobody
```
* Add a file with following content to `/usr/bin/` with name `gate_ssh.sh` owned by root

```
#!/bin/sh

/usr/bin/curl -k --silent "https://<gate server name or IP>/profile/$1/key"
```

> **Please Note** Adjust URL for GateServer and test by executing `gate_ssh.sh <username>` to see if this prints the public key


### Administration

You might have to open rails console and give one user admin privileges by setting up `user.admin = true` in console. Then Gate will open up Administration URL for you. You can do following with Gate's admin web UI

* Enable/Disable User account
* Make user administrator
* Control what host user's are allowed to login via host patterns, by default they are allowed everyhost which starts with s-* (we use s- for staging, p- for production)
* Make user part of group, by default they are part of 'people' group.

> **DNS Alert** Please note gate heavily relies on DNS and host supplied IP addresses, so it authenticates against host's native IP address rather than natted IP address. It does reverse name lookup on supplied IP address, if that fails then it will be looking at matching IP address itself.





