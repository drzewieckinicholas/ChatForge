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
--- @return table
function FontOptions:CreateOptionsTableForChatFrame(chatFrame, index)
    local databaseFont = DatabaseUtils.GetChatFramesTable(index, 'font')

    return {
        order = 1,
        type = 'group',
        name = FontModule.moduleName,
        desc = 'Adjust font settings.',
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
                            return databaseFont.size
                        end,
                        set = function(_, value)
                            databaseFont.size = value

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
                            return databaseFont.name
                        end,
                        set = function(_, value)
                            databaseFont.name = value

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
                            return databaseFont.style
                        end,
                        set = function(_, value)
                            databaseFont.style = value

                            FontModule:UpdateFont(chatFrame, { style = value })
                        end,
                    },
                },
            },
        },
    }
end

Private.Options.Font = FontOptions
