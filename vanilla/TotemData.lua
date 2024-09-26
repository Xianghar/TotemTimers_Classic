if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local _, TotemTimers = ...

_G["TotemTimers"] = TotemTimers


TotemTimers.SpellIDs = {

    Tremor = 8143, --
    Stoneskin = 8071, --
    Stoneclaw = 5730, --
    StrengthOfEarth = 8075, --
    EarthBind = 2484, --

    Searing = 3599, --
    FireNova = 1535, --
    Magma = 8190, --
    FrostResistance = 8181, --
    Flametongue = 8227, --
    
    HealingStream = 5394, --
    ManaTide = 16190, --
    PoisonCleansing = 8166, --
    DiseaseCleansing = 8170, --
    ManaSpring = 5675, --
    FireResistance = 8184, --
    
    Grounding = 8177, --
    NatureResistance = 10595, --
    Windfury = 8512, --
    Sentry = 6495, --
    Windwall = 15107, --
    GraceOfAir = 8835, --
    TranquilAir = 25908, --
	
    
    Ankh = 20608,
    LightningShield = 324,

    RockbiterWeapon = 8017,
    FlametongueWeapon = 8024,
    FrostbrandWeapon = 8033,
    WindfuryWeapon = 8232,

    EarthShock = 8042,
    FrostShock = 8056,
    FlameShock = 8050,
    StormStrike = 17364,

    LightningBolt = 403,
    ChainLightning = 421,
    HealingWave = 331,
    LesserHealingWave = 8004,
    ChainHeal = 1064,

    ElementalMastery = 16166,
    NaturesSwiftness = 16188,

    -- SoD
    LavaLash = 408507,
    MoltenBlast = 425339,
    WaterShield = 408510,
    EarthShield = 408514,
    DualWield = 674,
    DecoyTotem = 425874,
    LavaBurst = 408490,
    SpiritAlpha = 408696,
    ShamanisticRage = 425336,
    AncestralGuidance = 409324,
    WayOfEarth = 408531,
    Maelstrom = 408498,
    PowerSurge = 415100,
    HealingRain = 415236,
    EarthShockTank = 408681,
    Riptide = 408521,
    FeralSpirit = 440580,

    PowerSurgeBuffDps = 415105,
    PowerSurgeBuffHeal = 468526,


    --EnamoredWaterSpirit = 24854 -- Water Totem trinket
    --[[ WaterShield = 52127,
    EarthShield = 974,
    TotemicCall = 36936,
    
    StormStrike = 17364,
    PrimalStrike = 73899,
    EarthShock = 8042,
    FrostShock = 8056,
    FlameShock = 8050,
    LavaLash = 60103,
    LightningBolt = 403,
    ChainLightning = 421,
    LavaBurst = 51505,
    Maelstrom = 51530,
    WindShear = 57994,
    ShamanisticRage = 30823,
    FeralSpirit = 51533,
    ElementalMastery = 16166,
    Thunderstorm = 51490,
    HealingRain = 73920,
    Riptide = 61295,
    UnleashElements = 73680,
	UnleashLife = 73685,
    SpiritwalkersGrace = 79206,
    Ascendance = 114049,
	AscendanceEnhancement = 114051,
	AscendanceElemental = 114050,
	AscendanceRestoration = 114052,
     
    CallOfElements = 108285,
    SpiritWalk = 58875,
    AstralShift = 108271,
    TotemicProjection = 108287,
    AncestralSwiftness = 16188,
    AncestralGuidance = 108281,
    ElementalBlast = 117014,
    
    LiquidMagma = 152255,
    LavaSurge = 77762,
    
    Hex = 51514,
    
    UnleashFlame = 73683,
	UnleashFlameEle = 165462,
    Volcano = 99207,
	
	Bloodlust = 2825,
	Heroism = 32182,
	AstralShift = 108271,
	Stormblast = 115356,
	PurifySpirit = 77130,
	
	ChainHeal = 1064, ]]
}

local SpellIDs = TotemTimers.SpellIDs

TotemTimers.SpellIDsForceNames = {
    [SpellIDs.WaterShield] = true,
    [SpellIDs.EarthShield] = true,
    [SpellIDs.FireNova] = true,
}


