if Config.OxInventory then
    AddEventHandler('ox_inventory:currentWeapon', function(weapon)
        if weapon then
            if Config.BypassWeapons then
                for _, bypassWeapon in ipairs(Config.BypassWeapons) do
                    if weapon.name:upper() == bypassWeapon:upper() then
                        return
                    end
                end
            end
            TriggerServerEvent('lsc_playtime:checkWeapon', weapon)
        end
    end)
else
    CreateThread(function()
        while true do
            local weapon = GetSelectedPedWeapon(PlayerPedId())
            if weapon ~= -1569615261 then -- Unarmed
                local weaponName = 'WEAPON_' .. string.upper(weapon)
                if Config.BypassWeapons then
                    local isAllowed = false
                    for _, bypassWeapon in ipairs(Config.BypassWeapons) do
                        if weaponName == bypassWeapon:upper() then
                            isAllowed = true
                            break
                        end
                    end
                    if not isAllowed then
                        TriggerServerEvent('lsc_playtime:checkWeapon', { name = weaponName })
                    end
                end
            end
            Wait(1000)
        end
    end)
end

RegisterNetEvent('lsc_playtime:removeWeapon')
AddEventHandler('lsc_playtime:removeWeapon', function()
    local ped = PlayerPedId()
    RemoveAllPedWeapons(ped, true)
end)