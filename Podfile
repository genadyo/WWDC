platform :ios, '10.0'
inhibit_all_warnings!
use_frameworks!

target 'SFParties' do
    pod 'Crashlytics'
    pod 'OneSignal'
    pod 'Smooch'
    pod 'PINRemoteImage'
    pod 'JLRoutes'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['VALID_ARCHS'] = 'arm64'
  end
end
