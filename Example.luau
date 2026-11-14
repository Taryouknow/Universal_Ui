local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Taryouknow/Universal_Ui/main/Source.luau?v=3"))()

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

local Intro = Overview:Section({ Title = "Welcome", Side = "Left" })
Intro:Banner({ Title = "UNIVERSAL", SubTitle = "UI EXAMPLE" })
Intro:Paragraph({ Title = "Start here", Content = "Category > Tab > Section. Each column scrolls on its own." })
Intro:Text({ Text = "A clean base for your next UI." })
Intro:Button({
	Title = "Show bubble",
	Callback = function()
		Window:Bubble({ Title = "Hello", Content = "Your UI is ready.", Duration = 4 })
	end,
})
local Preview = Overview:Section({ Title = "Preview", Side = "Right" })
Preview:Image({ Image = "rbxassetid://120549670549494", Height = 150, Caption = "Transparent image" })
Preview:StatGrid({ { Label = "Version", Value = "3.0" }, { Label = "Status", Value = "Ready" } })
local Inputs = General:Section({ Title = "Inputs", Side = "Left" })
Inputs:Toggle({
	Title = "Enabled",
	Default = false,
	Callback = function(value)
		print("Enabled", value)
	end,
})
Inputs:Checkbox({ Title = "Checkbox", Default = true })
Inputs:Slider({ Title = "Amount", Min = 0, Max = 100, Default = 50, Suffix = "%" })
Inputs:Textbox({ Title = "Name", Default = "Player", Placeholder = "Type here" })
Inputs:Dropdown({ Title = "Mode", Options = { "Normal", "Fast", "Custom" }, Default = "Normal" })
Inputs:Dropdown({ Title = "Multiple", Options = { "One", "Two", "Three" }, Default = { "One" }, Multi = true })
Inputs:Keybind({ Title = "Shortcut", Default = Enum.KeyCode.F })
Inputs:ColorPicker({ Title = "Color", Default = "8D47FF" })
local Choices = General:Section({ Title = "Select", Side = "Right" })
Choices:Select({ Title = "Choice", Options = { "Small", "Medium", "Large" }, Default = "Medium" })
Choices:Select({ Title = "Many", Options = { "Red", "Green", "Blue" }, Default = { "Red" }, Multi = true })
Choices:Radio({ Title = "Radio", Options = { "A", "B" }, Default = "A" })
Choices:Divider("Actions")
Choices:ButtonGroup({
	Buttons = {
		{
			Title = "Hello",
			Callback = function()
				Window:Notify({ Title = "Hello" })
			end,
		},
		{
			Title = "Done",
			Callback = function()
				Window:Notify({ Title = "Done" })
			end,
		},
	},
})
local Display = Main:Tab({ Title = "Display" })
local Status = Display:Section({ Title = "Progress", Side = "Left" })
local Progress = Status:Progress({ Title = "Ready", Default = 0.35 })
Status:Button({
	Title = "Run demo",
	Callback = function()
		task.spawn(function()
			for step = 0, 20 do
				if Window.Destroyed then
					return
				end
				Progress.Set(step / 20, "Loading " .. step * 5 .. "%")
				task.wait(0.08)
			end
			Window:Notify({ Title = "Complete", Content = "Progress reached 100%." })
		end)
	end,
})
Status:Process({ Title = "Process alias", Default = 0.7 })
local Copy = Display:Section({ Title = "Text", Side = "Right" })
local Caption = Copy:Text({ Text = "Text can be updated." })
local Paragraph =
	Copy:Paragraph({ Title = "Paragraph", Content = "Longer text wraps inside the section automatically." })
Copy:Button({
	Title = "Update text",
	Callback = function()
		Caption.Set("Updated")
		Paragraph.Set("You can update a paragraph too.")
	end,
})
getgenv().__UniversalExample = { Progress = Progress, Text = Caption }

local Setting = Window:Category({ Title = "Setting", Icon = "settings" })
Window:AddSettings(Setting)
Window:LoadAutoload()

return Window

