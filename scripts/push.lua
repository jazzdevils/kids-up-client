local M = {}
local json = require("json")
local storyboard = require("storyboard")
local user = require("scripts.user_data")
local api = require("scripts.api")
local utils = require("scripts.commonUtils")

local function updateDeviceTokenCallBack(event)
    if ( event.isError ) then
        print( "Network error!")
    else
        print(event.status)
        if(event.status == 200) then
            print ( "RESPONSE: " .. event.response )
            local data = json.decode(event.response)
        
            if (data) then
                if(data.status == "OK") then
                    local p = {
                        id = data.device_id,
                        type = storyboard.state.DEVICE_TYPE,
                        token = storyboard.state.DEVICE_TOKEN,
                        locale = utils.getLocale()
                    }
                    local device = user.getDeviceData()
                    if device == nil then
                        user.addDevice(p)
                    else
                        device.locale = utils.getLocale()
                    end
                else
                    print("device token update FAIL!")
                end
            end
        end
    end
    return true
end

function M:updateDeviceToken()
    if storyboard.state.DEVICE_TYPE ~= nil and 
        string.len(storyboard.state.DEVICE_TYPE) > 0 and 
        storyboard.state.DEVICE_TOKEN ~= nil and 
        string.len(storyboard.state.DEVICE_TOKEN) > 0 then
        local device = user.getDeviceData()
        if device == nil then
            local params = {
                member_id = user.userData.id,
                device_type = storyboard.state.DEVICE_TYPE,
                device_token = storyboard.state.DEVICE_TOKEN
            }
            api.update_device_token(params, updateDeviceTokenCallBack)
        else
            local function callBack(event)
                if ( event.isError ) then
                    print( "Network error!")
                else
                    print(event.status)
                    if(event.status == 200) then
                        device.locale = utils.getLocale()
                    end
                end

                return true
            end
            local params = {
                member_id = user.userData.id,
                device_id = device.id,
                locale = utils.getLocale()
            }
            api.set_locale(params, callBack)
        end
    end
end

return M