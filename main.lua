-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
---------------------------------
-- default setting
-- __statusBarHeight__  : height of StatusBar
-- __appContentWidth__  : width of App
-- __appContentHeight__ : height of App

---------------------------------
-- here your code
--require "CiderDebugger"
require("scripts.commonSettings")
require("scripts.translationControl")
require("scripts.user_dataDefine")

local storyboard = require "storyboard"
local analytics = require "analytics"
local func = require("scripts.commonFunc")
local user = require("scripts.user_data")

local notifications = require( "plugin.notifications" ) --2015.01.22 추가
notifications.registerForPushNotifications()

analytics.init(__FLURRY_ANALYTICS_APPLICATION_KEY__) --flurry analytics

storyboard.state = {}
 
if __IS_APP_RELEASE_MODE__ == true then
     original_print = print -- print 오버라이드
     print = function() end
end
--storyboard.buffer = {}

--local function checkMemory()
--   collectgarbage( "collect" )
--   local memUsage_str = string.format( "MEMORY = %.3f KB", collectgarbage( "count" ) )
--   print( memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ) )
--end
--Runtime : addEventListener ( "enterFrame", checkMemory) --for testing

timer.performWithDelay(1, function() collectgarbage("collect") end)

--storyboard.gotoScene( "scripts.top", "fade", 300)
local utils = require("scripts.commonUtils")
local autoLogin = require("scripts.autoLoginCheck")

autoLogin:check()

local function myUnhandledErrorListener( event )
    local iHandledTheError = true

    if iHandledTheError then
        print( "Handling the unhandled error", event.errorMessage )
    else
        print( "Not handling the unhandled error", event.errorMessage )
    end
    
    local logTitle = ""
    local logAppVer = ""
    local sUserID = user.userData.id or ""
    
    local currentSceneName = storyboard.getCurrentSceneName()
    if(not currentSceneName) then
        currentSceneName = ""
    end
    if(__deviceType__ == "iphone") then
        logTitle = "Error("..__deviceType__..")"
        logAppVer = __LOCAL_APP_VERSION_IOS__
    else
        logTitle = "Error("..__deviceType__..")"
        logAppVer = __LOCAL_APP_VERSION_ANDROID__
    end
    analytics.logEvent(logTitle,
        {
            appVersion = logAppVer,
            errorSceneName = currentSceneName,
            errorMessage = event.errorMessage,
            stackTrace = event.stackTrace,
            userID = sUserID
        }
    )
    
    return iHandledTheError
end

Runtime:addEventListener("unhandledError", myUnhandledErrorListener)

if "Win" == system.getInfo( "platformName" ) then
    require("win_fix")
end

local function onKeyEvent( event )
   local phase = event.phase
   local keyName = event.keyName
   
   print( event.phase, event.keyName )

   if ( "back" == keyName and phase == "up" ) or ("b" == keyName and phase == "up" and system.getInfo("environment") == "simulator")  then
      if ( storyboard.getCurrentSceneName() == "scripts.joinCompleteScene" or 
           storyboard.getCurrentSceneName() == "scripts.homeScene" or
           storyboard.getCurrentSceneName() == "scripts.mngHomeScene" or
           storyboard.isAction == true 
          ) then
          print("back button ignored!")
          return true
      else
         if ( storyboard.isOverlay ) then
            storyboard.hideOverlay()
            return true
         else
            local lastScene = storyboard.returnTo
            print( "previous scene", lastScene )
            
            if ( lastScene) then
                if(lastScene == "scripts.newsScene") then
                    storyboard.purgeScene(lastScene)
                    storyboard.gotoScene( lastScene, { effect="crossFade", time=300 } )
                else
                    storyboard.gotoScene( lastScene, { effect="crossFade", time=300 } )
                end
                    
                return true
            else
               native.requestExit()
               return true
            end
         end
      end
   end
   
   return false

