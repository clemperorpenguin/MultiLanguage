local defaultOptions = {
    QUEST_TRANSLATIONS = true,
    ITEM_TRANSLATIONS = true,
    SPELL_TRANSLATIONS = true,
    NPC_TRANSLATIONS = true,
    SELECTED_LANGUAGE = nil, -- Will be set to client locale on first run
    SELECTED_INTERACTION = 'hover',
    SELECTED_HOTKEY = nil,
    AVAILABLE_LANGUAGES = {
        {value = 'en', text = 'English'}
    }
}

local addonName = ...
local optionsFrame = CreateFrame("Frame")
local hotkeyButton = nil
local waitingForKey = false

-- Merge account-wide and per-character settings
local function MergeSettings()
    MultiLanguageOptions = MultiLanguageOptions or {}
    MultiLanguageOptionsAccount = MultiLanguageOptionsAccount or {}

    -- Apply account-wide defaults first
    for key, value in pairs(defaultOptions) do
        if MultiLanguageOptionsAccount[key] == nil then
            MultiLanguageOptionsAccount[key] = value
        end
    end

    -- Per-character settings override account-wide for character-specific preferences
    for key, value in pairs(defaultOptions) do
        if MultiLanguageOptions[key] == nil then
            -- Use account-wide value if available, otherwise default
            if MultiLanguageOptionsAccount[key] ~= nil then
                MultiLanguageOptions[key] = MultiLanguageOptionsAccount[key]
            else
                MultiLanguageOptions[key] = value
            end
        end
    end

    -- Set default language to client locale if not set
    if MultiLanguageOptionsAccount.SELECTED_LANGUAGE == nil then
        -- Auto-detect from client locale
        local clientLocale = GetLocale()
        if clientLocale == "enUS" or clientLocale == "enGB" then
            MultiLanguageOptionsAccount.SELECTED_LANGUAGE = "en"
        elseif clientLocale == "esES" or clientLocale == "esMX" then
            MultiLanguageOptionsAccount.SELECTED_LANGUAGE = "es"
        elseif clientLocale == "deDE" then
            MultiLanguageOptionsAccount.SELECTED_LANGUAGE = "de"
        elseif clientLocale == "frFR" then
            MultiLanguageOptionsAccount.SELECTED_LANGUAGE = "fr"
        elseif clientLocale == "ptBR" then
            MultiLanguageOptionsAccount.SELECTED_LANGUAGE = "ptBR"
        elseif clientLocale == "ruRU" then
            MultiLanguageOptionsAccount.SELECTED_LANGUAGE = "ru"
        elseif clientLocale == "zhCN" then
            MultiLanguageOptionsAccount.SELECTED_LANGUAGE = "zhCN"
        elseif clientLocale == "zhTW" then
            MultiLanguageOptionsAccount.SELECTED_LANGUAGE = "zhTW"
        elseif clientLocale == "koKR" then
            MultiLanguageOptionsAccount.SELECTED_LANGUAGE = "koKR"
        else
            MultiLanguageOptionsAccount.SELECTED_LANGUAGE = "en"
        end
        -- Sync per-character setting
        if MultiLanguageOptions.SELECTED_LANGUAGE == nil then
            MultiLanguageOptions.SELECTED_LANGUAGE = MultiLanguageOptionsAccount.SELECTED_LANGUAGE
        end
    end

    -- Sync missing per-character settings from account-wide
    for key, value in pairs(MultiLanguageOptionsAccount) do
        if MultiLanguageOptions[key] == nil then
            MultiLanguageOptions[key] = value
        end
    end
end

