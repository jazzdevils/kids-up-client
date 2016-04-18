local M = {}
local widget = require( "widget" )

function widget.newNavigationBar4WebView( options )
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
    opt.rightButton = customOptions.rightButton or nil
    opt.rightSideButton = customOptions.rightSideButton or nil
    opt.backwardButton = customOptions.backwardButton or nil
    opt.forwardButton = customOptions.forwardButton or nil

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
    
    local title
    function barContainer.setTitle(_title)
        if title then
            title:removeSelf()
            title = nil
        end
        title = display.newText(_title, background.x, background.y + statusBarPad * 0.5, opt.font, opt.fontSize)
        title:setFillColor(unpack(opt.titleColor))
        barContainer:insert(title)    
    end
    
    title = display.newText(opt.title, background.x, background.y + statusBarPad * 0.5, opt.font, opt.fontSize)
    title:setFillColor(unpack(opt.titleColor))
    barContainer:insert(title)

    local backwardButton
    if opt.backwardButton then
        if opt.backwardButton.defaultFile then -- construct an image button
            backwardButton = widget.newButton({
                id = opt.backwardButton.id,
                width = opt.backwardButton.width,
                height = opt.backwardButton.height,
                onRelease = opt.backwardButton.onRelease,
                onEvent = opt.backwardButton.onEvent,
                baseDir = opt.backwardButton.baseDir,
                defaultFile = opt.backwardButton.defaultFile,
                overFile = opt.backwardButton.overFile,
                label= opt.backwardButton.label,
                labelAlign = "center",
                font = opt.backwardButton.font or opt.font,
                fontSize = opt.backwardButton.fontSize or opt.fontSize,
                labelColor = opt.backwardButton.labelColor or { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            })
        else -- construct a text button
            backwardButton = widget.newButton({
                id = opt.backwardButton.id,
                label = opt.backwardButton.label,
                onRelease = opt.backwardButton.onRelease,
                onEvent = opt.backwardButton.onEvent,
                font = opt.backwardButton.font or opt.font,
                fontSize = opt.fontSize,
                labelColor = opt.backwardButton.labelColor or { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                labelAlign = "center",
            })
        end
--        leftButton.x = 15 + leftButton.width * 0.5
        backwardButton.x = backwardButton.width * 0.5    
        backwardButton.y = title.y
        barContainer:insert(backwardButton)
    end
    
    local forwardButton
    if opt.forwardButton then
        if opt.forwardButton.defaultFile then -- construct an image button
            forwardButton = widget.newButton({
                id = opt.forwardButton.id,
                width = opt.forwardButton.width,
                height = opt.forwardButton.height,
                onRelease = opt.forwardButton.onRelease,
                onEvent = opt.forwardButton.onEvent,
                baseDir = opt.forwardButton.baseDir,
                defaultFile = opt.forwardButton.defaultFile,
                overFile = opt.forwardButton.overFile,
                label= opt.forwardButton.label,
                labelAlign = "center",
                font = opt.forwardButton.font or opt.font,
                fontSize = opt.forwardButton.fontSize or opt.fontSize,
                labelColor = opt.forwardButton.labelColor or { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
            })
        else -- construct a text button
            forwardButton = widget.newButton({
                id = opt.forwardButton.id,
                label = opt.forwardButton.label,
                onRelease = opt.forwardButton.onRelease,
                onEvent = opt.forwardButton.onEvent,
                font = opt.forwardButton.font or opt.font,
                fontSize = opt.fontSize,
                labelColor = opt.forwardButton.labelColor or { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
                labelAlign = "center",
            })
        end
--        leftButton.x = 15 + leftButton.width * 0.5
        forwardButton.x = backwardButton.x + backwardButton.width 
        forwardButton.y = title.y
        barContainer:insert(forwardButton)
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

