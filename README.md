# Universal UI

Standalone Roblox UI library. No game systems.

- [Source.luau](Source.luau): main library
- [Example.luau](Example.luau): controls and layout examples
- [MainUi_Universal.luau](MainUi_Universal.luau): empty starting UI
- Library.luau: compatibility loader

## Load

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Taryouknow/Universal_Ui/main/Example.luau"))()
```

## Build

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Taryouknow/Universal_Ui/main/Source.luau"))()
local Window = UI:CreateWindow({Title = "My UI", Folder = "MyUi"})
local Home = Window:Category({Title = "Home", Icon = "home"})
local Main = Home:Tab({Title = "Main", Default = true})
local Left = Main:Section({Title = "Options", Side = "Left"})
Left:Toggle({Title = "Enabled", Default = false, Callback = function(value)
    print(value)
end})
local Setting = Window:Category({Title = "Setting", Icon = "settings"})
Window:AddSettings(Setting)
Window:LoadAutoload()
```

Top icons are Categories. Each category contains Tabs. Each tab has Sections placed Left or Right. Both columns scroll independently. Icons remain centered when tabs change.

## Controls

Toggle, Checkbox, Dropdown (single/multiple, searchable), Select (single/multiple), Radio, Slider, Textbox, Keybind, ColorPicker, Button, ButtonGroup, Image, Text, Paragraph, Divider, Banner, StatGrid, Progress and Process (alias).

Most value controls return `control.Get()` and `control.Set(value)`. Text and Paragraph support Set. Progress uses values from 0 to 1: `progress.Set(.5, "50%")`. See Example for options.

`Window:Notify({Title = "Done", Content = "Saved", Duration = 4})` shows a dismissible bubble. `Window:Bubble` is an alias. Opening the menu includes a short bubble animation. Hover, click and scroll effects are enabled by default.

## Settings and configs

`Window:AddSettings(category)` adds App and Configs tabs. App contains theme/accent color, scale, opacity, floating-button visibility and size. Configs supports named saves, loads, deletes and autoload. Files are local under `<Folder>/configs`; executor file APIs are required. Saved configs contain control values and appearance. Choose a saved config and Set autoload to restore it on the next launch.

`Window:SaveConfig("name")`, `Window:LoadConfig("name")`, `Window:LoadAutoload()` are available directly. Keep the same control order when sharing configs across versions.

## Images

`Logo`, `FloatLogo` and `ProfileImage` accept Roblox image content IDs. ProfileImage has a transparent background and no round mask. PNG navigation icons are downloaded and cached locally; file and custom-asset APIs are needed. `AssetUrl` can override the raw asset base URL.

RightShift toggles the menu. The floating button can be dragged. Reloading replaces the previous Universal UI window. `Window:Unload()` closes and cleans up the UI.
