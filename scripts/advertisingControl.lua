local utils = require("scripts.commonUtils")
local language = getLanguage()

local M = {}
local activeBannerIndex = 0

M.BannerList = {
    {   -- default 1    
        id = 1,
        title = language["appTitle"],
        desc = "test1_desc",
        image = "images/etc/default1.png",
        url = "http://www.kidsup.net",
        default = true, -- 키즈업광고: true, 외부광고: false
    },
    {   -- default 2
        id = 2,
        title = language["appTitle"],
        desc = "test2_desc",
        image = "images/etc/default2.png",
        url = "http://www.kidsup.net",
        default = true, -- 키즈업광고: true, 외부광고: false
    },
}

function M.getBannerByRandom()
    local index = utils.getRandomValue(1, #M.BannerList)
    
    return M.BannerList[index]
end

function M.getBanner()
    activeBannerIndex = activeBannerIndex + 1

    if activeBannerIndex > #M.BannerList or activeBannerIndex == 0 then
        activeBannerIndex = 1
    end
    
    return M.BannerList[activeBannerIndex]
end

function M.freeBannerList()
    for i = #M.BannerList, 1, -1 do
        table.remove(M.BannerList, i) 
    end
end

function M.addBanner(_title, _desc, _image, _url)
    local bannerData = {}
    bannerData.title = _title
    bannerData.desc = _desc
    bannerData.image = _image
    bannerData.url = _url
    
    table.insert(M.BannerList, bannerData)
end

return M



