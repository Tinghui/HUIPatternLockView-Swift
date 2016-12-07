Pod::Spec.new do |s|
  s.name                = "HUIPatternLockView-Swift"
  s.version             = "2.0.1"
  s.summary             = "A pattern lock view for iOS"
  s.homepage            = "https://github.com/Tinghui/HUIPatternLockView-Swift"
  s.license             = { :type => "MIT", :file => "LICENSE.md" }
  s.author              = { 'Tinghui' => 'tinghui.zhang3@gmail.com' }
  s.platform            = :ios, '8.0'
  s.requires_arc        = true
  s.source_files        = "Source/*.swift"
  s.source              = { :git => "https://github.com/Tinghui/HUIPatternLockView-Swift.git", :tag => s.version }
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
end
