local storyboard = require( "storyboard" )
local api = require("scripts.api")
local user = require("scripts.user_data")
local utils = require("scripts.commonUtils")
local json = require("json")

local funcs = {}

function funcs.getTabButtonImage()
    local images = {
        message = {
            defaultFile = "images/bottom/btn_bottom_message_normal.png",
            overFile = "images/bottom/btn_bottom_message_selected.png",
        },
        notice = {
            defaultFile = "images/bottom/btn_bottom_notice_normal.png",
            overFile = "images/bottom/btn_bottom_notice_selected.png",
        },
        event = {
            defaultFile = "images/bottom/btn_bottom_event_normal.png",
            overFile = "images/bottom/btn_bottom_event_selected.png",
        }
    }
    
    if __NEW_MESSAGE_COUNT__ > 0 then
        images.message.defaultFile = "images/bottom/btn_bottom_message_normal_marked.png"
        images.message.overFile = "images/bottom/btn_bottom_message_selected_marked.png"
    end
    
    if __NEW_NOTICE_COUNT__ > 0 then
        images.notice.defaultFile = "images/bottom/btn_bottom_notice_normal_marked.png"
        images.notice.overFile = "images/bottom/btn_bottom_notice_selected_marked.png"
    end
    
    if __NEW_EVENT_COUNT__ > 0 then
        images.event.defaultFile = "images/bottom/btn_bottom_event_normal_marked.png"
        images.event.overFile = "images/bottom/btn_bottom_event_selected_marked.png"
    end
    
    return images
end

function funcs.clear_news(member_id, sType)
    if utils.IS_Demo_mode(storyboard, false) == true then
        --체험 모드일경우는 패스
        return true
    end
    
    if sType == "contact" then
        if __NEW_MESSAGE_COUNT__ > 0 then
            __NEW_MESSAGE_COUNT__ = 0
            api.clear_news2(member_id, "contact", user.getActiveKid_IDByAuthority(), function(e) print(e.response) end)
        end
    elseif sType == "notice" then
        if __NEW_NOTICE_COUNT__ > 0 then
            __NEW_NOTICE_COUNT__ = 0
            api.clear_news2(member_id, "notice", user.getActiveKid_IDByAuthority(), function(e) print(e.response) end)    
        end
    elseif sType == "mamatalk" then
        if __NEW_MAMATALK_COUNT__ > 0 then
            __NEW_MAMATALK_COUNT__ = 0
            api.clear_news2(member_id, "mamatalk", user.getActiveKid_IDByAuthority(), function(e) print(e.response) end)
        end
    elseif sType == "event" then
        if __NEW_EVENT_COUNT__ > 0 then
            __NEW_EVENT_COUNT__ = 0
            api.clear_news2(member_id, "event", user.getActiveKid_IDByAuthority(), function(e) print(e.response) end)
        end
    elseif sType == "dailymenu" then
        if __NEW_MENU_COUNT__ > 0 then
            __NEW_MENU_COUNT__ = 0
            api.clear_news2(member_id, "dailymenu", user.getActiveKid_IDByAuthority(), function(e) print(e.response) end)
        end
    elseif sType == "manage" then
        if __NEW_MANAGE_COUNT__ > 0 then
            __NEW_MANAGE_COUNT__ = 0
            api.clear_news2(member_id, "manage", user.getActiveKid_IDByAuthority(), function(e) print(e.response) end)
        end
    elseif sType == "news" then
        if __NEW_NEWS_COUNT__ > 0 then
            __NEW_NEWS_COUNT__ = __NEW_NEWS_COUNT__ - 1 --새소식은 한개의 갯수를 뺌
            
            if __NEW_NEWS_COUNT__ <= 0 then
                __NEW_NEWS_COUNT__ = 0
            end
        else
            __NEW_NEWS_COUNT__ = 0
        end    
    end
end

local function SetIconVisible(object, visible)
    if storyboard.getCurrentSceneName() == __DEFAULT_HOMESCENE_NAME__ then
        if object then
            object.isVisible = visible
        end
    end
end

