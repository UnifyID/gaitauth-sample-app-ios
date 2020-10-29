platform :ios, '10.0'

ensure_bundler! '~> 2.0'

target 'GaitAuthSample' do
  use_frameworks!

  pod 'Charts'
  pod 'lottie-ios'
  pod 'UnifyID/GaitAuth'
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
          config.build_settings.delete('IPHONEOS_DEPLOYMENT_TARGET')
          if ['Charts', 'lottie-ios'].include? t.name
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'
            config.build_settings['LD_NO_PIE'] = 'NO'
          end
      end
  end
end
