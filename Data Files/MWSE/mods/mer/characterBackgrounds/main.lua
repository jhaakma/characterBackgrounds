
require("mer.characterBackgrounds.integrations")
require("mer.characterBackgrounds.MCM")

local common = require("mer.characterBackgrounds.common")
local config = common.config
local UI = require("mer.characterBackgrounds.UI")
local logger = require("logging.logger").new{
    name = "Character Backgrounds",
    logLevel = config.mcm.logLevel
}

local backgroundsList = require("mer.characterBackgrounds.backgroundsList")

event.register("CharacterBackgrounds:OpenPerksMenu", function()
    logger:debug("Opening perks menu from event")
    UI.createPerkMenu()
end)

local newGame
local function checkCharGen()
    local chargen = tes3.findGlobal("CharGenState").value
    if chargen == 10 then
        logger:debug("New game, will open perks menu when chargen complete")
        newGame = true
    elseif newGame and chargen == -1 then
        logger:debug("Character generation is done")
        event.unregister("simulate", checkCharGen)
        if not config.persistent.currentBackground then
            logger:debug("Background selected, opening perks menu in 0.7 seconds")
            timer.start{
                type = timer.simulate,
                duration = 0.7,
                callback = function()
                    logger:debug("Creating Perk Menu from timer")
                    UI.createPerkMenu()
                end
            }
        end
    end
end

local function loaded()
    newGame = false
    --initialise existing background
    local background = backgroundsList[config.persistent.currentBackground]
    if background then
        ---@diagnostic disable-next-line: deprecated
        if background.callback then background.callback(config.persistent) end
        if background.onLoad then
            logger:debug("Running onLoad for %s", background.name)
            background:onLoad()
        end
    end

    --Check for chargen
    event.unregister("simulate", checkCharGen)
    event.register("simulate", checkCharGen)
end

event.register("loaded", loaded )

