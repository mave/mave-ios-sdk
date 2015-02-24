#
# Be sure to run `pod lib lint MaveSDK.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
# Note the version needs to be manually kept up to date with MAVESDKVersion constant in the code

Pod::Spec.new do |s|
  s.name             = "MaveSDK"
  s.version          = "0.5.0-rc1"
  s.summary          = "A short description of MaveSDK."
  s.description      = <<-DESC
                       An optional longer description of MaveSDK

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/mave/mave-ios-sdk"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'GPL v2'
  s.author           = 'Mave'
  s.source           = { :git => "https://github.com/mave/mave-ios-sdk.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'MaveSDK/**/*.{m,h}'
  s.resource_bundles = {
    'MaveSDK' => ['MaveSDK/Resources/Images/**/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'AddressBook', 'UIKit'
  s.libraries = 'z'

  # 3rd party cocoapod dependencies
  s.dependency 'libPhoneNumber-iOS', '~> 0.8.3'
end
