Pod::Spec.new do |s|
  s.name             = 'duo_dynamic_sizing'
  s.version          = '2.0.2'
  s.summary          = 'Hinge, fold and camera data for the iPhone Duo.'
  s.description      = 'Reads the iPhone Duo hinge, reserved regions, size classes and vertical bar edge for duo_dynamic_sizing.'
  s.homepage         = 'https://github.com/Abojawdat/iPhone-Duo-package-'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Abojawdat' => 'https://github.com/Abojawdat' }
  s.source           = { :path => '.' }
  s.source_files     = 'duo_dynamic_sizing/Sources/duo_dynamic_sizing/**/*.swift'
  s.resource_bundles = { 'duo_dynamic_sizing_privacy' => ['duo_dynamic_sizing/Sources/duo_dynamic_sizing/PrivacyInfo.xcprivacy'] }
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
