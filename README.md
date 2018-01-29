# gate

![Build Status](https://api.travis-ci.org/gate-sso/gate.svg?branch=master)

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
* Setup below environment variables

```
GATE_OAUTH_CLIENT_ID                - Your OAuth client key
GATE_OAUTH_CLIENT_SECRET            - Your OAUTH client secret
GATE_HOSTED_DOMAINS                 - The hosted domains for gmail (comma separated)
GATE_SERVER_URL                     - Gate server FQDN
GATE_CONFIG_SECRET                  - Ruby required config secret key in production environment
GATE_EMAIL_DOMAIN                   - Your company's domain for email address
GATE_URL                            - Gate FQDN
GATE_ORGANIZATION_NAME              - Organization name to be reflected in vpn mobileconfig
GATE_ORGANIZATION_STATIC            - Organization static to be reflected in vpn mobileconfig
GATE_VPN_SSL_PVTKEY                 - Private key for signing vpn mobileconfig
GATE_VPN_SSL_CERT                   - SSL key for signing vpn mobileconfig
GATE_VPN_SSL_XSIGNED                - Cross signed key for signing vpn mobileconfig
PRODUCT_LIST                        - comma separated product list

GATE_SAML_IDP_ORGANIZATION_NAME     - company name
GATE_SAML_IDP_ORGANIZATION_URL      - company website url
GATE_SAML_IDP_RESPONSE_EXPIRY       - response timeout in seconds
GATE_SAML_IDP_SESSION_EXPIRY        - session timeout in seconds
GATE_SAML_IDP_X509_CERTIFICATE      - x509 cert
GATE_SAML_IDP_SECRET_KEY            - x509 key
GATE_SAML_IDP_FINGERPRINT           - x509 fingerprint
GATE_SAML_IDP_DATA_DOG_SSO_URL      - datadog service provider sso url
GATE_SAML_IDP_DATA_DOG_METADATA_URL - datadog service provider metadata url
```

* Run bundle exec rake db:create db:migrate db:seed
* Run bundle exec rake spec
* Setup gate with ruby/jruby in your favorite way, we recommend puma/nginx
* We will be including installation script or packages for this soon

Once Gate is setup, sign up with your user and you should see welcome page with a VPN profile download and VPN MFA Scanning.

If you want gate to setup VPN for your, then just install OpenVPN with easy rsa, Gate should just work fine with it.

> **NOTE** We will be putting some more effort to automate VPN setup using Gate as well. Or you can start creating pull request to help us with this.

### Setting Up with Google Authentication

You want to sign into the Google Cloud Console URL for the project and enabling Google+

```
https://console.developers.google.com/apis/api/plus.googleapis.com/overview?project=[ACCOUNT-ID]
```

Once you click activate, go to the following link

```
https://console.developers.google.com/apis/credentials?project=[ACCOUNT-ID]
```

Click `Create credentials > Client ID` and select Web Application

In `Authorized Javascript origins` put the your server url
In `Authorized Redirect URIs` put `<server url>/users/auth/google_oauth2/callback`

You can then put the clientId and clientSecret in the appropriate variables in `.env`

### Creating self signed x509 certificate for datadog SAML setup
> **NOTE** We will be putting some more effort to automate the integration for SAML Service Providers through UI.

Please run the following commands to generate certificate and key. You need to have openssl installed on your local System.
```
openssl genrsa -des3 -passout pass:x -out /tmp/server.pass.key 2048 && \
    openssl rsa -passin pass:x -in /tmp/server.pass.key -out /tmp/server.key && \
    rm /tmp/server.pass.key
```

```
    openssl req -new -key /tmp/server.key -out /tmp/server.csr -subj "/C=UK/ST=Warwickshire/L=Leamington/O=Test/OU=Example/CN=test-example.com"
```
> **NOTE** Please use appropriate values in place of C[Country Code], ST[State/Province], L[Location], O[Organization Name], OU[Organization Unit Name], CN[Company Domain Name]

```
    openssl x509 -req -days 365 -in /tmp/server.csr -signkey /tmp/server.key -out /tmp/server.crt
```
Use /tmp/server.crt for `GATE_SAML_IDP_X509_CERTIFICATE` and /tmp/server.key for `GATE_SAML_IDP_SECRET_KEY`

please run the following command to generate fingerprint[GATE_SAML_IDP_FINGERPRINT]
```
openssl x509 -in /tmp/server.crt -noout -sha256 -fingerprint
```



#### Local dockerised setup

* Checkout gate
* Run `make init` to setup `.env` file.
* Setup proper env variable values in `.env` file.
* Run `make all` to build, run and run migrations
* Run `make rpsec` or `make rspec <filename:line_no>` for running specs.
* Run `make routes` to list all the routes.
* Run `make shell` for shell access to app server.
* Run `make logs` to view logs of web container.
* Run `make kill` to remove daemonised containers.


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


#### Logs

The puma logs are in `shared/log/puma.stdout.log`  and `shared/log/puma.stderr.log` and the app logs are in `log/<env>.log`, some errors may be being written directly to stdout/stderr and may not be available in the application's log file
