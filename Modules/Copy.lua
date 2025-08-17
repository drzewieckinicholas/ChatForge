--- @diagnostic disable: undefined-field

local string_format = string.format
local table_concat = table.concat
local table_insert = table.insert
local type = type

local AceGUI = LibStub('AceGUI-3.0')

--- @type string
local AddonName = select(1, ...)

--- @class Private
local Private = select(2, ...)

--- @class CopyModule: AceModule
local CopyModule = Private.Addon:NewModule('Copy')

local CopyConstants = Private.Constants.Copy

local ChatFrameUtils = Private.Utils.ChatFrame
local ColorUtils = Private.Utils.Color
local DatabaseUtils = Private.Utils.Database
local MessageUtils = Private.Utils.Message

local ERROR_MESSAGES = {
    CHATFRAME_NIL = 'Chat frame cannot be nil',
    COUNT_TYPE = 'Expected messageCount to be a number, got %s',
    ENABLED_TYPE = 'Expected isEnabled to be a boolean, got %s',
    INDEX_TYPE = 'Expected index to be a number, got %s'
}

local activeDialogs = {}

--- Creates a unique key for dialog tracking.
--- @param chatFrameId number
--- @return string
local function getDialogKey(chatFrameId)
    return 'chatFrame' .. chatFrameId
end

--- Builds formatted text from chat messages.
--- @param chatFrame table
--- @param maxMessageCount number
--- @return string
local function buildFormattedMessagesText(chatFrame, maxMessageCount)
    local collectedMessages = {}
    local messageCount = 0

    ChatFrameUtils:ForEachChatFrameMessage(chatFrame, function(text, red, green, blue)
        if messageCount >= maxMessageCount then
            return false
        end

        if not MessageUtils:IsMessageProtected(text) then
            local hexColor = ColorUtils:ConvertRGBToHex(red, green, blue)
            local formattedMessage = hexColor .. text .. '|r'

            table_insert(collectedMessages, formattedMessage)

            messageCount = messageCount + 1
        end
    end)

    if #collectedMessages == 0 then
        return 'No messages to copy.'
    end

    return table_concat(collectedMessages, '\n')
end

--- Focuses and selects all text in the edit box.
--- @param editBoxWidget table
--- @param textContent string
local function focusAndSelectText(editBoxWidget, textContent)
    if not editBoxWidget or not editBoxWidget.editBox then
        return
    end

    local nativeEditBox = editBoxWidget.editBox

    nativeEditBox:SetCursorPosition(#textContent)
    nativeEditBox:HighlightText()
    nativeEditBox:SetFocus()
end

--- Handles dialog close event.
--- @param dialogKey string
local function handleDialogClose(dialogKey)
    local dialogData = activeDialogs[dialogKey]

    if not dialogData then
        return
    end

    if dialogData.frame then
        AceGUI:Release(dialogData.frame)
    end

    activeDialogs[dialogKey] = nil
end

--- Prevents edit box text modification.
--- @param widget table
--- @param expectedText string
local function handleTextChanged(widget, expectedText)
    local currentText = widget:GetText()

    if currentText ~= expectedText then
        widget:SetText(expectedText)
        widget:SetCursorPosition(#expectedText)
    end
end

--- Creates the copy dialog frame.
--- @return table
local function createDialogFrame()
    --- @class AceGUIFrame : AceGUIContainer
    local frame = AceGUI:Create('Frame')

    frame:SetTitle(string_format('%s - Copy', AddonName))
    frame:SetWidth(CopyConstants.Dialog.WIDTH)
    frame:SetHeight(CopyConstants.Dialog.HEIGHT)
    frame:SetLayout(CopyConstants.Dialog.LAYOUT)
    frame:EnableResize(false)

    frame.frame:SetClampedToScreen(true)
    -- So it does not cover the Main Menu.
    frame.frame:SetFrameStrata(CopyConstants.Dialog.FRAME_STRATA)

    return frame
end

--- Creates the multi-line edit box.
--- @return table
local function createMultiLineEditBox()
    --- @class AceGUIMultiLineEditBox : AceGUIWidget
    local editBox = AceGUI:Create('MultiLineEditBox')

    editBox:SetLabel('')
    editBox:SetFullWidth(true)
    editBox:SetFullHeight(true)
    editBox:DisableButton(true)

    return editBox
end

--- Shows the copy dialog for a chat frame.
--- @param chatFrame table
function CopyModule:ShowCopyDialog(chatFrame)
    assert(chatFrame, ERROR_MESSAGES.CHATFRAME_NIL)

    local chatFrameId = ChatFrameUtils:GetChatFrameId(chatFrame)
    local dialogKey = getDialogKey(chatFrameId)

    if activeDialogs[dialogKey] then
        handleDialogClose(dialogKey)
    end

    local databaseCopy = DatabaseUtils.GetChatFramesTable(chatFrameId, 'copy')
    local messageCount = databaseCopy.messageCount or CopyConstants.Messages.DEFAULT_COUNT

    local messagesText = buildFormattedMessagesText(chatFrame, messageCount)

    local dialogFrame = createDialogFrame()
    local editBox = createMultiLineEditBox()

    activeDialogs[dialogKey] = {
        frame = dialogFrame,
        editBox = editBox,
        text = messagesText
    }

    dialogFrame:SetCallback('OnClose', function()
        handleDialogClose(dialogKey)
    end)

    editBox:SetCallback('OnTextChanged', function(widget)
        handleTextChanged(widget, messagesText)
    end)

    editBox:SetText(messagesText)
    dialogFrame:AddChild(editBox)
    dialogFrame:Show()

    -- Ensures the edit box is fully rendered to reliably scroll to the bottom.
    C_Timer.After(0.1, function()
        if activeDialogs[dialogKey] and activeDialogs[dialogKey].editBox then
            focusAndSelectText(activeDialogs[dialogKey].editBox, messagesText)
        end
    end)
end

--- Updates the enabled state for a chat frame.
--- @param index number
--- @param isEnabled boolean
function CopyModule:UpdateCopyIsEnabled(index, isEnabled)
    assert(type(index) == 'number', string_format(ERROR_MESSAGES.INDEX_TYPE, type(index)))
    assert(type(isEnabled) == 'boolean', string_format(ERROR_MESSAGES.ENABLED_TYPE, type(isEnabled)))

    local databaseCopy = DatabaseUtils.GetChatFramesTable(index, 'copy')

    databaseCopy.isEnabled = isEnabled
end

--- Updates the message count for a chat frame.
--- @param index number
--- @param messageCount number
function CopyModule:UpdateMessageCount(index, messageCount)
    assert(type(index) == 'number', string_format(ERROR_MESSAGES.INDEX_TYPE, type(index)))
    assert(type(messageCount) == 'number', string_format(ERROR_MESSAGES.COUNT_TYPE, type(messageCount)))

    local databaseCopy = DatabaseUtils.GetChatFramesTable(index, 'copy')

    databaseCopy.messageCount = messageCount
end

function CopyModule:OnDisable()
    -- Clean up all active dialogs.
    for dialogKey in pairs(activeDialogs) do
        handleDialogClose(dialogKey)
    end
end
