system.activate( "multitouch" )

local Factory = {}

local path
------------------------------------------------------------------------------
--
-- ScrollView 클래스
--
------------------------------------------------------------------------------

-- 하나의 객체를 담는 스크롤 뷰
function Factory.newScrollView(_imgPath, _W, _H)
    ---------------------------------------

    -- 이미지를 감싸는 그룹 생성, 크기나 위치 변경 없음 (이벤트를 받아서 img 크기 조정)
    local group = display.newGroup( )
    group.anchorX = 0
    group.anchorY = 0
    group.mouseEnabled = true
    group.outBounce = true

    local bg = display.newRect( group, 0, 0, _W, _H ) -- 터치를 위한 배경, 크기나 위치 변경 없음
    bg:setFillColor(0, 0, 0, 0)
    -- bg:setReferencePoint(display.TopLeftReferencePoint)
    bg.anchorX = 0
    bg.anchorY = 0
    bg.x, bg.y = 0, 0

    ---------------------------------------

    local img -- 실제 이미지

    -- 처음 x, y 스케일
    local firstXScale, firstYScale
    local firstX, firstY

    local minScale = 0.6
    local maxScale = 3.5

    ---------------------------------------

    function group:setImage(imgPath)
        if imgPath == nil then return end

        if img then img:removeSelf() end

        local tempImg = display.newImage(group, imgPath, path ) -- 이미지 사이즈를 알아보기 위해 로드함
        
        local scalePoint
        if (tempImg.width > _W) then
            scalePoint =  _W / tempImg.width
        else    
            scalePoint = 1
        end
        
        img = display.newImageRect(group, imgPath, path, 0, 0 )
        img.width = tempImg.width * scalePoint
        img.height = tempImg.height * scalePoint
        img.anchorX = 0
        img.anchorY = 0
        img.y = (_H - img.height) * 0.5    
        
        if (img.width < _W) then
            img.x = (_W - img.width) * 0.5
        end
        
        tempImg:removeSelf()
        tempImg = nil

        firstXScale, firstYScale = img.xScale, img.yScale
        firstX, firstY = img.x, img.y
    end

    if _imgPath ~= nil then group:setImage(_imgPath) end

    ---------------------------------------
     
    local function calculateDelta( previousTouches, event )
     
            local id,touch = next( previousTouches )
            if event.id == id then
                    id,touch = next( previousTouches, id )
                    assert( id ~= event.id )
            end
     
            local dx = touch.x - event.x
            local dy = touch.y - event.y
            return dx, dy
            
    end
     
    local function calculateCenter( previousTouches, event )
     
            local id,touch = next( previousTouches )
            if event.id == id then
                    id,touch = next( previousTouches, id )
                    assert( id ~= event.id )
            end
     
            local cx = math.floor( ( touch.x + event.x ) * 0.5 )
            local cy = math.floor( ( touch.y + event.y ) * 0.5 )
            return cx, cy
        
    end

    -- 크기 및 위치를 초기화
    function group:restore()
        if img == nil then return true end

        local tw, th = firstXScale, firstYScale
        local tx, ty = firstX, firstY

        img.xScale = tw
        img.yScale = th
        img.x = tx
        img.y = ty
    end
     
    ---------------------------------------
    -- 그룹의 이벤트
    function group:touch( event )
            event.anchorX = 0
            event.anchorY = 0
            
            if not group.mouseEnabled then return true end

            if img.previousDeltaX == nil then img.previousDeltaX = 0 end
            if img.previousDeltaY == nil then img.previousDeltaY = 0 end

            local phase = event.phase
            local eventTime = event.time
            local previousTouches = img.previousTouches
            
            if not img.xScaleStart then
                    img.xScaleStart, img.yScaleStart = img.xScale, img.yScale
            end
     
            local numTotalTouches = 1
            if previousTouches then
                    -- add in total from previousTouches, subtract one if event is already in the array
                    numTotalTouches = numTotalTouches + img.numPreviousTouches
                    if previousTouches[event.id] then
                            numTotalTouches = numTotalTouches - 1
                    end
            end

            local realWidth = img.width * img.xScale
            local realHeight = img.height * img.yScale
     
            if "began" == phase then
                    group:dispatchEvent({name="mouseDown", target=img})

                    -- Very first "began" event
                    if not img.isFocus then
                            -- Subsequent touch events will target button even if they are outside the contentBounds of button
                            display.getCurrentStage():setFocus( img )
                            img.isFocus = true
                            
                            -- Store initial position
                            img.x0 = event.x - img.x
                            img.y0 = event.y - img.y
     
                            previousTouches = {}
                            img.previousTouches = previousTouches
                            img.numPreviousTouches = 0
                            img.firstTouch = event
                            
                    elseif not img.distance then
                            local dx,dy
                            local cx,cy
     
                            if previousTouches and numTotalTouches >= 2 then
                                    dx,dy = calculateDelta( previousTouches, event )
                                    cx,cy = calculateCenter( previousTouches, event )
                            end
     
                            -- initialize to distance between two touches
                            if dx and dy then
                                    local d = math.sqrt( dx*dx + dy*dy )
                                    if d > 0 then
                                            img.distance = d
                                            img.xScaleOriginal = img.xScale
                                            img.yScaleOriginal = img.yScale
                                            
                                            img.x0 = cx - img.x
                                            img.y0 = cy - img.y
                            
                                    end
                            end
                            
                    end
     
                    if not previousTouches[event.id] then
                            img.numPreviousTouches = img.numPreviousTouches + 1
                    end
                    previousTouches[event.id] = event
     
            elseif img.isFocus then
                    if "moved" == phase then
                            if img.distance then
                                    local dx,dy
                                    local cx,cy
                                    if previousTouches and numTotalTouches == 2 then
                                            dx,dy = calculateDelta( previousTouches, event )
                                            cx,cy = calculateCenter( previousTouches, event )
                                    end
     
                                    if dx and dy then
                                            local newDistance = math.sqrt( dx*dx + dy*dy )
                                            local scale = newDistance / img.distance
     
                                            if scale > 0 then
                                                    local _scaleX = img.xScaleOriginal * scale

                                                    if _scaleX > maxScale then
                                                        _scaleX = maxScale
                                                    elseif _scaleX < minScale then
                                                        _scaleX = minScale
                                                    end

                                                    img.xScale = _scaleX
                                                    img.yScale = _scaleX

                                                    if _scaleX > minScale and _scaleX < maxScale then
                                                        -- Make object move while scaling
                                                        img.x = cx - ( img.x0 * scale )
                                                        img.y = cy - ( img.y0 * scale )
                                                    end
                                            end
                                    end
                            else
                                    if event.id == img.firstTouch.id then
                                            -- don't move unless this is the first touch id.
                                            -- Make object move (we subtract img.x0, img.y0 so that moves are
                                            -- relative to initial grab point, rather than object "snapping").
                                            local _enableX = (realWidth > _W)
                                            local _enableY = (realHeight > _H)

                                            local tx = event.x - img.x0
                                            local ty = event.y - img.y0

                                            if not group.outBounce then -- 아웃바운스 안함
                                                if _enableX then
                                                    img.x = tx
                                                    if tx > 0 then
                                                        _enableX = false
                                                        img.x = 0
                                                    elseif tx + realWidth < _W then
                                                        _enableX = false
                                                        img.x = _W - realWidth
                                                    end
                                                end
                                                if _enableY then
                                                    img.y = ty
                                                    if ty > 0 then
                                                        _enableY = false
                                                        img.y = 0
                                                    elseif ty + realHeight < _H then
                                                        _enableY = false
                                                        img.y = _H - realHeight
                                                    end
                                                end
                                            else -- 아웃바운스 함
                                                local dx = event.x - img.firstTouch.x
                                                local dy = event.y - img.firstTouch.y

                                                if tx > 0 or tx + realWidth < _W then dx = dx * 0.5 end
                                                if ty > 0 or ty + realHeight < _H then dy = dy * 0.5 end

                                                img.x = img.x + dx
                                                img.y = img.y + dy
                                            end

                                            ---------------------------------
                                            -- 이 부분은 여기에 둘 것
                                            img.previousDeltaX = event.x - img.firstTouch.x
                                            img.previousDeltaY = event.y - img.firstTouch.y
                                            img.previousEnableX = _enableX
                                            img.previousEnableY = _enableY
                                            ---------------------------------
                                            group:dispatchEvent({name="mouseMove", target=img, enableX=_enableX, enableY=_enableY, dx=img.previousDeltaX, dy=img.previousDeltaY})
                                    end
                            end
                            
                            if event.id == img.firstTouch.id then
                                    img.firstTouch = event
                            end
     
                            if not previousTouches[event.id] then
                                    img.numPreviousTouches = img.numPreviousTouches + 1
                            end
                            previousTouches[event.id] = event
     
                    elseif "ended" == phase or "cancelled" == phase then
                            -- check for taps
                            local dx = math.abs( event.xStart - event.x )
                            local dy = math.abs( event.yStart - event.y )

                            if eventTime - previousTouches[event.id].time < 150 and dx < 10 and dy < 10 then
                                    if not img.tapTime then
                                            -- single tap
                                            img.tapTime = eventTime
                                            img.tapDelay = timer.performWithDelay( 200, function()
                                                img.tapTime = nil

--                                                group:dispatchEvent({name="singleTap", target=img})
                                                local _parent = group.parent
                                                while _parent do -- cancel이 안되는 bubbling
                                                    _parent:dispatchEvent({name="singleTap", target=img})
                                                    _parent = _parent.parent
                                                end
                                            end )
                                    elseif eventTime - img.tapTime < 200 then
                                            -- double tap
                                            timer.cancel( img.tapDelay )
                                            img.tapTime = nil
                                            if img.xScale == img.xScaleStart and img.yScale == img.yScaleStart then
                                                    -- 커짐
                                                    local tx = event.x - (img.x0 * maxScale)
                                                    if event.x < img.x then -- 이미지 바깥 빈 영역 터치
                                                        if realWidth * maxScale > _W then tx = 0
                                                        else tx = (_W * 0.5) - (realWidth * maxScale * 0.5) end
                                                    elseif event.x > img.x + img.width then
                                                        if realWidth * maxScale > _W then tx = _W - (realWidth * maxScale)
                                                        else tx = (_W * 0.5) - (realWidth * maxScale * 0.5) end
                                                    end

                                                    local ty = event.y - (img.y0 * maxScale)
                                                    if event.y < img.y then -- 이미지 바깥 빈 영역 터치
                                                        if realHeight * maxScale > _H then ty = 0
                                                        else ty = (_H * 0.5) - (realHeight * maxScale * 0.5) end
                                                    elseif event.y > img.y + img.height then
                                                        if realHeight * maxScale > _H then ty = _H - (realHeight * maxScale)
                                                        else ty = (_H * 0.5) - (realHeight * maxScale * 0.5) end
                                                    end

                                                    -- 이미지의 끝이 모서리보다 안쪽이면 모서리에 붙임
                                                    if tx > 0 then tx = 0
                                                    elseif tx < _W - (realWidth * maxScale) then tx = _W - (realWidth * maxScale) end

                                                    if ty > 0 then ty = 0
                                                    elseif ty < _H - (realHeight * maxScale) then ty = _H - (realHeight * maxScale) end

                                                    transition.to( img, { time=300, transition=easing.outQuad, xScale=img.xScale*maxScale, yScale=img.yScale*maxScale, x=tx, y=ty } )
                                            else
                                                    -- 원래대로 작아짐
                                                    local tw, th = firstXScale, firstYScale
                                                    local tx, ty = firstX, firstY

                                                    transition.to( img, { time=300, transition=easing.outQuad, xScale = tw, yScale = th, x=tx, y=ty } )
                                            end
                                    end
                            else
                                -- Tap 하지 않고 드래그 하다가 놓았을 경우
                                local tx = img.x + (img.previousDeltaX * 2)
                                local ty = img.y + (img.previousDeltaY * 2)

                                if tx > 0 then tx = 0
                                elseif tx + realWidth < _W then tx = _W - realWidth end

                                if ty > 0 then ty = 0
                                elseif ty + realHeight < _H then ty = _H - realHeight end

                                if img.x > 0 then
                                    tx = 0
                                elseif img.x + realWidth < _W then
                                    tx = _W - realWidth
                                end
                                if realWidth < _W then tx = (_W * 0.5) - (realWidth * 0.5) end

                                if img.y > 0 then
                                    ty = 0
                                elseif img.y + realHeight < _H then
                                    ty = _H - realHeight
                                end
                                if realHeight < _H then ty = (_H * 0.5) - (realHeight * 0.5) end

                                local tw, th = img.xScale, img.yScale
                                if tw < firstXScale then
                                    tw, th = firstXScale, firstYScale
                                    tx, ty = firstX, firstY
                                end

                                transition.to( img, { time=200, transition=easing.outQuad, xScale = tw, yScale = th, x=tx, y=ty } )

                                -- img.previousDeltaX, previousDeltaY, previousEnableX, previousEnableY
                                group:dispatchEvent({name="mouseUp", target=img})
                            end
                    
                            --
                            if previousTouches[event.id] then
                                    img.numPreviousTouches = img.numPreviousTouches - 1
                                    previousTouches[event.id] = nil
                            end
     
                            if img.numPreviousTouches == 1 then
                                    -- must be at least 2 touches remaining to pinch/zoom
                                    img.distance = nil
                                    -- reset initial position
                                    local id,touch = next( previousTouches )
                                    img.x0 = touch.x - img.x
                                    img.y0 = touch.y - img.y
                                    img.firstTouch = touch
     
                            elseif img.numPreviousTouches == 0 then
                                    -- previousTouches is empty so no more fingers are touching the screen
                                    -- Allow touch events to be sent normally to the objects they "hit"
                                    display.getCurrentStage():setFocus( nil )
                                    img.isFocus = false
                                    img.distance = nil
                                    img.xScaleOriginal = nil
                                    img.yScaleOriginal = nil
     
                                    -- reset array
                                    img.previousTouches = nil
                                    img.numPreviousTouches = nil
                            end
                    end
            end
     
            return true
    end

    group:addEventListener( "touch", group )

    return group
