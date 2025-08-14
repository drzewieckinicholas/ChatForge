--- @class Private
local Private = select(2, ...)

Private.Utils = Private.Utils or {}

local ChatFrameUtils = {}

local chatFrameCache = {}
local chatTabCache = {}
local isCacheInitialized = false

local CHAT_FRAME_PREFIX = 'ChatFrame'
local CHAT_TAB_SUFFIX = 'Tab'

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

function ChatFrameUtils:IsCacheInitialized()
    return isCacheInitialized
end

--- @return nil
function ChatFrameUtils:EnsureCacheInitialized()
    if not isCacheInitialized then
        self:InitializeCaches()
    end
end

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

--- @param index number
--- @return table?
function ChatFrameUtils:GetChatFrame(index)
    self:EnsureCacheInitialized()

    return chatFrameCache[index]
end

--- @param chatFrame table
--- @return number
function ChatFrameUtils:GetChatFrameId(chatFrame)
    return chatFrame:GetID()
end

--- @param chatFrame table
--- @return string
function ChatFrameUtils:GetChatFrameName(chatFrame)
    return chatFrame:GetName()
end

--- @param chatFrame table
--- @return table?
function ChatFrameUtils:GetChatTab(chatFrame)
    self:EnsureCacheInitialized()

    local chatFrameId = chatFrame:GetID()

    return chatTabCache[chatFrameId]
end

--- @param chatFrame table
--- @return string?
function ChatFrameUtils:GetChatTabName(chatFrame)
    self:EnsureCacheInitialized()

    local chatFrameId = chatFrame:GetID()
    local chatTab = chatTabCache[chatFrameId]

    return chatTab and chatTab:GetText() or nil
end

Private.Utils.ChatFrame = ChatFrameUtils
