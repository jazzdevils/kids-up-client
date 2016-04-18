require("widgets.widgetext")
require("widgets.widget_newNavBar")
require("scripts.user_dataDefine")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
local utils = require("scripts.commonUtils")
local language = getLanguage()

local navBar
local memberType, memberTypeLabel
local centerType, centerTypeLabel
local centerAddressTitle
local countryId, countryName, stateId, stateName, cityId, cityName, detailAddress
local countryId2, stateId2, cityId2
local centerAddressRefData = {}
local countryButton, stateButton, cityButton
local centerNameField, centerName, centerButton, centerId, classId, className, detailAddressField
local invitationCodeField, invitationCode, invitationCodeLabel, invitation_desc

local function onNextButton(event)
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        
        if countryId == nil then
            utils.showMessage(language["joinScene"]["notselected_country"])
            return true;
        end
        if stateId == nil then
            utils.showMessage(language["joinScene"]["notselected_state"])
            return true;
        end
        if cityId == nil then
            utils.showMessage(language["joinScene"]["notselected_city"])
            return true;
        end
        
        if detailAddressField:getText() == nil or detailAddressField:getText() == "" then
            utils.showMessage(language["joinScene"]["detail_addressfield_hint"])
            return true;
        end
        
        if centerNameField:getText() == nil or centerNameField:getText() == "" then
            utils.showMessage(language["joinScene"]["centername_textfield_hint"])
            return true;
        end
        
        local options = {
            effect = "slideLeft",
            time = 300,
            params = {
                memberType = memberType,
                memberTypeLabel = memberTypeLabel,
                centerType = centerType,
                centerTypeLabel = centerTypeLabel,
                countryId = countryId,
                countryName = countryName,
                stateId = stateId,
                stateName = stateName,
                cityId = cityId,
                cityName = cityName,
            }
        }
        
        options.params.centerId = nil
        options.params.centerName = centerNameField:getText()
        options.params.detailAddress = detailAddressField:getText()
        options.params.classId = nil
        options.params.className = nil
        storyboard.purgeScene("scripts.member1InfoScene")
        storyboard.gotoScene( "scripts.member1InfoScene", options)
    end
    
    return true
end

local function onBackButton(event)
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        
        local options = {
            effect = "slideRight",
            time = 300,
            params = {
                memberType = memberType,
                memberTypeLabel = memberTypeLabel,
                centerType = centerType,
                centerTypeLabel = centerTypeLabel,
                countryId = countryId,
                countryName = countryName,
                stateId = stateId,
                stateName = stateName,
                cityId = cityId,
                cityName = cityName,
                centerName = memberType == __DIRECTOR__ and centerNameField:getText() or centerName,
                detailAddress = memberType == __DIRECTOR__ and detailAddressField:getText() or detailAddress,
                centerId = centerId,
                classId = classId,
                className = className,
                invitationCode = invitationCode,
            }
        }
        storyboard.purgeScene("scripts.centerTypeScene")
        storyboard.gotoScene( "scripts.centerTypeScene", options ) 
    end
    
    return true
end

local function countryButtonEvent( event )
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        
        local options = {
            effect = "fade",
            time = 300,
            params = {
                centerAddressRefData = centerAddressRefData
            },
            isModal = true
        }
        storyboard.showOverlay( "scripts.countryListScene" ,options )
        return true
    end
    
    return true
end

local function stateButtonEvent( event )
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        
        if countryId ~= nil then
            centerAddressRefData.centerType = centerType
            centerAddressRefData.cntFlag = 0
            centerAddressRefData.countryId = countryId
            
            local options = {
                effect = "fade",
                time = 300,
                params = {
                    centerAddressRefData = centerAddressRefData
                },
                isModal = true
            }
            storyboard.showOverlay( "scripts.stateListScene", options ) 
        else
            utils.showMessage(language["joinScene"]["notselected_country"])
        end
        return true
    end
    
    return true
end

