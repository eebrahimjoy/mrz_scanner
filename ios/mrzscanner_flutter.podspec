#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mrzscanner_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mrzscanner_flutter'
  s.version          = '0.0.1'
  s.summary          = 'MRZ Scanner flutter plugin'
  s.description      = <<-DESC
MRZ Scanner flutter plugin
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'

  s.preserve_paths = 'MRZScannerSDK.framework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework MRZScannerSDK' }
  s.vendored_frameworks = 'MRZScannerSDK.xcframework'

end
