local AceAddon = LibStub('AceAddon-3.0')

--- @type string
local AddonName = select(1, ...)

--- @class Private
local Private = select(2, ...)

Private.Addon = AceAddon:NewAddon(AddonName)
