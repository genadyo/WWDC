platform :ios, '8.0'
inhibit_all_warnings!

xcodeproj 'SFParties'

link_with 'SFParties', 'SFPartiesKit'
pod 'TUSafariActivity'
pod 'GoogleAnalytics-iOS-SDK'
pod 'TMCache'
pod 'Mixpanel'
pod 'MMWormhole'

plugin 'cocoapods-keys', {
  :project => "SFParties",
  :target => "SFParties",
  :keys => [
    "GoogleAnalytics",
    "Uber",
    "Mixpanel"
  ]
}
