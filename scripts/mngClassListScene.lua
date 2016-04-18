---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------
require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("scripts.askApprovalMenu")
require("widgets.activityIndicator")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local json = require("json")
local widget = require("widget")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local api = require("scripts.api")
local user = require("scripts.user_data")
local ROW_HEIGHT = 100
local NAVI_BAR_HEIGHT = 50
local NODATA_ROW_HEIGHT = 280
local NAME_BAR_HEIGHT = 30
local LABEL_WIDTH = 70
local mngTable
local deletedRowIndex
local activityIndicator
---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function updateButtonEvent(event)
    if event.phase == "ended" then
        local rowData = event.target.rowData
        local options = {
            effect = "slideLeft",
            time = 300,
            params = {
                class_id = rowData.id,
                class_name = rowData.name,
                class_desc = rowData.desc
            }
        }
        storyboard.purgeScene("scripts.mngClassUpdateScene")
        storyboard.gotoScene("scripts.mngClassUpdateScene", options)
    end
    
    return true
end

local function listCallback(event)
    local function makeRow(json_data)
        if(mngTable) then
            local cnt = json_data.class_cnt
            if(cnt > 0) then
                mngTable:deleteAllRows()
                user.freeClassList()
                
                for i = 1, cnt do
                    mngTable:insertRow{
                        rowHeight = ROW_HEIGHT,
                        rowColor = {  default = { 1, 1, 1 , 0}, over = { 1, 1, 1, 0 } },
                        lineColor = { 0.5, 0.5, 0.5 },
                        params = {
                            class = json_data.class[i]
                        }
                    }
                    
                    user.addClass{
                        desc = json_data.class[i].desc, 
                        id = json_data.class[i].id, 
                        name = json_data.class[i].name
                    }
                end
            else
                mngTable:deleteAllRows()
                user.freeClassList()
                
                mngTable:insertRow{
                    rowHeight = NODATA_ROW_HEIGHT,
                    rowColor = {  default = { 1, 1, 1, 0}, over = { 1, 1, 1, 0 }},
                    lineColor = { 0.5, 0.5, 0.5 },
                    params = {
                        class = nil
                    }
                }
            end
        end
    end
    
    if (activityIndicator) then
        activityIndicator:destroy()
    end
    
    if ( event.isError ) then
        print( "Network error!")
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        print(event.status)
        if(event.status == 200) then
            print ( "RESPONSE: " .. event.response )
            local data = json.decode(event.response)
        
            if (data) then
                if(data.status == "OK") then
                    makeRow(data)
                else 
                    utils.showMessage( data.message )
                end
            end
        end
    end
    return true
end

local function apiCallback(event)
    if(activityIndicator) then
        activityIndicator:destroy()
    end
    
    if ( event.isError ) then
        print( "Network error!")
        utils.showMessage( language["common"]["wrong_connection"] )
    else
        print(event.status)
        if(event.status == 200) then
            print ( "RESPONSE: " .. event.response )
            local data = json.decode(event.response)

            if (data) then
                if(data.status == "OK") then
                    mngTable:deleteRow(deletedRowIndex)

                    local function listener( event )
                        api.get_mng_class_list(user.userData.centerid, listCallback)
                    end
                    
                    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
                    timer.performWithDelay( 500,  listener)
                else
                    utils.showMessage( data.message )
                end
            end
        end
    end
end

local function deleteButtonEvent(event)
    if event.phase == "ended" then
        if utils.IS_Demo_mode(storyboard, true) == true then
            return true
        end
        
        local rowData = event.target.rowData
        
        if (rowData.approved_cnt > 0 or rowData.nonapproved_cnt > 0) then
            utils.showMessage( language["mngClassListScene"]["cannot_delete_reason"] )
        else
            local alert = native.showAlert( language["appTitle"], string.gsub(language["mngClassListScene"]["delete_message"], "__CLASS__", rowData.name), {language["mngClassListScene"]["confirm"], language["mngClassListScene"]["cancel"] }, 
                function(event)
                    if "clicked" == event.action then
                        local i = event.index
                        if 1 == i then
                            mngTable._view._velocity = 0
                            activityIndicator = ActivityIndicator:new(language["activityIndicator"]["delete"])
                            deletedRowIndex = rowData.index
                            api.delete_class_info(rowData.id, apiCallback)
                        elseif 2 == i then
                        end
                    end
                end )
        end
    end
    
    return true
end

