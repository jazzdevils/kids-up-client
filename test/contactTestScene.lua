---------------------------------------------------------------------------------
-- splashScene
-- Scene notes go here
---------------------------------------------------------------------------------
local ga = require( "scripts.googleAnalytics" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local language = getLanguage()
local widget = require("widget")
local api = require("scripts.api")
local json = require("json")
require("widgets.widget_newNavBar")

-- local forward references should go here --

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local display_group, 
      navBar,
      post_contents_button

local function onBackButton(event)
    if event.phase == "ended" then
        storyboard.gotoScene( "test.mainScene", "slideRight", 300 ) 
    end
    
    return true
end

local function bg_OnTap( event )
    if (display_group.y < 0) then
        transition.to(display_group, {y = 0, time=100, onComplete=nil})
    end
    native.setKeyboardFocus( nil )
    
    return true
end

local function commonCallback( event )
    if ( event.isError ) then
        native.setActivityIndicator( false )
        print( "Network error!")
        local alert = native.showAlert( language["appTitle"], language["common"]["wrong_connection"], { language["common"]["alert_ok_button"]} )
    else
        print(event.status)
        if(event.status == 200) then
            print(event.response)
            local data = json.decode(event.response)
                
            if (data) then
                print(data)
                if(data.status == "OK") then
                    local alert = native.showAlert( language["appTitle"], "OK", { language["common"]["alert_ok_button"]})
                    native.setActivityIndicator( false )
                else
                    native.setActivityIndicator( false )
                    local alert = native.showAlert( language["appTitle"], "NG", { language["common"]["alert_ok_button"]})
                    return true
                end
            end
        end
    end
end

local function postContentsButtonEvent( event )
    if event.phase == "ended" then
        post_contents_button:setEnabled(false)
        
        native.setActivityIndicator( true )
        -- 1. to Center
--        local params = {
--            center_id = "16",
--            member_id = "71",
--            to_kids_id = "",
--            contents = "太郎ちゃんが昨日から熱出して、今日は欠席します。\n宜しくお願いいたします。"
--        }
        -- 2. to Parent
        local params = {
            center_id = "16",
            member_id = "69",
            to_kids_id = "40",
            contents = "太郎ちゃん大丈夫ですか？\nゆっくり休んだ方がいいですよ。"
        }
        -- 3. to Parents(multi Parent)
        --[[local params = {
            center_id = "16",
            member_id = "69",
            to_kids_id = "45,47,40",
            contents = "子供立ちの具合がよくありません。\n早めに迎えにお越しください。"
        }]]--
        api.post_contact_contents(params, commonCallback)
        return true
    end
    
    return true
end

local function postContents2ButtonEvent( event )
    if event.phase == "ended" then
        post_contents_button:setEnabled(false)
        
        native.setActivityIndicator( true )
        -- 1. to Center
        local params = {
            center_id = "16",
            member_id = "71",
            kids_id = "40",
            to_kids_id = "",
            contents = "𠀋 𡈽 𡌛 𡑮 𡢽 𠮟 𡚴 𡸴 𣇄"
            -- contents = "foobar"
        }
        -- 2. to Parent
--        local params = {
--            center_id = "16",
--            member_id = "72",
--            kids_id = "",
--            to_kids_id = "119",
--            contents = "香りちゃん、お誕生日おめでとうございます。2"
--        }
        -- 3. to Parents(multi Parent)
        --[[local params = {
            center_id = "16",
            member_id = "69",
            kids_id = "",
            to_kids_id = "40,119",
            contents = "明日は休日にします。"
        }--]]
        api.post_contact_contents2(params, commonCallback)
        return true
    end
    
    return true
end

local function postReplyButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.post_contact_reply("4", "78", "分かりました。今すぐ迎えに行きます。", commonCallback)
    end
    
    return true
end

local function postReply2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.post_contact_reply2("363", "71", "119", "香りです。わかりました。", commonCallback)
    end
    
    return true
end

local function sendRead2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.send_conatct_read2("363", "71", "119", commonCallback)
    end
    
    return true
end

local function readNotListButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_memberlist_notread_contact("3", commonCallback)
    end
    
    return true
end

local function updateContentsButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local contents = "テストの連絡帳です2。修正できましたか？2"
        api.update_conatct_contents("6", contents, commonCallback)
    end
    
    return true
end

local function postImageButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            center_id = "16",
            contact_id = "4",
            filename = "a03622bd1defda517a7dd6ca1da2448c01e1a6b9.jpg",
            dir = system.DocumentsDirectory
        }
        api.post_contact_image(params, commonCallback)
    end
    
    return true
end

local function deleteImageButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        local params = {
            contact_id = "4",
            filename = "058afd10886db1cee55fb59ab96c9b1b706aaf6e.jpg"
        }
        api.delete_contact_image(params, commonCallback)
    end
    
    return true
end

local function deleteReplyButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.delete_contact_reply("4", "2", commonCallback)
    end
    
    return true
end

local function deleteContactButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.delete_contact("1", commonCallback)
    end
    
    return true
