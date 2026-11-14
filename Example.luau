local UI =
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Taryouknow/Universal_Ui/main/Source.luau?v=final"))()

local Window = UI:CreateWindow({
	Title = "UNIVERSAL",
	Author = "TaTarzx",
	Version = "1.0",
	Logo = "rbxassetid://120549670549494",
	FloatLogo = "rbxassetid://99287950951825",
	Folder = "Universal_Ui",
	Width = 900,
	Height = 660,
})

local Home = Window:Category({ Title = "Home", Icon = "home" })
local Dashboard = Home:Tab({ Title = "Dashboard", Default = true })
local Main = Window:Category({ Title = "Main", Icon = "main" })
local General = Main:Tab({ Title = "General" })

local Intro = Dashboard:Section({ Title = "Welcome", Side = "Left" })
local Profile = Intro:UserInfo()
task.spawn(function()
	local ok, info = pcall(function()
		return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
	end)
	if ok and info and not Window.Unloaded then
		Profile.SetMap(info.Name)
	end
end)
local Community = Dashboard:Section({ Title = "Logo", Side = "Right" })
Community:Image({ Image = "rbxassetid://120549670549494", Height = 178 })
Community:Paragraph({ Title = "Join Discord Server", Content = 'D0TFrosty "Area' })
local joining = false
Community:Button({
	Title = "Join Discord",
	Primary = true,
	Callback = function()
		if joining then
			return
		end
		joining = true
		task.spawn(function()
			local code = "tgv4ywuGSg"
			local link = "https://discord.gg/" .. code
			local copy = setclipboard or toclipboard
			local copied = copy and pcall(copy, link)
			local send = request or http_request or (syn and syn.request)
			local opened = false
			if send then
				local http = game:GetService("HttpService")
				for port = 6463, 6472 do
					if Window.Unloaded then
						break
					end
					local ok, response = pcall(send, {
						Url = "http://127.0.0.1:" .. port .. "/rpc?v=1",
						Method = "POST",
						Headers = { ["Content-Type"] = "application/json", ["Origin"] = "https://discord.com" },
						Body = http:JSONEncode({
							cmd = "INVITE_BROWSER",
							nonce = http:GenerateGUID(false),
							args = {
								code = code,
							},
						}),
						Timeout = 1,
					})
					if ok and type(response) == "table" and response.StatusCode == 200 then
						opened = true
						break
					end
				end
			end
			if not Window.Unloaded then
				local message = opened
						and (copied and "เปิดดิสคอร์ด - ก๊อปปี้ลิ้งดิสแล้ว" or "เปิดดิสคอร์ดแล้ว")
					or (copied and "ก๊อปปี้ลิ้งดิสแล้ว" or link)
				Window:Notify({ Title = "Discord", Content = message, Duration = 5 })
			end
			joining = false
		end)
	end,
})
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
Choices:Divider()
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

local Icons = Display:Section({ Title = "Icons", Side = "Right" })
local IconPreview
Icons:Dropdown({
	Title = "Icon",
	Options = UI.Icons,
	Default = "car",
	Callback = function(name)
		if IconPreview then
			IconPreview.Set(Window:Icon(name))
		end
	end,
})
IconPreview = Icons:Image({ Image = Window:Icon("car"), Height = 64 })

local Setting = Window:Category({ Title = "Setting", Icon = "settings" })
Window:AddSettings(Setting)

return Window
