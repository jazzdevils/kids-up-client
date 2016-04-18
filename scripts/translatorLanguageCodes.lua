local language = getLanguage()

local TLC_Info = {}


TLC_Info.codes = {
    {
        name = language["translatorLanguageCodes"]["no_code"],
        code = "",
    },
    {
        name = "Arabic",
        code = "ar",
    },
    {
        name = "Bulgarian",
        code = "bg",
    },
    {
        name = "Catalan",
        code = "ca",
    },
    {
        name = "Chinese Simplified",
        code = "zh-CHS",
    },
    {
        name = "Chinese Traditional",
        code = "zh-CHT",
    },
    {
        name = "Czech",
        code = "cs",
    },
    {
        name = "Danish",
        code = "da",
    },
    {
        name = "Dutch",
        code = "nl",
    },
    {
        name = "English",
        code = "en",
    },
    {
        name = "Estonian",
        code = "et",
    },
    {
        name = "Finnish",
        code = "fi",
    },
    {
        name = "French",
        code = "fr",
    },
    {
        name = "German",
        code = "de",
    },
    {
        name = "Greek",
        code = "el",
    },
    {
        name = "Haitian Creole",
        code = "ht",
    },
    {
        name = "Hebrew",
        code = "he",
    },
    {
        name = "Hindi",
        code = "hi",
    },
    {
        name = "Hmong Daw",
        code = "mww",
    },
    {
        name = "Hungarian",
        code = "hu",
    },
    {
        name = "Indonesian",
        code = "id",
    },
    {
        name = "Italian",
        code = "it",
    },
    {
        name = "日本語",
        code = "ja",
    },
    {
        name = "Klingon",
        code = "tlh",
    },
    {
        name = "Klingon (pIqaD)",
        code = "tlh-Qaak",
    },
    {
        name = "한국어",
        code = "ko",
    },
    {
        name = "Latvian",
        code = "lv",
    },
    {
        name = "Lithuanian",
        code = "lt",
    },
    {
        name = "Malay",
        code = "ms",
    },
    {
        name = "Maltese",
        code = "mt",
    },
    {
        name = "Norwegian",
        code = "no",
    },
    {
        name = "Persian",
        code = "fa",
    },
    {
        name = "Polish",
        code = "pl",
    },
    {
        name = "Portuguese",
        code = "pt",
    },
    {
        name = "Romanian",
        code = "ro",
    },
    {
        name = "Russian",
        code = "ru",
    },
    {
        name = "Slovak",
        code = "sk",
    },
    {
        name = "Slovenian",
        code = "sl",
    },
    {
        name = "Spanish",
        code = "es",
    },
    {
        name = "Swedish",
        code = "sv",
    },
    {
        name = "Thai",
        code = "th",
    },
    {
        name = "Turkish",
        code = "tr",
    },
    {
        name = "Ukrainian",
        code = "uk",
    },
    {
        name = "Urdu",
        code = "ur",
    },
    {
        name = "Vietnamese",
        code = "vi",
    },
    {
        name = "Welsh",
        code = "cy",
    },
}

function TLC_Info:getLanguageCode(index)
    return self.codes[index]
end

function TLC_Info:getIndexOfLanguageCode(code)
    for i = 1, #self.codes do
        if(code == self.codes[i].code) then
            return i
        end
    end
end

return TLC_Info
