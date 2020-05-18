# iOS Facebook Login Without the Facebook SDK

Facebook login implementation without the Facebook SDK.

## Full tutorial link

https://dev.to/marinbenc/implementing-facebook-login-on-ios-without-facebook-sdk-3k05

## Details

This implementation uses `ASWebAuthenticationSession` to securely show a web view pointing to the [Facebook web login UI](https://developers.facebook.com/docs/facebook-login/manually-build-a-login-flow). The web view is set up to redirect the user to `fbYOUR_APP_ID://authorize`. From there, the implemention will parse the redirect URL to grab the access token and "send" it to a fake server (you'll need to implement this yourself). Once it's sent, the implementation uses [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) to store the access token in the iOS keychain.

## Dependencies

 - [KeychainAccess 4.2.0](https://github.com/kishikawakatsumi/KeychainAccess)
 - Xcode 11.4
 - Swift 5.1

## Resources

A general overview of building a manual Facebook login flow:
https://developers.facebook.com/docs/facebook-login/manually-build-a-login-flow/

Facebook security best practices:
https://developers.facebook.com/docs/facebook-login/security

How to handle expired access tokens:
https://developers.facebook.com/blog/post/2011/05/13/how-to--handle-expired-access-tokens/

General information about access tokens:
https://developers.facebook.com/docs/facebook-login/access-tokens

Handling access token errors:
https://developers.facebook.com/docs/facebook-login/access-tokens/debugging-and-error-handling
