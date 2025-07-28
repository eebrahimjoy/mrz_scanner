#import "MrzflutterpluginPlugin.h"
#if __has_include(<mrzscanner_flutter/mrzscanner_flutter-Swift.h>)
#import <mrzscanner_flutter/mrzscanner_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mrzscanner_flutter-Swift.h"
#endif

@implementation MrzflutterpluginPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMrzflutterpluginPlugin registerWithRegistrar:registrar];
}
@end
