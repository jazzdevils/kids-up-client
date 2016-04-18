
function getLanguage()
    local lang = system.getPreference("ui", "language")
    local language = nil
    print(lang)
        
    if __deviceType__ == "iphone" then
--        if lang == "ja" then --Japan   
--            language = require("language.jap")
--        elseif lang == "ko" then --Korea   
--            language = require("language.kor")
--        else
--            language = require("language.eng")    
--        end
        language = require("language.jap")
        lang = "ja"
    elseif __deviceType__ == "android" then
--        if lang == "日本語" then
--            language = require("language.jap")
--        elseif lang == "한국어" then
--            language = require("language.kor")
--        else
--            language = require("language.eng")    
--        end
        language = require("language.jap")
        lang = "日本語"
    end
    return language, lang
end





