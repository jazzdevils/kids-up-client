local M = {}
local widget = require( "widget" )

function widget.newNavigationBar( options )
    local customOptions = options or {}
    local opt = {}
    opt.left = customOptions.left or nil
    opt.top = customOptions.top or nil
    opt.width = customOptions.width or display.contentWidth
    opt.height = customOptions.height or 50
    if customOptions.includeStatusBar == nil then
        opt.includeStatusBar = true -- assume status bars for business apps
    else
        opt.includeStatusBar = customOptions.includeStatusBar
    end

    local statusBarPad = 0
    if opt.includeStatusBar then
        statusBarPad = display.topStatusBarContentHeight
    end

    opt.x = customOptions.x or display.contentCenterX
    opt.y = customOptions.y or (opt.height + statusBarPad) * 0.5
    opt.id = customOptions.id
    opt.isTransluscent = customOptions.isTransluscent or true
    opt.background = customOptions.background
    opt.backgroundColor = customOptions.backgroundColor
    opt.title = customOptions.title or ""
    opt.titleColor = customOptions.titleColor or { 0, 0, 0 }
    opt.font = customOptions.font or native.systemFontBold
    opt.fontSize = customOptions.fontSize or 18
    opt.leftButton = customOptions.leftButton or nil
    opt.rightButton = customOptions.rightButton or nil
    opt.rightSideButton = customOptions.rightSideButton or nil

    if opt.left then
    	opt.x = opt.left + opt.width * 0.5
    end
    if opt.top then
    	opt.y = opt.top + (opt.height + statusBarPad) * 0.5
    end

    local barContainer = display.newGroup()
--    local background = display.newRect(barContainer, opt.x, opt.y, opt.width, opt.height + statusBarPad )
    local background = display.newImageRect(barContainer, opt.background, opt.width, opt.height + statusBarPad)
    background.x = opt.x
    background.y = opt.y
--    local background = display.newImage(opt.background, opt.x, opt.y)    
--    barContainer:insert(background)
--    local background = display.newImage(barContainer, opt.background, opt.x, opt.y, opt.width, opt.height + statusBarPad)
--    if opt.background then
--        background.fill = { type = "image", filename=opt.background}
--    elseif opt.backgroundColor then
--        background.fill = opt.backgroundColor
--    else
--        if widget.isSeven() then
--            background.fill = {1,1,1} 
--        else
--            background.fill = { type = "gradient", color1={0.5, 0.5, 0.5}, color2={0, 0, 0}}
--        end
--    end
    
    local title = display.newText(opt.title, background.x, background.y + statusBarPad * 0.5, opt.font, opt.fontSize)
    title:setFillColor(unpack(opt.titleColor))
    barContainer:insert(title)

    local leftButton
    if opt.leftButton then
        if opt.leftButton.defaultFile then -- construct an image button
            leftButton = widget.newButton({
                id = opt.leftButton.id,
                width = opt.leftButton.width,
                height = opt.leftButton.height,
                onRelease = opt.leftButton.onRelease,
                onEvent = opt.leftButton.onEvent,
                baseDir = opt.leftButton.baseDir,
                defaultFile = opt.leftButton.defaultFile,
                overFile = opt.leftButton.overFile,
                label= opt.leftButton.label,
                labelAlign = "center",
                font = opt.leftButton.font or opt.font,
                fontSize = opt.leftButton.fontSize or opt.fontSize,
                labelColor = opt.leftButton.labelColor or { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            })
        else -- construct a text button
            leftButton = widget.newButton({
                id = opt.leftButton.id,
                label = opt.leftButton.label,
                onRelease = opt.leftButton.onRelease,
                onEvent = opt.leftButton.onEvent,
                font = opt.leftButton.font or opt.font,
                fontSize = opt.fontSize,
                labelColor = opt.leftButton.labelColor or { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                labelAlign = "center",
            })
        end
--        leftButton.x = 15 + leftButton.width * 0.5
        leftButton.x = leftButton.width * 0.5    
        leftButton.y = title.y
        barContainer:insert(leftButton)
    end

    local rightButton
    if opt.rightButton then
        if opt.rightButton.defaultFile then -- construct an image button
            rightButton = widget.newButton({
                id = opt.rightButton.id,
                width = opt.rightButton.width,
                height = opt.rightButton.height,
                onRelease = opt.rightButton.onRelease,
                onEvent = opt.rightButton.onEvent,
                baseDir = opt.rightButton.baseDir,
                defaultFile = opt.rightButton.defaultFile,
                overFile = opt.rightButton.overFile,
                label= opt.rightButton.label,
                labelAlign = "center",
                font = opt.rightButton.font or opt.font,
                fontSize = opt.rightButton.fontSize or opt.fontSize,
                labelColor = opt.rightButton.labelColor or { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            })
        else -- construct a text button
            rightButton = widget.newButton({
                id = opt.rightButton.id,
                label = opt.rightButton.label or "Default",
                onRelease = opt.rightButton.onRelease,
                onEvent = opt.rightButton.onEvent,
                font = opt.leftButton.font or opt.font,
                fontSize = opt.fontSize,
                labelColor = opt.rightButton.labelColor or { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                labelAlign = "center",
            })
        end
--        rightButton.x = display.contentWidth - (15 + rightButton.width * 0.5)
        rightButton.x = display.contentWidth - (rightButton.width * 0.5)
        rightButton.y = title.y
        barContainer:insert(rightButton)
    end
    
    local rightSideButton
    if opt.rightSideButton then
        if opt.rightSideButton.defaultFile then -- construct an image button
            rightSideButton = widget.newButton({
                id = opt.rightSideButton.id,
                width = opt.rightSideButton.width,
                height = opt.rightSideButton.height,
                onRelease = opt.rightSideButton.onRelease,
                onEvent = opt.rightSideButton.onEvent,
                baseDir = opt.rightSideButton.baseDir,
                defaultFile = opt.rightSideButton.defaultFile,
                overFile = opt.rightSideButton.overFile,
                label= opt.rightSideButton.label,
                labelAlign = "center",
                font = opt.rightSideButton.font or opt.font,
                fontSize = opt.rightSideButton.fontSize or opt.fontSize,
                labelColor = opt.rightSideButton.labelColor or { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            })
        else -- construct a text button
            rightSideButton = widget.newButton({
                id = opt.rightSideButton.id,
                label = opt.rightSideButton.label or "Default",
                onRelease = opt.rightSideButton.onRelease,
                onEvent = opt.rightSideButton.onEvent,
                font = opt.rightSideButton.font or opt.font,
                fontSize = opt.fontSize,
                labelColor = opt.rightSideButton.labelColor or { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                labelAlign = "center",
            })
        end
--        rightButton.x = display.contentWidth - (15 + rightButton.width * 0.5)
        if(rightButton) then
            rightSideButton.x = display.contentWidth - rightSideButton.width - (rightButton.width /2) - 15
            rightButton.x = display.contentWidth - (rightButton.width * 0.5) - 10
        else
            rightSideButton.x = display.contentWidth - (rightSideButton.width * 0.5)
        end
        
        rightSideButton.y = title.y
        barContainer:insert(rightSideButton)
    end

    return barContainer
end
return M