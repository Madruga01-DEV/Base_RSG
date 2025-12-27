local isActive = false
local displayInfo = true
local targetEntity = nil
local lastEntityInfo = nil

---@param entity number The entity handle
---@return string The model hash as string
local function GetEntityModelName(entity)
    local hash = GetEntityModel(entity)
    return tostring(hash)
end

---@param entity number The entity handle
---@return table|nil Entity information or nil if entity doesn't exist
local function GetEntityInfo(entity)
    if not DoesEntityExist(entity) then return nil end
    
    local coords = GetEntityCoords(entity)
    local rotation = GetEntityRotation(entity, 2)
    local heading = GetEntityHeading(entity)
    local hash = GetEntityModel(entity)
    local hashStr = tostring(hash)
    local entityType = GetEntityType(entity)
    
    local entityTypeStr = "Unknown"
    if entityType == 1 then entityTypeStr = "Ped"
    elseif entityType == 2 then entityTypeStr = "Vehicle"
    elseif entityType == 3 then entityTypeStr = "Object" end
    
    local networkId = 'N/A'
    if NetworkGetEntityIsNetworked(entity) then
        networkId = NetworkGetNetworkIdFromEntity(entity)
    end
    
    return {
        entity = entity,
        hash = hash,
        hashStr = hashStr,
        coords = coords,
        rotation = rotation,
        heading = heading,
        type = entityTypeStr,
        networkId = networkId
    }
end

---@param entity number The entity handle
local function UpdateEntityInfo(entity)
    if not entity or not DoesEntityExist(entity) then return end
    
    lastEntityInfo = GetEntityInfo(entity)
    
    SendNUIMessage({
        type = 'updateInfo',
        info = lastEntityInfo
    })
end

---@param format string Format to copy ('model', 'coords', 'rotation', 'heading', 'all')
local function CopyInfo(format)
    if not lastEntityInfo then 
        Notify("No entity information available", "error", 3000)
        return 
    end
    
    SendNUIMessage({
        type = 'copyFormat',
        format = format,
        info = lastEntityInfo
    })
end

RegisterNUICallback('clipboardResult', function(data, cb)
    if not data.success then
        Notify("Failed to copy to clipboard", "error", 3000)
    end
    cb('ok')
end)

RegisterNUICallback('copyToClipboard', function(data, cb)
    local text = data.text
    if text and text ~= '' then
        SendNUIMessage({
            type = 'execCopy',
            text = text,
            format = data.format
        })

        Notify('Copied to clipboard: ' .. data.format, 'success', 1000)
    else
        Notify('Failed to copy text', 'error', 1000)
    end
    cb('ok')
end)

---@param rotation vector3 Camera rotation
---@return vector3 Direction vector
local function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    
    return vector3(direction.x, direction.y, direction.z)
end

---@param distance number Maximum distance to raycast
---@return number, vector3, number hit, endCoords, entityHit
local function RaycastCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    
    local _, hit, endCoords, _, entityHit = GetShapeTestResult(
        StartShapeTestRay(
            cameraCoord.x, cameraCoord.y, cameraCoord.z,
            destination.x, destination.y, destination.z,
            -1, PlayerPedId(), 0
        )
    )
    
    return hit, endCoords, entityHit
end

---@class PropInfoMode Stops the prop info mode
local function StopPropInfoMode()
    isActive = false
    displayInfo = false
    targetEntity = nil
    
    SendNUIMessage({
        type = 'showUI',
        show = false
    })
    
    SendNUIMessage({
        type = 'showNoEntity',
        show = false
    })
    
    SendNUIMessage({
        type = 'updateInfo',
        info = nil
    })
    
    Notify("Entity Info Mode deactivated", "error", Config.Notifications.duration.standard)
end

---@class PropInfoMode Starts the prop info mode
local function StartPropInfoMode()
    isActive = true
    displayInfo = true
    
    SendNUIMessage({
        type = 'showUI',
        show = true
    })
    
    Notify("Entity Info Mode activated", "success", Config.Notifications.duration.standard)
    
    CreateThread(function()
        while isActive do
            Wait(0)
            
            local playerPed = PlayerPedId()
            
            local hit, endCoords, entityHit = RaycastCamera(Config.Raycast.maxDistance)
                
            if hit == 1 and DoesEntityExist(entityHit) then
                targetEntity = entityHit
                
                local playerPos = GetEntityCoords(playerPed)
                
                if Config.Raycast.drawLine then
                    DrawLine(
                        playerPos.x, playerPos.y, playerPos.z,
                        endCoords.x, endCoords.y, endCoords.z,
                        Config.Raycast.lineColor[1], Config.Raycast.lineColor[2], 
                        Config.Raycast.lineColor[3], Config.Raycast.lineColor[4]
                    )
                end
                
                if Config.Raycast.drawMarker then
                    DrawMarker(0x50638AB9, endCoords.x, endCoords.y, endCoords.z, 
                              0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 
                              Config.Raycast.markerSize, Config.Raycast.markerSize, Config.Raycast.markerSize, 
                              Config.Raycast.markerColor[1], Config.Raycast.markerColor[2], 
                              Config.Raycast.markerColor[3], Config.Raycast.markerColor[4], 
                              false, false, 2, false, nil, nil, false)
                end
                
                if displayInfo then
                    UpdateEntityInfo(entityHit)
                    SendNUIMessage({
                        type = 'showUI',
                        show = true
                    })
                end
                
                SendNUIMessage({
                    type = 'showNoEntity',
                    show = false
                })
                
                if IsControlJustReleased(0, Config.Keys.copyModel) then
                    CopyInfo('model')
                elseif IsControlJustReleased(0, Config.Keys.copyCoords) then
                    CopyInfo('coords')
                elseif IsControlJustReleased(0, Config.Keys.copyRotation) then
                    CopyInfo('rotation')
                elseif IsControlJustReleased(0, Config.Keys.copyHeading) then
                    CopyInfo('heading')
                elseif IsControlJustReleased(0, Config.Keys.copyAll) then
                    CopyInfo('all')
                elseif IsControlJustReleased(0, Config.Keys.toggle) then
                    displayInfo = not displayInfo
                    SendNUIMessage({
                        type = 'showUI',
                        show = displayInfo
                    })
                    Notify("Info display: " .. (displayInfo and "ON" or "OFF"), "primary", Config.Notifications.duration.short)
                end
            else
                SendNUIMessage({
                    type = 'showNoEntity',
                    show = true
                })
                
                if targetEntity then
                    targetEntity = nil
                    SendNUIMessage({
                        type = 'showUI',
                        show = false
                    })
                end
            end
        end
    end)
end

RegisterCommand(Config.Commands.main, function()
    if isActive then
        StopPropInfoMode()
    else
        StartPropInfoMode()
    end
end, false)
TriggerEvent("chat:addSuggestion", "/"..Config.Commands.main, "Toggle display of entity information", {})
