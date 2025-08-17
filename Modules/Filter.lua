local table_insert = table.insert
local table_remove = table.remove

--- @class Private
local Private = select(2, ...)

--- @class FilterModule: AceModule
local FilterModule = Private.Addon:NewModule('Filter')

local FilterConstants = Private.Constants.Filter

local ChatFrameUtils = Private.Utils.ChatFrame
local DatabaseUtils = Private.Utils.Database
local FilterUtils = Private.Utils.Filter

local activeFilters = {}

--- Checks if a message should be filtered for a specific chat frame.
--- @param chatFrame table
--- @param message string
function FilterModule:ShouldFilterMessage(chatFrame, message)
    if not chatFrame or not message then
        return false
    end

    local chatFrameId = ChatFrameUtils:GetChatFrameId(chatFrame)
    local filterDatabase = DatabaseUtils.GetChatFramesTable(chatFrameId, 'filter')

    if not filterDatabase.isEnabled or #filterDatabase.words == 0 then
        return false
    end

    return FilterUtils:MessageContainsFilterWord({
        message = message,
        words = filterDatabase.words,
        isCaseSensitive = filterDatabase.isCaseSensitive,
        isExactMatch = filterDatabase.isExactMatch
    })
end

--- Adds a filter word to a chat frame's filter list.
--- @param chatFrame table
--- @param word string
function FilterModule:AddFilterWord(chatFrame, word)
    local normalizedWord = FilterUtils:NormalizeFilterWord(word)

    if not normalizedWord then
        return false, 'Invalid filter word'
    end

    local chatFrameId = ChatFrameUtils:GetChatFrameId(chatFrame)
    local filterDatabase = DatabaseUtils.GetChatFramesTable(chatFrameId, 'filter')

    if FilterUtils:FilterWordExists({
            word = normalizedWord,
            words = filterDatabase.words,
            isCaseSensitive = filterDatabase.isCaseSensitive
        }) then
        return false, 'Filter word already exists'
    end

    table_insert(filterDatabase.words, normalizedWord)

    return true
end

--- Removes a filter word from a chat frame's filter list.
--- @param chatFrame table
--- @param word string
function FilterModule:RemoveFilterWord(chatFrame, word)
    local chatFrameId = ChatFrameUtils:GetChatFrameId(chatFrame)
    local filterDatabase = DatabaseUtils.GetChatFramesTable(chatFrameId, 'filter')

    for index, filterWord in ipairs(filterDatabase.words) do
        if filterWord == word then
            table_remove(filterDatabase.words, index)

            return true
        end
    end

    return false
end

--- Clears all filter words for a chat frame.
--- @param chatFrame table
function FilterModule:ClearFilterWords(chatFrame)
    local chatFrameId = ChatFrameUtils:GetChatFrameId(chatFrame)
    local filterDatabase = DatabaseUtils.GetChatFramesTable(chatFrameId, 'filter')

    wipe(filterDatabase.words)
end

--- Creates a message filter function for a specific chat frame.
--- @param chatFrame table
local function createMessageFilter(chatFrame)
    return function(_, event, message, ...)
        if FilterModule:ShouldFilterMessage(chatFrame, message) then
            -- Hide message.
            return true
        end

        -- Show message.
        return false, message, ...
    end
end

--- Registers message filters for a chat frame.
--- @param chatFrame table
function FilterModule:RegisterFiltersForChatFrame(chatFrame)
    local chatFrameId = ChatFrameUtils:GetChatFrameId(chatFrame)

    -- Clean up existing filters if any.
    self:UnregisterFiltersForChatFrame(chatFrame)

    -- Create new filter function for this frame.
    local filterFunction = createMessageFilter(chatFrame)

    activeFilters[chatFrameId] = {}

    -- Register filter for each event.
    for _, event in ipairs(FilterConstants.Events) do
        ChatFrame_AddMessageEventFilter(event, filterFunction)
        activeFilters[chatFrameId][event] = filterFunction
    end
end

--- Unregisters message filters for a chat frame.
--- @param chatFrame table
function FilterModule:UnregisterFiltersForChatFrame(chatFrame)
    local chatFrameId = ChatFrameUtils:GetChatFrameId(chatFrame)
    local filters = activeFilters[chatFrameId]

    if not filters then
        return
    end

    -- Remove each registered filter.
    for event, filterFunction in pairs(filters) do
        ChatFrame_RemoveMessageEventFilter(event, filterFunction)
    end

    activeFilters[chatFrameId] = nil
end

--- Updates filter state for a chat frame.
--- @param chatFrame table
function FilterModule:UpdateFilterState(chatFrame)
    local chatFrameId = ChatFrameUtils:GetChatFrameId(chatFrame)
    local filterDatabase = DatabaseUtils.GetChatFramesTable(chatFrameId, 'filter')

    if filterDatabase.isEnabled then
        self:RegisterFiltersForChatFrame(chatFrame)
    else
        self:UnregisterFiltersForChatFrame(chatFrame)
    end
end

function FilterModule:OnEnable()
    -- Register filters for all chat frames.
    ChatFrameUtils:ForEachChatFrame(function(chatFrame)
        self:UpdateFilterState(chatFrame)
    end)
end

function FilterModule:OnDisable()
    -- Unregister all filters.
    ChatFrameUtils:ForEachChatFrame(function(chatFrame)
        self:UnregisterFiltersForChatFrame(chatFrame)
    end)

    wipe(activeFilters)
end
