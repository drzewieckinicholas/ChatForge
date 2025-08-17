--- @class Private
local Private = select(2, ...)

Private.Utils = Private.Utils or {}

local MessageUtils = {}

local string_gsub = string.gsub

--- Extracts protected ID from a potential protected string.
--- @param potentialProtectedString string
--- @param fallbackId string
--- @return string?
local function extractProtectedId(potentialProtectedString, fallbackId)
    if fallbackId and potentialProtectedString == '' then
        return fallbackId
    end
end

--- Checks if a message contains protected content.
--- @param message string
--- @return boolean
function MessageUtils:IsMessageProtected(message)
    return message and (message ~= string_gsub(message, '(:?|?)|K(.-)|k', extractProtectedId))
end

Private.Utils.Message = MessageUtils
