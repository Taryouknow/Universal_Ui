# Universal UI

A blank Roblox UI with Home, Main and Setting. No game scripts are loaded.

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Taryouknow/Universal_Ui/main/Library.luau"))()

local Window = UI:CreateWindow({
    Title = "UNIVERSAL",
    Author = "TaTarzx",
    Folder = "Universal_Ui",
    Logo = "rbxassetid://120549670549494",
    FloatLogo = "rbxassetid://99287950951825",
})

Window:SidebarSection("Menu")

local Home = Window:Tab({ Title = "Home", Icon = "home", Default = true })
local Main = Window:Tab({ Title = "Main", Icon = "main" })
local Settings = Window:Tab({ Title = "Setting", Icon = "settings" })
```

## Add controls

```lua
local General = Main:Section({ Title = "General", Side = "Left" })

General:Toggle({
    Title = "Enabled",
    Default = false,
    Callback = function(value)
        print(value)
    end,
})

General:Slider({ Title = "Speed", Min = 0, Max = 100, Default = 50 })
General:Dropdown({ Title = "Mode", Options = { "A", "B" }, Default = "A" })
General:Textbox({ Title = "Name", Default = "" })
General:Button({ Title = "Run", Callback = function() end })
```

`Main:Category({ Title = "Other" })` adds a subcategory. It has the same `Section` method.
The top navigation, categories and both content columns scroll independently.

## Settings

`MainUi_Universal.luau` is the ready-to-run blank template. It includes scale,
motion, smooth scrolling, click sound, volume, menu key and a config manager.
Right Shift or the floating logo opens/closes the window.

Controls return `Set(value, fire)` and `Get()`. Use `Set(value, false)` for a silent update.
The window supports `SetVisible`, `Unload`, `SaveConfig`, `LoadConfig` and `LoadAutoload`.
Configs stay in the executor workspace, under the configured folder.

This library uses ordinary Roblox GUI instances and does not promise concealment.
