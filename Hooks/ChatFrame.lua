local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')

--- @type string
local AddonName = select(1, ...)

--- @class Private
local Private = select(2, ...)

Private.Hooks = Private.Hooks or {}

local ChatFrameHooks = {}

--- @class FontModule: AceModule
local FontModule = Private.Addon:GetModule('Font')

local ChatFrameUtils = Private.Utils.ChatFrame
local DatabaseUtils = Private.Utils.Database

local ERROR_MESSAGE_FONTSIZE_TYPE = 'Expected fontSize to be a number, got %s'

--- @param self table
--- @param chatFrame? table
--- @param fontSize? number
local function handleSetChatWindowFontSize(self, chatFrame, fontSize)
	chatFrame = chatFrame or FCF_GetCurrentChatFrame()
	fontSize = fontSize or self.value

	assert(type(fontSize) == 'number', ERROR_MESSAGE_FONTSIZE_TYPE:format(type(fontSize)))

	local chatFrameId = ChatFrameUtils:GetChatFrameId(chatFrame)
	local databaseFont = DatabaseUtils.GetChatFramesTable(chatFrameId, 'font')

	databaseFont.size = fontSize

	FontModule:UpdateFont(chatFrame, { size = fontSize })

	AceConfigRegistry:NotifyChange(AddonName)
end

function ChatFrameHooks:Initialize()
	hooksecurefunc('FCF_SetChatWindowFontSize', handleSetChatWindowFontSize)
end

Private.Hooks.ChatFrame = ChatFrameHooks
