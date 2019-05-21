# Additional Setup

### Setting-up Public Key Lookup

* Ensure user has uploaded their public key into gate.
* Add following lines to your sshd_config - It is located at `/etc/ssh/sshd_config` on most linux distros.

  ```
  AuthorizedKeysCommand /usr/bin/gate_ssh.sh
  AuthorizedKeysCommandUser nobody
  ```

* Add file with following content to `/usr/bin/` with name `gate_ssh.sh` owned by root

  ```
  #!/bin/sh
  /usr/bin/curl -k --silent "https://<gate server name or IP>/profile/$1/key"
  ```

> **Please Note:** Point URL to Gate server and test by executing `gate_ssh.sh <username>` to see if this prints the public key.
