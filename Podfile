platform :ios, '9.0'
inhibit_all_warnings!
use_frameworks!

pod 'TMCache'
pod 'Parse'
pod 'SDCloudUserDefaults'
pod 'Crashlytics'
pod 'PINRemoteImage'

plugin 'cocoapods-keys', {
  :project => "SFParties",
  :keys => [
    "Crashlytics",
    "Lyft",
    "ParseApplicationId",
    "ParseClientKey"
  ]
}

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
