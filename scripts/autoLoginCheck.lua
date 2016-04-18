local M = {}
local storyboard = require( "storyboard" )
local utils = require("scripts.commonUtils")
local access = require("scripts.accessScene")

function M:check()
    local appPropertyData = utils.getAppPropertyData()
    if appPropertyData.logined == "1" then
        if appPropertyData.member.type == "3" then
            access:getKidsInfo(appPropertyData.member.id)
        else
            access:gotoMngHomeSceneFromAutoAccess(appPropertyData)
        end
    else
        storyboard.purgeScene("scripts.top")
        storyboard.gotoScene( "scripts.top" )
    end
end

function M:forceCheck()
    local appPropertyData = utils.getAppPropertyData()
    if appPropertyData.member.type == "3" then
        access:getKidsInfo(appPropertyData.member.id)
    else
        access:gotoMngHomeSceneFromAutoAccess(appPropertyData)
    end
end

return M

