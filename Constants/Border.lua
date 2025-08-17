--- @class Private
local Private = select(2, ...)

Private.Constants = Private.Constants or {}

Private.Constants.Border = {
    Color = {
        DEFAULT = { 1, 1, 1, 1 }
    },
    Margin = {
        MAX = 8,
        MIN = 0,
        STEP = 0.5
    },
    Size = {
        DEFAULT = 12,
        MAX = 16,
        MIN = 8,
        STEP = 1
    },
    Textures = {
        ['Interface\\DialogFrame\\UI-DialogBox-Border'] = 'Blizzard Dialog',
        ['Interface\\Tooltips\\UI-Tooltip-Border'] = 'Blizzard Tooltip'
    }
}
