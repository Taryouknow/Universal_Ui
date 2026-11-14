# Universal UI

`MainUi_Universal.luau` is the personal UI with Dashboard and settings.

`Library/Source.luau` is the library. `Library/Example.luau` has the full control examples.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Taryouknow/Universal_Ui/main/Library/Example.luau"))()
```

Drag the top bar and the lower tab bar to move each panel separately.

Category > Tab > Section. Sections use Left or Right.

Changes reset on a new run. Save and load from Configs yourself.

Use `Icon = "car"` or `Window:Icon("car")`. All 87 names are in assets/icons.json. Lucide license is in assets.
