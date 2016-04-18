---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------

require("widgets.widget_newNavBar")
require("scripts.user_dataDefine")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require("widget")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local html = require("scripts.htmlPageController")

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local help_button
local navBar
local memberType, memberTypeLabel, centerType, centerTypeLabel
local countryId, countryName, stateId, stateName, cityId, cityName, centerName, centerId, classId, className, invitationCode, detailAddress
local radioChecked3, radioUnChecked3, radioChecked2, radioUnChecked2, radioChecked1, radioUnChecked1

local function onBackButton(event)
    if event.phase == "ended" then
--        storyboard.purgeScene("scripts.top") 
        storyboard.removeScene("scripts.top") 
        storyboard.gotoScene( "scripts.top", "slideRight", 300) 
    end
    
    return true
end

local function onNextButton(event)
    if event.phase == "ended" then
        if memberType == nil then
            utils.showMessage( language["joinScene"]["notselected_membertype"] )
        else
            local options =
            {
                effect = "slideLeft",
                time = 300,
                params =
                {
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
                    centerName = centerName,
                    detailAddress = detailAddress,
                    centerId = centerId,
                    classId = classId,
                    className = className,
                    invitationCode = invitationCode,
                }
            }
            storyboard.purgeScene("scripts.centerTypeScene")
            storyboard.gotoScene( "scripts.centerTypeScene", options ) 
        end
    end
    
    return true
end

local function onRadioButtonPress( event )
    memberType = event.target.memberType
    memberTypeLabel = event.target.memberTypeLabel
end

local function radio1Fired()
    memberType = radioChecked1.memberType
    memberTypeLabel = radioChecked1.memberTypeLabel
    radioChecked3.alpha = 0
    radioUnChecked3.alpha = 1
    radioChecked2.alpha = 0
    radioUnChecked2.alpha = 1
    radioChecked1.alpha = 1
    radioUnChecked1.alpha = 0
    
    help_button.helpPage.jobType = __DIRECTOR__ -- 원장
    help_button.isVisible = true
end

local function radio2Fired()
    memberType = radioChecked2.memberType
    memberTypeLabel = radioChecked2.memberTypeLabel
    radioChecked3.alpha = 0
    radioUnChecked3.alpha = 1
    radioChecked2.alpha = 1
    radioUnChecked2.alpha = 0
    radioChecked1.alpha = 0
    radioUnChecked1.alpha = 1
    
    help_button.helpPage.jobType = __TEACHER__ -- 교사
    help_button.isVisible = true
end

local function radio3Fired()
    memberType = radioChecked3.memberType
    memberTypeLabel = radioChecked3.memberTypeLabel
    radioChecked3.alpha = 1
    radioUnChecked3.alpha = 0
    radioChecked2.alpha = 0
    radioUnChecked2.alpha = 1
    radioChecked1.alpha = 0
    radioUnChecked1.alpha = 1
    
    help_button.helpPage.jobType = __PARENT__ -- 부모
    help_button.isVisible = true
end

local function label1TouchListener(event) 
    radio1Fired()
end

local function label2TouchListener(event) 
    radio2Fired()
end

local function label3TouchListener(event) 
    radio3Fired()
end

