--
-- Include the existing widget library.  When this is done, widget.newTextField will 
-- temporarily be added to the in-memory widget library.
--
local widget = require( "widget" )
-- 
-- Forward declare the on screen textField Object
--
local textField

--
-- Set up a function to handle the editing events and dismiss the keyboard when done.
--
local function textFieldHandler( event )
    --
    -- event.text only exists during the editing phase to show what's being edited.  
    -- It is **NOT** the field's .text attribute.  That is event.target.text
    --
    if event.phase == "began" then

        -- user begins editing textField
        print( "Begin editing", event.target.text )

    elseif event.phase == "ended" or event.phase == "submitted" then

        -- do something with defaulField's text
        print( "Final Text: ", event.target.text)
        native.setKeyboardFocus( nil )

    elseif event.phase == "editing" then

        print( event.newCharacters )
        print( event.oldText )
        print( event.startPosition )
        print( event.text )

    end
end

--
-- This is the starter code for a newTextField widget
--

function widget.newTextField(options)
    local customOptions = options or {}
    local opt = {}

    --
    -- Core parameters
    --
    opt.left = customOptions.left or 0
    opt.top = customOptions.top or 0
    opt.x = customOptions.x or 0
    opt.y = customOptions.y or 0
    opt.width = customOptions.width or (display.contentWidth * 0.75)
    opt.height = customOptions.height or 20
    opt.id = customOptions.id
    opt.listener = customOptions.listener or nil
    opt.text = customOptions.text or ""
    opt.inputType = customOptions.inputType or "default"
    opt.font = customOptions.font or native.systemFont
    opt.fontSize = customOptions.fontSize or opt.height * 0.67

    -- Vector options
    opt.strokeWidth = customOptions.strokeWidth or 2
    opt.cornerRadius = customOptions.cornerRadius or opt.height * 0.33 or 10
    opt.strokeColor = customOptions.strokeColor or {0, 0, 0}
    opt.backgroundColor = customOptions.backgroundColor or {1, 1, 1}
    opt.placeholder = customOptions.placeholder or nil

    --
    -- Create the display portion of the widget and position it.
    --

    local field = display.newGroup()

    local background = display.newRoundedRect( 0, 0, opt.width, opt.height, opt.cornerRadius )
    background:setFillColor(unpack(opt.backgroundColor))
    background.strokeWidth = opt.strokeWidth
    background.stroke = opt.strokeColor
    field:insert(background)

    if opt.x then
        field.x = opt.x
    elseif opt.left then
        field.x = opt.left + opt.width * 0.5
    end
    if opt.y then
        field.y = opt.y
    elseif opt.top then
        field.y = opt.top + opt.height * 0.5
    end

    -- create the native.newTextField to handle the input

    field.textField = native.newTextField(0, 0, opt.width - opt.cornerRadius, opt.height - opt.strokeWidth * 2)
    field.textField.x = field.x
    field.textField.y = field.y
    field.textField.hasBackground = false
    field.textField.inputType = opt.inputType
    field.textField.text = opt.text
    field.textField.placeholder = opt.placeholder

    if opt.listener and type(opt.listener) == "function" then
        field.textField:addEventListener("userInput", opt.listener)
    end

    --
    -- Handle setting the text parameters for the native field.
    --

    local deviceScale = (display.pixelWidth / display.contentWidth) * 0.5
    
    field.textField.font = native.newFont( opt.font )
    field.textField.size = opt.fontSize * deviceScale

    --
    -- Sync the position of the native object and the display object.
    -- A 60 fps app will make this smoother than a 30 fps app
    -- 
    -- You could add in things to handle other properties like alpha, .isVisible etc.
    -- that both objects support.
    --

    local function syncFields(event)
        field.textField.x = field.x
        field.textField.y = field.y
    end
    Runtime:addEventListener( "enterFrame", syncFields )

    --
    -- Handle cleaning up the native object when the display object is destroyed.
    --
    function field:finalize( event )
        event.target.textField:removeSelf()
    end

    field:addEventListener( "finalize" )

    return field
end 

--
-- Create an instance of the widget.
-- 
--textField = widget.newTextField({
--    width = 250,
--    height = 30,
--    text = "Hello World",
--    fontSize = 18,
--    font = "HelveticaNeue-Light",
--    listener = textFieldHandler,
--})
--
--textField.x = display.contentCenterX
--textField.y = 100
--
---- 
---- Do some fun things like move the text field
---- Change the text.
---- Remove it.
----
--timer.performWithDelay( 5000, function()
--    transition.to(textField, {time=1000, y=300, onComplete = function(target) target.textField.text = "Bye Bye"; end })
--end )
--
--timer.performWithDelay( 10000, function() textField:removeSelf(); end )
