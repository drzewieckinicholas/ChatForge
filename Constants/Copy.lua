--- @class Private
local Private = select(2, ...)

Private.Constants = Private.Constants or {}

Private.Constants.Copy = {
    Dialog = {
        HEIGHT = 250,
        WIDTH = 400,
        LAYOUT = 'Fill'
    },
    Messages = {
        DEFAULT_COUNT = 50,
        MAX_COUNT = 100,
        MIN_COUNT = 10,
        STEP = 10
    }
}
