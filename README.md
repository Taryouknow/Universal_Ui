# Universal UI

UI base with tabs, controls and configs.

- `Source.luau` — library
- `Example.luau` — try the controls
- `MainUi_Universal.luau` — empty UI to start with
- `assets/` — icons and logo

## Try it

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Taryouknow/Universal_Ui/main/Example.luau?v=8"))()
```

Category is the top menu. Tab is the page below it. Section holds your controls; use `Left` or `Right`.

Check Example for switches, dropdowns, mode buttons, colors, images and progress bars.

Setting has App and Configs. Changes reset when you reopen. Save and load configs yourself; files stay on your device.

RightShift opens the menu. You can drag the floating button.
