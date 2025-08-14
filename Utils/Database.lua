--- @class Private
local Private = select(2, ...)

Private.Utils = Private.Utils or {}

local DatabaseUtils = {}

local ERROR_MESSAGE_DATABASE_NOT_INITIALIZED = 'Database not initialized'

--- @param index number
--- @param key 'font'
--- @return table
function DatabaseUtils.GetChatFramesTable(index, key)
    assert(Private.database, ERROR_MESSAGE_DATABASE_NOT_INITIALIZED)

    if not Private.database.profile.frames[index] then
        Private.database.profile.frames[index] = Private.Core.Database.GetChatFrameDefaults()
    end

    return Private.database.profile.frames[index][key]
end

Private.Utils.Database = DatabaseUtils
