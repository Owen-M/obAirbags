RegisterNetEvent("airbags:setstate")

AddEventHandler("airbags:setstate", function(vehiclenet, bool)
    Entity(NetworkGetEntityFromNetworkId(vehiclenet)).state.airbags = bool
end)

AddEventHandler("entityRemoved", function(entity)
    if GetEntityType(entity) == 2 then
        if Entity(entity).state.airbags then
            for i, object in ipairs(GetAllObjects()) do
                if #(GetEntityCoords(object)-GetEntityCoords(entity))<=6.0 and GetEntityModel(object) == Config.airbagProp then
                    DeleteEntity(object)
                end
            end
        end
    end
end)
