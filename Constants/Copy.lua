--- @class Private
local Private = select(2, ...)

Private.Constants = Private.Constants or {}

Private.Constants.Copy = {
    Dialog = {
        FRAME_STRATA = 'DIALOG',
        HEIGHT = 250,
        LAYOUT = 'Fill',
        WIDTH = 400
    },
    Messages = {
        DEFAULT_COUNT = 50,
        MAX_COUNT = 100,
        MIN_COUNT = 10,
        STEP = 10
    }
}
