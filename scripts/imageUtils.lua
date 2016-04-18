

local ui = {}

function ui.imageGetWidth(image, height)
    local tempImage = display.newImage(image)
     
    local multiplier = height / tempImage.height
     
    tempImage:removeSelf()
    return tempImage.width * multiplier
end

function ui.getImageSize(image, maxwidth, maxheight)
    -- print(image .. ":" .. maxwidth .. "x" .. maxheight)
    local tempImage = display.newImage(image)
     
    local multiplier_height = maxheight / tempImage.height
    local multiplier_width = maxwidth / tempImage.width
     
    local width = nil
    local height = nil
     
    if multiplier_height > multiplier_width then
        width = tempImage.width * multiplier_height
        height = tempImage.height * multiplier_height
    else
        width = tempImage.width * multiplier_width
        height = tempImage.height * multiplier_width    
    end
     
    if width > maxwidth then
        multiplier_width = maxwidth / width
         
        width = maxwidth
        height = height * multiplier_width
    end
     
    if height > maxheight then
        multiplier_height = maxheight / height
         
         
        height = maxheight
        width = width * multiplier_height
    end
     
    tempImage:removeSelf()
     
    width = math.floor(width)
    height = math.floor(height)
     
    return {
        width = width,
        height = height
    }
end    

function ui.newImageRect(image, maxwidth, maxheight)
    local size = ui.getImageSize(image, maxwidth, maxheight)
    return display.newImageRect(image, size.width, size.height)
end

return ui
