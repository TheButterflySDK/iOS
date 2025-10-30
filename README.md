# The Butterfly SDK for iOS

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/TheButterflySDK/iOS/blob/main/LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg)](https://developer.apple.com/ios/)

[The Butterfly SDK](https://github.com/TheButterflyButton/About/blob/main/README.md) helps your app to take an active part in the fight against domestic violence.

## Installation

### 🔌 & ▶️

### Install via Swift Package Manager

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/TheButterflySDK/iOS.git`
3. Select the version you want to use (or use the latest version)
4. Click **Add Package**
5. Select your target and click **Add Package**

Alternatively, you can add it directly to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/TheButterflySDK/iOS.git", from: "x.y.z")
]
```

## Usage

To recognize your app in TheButterflySDK servers you'll need an application key. You can set it via code, as demonstrated here.

## Example

### Objective-C

```objective-c
// import the framework (choose one of these styles)
#import "TheButterflySDK.h"
// or
#import <TheButterflySDK.h>

/* ... */

// Whenever you wish to open our screen, simply call:
[ButterflySDK openReporterWithKey:@"YOUR_API_KEY"];
```

### Swift

```Swift
// import the framework
import TheButterflySDK

/* ... */

// Whenever you wish to open our screen, simply call:
ButterflySDK.openReporter(withKey: "YOUR_API_KEY")
```

## Integration tests
#### How?

You can easily verify your application key 🔑 by simply running the SDK in **DEBUG mode** 🐞.

This will cause our servers to skip the part of sending reports to real live support centers, they will only verify the API key. Eventually you'll get success / failure result.


### Enjoy and good luck ❤️
