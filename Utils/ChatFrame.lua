--- @class Private
local Private = select(2, ...)

Private.Utils = Private.Utils or {}

local ChatFrameUtils = {}

local chatFrameCache = {}
local chatTabCache = {}
local isCacheInitialized = false

local CHAT_FRAME_PREFIX = 'ChatFrame'
local CHAT_TAB_SUFFIX = 'Tab'

--- Initializes the chat frame and tab caches.
function ChatFrameUtils:InitializeCaches()
    if isCacheInitialized then
        return true
    end

    wipe(chatFrameCache)
    wipe(chatTabCache)

    for index = 1, NUM_CHAT_WINDOWS do
        local frameName = CHAT_FRAME_PREFIX .. index
        local frame = _G[frameName]

        if frame then
            chatFrameCache[index] = frame

            local tabName = frameName .. CHAT_TAB_SUFFIX

            chatTabCache[index] = _G[tabName]
        end
    end

    isCacheInitialized = true

    return true
end

--- Checks if the caches have been initialized.
function ChatFrameUtils:IsCacheInitialized()
    return isCacheInitialized
end

--- Ensures the caches are initialized before use.
--- @return nil
function ChatFrameUtils:EnsureCacheInitialized()
    if not isCacheInitialized then
        self:InitializeCaches()
    end
end

--- Executes a callback function for each chat frame.
--- @param callback function
--- @return nil
function ChatFrameUtils:ForEachChatFrame(callback)
    self:EnsureCacheInitialized()

    for index = 1, NUM_CHAT_WINDOWS do
        local chatFrame = chatFrameCache[index]

        if chatFrame then
            callback(chatFrame, index)
        end
    end
end

--- Retrieves a chat frame by its index.
--- @param index number
--- @return table|nil
function ChatFrameUtils:GetChatFrame(index)
    self:EnsureCacheInitialized()

    return chatFrameCache[index]
end

--- Retrieves the ID of a chat frame.
--- @param chatFrame table
--- @return number
function ChatFrameUtils:GetChatFrameId(chatFrame)
    return chatFrame:GetID()
end

--- Retrieves the name of a chat frame.
--- @param chatFrame table
--- @return string
function ChatFrameUtils:GetChatFrameName(chatFrame)
    return chatFrame:GetName()
end

--- Retrieves the tab associated with a chat frame.
--- @param chatFrame table
--- @return table|nil
function ChatFrameUtils:GetChatTab(chatFrame)
    self:EnsureCacheInitialized()

    local chatFrameId = chatFrame:GetID()

    return chatTabCache[chatFrameId]
end

--- Retrieves the text displayed on a chat frame's tab.
--- @param chatFrame table
--- @return string|nil
function ChatFrameUtils:GetChatTabName(chatFrame)
    self:EnsureCacheInitialized()

    local chatFrameId = chatFrame:GetID()
    local chatTab = chatTabCache[chatFrameId]

    return chatTab and chatTab:GetText() or nil
end

Private.Utils.ChatFrame = ChatFrameUtils
