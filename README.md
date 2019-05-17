# gate

![Build Status](https://api.travis-ci.org/gate-sso/gate.svg?branch=master)
[![Open Source Helpers](https://www.codetriage.com/gate-sso/gate/badges/users.svg)](https://www.codetriage.com/gate-sso/gate)

Gate is Single Sign On platform for centralised authentication across Linux, OpenVPN and CAS.

Gate works by automating OpenVPN profile creation for you and also providing you with google multi factor authentication(MFA) integration. Gate provides single MFA Token authorisation across your organisation for following services.

> The entry point for self-signin is Google Email authentication. If you don't use Google Email authentication, you can point gate to any existing oAuth provider and it should straight forward.

1. Setup OpenVPN with Gate's authentication.
2. Automatically create VPN profiles for each of the users.
3. Provide you with JaSig CAS Custom Authentication Handler to authenticate with Gate SSO and in turn enabling MFA for JaSig CAS.
4. Enable Linux authentication with gate-pam - which sits like small module with Linux and allow authentication.
5. Enable Name Service Switch on Linux - so that Gate User's can be discovered and authenticated on Linux.
6. **Access Control on Linux** Gate also allows you to control access to specific machines, like which hosts a user can login. And that can be controlled by reg-ex pattern on host name or IP addresses. Please note pattern * matches everything.

> Gate provides you with single sign on solution plus centralised user managment across your applications. It not only helps you control user's access but also makes most of it automated.

### Setup


#### Initializing Your Application
* Checkout gate
* Run `bundle install --path .local`
* Run `rake app:init` to copy your environment file (we use dotenv to manage environment variables)

#### Setting up your Environment Variables
* Setup your database (mysql) and update the following values (GATE_DB_HOST, GATE_DB_PORT, GATE_DB_USER, GATE_DB_PASSWORD)
* Setup your cache (redis) and update the following values (CACHE_DB, CACHE_HOST)
* Add dummy values to `PRODUCT_LIST`, can be any string (we would be removing this soon)
* Configuring oAuth
  * Head to https://console.developers.google.com/apis/api/plus.googleapis.com/overview?project=[ACCOUNT-ID]
 to setup your oAuth credentials, you might need to enable **Google+**
  * If you are running on `localhost:3000`, specify that for the `Authorized Javascript Origins` and `Authorized Redirect URIs` following which you can generate your client_id and client_secret
  * Update the client_id and client_secret to `GATE_OAUTH_CLIENT_ID` and `GATE_OAUTH_CLIENT_SECRET` respectively
  * Update your `GATE_SERVER_URL` to `http://localhost:3000`
  * Specify your email domain for `GATE_HOSTED_DOMAIN` and `GATE_HOSTED_DOMAINS`, for instance if you are your email address is  `test123@gmail.com` then the values would be `gmail.com`
  * Leave `SIGN_IN_TYPE` to empty value

#### Finishing Setup
To finish with your setup you just need to run `rake app:setup` this would setup your database and also run the inital set of tests to make sure you have a successful setup.

#### Additional Steps
Once Gate is setup, sign up with your user and you should see welcome page with a VPN profile download and VPN MFA Scanning.

If you want gate to setup VPN for your, then just install OpenVPN with easy rsa, Gate should just work fine with it.

> **NOTE** We will be putting some more effort to automate VPN setup using Gate as well. Or you can start creating pull request to help us with this.

#### Run on docker
* Build the docker image using `docker build -t gate .`
* Create and update `.env` file according to `.env.example` with appropriate values
* Run the image using `docker run -p 3000:3000 --env-file=.env -it gate`

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

#### Newrelic Support
If you want to enable Newrelic monitoring on your Gate deployment, you just have to create these additional keys on your environment variables:

```
NEWRELIC_LICENSE_KEY                - Your Newrelic license key
NEWRELIC_APP_NAME                   - Your application name (identifer) on Newrelic
NEWRELIC_AGENT_ENABLED              - Set it true if you want Newrelic agent to runs
```

#### Scheduler
Gate has several tasks that can be scheduled for maintenance purpose. Please see `config/scheduler.rb` to see the list of tasks.

You may have to run `whenever --update-crontab` to update cronjob so that it run these tasks. Gate utilize `whenever` gem for maintaining scheduled tasks, which in turn utilize cronjob as its backend.

### Development note
When you're in development and need to bypass oAuth sign in you can update your `SIGN_IN_TYPE` to `form`. Note that you still need to update `GATE_HOSTED_DOMAINS` to serve your email domain.

This option will provide you with sign in form in the homepage that you can fill with your email and name to sign in.
