currentSpeed = 0
storing = true

Citizen.CreateThread(function()
    while true do
        if storing then
            playerPed = PlayerPedId()
            playerVehicle = GetVehiclePedIsUsing(playerPed)

            if not IsEntityDead(playerPed) and DoesEntityExist(playerVehicle) and IsEntityAVehicle(playerVehicle) and storing then
                currentSpeed = GetEntitySpeed(playerVehicle) * 2.236936
            end
        end

        Citizen.Wait(20)
    end
end)

AddEventHandler("entityDamaged", function(victim, culprit, weapon, baseDamage)
    if IsEntityAVehicle(victim) then
        storing = false
        playerPed = PlayerPedId()

        if (playerPed == GetPedInVehicleSeat(victim, -1)) then
            Citizen.Wait(50)

            if currentSpeed >= Config.deploySpeed and GetEntitySpeed(victim) * 2.236936 <= currentSpeed - 10 and not Entity(victim).state.airbags and isValidVehicle(victim) then
                ToggleAirbag(victim)
            end
    
            if GetEntityHealth(victim) <= Config.damageLevel and not Entity(victim).state.airbags and isValidVehicle(victim) then
                ToggleAirbag(victim)
            end

            storing = true
        end
    end
end)

RegisterCommand("addAirbag", function ()
    playerPed = PlayerPedId()
    playerVehicle = GetVehiclePedIsUsing(playerPed)

    if not IsEntityDead(playerPed) and DoesEntityExist(playerVehicle) and IsEntityAVehicle(playerVehicle) and playerPed == GetPedInVehicleSeat(playerVehicle, -1) and not Entity(playerVehicle).state.airbags and isValidVehicle(playerVehicle) then
        ToggleAirbag(playerVehicle)
    end
end, false)

RegisterCommand("removeAirbag", function ()
    playerPed = PlayerPedId()
    playerVehicle = GetVehiclePedIsUsing(playerPed)

    if not IsEntityDead(playerPed) and DoesEntityExist(playerVehicle) and IsEntityAVehicle(playerVehicle) and playerPed == GetPedInVehicleSeat(playerVehicle, -1) and Entity(playerVehicle).state.airbags and isValidVehicle(playerVehicle) then
        RemoveAirbag(playerVehicle)
    end
end, false)

function ToggleAirbag(currVehicle)
    loadModel(Config.airbagProp)
    pCoords = GetEntityCoords(PlayerPedId())
    airbag1 = CreateObject(Config.airbagProp, pCoords.x, pCoords.y, pCoords.z, true, true, true)
    airbag2 = CreateObject(Config.airbagProp, pCoords.x, pCoords.y, pCoords.z, true, true, true)


    driverSideBone = GetEntityBoneIndexByName(currVehicle, "seat_dside_f")
    passSideBone = GetEntityBoneIndexByName(currVehicle, "seat_pside_f")
    AttachEntityToEntity(airbag1, currVehicle, driverSideBone, 0.0, 0.30, 0.40, 0.0, 0.0, 90.0, true, true, false, false, 2, true)
    AttachEntityToEntity(airbag2, currVehicle, passSideBone, 0.0, 0.40, 0.40, 0.0, 0.0, 90.0, true, true, false, false, 2, true)

    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10.0, "airbag", 1.0)

    Citizen.CreateThread(function()
        StartScreenEffect("DeathFailOut", 0, 0)
        ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)

        Citizen.Wait(3000)

        StopScreenEffect("DeathFailOut")
    end)

    Entity(currVehicle).state.airbags = true
    TriggerServerEvent("airbags:setstate", NetworkGetNetworkIdFromEntity(currVehicle), true)
end

function RemoveAirbag(entity)
    if Entity(entity).state.airbags then
        for _, object in ipairs(GetGamePool("CObject")) do
            if #(GetEntityCoords(object)-GetEntityCoords(entity)) < 6.0 and GetEntityModel(object) == Config.airbagProp then
                DeleteEntity(object)
            end
        end
    end
    TriggerServerEvent("airbags:setstate", NetworkGetNetworkIdFromEntity(entity), false)
end

function loadModel(modelName)
    while not HasModelLoaded(modelName) do
        RequestModel(modelName)
        Wait(0)
    end
end

function isValidVehicle(vehicle)
    for _, vehicleHash in ipairs(Config.exemptVehicles) do
        if GetEntityModel(vehicle) == vehicleHash then
            showHelpNotification("That vehicle does not have airbags.")
            return false
        end
    end

    for _, vehicleClass in pairs(Config.exemptClasses) do
        if GetVehicleClass(vehicle) == vehicleClass then
            showHelpNotification("That vehicle does not have airbags.")
            return false
        end
    end

    return true
end

function showHelpNotification(msg)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end