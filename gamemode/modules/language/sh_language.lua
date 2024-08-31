local rp_languages = {}
local selectedLanguage = GetConVar("gmod_language"):GetString()

function DarkRP.addLanguage(name, tbl)
    local old = rp_languages[name] or {}
    rp_languages[name] = tbl

    for k, v in pairs(old) do
        if rp_languages[name][k] then continue end
        rp_languages[name][k] = v
    end
    LANGUAGE = rp_languages[name] -- backwards compatibility
end

function DarkRP.addPhrase(lang, name, phrase)
    rp_languages[lang] = rp_languages[lang] or {}
    rp_languages[lang][name] = phrase
end

function DarkRP.getPhrase(name, ...)
    local langTable = rp_languages[selectedLanguage] or rp_languages.en
    return langTable[name] and string.format(langTable[name], ...) or nil
end
