/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

var DATACENTER = '';

var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
		document.getElementById('start').addEventListener('click', this.start.bind(this));
		document.getElementById('buttonUS').addEventListener('click', this.handleButtonUS);
        document.getElementById('buttonEU').addEventListener('click', this.handleButtonEU);
        document.getElementById('buttonSG').addEventListener('click', this.handleButtonSG);
        document.getElementById('modalCloseButton').addEventListener('click', () => {
             document.getElementById('resultModalOverlay').style.display = 'none';
        });
    },

    showModal: function(title, messageObject) {
        document.getElementById('modalTitle').innerText = title;
        document.getElementById('modalMessage').innerText = JSON.stringify(messageObject);
        document.getElementById('resultModalOverlay').style.display = 'flex';
    },

    handleJumioResult: function(result) {
        this.showModal('Jumio Result', result);
    },

    handleJumioError: function(error) {
        this.showModal('Jumio Error', error);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
        Jumio.getCachedResult(
            (result) => {
                if (result) {
                    this.handleJumioResult(result);
                } else {
                    console.log('No cached result found.');
                }
            },
            (error) => {
                if (error) {
                    this.handleJumioError(error);
                }
            }
        );

        Jumio.setPreloaderFinishedBlock(
            function(data) {
                 console.log('All models are preloaded. You may start the SDK now!');
            }, function(error) {
                 alert(JSON.stringify(error));
            }
        );
        Jumio.preloadIfNeeded()
	},

	start: function() {
        var authorizationToken = '';
        if(document.getElementById('tokenInput') && document.getElementById('tokenInput').value) {
            authorizationToken = document.getElementById('tokenInput').value;
        }

        Jumio.initialize(authorizationToken, DATACENTER,
            () => {
                console.log('Jumio initialized successfully.');
                Jumio.start(
                    this.handleJumioResult.bind(this),
                    this.handleJumioError.bind(this),
                    {
//                         background: "#AC3D9A",
//                         primaryColor: "#FF5722",
//                         loadingCircleIcon: "#F2F233",
//                         loadingCirclePlain: "#57ffc7",
//                         loadingCircleGradientStart: "#EC407A",
//                         loadingCircleGradientEnd: "#bc2e41",
//                         loadingErrorCircleGradientStart: "#AC3D9A",
//                         loadingErrorCircleGradientEnd: "#C31322",
//                         primaryButtonBackground: {"light": "#D900ff00", "dark": "#9Edd9E"}
                    }
                );
            },
            (error) => {
                this.handleJumioError(error);
            }
        );
    },
    handleButtonUS: function() {
        DATACENTER = 'US';
        document.getElementById('buttonUS').style.backgroundColor = "#FFC055";
        document.getElementById('buttonEU').style.backgroundColor = "#B4B7BB";
        document.getElementById('buttonSG').style.backgroundColor = "#B4B7BB";
    },
    handleButtonEU: function() {
        DATACENTER = 'EU';
        document.getElementById('buttonEU').style.backgroundColor = "#FFC055";
        document.getElementById('buttonUS').style.backgroundColor = "#B4B7BB";
        document.getElementById('buttonSG').style.backgroundColor = "#B4B7BB";
    },
    handleButtonSG: function() {
        DATACENTER = 'SG';
        document.getElementById('buttonSG').style.backgroundColor = "#FFC055";
        document.getElementById('buttonUS').style.backgroundColor = "#B4B7BB";
        document.getElementById('buttonEU').style.backgroundColor = "#B4B7BB";
    }
};

app.initialize();