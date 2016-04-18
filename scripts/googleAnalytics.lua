
local ga = {};

-- CALLING THE INIT FUNC WILL ATTEMPT TO LOG A GOOGLE ANALYTICS MEASUREMENT PROTOCOL EVENT IN LIEU OF THE PLUGIN
-- FOR MORE INFO, SEE https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide#apptracking

local track = function(pageName)

    local ga_tid = "UA-49890542-1" --UA-XXXXX-XX" -- YOUR GA MOBILE APP TID 
    local appName = "KidsUp" -- Name of your game - w/o spaces or special chars
    local cd = pageName -- argument sent in function call
    local ga_cid = system.getInfo("deviceID")
     
    local function networkListener(e)  
        if e.isError then
            print("GA Tracking unsuccessful")
        else
            print("Tracking sent to GA....");
            print(e.response);            
        end 
    end
     
    network.request("http://google-analytics.com/collect?v=1&tid="..ga_tid.."&cid="..ga_cid.."&an="..appName.."&t=appview&av=1&cd="..pageName.."","POST",networkListener)

end

local crash = function(desc)

    local ga_tid = "UA-49890542-1"
    local appName = "KidsUp" 
    local ga_cid = system.getInfo("deviceID")
     
    local function networkListener(e)  
        if e.isError then
            print("GA Tracking unsuccessful")
        else
            print("Crash sent to GA....");
            print(e.response);            
        end 
    end
     
--    network.request("http://google-analytics.com/collect?v=1&tid="..ga_tid.."&cid="..ga_cid.."&t=exception&exf=1&av=1&exd="..desc.."","POST",networkListener)
    local str = "http://google-analytics.com/collect?v=1&tid="..ga_tid.."&cid="..ga_cid.."&t=exception&exf=1&exd=".."exception crash"..""
    print(str)
    network.request(str,"POST",networkListener)

end

ga.track = track
ga.crash = crash

return ga

--How to Use
--local ga = require( "scripts.googleAnalytics" )
--ga.track("launchScreen")

