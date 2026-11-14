local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Taryouknow/Universal_Ui/main/Source.luau?v=7"))()

local Window = UI:CreateWindow({
	Title = "UNIVERSAL",
	Author = "TaTarzx",
	Version = "v3",
	Logo = "rbxassetid://120549670549494",
	FloatLogo = "rbxassetid://99287950951825",
	Folder = "Universal_Ui",
	Width = 900,
	Height = 660,
})

local Home = Window:Category({ Title = "Home", Icon = "home" })
local Overview = Home:Tab({ Title = "Overview", Default = true })
local Main = Window:Category({ Title = "Main", Icon = "main" })
local General = Main:Tab({ Title = "General" })

local Setting = Window:Category({ Title = "Setting", Icon = "settings" })
Window:AddSettings(Setting)
Window:LoadAutoload()

return Window
