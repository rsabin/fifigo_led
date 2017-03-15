wifi.setmode(wifi.STATION)
wifi.sta.config("ssid","password")
print(wifi.sta.getip())
led1 = 3
led2 = 4
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        print(request)

        local buf = ""
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end

        local h = ""
        h = h.."<html><head><title>Fifigo - Server</title></head><body>"
        h = h.."<h1>ESP8266 Web Server</h1>"
        h = h.."<p>GPIO0 <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>"
        h = h.."<p>GPIO2 <a href=\"?pin=ON2\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF2\"><button>OFF</button></a></p>"
        h = h.."</body></html>"
        local response = {"HTTP/1.0 200 OK\n", "Server: ESP (nodeMCU)\n", "Content-Length: " .. string.len(h) .. "\n\n", h} 

        local _on,_off = "",""
        if(_GET.pin == "ON1")then
              gpio.write(led1, gpio.HIGH)
        elseif(_GET.pin == "OFF1")then
              gpio.write(led1, gpio.LOW)
        elseif(_GET.pin == "ON2")then
              gpio.write(led2, gpio.HIGH)
        elseif(_GET.pin == "OFF2")then
              gpio.write(led2, gpio.LOW)
        end

        local function sender (client)
            if #response>0 then client:send(table.remove(response,1))
            else client:close()
            end
        end
        client:on("sent", sender)
        sender(client)

    end)
end)
