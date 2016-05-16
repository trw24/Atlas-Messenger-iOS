Pod::Spec.new do |s|
  s.name     = 'Atlas-Messenger'
  s.version  = '0.8.8'
  s.license  = 'Apache2'
  s.summary  = 'Atlas Messenger is the example app for Atlas, the Layer messaging UI component library.'
  s.homepage = 'https://github.com/layerhq/Atlas-Messenger-iOS'
  s.authors  = { 'Blake Watters' => 'blake@layer.com', 'Kevin Coleman' => 'kevin@layer.com', 'Klemen Verdnik' => 'klemen@layer.com' }
  s.source   = { :git => 'git@github.com:layerhq/Atlas-Messenger-iOS.git', :tag => "v#{s.version}" }
  s.requires_arc = true
  s.libraries = 'z'
  s.xcconfig = { 'ENABLE_NS_ASSERTIONS' => 'YES' }

  s.ios.frameworks = 'CFNetwork', 'Security', 'MobileCoreServices', 'SystemConfiguration'
  s.ios.deployment_target = '8.0'

  s.source_files = 'Code/**/*.{h,m}'
  s.public_header_files = 'Code/**/*.h'

  s.dependency 'Atlas'
  s.dependency 'ClusterPrePermissions', '~> 0.1'
  s.dependency 'SVProgressHUD'
end
