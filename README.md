# The Butterfly SDK for iOS
[![Version](https://img.shields.io/cocoapods/v/TheButterflySDK.svg?style=flat)](https://cocoapods.org/pods/TheButterflySDK)
[![License](https://img.shields.io/cocoapods/l/TheButterflySDK.svg?style=flat)](https://cocoapods.org/pods/TheButterflySDK)
[![Platform](https://img.shields.io/cocoapods/p/TheButterflySDK.svg?style=flat)](https://cocoapods.org/pods/TheButterflySDK)


The Butterfly SDK help your app to take an active part in the fight against domestic violent.


## Installation
### 🔌 & ▶️

### Install via CocoaPods


Just add the pod 'TheButterflySDK' similar to the following to your Podfile:

```
target 'MyApp' do
  pod 'TheButterflySDK', '0.9.1'
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

## Comments

* If you don't have CocoaPods In your project, visit here : https://cocoapods.org/
