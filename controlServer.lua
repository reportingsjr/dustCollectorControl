
dcPin = 1
currentStatus = "off"
-- set pin to output and set it to low to start with for safety
gpio.mode(dcPin, gpio.OUTPUT)
gpio.write(dcPin, gpio.LOW)

wifi.setmode(wifi.STATION)
wifi.sta.config("hive13int", "hive13int")
print(wifi.sta.getip())

srv = net.createServer(net.TCP)
srv:listen(80, function(conn)
  conn:on("receive",function(client, payload)
    local buf = ""
    local _, _, method, path, vars = string.find(payload, "([A-Z]+) (.+)?(.+) HTTP")
    if (method == nil) then
      _, _, method, path = string.find(payload, "([A-Z]+) (.+) HTTP")
    end
    local _GET = {}
    if (vars ~= nil) then
      for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
        _GET[k] = v
      end
      print(_GET.turn)
    end

    if(_GET.turn == "on") then
      currentStatus = "on"
      gpio.write(dcPin, gpio.HIGH)
      print("turning on")
    elseif(_GET.turn == "off") then
      currentStatus = "off"
      gpio.write(dcPin, gpio.LOW);
      print("turning off")
    end
    
    buf = buf.."<h1>Dust Collector Control</h1><br />"
    buf = buf.."<h3>The dust collector is currently "..currentStatus.."</h3>"
    buf = buf.."<a href='?turn=on'>Turn on</a><br />"
    buf = buf.."<a href='?turn=off'>Turn off</a><br />"
    client:send(buf)
    client:close()
    collectgarbage()
  end)
end)
