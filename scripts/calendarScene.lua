---------------------------------------------------------------------------------
-- SCENE NAME
-- Scene notes go here
---------------------------------------------------------------------------------

require("scripts.commonSettings")
require("widgets.widget_newNavBar")
require("widgets.activityIndicator")

local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local user = require("scripts.user_data")
local json = require("json")
local api = require("scripts.api")
local language = getLanguage()
local utils = require("scripts.commonUtils")
local func = require("scripts.commonFunc")

local NAVI_BAR_HEIGHT = 50
local NAME_BAR_HEIGHT = 30

local previous_scene 
local calendar_group

local jump_to_prev_month
local jump_to_next_month
local activityIndicator

-- Clear previous scene

-- local forward references should go here --

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function onLeftButton(event)
    if event.phase == "ended" then
--        storyboard.hideOverlay("slideRight", 300)
        if (previous_scene == "scripts.newsScene") then
            storyboard.purgeScene(previous_scene)
            storyboard.gotoScene(previous_scene, "slideRight", 300)
        else
            storyboard.gotoScene(__DEFAULT_HOMESCENE_NAME__, "slideRight", 300)
        end    
    end
    
    return true
end

local function onRightButton(event)
    if event.phase == "ended" then
        storyboard.purgeScene("scripts.calendarWriteScene")
        storyboard.gotoScene("scripts.calendarWriteScene", "slideLeft", 300)
    end    
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    previous_scene = storyboard.getPrevious()
    
    if(previous_scene == "scripts.newsScene" and event.params) then
        api.get_news_detail3(event.params.member_id, event.params.device_id, event.params.seq, user.getActiveKid_IDByAuthority(),
            utils.IS_Demo_mode(storyboard, false),
            function(e)  end
        )
    end
    
    local tabButton_width = __appContentWidth__/5 - 2--math.floor(display.actualContentWidth/5) - 2
    local tabButton_height = tabButton_width * 0.7--math.floor(tabButton_width * 0.7)
    
    local bg = display.newImageRect(group, "images/bg_set/bg_sub.png", __backgroundWidth__, __backgroundHeight__)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    group:insert(bg)
    
    local btn_left_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["calendarScene"]["back"],
        onEvent = onLeftButton,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        width = 100,
        height = 50,
        defaultFile = "images/top_with_texts/btn_top_text_home_normal.png",
        overFile = "images/top_with_texts/btn_top_text_home_touched.png",    
    }
    
    local btn_right_opt = {
        labelColor = { default = __NAVBAR_BUTTON_COLOR__, over = __NAVBAR_BUTTON_COLOR__ },
        label = language["calendarScene"]["write"],
        onEvent = onRightButton,
        width = 100,
        height = 50,
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        defaultFile = "images/top_with_texts/btn_top_text_input_normal.png",
        overFile = "images/top_with_texts/btn_top_text_input_touched.png",
    }
    local navBar = widget.newNavigationBar({
        title = language["calendarScene"]["title"],
        width = __appContentWidth__,
        background = "images/top/bg_top.png",
        titleColor = __NAVBAR_TXT_COLOR__,
        font = native.systemFontBold,
        fontsize = __navBarTitleFontSize__,
        leftButton = btn_left_opt,
        rightButton = btn_right_opt,
--        includeStatusBar = false
    })
    group:insert(navBar)
    
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
        font = native.systemFont,
        fontSize = __buttonFontSize__,
        align = "center"
    }
    
    local labelTag = display.newText(tag_Opt)
    labelTag:setFillColor( 1 )
    group:insert(labelTag)
    
    calendar_group = display.newGroup()
    
    local date = os.date( "*t" )
    local curMonth = date.month
    local curYear = date.year
    
    --Returns name of month[i]
--    local get_month_name =
--    {
----        "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
--        "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"
--    }
    local get_month_name = language["calendar"]["month"]
    
    --Returns short name of month[i]
    local get_short_month_name = language["calendar"]["month"]
