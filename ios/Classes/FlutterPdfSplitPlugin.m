#import "FlutterPdfSplitPlugin.h"
#if __has_include(<flutter_pdf_split/flutter_pdf_split-Swift.h>)
#import <flutter_pdf_split/flutter_pdf_split-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_pdf_split-Swift.h"
#endif

@implementation FlutterPdfSplitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPdfSplitPlugin registerWithRegistrar:registrar];
}
@end
