#
# Be sure to run `pod lib lint WXYMediator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "WXYMediator"
  s.version          = "0.1.0"
  s.summary          = "A Component Framework"

  s.description      = "A Component Framework"

  s.homepage         = "https://github.com/wuxulome/WXYMediator.git"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "wuxu" => "wuxulome@gmail.com" }
  s.source           = { :git => "https://github.com/wuxulome/WXYMediator.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.ios.deployment_target = "6.0"
  s.requires_arc = true

  s.source_files = 'WXYMediator/*.{h,m}'

  s.frameworks = 'Foundation'
  
end