# OAuth Setup

* Ensure that you have a registered account in Google Cloud Platform.
* Enable `plus.googleapis.com` API at the following URL:

    https://console.developers.google.com/apis/api/plus.googleapis.com/overview?project=[YOUR-PROJECT-NAME]
* Create OAuth Client ID credentials at the following URL (with type `Web Application`):

    https://console.developers.google.com/apis/credentials?project=[YOUR-PROJECT-NAME]
* Configure Restrictions (Origins & Redirect URIs). We cannot use localhost in this section, therefore you can specify any arbitrary domain then configure your computer `/etc/hosts` file.

    Example if you are running on `http://example.com:4000`:
    * http://example.com:4000
    * http://example.com:4000/users/auth/google_oauth2/callback
* Put client_id and client_secret on `GATE_OAUTH_CLIENT_ID` and `GATE_OAUTH_CLIENT_SECRET` respectively
* Update your `GATE_SERVER_URL` to `http://example.com:4000`
* Specify your e-mail domain on `GATE_HOSTED_DOMAIN` and `GATE_HOSTED_DOMAINS`, for instance if your e-mail address is  `test123@gmail.com` then the value should be `gmail.com`
* Leave `SIGN_IN_TYPE` empty
