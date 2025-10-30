# The Butterfly SDK for iOS

[![Version](https://img.shields.io/cocoapods/v/TheButterflySDK.svg?style=flat)](https://cocoapods.org/pods/TheButterflySDK)
[![License](https://img.shields.io/cocoapods/l/TheButterflySDK.svg?style=flat)](https://github.com/TheButterflySDK/iOS/blob/main/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/TheButterflySDK.svg?style=flat)](https://cocoapods.org/pods/TheButterflySDK)

[The Butterfly SDK](https://github.com/TheButterflyButton/About/blob/main/README.md) helps your app to take an active part in the fight against domestic violence.

## Installation

### 🔌 & ▶️

### Install via CocoaPods

- If you don't have CocoaPods In your project, visit here : https://cocoapods.org/
Just add the pod 'TheButterflySDK' similar to the following to your Podfile:

```
target 'MyApp' do
  pod 'TheButterflySDK', '2.1.2'
end

```

Then run a pod install in your terminal, or from CocoaPods app.

## Usage examples

To recognize your app in TheButterflySDK servers you'll need an application key. You can set it via code, as demonstrated here.

### Forward the deep link to the SDK for handling


#### Objective-C

```objective-c
// import the pod
#import "ButterflySDK.h"

/* ... */

// Whenever you wish to open our screen, simply call:
[ButterflySDK openWithKey:@"YOUR_API_KEY"];
```

#### Swift

```Swift
// import the pod
import TheButterflySDK

/* ... */

// Whenever you wish to open our screen, simply call:
ButterflySDK.open(withKey: "YOUR_API_KEY")
```

### Forward the deep link to the SDK for handling

#### Swift 🤓
```swift
// import the pod
import TheButterflySDK

/* ... */

// Whenever you need to handle a deep link in your app:
ButterflySDK.handleIncomingURL(URL(string: "https://some.website?someParam=someValue&otherParam=otherValue"), apiKey: "YOUR_API_KEY")
```

## Integration tests
#### How?

You can easily verify your application key 🔑 by simply running the SDK in **DEBUG mode** 🐞 and start a chat with Betty 💬


### Enjoy and good luck ❤️
