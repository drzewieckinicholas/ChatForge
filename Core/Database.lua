--- @class Private
local Private = select(2, ...)

Private.Core = Private.Core or {}

local Database = {}

local ChatFrameUtils = Private.Utils.ChatFrame

local defaults = {
    border = {
        color = { 1, 1, 1, 1 },
        isEnabled = false,
        margin = 2,
        size = 12,
        texture = 'Interface\\DialogFrame\\UI-DialogBox-Border'
    },
    filter = {
        isCaseSensitive = false,
        isEnabled = false,
        isExactMatch = false,
        words = {}
    },
    font = {
        name = 'Fonts\\ARIALN.TTF',
        size = 14,
        style = ''
    }
}

function Database.GetChatFrameDefaults()
    return {
        border = defaults.border,
        filter = defaults.filter,
        font = defaults.font
    }
end

function Database.GetDefaults()
    local database = {
        profile = {
            frames = {},
            global = {}
        }
    }

    ChatFrameUtils:ForEachChatFrame(function(_, index)
        database.profile.frames[index] = Database.GetChatFrameDefaults()
    end)

    return database
end

Private.Core.Database = Database
