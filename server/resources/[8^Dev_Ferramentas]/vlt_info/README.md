# bs-entityinfo

This developer tool displays detailed information about entities in the game world and allows copying various properties to clipboard. Ideal for script developers and server administrators who need to inspect and extract entity data for development purposes.

![Image](https://i.imgur.com/qtbMSns.jpeg)

## Features

- Display detailed information about entities in the game world
  - Entity
  - Type
  - Model Hash
  - Network ID
  - Coords
  - Rotation
  - Heading
- Copy entity model hash, coordinates, rotation and heading to clipboard
- Configurable key bindings in config.lua
- Visual raycast line to show what entity you're targeting
- Standalone

## Preview

![Image](https://i.imgur.com/sY5AGaR.jpeg)

## Installation

1. Download the resource
2. Place it in your server's resources folder
3. Add `ensure bs-entityinfo` to your server.cfg
4. Restart your server

## Usage

Enter the command `/entityinfo` (default) to toggle the entity info display.

### Default Controls

- **E** - Copy entity coordinates
- **R** - Copy entity rotation
- **G** - Copy entity model hash
- **J** - Copy entity heading
- **Z** - Copy all entity information
- **Space** - Toggle entity info display

All key bindings can be customized in the `config.lua` file.

## Configuration

The resource is highly configurable through the `config.lua` file:

```lua
Config = {}

-- Command settings
Config.Commands = {
    main = "entityinfo",
}

-- Key bindings (RedM control hashes)
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
```

## Framework Integration

The resource automatically detects and uses notification systems from popular frameworks:

- **ox_lib**: If available, uses ox_lib notifications (RSGCore)
- **VORP**: If available, uses VORP bottom notifications
- **Fallback**: Console logging with colored prefix

You can customize the notification system in the `config.lua` file.

## Commands

- `/entityinfo` - Toggle entity info display (can be changed in config)

## License

This resource is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.