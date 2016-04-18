--test

--local loadsave = require("scripts.loadsave")

--local myTable = {}
--myTable.value1 = "한국어, 日本語、value1"
--myTable.value2 = "한국어, 日本語、value2"
--myTable.musicOn = true
--myTable.soundOn = false

--loadsave.saveTable(myTable, "myTable.json")
--print("myTable.value1 : "..myTable.value1)
--print("myTable.value2 : "..myTable.value2)
--print(myTable.musicOn)
--print(myTable.soundOn)

----save = display.newText("save: "..myTable.value1, 150, 150, 200, 200, 14)
--display.newText("save: "..myTable.value1, 150, 150, 200, 200, 14)

--local myData = loadsave.loadTable("myTable.json", nil)
--print("myData.value1 : "..myData.value1)
--print("myData.value2 : "..myData.value2)
--print(myData.musicOn)
--print(myData.soundOn)
----load = display.newText("load: "..myData.value1, 150, 300, 200, 200, 14)
--display.newText("load: "..myData.value1, 150, 300, 200, 200, 14)

--local api = require("scripts.api")

--api.login_api("jazzdevils_Test","3333")

----api.image_api("jazzdevils")


------------------------ facebook ----------------------------------
--local facebook = require( "facebook" )
--local fbAppID = "590005947742428"  --replace with your Facebook App ID
--local function facebookListener( event )
--
--    print( "event.name", event.name )  --"fbconnect"
--    print( "event.type:", event.type ) --type is either "session", "request", or "dialog"
--    print( "isError: " .. tostring( event.isError ) )
--    print( "didComplete: " .. tostring( event.didComplete ) )
--
--    --"session" events cover various login/logout events
--    --"request" events handle calls to various Graph API calls
--    --"dialog" events are standard popup boxes that can be displayed
--
--    if ( "session" == event.type ) then
--        --options are: "login", "loginFailed", "loginCancelled", or "logout"
--        if ( "login" == event.phase ) then
--            local access_token = event.token
--            --code for tasks following a successful login
--        end
--
--    elseif ( "request" == event.type ) then
--        print("facebook request")
--        if ( not event.isError ) then
--            local response = json.decode( event.response )
--            --process response data here
--        end
--
--    elseif ( "dialog" == event.type ) then
--        print( "dialog", event.response )
--        --handle dialog results here
--    end
--end 
--facebook.login( fbAppID, facebookListener, { "publish_actions, email" } ) 


