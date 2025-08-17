--- @class Private
local Private = select(2, ...)

Private.Options = Private.Options or {}

local BorderOptions = {}

--- @class BorderModule: AceModule
local BorderModule = Private.Addon:GetModule('Border')

local BorderConstants = Private.Constants.Border
local DatabaseUtils = Private.Utils.Database

--- @param chatFrame table
--- @param index number
function BorderOptions:CreateOptionsTableForChatFrame(chatFrame, index)
    local databaseBorder = DatabaseUtils.GetChatFramesTable(index, 'border')

    return {
        order = 1,
        type = 'group',
        name = BorderModule.moduleName,
        desc = 'Configure border appearance.',
        args = {
            enableBorder = {
                order = 1,
                type = 'toggle',
                name = 'Enable Border',
                desc = 'Enable border for this chat frame.',
                width = 'full',
                get = function()
                    return databaseBorder.isEnabled
                end,
                set = function(_, value)
                    databaseBorder.isEnabled = value

                    BorderModule:UpdateBorderIsEnabled(index, value)
                end
            },
            borderSettings = {
                order = 2,
                type = 'group',
                name = 'Border Settings',
                inline = true,
                disabled = function()
                    return not databaseBorder.isEnabled
                end,
                args = {
                    borderTexture = {
                        order = 1,
                        type = 'select',
                        name = 'Border Style',
                        desc = 'Select the border texture style.',
                        values = BorderConstants.Textures,
                        width = 'full',
                        get = function()
                            return databaseBorder.texture
                        end,
                        set = function(_, value)
                            databaseBorder.texture = value

                            BorderModule:UpdateBorderTexture(index, value)
                        end
                    },
                    borderSize = {
                        order = 2,
                        type = 'range',
                        name = 'Border Size',
                        desc = 'Set the thickness of the border.',
                        min = BorderConstants.Size.MIN,
                        max = BorderConstants.Size.MAX,
                        step = BorderConstants.Size.STEP,
                        width = 'full',
                        get = function()
                            return databaseBorder.size
                        end,
                        set = function(_, value)
                            databaseBorder.size = value

                            BorderModule:UpdateBorderSize(index, value)
                        end
                    },
                    borderMargin = {
                        order = 3,
                        type = 'range',
                        name = 'Border Margin',
                        desc = 'Set the distance between the border and chat frame.',
                        min = BorderConstants.Margin.MIN,
                        max = BorderConstants.Margin.MAX,
                        step = BorderConstants.Margin.STEP,
                        width = 'full',
                        get = function()
                            return databaseBorder.margin
                        end,
                        set = function(_, value)
                            databaseBorder.margin = value

                            BorderModule:UpdateBorderMargin(index, value)
                        end
                    },
                    borderColor = {
                        order = 4,
                        type = 'color',
                        name = 'Border Color',
                        desc = 'Set the border color.',
                        hasAlpha = true,
                        width = 'full',
                        get = function()
                            return databaseBorder.color[1],
                                databaseBorder.color[2],
                                databaseBorder.color[3],
                                databaseBorder.color[4]
                        end,
                        set = function(_, red, green, blue, alpha)
                            databaseBorder.color = { red, green, blue, alpha }

                            BorderModule:UpdateBorderColor(index, databaseBorder.color)
                        end
                    },
                    resetBorderColor = {
                        order = 5,
                        type = 'execute',
                        name = 'Reset Color',
                        desc = 'Reset border color to default.',
                        width = 'full',
                        func = function()
                            databaseBorder.color = { unpack(BorderConstants.Color.DEFAULT) }

                            BorderModule:UpdateBorderColor(index, databaseBorder.color)
                        end
                    }
                }
            }
        }
    }
end

Private.Options.Border = BorderOptions
