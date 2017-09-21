# Uncomment the next line to define a global platform for your project 
platform :ios, '10.0'

target 'Petto' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Petto
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Core'
  pod "Firebase/Storage"
  pod 'FirebaseUI/Storage'
  pod 'SVProgressHUD'
  pod 'SlideMenuControllerSwift'
  pod 'RxCocoa'
  pod 'RxSwift'
  pod 'JSQMessagesViewController'
  pod 'SwiftyJSON'
  pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git', :branch => 'feature/Xcode9-Swift3_2'
  pod 'RKNotificationHub'
  pod 'Firebase/Messaging'
  pod 'SCLAlertView'
  pod 'Toucan'
  pod "LINEActivity", "~> 0.2.0"

# Manually making Quick compiler version be swift 3.2
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            if target.name == 'Quick'
                print "Changing Quick swift version to 3.2\n"
                target.build_configurations.each do |config|
                    config.build_settings['SWIFT_VERSION'] = '3.2'
                end
            end
        end
    end
end