--    {
----        "jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"
----        "(1月)", "(2月)", "(3月)", "(4月)", "(5月)", "(6月)", "(7月)", "(8月)", "(9月)", "(10月)", "(11月)", "(12月)"
--        
--    }
    
    --Returns days in a month, including for leap year
    local function get_days_in_month(month, year)
        local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
        local d = days_in_month[month]
        
        --Check for leap year
        if (month == 2) then
            if year%4==0 and (year%100~=0 or year%400==0) then
                d = 29
            end
        end
        
        return d
    end
    
    --Returns day of week
    local get_day_of_week = language["calendar"]["week"]
--    {
----        "sun", "mon", "tue", "wed", "thu", "fri", "sat"
----        "日","月", "火", "水", "木", "金", "土"
--    }
    
    --Get the first day of the month
    local function get_start_day( cur_month, cur_year )
        local temp = os.time{year = cur_year, month=cur_month, day=1}
        
        return tonumber(os.date("%w", temp))
    end
    
    --Get the last day of the month
    local function get_end_day( cur_month, cur_year )
        return tonumber(get_days_in_month(cur_month, curYear))
    end
    
    local function onTapDayBox(event)
        local obj = event.target --dayBox
        local options = {
            effect = "slideLeft",
            time = 300,
--            params = { date = string.format("%04d",obj.year)..string.format("%02d",obj.month)..string.format("%02d",obj.day)}
            params = { year = obj.year,
                       month =  obj.month,
                       day = obj.day
                    }
        }
        if(obj.event_cnt and obj.event_cnt > 0) then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.calendarViewScene")
            storyboard.gotoScene("scripts.calendarViewScene", options)
        elseif(obj.attendance and obj.attendance > 0) then
            storyboard.isAction = true
            storyboard.purgeScene("scripts.calendarViewScene")
            storyboard.gotoScene("scripts.calendarViewScene", options)
        end
        
        print("year : "..obj.year)
        print("month : "..obj.month)
        print("day : "..obj.day)
        
        return true
    end
    
    -- Creates the calendar
    local function create_calender( year, month, userScheduleData)
        --Create previous month
        local prevMonth = month - 1
        local prevYear = year
        if prevMonth < 1 then
            prevMonth = 12
            prevYear = prevYear - 1
        end
        local prevDays = false
        local prevStartDay
        local prevEndDay
        
        --Create selected month
        local selMonth = month
        local selYear = year
        local selDays = false
        local selStartDay = get_start_day( month, year ) + 1 --Adds 1 because table index starts at 1.
        local selEndDay = get_end_day( month, year )
        
        --Create next month
        local nextMonth = month + 1
        local nextYear = year
        if nextMonth > 12 then
            nextMonth = 1
            nextYear = nextYear + 1
        end
        local nextDays = false
        local nextStartDay = 1
        local nextEndDay
        
        --Check if there is a previous month on the screen
        local daysToSelMonth = 1 - selStartDay
        if daysToSelMonth < 0 then
            prevDays = true
        end
        
        if prevDays then
            daysToSelMonth = daysToSelMonth + 1
            prevEndDay = get_days_in_month( prevMonth, year )
            prevStartDay = prevEndDay + daysToSelMonth
        end
        
        local calBox = display.newRect(calendar_group, display.contentCenterX , 32, __appContentWidth__, 47 )
        calBox.x = display.contentCenterX
        calBox.anchorY = 0
        calBox.y = __statusBarHeight__ + NAVI_BAR_HEIGHT + NAME_BAR_HEIGHT 
        calBox:setFillColor( unpack(__SELECT_CLASS_RECT_COLOR__))
        calendar_group:insert( calBox )
        
        local yearMonthName = display.newText(utils.convert2LocaleDateStringYYYYMM(year, selMonth), 0, 0, 0, 0, native.systemFont, 20 )
        yearMonthName:setFillColor(unpack(__Read_NoticeList_FontColor__))
        yearMonthName.anchorY = 0
        yearMonthName.x = display.contentCenterX
        yearMonthName.y = calBox.y + 4
        calendar_group:insert( yearMonthName )
