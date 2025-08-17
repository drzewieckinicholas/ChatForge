--- @class Private
local Private = select(2, ...)

Private.Options = Private.Options or {}

local CopyOptions = {}

--- @class CopyModule: AceModule
local CopyModule = Private.Addon:GetModule('Copy')

local CopyConstants = Private.Constants.Copy
local DatabaseUtils = Private.Utils.Database

--- @param chatFrame table
--- @param index number
function CopyOptions:CreateOptionsTableForChatFrame(chatFrame, index)
    local databaseCopy = DatabaseUtils.GetChatFramesTable(index, 'copy')

    return {
        order = 2,
        type = 'group',
        name = CopyModule.moduleName,
        desc = 'Configure message copying.',
        args = {
            enableCopy = {
                order = 1,
                type = 'toggle',
                name = 'Enable Copy',
                desc =
                'Enable copying messages from this chat frame.\n\nCtrl + left-click on the chat tab to open the copy dialog.',
                width = 'full',
                get = function()
                    return databaseCopy.isEnabled
                end,
                set = function(_, value)
                    databaseCopy.isEnabled = value

                    CopyModule:UpdateCopyIsEnabled(index, value)
                end
            },
            copySettings = {
                order = 2,
                type = 'group',
                name = 'Copy Settings',
                inline = true,
                disabled = function()
                    return not databaseCopy.isEnabled
                end,
                args = {
                    messageCount = {
                        order = 1,
                        type = 'range',
                        name = 'Message Count',
                        desc = 'Maximum number of recent messages to include for copying.',
                        min = CopyConstants.Messages.MIN_COUNT,
                        max = CopyConstants.Messages.MAX_COUNT,
                        step = CopyConstants.Messages.STEP,
                        width = 'full',
                        get = function()
                            return databaseCopy.messageCount
                        end,
                        set = function(_, value)
                            databaseCopy.messageCount = value

                            CopyModule:UpdateMessageCount(index, value)
                        end
                    },
                }
            }
        }
    }
end

Private.Options.Copy = CopyOptions
