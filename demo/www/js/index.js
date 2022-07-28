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

const DATACENTER = 'DATACENTER';

var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
		document.getElementById("start").addEventListener("click", this.start);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
		
	},

	start: function() {
    		var authorizationToken = '...';
            if(document.getElementById("tokenInput") && document.getElementById("tokenInput").value) {
    		    authorizationToken = document.getElementById("tokenInput").value;
    		}

    		Jumio.initialize(authorizationToken, DATACENTER);

    		Jumio.start(function(documentData) {
    			 alert(JSON.stringify(documentData));
    		}, function(error) {
    			 alert(JSON.stringify(error));
    		},
//    		{
//    		    loadingCircleIcon: "#000000",
//    		    loadingCirclePlain: "#000000",
//    		    loadingCircleGradientStart: "#000000",
//    		    loadingCircleGradientEnd: "#000000",
//    		    loadingErrorCircleGradientStart: "#000000",
//    		    loadingErrorCircleGradientEnd: "#000000",
//              primaryButtonBackground: {"light": "#FFC0CB", "dark": "#FF1493"}
//    		}
    		);
    }
};

app.initialize();