--      
        local leftArrowButton = display.newImageRect("images/assets1/icon_calendar_prev.png", 24 , 24)
        leftArrowButton.anchorX = 0
        leftArrowButton.anchorY = 0
        leftArrowButton.x = 10
        leftArrowButton.y = calBox.y + 4
        calendar_group:insert(leftArrowButton)
        leftArrowButton:addEventListener("tap", function() jump_to_prev_month() end)
        
        local rightArrowButton = display.newImageRect("images/assets1/icon_calendar_next.png", 24 , 24)
        rightArrowButton.anchorX = 0
        rightArrowButton.anchorY = 0
        rightArrowButton.x = calBox.width - rightArrowButton.width - 10
        rightArrowButton.y = calBox.y + 4
        calendar_group:insert(rightArrowButton)
        rightArrowButton:addEventListener("tap", function() jump_to_next_month() end)

        --Create calender days
        local calDay
        local calMonth
        local calYear
        local calEnd
        local calFirst = false
        local calWhatMonth
        local calRows = 5
        if 36 - selEndDay- selStartDay < 0 then --If the selected month starts on a fri/sat then expand the rows.
            calRows = 6
        end
        
        --Check if there is a previous month for the selected month
        if prevDays then
            calDay = prevStartDay
            calMonth = prevMonth
            calYear = prevYear
            calEnd = prevEndDay
            if calDay ~= 1 then
                calFirst = true
            else
                calFirst = false
            end
            calWhatMonth = 1
        else
            calDay = selStartDay
            calMonth = selMonth
            calYear = selYear
            calEnd = selEndDay
            if calDay ~= 1 then
                calFirst = true
            else
                calFirst = false
            end    
            calWhatMonth = 2
        end
        
        local x = 2
        local y = calBox.y + calBox.height + 4
        
        local calendarHeight = __appContentHeight__ - (calBox.y + calBox.height + 4 + tabButton_height + 24)
        local dayBoxHeight
            
        --Create a 5-6*7 grid.
        for j = 1, calRows do --5-6 rows
            for i = 1, 7 do --7 columns
                --Creates a box for each day.
                local dayBox
                --Change height depending on amount of rows.
                if calRows == 5 then
                    dayBoxHeight = calendarHeight / 5
                    
                    if calWhatMonth ~= 2 then --Fills the days which aren't the selected month with a different color
                        dayBox = display.newImageRect("images/assets1/bg_calendar_closed.png", __appContentWidth__/7 - 4, dayBoxHeight)
--                        dayBox:setFillColor( 0.8, 0.8, 0.8 )
                    elseif i == 1 then -- 일요일
                        dayBox = display.newImageRect("images/assets1/bg_calendar_sunday.png", __appContentWidth__/7 - 4, dayBoxHeight)
                    elseif i == 7 then -- 토요일
                        dayBox = display.newImageRect("images/assets1/bg_calendar_saturday.png", __appContentWidth__/7 - 4, dayBoxHeight)
                    else
                        dayBox = display.newImageRect("images/assets1/bg_calendar_normal.png", __appContentWidth__/7 - 4, dayBoxHeight)
                    end
                    
                    if calDay == date.day and calMonth == date.month and calYear == date.year then
                        if(dayBox) then
                            display.remove(dayBox)
                        end
                        dayBox = display.newImageRect("images/assets1/bg_calendar_normal_today_new.png", __appContentWidth__/7 - 4, dayBoxHeight)
                    end
                    
                    dayBox.anchorX = 0
                    dayBox.anchorY = 0
                else
                    dayBoxHeight = calendarHeight / 6
                    if calWhatMonth ~= 2 then --Fills the days which aren't the selected month with a different color
                        dayBox = display.newImageRect("images/assets1/bg_calendar_closed.png", __appContentWidth__/7 - 4, dayBoxHeight)
