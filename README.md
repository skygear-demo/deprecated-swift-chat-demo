# Skygear Swift Chat Demo

This demo shows you how to create a chat app using Skygear Server with the chat
plugin. Using the chat plugin allows you to focus on making your app great
rather than backend implementation details.

This demo is implemented in Swift. In this demo, you will see how a Swift
app can make use of the [SKYKitChat](https://github.com/skygeario/chat-SDK-iOS)
framework to make a simple chat app.

## Demonstrated Features

* User sign-up and log-in using Skygear user account
* Search for other users using username
* Create a direct messaging conversation with other users
* Create a multi-user conversation
* Add and remove participants
* Send messages in a conversation
* Receive messages
* Show whether messages are received by other users
* Display a typing indicator when other users are typing

If you want to get an idea of how these features are implemented, you can
take a look at `MessagesViewController.swift` to get an idea. It is where
most of the features of the chat demo are implemented.

## Getting Started

Before you start, make sure you have Xcode 8 installed. You can get
a copy of Xcode from the Mac App Store or from [Apple Developer
website](https://developer.apple.com/).

You also need to configure your Skygear Server with the [chat
plugin](https://github.com/SkygearIO/chat/). The easiest way to get started
is to sign up an account on [Skygear Cloud](https://portal.skygear.io/). See
[documentation](https://docs.skygear.io/) for details.

To try out this demo:

1. Clone this repository
2. Open `Swift Chat Demo.xcworkspace` using Xcode (do not open with
   `.xcodeproj`)
3. Find and open `AppDelegate.swift`
4. In `application(_:,didFinishLaunchingWithOptions:)`, replace the Skygear
   endpoint address and API key
5. Run the project to build and run the app

Here is how `AppDelegate.swift` should look like when you have configured
your app with the Skygear Server endpoint and API key:

```objective-c
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.

    SKYContainer.default().configAddress("https://your-app-name.skygeario.com")
    SKYContainer.default().configure(withAPIKey: "c4b998d3f2064fc9881db8822fbcd5d7")
    return true
}
```
