if Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local function getPlayerTime(playerId)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if not xPlayer then return end
        local playtime = xPlayer.getPlayTime()
        local days = math.floor(playtime / 86400)
        local hours = math.floor((playtime % 86400) / 3600)
        local minutes = math.floor((playtime % 3600) / 60)
        local totalHours = (days * 24) + hours

        return {
            days = days,
            hours = hours,
            minutes = minutes,
            totalHours = totalHours
        }
    elseif Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(playerId)
        if not Player then return end
        
        local result = MySQL.scalar.await('SELECT playtime FROM players WHERE citizenid = ?', {Player.PlayerData.citizenid})
        local playtime = result or 0
        local days = math.floor(playtime / 1440)
        local hours = math.floor((playtime % 1440) / 60)
        local minutes = playtime % 60
        local totalHours = math.floor(playtime / 60)

        return {
            days = days,
            hours = hours,
            minutes = minutes,
            totalHours = totalHours
        }
    end
end

exports('getPlayerTime', getPlayerTime)

-- exports.lsc_playtime:getPlayerTime(playerId) or exports['lsc_playtime']:getPlayerTime(playerId)

if Config.Framework == 'esx' then
    local function checkPlaytime(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if not xPlayer then return end

        if Config.BypassJobs then
            for _, job in ipairs(Config.BypassJobs) do
                if xPlayer.job.name == job then
                    return true
                end
            end
        end

        local time = getPlayerTime(playerId)
        if not time then return end

        if time.totalHours < Config.RequiredHours then
            if Config.OxInventory then
                TriggerClientEvent('ox_inventory:disarm', playerId, false)
            else
                TriggerClientEvent('lsc_playtime:removeWeapon', playerId)
            end
            TriggerClientEvent('chat:addMessage', playerId, {
                template = '^1[ ! ]^7 You need {0} hours of playtime to use weapons.',
                args = { Config.RequiredHours }
            })
            return false
        end
        return true
    end

    RegisterNetEvent('lsc_playtime:checkWeapon')
    AddEventHandler('lsc_playtime:checkWeapon', function(weapon)
        local playerId = source
        if not checkPlaytime(playerId) then
            Wait(100)
            if Config.OxInventory then
                TriggerClientEvent('ox_inventory:disarm', playerId, false)
            else
                TriggerClientEvent('lsc_playtime:removeWeapon', playerId)
            end
        end
    end)

elseif Config.Framework == 'qb' then
    CreateThread(function()
        while true do
            local players = QBCore.Functions.GetQBPlayers()
            for _, Player in pairs(players) do
                MySQL.update('UPDATE players SET playtime = playtime + 1 WHERE citizenid = ?', {Player.PlayerData.citizenid})
            end
            Wait(60000)
        end
    end)

    local function checkPlaytime(playerId)
        local Player = QBCore.Functions.GetPlayer(playerId)
        if not Player then return end

        if Config.BypassJobs then
            for _, job in ipairs(Config.BypassJobs) do
                if Player.PlayerData.job.name == job then
                    return true
                end
            end
        end

        local time = getPlayerTime(playerId)
        if not time then return end

        if time.totalHours < Config.RequiredHours then
            if Config.OxInventory then
                TriggerClientEvent('ox_inventory:disarm', playerId, false)
            else
                TriggerClientEvent('lsc_playtime:removeWeapon', playerId)
            end
            TriggerClientEvent('chat:addMessage', playerId, {
                template = '^1[ ! ]^7 You need {0} hours of playtime to use weapons.',
                args = { Config.RequiredHours }
            })
            return false
        end
        return true
    end

    RegisterNetEvent('lsc_playtime:checkWeapon')
    AddEventHandler('lsc_playtime:checkWeapon', function(weapon)
        local playerId = source
        if not checkPlaytime(playerId) then
            Wait(100)
            if Config.OxInventory then
                TriggerClientEvent('ox_inventory:disarm', playerId, false)
            else
                TriggerClientEvent('lsc_playtime:removeWeapon', playerId)
            end
        end
    end)
end

lib.addCommand({'pt', 'playtime'}, {
    help = 'Check your playtime'
}, function(source, args, raw)
    local time = getPlayerTime(source)
    if time then
        TriggerClientEvent('chat:addMessage', source, {
            template = '^1[ ! ]^7 Your current playtime is ^3{0} days, {1} hours, {2} minutes.^7',
            args = { time.days, time.hours, time.minutes }
        })
    end
end)