end

local function listButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_contact_list("16","201503","71","1","10", commonCallback)
    end
    
    return true
end

local function list2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_contact_list2("16","201503","69","","1","10", commonCallback)
    end
    
    return true
end

local function sendContactReadButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.send_conatct_read("26","70", commonCallback)
    end
    
    return true
end

local function replylistButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_contact_reply_list("4","1","10", commonCallback)
    end
    
    return true
end

local function replyList2ButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_contact_reply_list2("363","71","1","10", commonCallback)
    end
    
    return true
end

local function pushNotReadListButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.push_not_read_contact_member_list("26", commonCallback)
    end
    
    return true
end

local function kidslistButtonEvent( event )
    if event.phase == "ended" then
        native.setActivityIndicator( true )
        api.get_kids_list("16", "189", commonCallback)
    end
    
    return true
end

function scene:createScene( event )
    local group = self.view
    display_group = group
    
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

    navBar = widget.newNavigationBar({
        title = "Contact Test Main",
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontSize = __navBarTitleFontSize__,
        leftButton = btn_left_opt
    })    
    group:insert(navBar)

    group:addEventListener( "tap", bg_OnTap )
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

    post_contents_button = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10, 
        top = navBar.height + 10, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "POST CONTENTS",
        onRelease = postContentsButtonEvent
    }
    group:insert(post_contents_button)
    
    local delete_reply = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = post_contents_button.x + 80,
        top = navBar.height + 10, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete reply",
        onRelease = deleteReplyButtonEvent
    }
    group:insert(delete_reply)

    local post_reply_button = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10, 
        top = post_contents_button.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        labelYOffset = -2,
        fontSize = __buttonFontSize__,
        label = "POST Reply",
        onRelease = postReplyButtonEvent
    }
    group:insert(post_reply_button)

    local readnotlist = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = post_reply_button.x + 80,
        top = post_contents_button.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "read not list",
        onRelease = readNotListButtonEvent
    }
    group:insert(readnotlist)
    
    local update_contents = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = readnotlist.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "update Contents",
        onRelease = updateContentsButtonEvent
    }
    group:insert(update_contents)
    
    local post_image = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = update_contents.x + 80,
        top = readnotlist.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "post_image",
        onRelease = postImageButtonEvent
    }
    group:insert(post_image)
    
    local delete_image = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = update_contents.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete image",
        onRelease = deleteImageButtonEvent
    }
    group:insert(delete_image)
    
    local delete_contact = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = delete_image.x + 80,
        top = post_image.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "delete contact",
        onRelease = deleteContactButtonEvent
    }
    group:insert(delete_contact)
    
    local list = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = delete_image.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "list",
        onRelease = listButtonEvent
    }
    group:insert(list)
    
    local send_contact_read = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = list.x + 80,
        top = delete_contact.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "send conatct read",
        onRelease = sendContactReadButtonEvent
    }
    group:insert(send_contact_read)
    
    local replylist = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = list.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "reply list",
        onRelease = replylistButtonEvent
    }
    group:insert(replylist)
    
    local pushnotreadlist = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = replylist.x + 80,
        top = send_contact_read.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "push not read list",
        onRelease = pushNotReadListButtonEvent
    }
    group:insert(pushnotreadlist)
    
    local kidslist = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10,
        top = replylist.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "kids list",
        onRelease = kidslistButtonEvent
    }
    group:insert(kidslist)
    
    local list2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = replylist.x + 80,
        top = pushnotreadlist.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "list2",
        onRelease = list2ButtonEvent
    }
    group:insert(list2)
    
    local post_contents_button2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10, 
        top = kidslist.y + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "POST CONTENTS2",
        onRelease = postContents2ButtonEvent
    }
    group:insert(post_contents_button2)
    
    local replyList2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = post_contents_button2.x + 80,
        top = list2.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "reply List2",
        onRelease = replyList2ButtonEvent
    }
    group:insert(replyList2)
    
    local post_reply_button2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = 10, 
        top = post_contents_button2.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        labelYOffset = -2,
        fontSize = __buttonFontSize__,
        label = "POST Reply2",
        onRelease = postReply2ButtonEvent
    }
    group:insert(post_reply_button2)
    
    local sendRead2 = widget.newButton
    {
        width = 130 ,
        height = 40 ,
        left = post_reply_button2.x + 80,
        top = replyList2.y  + 20, 
        defaultFile = "images/button_inframe/btn_inframe_blue_3_normal.png",
        overFile = "images/button_inframe/btn_inframe_blue_3_touched.png",
        labelColor = { default={ 1 }, over={ 1 } },
        emboss = true,
        fontSize = __buttonFontSize__,
        label = "sendRead2",
        onRelease = sendRead2ButtonEvent
    }
    group:insert(sendRead2)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    
end

-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
    
--    display:remove(group)
    
end

-- Called prior to the removal of scene's "view" (display view)
function scene:destroyScene( event )
    local group = self.view
    
    group:removeSelf()
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
    
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
    
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