--                        dayBox:setFillColor( 0.8, 0.8, 0.8 )
                    elseif i == 1 then -- 일요일
                        dayBox = display.newImageRect("images/assets1/bg_calendar_sunday.png", __appContentWidth__/7 - 4, dayBoxHeight)
                    elseif i == 7 then -- 토요일
                        dayBox = display.newImageRect("images/assets1/bg_calendar_saturday.png", __appContentWidth__/7 - 4, dayBoxHeight)
                    else
                        dayBox = display.newImageRect("images/assets1/bg_calendar_normal.png", __appContentWidth__/7 - 4, dayBoxHeight)
                    end
                    
                    if calDay == date.day and calMonth == date.month and calYear == date.year then
                        if(dayBox) then
                            display.remove(dayBox)
                        end
                        dayBox = display.newImageRect("images/assets1/bg_calendar_normal_today_new.png", __appContentWidth__/7 - 4, dayBoxHeight)
                    end
                    dayBox.anchorX = 0
                    dayBox.anchorY = 0
                end
                dayBox.x = x
                dayBox.y = y
                           
                calendar_group:insert( dayBox )
                
                local calDayText
                --If it's the first day of the month, show the name of the month.
                if calFirst then
                    calDayText = calDay-- .. " " .. get_short_month_name[calMonth]
                    calFirst = false
                else
                    calDayText = calDay
                end
                
                --A text representing each day nr.
                local dayText
                
                dayText = display.newText( calDayText, 0, 0, 0, 0, native.systemFont, 10 )
                dayText:setFillColor( 0, 0, 0 )
                
                dayBox.year = calYear
                dayBox.month = calMonth
                dayBox.day = calDay
                
--                local titleText = display.newText( "이것은 타이틀...", 0, 0, 0, 0, native.systemFont, 10 )
--                titleText.anchorX = 0
--                titleText.anchorY = 0
--                titleText.x = x + 2
--                titleText.y = y + 4
                
