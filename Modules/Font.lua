--- @class Private
local Private = select(2, ...)

--- @class FontModule: AceModule
local FontModule = Private.Addon:NewModule('Font')

local ChatFrameUtils = Private.Utils.ChatFrame
local DatabaseUtils = Private.Utils.Database

local ERROR_MESSAGES = {
    CHATFRAME_TYPE = 'Expected chatFrame to be a table, got %s',
    FONTNAME_TYPE = 'Expected fontName to be a string, got %s',
    FONTSIZE_TYPE = 'Expected fontSize to be a number, got %s',
    FONTSTYLE_TYPE = 'Expected fontStyle to be a string, got %s'
}

--- @class FontOptions
--- @field name string?
--- @field size number?
--- @field style string?

--- @param chatFrame table
--- @param fontOptions? FontOptions
function FontModule:UpdateFont(chatFrame, fontOptions)
    assert(type(chatFrame) == 'table', ERROR_MESSAGES.CHATFRAME_TYPE:format(type(chatFrame)))

    if not fontOptions then
        fontOptions = {}
    end

    local fontName = fontOptions.name
    local fontSize = fontOptions.size
    local fontStyle = fontOptions.style

    if not fontName or not fontSize or not fontStyle then
        local chatFrameId = ChatFrameUtils:GetChatFrameId(chatFrame)
        local databaseFont = DatabaseUtils.GetChatFramesTable(chatFrameId, 'font')

        fontName = fontName or databaseFont.name
        fontSize = fontSize or databaseFont.size
        fontStyle = fontStyle or databaseFont.style
    end

    assert(type(fontName) == 'string', ERROR_MESSAGES.FONTNAME_TYPE:format(type(fontName)))
    assert(type(fontSize) == 'number', ERROR_MESSAGES.FONTSIZE_TYPE:format(type(fontSize)))
    assert(type(fontStyle) == 'string', ERROR_MESSAGES.FONTSTYLE_TYPE:format(type(fontStyle)))

    chatFrame:SetFont(fontName, fontSize, fontStyle)
end

function FontModule:OnEnable()
    ChatFrameUtils:ForEachChatFrame(function(chatFrame)
        self:UpdateFont(chatFrame)
    end)
end
