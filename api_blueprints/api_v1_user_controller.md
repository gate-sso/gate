# Fetch Users Detailed [api/v1/users/{emaiid}]

## Fetch Users Detailed [Get]
The purpose of this API is to get the details of a users with emailid.

+ Request
     + Headers

         Content-Type: application/json
         access_access_token: "Access-Token"

 + Response 200
      + Headers

         Content-Type: application/json

      + Body

         ```js
         {
             "user": {
                 "id": 67,
                 "email": "dev@a.c",
                 "created_at": "2018-01-05T07:14:22.000Z",
                 "updated_at": "2018-01-05T07:14:22.000Z",
                 "provider": null,
                 "uid": "5067",
                 "name": "Dev User",
                 "auth_key": "asdfasdfasfd",
                 "provisioning_uri": "otpauth://totp/dev@a.c?secret=asdfasdfasdf.",
                 "active": true,
                 "admin": true,
                 "home_dir": null,
                 "shell": null,
                 "public_key": null,
                 "user_login_id": "dev",
                 "product_name": null
             }
         }
         ```

## Fetch Users Detailed [Get] with invalid access token

+ Request
     + Headers

         Content-Type: application/json
         access_token: "Invalid-Access-Token"

 + Response 401
      + Headers

         Content-Type: application/json

## Fetch Users Detailed [Get] with emailid which is not present

+ Request
     + Headers

         Content-Type: application/json
         access_token: "Access-Token"

 + Response 404
      + Headers

         Content-Type: application/json