--                calendar_group:insert( titleText)
                dayText.anchorX = 0
                dayText.anchorY = 0
                
                dayText.x = x + 2
                dayText.y = y + 2
                calendar_group:insert( dayText )
                
                if(userScheduleData and userScheduleData.schedule_cnt > 0) then
                    local schedule_cnt = userScheduleData.schedule_cnt
                    for k = 1, schedule_cnt do
                        local schedule = userScheduleData.schedule[k]
                        local sYear = string.sub(schedule.date, 1, 4)
                        local sMonth = string.sub(schedule.date, 5, 6)
                        local sDay = string.sub(schedule.date, 7, 8)
                        
                        local strYear = string.format("%04d",calYear)
                        local strMonth = string.format("%02d",calMonth)
                        local strDay = string.format("%02d",calDay)
                        if(sYear == strYear and sMonth == strMonth and sDay == strDay) then
                            dayBox.event_cnt = tonumber(schedule.event_cnt)
                            dayBox.attendance = tonumber(schedule.attendance)
                            
                            local eventImg
                            if (dayBox.event_cnt > 0) then
                                eventImg = display.newImageRect("images/assets1/icon_news.png", 15 , 15)
                                eventImg.anchorX = 0
                                eventImg.anchorY = 0
                                eventImg.x = dayBox.x + (dayBox.width - eventImg.width)/2
                                eventImg.y = dayBox.y + (dayBox.height - eventImg.height)/2
                                calendar_group:insert(eventImg)
                            end
                            
                            local attendanceImg
                            if (dayBox.attendance > 0) then
                                attendanceImg = display.newImageRect("images/assets1/icon_attend.png", 15 , 15)
                                attendanceImg.anchorX = 0
                                attendanceImg.anchorY = 0
                                
                                if(eventImg) then
                                    eventImg.x = eventImg.x - 10
                                    attendanceImg.x = dayBox.x + (dayBox.width - attendanceImg.width)/2 + 10
                                    attendanceImg.y = dayBox.y + (dayBox.height - attendanceImg.height)/2
                                else
                                    attendanceImg.x = dayBox.x + (dayBox.width - attendanceImg.width)/2
                                    attendanceImg.y = dayBox.y + (dayBox.height - attendanceImg.height)/2
                                end
                                
                                calendar_group:insert(attendanceImg)
                            end    
                                
                            dayBox:addEventListener("tap", onTapDayBox)
                        end
                    end
                end
                
                --If it's the end of the month, stop showing day numbers.
                if calDay == calEnd then
                    if calWhatMonth == 1 then
                        calDay = 1
                        calMonth = selMonth
                        calYear = selYear
                        calEnd = selEndDay
                        calFirst = true
                        calWhatMonth = 2
                    elseif calWhatMonth == 2 then
                        calDay = 1
                        calMonth = nextMonth
                        calYear = nextYear
                        calEnd = nextEndDay
                        calFirst = true
                        calWhatMonth = 3
                    end
                else
                    calDay = calDay + 1
                end
                
                --Print out the day names on the calBox.
                if j == 1 then
                    local dayText = display.newText( get_day_of_week[i], 0, 0, 44, 0, native.systemFont, 14 )
                    dayText.anchorX = 0
                    dayText.anchorY = 0
                    dayText:setFillColor(unpack(__Read_NoticeList_FontColor__))
                    dayText.x = dayBox.x + dayBox.contentWidth * 0.5 - dayText.contentWidth * 0.25
                    dayText.y = dayBox.y - dayText.height - 2 
                    calendar_group:insert( dayText )
                end
                
                x = x + display.contentWidth/7
            end
            
            if calRows == 5 then
                y = y + dayBoxHeight + 4--66
            else
                y = y + dayBoxHeight + 3 --55
            end
            x = 2
        end
    end
    
    --Remove objects
    local function remove_objects()
        for i=calendar_group.numChildren,1,-1 do
            local child = calendar_group[i]
            child.parent:remove( child )
            child:removeEventListener("tap", onTapDayBox)
            child = nil
        end
    end
    
    local function getDataCallback(event)
        if(activityIndicator) then
            activityIndicator:destroy()
        end

        if ( event.isError ) then
            print( "Network error!")
            utils.showMessage(language["common"]["wrong_connection"])
        else
            print(event.status)
            if(event.status == 200) then
                print ( "RESPONSE: " .. event.response )
                local data = json.decode(event.response)

                if (data) then
                    if(data.status == "OK") then
                        create_calender( curYear, curMonth, data)
                    else
                        utils.showMessage(language["common"]["wrong_connection"])
                        create_calender( curYear, curMonth, nil)
                    end
                end
            end
        end
        return true
    end
    
    local function getMakeSchedule(aYear, aMonth)
        local strYear = string.format("%04d",aYear)
        local strMonth = string.format("%02d",aMonth)
        
        activityIndicator = ActivityIndicator:new(language["activityIndicator"]["getdata"])
        api.get_schedule_list2(user.userData.centerid, user.userData.id, user.getActiveKid_IDByAuthority(), strYear..strMonth, getDataCallback)
    end
    
    --Go to the previous month.
    function jump_to_prev_month()
        --Remove all objects
        remove_objects()
        
        --Set the cal month back to the previous month.
        curMonth = curMonth - 1
        
        --If the month is before January, go back to previous year.
        if curMonth < 1 then
            curMonth = 12
            curYear = curYear - 1
        end
        
        --Create background, buttons and calender.
