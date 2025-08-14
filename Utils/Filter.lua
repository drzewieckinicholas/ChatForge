--- @class Private
local Private = select(2, ...)

Private.Utils = Private.Utils or {}

local FilterUtils = {}

local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local string_lower = string.lower
local type = type

local ERROR_MESSAGES = {
    MESSAGE_TYPE = 'Expected options.message to be a string, got %s',
    WORD_TYPE = 'Expected options.word to be a string, got %s',
    WORDS_TYPE = 'Expected options.words to be a table, got %s',
    MISSING_MESSAGE = 'options.message is required',
    MISSING_WORD = 'options.word is required',
    MISSING_WORDS = 'options.words is required'
}

--- Escapes special pattern characters in a string.
--- @param text string
local function escapePattern(text)
    return string_gsub(text, '[%(%)%.%%%+%-%*%?%[%]%^%$]', '%%%1')
end

--- Creates a word boundary pattern for exact matching.
--- @param word string
local function createWordBoundaryPattern(word)
    local escapedWord = escapePattern(word)

    return string_format('%%f[%%a]%s%%f[%%A]', escapedWord)
end

--- @class MessageContainsFilterWordOptions
--- @field message string
--- @field words table
--- @field caseSensitive? boolean
--- @field exactMatch? boolean

--- Checks if a message contains any of the filter words.
--- @param options MessageContainsFilterWordOptions
function FilterUtils:MessageContainsFilterWord(options)
    assert(options.message, ERROR_MESSAGES.MISSING_MESSAGE)
    assert(options.words, ERROR_MESSAGES.MISSING_WORDS)

    local wordCount = #options.words

    if wordCount == 0 then
        return false
    end

    assert(type(options.message) == 'string', ERROR_MESSAGES.MESSAGE_TYPE:format(type(options.message)))
    assert(type(options.words) == 'table', ERROR_MESSAGES.WORDS_TYPE:format(type(options.words)))

    local messageToCheck = self:NormalizeFilterWord(options.message)

    if not messageToCheck then
        return false
    end

    local caseSensitive = options.caseSensitive or false
    local exactMatch = options.exactMatch or false

    if not caseSensitive then
        messageToCheck = string_lower(messageToCheck)
    end

    if exactMatch then
        for i = 1, wordCount do
            local filterWord = options.words[i]
            local wordToCheck = caseSensitive and filterWord or string_lower(filterWord)
            local pattern = createWordBoundaryPattern(wordToCheck)

            if string_find(messageToCheck, pattern) then
                return true
            end
        end
    else
        for i = 1, wordCount do
            local filterWord = options.words[i]
            local wordToCheck = caseSensitive and filterWord or string_lower(filterWord)

            if string_find(messageToCheck, wordToCheck, 1, true) then
                return true
            end
        end
    end

    return false
end

--- Normalizes a filter word by removing punctuation and whitespace.
--- @param word string
function FilterUtils:NormalizeFilterWord(word)
    if type(word) ~= 'string' then
        return nil
    end

    -- Trim punctuation and whitespace.
    word = string_gsub(word, '[%p%s]', '')

    return word ~= '' and word or nil
end

--- @class FilterWordExistsOptions
--- @field word string
--- @field words table
--- @field caseSensitive? boolean

--- Checks if a filter word already exists in the list.
--- @param options FilterWordExistsOptions
function FilterUtils:FilterWordExists(options)
    assert(options.word, ERROR_MESSAGES.MISSING_WORD)
    assert(options.words, ERROR_MESSAGES.MISSING_WORDS)
    assert(type(options.word) == 'string', ERROR_MESSAGES.WORD_TYPE:format(type(options.word)))
    assert(type(options.words) == 'table', ERROR_MESSAGES.WORDS_TYPE:format(type(options.words)))

    local caseSensitive = options.caseSensitive or false
    local wordToCheck = caseSensitive and options.word or string_lower(options.word)

    local wordCount = #options.words

    for i = 1, wordCount do
        local existingWord = options.words[i]
        local existingWordToCheck = caseSensitive and existingWord or string_lower(existingWord)

        if wordToCheck == existingWordToCheck then
            return true
        end
    end

    return false
end

Private.Utils.Filter = FilterUtils
