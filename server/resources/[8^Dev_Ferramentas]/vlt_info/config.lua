Config = {}

-- Command
Config.Commands = {
    main = "info",
}

-- Key bindings
Config.Keys = {
    toggle = 0xD9D0E1C0,     -- Space key
    copyModel = 0x760A9C6F,   -- G key
    copyCoords = 0xCEFD9220,  -- E key
    copyRotation = 0xE30CD707, -- R key
    copyHeading = 0xF3830D8E, -- J key
    copyAll = 0x26E9DC00,     -- Z key
}

-- Raycast settings
Config.Raycast = {
    maxDistance = 25.0,
    drawLine = true,
    lineColor = {255, 0, 0, 180}, -- RGBA
    drawMarker = true,
    markerColor = {255, 0, 0, 255}, -- RGBA
    markerSize = 0.03
}

-- Notification settings
Config.Notifications = {
    enabled = true,
    duration = {
        standard = 3000,
        short = 1000
    }
}

---@param message string The notification message
---@param type string The notification type (primary, success, error)
---@param duration number Duration in milliseconds
function Notify(message, type, duration)
    if not Config.Notifications.enabled then return end

    -- RSG / ox_lib
    if GetResourceState('ox_lib') ~= 'missing' then
        TriggerEvent('ox_lib:notify', {
            title = 'Entity Info',
            description = message,
            type = type,
            duration = duration
        })
        return
    end
    
    -- VORP
    if GetResourceState('vorp_core') ~= 'missing' then
        TriggerEvent('vorp:TipBottom', message, duration)
        return
    end

    -- Fallback F8 Console
    print("^3[ENTITY INFO]^0 " .. message)
end