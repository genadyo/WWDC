platform :ios, '9.0'
inhibit_all_warnings!
use_frameworks!

target 'SFParties' do
    pod 'Crashlytics'
    pod 'OneSignal'
    pod 'PINRemoteImage'
end

plugin 'cocoapods-keys', {
  :project => "SFParties",
  :keys => [
    "Crashlytics",
    "Lyft",
    "LyftSecret",
    "OneSignal"
  ]
}

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
