local UI = loadstring(
	game:HttpGet(
		"https://raw.githubusercontent.com/Taryouknow/Universal_Ui/28348884f7b198a3ab35e28855b29566a20cb2e8/Library/Source.luau"
	)
)()

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
local Profile = Intro:UserInfo({ Description = "V." .. game.PlaceVersion })
task.spawn(function()
	local ok, info = pcall(function()
		return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
	end)
	if ok and info and not Window.Unloaded then
		Profile.SetMap(info.Name)
	end
end)
local Community = Dashboard:Section({ Title = "Community - Support", Side = "Right" })
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
local Setting = Window:Category({ Title = "Setting", Icon = "settings" })
Window:AddSettings(Setting)

return Window
