if select(2,UnitClass("player")) ~= "SHAMAN" then return end

local addon, TotemTimers = ...

_G["TotemTimers"] = TotemTimers


TotemTimers.SpellIDs = {

    Tremor = 8143, --
    --Stoneskin = 8071, --
    --Stoneclaw = 5730, --
    --StrengthOfEarth = 8075, --
    EarthBind = 2484, --
    EarthElemental = 2062,
    EarthGrab = 51485,
    StoneBulwark = 108270,

    Searing = 3599, --
    FireNova = 1535, --
    Magma = 8190, --
    --FrostResistance = 8181, --
    --Flametongue = 8227, --
    FireElemental = 2894,
    --Wrath = 30706,

    HealingStream = 5394, --
    ManaTide = 16190, --
    --Cleansing = 8170, --
    --ManaSpring = 5675, --
    --FireResistance = 8184,
    HealingTide = 108280,

    Grounding = 8177, --
    --NatureResistance = 10595, --
    --Windfury = 8512, --
    --Sentry = 6495, --
    --WrathOfAir = 3738,
    TranquilMind = 108279,
    SpiritLink = 98008,
    StormLash = 120668,
    Capacitor = 108269,
    WindWalk = 108273,


    Ankh = 20608, --Reincarnation
    TotemicCall = 36936,
    LightningShield = 324,
    WaterShield = 52127,
    EarthShield = 974,

    --RockbiterWeapon = 8017,
    FlametongueWeapon = 8024,
    FrostbrandWeapon = 8033,
    WindfuryWeapon = 8232,
    EarthlivingWeapon = 51730,

    EarthShock = 8042,
    FrostShock = 8056,
    FlameShock = 8050,
    StormStrike = 17364,

    --CallOfSpirits = 66844,
    --CallOfElements = 66842,
    --CallOfAncestors = 66843,

    Bloodlust = 2825,
    ChainLightning = 421,
    ElementalMastery = 16166,
    FeralSpirit = 51533,
    Heroism = 32182,
    Hex = 51514,
    LavaBurst = 51505,
    LavaLash = 60103,
    --LightningBolt = 403,
    NaturesSwiftness = 132158,
    Riptide = 61295,
    ShamanisticRage = 30823,
    --TidalForce = 55198,
    Thunderstorm = 51490,
    WindShear = 57994,
    Maelstrom = 53817,

    LightningBolt = 403,
    HealingWave = 331,
    --LesserHealingWave = 8004,
    HealingSurge = 8004,
    ChainHeal = 1064,
    GreaterHealingWave = 77472,
    TidalWaves = 53390,
    ElementalFocus = 16246,


    --ClearCasting = 16246,

    Earthquake = 61882,
    SpiritwalkersGrace = 79206,
    PrimalStrike = 73899,
    --BindElemental = 76780,
    --GreaterHealingWave = 77472,
    UnleashElements = 73680,
    HealingRain = 73920,

    Ascendance = 114049,
    AscendanceEnhancement = 114051,
    AscendanceElemental = 114050,
    AscendanceRestoration = 114052,
    SpiritWalk = 58875,
    LavaSurge = 77762,
    Stormblast = 115356,
    SearingFlames = 77657,
    PurifySpirit = 77130,
    CleanseSpirit = 51886,

    CallOfElements = 108285,
    SpiritWalk = 58875,
    AstralShift = 108271,
    TotemicProjection = 108287,
    AncestralSwiftness = 16188,
    AncestralGuidance = 108281,
    ElementalBlast = 117014,


    --EnamoredWaterSpirit = 24854 -- Water Totem trinket
    --[[
    PrimalStrike = 73899,

    LightningBolt = 403,

    LavaBurst = 51505,
    Maelstrom = 51530,
    WindShear = 57994,
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


TotemData = {
	[SpellIDs.Tremor] = {
        element = EARTH_TOTEM_SLOT,
        flashInterval = 3,
        warningPoint = 0,
        rangeCheck = 30,
    },
    [SpellIDs.EarthBind] = {
        element = EARTH_TOTEM_SLOT,
        flashInterval = 3,
        flashDelay = 0,
        warningPoint = 5,
    },
    [SpellIDs.EarthElemental] = {
        element = EARTH_TOTEM_SLOT,
    },

	[SpellIDs.Searing] = {
		element = FIRE_TOTEM_SLOT,
        warningPoint = 5,
	},
	[SpellIDs.Magma] = {
		element = FIRE_TOTEM_SLOT,
	},
    [SpellIDs.FireElemental] = {
        element = FIRE_TOTEM_SLOT,
    },

    [SpellIDs.HealingStream] = {
		element = WATER_TOTEM_SLOT,
		warningPoint = 4,
        rangeCheck = 30,
	},
    [SpellIDs.ManaTide] = {
        element = WATER_TOTEM_SLOT,
        warningPoint = 2,
        rangeCheck = 30,
    },
    [SpellIDs.HealingTide] = {
        element = WATER_TOTEM_SLOT,
        warningPoint = 2,
        rangeCheck = 30,
    },

	[SpellIDs.Grounding] = {
		element = AIR_TOTEM_SLOT,
        range = 100,
		warningPoint = 5,
		--flashInterval = 10,
        buff = 8178,
	},
    [SpellIDs.TranquilMind] = {
        element = WATER_TOTEM_SLOT,
        buff = 87717,
        warningPoint = 0,
    },
    [SpellIDs.SpiritLink] = {
        element = AIR_TOTEM_SLOT,
        buff = 98008,
        warningPoint = 0,
    },
    [SpellIDs.Capacitor] = {
        element = AIR_TOTEM_SLOT,
        warningPoint = 0,
    },
    [SpellIDs.WindWalk] = {
        element = AIR_TOTEM_SLOT,
        warningPoint = 0,
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
        SpellIDs.EarthElemental,
    },
    [WATER_TOTEM_SLOT] = {
        SpellIDs.ManaTide,
        SpellIDs.HealingTide,
    },
    [FIRE_TOTEM_SLOT] = {
        SpellIDs.FireElemental,
    },
    [AIR_TOTEM_SLOT] = {
        SpellIDs.Grounding,
        SpellIDs.TranquilMind,
        SpellIDs.SpiritLink,
        SpellIDs.Capacitor,
        SpellIDs.WindWalk,
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
    [283] = SpellIDs.WindfuryWeapon,
    [284] = SpellIDs.WindfuryWeapon,
    [525] = SpellIDs.WindfuryWeapon,
    [1669] = SpellIDs.WindfuryWeapon,
    [2636] = SpellIDs.WindfuryWeapon,
    [3785] = SpellIDs.WindfuryWeapon,
    [3786] = SpellIDs.WindfuryWeapon,
    [3787] = SpellIDs.WindfuryWeapon,
    [2] = SpellIDs.FrostbrandWeapon,
    [12] = SpellIDs.FrostbrandWeapon,
    [5244] = SpellIDs.FrostbrandWeapon,
    [1667] = SpellIDs.FrostbrandWeapon,
    [1668] = SpellIDs.FrostbrandWeapon,
    [2635] = SpellIDs.FrostbrandWeapon,
    [3782] = SpellIDs.FrostbrandWeapon,
    [3783] = SpellIDs.FrostbrandWeapon,
    [3784] = SpellIDs.FrostbrandWeapon,
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
    [3345] = SpellIDs.EarthlivingWeapon,
    [3346] = SpellIDs.EarthlivingWeapon,
    [3347] = SpellIDs.EarthlivingWeapon,
    [3348] = SpellIDs.EarthlivingWeapon,
    [3349] = SpellIDs.EarthlivingWeapon,
    [3350] = SpellIDs.EarthlivingWeapon,
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
    SpellIDs.TotemicCall,
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
        SpellIDs.UnleashElements,
        SpellIDs.FireNova,
        SpellIDs.LavaLash,
        SpellIDs.WindShear,
        SpellIDs.Searing,
        SpellIDs.Magma,
        SpellIDs.ChainLightning,
    },
    [1] = {
        SpellIDs.FlameShock,
        SpellIDs.EarthShock,
        SpellIDs.ChainLightning,
        SpellIDs.LightningBolt,
        SpellIDs.LavaBurst,
        SpellIDs.UnleashElements,
        SpellIDs.FireNova,
        SpellIDs.EarthQuake,
        SpellIDs.WindShear,

    },
    [3] = {
        SpellIDs.Riptide,
        SpellIDs.HealingRain,
        SpellIDs.UnleashElements,
        SpellIDs.FlameShock,
        SpellIDs.EarthShock,
        SpellIDs.WindShear,

    },
}


TotemTimers.LongCooldownSpells = {
    {
        spell = SpellIDs.FireElemental,
        totem = SpellIDs.FireElemental,
        element = FIRE_TOTEM_SLOT,
        customOnEvent = "CDTotemEvent",
    },
    {
        spell = SpellIDs.EarthElemental,
        totem = SpellIDs.EarthElemental,
        element = EARTH_TOTEM_SLOT,
        customOnEvent = "CDTotemEvent",
    },
    {
        spell = SpellIDs.ElementalMastery,
        buff = SpellIDs.ElementalMastery,
    },
    {
        spell = SpellIDs.Thunderstorm,
    },
    {
        spell = SpellIDs.NaturesSwiftness,
        buff = SpellIDs.NaturesSwiftness,
    },
    {
        spell = SpellIDs.ManaTide,
        totem = SpellIDs.ManaTide,
        element = WATER_TOTEM_SLOT,
        customOnEvent = "CDTotemEvent",
    },
    {
        spell = SpellIDs.SpiritLink,
        totem = SpellIDs.SpiritLink,
        element = AIR_TOTEM_SLOT,
        customOnEvent = "CDTotemEvent",
    },
    {
        spell = SpellIDs.ShamanisticRage,
        buff = SpellIDs.ShamanisticRage,
    },
    {
        spell = SpellIDs.FeralSpirit,
        customOnEvent = "FeralSpiritEvent",
    },
    {
        spell = SpellIDs.Bloodlust,
        buff = SpellIDs.Bloodlust,
    },
    {
        spell = SpellIDs.Heroism,
        buff = SpellIDs.Heroism,
    },
}


TotemTimers.MaelstromSpells = {
    SpellIDs.LightningBolt,
    SpellIDs.ChainLightning,
    SpellIDs.HealingWave,
    SpellIDs.GreaterHealingWave,
    SpellIDs.HealingSurge,
    SpellIDs.ChainHeal,
}

TotemTimers.ProcData = {
    maelstrom = {
        buff = SpellIDs.Maelstrom,
        textures = {
            "Interface/AddOns/TotemTimers/textures/maelstrom_weapon_1",
            "Interface/AddOns/TotemTimers/textures/maelstrom_weapon_2",
            "Interface/AddOns/TotemTimers/textures/maelstrom_weapon_3",
            "Interface/AddOns/TotemTimers/textures/maelstrom_weapon_4",
            "Interface/AddOns/TotemTimers/textures/maelstrom_weapon",
        },
        flashSpells = {
            SpellIDs.LightningBolt,
            SpellIDs.ChainLightning,
            SpellIDs.HealingWave,
            SpellIDs.LesserHealingWave,
            SpellIDs.GreaterHealingWave,
            SpellIDs.ChainHeal,
            SpellIDs.Hex,
        },
        isCenter = true,
        animateOn = 5,
        glow = 5,
    },
    clearcasting = {
        buff = SpellIDs.ClearCasting,
        textures = {
            "Interface/AddOns/TotemTimers/textures/echo_of_the_elements",
        },
        --[[flashSpells = {
            SpellIDs.LightningBolt,
            SpellIDs.ChainLightning,
            SpellIDs.EarthShock,
            SpellIDs.FlameShock,
            SpellIDs.FrostShock,
            SpellIDs.LavaBurst,
            SpellIDs.LesserHealingWave,
            SpellIDs.HealingWave,
            SpellIDs.ChainHeal,
            SpellIDs.FireNova,
        },]]
        isCenter = false,
        animateOn = 2,
    },
}