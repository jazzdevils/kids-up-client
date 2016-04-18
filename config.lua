--[[
  display.HiddenStatusBar
  display.DefaultStatusBar
  display.TranslucentStatusBar
  display.DarkStatusBar
]]
--statusBarType = "translucent" --  hidden, default, translucent, dark
statusBarType = 'default'
__statusBarHeight__ = nil -- StatusBar Height
__appContentWidth__ = nil -- application.content.width
__appContentHeight__ = nil -- application.content.height

local aspectRatio = display.pixelHeight / display.pixelWidth
application = {
    content = {
        width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
        height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),
        scale = "letterBox",
        fps = 60,

        imageSuffix = {
            ["@2x"] = 1.5,
            ["@4x"] = 3.0,
        },
   },
   notification = {
        google = { 
            projectNumber = "340040307853", 
        },
        iphone = {
            types = {
                "badge", "sound", "alert"
            },
        },
    },
}