local function onRowRender( event )
    local row = event.row
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    
    local rowData = row.params.class;
    if rowData then
        row.bg = display.newImageRect("images/bg_set/bg_frame_320x110.png", rowWidth - 10, rowHeight - 6)
        row.bg.x = rowWidth * 0.5
        row.bg.y = rowHeight * 0.5
        row:insert(row.bg)

        row.classNameLabel = display.newText( {text = language["mngClassAddScene"]["class_name_label"], width = LABEL_WIDTH, fontSize = __textLabelFontSize__} )
        row.classNameLabel:setFillColor( 0,0,0,0.3 )
        row.classNameLabel.anchorX = 0
        row.classNameLabel.anchorY = 0
        row.classNameLabel.x = 10
        row.classNameLabel.y = 10
        row:insert(row.classNameLabel)

        row.className = display.newText( {text = rowData.name, fontSize = __textLabelFontSize__} )
        row.className:setFillColor( 0 )
        row.className.anchorX = 0
        row.className.anchorY = 0
        row.className.x = row.classNameLabel.x + row.classNameLabel.width + 12
        row.className.y = row.classNameLabel.y
        row:insert(row.className)

        row.classDescLabel = display.newText( {text = language["mngClassAddScene"]["class_desc_label"], width = LABEL_WIDTH, fontSize = __textLabelFontSize__} )
        row.classDescLabel:setFillColor( 0,0,0,0.3 )
        row.classDescLabel.anchorX = 0
        row.classDescLabel.anchorY = 0
        row.classDescLabel.x = row.classNameLabel.x
        row.classDescLabel.y = row.classNameLabel.y + row.classNameLabel.height + 5
        row:insert(row.classDescLabel)

        row.classDesc = display.newText( {text = rowData.desc, fontSize = __textLabelFontSize__} )
        row.classDesc:setFillColor( 0 )
        row.classDesc.anchorX = 0
        row.classDesc.anchorY = 0
        row.classDesc.x = row.className.x
        row.classDesc.y = row.classDescLabel.y
        row:insert(row.classDesc)
        
        row.usingCntLabel = display.newText( {text = language["mngClassListScene"]["belongto_count"], width = LABEL_WIDTH, fontSize = __textLabelFontSize__} )
        row.usingCntLabel:setFillColor( 0,0,0,0.3 )
        row.usingCntLabel.anchorX = 0
        row.usingCntLabel.anchorY = 0
        row.usingCntLabel.x = row.classNameLabel.x
        row.usingCntLabel.y = row.classDescLabel.y + row.classDescLabel.height + 5
        row:insert(row.usingCntLabel)

        row.usingCnt = display.newText( {text = rowData.approved_cnt, fontSize = __textLabelFontSize__} )
        row.usingCnt:setFillColor( 0 )
        row.usingCnt.anchorX = 0
        row.usingCnt.anchorY = 0
        row.usingCnt.x = row.className.x
        row.usingCnt.y = row.usingCntLabel.y
        row:insert(row.usingCnt)
        
        row.notUsingCntLabel = display.newText( {text = language["mngClassListScene"]["unbelongto_count"], width = LABEL_WIDTH, fontSize = __textLabelFontSize__} )
        row.notUsingCntLabel:setFillColor( 0,0,0,0.3 )
        row.notUsingCntLabel.anchorX = 0
        row.notUsingCntLabel.anchorY = 0
        row.notUsingCntLabel.x = row.classNameLabel.x
        row.notUsingCntLabel.y = row.usingCntLabel.y + row.usingCntLabel.height + 5
        row:insert(row.notUsingCntLabel)

        row.notUsingCnt = display.newText( {text = rowData.nonapproved_cnt, fontSize = __textLabelFontSize__} )
        row.notUsingCnt:setFillColor( 0 )
        row.notUsingCnt.anchorX = 0
        row.notUsingCnt.anchorY = 0
        row.notUsingCnt.x = row.className.x
        row.notUsingCnt.y = row.notUsingCntLabel.y
        row:insert(row.notUsingCnt)

        row.update_button = widget.newButton
        {
            width = rowWidth * 0.25,
            height = 30 ,
            defaultFile = "images/button_inframe/btn_inframe_blue_2_normal.png",
            overFile = "images/button_inframe/btn_inframe_blue_2_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = __textSubMenuFontSize__,
            label = language["mngClassListScene"]["update"],
            onRelease = updateButtonEvent
        }
        row.update_button.anchorX = 0
        row.update_button.x = rowWidth * 0.75 - 10
        row.update_button.y = rowHeight * 0.25 + 5
        row.update_button.rowData = rowData
        row:insert(row.update_button)
        if user.userData.jobType == __TEACHER__ then
            row.update_button.alpha = 0
        end

        row.delete_button = widget.newButton
        {
            width = rowWidth * 0.25,
            height = 30 ,
            defaultFile = "images/button_inframe/btn_inframe_red_2_normal.png",
            overFile = "images/button_inframe/btn_inframe_red_2_touched.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = __textSubMenuFontSize__,
            label = language["mngClassListScene"]["delete"],
            onRelease = deleteButtonEvent
        }
        row.delete_button.rowData = rowData
        row.delete_button.rowData.index = row.index
        row.delete_button.anchorX = 0
        row.delete_button.x = row.update_button.x
        row.delete_button.y = rowHeight * 0.75 - 5
        row:insert(row.delete_button)
        if user.userData.jobType == __TEACHER__ then
            row.delete_button.alpha = 0
        end
    else
        row.rect = display.newRoundedRect(row.width/2, row.height/2, row.width - 12, row.height - 10, 6)
        row:insert(row.rect)

        row.noDataimg = display.newImageRect("images/assets1/icon_no_data.png", 360, 200)
        row.noDataimg.anchorY = 0
        row.noDataimg.x = display.contentCenterX
        row.noDataimg.y = 20
        row:insert(row.noDataimg)

        row.noData_txt = display.newText(language["common"]["there_is_nodata"], 12, 0, native.systemFont, 12)
        row.noData_txt.anchorY = 0
        row.noData_txt:setFillColor( 0 ,0 ,0 )
        row.noData_txt.y = row.noDataimg.y + row.noDataimg.height + 10
        row.noData_txt.x = display.contentCenterX
        row:insert(row.noData_txt)
    end