function scene:createScene( event )
    local group = self.view
    
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

    navBar = widget.newNavigationBar({
        title = language["joinScene"]["membertype_select_title"],
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt,
    })
    navBar:addEventListener("touch", function() return true end )
    group:insert(navBar)

    local progressFrame = display.newRect( group, display.contentCenterX, navBar.height + 3, __appContentWidth__, 6 )
    progressFrame.strokeWidth = 0
    progressFrame:setFillColor( 0, 0, 0 )

    local bg_w = display.newImageRect(group, "images/bg_set/bg_frame_320x250.png", __appContentWidth__ - 40, 300)
    bg_w.x = display.contentCenterX
    bg_w.anchorY = 0
    bg_w.y = navBar.height + progressFrame.height + 20
    bg_w.alpha = 0
    
    
    local roundRect3 = display.newRoundedRect( group, 0, 0, bg_w.width - 40, 50, 6 )
    roundRect3.strokeWidth = 3
    roundRect3:setFillColor( 1 )
    roundRect3:setStrokeColor( 118/255, 135/255, 151/255 )
    roundRect3.anchorX = 0
    roundRect3.x = (__appContentWidth__ - roundRect3.width) * 0.5
    roundRect3.y = bg_w.y + (bg_w.height / 4) / 2 - 8
    roundRect3:addEventListener( "touch", label3TouchListener )
    
    radioChecked3 = display.newImageRect("images/input/radio_checked.png", 22, 22)
    radioChecked3.anchorX = 0
    radioChecked3.x = roundRect3.x + 10
    radioChecked3.y = roundRect3.y
    radioChecked3.memberType = __PARENT__
    radioChecked3.memberTypeLabel = language["joinScene"]["membertype3_label"]
    group:insert(radioChecked3)
    if memberType == __PARENT__ then
        radioChecked3.alpha = 1
    else
        radioChecked3.alpha = 0
    end

    radioUnChecked3 = display.newImageRect("images/input/radio_unchecked.png", 22, 22)
    radioUnChecked3.anchorX = 0
    radioUnChecked3.x = roundRect3.x + 10
    radioUnChecked3.y = roundRect3.y
    group:insert(radioUnChecked3)
    if memberType == __PARENT__ then
        radioUnChecked3.alpha = 0
    else
        radioUnChecked3.alpha = 1
    end
    
    local label3Options = 
    {
        parent = group,
        text = language["joinScene"]["membertype3_label"],
        width = 100,
        font = native.systemFontBold,   
        fontSize = __textLabelFontSize__,
        align = "left"
    }

    local label3 = display.newText(label3Options)
    label3.anchorX = 0
    label3.x = radioChecked3.x + radioChecked3.width + 10
    label3.y = radioChecked3.y
    label3:setFillColor( 0,0,0 )
    label3:addEventListener( "touch", label3TouchListener )

    local roundRect2 = display.newRoundedRect( group, 0, 0, roundRect3.width, 50, 6 )
    roundRect2.strokeWidth = 3
    roundRect2:setFillColor( 1 )
    roundRect2:setStrokeColor( 118/255, 135/255, 151/255 )
    roundRect2.anchorX = 0
    roundRect2.x = 40
    roundRect2.y = bg_w.y + bg_w.height / 4 + (bg_w.height / 4) / 2 - 20
    roundRect2:addEventListener( "touch", label2TouchListener )
    
    radioChecked2 = display.newImageRect("images/input/radio_checked.png", 22, 22)
    radioChecked2.anchorX = 0
    radioChecked2.x = roundRect2.x + 10
    radioChecked2.y = roundRect2.y
    radioChecked2.memberType = __TEACHER__
    radioChecked2.memberTypeLabel = language["joinScene"]["membertype2_label"]
    group:insert(radioChecked2)
    if memberType == __TEACHER__ then
        radioChecked2.alpha = 1
    else
        radioChecked2.alpha = 0
    end

    radioUnChecked2 = display.newImageRect("images/input/radio_unchecked.png", 22, 22)
    radioUnChecked2.anchorX = 0
    radioUnChecked2.x = roundRect2.x + 10
    radioUnChecked2.y = roundRect2.y
    group:insert(radioUnChecked2)
    if memberType == __TEACHER__ then
        radioUnChecked2.alpha = 0
    else
        radioUnChecked2.alpha = 1
    end
    
    local label2Options = 
    {
        parent = group,
        text = language["joinScene"]["membertype2_label"],
        width = 100,
        font = native.systemFontBold,   
        fontSize = __textLabelFontSize__,
        align = "left"
    }
    local label2 = display.newText(label2Options)
    label2.anchorX = 0
    label2.x = radioChecked2.x + radioChecked2.width + 10
    label2.y = roundRect2.y
    label2:setFillColor( 0,0,0 )
    label2:addEventListener( "touch", label2TouchListener )

    local roundRect1 = display.newRoundedRect( group, 0, 0, roundRect3.width, 70, 6 )
    roundRect1.strokeWidth = 3
    roundRect1:setFillColor( 1 )
    roundRect1:setStrokeColor( 118/255, 135/255, 151/255 )
    roundRect1.anchorX = 0
    roundRect1.x = 40
    roundRect1.y = bg_w.y + bg_w.height * 2 / 4 + (bg_w.height / 4) / 2 - 22
    roundRect1:addEventListener( "touch", label1TouchListener )

    radioChecked1 = display.newImageRect("images/input/radio_checked.png", 22, 22)
    radioChecked1.anchorX = 0
    radioChecked1.x = roundRect1.x + 10
    radioChecked1.y = roundRect1.y - 15
    radioChecked1.memberType = __DIRECTOR__
    radioChecked1.memberTypeLabel = language["joinScene"]["membertype1_label"]
    group:insert(radioChecked1)
    if memberType == __DIRECTOR__ then
        radioChecked1.alpha = 1
    else
        radioChecked1.alpha = 0
    end

    radioUnChecked1 = display.newImageRect("images/input/radio_unchecked.png", 22, 22)
    radioUnChecked1.anchorX = 0
    radioUnChecked1.x = roundRect1.x + 10
    radioUnChecked1.y = roundRect1.y - 15
    group:insert(radioUnChecked1)
    if memberType == __DIRECTOR__ then
        radioUnChecked1.alpha = 0
    else
        radioUnChecked1.alpha = 1
    end
    
    local label1Options = 
    {
        parent = group,
        text = language["joinScene"]["membertype1_label"],     
        width = 100,
        font = native.systemFontBold,   
        fontSize = __textLabelFontSize__,
        align = "left"
    }
    local label1 = display.newText(label1Options)
    label1.anchorX = 0
    label1.x = radioChecked1.x + radioChecked1.width + 10
    label1.y = roundRect1.y - 15
    label1:setFillColor( 0,0,0 )
    label1:addEventListener( "touch", label1TouchListener )
    
    local label1_DescOptions = 
    {
        parent = group,
        text = language["joinScene"]["membertype1_label_desc"],     
        width = roundRect1.width - 50,
        font = native.systemFont,   
        fontSize = __textLabelFontSize__,
        align = "left"
    }
    local label1_Desc = display.newText(label1_DescOptions)
    label1_Desc.anchorX = 0
    label1_Desc.x = radioChecked1.x + radioChecked1.width + 10
    label1_Desc.y = roundRect1.y + 10
    label1_Desc:setFillColor( 0,0,0 )
    label1_Desc:addEventListener( "touch", label1TouchListener )

    local logoFooter = display.newImageRect(group, "images/logo/logo_footer.png", __appContentWidth__, 30)
    logoFooter.x = display.contentCenterX
    logoFooter.anchorY = 0
    logoFooter.y = __appContentHeight__ - logoFooter.height

    local picFooter = display.newImageRect(group, "images/bg_set/pic_footer.png", __backgroundWidth__, 70)
    picFooter.x = display.contentCenterX
    picFooter.anchorY = 0
    picFooter.y = __appContentHeight__ - picFooter.height - logoFooter.height
    
    help_button = widget.newButton
    {
        width = roundRect1.width ,
        height = 40 ,
        left = 0,--display.contentCenterX - (155/2)  , 
        top = display.contentCenterY + 105, 
        defaultFile = "images/button/btn_black_1_normal.png",
        overFile = "images/button/btn_black_1_touched.png",
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        emboss = true,
        labelYOffset = -2,
        fontSize = __textSubMenuFontSize__,
        label = language["help"]["join"],
        onRelease = function(event)
                        if event.phase == "ended" then
                            html.showHelpOnBrowser(help_button.helpPage.jobType, help_button.helpPage.helpType)
--                            utils.showWebView(html.getURLofHelp(help_button.helpPage.jobType, help_button.helpPage.helpType), language["help"]["join"])
                        end
                    end
    }
    help_button.x = display.contentCenterX
    help_button.anchorY = 0
    help_button.y = roundRect1.y + roundRect1.height - 20
    group:insert(help_button)
    help_button.isVisible = false
    help_button.helpPage = {jobType = "", helpType = "join_help"}
    
    local params = event.params
    if params then
        memberType = params.memberType
