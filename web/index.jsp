<%-- 
    Document   : index
    Created on : 18.9.2016, 11:00:13
    Author     : Ladislav Trejtnar
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>INNservis by Honeywell</title>
        <style>
            div.container {
                display: block;
                margin: auto;
                width: 75%;
                border: 1px solid #EE1A2E;
                font-family: Palatino, "Palatino Linotype", "Palatino LT STD", "Book Antiqua", Georgia, serif;
            }
            header, footer {
                padding: 1em;
                color: white;
                background-color: #EE1A2E;
                clear: left;
                text-align: center;
            }
            hr{
                color:#EE1A2E; 
                border-style:solid;
            }
            .tableroom{
                width: 50%;
                margin: 0 auto;
            }
            .infotable{
                border: 2px solid #EE1A2E;
                border-collapse: separate;
                table-layout: fixed;
                width: 50%;
                margin: 0 auto;
                background-color: #EE1A2E;  
                color: white;
                text-align: left;
            }
            .titlehead{
                text-align: center;
            }
            .room{
                font-size: 14px;
                background-color: white;
                color: black;
            }
            div.footer {
                text-align: center;
                font-size: 12px;
            } 
            p.button{
                text-align: center;
            }
        </style>
    </head>

    <body>
        <div class="container">
            <img src="img/honeywell-logo.png" alt="Honeywell logo">
            <header>
                <h1>  INNservis</h1>
            </header>


            <form>
                <table class="tableroom">
                    <tr><td>Room number:</td><td><input type="text" id="msg" /></td><td><button type="button" onclick="connect();">Give me info</button></td></tr>
                </table>

            </form>
            <hr/> 
            <table class="infotable">
                <tr><th>Room number:</th><th><span id="room"></span></th></tr>
                <tr><td colspan="2" class="titlehead">Room info</td></tr>

                <tr><td>Rented:</td><td class="room"><span id="rented"></span></td></tr>
                <tr><td>Privacy:</td><td class="room"><span id="privacy" ></span></td></tr>
                <tr><td>Occupacy:</td><td class="room"><span id="occupacy"></span></td></tr>
                <tr><td>Open window:</td><td class="room"><span id="window"></span></td></tr>

                <tr><td colspan="2" class="titlehead">HVAC info</td></tr>

                <tr><td>Temperature:</td><td class="room"><span id="temp"></span></td></tr>
                <tr><td>Target tamperature:</td><td class="room"><span id="targTemp"></span></td></tr>
                <tr><td>AC mode:</td><td class="room"><span id="ac"></span></td></tr>
                <tr><td>Proposed fan speed:</td><td class="room"><span id="proFan"></span></td></tr>
                <tr><td>Heating:</td><td class="room"><span id="heat"></span></td></tr>
                <tr><td>Cooling:</td><td class="room"><span id="cool"></span></td></tr>
            </table>

            <p class="button">  
                <button type="button" onclick="download();">Download like a text</button>

            </p>
            <footer>
                <div class="footer">Copyright &copy; Honeywell 2016 </div>
            </footer>
        </div>
    <script>
        var port = 22348;
        var address = window.location.hostname;
        var connection;
        var data;
        var unknown = "";
        var room = "Room does not exist";

        function connect() {
            console.log("connection");
            connection = new WebSocket("ws://" + address + ":" + port + "/");
            console.log(address);
           
        // Log errors
            connection.onerror = function (error) {
                console.log('WebSocket Error ');
                console.log(error);
                //  alert("Connection failed!");              
            };

            // Log messages from the server
            connection.onmessage = function (e) {
                console.log('Server: ' + e.data);
                data = JSON.parse(e.data);
                if (data.ro === "-1") {
                    alert("Room does not exist!");
                    setEmpty();
                } else {
                    setData();
                }

            };

            connection.onopen = function (e) {
                console.log("Connection open...");
                sendNumber();

            };

            connection.onclose = function (e) {
                console.log("Connection closed...");
            };
        }

        function setData() {
            document.getElementById("room").innerHTML = data.ro;
            document.getElementById("temp").innerHTML = data.tm + "&degF" + "/" + toCelsius(data.tm) + "&degC";
            document.getElementById("targTemp").innerHTML = data.tt + "&degF" + "/" + toCelsius(data.tt) + "&degC";
            document.getElementById("ac").innerHTML = data.ac;
            document.getElementById("window").innerHTML = booleanYesNo(data.wi);
            document.getElementById("proFan").innerHTML = data.fa;
            document.getElementById("privacy").innerHTML = booleanYesNo(data.pr);
            document.getElementById("occupacy").innerHTML = booleanYesNo(data.oc);
            document.getElementById("rented").innerHTML = booleanYesNo(data.re);
            document.getElementById("heat").innerHTML = booleanOnOff(data.he);
            document.getElementById("cool").innerHTML = booleanOnOff(data.co);
        }
        function setEmpty() {
            document.getElementById("room").innerHTML = room;
            document.getElementById("temp").innerHTML = unknown;
            document.getElementById("targTemp").innerHTML = unknown;
            document.getElementById("ac").innerHTML = unknown;
            document.getElementById("window").innerHTML = unknown;
            document.getElementById("proFan").innerHTML = unknown;
            document.getElementById("privacy").innerHTML = unknown;
            document.getElementById("occupacy").innerHTML = unknown;
            document.getElementById("rented").innerHTML = unknown;
            document.getElementById("heat").innerHTML = unknown;
            document.getElementById("cool").innerHTML = unknown;
        }

        function toCelsius(degree) {
            var x = (degree - 32) * 5 / 9;
            return (Math.round(x * 10)) / 10;
        }

        function sendNumber() {
            var number = document.getElementById("msg").value;
            console.log("Number send:" + number);
            if (isNaN(number)) {
                alert("Bad room number format!");
                setEmpty();
            } else {
                connection.send(number);
            }
        }

        function download() {
            console.log("Data downloading....");
            var currentTime = new Date();
            var month = currentTime.getMonth() + 1;
            var filename = "Room_" + data.ro + "_date_" + currentTime.getDate() + "_" + month + "_" + currentTime.getFullYear();
            var blob = new Blob([prepareData(currentTime)], {type: "text/plain"});
            var url = window.URL.createObjectURL(blob);
            var a = document.createElement("a");
            a.href = url;
            a.download = filename;
            a.click();
        }

        function prepareData(date) {
            return date + "\n Room: " + data.ro + "\n Temperature: " + data.tm + "°F\n Rarget temperature: " + data.tt + "°F\n AC mode: " + data.ac + "\n Fan speed proposed: " + data.fa + "\n Cooling: " + booleanOnOff(data.co) + "\n Heating: " + booleanOnOff(data.he) + "\n Rented: " + booleanYesNo(data.re) + "\n Privacy: " + booleanYesNo(data.pr) + "\n Occupacy: " + booleanYesNo(data.oc) + "\n Open window: " + booleanYesNo(data.wi);
        }

        function booleanOnOff(bool) {
            if (bool === "1") {
                return "ON";
            } else {
                return "OFF";
            }
        }

        function booleanYesNo(bool) {
            if (bool === "1") {
                return "YES";
            } else {
                return "NO";
            }
        }

        function close() {
            console.log("Closing...");
            connection.send("end");
            connection.close();

        }
    </script>
</body>


</html>
