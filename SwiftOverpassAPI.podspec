#
# Be sure to run `pod lib lint SwiftOverpassAPI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftOverpassAPI'
  s.version          = '0.1.1'
  s.summary          = 'Query, process, and visualize Overpass API data.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
'SwiftOverpassAPI is an interface for writing queries to Overpass API, a read only API for OpenStreetMap data. The returned results will be processed and ready for visualization. A simple MapKit visualization struct has been included for those who want to get started quickly'
                       DESC

  s.homepage         = 'https://github.com/ebsamson3/SwiftOverpassAPI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ebsamson3' => 'ebsamson3@gmail.com' }
  s.source           = { :git => 'https://github.com/ebsamson3/SwiftOverpassAPI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
	s.swift_version = '5.0'

  s.source_files = 'Source/**/*.swift'
  
  # s.resource_bundles = {
  #   'SwiftOverpassAPI' => ['SwiftOverpassAPI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
