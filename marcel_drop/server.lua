ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local drop = false
local savepos
local aufmachen = false

ESX.RegisterServerCallback('drop:getstatus', function(source, cb)
    cb(drop)
end)

ESX.RegisterServerCallback('drop:getaufmachen', function(source, cb)
    cb(aufmachen)
end)

ESX.RegisterServerCallback('drop:getpos', function(source, cb)
    cb(savepos)
end)

ESX.RegisterServerCallback('drop:getgroup', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local group = xPlayer.getGroup()
    cb(group)
end)

ESX.RegisterServerCallback('drop:getfrak', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local frak = xPlayer.getJob().name
    cb(frak)
end)

ESX.RegisterServerCallback('drop:hasItem', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem(marcel.item)
    cb(item.count)
end)

ESX.RegisterServerCallback('drop:getplayername', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {['identifier'] = xPlayer.getIdentifier()}, function(result)
        if result[1] then
            local name = result[1].firstname .. "_" .. result[1].lastname
            cb(name)
        end
    end)
end)

RegisterNetEvent('drop:setDrop')
AddEventHandler('drop:setDrop', function(status)
    drop = status
    TriggerClientEvent('marceldrop_announce:annouce', -1, 'Es wurde ein Drop rausgelassen, gucke auf deine Karte!')
    TriggerClientEvent('drop:showBlips', -1, savepos)
    print(drop)
end)

RegisterNetEvent('drop:savePos')
AddEventHandler('drop:savePos', function(position)
    savepos = position
end)

RegisterNetEvent('drop:setAufmachen')
AddEventHandler('drop:setAufmachen', function(status)
    aufmachen = status
    print(aufmachen)
end)

RegisterNetEvent('drop:playerOpened')
AddEventHandler('drop:playerOpened', function(name)
    TriggerClientEvent('marceldrop_announce:annouce', -1, 'Drop wurde von ' .. name .. ' geplündert.')
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addWeapon(marcel.reward, 1000)
    TriggerClientEvent('drop:removeBlips', -1)
end)