function funcs.get_news4Home()
    local function newsListener(event)
        if (not event.isError) then
            if(event.status == 200) then
                print(event.response)
                local data = json.decode(event.response)
                
                if(data.status == "OK") then
                    if(data.badge.contact and tonumber(data.badge.contact) > 0) then
                        __NEW_MESSAGE_COUNT__ = tonumber(data.badge.contact)
                        
                        SetIconVisible(__NEW_ICON_SET__.new_message_icon, true)
                    else
                        __NEW_MESSAGE_COUNT__ = 0
                        
                        SetIconVisible(__NEW_ICON_SET__.new_message_icon, false)
                    end

                    if(data.badge.notice and tonumber(data.badge.notice) > 0) then
                        __NEW_NOTICE_COUNT__ = tonumber(data.badge.notice)
                        
                        SetIconVisible(__NEW_ICON_SET__.new_notice_icon, true)
                    else
                        __NEW_NOTICE_COUNT__ = 0
                        
                        SetIconVisible(__NEW_ICON_SET__.new_notice_icon, false)
                    end

                    if(data.badge.event and tonumber(data.badge.event) > 0) then
                        __NEW_EVENT_COUNT__ = tonumber(data.badge.event)
                        
                        SetIconVisible(__NEW_ICON_SET__.new_event_icon, true)
                    else
                        __NEW_EVENT_COUNT__ = 0
                        
                        SetIconVisible(__NEW_ICON_SET__.new_event_icon, false)
                    end 

                    if(data.badge.dailymenu and tonumber(data.badge.dailymenu) > 0) then
                        __NEW_MENU_COUNT__ = tonumber(data.badge.dailymenu)
                        
                        SetIconVisible(__NEW_ICON_SET__.new_menu_icon, true)
                    else
                        __NEW_MENU_COUNT__ = 0
                        
                        SetIconVisible(__NEW_ICON_SET__.new_menu_icon, false)
                    end

                    if(data.badge.mamatalk and tonumber(data.badge.mamatalk) > 0) then
                        __NEW_MAMATALK_COUNT__ = tonumber(data.badge.mamatalk)
                        
                        SetIconVisible(__NEW_ICON_SET__.new_mamatalk_icon, true)
                    else
                        __NEW_MAMATALK_COUNT__ = 0
                        
                        SetIconVisible(__NEW_ICON_SET__.new_mamatalk_icon, false)
                    end

                    if(data.badge.news and tonumber(data.badge.news) > 0) then
                        __NEW_NEWS_COUNT__ = tonumber(data.badge.news)
                        
                        SetIconVisible(__NEW_ICON_SET__.new_alarm_icon, true)
                    else
                        __NEW_NEWS_COUNT__ = 0
                        
                        SetIconVisible(__NEW_ICON_SET__.new_alarm_icon, false)
                    end
                    
                    if(data.badge.manage and tonumber(data.badge.manage) > 0) then
                        __NEW_MANAGE_COUNT__ = tonumber(data.badge.manage)
                        
                        SetIconVisible(__NEW_ICON_SET__.new_manage_icon, true)
                    else
                        __NEW_MANAGE_COUNT__ = 0
                        
                        SetIconVisible(__NEW_ICON_SET__.new_manage_icon, false)
                    end
                end
            end
        end    
    end
    
    if ( user.userData and user.userData.id ) then
        if utils.IS_Demo_mode(storyboard, false) == true then
            api.get_news2( user.userData.id, __DEMO_MODE_DEVICE_ID__, user.getActiveKid_IDByAuthority(), newsListener )
        else
            local deviceData = user.getDeviceData()

            if( deviceData and deviceData.id ) then
                api.get_news2( user.userData.id, deviceData.id, user.getActiveKid_IDByAuthority(), newsListener )
            end
        end
    end
end

function funcs.refresh_Home_New_icon()
    if __NEW_MESSAGE_COUNT__ > 0 then
        SetIconVisible(__NEW_ICON_SET__.new_message_icon, true)
    else
        SetIconVisible(__NEW_ICON_SET__.new_message_icon, false)
    end

    if __NEW_NOTICE_COUNT__ > 0 then
        SetIconVisible(__NEW_ICON_SET__.new_notice_icon, true)
    else
        SetIconVisible(__NEW_ICON_SET__.new_notice_icon, false)
    end

    if __NEW_EVENT_COUNT__ > 0 then
        SetIconVisible(__NEW_ICON_SET__.new_event_icon, true)
    else
        SetIconVisible(__NEW_ICON_SET__.new_event_icon, false)
    end

    if __NEW_MENU_COUNT__ > 0 then
        SetIconVisible(__NEW_ICON_SET__.new_menu_icon, true)
    else
        SetIconVisible(__NEW_ICON_SET__.new_menu_icon, false)
    end

    if __NEW_MAMATALK_COUNT__ > 0 then
        SetIconVisible(__NEW_ICON_SET__.new_mamatalk_icon, true)
    else
        SetIconVisible(__NEW_ICON_SET__.new_mamatalk_icon, false)
    end

    if __NEW_NEWS_COUNT__ > 0 then
        SetIconVisible(__NEW_ICON_SET__.new_alarm_icon, true)
    else
        SetIconVisible(__NEW_ICON_SET__.new_alarm_icon, false)
    end 
    
    if __NEW_MANAGE_COUNT__ > 0 then
        SetIconVisible(__NEW_ICON_SET__.new_manage_icon, true)
    else
        SetIconVisible(__NEW_ICON_SET__.new_manage_icon, false)
    end
end

return funcs

