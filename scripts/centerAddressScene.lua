
require("widgets.widgetext")
require("widgets.widget_newNavBar")
require("scripts.user_dataDefine")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
local utils = require("scripts.commonUtils")
local api = require("scripts.api")
local json = require("json")
local language = getLanguage()

local navBar
local memberType, memberTypeLabel
local centerType, centerTypeLabel
local centerAddressTitle
local countryId, countryName, stateId, stateName, cityId, cityName
local countryId2, stateId2, cityId2
local centerAddressRefData = {}
local countryButton, stateButton, cityButton
local centerNameField, centerName, centerButton, centerId, classId, className
local invitationCodeField, invitationCode, bg_invitation, invitation_desc, searchField

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
        if memberType == __DIRECTOR__ then
            if centerNameField:getText() == nil or centerNameField:getText() == "" then
                utils.showMessage(language["joinScene"]["centername_textfield_hint"])
                return true;
            end
        end
        if memberType == __TEACHER__ or memberType == __PARENT__ then
            if centerId == nil then
                utils.showMessage(centerAddressTitle)
                return true;
            end
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
                cityName = cityName
            }
        }
        if memberType == __DIRECTOR__ then
            options.params.centerId = nil
            options.params.centerName = centerNameField:getText()
            options.params.classId = nil
            options.params.className = nil
            storyboard.purgeScene("scripts.member1InfoScene")
            storyboard.gotoScene( "scripts.member1InfoScene", options)
        elseif memberType == __TEACHER__ then
            options.params.centerId = centerId
            options.params.centerName = centerName
            options.params.classId = classId
            options.params.className = className
            options.params.invitationCode = invitationCode
            if invitationCode ~= "" and invitationCode == invitationCodeField:getText() then
                options.params.invitationCodeInputResult = "1"
                storyboard.purgeScene("scripts.member2InfoScene")
                storyboard.gotoScene( "scripts.member2InfoScene", options)
            elseif invitationCode ~= "" and invitationCodeField:getText() ~= "" and invitationCode ~= invitationCodeField:getText() then
                local alert = native.showAlert( language["appTitle"], language["joinScene"]["invitation_not_valid"], { language["joinScene"]["confirm"], language["joinScene"]["cancel"] }, 
                    function(event)
                        if "clicked" == event.action then
                            local i = event.index
                            if 1 == i then
                                options.params.invitationCodeInputResult = "0"
                                storyboard.purgeScene("scripts.member2InfoScene")
                                storyboard.gotoScene( "scripts.member2InfoScene", options)
                            elseif 2 == i then
                            end
                        end
                    end 
                )
            else
                options.params.invitationCodeInputResult = "0"
                storyboard.purgeScene("scripts.member2InfoScene")
                storyboard.gotoScene( "scripts.member2InfoScene", options)
            end
        elseif memberType == __PARENT__ then
            options.params.centerId = centerId
            options.params.centerName = centerName
            options.params.classId = classId
            options.params.className = className
            options.params.invitationCode = invitationCode
            if invitationCode ~= "" and invitationCode == invitationCodeField:getText() then
                options.params.invitationCodeInputResult = "1"
                storyboard.purgeScene("scripts.member31InfoScene")
                storyboard.gotoScene( "scripts.member31InfoScene", options)
            elseif invitationCode ~= "" and invitationCodeField:getText() ~= "" and invitationCode ~= invitationCodeField:getText() then
                local alert = native.showAlert( language["appTitle"], language["joinScene"]["invitation_not_valid"], { language["joinScene"]["confirm"], language["joinScene"]["cancel"] }, 
                    function(event)
                        if "clicked" == event.action then
                            local i = event.index
                            if 1 == i then
                                options.params.invitationCodeInputResult = "0"
                                storyboard.purgeScene("scripts.member31InfoScene")
                                storyboard.gotoScene( "scripts.member31InfoScene", options)
                            elseif 2 == i then
                            end
                        end
                    end 
                )
            else
                options.params.invitationCodeInputResult = "0"
                storyboard.purgeScene("scripts.member31InfoScene")
                storyboard.gotoScene( "scripts.member31InfoScene", options)
            end
        else
            utils.showMessage(language["joinScene"]["membertype_select_err"])
        end
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
                centerId = centerId,
                classId = classId,
                className = className,
                invitationCode = invitationCode
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
            if memberType == __DIRECTOR__ then
                centerAddressRefData.cntFlag = 0
            else
                centerAddressRefData.cntFlag = 1
            end
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
            if memberType == __DIRECTOR__ then
                centerAddressRefData.cntFlag = 0
            else
                centerAddressRefData.cntFlag = 1
            end
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

    if memberType == __DIRECTOR__ then
        centerAddressTitle = string.gsub(language["joinScene"]["input_centername"], "_CENTER_", language["joinScene"]["facilityname"])
    else
        centerAddressTitle = string.gsub(language["joinScene"]["select_centername"], "_CENTER_", language["joinScene"]["facilityname"])
    end

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

    local bg_w = display.newImageRect(group, "images/bg_set/bg_frame_320x250.png", __appContentWidth__ - 40, 270)
    bg_w.x = display.contentCenterX
    bg_w.anchorY = 0
    bg_w.y = navBar.height + progressFrame.height + 20
    
    bg_invitation = display.newImageRect(group, "images/bg_set/bg_frame_320x60.png", __appContentWidth__ - 40, 50)
    bg_invitation.x = display.contentCenterX
    bg_invitation.anchorY = 0
    bg_invitation.y = bg_w.y + bg_w.height - 7
    
    searchField = widget.newEditField
    {
        width = bg_w.width - 40,
--        height = 32,
        editHintColor = {1,1,1,1},
        hint = language["joinScene"]["search_centername"],
        editFont = native.systemFontBold,
        editFontSize = __textFieldFontSize__,
        editFontColor = {1,1,1,1},
        slideGroup = group,
        isSecure = false,
        returnKey = "search",
        listener   =  function(event)
                        print("searchField listener : "..event.phase)
                        if event.phase == "began" then
                            
                        elseif ( event.phase == "submitted" ) then
                            local sWord = searchField:getText()
                            sWord = sWord:match( "^%s*(.-)%s*$" )
                            if sWord ~= "" then
                                centerAddressRefData.centerType = centerType
                                local options = {
                                    effect = "fade",
                                    time = 300,
                                    params = {
                                        centerAddressRefData = centerAddressRefData,
                                        searchName = sWord,
                                    },
                                    isModal = true
                                }
                                storyboard.showOverlay( "scripts.searchCenterListScene", options ) 
                            end
                        elseif event.phase == "editing" then
                            print( event.text )
                        end
                    end,
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
        inputType = "default",
        buttons = {
            {
                kind = "icon",
                defaultFile = "images/widgets/search.png"
            }
        }
    }
    searchField.x = display.contentCenterX
    searchField.anchorY = 0
    searchField.y = bg_w.y + 10
    group:insert(searchField)
    
