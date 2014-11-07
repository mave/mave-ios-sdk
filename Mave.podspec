#
# Be sure to run `pod lib lint GrowthKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "GrowthKit"
  s.version          = "0.0.1"
  s.summary          = "A short description of GrowthKit."
  s.description      = <<-DESC
                       An optional longer description of GrowthKit

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/growthkit/growthkit-ios"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'GPL v2'
  s.author           = { "Danny Cosson" => "dcosson@gmail.com" }
  s.source           = { :git => "https://github.com/growthkit/growthkit-ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'GrowthKit/**/*.{m,h}'
  s.resource_bundles = {
    'GrowthKit' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'AddressBook', 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