--        create_bg()
--        create_buttons()
        getMakeSchedule(curYear, curMonth)
    end
    
    --Go to the next month.
    function jump_to_next_month()
        --Remove all objects
        remove_objects()
        
        --Set the cal month back to the next month.
        curMonth = curMonth + 1
        --If the month is after December, go to the next year.
        if curMonth > 12 then
            curMonth = 1
            curYear = curYear + 1
        end
              
        getMakeSchedule(curYear, curMonth)      
    end
    
    local function onSlide_Calendar(event)
        local obj = event.target
        if event.phase == "began" then
            obj.startX = event.x
            display.getCurrentStage():setFocus( obj )
            obj.isFocus = true
        elseif obj.isFocus then
            if event.phase == "moved" then
                obj.changeSinceLast = event.x - obj.startX
            elseif event.phase == "ended" or event.phase == "cancelled" then
                if (obj.changeSinceLast) then
                    if obj.changeSinceLast < -120 then
                        jump_to_next_month()
                        print("right -> left")
                    elseif obj.changeSinceLast > 120 then
                        jump_to_prev_month()
                        print("left -> right")
                    end
                    obj.changeSinceLast = nil
                end
                
                display.getCurrentStage():setFocus( nil )
                obj.isFocus = false
            end
        end

        return true
    end
    calendar_group:addEventListener("touch", onSlide_Calendar)
    group:insert(calendar_group)
    
    --Create main
    getMakeSchedule(curYear, curMonth)      
    
    local tabButtonImages = func.getTabButtonImage()
    local tabButtons = {
        {
            label = language["tab_button"]["tab_button_1"],
            defaultFile = "images/bottom/btn_bottom_home_normal.png",
            overFile = "images/bottom/btn_bottom_home_selected.png",
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
--            size = 16,
            width = tabButton_width,
            height = tabButton_height,
            onPress = function() storyboard.gotoScene(__DEFAULT_HOMESCENE_NAME__, "crossFade", 300) end,
        },
        {
            label = language["tab_button"]["tab_button_2"],
            defaultFile = tabButtonImages.message.defaultFile,
            overFile = tabButtonImages.message.overFile,
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
            width = tabButton_width,
            height = tabButton_height,
            onPress =   function() 
                            storyboard.isAction = true
                            storyboard.purgeScene("scripts.messageScene")
                            storyboard.gotoScene("scripts.messageScene", "crossFade", 300) 
                        end,
        },
        {
            label = language["tab_button"]["tab_button_3"],
            defaultFile = tabButtonImages.notice.defaultFile,
            overFile = tabButtonImages.notice.overFile,
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
            width = tabButton_width,
            height = tabButton_height,
            onPress =   function() 
                            storyboard.isAction = true
                            storyboard.purgeScene("scripts.noticeScene")
                            storyboard.gotoScene("scripts.noticeScene", "crossFade", 300) 
                        end,
        },
        {
            label = language["tab_button"]["tab_button_4"],
            defaultFile = tabButtonImages.event.defaultFile,
            overFile = tabButtonImages.event.overFile,
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
            width = tabButton_width,
            height = tabButton_height,
            onPress =   function() 
                            storyboard.isAction = true
                            storyboard.purgeScene("scripts.eventScene")
                            storyboard.gotoScene("scripts.eventScene", "crossFade", 300) 
                        end,
        },
        {
            label = language["tab_button"]["tab_button_5"],
            defaultFile = "images/bottom/btn_bottom_schedule_normal.png",
            overFile = "images/bottom/btn_bottom_schedule_selected.png",
            labelColor = { 
                default = { 0.25, 0.25, 0.25 }, 
                over = { 1, 1, 1 }
            },
            width = tabButton_width,
            height = tabButton_height,
            onPress = nil,
            selected = true,
        },
    }
    
    local tabBarBackgroundFile = "images/bottom/tabBarBg7.png"
    local tabBarLeft = "images/bottom/tabBar_tabSelectedLeft7.png"
    local tabBarMiddle = "images/bottom/tabBar_tabSelectedMiddle7.png"
    local tabBarRight = "images/bottom/tabBar_tabSelectedRight7.png"
    
    local tabBar = widget.newTabBar{
        top =  display.contentHeight - tabButton_height,
        left = 0,
        width = __appContentWidth__,
        backgroundFile = tabBarBackgroundFile,
        tabSelectedLeftFile = tabBarLeft, 
        tabSelectedRightFile = tabBarRight,
        tabSelectedMiddleFile = tabBarMiddle,
        tabSelectedFrameWidth = 0,           
        tabSelectedFrameHeight = 0,--tabButton_height, 
        buttons = tabButtons,
        height = tabButton_height,
    }
    tabBar.x = display.contentWidth / 2
    group:insert(tabBar)
    
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    storyboard.isAction = false
--    storyboard.returnTo = __DEFAULT_HOMESCENE_NAME__
    storyboard.returnTo = previous_scene
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

