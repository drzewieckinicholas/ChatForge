local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')

--- @type string
local AddonName = select(1, ...)

--- @class Private
local Private = select(2, ...)

Private.Options = Private.Options or {}

local FilterOptions = {}

--- @class FilterModule: AceModule
local FilterModule = Private.Addon:GetModule('Filter')

local DatabaseUtils = Private.Utils.Database

local filterWordsGroups = {}
local newFilterWords = {}

--- Creates the filter word list display.
--- @param chatFrame table
--- @param index number
local function createFilterWordList(chatFrame, index)
    local filterDatabase = DatabaseUtils.GetChatFramesTable(index, 'filter')
    local args = {}

    if #filterDatabase.words == 0 then
        args.noWords = {
            order = 1,
            type = 'description',
            name = 'No filter words added yet.',
            fontSize = 'medium'
        }
    else
        for wordIndex, word in ipairs(filterDatabase.words) do
            args['word' .. wordIndex] = {
                order = wordIndex,
                type = 'group',
                name = word,
                inline = true,
                args = {
                    remove = {
                        order = 1,
                        type = 'execute',
                        name = 'Remove',
                        desc = 'Remove this filter word.',
                        width = 'full',
                        func = function()
                            FilterModule:RemoveFilterWord(chatFrame, word)

                            FilterOptions:RefreshFilterWordList(chatFrame, index)

                            AceConfigRegistry:NotifyChange(AddonName)
                        end
                    }
                }
            }
        end
    end

    return args
end

--- Refreshes the filter word list for a specific chat frame.
--- @param chatFrame table
--- @param index number
function FilterOptions:RefreshFilterWordList(chatFrame, index)
    local filterWordsGroup = filterWordsGroups[index]

    if filterWordsGroup then
        -- Clear existing args.
        wipe(filterWordsGroup.args)

        -- Recreate the filter word list.
        local newArgs = createFilterWordList(chatFrame, index)

        -- Copy new args to the group.
        for key, value in pairs(newArgs) do
            filterWordsGroup.args[key] = value
        end
    end
end

--- @param chatFrame table
--- @param index number
function FilterOptions:CreateOptionsTableForChatFrame(chatFrame, index)
    local filterDatabase = DatabaseUtils.GetChatFramesTable(index, 'filter')

    -- Stores this chat frame's new filter word.
    newFilterWords[index] = newFilterWords[index] or ''

    local filterWordsGroup = {
        order = 4,
        type = 'group',
        name = 'Filter Words',
        inline = true,
        disabled = function()
            return not filterDatabase.isEnabled
        end,
        args = createFilterWordList(chatFrame, index)
    }

    filterWordsGroups[index] = filterWordsGroup

    return {
        order = 3,
        type = 'group',
        name = FilterModule.moduleName,
        desc = 'Configure message filtering.',
        args = {
            enableFilter = {
                order = 1,
                type = 'toggle',
                name = 'Enable Filter',
                desc = 'Enable message filtering for this chat frame.',
                width = 'full',
                get = function()
                    return filterDatabase.isEnabled
                end,
                set = function(_, value)
                    filterDatabase.isEnabled = value

                    FilterModule:UpdateFilterState(chatFrame)
                end
            },
            filterSettings = {
                order = 2,
                type = 'group',
                name = 'Filter Settings',
                inline = true,
                disabled = function()
                    return not filterDatabase.isEnabled
                end,
                args = {
                    isCaseSensitive = {
                        order = 1,
                        type = 'toggle',
                        name = 'Case Sensitive',
                        desc = 'Enable case-sensitive matching.',
                        width = 'full',
                        get = function()
                            return filterDatabase.isCaseSensitive
                        end,
                        set = function(_, value)
                            filterDatabase.isCaseSensitive = value
                        end
                    },
                    isExactMatch = {
                        order = 2,
                        type = 'toggle',
                        name = 'Exact Match',
                        desc = 'Match whole words only.',
                        width = 'full',
                        get = function()
                            return filterDatabase.isExactMatch
                        end,
                        set = function(_, value)
                            filterDatabase.isExactMatch = value
                        end
                    }
                }
            },
            addWord = {
                order = 3,
                type = 'group',
                name = 'Add Filter Word',
                inline = true,
                disabled = function()
                    return not filterDatabase.isEnabled
                end,
                args = {
                    wordInput = {
                        order = 1,
                        type = 'input',
                        name = 'New Word',
                        desc = 'Enter a word to filter.',
                        width = 'full',
                        get = function()
                            return newFilterWords[index]
                        end,
                        set = function(_, value)
                            newFilterWords[index] = value
                        end
                    },
                    addButton = {
                        order = 2,
                        type = 'execute',
                        name = 'Add',
                        desc = 'Add the word to the filter list.',
                        width = 'full',
                        func = function()
                            local word = newFilterWords[index]

                            if word and word ~= '' then
                                local success, errorMessage = FilterModule:AddFilterWord(chatFrame, word)

                                if success then
                                    newFilterWords[index] = ''

                                    FilterOptions:RefreshFilterWordList(chatFrame, index)

                                    AceConfigRegistry:NotifyChange(AddonName)
                                else
                                    print(AddonName .. ': ' .. (errorMessage or 'Failed to add filter word'))
                                end
                            end
                        end
                    }
                }
            },
            filterWords = filterWordsGroup,
            clearAll = {
                order = 5,
                type = 'execute',
                name = 'Clear All Filter Words',
                desc = 'Remove all filter words for this chat frame.',
                width = 'full',
                disabled = function()
                    return not filterDatabase.isEnabled or #filterDatabase.words == 0
                end,
                confirm = function()
                    return 'Are you sure you want to clear all filter words?'
                end,
                func = function()
                    FilterModule:ClearFilterWords(chatFrame)

                    FilterOptions:RefreshFilterWordList(chatFrame, index)

                    AceConfigRegistry:NotifyChange(AddonName)
                end
            }
        }
    }
end

Private.Options.Filter = FilterOptions
