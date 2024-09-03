local backgroundList = require("mer.characterBackgrounds.backgroundsList")
local config = require("mer.characterBackgrounds.config")
local Background = require("mer.characterBackgrounds.Background")
local common = require("mer.characterBackgrounds.common")
local logger = common.createLogger("Interop")

---@class CharacterBackgrounds.Interop
local Interop = {}

---@param backgroundConfig CharacterBackgrounds.BackgroundConfig
function Interop.addBackground(backgroundConfig)
    local background = Background:new(backgroundConfig)
    if backgroundList[background.id] then
        logger:warn("Background %s already exists", background.name)
        return
    end
    backgroundList[background.id] = background
    logger:info("Background %s added successfully", background.name)
    return background
end

---@param id string
---@return CharacterBackgrounds.Background?
function Interop.getBackground(id)
    return Background.get(id)
end

---@return CharacterBackgrounds.Background?
function Interop.getCurrentBackground()
    ---@type string
    local backgroundId = tes3.player
        and tes3.player.data.merBackgrounds
        and tes3.player.data.merBackgrounds.currentBackground
    if backgroundId then
        return backgroundList[backgroundId]
    end
end

--- Returns true if the background is currently active
---@param backgroundId string The id of the background
---@return boolean #Whether the background is currently active
function Interop.isActive(backgroundId)
    local background = Background.get(backgroundId)
    return background and background:isActive()
end

--- Returns the data table for the background
---@return table? #The data table for the background if available
function Interop.getData(backgroundId)
    local background = backgroundList[backgroundId]
    if not background then
        return
    end
    if not tes3.player then
        return
    end
    return background.data
end

return Interop
