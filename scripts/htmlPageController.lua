require("scripts.commonSettings")
local utils = require("scripts.commonUtils")
local language = getLanguage()

local html = {}

function html.openBrowser(_url)
    system.openURL( _url )
end

function html.getURLofTermsService()
    local lang = system.getPreference("ui", "language")
    local returnStr = ""
--    if (lang == "ja" or lang == "日本語") then --Japan   
    returnStr = __WEB_PAGE_SERVER_ADDR__.."/inapp_rule-ja.html".."?cachebust="..os.time() 
--    elseif (lang == "ko" or lang == "한국어") then --Japan   
--        returnStr = __WEB_PAGE_SERVER_ADDR__.."/inapp_rule-ko.html".."?cachebust="..os.time() 
--    else
--        returnStr = __WEB_PAGE_SERVER_ADDR__.."/inapp_rule-en.html".."?cachebust="..os.time() 
--    end
    
    return returnStr
end

function html.getURLofFAQ()
    local lang = system.getPreference("ui", "language")
    local returnStr = ""
--    if (lang == "ja" or lang == "日本語") then --Japan   
    returnStr = __WEB_PAGE_SERVER_ADDR__.."/inapp_faq-ja.html".."?cachebust="..os.time() 
--    elseif (lang == "ko" or lang == "한국어") then --Japan   
--        returnStr = __WEB_PAGE_SERVER_ADDR__.."/inapp_faq-ko.html".."?cachebust="..os.time() 
--    else
--        returnStr = __WEB_PAGE_SERVER_ADDR__.."/inapp_faq-en.html".."?cachebust="..os.time() 
--    end
    
    return returnStr
end

function html.getURLofKidsUpNews()
    local lang = system.getPreference("ui", "language")
    local returnStr = ""
--    if (lang == "ja" or lang == "日本語") then --Japan   
    returnStr = __WEB_PAGE_SERVER_ADDR__.."/inapp_news-ja.html".."?cachebust="..os.time()  
--    elseif (lang == "ko" or lang == "한국어") then --Japan   
--        returnStr = __WEB_PAGE_SERVER_ADDR__.."/inapp_news-ko.html".."?cachebust="..os.time() 
--    else
--        returnStr = __WEB_PAGE_SERVER_ADDR__.."/inapp_news-en.html".."?cachebust="..os.time() 
--    end
    
    return returnStr
end

function html.getURLofHelp(jobType, helpType) --멤버타입(원장,교사,학부모) , 보여줄 도움말 타입(외부 브라우져 호출)
--    local lang = system.getPreference("ui", "language")
    local returnStr = ""
    
--    if (lang == "ja" or lang == "日本語") then --Japan   
        if helpType == "join_help" then
            if jobType == __DIRECTOR__ then
                returnStr = __WEB_PAGE_SERVER_ADDR__.."/follow_principal-ja.html" 
            elseif jobType == __TEACHER__ then
                returnStr = __WEB_PAGE_SERVER_ADDR__.."/follow_teacher-ja.html" 
            elseif jobType == __PARENT__ then
                returnStr = __WEB_PAGE_SERVER_ADDR__.."/follow_parent-ja.html" 
            end
        end
--    elseif (lang == "ko" or lang == "한국어") then --Japan   
--        if helpType == "join_help" then
--            if jobType == __DIRECTOR__ then
--                returnStr = __WEB_PAGE_SERVER_ADDR__.."/follow_principal-ko.html" 
--            elseif jobType == __TEACHER__ then
--                returnStr = __WEB_PAGE_SERVER_ADDR__.."/follow_teacher-ko.html" 
--            elseif jobType == __PARENT__ then
--                returnStr = __WEB_PAGE_SERVER_ADDR__.."/follow_parent-ko.html" 
--            end
--        end
--    else
--        if helpType == "join_help" then
--            if jobType == __DIRECTOR__ then
--                returnStr = __WEB_PAGE_SERVER_ADDR__.."/follow_principal-en.html" 
--            elseif jobType == __TEACHER__ then
--                returnStr = __WEB_PAGE_SERVER_ADDR__.."/follow_teacher-en.html" 
--            elseif jobType == __PARENT__ then
--                returnStr = __WEB_PAGE_SERVER_ADDR__.."/follow_parent-en.html" 
--            end
--        end
--    end
    
    return returnStr
end

function html.showHelpOnBrowser(jobType, helpType) --멤버타입(원장,교사,학부모) , 보여줄 도움말 타입
    local url = html.getURLofHelp(jobType, helpType)
    
    if url == "" then
        utils.showMessage(language["help"]["not_support"])
    else
        html.openBrowser(url)
    end
end

return html