end

------------------------------------------------------------------------------
--
-- ImageSlider 클래스
--
------------------------------------------------------------------------------

-- 이미지 슬라이더
function Factory.newImageSlider(_W, _H)
    local isv = display.newGroup( )
    isv.selectedIndex = 1

    local center, left, right, setCenterScrollView, on_MouseDown, on_MouseMove, on_MouseUp
    local horizontalGap = 40

    -- 슬라이더 배경
    local bg = display.newRect( isv, -1 * (_W + horizontalGap), 0, (_W * 3) + (horizontalGap * 3), _H )
    bg.anchorX = 0
    bg.anchorY = 0
    bg.x = -1 * (_W + horizontalGap)
    bg.y = 0
    bg:setFillColor(0, 0, 0)

    local images -- collection
    
    setCenterScrollView = function (_center, _left, _right)
        if images[isv.selectedIndex - 1] then _left:setImage(images[isv.selectedIndex - 1]) end
        if images[isv.selectedIndex] then _center:setImage(images[isv.selectedIndex]) end
        if images[isv.selectedIndex + 1] then _right:setImage(images[isv.selectedIndex + 1]) end

        -- 크기 및 위치를 초기화
        _center:restore()
        _left:restore()
        _right:restore()

        _center:removeEventListener("mouseDown", on_MouseDown)
        _left:removeEventListener("mouseDown", on_MouseDown)
        _right:removeEventListener("mouseDown", on_MouseDown)

        _center:removeEventListener("mouseMove", on_MouseMove)
        _left:removeEventListener("mouseMove", on_MouseMove)
        _right:removeEventListener("mouseMove", on_MouseMove)

        _center:removeEventListener("mouseUp", on_MouseUp)
        _left:removeEventListener("mouseUp", on_MouseUp)
        _right:removeEventListener("mouseUp", on_MouseUp)

        center = _center
        left = _left
        right = _right

        center.x = 0
        
        if isv.selectedIndex > 1 then left.x = -1 * (_W + horizontalGap)
        else left.x = -1000 end

        if isv.selectedIndex < #images then right.x = (_W + horizontalGap)
        else right.x = 1000 end

        isv.x = 0

        center:addEventListener("mouseDown", on_MouseDown)
        center:addEventListener("mouseMove", on_MouseMove)
        center:addEventListener("mouseUp", on_MouseUp)

        isv:dispatchEvent({name="changed"})
    end

    local tr

    on_MouseDown = function (e)
        if tr then transition.cancel( tr ) end
    end

    on_MouseMove = function (e)
        local _enableX = e.enableX
        local dx = e.dx

        if _enableX then if isv.x ~= 0 then isv.x = 0 end end
        
        if not _enableX then
            isv.x = isv.x + dx * (((dx > 0 and isv.selectedIndex <= 1) or (dx < 0 and isv.selectedIndex >= #images)) and 0.5 or 1)
        end
    end

    local function leftComplete(e)
        isv.selectedIndex = isv.selectedIndex + 1
        setCenterScrollView(right, left, center)
    end

    local function rightComplete(e)
        isv.selectedIndex = isv.selectedIndex - 1
        setCenterScrollView(left, center, right)
    end

    local function centerComplete(e)
    end

    on_MouseUp = function (e)
        if e.target.previousDeltaX == nil then return true end

        if e.target.previousEnableX then
            if isv.x ~= 0 then isv.x = 0 end
            return true
        end

        function moveLeft()
            local isPossible = isv.selectedIndex < #images
            if isPossible then tr = transition.to(isv, {time = 300, x = -1 * (_W + horizontalGap), transition=easing.outQuad, onComplete = leftComplete}) end
            return isPossible
        end

        function moveRight()
            local isPossible = isv.selectedIndex > 1
            if isPossible then tr = transition.to(isv, {time = 300, x = (_W + horizontalGap), transition=easing.outQuad, onComplete = rightComplete}) end
            return isPossible
        end

        function moveCenter()
            local _t = ((math.abs(e.target.previousDeltaX) > 10) and 1 or 300)
            if isv.selectedIndex == 1 or isv.selectedIndex >= #images then _t = 300 end
            tr = transition.to(isv, {time = _t, x = 0, transition=easing.outQuad, onComplete = centerComplete})
        end

        if isv.x < 0 and e.target.previousDeltaX < -10 then
            -- print("left", isv.selectedIndex, #images)
            if not moveLeft() then moveCenter() end
        elseif isv.x + _W > _W and e.target.previousDeltaX > 10 then
            -- print("right", isv.selectedIndex, #images)
            if not moveRight() then moveCenter() end
        else
            -- 느리게 움직인 경우
            if isv.x < -_W * 0.5 then
                if not moveLeft() then moveCenter() end
            elseif isv.x > _W * 0.5 then
                if not moveRight() then moveCenter() end
            else moveCenter() end
        end
    end

    left = Factory.newScrollView(nil, _W, _H)
    left.outBounce = false
    center = Factory.newScrollView(nil, _W, _H)
    center.outBounce = false
    right = Factory.newScrollView(nil, _W, _H)
    right.outBounce = false

    isv:insert( center )
    isv:insert( right )
    isv:insert( left )

    -- center 좌, 우에 검정색 띠를 덮음
    local leftCover = display.newRect( isv, -1 * horizontalGap, 0, horizontalGap, _H )
    leftCover.anchorX = 0
    leftCover.anchorY = 0
    leftCover.x = -1 * horizontalGap
    leftCover.y = 0
    leftCover:setFillColor(0, 0, 0)

    local rightCover = display.newRect( isv, _W, 0, horizontalGap, _H )
    rightCover.anchorX = 0
    rightCover.anchorY = 0
    rightCover.x = _W
    rightCover.y = 0
    rightCover:setFillColor(0, 0, 0)

    function isv:setDataProvider(_images, _path, idx) -- idx = firstPage
        images = _images
        path = _path
        
        if idx == nil then idx = 1 end
        isv:selectPage(idx)
    end

    function isv:selectPage(idx)
        isv.selectedIndex = idx

        setCenterScrollView(center, left, right)
    end
    
    function isv:getCurrentImageFileName()
        local result = nil
        local selectedFileName = ""
        selectedFileName = images[isv.selectedIndex]
        
        if(selectedFileName ~= "" and path) then
            result = {selectedFileName, path}
        end
        
        return result
    end

    return isv
end

return Factory