end

local function onRowTouch( event )
    if event.phase == "release" then
    end
    return true
end

local function scrollListener( event )
   return true
end

local function onLeftButton(event)
    if event.phase == "ended" then
        storyboard.purgeScene("scripts.mngDirectorScene")
        storyboard.gotoScene("scripts.mngDirectorScene", "slideRight", 300)  
    end
    return true
end

local function onAddButton(event)
    if event.phase == "ended" then
        storyboard.purgeScene("scripts.mngClassAddScene")
        storyboard.gotoScene("scripts.mngClassAddScene", "slideLeft", 300) 
    end
    return true
end

function scene:createScene( event )
    local group = self.view
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentWidth / 2
    bg.y = display.contentHeight / 2
    group:insert(bg)
    
    local nameRect = display.newRect(group, display.contentCenterX, __statusBarHeight__ + 65, __appContentWidth__, NAME_BAR_HEIGHT )
    nameRect.strokeWidth = 0
    nameRect:setFillColor( 1, 0, 0 )
    nameRect:setStrokeColor( 0, 0, 0)
    
    local tag_Opt = {
        parent = group,
        text = user.getNameTagByAuthority(),
        x = display.contentCenterX,
        width = __appContentWidth__,
        y = __statusBarHeight__ + 68,
        font = native.systemFontBold,
        fontSize = __buttonFontSize__,
        align = "center"
    }
    
    local labelTag = display.newText(tag_Opt)
    labelTag:setFillColor( 1 )
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["mngClassListScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",    
    }
    
    local btn_right_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__},
        label = language["mngClassListScene"]["add"],
        onEvent = onAddButton,
        width = 100,
        height = 50,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        defaultFile = "images/top_with_texts/btn_top_text_input_normal.png",
        overFile = "images/top_with_texts/btn_top_text_input_touched.png",    
    }
    
    mngTable = widget.newTableView{
        top = __statusBarHeight__ + nameRect.height +  NAVI_BAR_HEIGHT,
        height = __appContentHeight__ - (NAVI_BAR_HEIGHT) - nameRect.height - __statusBarHeight__,
        width = __appContentWidth__,
    	maxVelocity = 1,
        backgroundColor = { 0.9, 0.9, 0.9, 0},
        noLines = true,
        hideBackground = true,
        rowTouchDelay = __tableRowTouchDelay__,
        isBounceEnabled = true,
    	onRowRender = onRowRender,
    	onRowTouch = onRowTouch,
    	listener = scrollListener
    }
    mngTable.x = display.contentCenterX
    group:insert(mngTable)
    
    local navBar = nil
    if user.userData.jobType == __TEACHER__ then
        navBar = widget.newNavigationBar({
            title = language["mngClassListScene"]["title"],
            width = __appContentWidth__,
            background = "images/top/bg_top.png",
            titleColor = __NAVBAR_TXT_COLOR__,
            font = native.systemFontBold,
            fontSize = __navBarTitleFontSize__,
            leftButton = btn_left_opt
        })
    else
        navBar = widget.newNavigationBar({
            title = language["mngClassListScene"]["title"],
            width = __appContentWidth__,
            background = "images/top/bg_top.png",
            titleColor = __NAVBAR_TXT_COLOR__,
            font = native.systemFontBold,
            fontSize = __navBarTitleFontSize__,
            leftButton = btn_left_opt,
            rightButton = btn_right_opt
        })
    end
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)
    activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
    api.get_mng_class_list(user.userData.centerid, listCallback)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.isAction = false
    storyboard.returnTo = "scripts.mngDirectorScene"
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
    
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
    print( "Showing overlay: " .. event.sceneName )
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
    print( "Overlay removed: " .. event.sceneName )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )

-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )

---------------------------------------------------------------------------------

return scene

