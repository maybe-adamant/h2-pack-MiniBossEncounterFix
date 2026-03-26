local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-Modpack_Lib']

config = chalk.auto('config.lua')
public.config = config

local backup, revert = lib.createBackupSystem()

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "MiniBossEncounterFix",
    name     = "Miniboss Encounter Fix",
    category = "Bug Fixes",
    group    = "NPC & Encounters",
    tooltip  = "Fixes Miniboss with top screen health bars not properly progressing biome depth.",
    default  = true,
    dataMutation = true,
    modpack = "h2-modpack",
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function apply()
    backup(EncounterData.MiniBossBoar,      "CountsForRoomEncounterDepth")
    backup(EncounterData.MiniBossCharybdis, "CountsForRoomEncounterDepth")
    backup(EncounterData.MiniBossTalos,     "CountsForRoomEncounterDepth")
    backup(EncounterData.BossTyphonEye01,   "CountsForRoomEncounterDepth")
    backup(EncounterData.BossTyphonArm01,   "CountsForRoomEncounterDepth")
    EncounterData.MiniBossBoar.CountsForRoomEncounterDepth = true
    EncounterData.MiniBossCharybdis.CountsForRoomEncounterDepth = true
    EncounterData.MiniBossTalos.CountsForRoomEncounterDepth = true
    EncounterData.BossTyphonEye01.CountsForRoomEncounterDepth = true
    EncounterData.BossTyphonArm01.CountsForRoomEncounterDepth = true
end

local function registerHooks()
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.apply = apply
public.definition.revert = revert

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if lib.isEnabled(config, public.definition.modpack) then apply() end
        if public.definition.dataMutation and not lib.isCoordinated(public.definition.modpack) then
            SetupRunData()
        end
    end)
end)

local uiCallback = lib.standaloneUI(public.definition, config, apply, revert)
rom.gui.add_to_menu_bar(uiCallback)
