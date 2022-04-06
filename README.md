# The Butterfly SDK for iOS

[![Version](https://img.shields.io/cocoapods/v/TheButterflySDK.svg?style=flat)](https://cocoapods.org/pods/TheButterflySDK)
[![License](https://img.shields.io/cocoapods/l/TheButterflySDK.svg?style=flat)](https://cocoapods.org/pods/TheButterflySDK)
[![Platform](https://img.shields.io/cocoapods/p/TheButterflySDK.svg?style=flat)](https://cocoapods.org/pods/TheButterflySDK)

[The Butterfly SDK](https://github.com/TheButterflySDK/About/blob/main/README.md) helps your app to take an active part in the fight against domestic violence.

## Installation

### 🔌 & ▶️

### Install via CocoaPods

- If you don't have CocoaPods In your project, visit here : https://cocoapods.org/
Just add the pod 'TheButterflySDK' similar to the following to your Podfile:

```
target 'MyApp' do
  pod 'TheButterflySDK', '1.0.2'
end

```

Then run a pod install in your terminal, or from CocoaPods app.

## Usage

To recognize your app in TheButterflySDK servers you'll need an application key. You can set it via code, as demonstrated here.

## Example

### Objective-C

```objective-c
// import the pod
#import "ButterflySDK.h"
    // Whenever you wish to open our screen, simply call:
    [ButterflySDK openReporterWithKey:@"YOUR_API_KEY"];
```

### Swift

```Swift
// import the pod
import TheButterflySDK
    // Whenever you wish to open our screen, simply call:
    ButterflySDK.openReporter(withKey: "YOUR_API_KEY")
```

## Integration tests
#### How?

You can easily verify your application key by simply running the SDK in **DEBUG mode**.

This will cause our servers to skip the part of sending reports to real live support centers, they will only verify the API key. Eventually you'll get success / failure result.


### Enjoy and good luck ❤️
