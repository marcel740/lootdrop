ESX = nil
local container
local blip
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterCommand('loadDrop', function(source, args, rawCommand)
    ESX.TriggerServerCallback('drop:getgroup', function(group) 
        if group == "Highteam" then
            ESX.TriggerServerCallback('drop:getstatus', function(status) 
               if status == false then
                    setDrop()
               else
                    TriggerEvent('marcel_notify', 'red', 'DROP', 'Es wurde bereits ein Drop Rausgelassen')
               end
            end)
        else
            TriggerEvent('marcel_notify', 'red', 'DROP', 'Du hast dazu keine Berechtigung.')
        end
    end)
end)

function setDrop()
    TriggerEvent('marcel_notify', 'green', 'DROP', 'Drop wurde rausgelassen.')
    local random = math.random(1, #marcel.positions)
    local position = GetEntityCoords(PlayerPedId()) 
    TriggerServerEvent('drop:savePos', position)
    
    Wait(10)
    TriggerServerEvent('drop:setDrop', true)
    container = CreateObject('prop_container_03mb', position, true, false)
    SetEntityCoords(PlayerPedId(), position.x, position.y, position.z+2.5)
end

RegisterNetEvent('drop:showBlips')
AddEventHandler('drop:showBlips', function(position)
    print("Blip")
    blip = AddBlipForCoord(position)
    SetBlipSprite(blip, 677)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 69)
    SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("DROP")
    EndTextCommandSetBlipName(blip)
end)

RegisterNetEvent('drop:removeBlips')
AddEventHandler('drop:removeBlips', function(blip)
    print("BLIP WEG")
    RemoveBlip(blip)
end)



local amaufmachen = false

CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 38) then
            ESX.TriggerServerCallback('drop:getpos', function(position) 
                local pCoords = GetEntityCoords(PlayerPedId())
                local dist = Vdist(pCoords, position)
                --[[ print(dist) ]]
                if dist <= 3.50 then
                    ESX.TriggerServerCallback('drop:getstatus', function(status)
                        if status == true then
                            ESX.TriggerServerCallback('drop:hasItem', function(item)
                                ESX.TriggerServerCallback('drop:getaufmachen', function(status_auf)
                                    print(status_auf)
                                    if status_auf == false then
                                        if item >= 1 then
                                            TriggerServerEvent('drop:setAufmachen', true)
                                            amaufmachen = true
                                            ClearPedTasksImmediately(PlayerPedId())
                                            TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_WELDING', '0', true)
                                            startProgress(marcel.time)
                                            Wait(marcel.time)
                                            ClearPedTasksImmediately(PlayerPedId())
                                            TriggerServerEvent('drop:setAufmachen', false)
                                            TriggerServerEvent('drop:setDrop', false)
                                            TriggerEvent('marcel_notify', 'green', 'DROP', 'Du hast erfolgreich den Drop geöffnet.')
                                            TriggerEvent('marcel_notify', 'green', 'DROP', 'Du hast 1x MG bekommen.')
                                            ESX.TriggerServerCallback('drop:getplayername', function(name) 
                                                TriggerServerEvent('drop:playerOpened', name)
                                                DeleteObject(container)
                                                amaufmachen = false
                                            end)
                                        else
                                            TriggerEvent('marcel_notify', 'red', 'DROP', 'Du hast kein bolzenschneider.')
                                        end
                                    else
                                        TriggerEvent('marcel_notify', 'red', 'DROP', 'Der Drop wird bereitsgeöffnet.')
                                    end
                                end)
                            end)
                        end
                    end)
                end
            end)
        end
    end
end)

function startProgress(time)
    TriggerEvent('healingv2:progress_status', "start", time)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if amaufmachen == true then
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 38, true)
        end
    end
end)

--Citizen.CreateThread(function()
--
--    while true do
--        Citizen.Wait(1)
--        if amaufmachen == true then
--            DisableAllControlActions(0)
--            EnableControlAction(0, 1, true)
--            EnableControlAction(0, 2, true)
--            EnableControlAction(0, 38, true)
--        end
--        if IsControlJustReleased(0, 38) then
--            penisaufhoeren()
--        end
--    end
--
--end)
--
--function penisaufhoeren()
--    if amaufmachen == true then
--    ClearPedTasksImmediately(PlayerPedId())
--    amaufmachen = false
--    status_auf = false
--    TriggerEvent('healingv2:progress_status', "stop")
--    end
--end 
