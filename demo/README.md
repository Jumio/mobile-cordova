# Cordova Demo-App
Demonstrates how to use the JumioMobileSDK plugin.

## Prerequisites

* Cordova CLI 11.0.0
* NodeJS 18.2.0

## Usage

Add your data center in `www/js/index.js` and run the following commands:

```
cordova plugin add --link ../
cordova prepare
```

### iOS-specific

Navigate to `platforms/ios/Podfile` and add the following:
```
dynamic_frameworks = ['Starscream', 'iProov', 'DatadogSDK', 'SwiftProtobuf']

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
    
    # Add Localization to Resources group to make iProov work
    destinationFolder = './DemoApp/Resources'
    localizableName = 'Localizable-Jumio.strings'
    project = installer.aggregate_targets[0].user_project
    FileUtils.mkdir_p destinationFolder
    FileUtils.cp_r './Pods/Jumio/Localization', destinationFolder
    resourcesGroup = project.groups.find do |group|
      group.name == 'Resources'
    end
    localizableGroup = resourcesGroup.children.select {|group|
      group.name == localizableName
    }[0]
    if localizableGroup.nil?
      localizableGroup = resourcesGroup.new_variant_group(localizableName)
    end
    Dir.foreach(destinationFolder + '/Localization') do |folder|
      if folder.include? ".lproj"
        localizableGroup.new_file('./Localization/' + folder + '/Localizable-Jumio.strings')
      end
    end
    project.native_targets.each do |target|
       target.add_resources([localizableGroup])
    end
    project.save
end
```

Reinstall pods.

## Run the application
```
cordova run android
# OR
cordova run ios
```
