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
    local borderDatabase = DatabaseUtils.GetChatFramesTable(index, 'border')

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
                    return borderDatabase.isEnabled
                end,
                set = function(_, value)
                    borderDatabase.isEnabled = value

                    BorderModule:UpdateBorderIsEnabled(index, value)
                end
            },
            borderSettings = {
                order = 2,
                type = 'group',
                name = 'Border Settings',
                inline = true,
                disabled = function()
                    return not borderDatabase.isEnabled
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
                            return borderDatabase.texture
                        end,
                        set = function(_, value)
                            borderDatabase.texture = value

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
                            return borderDatabase.size
                        end,
                        set = function(_, value)
                            borderDatabase.size = value

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
                            return borderDatabase.margin
                        end,
                        set = function(_, value)
                            borderDatabase.margin = value

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
                            return borderDatabase.color[1],
                                borderDatabase.color[2],
                                borderDatabase.color[3],
                                borderDatabase.color[4]
                        end,
                        set = function(_, red, green, blue, alpha)
                            borderDatabase.color = { red, green, blue, alpha }

                            BorderModule:UpdateBorderColor(index, borderDatabase.color)
                        end
                    },
                    resetBorderColor = {
                        order = 5,
                        type = 'execute',
                        name = 'Reset Color',
                        desc = 'Reset border color to default.',
                        width = 'full',
                        func = function()
                            borderDatabase.color = { unpack(BorderConstants.Color.DEFAULT) }

                            BorderModule:UpdateBorderColor(index, borderDatabase.color)
                        end
                    }
                }
            }
        }
    }
end

Private.Options.Border = BorderOptions
