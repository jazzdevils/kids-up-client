local widget = require("widget");
local isGraphicsV1 = ( 1 == display.getDefault( "graphicsCompatibility" ) )

-- Function to retrieve a widget's theme settings
local function _getTheme( widgetTheme, options )	
    local theme = nil
    
    -- If a theme has been set
    if widget.theme then
        theme = widget.theme[widgetTheme]
    end
    
    -- If a theme exists
    if theme then
        -- Style parameter optionally set by user
        if options and options.style then
            local style = theme[options.style]
            
            -- For themes that support various "styles" per widget
            if style then
                theme = style
            end
        end
    end
    
    return theme
end

local function createWidget(createFunction, ...)
    local defAnchorX, defAnchorY
    if not isGraphicsV1 then
        defAnchorX = display.getDefault( "anchorX")
        defAnchorY = display.getDefault( "anchorY" )
        widget._oldAnchorX = defAnchorX
        widget._oldAnchorY = defAnchorY
        
        display.setDefault( "anchorX", 0.5)
        display.setDefault( "anchorY", 0.5 )
  
    end
    local w = createFunction(...)
    if not isGraphicsV1 then
        display.setDefault( "anchorX", defAnchorX)
        display.setDefault( "anchorY", defAnchorY )
        w.anchorX = defAnchorX
        w.anchorY = defAnchorY        
    end
    return w
end

local function newEditField( options )
    local theme;
    if options.theme then
        theme = require(options.theme)["editField"]
    else
        theme = _getTheme( "editField", options );
    end
    if theme == nil then
        --if the current theme does not have a editfield, revert to searchfield
        theme = _getTheme( "searchField", options )
    end;  
    local _editField = require( "widgets.widget_editfield" )
    return createWidget(_editField.new, options, theme )
end

widget.newEditField = newEditField;

local function newPickerWheel( options )
	local theme = _getTheme( "pickerWheel", options )
	local _pickerWheel = require( "widgets.widget_pickerWheel" )
	return createWidget(_pickerWheel.new, options, theme )	
end
widget.newPickerWheel = newPickerWheel;


local function newPickerList( options )
    local _pickerList = require( "widgets.widget_pickerlist" )
    return createWidget(_pickerList.new, options)
end

widget.newPickerList = newPickerList;

