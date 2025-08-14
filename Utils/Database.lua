--- @class Private
local Private = select(2, ...)

Private.Utils = Private.Utils or {}

local DatabaseUtils = {}

local ERROR_MESSAGE_DATABASE_NOT_INITIALIZED = 'Database not initialized'

--- Retrieves the database table for a specific chat frame and key.
--- @param index number
--- @param key 'filter'|'font'
--- @return table
function DatabaseUtils.GetChatFramesTable(index, key)
    assert(Private.database, ERROR_MESSAGE_DATABASE_NOT_INITIALIZED)

    if not Private.database.profile.frames[index] then
        Private.database.profile.frames[index] = Private.Core.Database.GetChatFrameDefaults()
    end

    return Private.database.profile.frames[index][key]
end

Private.Utils.Database = DatabaseUtils
