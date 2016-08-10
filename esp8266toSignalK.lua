--based on https://odd-one-out.serek.eu/esp8266-nodemcu-dht22-mqtt-deep-sleep/ 
--apparently, there is nodemcu firmware with another dht library included
-- this works if compiled, otherwise it crashes due to memory issues


port=7777 --works for openplotter UDP deltas
ip="10.10.10.1"
vessel="123456789"  --Use your own vessel id

function getNet()
	print("getting net")
	cu=net.createConnection(net.UDP)
	cu:on("receive",function(cu,c) print(c) end)
	cu:connect(port,ip)
end


-- DHT22 sensor logic
function get_sensor_Data()
	DHT= require("dht22_min")
  DHT.read(2)
  temperature = DHT.getTemperature()
  humidity = DHT.getHumidity()
	DHT = nil
  package.loaded["dht22_min"]=nil

  if humidity == nil then
    print("Error reading from DHT22")
  else
  end

end


function loop()
	
	if wifi.sta.status() == 5 then
    -- Get sensor data
    get_sensor_Data()
		tempkInt = (27316/100 + (temperature / 10))
		tempkDec = string.format("%04d",27316 % 100 + (temperature % 10))
		tempk = tempkInt.."."..tempkDec
		humk = string.format("%03d",humidity)
        
		--send to Signalk
		msg='{"context":"vessels.'..vessel..'","updates":\[{"source":{"type":"NMEA0183","sentence":"RSA","label":"witosk","talker":"hum"},"timestamp":"","values":\[{"path":"environment.inside.temperature","value":'..tempk..'},{"path":"environment.inside.humidity","value":0.'..humk..'}\]}\]}\n'
		cu:send(msg)
		msg, temperature, humidity, tempk, tempkDec, humk = nil
		print("sent  ")


    else
        print("Connecting...")
		cu:connect(port,ip)
    end
end

getNet()

tmr.alarm(0, 1000, 1, function() loop() end)

