#import "FlutterNotificationsUtilsPlugin.h"
#if __has_include(<flutter_notifications_utils/flutter_notifications_utils-Swift.h>)
#import <flutter_notifications_utils/flutter_notifications_utils-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_notifications_utils-Swift.h"
#endif

@implementation FlutterNotificationsUtilsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNotificationsUtilsPlugin registerWithRegistrar:registrar];
}
@end
