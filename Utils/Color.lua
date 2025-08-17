local string_format = string.format

--- @class Private
local Private = select(2, ...)

Private.Utils = Private.Utils or {}

local ColorUtils = {}

--- Converts RGB values to hex color code.
--- @param red number
--- @param green number
--- @param blue number
--- @return string
function ColorUtils:ConvertRGBToHex(red, green, blue)
    if red and green and blue then
        return string.format('|cff%02x%02x%02x', red * 255, green * 255, blue * 255)
    else
        return '|cffffffff'
    end
end

Private.Utils.Color = ColorUtils
