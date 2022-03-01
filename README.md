# TheButterflyHost iOS SDK
[![Version](https://img.shields.io/cocoapods/v/TheButterflySDK.svg?style=flat)](https://cocoapods.org/pods/TheButterflySDK)
[![License](https://img.shields.io/cocoapods/l/TheButterflySDK.svg?style=flat)](https://cocoapods.org/pods/TheButterflySDK)
[![Platform](https://img.shields.io/cocoapods/p/TheButterflySDK.svg?style=flat)](https://cocoapods.org/pods/TheButterflySDK)


TheButterflyHost help you app to take part in the fight against domestic violent.


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

To recognize your app in ButterflyHostSDK servers you need an application key, you can set it via code.
In order to present the view, ButterflyHostSDK require an the current UIViewController.

#### Example

```Objective - c
// import the pod
#import "ButterflySDK.h"
    // Whenever you wish to open our screen, simply call:
    [ButterflySDK openReporterWithKey:@"YOUR_API_KEY"];
```

```Swift
// import the pod
import ButterflyHost
    // Whenever you wish to open our screen, simply call:
    ButterflySDK.openReporterWithKey(withKey:"YOUR_API_KEY")
```

## Comments

* If you don't have CocoaPods In your project, visit here : https://cocoapods.org/
* check out Localization suuport and add it to your project !