--    local searchButton = widget.newButton
--    {
--        width = bg_w.width - 40,
--        height = 30,
--        defaultFile = "images/input/selectbox_full_width.png",
--        overFile = "images/input/selectbox_full_width.png",
--        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
--        emboss = true,
--        fontSize = __buttonFontSize__,
--        label = "Test",
--        onRelease = function(event)
--            if event.phase == "ended" then
--                centerAddressRefData.centerType = centerType
--                local sName = " "
--                local sName = "レイン "
--                sName = sName:match( "^%s*(.-)%s*$" )
----                if sName ~= "" then
--                    local options = {
--                        effect = "fade",
--                        time = 300,
--                        params = {
--                            centerAddressRefData = centerAddressRefData,
--                            searchName = sName,
--                        },
--                        isModal = true
--                    }
--                    storyboard.showOverlay( "scripts.searchCenterListScene", options ) 
----                end
--            end
--        end
--    }    
--    searchButton.anchorY = 0
--    searchButton.x = display.contentCenterX
--    searchButton.y = searchField.y - 15
--    group:insert(searchButton)
    
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
    countryButton.y = searchField.y + searchField.height + 15
    group:insert(countryButton)
    
--    local countryLabel = display.newText(language["joinScene"]["country_label"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
--    countryLabel.anchorX = 0
--    countryLabel.anchorY = 0
--    countryLabel.x = bg_w.x - bg_w.width * 0.5 + 20
--    countryLabel.y = countryButton.y - countryLabel.height
--    countryLabel:setFillColor(0, 0, 0)
--    group:insert(countryLabel)

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
    stateButton.y = countryButton.y + countryButton.height + 15
    group:insert(stateButton)
    
--    local stateLabel = display.newText(language["joinScene"]["state_label"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
--    stateLabel.anchorX = 0
--    stateLabel.anchorY = 0
--    stateLabel.x = bg_w.x - bg_w.width * 0.5 + 20
--    stateLabel.y = stateButton.y - stateLabel.height
--    stateLabel:setFillColor(0, 0, 0)
--    group:insert(stateLabel)

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
    cityButton.y = stateButton.y + stateButton.height + 15
    group:insert(cityButton)
    
--    local cityLabel = display.newText(language["joinScene"]["city_label"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
--    cityLabel.anchorX = 0
--    cityLabel.anchorY = 0
--    cityLabel.x = bg_w.x - bg_w.width * 0.5 + 20
--    cityLabel.y = cityButton.y - cityLabel.height
--    cityLabel:setFillColor(0, 0, 0)
--    group:insert(cityLabel)
    
    if memberType == __DIRECTOR__ then
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
        --centerNameField:setText("品川の幼稚園")
        centerNameField.anchorY = 0
        centerNameField.x = display.contentCenterX
        centerNameField.y = cityButton.y + cityButton.height + 15
        group:insert(centerNameField)
        
--        local centerLabel = display.newText(language["joinScene"]["center_label"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
--        centerLabel.anchorX = 0
--        centerLabel.anchorY = 0
--        centerLabel.x = bg_w.x - bg_w.width * 0.5 + 20
--        centerLabel.y = centerNameField.y - centerLabel.height + 3
--        centerLabel:setFillColor(0, 0, 0)
--        group:insert(centerLabel)
    else
        centerButton = widget.newButton {
            width = bg_w.width - 40,
            height = 30,
            defaultFile = "images/input/selectbox_full_width.png",
            overFile = "images/input/selectbox_full_width.png",
            labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            emboss = true,
            fontSize = __buttonFontSize__,
            label = centerAddressTitle,
            onRelease = centerButtonEvent
        }
        centerButton.label_org = centerAddressTitle
        centerButton.anchorY = 0
        centerButton.x = display.contentCenterX
        centerButton.y = cityButton.y + cityButton.height + 15
        group:insert(centerButton)
        
--        local centerLabel = display.newText(language["joinScene"]["center_label"], 0, 0, bg_w.width * 0.5, 20, native.systemFont, 12)
--        centerLabel.anchorX = 0
--        centerLabel.anchorY = 0
--        centerLabel.x = bg_w.x - bg_w.width * 0.5 + 20
--        centerLabel.y = centerButton.y - centerLabel.height
--        centerLabel:setFillColor(0, 0, 0)
--        group:insert(centerLabel)
        
        invitationCodeField = widget.newEditField
        {
            width = bg_w.width - 40,
            editHintColor = {1,1,1,1},
            hint = language["joinScene"]["invitation_code_input"],
            editFont = native.systemFontBold,
            editFontSize = __buttonFontSize__,
            editFontColor = {1,1,1,1},
            slideGroup = group,
            align = "center",
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
        invitationCodeField.anchorY = 0
        invitationCodeField.x = display.contentCenterX
        invitationCodeField.y = centerButton.y + centerButton.height + 15
        group:insert(invitationCodeField)
        
        invitation_desc = display.newText(language["joinScene"]["invitation_desc"], 0, 0, invitationCodeField.width, 0, native.systemFont, 11)
        invitation_desc.anchorX = 0
        invitation_desc.anchorY = 0
        invitation_desc.x = bg_w.x - bg_w.width * 0.5 + 20
        invitation_desc.y = invitationCodeField.y + invitationCodeField.height + 2
        invitation_desc:setFillColor(0, 0, 0)
        group:insert(invitation_desc)

        if invitationCode ~= nil and invitationCode ~= "" then
            invitationCodeField.isVisible = true
            bg_invitation.isVisible = true
            invitation_desc.isVisible = true
        else
            invitationCodeField.isVisible = false
            bg_invitation.isVisible = false
            invitation_desc.isVisible = false
        end
    end

    if countryId ~= nil then
        countryButton:setLabel( countryName )
    end

    if stateId ~= nil then
        stateButton:setLabel(stateName)
    end

    if cityId ~= nil then
        cityButton:setLabel(cityName)
    end
    
    if memberType == __DIRECTOR__ then
        if centerName ~= nil then
            centerNameField:setText(centerName)
        end
    end
    
    if centerId ~= nil then
        if centerName ~= nil then
            if memberType == __TEACHER__ or memberType == __PARENT__ then
                centerButton:setLabel(centerName)
            end
        end
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
    
    if (event.sceneName == "scripts.searchCenterListScene") then
        if centerAddressRefData.countryId then
            countryId = centerAddressRefData.countryId
            countryId2 = countryId
            countryName = centerAddressRefData.countryName
            countryButton:setLabel(countryName)

            stateId = centerAddressRefData.stateId
            stateId2 = stateId
            stateName = centerAddressRefData.stateName
            stateButton:setLabel(stateName)

            cityId = centerAddressRefData.cityId
            cityId2 = cityId
            cityName = centerAddressRefData.cityName
            cityButton:setLabel(cityName)

            centerId = centerAddressRefData.centerId
            centerName = centerAddressRefData.centerName
            centerButton:setLabel(centerName)
            centerButton:setLabel(centerName)

            invitationCode = centerAddressRefData.invitationCode
            if  invitationCode == nil or invitationCode == "" then
                invitationCodeField.isVisible = false
                bg_invitation.isVisible = false
                invitation_desc.isVisible = false
            else
                invitationCodeField.isVisible = true
                bg_invitation.isVisible = true
                invitation_desc.isVisible = true
            end
        end
    end
    
    if (centerAddressRefData.countryId ~= nil) then
        countryId = centerAddressRefData.countryId
        countryName = centerAddressRefData.countryName
        if (event.sceneName == "scripts.countryListScene" ) then
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
                stateButton:setLabel(stateButton.label_org)
                cityButton:setLabel(cityButton.label_org)
                if memberType == __TEACHER__ or memberType == __PARENT__ then
                    centerButton:setLabel(centerButton.label_org)
                    invitationCodeField.isVisible = false
                    invitationCode = ""
                    bg_invitation.isVisible = false
                    invitation_desc.isVisible = false
                end
            end
            countryId2 = countryId
        end
    end
    
    if (centerAddressRefData.stateId ~= nil) then
        stateId = centerAddressRefData.stateId
        stateName = centerAddressRefData.stateName
        if (event.sceneName == "scripts.stateListScene" ) then
            stateButton:setLabel(stateName)
            if stateId2 == nil then
                stateId2 = stateId
            end
            if stateId ~= stateId2 then
                centerAddressRefData.cityId = nil
                centerAddressRefData.cityName = nil
                centerAddressRefData.centerId = nil
                centerAddressRefData.centerName = nil
                cityId = nil
                cityName = nil
                centerId = nil
                centerName = nil
                cityButton:setLabel(cityButton.label_org)
                if memberType == __TEACHER__ or memberType == __PARENT__ then
                    centerButton:setLabel(centerButton.label_org)
                    invitationCodeField.isVisible = false
                    invitationCode = ""
                    bg_invitation.isVisible = false
                    invitation_desc.isVisible = false
                end
            end
            stateId2 = stateId
        end
    end
    
    if (centerAddressRefData.cityId ~= nil) then
        cityId = centerAddressRefData.cityId
        cityName = centerAddressRefData.cityName
        if (event.sceneName == "scripts.cityListScene" ) then
            cityButton:setLabel(cityName)
            if cityId2 == nil then
                cityId2 = cityId
            end
            if cityId ~= cityId2 then
                centerAddressRefData.centerId = nil
                centerAddressRefData.centerName = nil
                centerId = nil
                centerName = nil
                if memberType == __TEACHER__ or memberType == __PARENT__ then
                    centerButton:setLabel(centerButton.label_org)
                    invitationCodeField.isVisible = false
                    invitationCode = ""
                    bg_invitation.isVisible = false
                    invitation_desc.isVisible = false
                end
            end
            cityId2 = cityId
        end
    end
    
    if (centerAddressRefData.centerId ~= nil) then
        if (event.sceneName == "scripts.centerListScene" ) then
            centerId = centerAddressRefData.centerId
            centerName = centerAddressRefData.centerName
            if memberType == __TEACHER__ or memberType == __PARENT__ then
                invitationCode = centerAddressRefData.invitationCode
                centerButton:setLabel(centerName)
                if invitationCode == "" then
                    invitationCodeField.isVisible = false
                    bg_invitation.isVisible = false
                    invitation_desc.isVisible = false
                else
                    invitationCodeField.isVisible = true
                    bg_invitation.isVisible = true
                    invitation_desc.isVisible = true
                end
            end
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