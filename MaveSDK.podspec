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
  s.version          = "0.7.0"
  s.summary          = "A drop-in SMS invite and share platform to accelerate your user growth"
  s.description      = <<-DESC
                       Make it simple for your users to send more, higher quality invites and shares.

                       Sign up on our website to get started, and be up and running in 20 minutes
                       with an invite page that's as good or better as what the top apps are using.
                       DESC
  s.homepage         = "http://mave.io"
  s.license          = 'Proprietary'
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
