Pod::Spec.new do |s|
  s.name             = "QuickActions"
  s.version          = "7.0.0"
  s.summary          = "Swift wrapper for iOS Home Screen Quick Actions"
  s.homepage         = "https://github.com/ricardopereira/QuickActions"
  s.license          = 'MIT'
  s.author           = { "Ricardo Pereira" => "m@ricardopereira.eu" }
  s.source           = { :git => "https://github.com/ricardopereira/QuickActions.git", :tag => s.version.to_s }
  s.social_media_url = 'https://mastodon.social/@ricardopereira'

  s.platform     = :ios, '12.0'
  s.requires_arc = true
  s.swift_version = '5.0'

  s.source_files = 'QuickActions/*.{h}', 'Source/**/*.{h,swift}'
  s.frameworks = 'UIKit'
end
