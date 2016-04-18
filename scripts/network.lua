
local socket = require("socket")
 
local connection = {}

local function manual_try(callback, timeout)
	if timeout == nil then 
            timeout = 3000 
        end
        
        local connection = assert(socket.tcp())
        
        connection:settimeout(0)
        
        local result = connection:connect("www.google.com", 80)
        
        local t
	t = timer.performWithDelay( 10, function()
		local r, w, e = socket.select(nil, {connection}, 0)
		if w[1] or timeout == 0 then
			connection:close()
			timer.cancel( t )
			callback(timeout > 0)
		end
		timeout = timeout - 10
	end , 0)
end
local isReachable = nil
function connection.try(callback)
    if network.canDetectNetworkStatusChanges then
    	if isReachable == nil then
		    local function networkListener(event)
		        isReachable = event.isReachable
				callback(isReachable)
		    end
		    network.setStatusListener( "www.google.com", networkListener )
		else
			callback(isReachable)
		end
    else
        manual_try(callback)
    end
end

return connection
    