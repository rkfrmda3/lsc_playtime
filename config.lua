Config = {
    -- esx = es_extended, qb = qb-core
    Framework = "qb",

    -- If you use ox inventory make sure this is turned to true!
    OxInventory = false,
    
    -- Amount of hours needed to use weapons
    RequiredHours = 10,

    -- Jobs that don't require playtime to access weapons.
    BypassJobs = {
        'police',
        'sheriff',
    },

     -- Weapons that automaticly bypass the RequiredHours.
    BypassWeapons = {
        'WEAPON_JERRYCAN',
        'WEAPON_NEWSPAPER',
        'WEAPON_NIGHTSTICK',
    },
}