TotemData = {
	[TotemTimers.SpellIDs.Tremor] = {
        element = EARTH_TOTEM_SLOT,
        flashInterval = 4,
        warningPoint = 2,
    },
    [TotemTimers.SpellIDs.Stoneskin] = {
        element = EARTH_TOTEM_SLOT,
        buff = 8072,
    },
    [TotemTimers.SpellIDs.Stoneclaw] = {
        element = EARTH_TOTEM_SLOT,
        warningPoint = 2,
    },
    [TotemTimers.SpellIDs.StrengthOfEarth] = {
        element = EARTH_TOTEM_SLOT,
        buff = 8076,
    },
    [TotemTimers.SpellIDs.EarthBind] = {
        element = EARTH_TOTEM_SLOT,
        flashInterval = 3,
        flashDelay = 1,
        warningPoint = 5,
    },
	[TotemTimers.SpellIDs.Searing] = {
		element = FIRE_TOTEM_SLOT,
        warningPoint = 5,
	},
    [TotemTimers.SpellIDs.FireNova] = {
        element = FIRE_TOTEM_SLOT,
    },
	[TotemTimers.SpellIDs.Magma] = {
		element = FIRE_TOTEM_SLOT,
	},
    [TotemTimers.SpellIDs.FrostResistance] = {
        element = FIRE_TOTEM_SLOT,
        buff = 8182,
    },
    [TotemTimers.SpellIDs.Flametongue] = {
        element = FIRE_TOTEM_SLOT,
    },
    [TotemTimers.SpellIDs.HealingStream] = {
		element = WATER_TOTEM_SLOT,
        range = 1600,
		warningPoint = 4,
        buff = 5672,
	},
    [TotemTimers.SpellIDs.ManaTide] = {
        element = WATER_TOTEM_SLOT,
        warningPoint = 2,
        buff = 16191,
    },
    [TotemTimers.SpellIDs.PoisonCleansing] = {
        element = WATER_TOTEM_SLOT,
        flashInterval = 5,
        rangeCheck = 20,
    },
    [TotemTimers.SpellIDs.DiseaseCleansing] = {
        element = WATER_TOTEM_SLOT,
        flashInterval = 5,
        rangeCheck = 20,
    },
    [TotemTimers.SpellIDs.ManaSpring] = {
        element = WATER_TOTEM_SLOT,
        buff = 5677,
    },
    [TotemTimers.SpellIDs.FireResistance] = {
        element = WATER_TOTEM_SLOT,
        buff = 8185,
    },
	[TotemTimers.SpellIDs.Grounding] = {
		element = AIR_TOTEM_SLOT,
        range = 100,
		warningPoint = 5,
		flashInterval = 10,
        buff = 8178,
	},
    [TotemTimers.SpellIDs.NatureResistance] = {
        element = AIR_TOTEM_SLOT,
        buff = 10596,
    },
    [TotemTimers.SpellIDs.Windfury] = {
        element = AIR_TOTEM_SLOT,
    },
    [TotemTimers.SpellIDs.Sentry] = {
        element = AIR_TOTEM_SLOT,
    },
    [TotemTimers.SpellIDs.Windwall] = {
        element = AIR_TOTEM_SLOT,
        buff = 15108,
    },
    [TotemTimers.SpellIDs.GraceOfAir] = {
        element = AIR_TOTEM_SLOT,
        buff = 8836,
    },
    [TotemTimers.SpellIDs.TranquilAir] = {
        element = AIR_TOTEM_SLOT,
        buff = 25909,
    },
    [TotemTimers.SpellIDs.DecoyTotem] = {
        element = EARTH_TOTEM_SLOT,
        buff = 436391,
    },
}

local TotemCount = {}
for k,v in pairs(TotemData) do
    TotemCount[v.element] = (TotemCount[v.element] or 0) + 1
end
TotemTimers.TotemCount = TotemCount

for k,v in pairs(TotemData) do
    if  v.buff then v.buffName = GetSpellInfo(v.buff) end
end


TotemTimers.TotemCooldowns = {
    [EARTH_TOTEM_SLOT] = {
        SpellIDs.EarthBind,
        SpellIDs.Tremor,
        SpellIDs.Stoneclaw,
    },
    [WATER_TOTEM_SLOT] = {
        SpellIDs.ManaTide,
    },
    [FIRE_TOTEM_SLOT] = {
        SpellIDs.FireNova,
    },
    [AIR_TOTEM_SLOT] = {
    },
}

TotemTimers.WeaponEnchants = {
    [3] = SpellIDs.FlametongueWeapon,
    [4] = SpellIDs.FlametongueWeapon,
    [5] = SpellIDs.FlametongueWeapon,
    [523] = SpellIDs.FlametongueWeapon,
    [1665] = SpellIDs.FlametongueWeapon,
    [1666] = SpellIDs.FlametongueWeapon,
    [2634] = SpellIDs.FlametongueWeapon,
    [3779] = SpellIDs.FlametongueWeapon,
    [3780] = SpellIDs.FlametongueWeapon,
    [3781] = SpellIDs.FlametongueWeapon,
    [7567] = SpellIDs.FlametongueWeapon,
    [1] = SpellIDs.RockbiterWeapon,
    [6] = SpellIDs.RockbiterWeapon,
    [29] = SpellIDs.RockbiterWeapon,
    [503] = SpellIDs.RockbiterWeapon,
    [504] = SpellIDs.RockbiterWeapon,
    [683] = SpellIDs.RockbiterWeapon,
    [1663] = SpellIDs.RockbiterWeapon,
    [1664] = SpellIDs.RockbiterWeapon,
    [2632] = SpellIDs.RockbiterWeapon,
    [2633] = SpellIDs.RockbiterWeapon,
    [3018] = SpellIDs.RockbiterWeapon,
    [7568] = SpellIDs.RockbiterWeapon,
    [283] = SpellIDs.WindfuryWeapon,
    [284] = SpellIDs.WindfuryWeapon,
    [525] = SpellIDs.WindfuryWeapon,
    [1669] = SpellIDs.WindfuryWeapon,
    [2636] = SpellIDs.WindfuryWeapon,
    [3785] = SpellIDs.WindfuryWeapon,
    [3786] = SpellIDs.WindfuryWeapon,
    [3787] = SpellIDs.WindfuryWeapon,
    [7569] = SpellIDs.WindfuryWeapon,
    [2] = SpellIDs.FrostbrandWeapon,
    [12] = SpellIDs.FrostbrandWeapon,
    [5244] = SpellIDs.FrostbrandWeapon,
    [1667] = SpellIDs.FrostbrandWeapon,
    [1668] = SpellIDs.FrostbrandWeapon,
    [2635] = SpellIDs.FrostbrandWeapon,
    [3782] = SpellIDs.FrostbrandWeapon,
    [3783] = SpellIDs.FrostbrandWeapon,
    [3784] = SpellIDs.FrostbrandWeapon,
    [7566] = SpellIDs.FrostbrandWeapon,
    [563] = SpellIDs.Windfury,
    [564] = SpellIDs.Windfury,
    [1783] = SpellIDs.Windfury,
    [2638] = SpellIDs.Windfury,
    [2639] = SpellIDs.Windfury,
    [3014] = SpellIDs.Windfury,
    [124] = SpellIDs.Flametongue,
    [285] = SpellIDs.Flametongue,
    [543] = SpellIDs.Flametongue,
    [1683] = SpellIDs.Flametongue,
    [2637] = SpellIDs.Flametongue,
}

