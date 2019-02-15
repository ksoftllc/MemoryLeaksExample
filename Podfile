workspace 'MemoryLeaksExample'


# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MemoryLeaksExample' do
project 'MemoryLeaksExample'
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  platform :ios, '12.0'
  use_frameworks!

  # Pods for MemoryLeaksExample
  pod 'RxSwift', '~> 4.4.0'
  pod 'RxCocoa', '~> 4.4.0'
  pod 'ReSwift', '~> 4.0.1'
   
  target 'MemoryLeaksExampleTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
 
 

target 'CMUtilities' do
  project './CMUtilities/CMUtilities'
  platform :ios, '12.0'
  use_frameworks!
  
  pod 'RxSwift', '~> 4.4.0'
  pod 'RxCocoa', '~> 4.4.0'
  pod 'ReSwift', '~> 4.0.1'
  
  target 'CMUtilitiesTests' do
    inherit! :search_paths
  end
  
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'RxSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug' || config.name == 'StagingDebug' || config.name == 'ProductionDebug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)', '-D', 'TRACE_RESOURCES']
                end
            end
        end
    end
end