--        memberTypeLabel = params.memberTypeLabel
--        centerType = params.centerType
--        centerTypeLabel = params.centerTypeLabel
--        countryId = params.countryId
--        countryName = params.countryName
--        stateId = params.stateId
--        stateName = params.stateName
--        cityId = params.cityId
--        cityName = params.cityName
--        centerName = params.centerName
--        centerId = params.centerId
--        classId = params.classId
--        className = params.className
--        invitationCode = params.invitationCode
        memberTypeLabel = nil
        centerType = nil
        centerTypeLabel = nil
        countryId = nil
        countryName = nil
        stateId = nil
        stateName = nil
        cityId = nil
        cityName = nil
        centerName = nil
        detailAddress = nil
        centerId = nil
        classId = nil
        className = nil
        invitationCode = nil
        
        if memberType == __DIRECTOR__ then
            radio1Fired()
        elseif memberType == __TEACHER__ then
            radio2Fired()
        elseif memberType == __PARENT__ then
            radio3Fired()
        end
    else
        memberType = nil
        memberTypeLabel = nil
        centerType = nil
        centerTypeLabel = nil
        countryId = nil
        countryName = nil
        stateId = nil
        stateName = nil
        cityId = nil
        cityName = nil
        centerName = nil
        detailAddress = nil
        centerId = nil
        classId = nil
        className = nil
        invitationCode = nil
    end
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    local progress = display.newRoundedRect( group, 0, 0, __appContentWidth__ * 1 / 5, 6, 3 )
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
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
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