for i = 3018, 3044 do TotemTimers.WeaponEnchants[i] = SpellIDs.RockbiterWeapon end

TotemTimers.TotemWeaponEnchants = {
    [563] = SpellIDs.Windfury,
    [564] = SpellIDs.Windfury,
    [1783] = SpellIDs.Windfury,
    [2638] = SpellIDs.Windfury,
    [2639] = SpellIDs.Windfury,
    [3014] = SpellIDs.Windfury,
    [124] = SpellIDs.Flametongue,
    [285] = SpellIDs.Flametongue,
    [543] = SpellIDs.Flametongue,
    [1683] = SpellIDs.Flametongue,
    [2637] = SpellIDs.Flametongue,
}


TotemTimers.ShieldButtons = {
    SpellIDs.LightningShield,
    SpellIDs.WaterShield,
    SpellIDs.EarthShield,
}

TotemTimers.ShieldSpells = {
    SpellIDs.LightningShield,
    SpellIDs.WaterShield,
    SpellIDs.EarthShield,
}

TotemTimers.CombatCooldownSpells = {
    [2] = {
        SpellIDs.StormStrike,
        SpellIDs.FlameShock,
        SpellIDs.EarthShock,
        SpellIDs.MoltenBlast,
        SpellIDs.LavaLash,
        SpellIDs.LavaBurst,
        SpellIDs.ChainLightning,
        SpellIDs.Searing,
        SpellIDs.Magma,
        SpellIDs.FireNova,
    },
    [1] = {
        SpellIDs.FlameShock,
        SpellIDs.EarthShock,
        SpellIDs.ChainLightning,
        SpellIDs.LightningBolt,
        SpellIDs.LavaBurst,
        SpellIDs.LavaLash,
        SpellIDs.MoltenBlast,
    },
    [3] = {
        SpellIDs.FlameShock,
        SpellIDs.ChainHeal,
        SpellIDs.HealingRain,
        SpellIDs.Riptide,
        SpellIDs.LavaLash,
        SpellIDs.LavaBurst,
        SpellIDs.MoltenBlast,
    },
}


TotemTimers.LongCooldownSpells = {
    {
        spell = SpellIDs.SpiritAlpha,
        customOnEvent = "SpiritAlphaEvent",
        events = { "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_SENT", "PLAYER_REGEN_ENABLED" }
    },
    {
        spell = SpellIDs.ManaTide,
        totem = SpellIDs.ManaTide,
        element = WATER_TOTEM_SLOT,
        customOnEvent = "CDTotemEvent",
    },
    {
        spell = SpellIDs.ShamanisticRage,
        buff = SpellIDs.ShamanisticRage,
    },
    {
        spell = SpellIDs.AncestralGuidance,
        buff = SpellIDs.AncestralGuidance,
    },
    {
        spell = SpellIDs.ElementalMastery,
        buff = SpellIDs.ElementalMastery,
    },
    {
        spell = SpellIDs.NaturesSwiftness,
        buff = SpellIDs.NaturesSwiftness,
    },
    {
        spell = SpellIDs.FeralSpirit,
        customOnEvent = "FeralSpiritEvent",
    },
}


TotemTimers.MaelstromSpells = {
    SpellIDs.LightningBolt,
    SpellIDs.ChainLightning,
    SpellIDs.LavaBurst,
    SpellIDs.LesserHealingWave,
}


TotemTimers.PowerSurgeSpellsDps = {
    SpellIDs.LavaBurst,
    SpellIDs.ChainLightning,
}
TotemTimers.PowerSurgeSpellsHeal = {
    SpellIDs.ChainHeal,
}