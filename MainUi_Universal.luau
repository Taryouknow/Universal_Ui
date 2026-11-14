local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Taryouknow/Universal_Ui/main/Library.luau"))()

local Window = UI:CreateWindow({
	Title = "UNIVERSAL",
	Author = "TaTarzx",
	Version = "v1.0",
	Logo = "rbxassetid://99287950951825",
	FloatLogo = "rbxassetid://120549670549494",
	Folder = "Universal_Ui",
	Width = 900,
	Height = 660,
})

Window:SidebarSection("Menu")

local Home = Window:Tab({
	Title = "Home",
	Icon = "home",
	Default = true,
})

local Main = Window:Tab({
	Title = "Main",
	Icon = "main",
})

Window:SidebarSection("System")

local Settings = Window:Tab({
	Title = "Setting",
	Icon = "settings",
})

local Interface = Settings:Section({ Title = "Interface", Side = "Left" })

Interface:Slider({
	Title = "Scale",
	Min = 60,
	Max = 110,
	Default = 100,
	Suffix = "%",
	Callback = function(value)
		Window.Appearance.Scale = value
		Window:ApplyAppearance()
	end,
})

Interface:Toggle({
	Title = "Motion",
	Default = true,
	Callback = function(value)
		Window:SetMotion(value)
	end,
})

Interface:Toggle({
	Title = "Smooth scroll",
	Default = true,
	Callback = function(value)
		Window:SetSmoothScroll(value)
	end,
})

Interface:Toggle({
	Title = "Click sound",
	Default = true,
	Callback = function(value)
		Window:SetSound(value)
	end,
})

Interface:Slider({
	Title = "Volume",
	Min = 0,
	Max = 100,
	Default = 15,
	Suffix = "%",
	Callback = function(value)
		Window:SetVolume(value / 100)
	end,
})

Interface:Keybind({
	Title = "Menu key",
	Default = Enum.KeyCode.RightShift,
	Callback = function(key)
		Window.Native:SetKeybind(key)
	end,
})

Settings:Section({ Title = "Config", Side = "Right" }):ConfigManager()

Window:LoadAutoload()

return Window
