# Administration

### Running Administrative Tasks

You can open rails console and give one user admin privilege by setting up `user.admin = true` in console. Then when you signed-in as that user, Gate will show you its administration UI. You can do the following with Gate admin UI:

* Enable/disable user account
* Make user administrator
* Control what host user's are allowed to login via host patterns, by default they are allowed everyhost which starts with `s-*` (we use `s-` for staging and `p-` for production)
* Make user part of group, by default they are part of 'people' group.

> **DNS Alert** Please note that gate rely heavily on DNS and host supplied IP addresses, so it authenticates against host native IP address rather than NAT'd IP address. It does reverse name lookup on supplied IP address, if that fails then it will be looking at matching IP address itself.

### Scheduler

Gate has some tasks that can be scheduled for maintenance purpose. Please see `config/scheduler.rb` to see the list of available tasks.

You can run `whenever --update-crontab` to update cronjob so that it run these tasks. Gate utilize `whenever` gem for maintaining scheduled tasks, which in turn utilize cronjob as its backend.

### Logs

Logs are stored here:

* Puma logs
  * `shared/log/puma.stdout.log`
  * `shared/log/puma.stderr.log`
* App logs
  * `log/<env>.log`

Some errors may be being written directly to stdout/stderr and may not be available in the application log file.
