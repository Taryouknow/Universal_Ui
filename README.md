# Universal UI

`Source.luau` is the library. `Example.luau` has the controls and Dashboard.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Taryouknow/Universal_Ui/main/Example.luau?v=final"))()
```

Top menu: Category > Tab > Section. Sections use `Left` or `Right`.

Changes reset on a new run. Save and load from Configs when you want to keep them.

Icons live in assets. Use `Icon = "car"` for a category or `Window:Icon("car")` for an image. See assets/icons.json for all 87 names. Icons are from Lucide; the license is in assets.

The Discord button copies the invite and tries to open Discord desktop. If Discord is closed or unavailable, paste the copied link in your browser.

RightShift toggles the menu. Drag the logo button to move it.
