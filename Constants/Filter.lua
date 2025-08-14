--- @class Private
local Private = select(2, ...)

Private.Constants = Private.Constants or {}

Private.Constants.Filter = {
    Events = {
        'CHAT_MSG_CHANNEL',
        'CHAT_MSG_SAY',
        'CHAT_MSG_WHISPER',
        'CHAT_MSG_YELL'
    }
}
