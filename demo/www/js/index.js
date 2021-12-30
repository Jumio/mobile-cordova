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
		document.getElementById("log").addEventListener("change",function unhide() {
			document.getElementById("logtitle").hidden = true
		})			
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
		
	},

	start: function() {
    		var authorizationToken = document.getElementById("tokenInput").value;
    		Jumio.initialize(authorizationToken, DATACENTER);

    		Jumio.start(function(documentData) {
    			// alert(JSON.stringify(documentData));
    			document.getElementById("log").textContent = JSON.stringify(documentData);
    		}, function(error) {
    			// alert(JSON.stringify(error));
    			document.getElementById("log").textContent = JSON.stringify(error);
    		});
    }
};

app.initialize();