--   if ( keyName == "volumeUp" and phase == "down" ) then
--      local masterVolume = audio.getVolume()
--      print( "volume:", masterVolume )
--      if ( masterVolume < 1.0 ) then
--         masterVolume = masterVolume + 0.1
--         audio.setVolume( masterVolume )
--      end
--      return true
--   elseif ( keyName == "volumeDown" and phase == "down" ) then
--      local masterVolume = audio.getVolume()
--      print( "volume:", masterVolume )
--      if ( masterVolume > 0.0 ) then
--         masterVolume = masterVolume - 0.1
--         audio.setVolume( masterVolume )
--      end
--      return true
--   end
--   return false  --SEE NOTE BELOW
end

--add the key callback
Runtime:addEventListener( "key", onKeyEvent )

local function onSystemEvent( event )
    if event.type == "applicationStart" then
        print("app start")
    elseif event.type == "applicationExit" then
        print("app quit")
    elseif event.type == "applicationSuspend" then
        display.currentStage.alpha = 0.9

	timer.performWithDelay(1000, 
            function()
                display.currentStage.alpha = 1.0
            end
        )
        print("app suspended")
    elseif event.type == "applicationResume" then
        display.currentStage.alpha = 0.9

	timer.performWithDelay(1000, 
            function()
                display.currentStage.alpha = 1.0
            end
        )
        
        func.get_news4Home() --새로운 새소식 갱신
        
        print("app resume")
    end
end
Runtime:addEventListener( "system", onSystemEvent )

local function printTable(table, stringPrefix)
    if not stringPrefix then
        stringPrefix = "### "
    end
    if type(table) == "table" then
        for key, value in pairs(table) do
            if type(value) == "table" then
                print(stringPrefix .. tostring(key))
                print(stringPrefix .. "{")
                printTable(value, stringPrefix .. "   ")
                print(stringPrefix .. "}")
            else
                print(stringPrefix .. tostring(key) .. ": " .. tostring(value))
            end
        end
    end
end

local launchArgs = ...
print("*** launchArgs : ", launchArgs)
printTable(launchArgs)

local function onNotification(event)
    print("*** onNotification")
    if event.type == "remoteRegistration" then
        local deviceType = '1'  --default to iOS
        if ( system.getInfo("platformName") == "Android" ) then
            deviceType = '2'
        end
        storyboard.state.DEVICE_TYPE = deviceType
        storyboard.state.DEVICE_TOKEN = event.token
        print("*** devicetype:", deviceType)
        print("*** devicetoken:", event.token)
    else
        print("in mainScene### --- Notification Event ---")
        printTable(event)
        if event.name == "notification" and event.applicationState == "inactive" then
            func.get_news4Home() --새로운 새소식 갱신
            
            if event.custom then
                local threadType = event.custom.thread_type
                local threadId = event.custom.thread_id
                if threadType == "5" then -- goto homeScene or mngHomeScene
                    autoLogin:forceCheck()
                end
            end
        end
        if event.name == "notification" and event.applicationState == "active" then
            func.get_news4Home() --새로운 새소식 갱신
            
            if event.alert and system.getInfo("platformName") ~= "Android" then
                utils.create_iOSPushPopup(event.alert);
            end
            
            if event.custom then
                local threadType = event.custom.thread_type
                local threadId = event.custom.thread_id
                if threadType == "5" then -- goto homeScene or mngHomeScene
                    autoLogin:forceCheck()
                end
            end
        end
    end
end
Runtime:addEventListener("notification", onNotification)

if launchArgs and launchArgs.notification and launchArgs.notification.custom then
    -- 1:notice, 2:announce, 3:event, 4:mngHomeScene's askApproveScene, 5:homeScene, 6:MamaTalk reply add
    print ("*** thread_type:", launchArgs.notification.custom.thread_type)
    print ("*** thread_id:",launchArgs.notification.custom.thread_id)
    onNotification( launchArgs.notification )
end