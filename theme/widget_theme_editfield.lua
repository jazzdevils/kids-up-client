local modname = ...
local theme = {}
package.loaded[modname] = theme
local imageSuffix = display.imageSuffix or ""

local sheetFile = "theme/editField.png"
local sheetData = "theme.editField"

theme.editField = 
{
    sheet = sheetFile,
    data = sheetData,
    
    topLeftFrame = "editField_topLeft",
    middleLeftFrame = "editField_middleLeft",
    bottomLeftFrame = "editField_bottomLeft",
    
    topMiddleFrame = "editField_topMiddle",
    middleFrame = "editField_middle",
    bottomMiddleFrame = "editField_bottomMiddle",
    
    topRightFrame = "editField_topRight",
    middleRightFrame = "editField_middleRight",
    bottomRightFrame = "editField_bottomRight",
    
    textFieldWidth = 150,
    textFieldHeight = 29,
}


return theme