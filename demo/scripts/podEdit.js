const fs = require('fs');
const podfilePath = 'platforms/ios/Podfile'

module.exports = function() {
    fs.readFile(podfilePath, 'utf-8', function(error, podData){
        if (error) throw error;

        fs.readFile('scripts/podExtension', 'utf-8', function(error, extensionData){
            if (error) throw err;

            const newValue = podData + extensionData;

            fs.writeFile(podfilePath, newValue, 'utf-8', function (error) {
                if (error) throw err;
            });
        });
    });
}