local function cityButtonEvent( event )
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        
        if stateId ~= nil then
            centerAddressRefData.centerType = centerType
            centerAddressRefData.cntFlag = 0
            centerAddressRefData.stateId = stateId
            
            local options = {
                effect = "fade",
                time = 300,
                params = {
                    centerAddressRefData = centerAddressRefData
                },
                isModal = true
            }
            storyboard.showOverlay( "scripts.cityListScene", options ) 
        else
            utils.showMessage(language["joinScene"]["notselected_state"])
        end
        return true
    end
    
    return true
end

local function centerButtonEvent( event )
    if event.phase == "ended" then
        native.setKeyboardFocus(nil)
        
        if cityId ~= nil then
            centerAddressRefData.centerType = centerType
            centerAddressRefData.countryId = countryId
            centerAddressRefData.stateId = stateId
            centerAddressRefData.cityId = cityId
            local options = {
                effect = "fade",
                time = 300,
                params = {
                    centerAddressRefData = centerAddressRefData
                },
                isModal = true
            }
            storyboard.showOverlay( "scripts.centerListScene", options ) 
        else
            utils.showMessage(language["joinScene"]["notselected_city"])
        end
        return true
    end
    
    return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
end

function scene:willEnterScene( event )
    local group = self.view

    local params = event.params
    memberType = params.memberType
    memberTypeLabel = params.memberTypeLabel
    centerType = params.centerType
    centerTypeLabel = params.centerTypeLabel
    countryId = params.countryId
    countryName = params.countryName
    stateId = params.stateId
    stateName = params.stateName
    cityId = params.cityId
    cityName = params.cityName
    centerName = params.centerName
    centerId = params.centerId
    classId = params.classId
    className = params.className
    invitationCode = params.invitationCode
    detailAddress = params.detailAddress

    local b = display.newRect(group, 0,0, __appContentWidth__, __appContentHeight__)
    b.anchorX, b.anchorY = 0,0
    b:setFillColor(0.9,0.9,0.9,1)
    b:addEventListener("touch",function (event) native.setKeyboardFocus(nil) end )

    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __appContentWidth__, __appContentHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY

    local btn_left_opt = {
        label = language["top"]["back"],
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        onEvent = onBackButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_back_normal.png",
        overFile = "images/top_with_texts/btn_top_text_back_touched.png",
    }

    local btn_right_opt = {
        label = language["top"]["next"],
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        onEvent = onNextButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_next_normal.png",
        overFile = "images/top_with_texts/btn_top_text_next_touched.png",
    }

    centerAddressTitle = string.gsub(language["joinScene"]["input_centername"], "_CENTER_", language["joinScene"]["facilityname"])
    
    navBar = widget.newNavigationBar({
        title = centerAddressTitle,
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt,
    })    
    group:insert(navBar)

    local progressFrame = display.newRect( group, display.contentCenterX, navBar.height + 3, __appContentWidth__, 6 )
    progressFrame.strokeWidth = 0
    progressFrame:setFillColor( 0, 0, 0 )
    
    local logoFooter = display.newImageRect(group, "images/logo/logo_footer.png", __appContentWidth__, 30)
    logoFooter.x = display.contentCenterX
    logoFooter.anchorY = 0
    logoFooter.y = __appContentHeight__ - logoFooter.height

    local picFooter = display.newImageRect(group, "images/bg_set/pic_footer.png", __backgroundWidth__, 70)
    picFooter.x = display.contentCenterX
    picFooter.anchorY = 0
    picFooter.y = __appContentHeight__ - picFooter.height - logoFooter.height

    local bg_w = display.newImageRect(group, "images/bg_set/bg_frame_320x250.png", __appContentWidth__ - 40, 310)
    bg_w.anchorX = 0
    bg_w.anchorY = 0
    bg_w.x = (__appContentWidth__ - bg_w.width) * 0.5
    bg_w.y = navBar.height + progressFrame.height + 20
    
    local countryLabel = display.newText(language["joinScene"]["country_label"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    countryLabel.anchorX = 0
    countryLabel.anchorY = 0
    countryLabel.x = bg_w.x + 20
    countryLabel.y = bg_w.y + 4
    countryLabel:setFillColor(0, 0, 0)
    group:insert(countryLabel)

    countryButton = widget.newButton
    {
        width = bg_w.width - 40,
        height = 30,
        defaultFile = "images/input/selectbox_full_width.png",
        overFile = "images/input/selectbox_full_width.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = language["joinScene"]["country_select_txt"],
        onRelease = countryButtonEvent
    }    
    countryButton.anchorY = 0
    countryButton.x = display.contentCenterX
    countryButton.y = countryLabel.y + countryLabel.height
    group:insert(countryButton)
    
    local stateLabel = display.newText(language["joinScene"]["state_label"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    stateLabel.anchorX = 0
    stateLabel.anchorY = 0
    stateLabel.x = countryLabel.x
    stateLabel.y = countryButton.y + countryButton.height + 10
    stateLabel:setFillColor(0, 0, 0)
    group:insert(stateLabel)
    
    stateButton = widget.newButton
    {
        width = bg_w.width - 40,
        height = 30,
        defaultFile = "images/input/selectbox_full_width.png",
        overFile = "images/input/selectbox_full_width.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = language["joinScene"]["state_select_txt"],
        onRelease = stateButtonEvent
    }
    stateButton.label_org = language["joinScene"]["state_select_txt"]
    stateButton.anchorY = 0
    stateButton.x = display.contentCenterX
    stateButton.y = stateLabel.y + stateLabel.height
    group:insert(stateButton)
    
    local cityLabel = display.newText(language["joinScene"]["city_label"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    cityLabel.anchorX = 0
    cityLabel.anchorY = 0
    cityLabel.x = stateLabel.x
    cityLabel.y = stateButton.y + stateButton.height + 10
    cityLabel:setFillColor(0, 0, 0)
    group:insert(cityLabel)
    
    cityButton = widget.newButton
    {
        width = bg_w.width - 40,
        height = 30,
        defaultFile = "images/input/selectbox_full_width.png",
        overFile = "images/input/selectbox_full_width.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = language["joinScene"]["city_select_txt"],
        onRelease = cityButtonEvent
    }
    cityButton.label_org = language["joinScene"]["city_select_txt"]
    cityButton.anchorY = 0
    cityButton.x = display.contentCenterX
    cityButton.y = cityLabel.y + cityLabel.height
    group:insert(cityButton)
    
    local addressLabel = display.newText(language["joinScene"]["detail_address"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    addressLabel.anchorX = 0
    addressLabel.anchorY = 0
    addressLabel.x = cityLabel.x
    addressLabel.y = cityButton.y + cityButton.height + 10
    addressLabel:setFillColor(0, 0, 0)
    group:insert(addressLabel)
    
    detailAddressField = widget.newEditField
    {
        width = bg_w.width - 40,
        editHintColor = {1,1,1,1},
        hint = language["joinScene"]["detail_addressfield_hint"],
        editFont = native.systemFontBold,
        editFontSize = __textFieldFontSize__,
        editFontColor = {1,1,1,1},
        slideGroup = group,
        frame = {
            cornerRadius = 1,
            strokeWidth = 1,
            strokeColor = __EDITFIELD_FILL_COLOR__,
            fillColor = __EDITFIELD_FILL_COLOR__
        },
        required = true,
        errorFrame = {
            cornerRadius = 1
        },
        buttons = {
            {
                kind = "clear",
                defaultFile = "images/widgets/clear.png"
            }
        }
    }
    detailAddressField.anchorY = 0
    detailAddressField.x = display.contentCenterX
    detailAddressField.y = addressLabel.y + addressLabel.height 
    group:insert(detailAddressField)
    
    local centerLabel = display.newText(language["joinScene"]["center_label"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
    centerLabel.anchorX = 0
    centerLabel.anchorY = 0
    centerLabel.x = cityLabel.x
    centerLabel.y = detailAddressField.y + detailAddressField.height + 10
    centerLabel:setFillColor(0, 0, 0)
    group:insert(centerLabel)
    
    centerNameField = widget.newEditField
    {
        width = bg_w.width - 40,
        editHintColor = {1,1,1,1},
        hint = language["joinScene"]["centername_textfield_hint"],
        editFont = native.systemFontBold,
        editFontSize = __textFieldFontSize__,
        editFontColor = {1,1,1,1},
        slideGroup = group,
        frame = {
            cornerRadius = 1,
            strokeWidth = 1,
            strokeColor = __EDITFIELD_FILL_COLOR__,
            fillColor = __EDITFIELD_FILL_COLOR__
        },
        required = true,
        errorFrame = {
            cornerRadius = 1
        },
        buttons = {
            {
                kind = "clear",
                defaultFile = "images/widgets/clear.png"
            }
        }
    }
    centerNameField.anchorY = 0
    centerNameField.x = display.contentCenterX
    centerNameField.y = centerLabel.y + centerLabel.height
    group:insert(centerNameField)
    
    if countryId ~= nil then
        countryButton:setLabel( countryName )
    end

    if stateId ~= nil then
        stateButton:setLabel(stateName)
    end

    if cityId ~= nil then
        cityButton:setLabel(cityName)
    end
    
    if centerName ~= nil then
        centerNameField:setText(centerName)
    end
    
    if detailAddress ~= nil then
        detailAddressField:setText(detailAddress)
    end
end

function scene:enterScene( event )
    local group = self.view

    local progress = display.newRoundedRect( group, 0, 0, __appContentWidth__ * 3 / 5, 6, 3 )
    progress.anchorX = 0
    progress.anchorY = 0
    progress.x = display.contentWidth - __appContentWidth__
    progress.y = navBar.height
    progress:setFillColor( unpack(__PROGRESS_BAR_COLOR) )
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
    group:removeSelf()
    group = nil
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local group = self.view
    print( "overlayBegan: " .. event.sceneName )
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
    
    if (centerAddressRefData.countryId ~= nil) then
        countryId = centerAddressRefData.countryId
        countryName = centerAddressRefData.countryName
        if (event.sceneName == "scripts.countryListScene") then
            countryButton:setLabel(countryName)
            if countryId2 == nil then
                countryId2 = countryId
            end
            if countryId ~= countryId2 then
                centerAddressRefData.stateId = nil
                centerAddressRefData.stateName = nil
                centerAddressRefData.cityId = nil
                centerAddressRefData.cityName = nil
                centerAddressRefData.centerId = nil
                centerAddressRefData.centerName = nil
                stateId = nil
                stateName = nil
                cityId = nil
                cityName = nil
                centerId = nil
                centerName = nil
                detailAddress = nil
                stateButton:setLabel(stateButton.label_org)
                cityButton:setLabel(cityButton.label_org)
            end
            countryId2 = countryId
        end
    end
    
    if (centerAddressRefData.stateId ~= nil) then
        stateId = centerAddressRefData.stateId
        stateName = centerAddressRefData.stateName
        if (event.sceneName == "scripts.stateListScene") then
            stateButton:setLabel(stateName)
            if stateId2 == nil then
                stateId2 = stateId
            end
            if stateId ~= stateId2 then
                centerAddressRefData.cityId = nil
                centerAddressRefData.cityName = nil
                centerAddressRefData.centerId = nil
                centerAddressRefData.centerName = nil
                centerAddressRefData.detailAddress = nil
                cityId = nil
                cityName = nil
                centerId = nil
                centerName = nil
                detailAddress = nil
                cityButton:setLabel(cityButton.label_org)
            end
            stateId2 = stateId
        end
    end
    
    if (centerAddressRefData.cityId ~= nil) then
        cityId = centerAddressRefData.cityId
        cityName = centerAddressRefData.cityName
        if (event.sceneName == "scripts.cityListScene") then
            cityButton:setLabel(cityName)
            if cityId2 == nil then
                cityId2 = cityId
            end
            if cityId ~= cityId2 then
                centerAddressRefData.centerId = nil
                centerAddressRefData.centerName = nil
                centerAddressRefData.detailAddress = nil
                centerId = nil
                centerName = nil
                detailAddress = nil
            end
            cityId2 = cityId
        end
    end
    if (centerAddressRefData.centerId ~= nil) then
        if (event.sceneName == "scripts.centerListScene") then
            centerId = centerAddressRefData.centerId
            centerName = centerAddressRefData.centerName
        end
    end
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

