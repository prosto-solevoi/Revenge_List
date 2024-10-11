DeathNotebookDB = DeathNotebookDB or {}
local isOpen = false



local function AddDeathRecord(playerName, faction, reason)
    table.insert(DeathNotebookDB, {
        playerName = playerName,
        faction = faction,
        reason = reason
    })
end

local function OnAddonLoaded(self, event, addonName)
    if addonName == "DeathNotebook" then
        local f = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
        f:SetSize(280, 360)
        f:SetPoint("CENTER")
        f.title = f:CreateFontString(nil, "OVERLAY")
        f.title:SetFontObject("GameFontHighlight")
        f.title:SetPoint("CENTER", f.TitleBg, "CENTER", 0, 0)
        f.title:SetText("Death Notebook")

        local playerLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        playerLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -40)
        playerLabel:SetText("Player Name")

        local playerInput = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
        playerInput:SetSize(200, 20)
        playerInput:SetPoint("TOPLEFT", playerLabel, "BOTTOMLEFT", 0, -10)
        playerInput:SetAutoFocus(false)

        local factionLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        factionLabel:SetPoint("TOPLEFT", playerInput, "BOTTOMLEFT", 0, -20)
        factionLabel:SetText("Faction")

        local factions = {"Horde", "Alliance", "Renegades"}
        local factionDropdown = CreateFrame("Frame", "FactionDropdown", f, "UIDropDownMenuTemplate")
        factionDropdown:SetPoint("TOPLEFT", factionLabel, "BOTTOMLEFT", -16, -10)
        UIDropDownMenu_SetWidth(factionDropdown, 160)

        UIDropDownMenu_Initialize(factionDropdown, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            for _, faction in ipairs(factions) do
                info.text = faction
                info.checked = false
                info.menuList = faction
                info.func = function()
                    UIDropDownMenu_SetSelectedName(factionDropdown, faction)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        

        local reasonLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        reasonLabel:SetPoint("TOPLEFT", factionDropdown, "BOTTOMLEFT", 16, -20)
        reasonLabel:SetText("Reason")

        local reasonInput = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
        reasonInput:SetSize(200, 20)
        reasonInput:SetPoint("TOPLEFT", reasonLabel, "BOTTOMLEFT", 0, -10)
        reasonInput:SetAutoFocus(false)

        local saveButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        saveButton:SetSize(80, 22)
        saveButton:SetPoint("TOPRIGHT", reasonInput, "BOTTOMRIGHT", 0, -10)
        saveButton:SetText("Сохранить")
        saveButton:SetScript("OnClick", function()
            local playerName = playerInput:GetText()
            local selectedFaction = factions[UIDropDownMenu_GetSelectedID(factionDropdown)]
            local reasonText = reasonInput:GetText()

            if playerName ~= "" and selectedFaction ~= nil and reasonText ~= "" then
                AddDeathRecord(playerName, selectedFaction, reasonText)
                print("Данные сохранены для игрока " .. playerName)
                playerInput:SetText("")
                reasonInput:SetText("")
                UIDropDownMenu_SetSelectedID(factionDropdown, nil)
            else
                print("Проверьте заполненные данные!")
            end
        end)

        local exportButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")

        exportButton:SetSize(80, 22)
        exportButton:SetPoint("TOPLEFT", saveButton, "BOTTOMLEFT", 0, -10)
        exportButton:SetText("Экспорт")
        exportButton:SetScript("OnClick", function()
            if #DeathNotebookDB == 0 then
                print("Данные отсутствуют")
            else
                local exportString = ""
                for _, record in ipairs(DeathNotebookDB) do
                     exportString = exportString .. "!#234   " .. (record.playerName or "unknown") .. " - " .. (record.faction or "unknown") .. " - " .. (record.reason or "unknown") .. "\n"
                end
                print(exportString)
            end
        end)

        local clearButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        clearButton:SetSize(80, 22)
        clearButton:SetPoint("TOPLEFT", exportButton, "BOTTOMLEFT", 0, -10)
        clearButton:SetText("Очистить")
        clearButton:SetScript("OnClick", function()
            if #DeathNotebookDB == 0 then
                print("данных нет, отъ*бись!!!")
            else
                DeathNotebookDB = {}
                print("Данные очищены")
            end
        end)

        self.f = f -- Сохранение фрейма в глобальное поле self (фрейм события)
        SLASH_DEATHNOTEBOOK1 = "/notebook"
        SlashCmdList["DEATHNOTEBOOK"] = function()
            if isOpen then
                f:Hide()
            else
                f:Show()
            end
            isOpen = not isOpen
        end
        
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnAddonLoaded)




--code key: "!#234   "