local function InitializeOptions()
    MergeSettings()

    local category, layout = Settings.RegisterVerticalLayoutCategory("MultiLanguage")

    -- Quest Translations
    local function GetQuestTranslationsValue()
        return MultiLanguageOptions["QUEST_TRANSLATIONS"]
    end

    local function SetQuestTranslationsValue(value)
        MultiLanguageOptions["QUEST_TRANSLATIONS"] = value
        MultiLanguageOptionsAccount["QUEST_TRANSLATIONS"] = value
    end

    local questTranslationsSetting = Settings.RegisterProxySetting(category, "MULTILANGUAGE_QUEST_TRANSLATIONS",
        Settings.VarType.Boolean, "Enable quest translations", Settings.Default.True, GetQuestTranslationsValue, SetQuestTranslationsValue)
    Settings.CreateCheckbox(category, questTranslationsSetting)

    -- Item Translations
    local function GetItemTranslationsValue()
        return MultiLanguageOptions["ITEM_TRANSLATIONS"]
    end

    local function SetItemTranslationsValue(value)
        MultiLanguageOptions["ITEM_TRANSLATIONS"] = value
        MultiLanguageOptionsAccount["ITEM_TRANSLATIONS"] = value
    end

    local itemTranslationsSetting = Settings.RegisterProxySetting(category, "MULTILANGUAGE_ITEM_TRANSLATIONS",
        Settings.VarType.Boolean, "Enable item translations", Settings.Default.True, GetItemTranslationsValue, SetItemTranslationsValue)
    Settings.CreateCheckbox(category, itemTranslationsSetting)

    -- Spell Translations
    local function GetSpellTranslationsValue()
        return MultiLanguageOptions["SPELL_TRANSLATIONS"]
    end

    local function SetSpellTranslationsValue(value)
        MultiLanguageOptions["SPELL_TRANSLATIONS"] = value
        MultiLanguageOptionsAccount["SPELL_TRANSLATIONS"] = value
    end

    local spellTranslationsSetting = Settings.RegisterProxySetting(category, "MULTILANGUAGE_SPELL_TRANSLATIONS",
        Settings.VarType.Boolean, "Enable spell translations", Settings.Default.True, GetSpellTranslationsValue, SetSpellTranslationsValue)
    Settings.CreateCheckbox(category, spellTranslationsSetting)

    -- NPC Translations
    local function GetNpcTranslationsValue()
        return MultiLanguageOptions["NPC_TRANSLATIONS"]
    end

    local function SetNpcTranslationsValue(value)
        MultiLanguageOptions["NPC_TRANSLATIONS"] = value
        MultiLanguageOptionsAccount["NPC_TRANSLATIONS"] = value
    end

    local npcTranslationsSetting = Settings.RegisterProxySetting(category, "MULTILANGUAGE_NPC_TRANSLATIONS",
        Settings.VarType.Boolean, "Enable NPC translations", Settings.Default.True, GetNpcTranslationsValue, SetNpcTranslationsValue)
    Settings.CreateCheckbox(category, npcTranslationsSetting)

    -- Language Dropdown
    local function GetSelectedLanguageValue()
        return MultiLanguageOptions["SELECTED_LANGUAGE"]
    end

    local function SetSelectedLanguageValue(value)
        MultiLanguageOptions["SELECTED_LANGUAGE"] = value
        MultiLanguageOptionsAccount["SELECTED_LANGUAGE"] = value
    end

    local function GetLanguageOptions()
        local container = Settings.CreateControlTextContainer()
        for i, lang in ipairs(MultiLanguageOptions.AVAILABLE_LANGUAGES) do
            container:Add(lang.value, lang.text)
        end
        return container:GetData()
    end

    local languageSetting = Settings.RegisterProxySetting(category, "MULTILANGUAGE_SELECTED_LANGUAGE",
        Settings.VarType.String, "Language", Settings.Default.String("en"), GetSelectedLanguageValue, SetSelectedLanguageValue)
    Settings.CreateDropdown(category, languageSetting, GetLanguageOptions, "Select language:")

    -- Interaction Dropdown
    local function GetSelectedInteractionValue()
        return MultiLanguageOptions["SELECTED_INTERACTION"]
    end

    local function SetSelectedInteractionValue(value)
        MultiLanguageOptions["SELECTED_INTERACTION"] = value
        MultiLanguageOptionsAccount["SELECTED_INTERACTION"] = value
    end

    local function GetInteractionOptions()
        local container = Settings.CreateControlTextContainer()
        container:Add("hover", "Hover")
        container:Add("hover-hotkey", "Hover + hotkey")
        return container:GetData()
    end

    local interactionSetting = Settings.RegisterProxySetting(category, "MULTILANGUAGE_SELECTED_INTERACTION",
        Settings.VarType.String, "Interaction", Settings.Default.String("hover"), GetSelectedInteractionValue, SetSelectedInteractionValue)
    Settings.CreateDropdown(category, interactionSetting, GetInteractionOptions, "Select interaction:")

    -- Hotkey Frame
    local hotkeyFrame = CreateFrame("Frame")
    hotkeyFrame:SetHeight(60)

    local hotkeyDescription = hotkeyFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    hotkeyDescription:SetPoint("TOPLEFT", 0, 0)
    hotkeyDescription:SetText("Register Hotkey (right-click to unbind):")

    hotkeyButton = CreateFrame("Button", "MultiLanguageRegisterHotkeyButton", hotkeyFrame, "UIPanelButtonTemplate")
    hotkeyButton:SetWidth(120)
    hotkeyButton:SetHeight(25)
    hotkeyButton:SetPoint("TOPLEFT", hotkeyDescription, "TOPLEFT", 0, -18)

    if MultiLanguageOptions.SELECTED_HOTKEY then
        hotkeyButton:SetText(MultiLanguageOptions.SELECTED_HOTKEY)
    else
        hotkeyButton:SetText("Not Bound")
    end

    hotkeyButton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if not waitingForKey then
                waitingForKey = true
                hotkeyButton:SetText("Press button..")
            end
        elseif button == "RightButton" then
            waitingForKey = false
            hotkeyButton:SetText("Not Bound")
            MultiLanguageOptions.SELECTED_HOTKEY = nil
            MultiLanguageOptionsAccount.SELECTED_HOTKEY = nil
        end
    end)

    hotkeyButton:SetScript("OnKeyDown", function(self, key)
        if waitingForKey then
            MultiLanguageOptions.SELECTED_HOTKEY = key
            MultiLanguageOptionsAccount.SELECTED_HOTKEY = key
            hotkeyButton:SetText(MultiLanguageOptions.SELECTED_HOTKEY)
            waitingForKey = false
        end
    end)
    hotkeyButton:SetPropagateKeyboardInput(true)

    Settings.RegisterCanvasLayoutSubcategory(category, hotkeyFrame, "Hotkey")

    Settings.RegisterAddOnCategory(category)
end

local function addonLoaded(self, event, addonLoadedName)
    if addonLoadedName == addonName then
        InitializeOptions()
    end
end

optionsFrame:RegisterEvent("ADDON_LOADED")
optionsFrame:SetScript("OnEvent", addonLoaded)

-- Expose hotkey state for the main translation frame
function MultiLanguage_IsWaitingForKey()
    return waitingForKey
end

function MultiLanguage_SetWaitingForKey(value)
    waitingForKey = value
end

function MultiLanguage_GetHotkeyButton()
    return hotkeyButton
end
