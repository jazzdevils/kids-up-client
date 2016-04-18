--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:2c9e4d584db354c3dd383aa4782430f7:2751b1e0cd5aa2c2b90be3342007d97c:6f01185cf5ff3f0875d1b064468fe626$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- editField_bottomLeft
            x=23,
            y=23,
            width=6,
            height=6,

        },
        {
            -- editField_bottomMiddle
            x=23,
            y=13,
            width=6,
            height=6,

        },
        {
            -- editField_bottomRight
            x=13,
            y=23,
            width=6,
            height=6,

        },
        {
            -- editField_middle
            x=13,
            y=13,
            width=6,
            height=6,

        },
        {
            -- editField_middleLeft
            x=23,
            y=3,
            width=6,
            height=6,

        },
        {
            -- editField_middleRight
            x=13,
            y=3,
            width=6,
            height=6,

        },
        {
            -- editField_topLeft
            x=3,
            y=23,
            width=6,
            height=6,

        },
        {
            -- editField_topMiddle
            x=3,
            y=13,
            width=6,
            height=6,

        },
        {
            -- editField_topRight
            x=3,
            y=3,
            width=6,
            height=6,

        },
    },
    
    sheetContentWidth = 32,
    sheetContentHeight = 32
}

SheetInfo.frameIndex =
{

    ["editField_bottomLeft"] = 1,
    ["editField_bottomMiddle"] = 2,
    ["editField_bottomRight"] = 3,
    ["editField_middle"] = 4,
    ["editField_middleLeft"] = 5,
    ["editField_middleRight"] = 6,
    ["editField_topLeft"] = 7,
    ["editField_topMiddle"] = 8,
    ["editField_topRight"] = 9,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
