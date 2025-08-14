--- @type string
local AddonName = select(1, ...)

--- @class Private
local Private = select(2, ...)

local Addon = Private.Addon

function Addon:OnInitialize()
    Private.database = LibStub('AceDB-3.0'):New(AddonName .. 'DB', Private.Core.Database:GetDefaults(), true)

    Private.Utils.ChatFrame:InitializeCaches()

    Private.Options:Initialize()
end

function Addon:OnEnable()
    Private.Hooks.ChatFrame:Initialize()
end
