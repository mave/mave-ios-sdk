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
  s.version          = "0.8.0"
  s.summary          = "A drop-in SMS invite and share page to accelerate your user growth"
  s.description      = <<-DESC
                       Mave the service has shut down as of Dec 2015.

                       This library is still functional as a stand-alone invite or share page, but the Mave-provided services such as SMS invite delivery, the stats dashboard, and suggested invites are no longer available. The library is now released under the MIT license.
                       DESC
  s.homepage         = "https://github.com/mave/mave-ios-sdk"
  s.license          = 'MIT'
  s.author           = 'Mave'
  s.source           = { :git => "https://github.com/mave/mave-ios-sdk.git", :tag => "v#{s.version.to_s}" }
  s.social_media_url = 'https://twitter.com/mavegrowth'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'MaveSDK/**/*.{m,h}'
  s.resource_bundles = {
    'MaveSDK' => ['MaveSDK/Resources/Images/**/*.png']
  }

  s.frameworks = 'AddressBook', 'UIKit'
  s.libraries = 'z'

  # 3rd party cocoapod dependencies
  s.dependency 'libPhoneNumber-iOS', '~> 0.8.3'
  s.dependency 'CCTemplate', '0.2.0'
end
