--- @class Private
local Private = select(2, ...)

Private.Options = Private.Options or {}

local FontOptions = {}

--- @class FontModule: AceModule
local FontModule = Private.Addon:GetModule('Font')

local FontConstants = Private.Constants.Font

local DatabaseUtils = Private.Utils.Database

--- @param chatFrame table
--- @param index number
function FontOptions:CreateOptionsTableForChatFrame(chatFrame, index)
    local fontDatabase = DatabaseUtils.GetChatFramesTable(index, 'font')

    return {
        order = 4,
        type = 'group',
        name = FontModule.moduleName,
        desc = 'Configure font appearance.',
        args = {
            fontSettings = {
                order = 1,
                type = 'group',
                name = 'Font Settings',
                inline = true,
                args = {
                    fontSize = {
                        order = 1,
                        type = 'range',
                        name = 'Font Size',
                        desc = 'Set font size.',
                        min = FontConstants.Size.MIN,
                        max = FontConstants.Size.MAX,
                        step = FontConstants.Size.STEP,
                        width = 'full',
                        get = function(_)
                            return fontDatabase.size
                        end,
                        set = function(_, value)
                            fontDatabase.size = value

                            FontModule:UpdateFont(chatFrame, { size = value })
                        end,
                    },
                    fontName = {
                        order = 2,
                        type = 'select',
                        name = 'Font Name',
                        desc = 'Set font name.',
                        values = FontConstants.Names,
                        width = 'full',
                        get = function(_)
                            return fontDatabase.name
                        end,
                        set = function(_, value)
                            fontDatabase.name = value

                            FontModule:UpdateFont(chatFrame, { name = value })
                        end,
                    },
                    fontStyle = {
                        order = 3,
                        type = 'select',
                        name = 'Font Style',
                        desc = 'Set font style.',
                        values = FontConstants.Styles,
                        width = 'full',
                        get = function(_)
                            return fontDatabase.style
                        end,
                        set = function(_, value)
                            fontDatabase.style = value

                            FontModule:UpdateFont(chatFrame, { style = value })
                        end,
                    },
                },
            },
        },
    }
end

Private.Options.Font = FontOptions
