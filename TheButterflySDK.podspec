#
# Be sure to run `pod lib lint Butterfly.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TheButterflySDK'
  s.version          = '0.9.1'
  s.summary          = 'The Butterfly Host SDK will allow your app to host our butterfly report button.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This will cause your app to host the Butterfly project. This will give your app the ability to send hidden report from your app to The Butterfly's servers.
Just: place the Butterfly report button + use a valid API key = you're good to go!
                       DESC

  s.homepage         = 'https://github.com/TheButterflySDK/iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'perrchick' => 'perrchick@gmail.com' }
  s.source           = { :git => 'https://github.com/TheButterflySDK/iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ButterflyHost/Classes/**/*'
  
   s.resource_bundles = {
     'Butterfly' => ['ButterflyHost/Assets/resources/*.lproj/*.strings']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit' (for example) 
  s.dependency 'Reachability' # , '~> 2.3'
  
end
