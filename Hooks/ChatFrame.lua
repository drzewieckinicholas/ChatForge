local string_format = string.format

local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')

--- @type string
local AddonName = select(1, ...)

--- @class Private
local Private = select(2, ...)

Private.Hooks = Private.Hooks or {}

local ChatFrameHooks = {}

--- @class CopyModule: AceModule
local CopyModule = Private.Addon:GetModule('Copy')

--- @class FontModule: AceModule
local FontModule = Private.Addon:GetModule('Font')

local ChatFrameUtils = Private.Utils.ChatFrame
local DatabaseUtils = Private.Utils.Database

local ERROR_MESSAGE_FONTSIZE_TYPE = 'Expected fontSize to be a number, got %s'

--- Handles font size changes from the UI.
--- @param self table
--- @param chatFrame? table
--- @param fontSize? number
local function handleSetChatWindowFontSize(self, chatFrame, fontSize)
	chatFrame = chatFrame or FCF_GetCurrentChatFrame()
	fontSize = fontSize or self.value

	assert(type(fontSize) == 'number', ERROR_MESSAGE_FONTSIZE_TYPE:format(type(fontSize)))

	local chatFrameId = ChatFrameUtils:GetChatFrameId(chatFrame)
	local fontDatabase = DatabaseUtils.GetChatFramesTable(chatFrameId, 'font')

	fontDatabase.size = fontSize

	FontModule:UpdateFont(chatFrame, { size = fontSize })

	AceConfigRegistry:NotifyChange(AddonName)
end

--- Handles chat tab clicks for the copy feature.
--- @param chatTab table
--- @param button string
local function handleTabOnClick(chatTab, button)
	if button ~= 'LeftButton' or not IsControlKeyDown() then
		return
	end

	local chatFrameId = chatTab:GetID()
	local chatFrame = ChatFrameUtils:GetChatFrame(chatFrameId)

	if not chatFrame then
		return
	end

	local chatTabName = ChatFrameUtils:GetChatTabName(chatFrame)
	local copyDatabase = DatabaseUtils.GetChatFramesTable(chatFrameId, 'copy')

	if copyDatabase.isEnabled then
		CopyModule:ShowCopyDialog(chatFrame)
	else
		chatFrame:AddMessage(
			string_format('%s: Copy is disabled for %s. Enable it in the addon options.', AddonName, chatTabName)
		)
	end
end

function ChatFrameHooks:Initialize()
	hooksecurefunc('FCF_SetChatWindowFontSize', handleSetChatWindowFontSize)
	hooksecurefunc('FCF_Tab_OnClick', handleTabOnClick)
end

Private.Hooks.ChatFrame = ChatFrameHooks
