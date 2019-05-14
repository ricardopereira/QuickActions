Pod::Spec.new do |s|
  s.name             = "QuickActions"
  s.version          = "4.0.0"
  s.summary          = "Swift wrapper for iOS Home Screen Quick Actions"
  s.homepage         = "https://github.com/ricardopereira/QuickActions"
  s.license          = 'MIT'
  s.author           = { "Ricardo Pereira" => "m@ricardopereira.eu" }
  s.source           = { :git => "https://github.com/ricardopereira/QuickActions.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ricardopereiraw'

  s.platform     = :ios, '8.1'
  s.requires_arc = true
  s.swift_version = '4.2'

  s.source_files = 'QuickActions/*.{h}', 'Source/**/*.{h,swift}'
  s.frameworks = 'UIKit'
end
