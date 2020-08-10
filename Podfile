platform :ios, '10.0'

target 'GaitAuthSample' do
  use_frameworks!

  pod 'Charts'
  pod 'lottie-ios'
  pod 'UnifyID/GaitAuth'
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    if ['Charts', 'lottie-ios'].include? t.name
        t.build_configurations.each do |config|
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'
        end
    end
  end
end
