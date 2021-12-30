# Cordova Demo-App
Demonstrates how to use the JumioMobileSDK plugin.

## Prerequisites

* Cordova CLI 10.0.0
* NodeJS 17.0.1

## Usage

Add your data center in `www/js/index.js` and run the following commands:

```
cordova plugin add --link ../
cordova prepare
```
### Android-specific

Navigate to `platforms/android/gradle.properties` and add the following line:

```
android.jetifier.ignorelist=bcprov-jdk15on
```

### iOS-specific

Navigate to `platforms/ios/Podfile` and add the following:
```
dynamic_frameworks = ['Socket.IO-Client-Swift', 'Starscream', 'iProov']

# make all the other frameworks into static frameworks by overriding the static_framework? function to return true
pre_install do |installer|
  installer.pod_targets.each do |pod|
    if !dynamic_frameworks.include?(pod.name)
      puts "Overriding the static_framework? method for #{pod.name}"
      def pod.static_framework?;
        true
      end
      def pod.build_type;
        Pod::BuildType.static_library
      end
    end
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
end
```

Reinstall pods.

## Run the application
```
cordova run android
# OR
cordova run ios
```
