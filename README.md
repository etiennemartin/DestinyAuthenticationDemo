# DestinyAuthenticationDemo

This project is a simple demo app that will show you how to authenticate with the Bungie API using OAuth. This assumes that you are attempting to use a confidential application type (i.e. You want the refresh tokens). This code was meant to be nice and simple and show how you can navigate the authentication process. It is not meant to be a re-usable solution. So I hope reading this code helps you in your process of building a really cool Destiny App!

# Why doesn't it work out of the box?

Before you can actually run this app you will need to make a few changes. Bungie requires that you sign up for an application key in order to identity yourself when calling their API. This is a defence mechanism so Bungie can protect itself against apps that may abuse their servers (DoS attacks and such).

So that being said head over to https://www.bungie.net/en/application and sign in to your bungie account and create an application. Make sure that your API key has the following specified (if it doesn't create a new one):

- API Key
- OAuth Authorization URL
- OAuth client_id
- OAuth client_secret

Also make sure that your OAuth Client Type is set to `Confidential` and that you specify a Redirect URL. I used `https://localhost/auth`.

Once you have that information you will need to look in the `ViewController.swift` and specify the values marked as `// <<< SETUP REQUIRED`. You can simply copy and paste your values in there.

That should be it! I really hope this demo app helps you navigate the authentication maze and allows you to build some awesome apps!
