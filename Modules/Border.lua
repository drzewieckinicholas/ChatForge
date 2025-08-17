local string_format = string.format
local type = type

--- @class Private
local Private = select(2, ...)

--- @class BorderModule: AceModule
local BorderModule = Private.Addon:NewModule('Border')

local ChatFrameUtils = Private.Utils.ChatFrame
local DatabaseUtils = Private.Utils.Database

local ERROR_MESSAGES = {
    COLOR_TYPE = 'Expected color to be a table, got %s',
    INDEX_TYPE = 'Expected index to be a number, got %s',
    MARGIN_TYPE = 'Expected margin to be a number, got %s',
    SIZE_TYPE = 'Expected size to be a number, got %s',
    TEXTURE_TYPE = 'Expected texture to be a string, got %s'
}

local borderFrames = {}

--- Creates a border frame for a chat frame.
--- @param chatFrame table
--- @param index number
--- @return table
local function createBorderFrame(chatFrame, index)
    local borderFrame = CreateFrame('Frame', nil, chatFrame, 'BackdropTemplate')

    borderFrames[index] = borderFrame

    return borderFrame
end

--- Initializes a border frame with database defaults.
--- @param chatFrame table
--- @param index number
local function initializeBorderFrame(chatFrame, index)
    local borderFrame = borderFrames[index]

    if not borderFrame then
        borderFrame = createBorderFrame(chatFrame, index)
    end

    local borderDatabase = DatabaseUtils.GetChatFramesTable(index, 'border')

    borderFrame:SetBackdrop({
        edgeFile = borderDatabase.texture,
        edgeSize = borderDatabase.size,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })

    local color = borderDatabase.color

    borderFrame:SetBackdropBorderColor(color[1], color[2], color[3], color[4])

    BorderModule:UpdateBorderMargin(index, borderDatabase.margin)

    borderFrame:SetShown(borderDatabase.isEnabled)
end

--- Updates the border margin for a chat frame.
--- @param index number
--- @param margin number
function BorderModule:UpdateBorderMargin(index, margin)
    assert(type(index) == 'number', string_format(ERROR_MESSAGES.INDEX_TYPE, type(index)))
    assert(type(margin) == 'number', string_format(ERROR_MESSAGES.MARGIN_TYPE, type(margin)))

    local borderFrame = borderFrames[index]

    if not borderFrame then
        return
    end

    local chatFrame = ChatFrameUtils:GetChatFrame(index)

    if not chatFrame then
        return
    end

    local background = ChatFrameUtils:GetChatFrameBackground(chatFrame)

    borderFrame:ClearAllPoints()
    borderFrame:SetPoint('TOPLEFT', background, 'TOPLEFT', -margin, margin)
    borderFrame:SetPoint('BOTTOMRIGHT', background, 'BOTTOMRIGHT', margin, -margin)
end

--- Updates the border color for a chat frame.
--- @param index number
--- @param color table
function BorderModule:UpdateBorderColor(index, color)
    assert(type(index) == 'number', string_format(ERROR_MESSAGES.INDEX_TYPE, type(index)))
    assert(type(color) == 'table', string_format(ERROR_MESSAGES.COLOR_TYPE, type(color)))

    local borderFrame = borderFrames[index]

    if not borderFrame then
        return
    end

    borderFrame:SetBackdropBorderColor(color[1], color[2], color[3], color[4])
end

--- Updates the border size for a chat frame.
--- @param index number
--- @param size number
function BorderModule:UpdateBorderSize(index, size)
    assert(type(index) == 'number', string_format(ERROR_MESSAGES.INDEX_TYPE, type(index)))
    assert(type(size) == 'number', string_format(ERROR_MESSAGES.SIZE_TYPE, type(size)))

    local borderFrame = borderFrames[index]

    if not borderFrame then
        return
    end

    local borderDatabase = DatabaseUtils.GetChatFramesTable(index, 'border')

    borderFrame:SetBackdrop({
        edgeFile = borderDatabase.texture,
        edgeSize = size,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })

    local color = borderDatabase.color

    borderFrame:SetBackdropBorderColor(color[1], color[2], color[3], color[4])
end

--- Updates the border texture for a chat frame.
--- @param index number
--- @param texture string
function BorderModule:UpdateBorderTexture(index, texture)
    assert(type(index) == 'number', string_format(ERROR_MESSAGES.INDEX_TYPE, type(index)))
    assert(type(texture) == 'string', string_format(ERROR_MESSAGES.TEXTURE_TYPE, type(texture)))

    local borderFrame = borderFrames[index]

    if not borderFrame then
        return
    end

    local borderDatabase = DatabaseUtils.GetChatFramesTable(index, 'border')

    borderFrame:SetBackdrop({
        edgeFile = texture,
        edgeSize = borderDatabase.size,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })

    local color = borderDatabase.color

    borderFrame:SetBackdropBorderColor(color[1], color[2], color[3], color[4])
end

--- Updates the border enabled state for a chat frame.
--- @param index number
--- @param isEnabled boolean
function BorderModule:UpdateBorderIsEnabled(index, isEnabled)
    assert(type(index) == 'number', string_format(ERROR_MESSAGES.INDEX_TYPE, type(index)))

    local borderFrame = borderFrames[index]

    if not borderFrame then
        if isEnabled then
            local chatFrame = ChatFrameUtils:GetChatFrame(index)

            if chatFrame then
                initializeBorderFrame(chatFrame, index)
            end
        end

        return
    end

    borderFrame:SetShown(isEnabled)
end

function BorderModule:OnEnable()
    -- Initialize borders for all chat frames.
    ChatFrameUtils:ForEachChatFrame(function(chatFrame, index)
        initializeBorderFrame(chatFrame, index)
    end)
end

function BorderModule:OnDisable()
    -- Hide all borders.
    for index, borderFrame in pairs(borderFrames) do
        if borderFrame then
            borderFrame:Hide()
        end
    end
end
