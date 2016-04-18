local M = {}

M.sceneDataList = {}  --sender, receiver와 함께 사용  
M.sceneDataList2 = {} --uid 와 함께 사용

local function getSceneData(sender, receiver)
    local sceneListCount = #M.sceneDataList
    for i=1, sceneListCount do
        if (M.sceneDataList[i].sender == sender and M.sceneDataList[i].receiver == receiver) then
            return M.sceneDataList[i]
        end
    end
    
    return nil    
end

--sender, receiver:String type, sceneData:Table type
function M.addSceneData(sender, receiver, sceneData)
    if(sender and receiver and sceneData) then
        local oSceneData = getSceneData(sender, receiver)
            
        if(oSceneData) then
            oSceneData.data = sceneData
        else
            local oSceneData = {}
            oSceneData.sender = sender
            oSceneData.receiver = receiver
            oSceneData.data = sceneData
                
            table.insert(M.sceneDataList, oSceneData)
        end
    end
end

function M.getSceneData(sender, receiver)
    local sceneListCount = #M.sceneDataList
    for i=1, sceneListCount do
        if (M.sceneDataList[i].sender == sender and M.sceneDataList[i].receiver == receiver) then
            print(M.sceneDataList[i].data)
            return M.sceneDataList[i].data
        end
    end
    
    return nil    
end

function M.freeSceneData(sender, receiver)
    local sceneListCount = #M.sceneDataList
    for i=1, sceneListCount do
        if (M.sceneDataList[i].sender == sender and M.sceneDataList[i].receiver == receiver) then
            table.remove(M.sceneDataList, i) 
            
            return
        end
    end
end

-- with uid----------------------------------------------------------
local function getSceneDataWithUID(uid)
    local sceneListCount = #M.sceneDataList2
    for i=1, sceneListCount do
        if (M.sceneDataList2[i].uid == uid) then
            return M.sceneDataList2[i]
        end
    end
    
    return nil    
end

function M.addSceneDataWithUID(uid, sceneData)
    if(uid and sceneData) then
        local oSceneData = getSceneDataWithUID(uid)
            
        if(oSceneData) then
            oSceneData.data = sceneData
        else
            local oSceneData = {}
            oSceneData.uid = uid
            oSceneData.data = sceneData
                
            table.insert(M.sceneDataList2, oSceneData)
        end
    end
end

function M.getSceneDataWithUID(uid)
    local sceneListCount = #M.sceneDataList2
    for i=1, sceneListCount do
        print(M.sceneDataList2[i].uid)
        if (M.sceneDataList2[i].uid == uid) then
            return M.sceneDataList2[i].data
        end
    end
    
    return nil    
end

function M.freeSceneDataWithUID(uid)
    local sceneListCount = #M.sceneDataList2
    for i=1, sceneListCount do
        if (M.sceneDataList2[i].uid == uid) then
            table.remove(M.sceneDataList2, i) 
            
            return
        end
    end
end

function M.freeAllSceneData()
    local sceneListCount = #M.sceneDataList
    for i=sceneListCount, 1, -1 do
        table.remove(M.sceneDataList, i) 
    end
    
    local sceneListCount2 = #M.sceneDataList2
    for i=sceneListCount2, 1, -1 do
        table.remove(M.sceneDataList2, i) 
    end
end

return M

