#import "DeviceInfoGetter.h"
#import <sys/utsname.h>

@implementation DeviceInfoGetter

+ (NSDictionary *) deviceInfo {
    UIDevice* device = [UIDevice currentDevice];
    struct utsname un;
    uname(&un);
    
    return @{
        @"name" : [device name],
        @"systemName" : [device systemName],
        @"systemVersion" : [device systemVersion],
        @"model" : [device model],
        @"localizedModel" : [device localizedModel],
        @"identifierForVendor" : [[device identifierForVendor] UUIDString],
        @"isPhysicalDevice" : [DeviceInfoGetter isDevicePhysical],
        @"utsname" : @{
            @"sysname" : @(un.sysname),
            @"nodename" : @(un.nodename),
            @"release" : @(un.release),
            @"version" : @(un.version),
            @"machine" : @(un.machine),
        }
    };
}

// return value is false if code is run on a simulator
+ (NSString*)isDevicePhysical {
#if TARGET_OS_SIMULATOR
  NSString* isPhysicalDevice = @"false";
#else
  NSString* isPhysicalDevice = @"true";
#endif

  return isPhysicalDevice;
}

@end
