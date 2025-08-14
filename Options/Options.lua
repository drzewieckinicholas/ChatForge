local AceConfig = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

--- @type string
local AddonName = select(1, ...)

--- @class Private
local Private = select(2, ...)

local Options = {}

local FilterOptions = Private.Options.Filter
local FontOptions = Private.Options.Font

local ChatFrameUtils = Private.Utils.ChatFrame

--- @param chatFrame table
--- @param index number
local function createOptionsTableForChatFrame(chatFrame, index)
    return {
        filter = FilterOptions:CreateOptionsTableForChatFrame(chatFrame, index),
        font = FontOptions:CreateOptionsTableForChatFrame(chatFrame, index)
    }
end

local function createOptionsTable()
    local options = {
        type = 'group',
        name = AddonName,
        args = {
            frames = {
                order = 1,
                type = 'group',
                name = 'Chat Frames',
                desc = 'Lorem ipsum dolor sit amet',
                args = {},
            },
        },
    }

    ChatFrameUtils:ForEachChatFrame(function(chatFrame, index)
        local chatFrameName = ChatFrameUtils:GetChatFrameName(chatFrame)
        local chatTabName = ChatFrameUtils:GetChatTabName(chatFrame)

        options.args.frames.args[chatFrameName] = {
            order = index,
            type = 'group',
            name = chatTabName,
            args = createOptionsTableForChatFrame(chatFrame, index),
        }
    end)

    return options
end

function Options:Initialize()
    AceConfig:RegisterOptionsTable(AddonName, createOptionsTable())
    AceConfigDialog:AddToBlizOptions(AddonName, AddonName)
end

Private.Options = Options
