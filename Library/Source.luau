local Library = {}
Library.Icons = {
	"activity",
	"airplay",
	"archive",
	"arrow-down",
	"arrow-left",
	"arrow-right",
	"arrow-up",
	"bell",
	"bookmark",
	"box",
	"briefcase",
	"calendar",
	"camera",
	"car",
	"chart-column",
	"check",
	"chevron-down",
	"chevron-left",
	"chevron-right",
	"chevron-up",
	"clipboard",
	"clock",
	"cloud",
	"code",
	"compass",
	"copy",
	"credit-card",
	"download",
	"ellipsis",
	"eye",
	"eye-off",
	"file",
	"file-code",
	"flag",
	"folder",
	"gamepad-2",
	"gauge",
	"globe",
	"heart",
	"house",
	"image",
	"info",
	"key",
	"keyboard",
	"layers",
	"layout-dashboard",
	"link",
	"list",
	"lock",
	"log-in",
	"log-out",
	"mail",
	"map",
	"map-pin",
	"menu",
	"message-circle",
	"monitor",
	"moon",
	"mouse-pointer",
	"palette",
	"pause",
	"play",
	"plus",
	"power",
	"refresh-cw",
	"rocket",
	"save",
	"search",
	"settings",
	"shield",
	"shopping-cart",
	"sliders-horizontal",
	"smartphone",
	"sparkles",
	"star",
	"sun",
	"terminal",
	"trophy",
	"upload",
	"user",
	"users",
	"volume-2",
	"wallet",
	"wifi",
	"wrench",
	"x",
	"zap",
}

function Library:CreateWindow(options)
	options = options or {}
	local env = getgenv()
	local player = game:GetService("Players").LocalPlayer
	local previous = env.__UniversalWindow
	if previous then
		previous:Unload()
	end
	local Runtime = { Alive = true, Connections = {} }
	function Runtime:Connect(signal, fn)
		local connection = signal:Connect(fn)
		self.Connections[#self.Connections + 1] = connection
		return connection
	end
	local Http = game:GetService("HttpService")
	local TweenService = game:GetService("TweenService")
	local Input = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local palette = {
		base = Color3.fromRGB(22, 20, 27),
		panel = Color3.fromRGB(15, 14, 20),
		text = Color3.fromRGB(238, 238, 240),
		dim = Color3.fromRGB(133, 133, 138),
		line = Color3.fromRGB(43, 39, 50),
		accent = Color3.fromRGB(141, 71, 255),
		check = Color3.fromRGB(98, 121, 251),
	}
	local surfaces = {}
	local styleButton
	local trackScroll
	local function make(class, props, parent)
		local obj = Instance.new(class)
		for key, value in pairs(props) do
			obj[key] = value
		end
		obj.Parent = parent
		if class == "ScrollingFrame" and trackScroll then
			trackScroll(obj)
		end
		return obj
	end
	local function round(obj, radius)
		make("UICorner", { CornerRadius = UDim.new(0, radius) }, obj)
	end
	local function surface(parent, name, size, pos, color)
		local f = make("Frame", {
			Name = name,
			Size = size,
			Position = pos or UDim2.new(),
			BackgroundColor3 = color or palette.panel,
			BorderSizePixel = 0,
		}, parent)
		surfaces[#surfaces + 1] = f
		make("UIStroke", { Color = palette.line, Thickness = 1, Transparency = 0.4 }, f)
		return f
	end
	local function text(parent, value, size, pos, fontSize, color)
		return make("TextLabel", {
			BackgroundTransparency = 1,
			Size = size,
			Position = pos or UDim2.new(),
			Text = tostring(value),
			Font = Enum.Font.Gotham,
			TextSize = fontSize or 14,
			TextColor3 = color or palette.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, parent)
	end
	local function button(parent, value, size, pos)
		local b = make("TextButton", {
			BackgroundTransparency = 1,
			Size = size,
			Position = pos or UDim2.new(),
			Text = value,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = palette.text,
			AutoButtonColor = false,
		}, parent)
		if parent.Name == "Options" or parent.Name == "Tabs" or parent.Name == "Navigation" then
			b:SetAttribute("HoverStyle", "Highlight")
		end
		if styleButton then
			styleButton(b)
		end
		return b
	end
	local function callback(fn)
		return function(...)
			if not Runtime.Alive then
				return
			end
			local elevate = setthreadidentity or setidentity
			if elevate then
				elevate(8)
			end
			local ok, err = pcall(fn or function() end, ...)
			if not ok then
				Runtime.LastUIError = tostring(err)
			end
		end
	end
	local function uiRuntimeConnect(signal, fn)
		return Runtime:Connect(signal, callback(fn))
	end
	local icons = {}
	local assetUrl = options.AssetUrl or "https://raw.githubusercontent.com/Taryouknow/Universal_Ui/main/assets/"
	for _, name in ipairs({ "home", "main", "settings" }) do
		local path = (options.Folder or "Universal_Ui") .. "/assets/v3/" .. name .. ".png"
		if not isfile(path) then
			writefile(path, game:HttpGet(assetUrl .. name .. ".png?v=3"))
		end
		icons[name] = { Image = getcustomasset(path) }
	end

	local function iconImage(name)
		local aliases = { home = "house", main = "layers" }
		name = aliases[name] or name or "layers"
		if name:find("rbxasset", 1, true) then
			return name
		end
		if not table.find(Library.Icons, name) then
			name = "layers"
		end
		local path = (options.Folder or "Universal_Ui") .. "/assets/icons/" .. name .. ".png"
		local ok, result = pcall(function()
			if not isfile(path) then
				writefile(path, game:HttpGet(assetUrl .. name .. ".png?v=final"))
			end
			return getcustomasset(path)
		end)
		return ok and result or icons.main.Image
	end

	local function logoImage(value)
		local file = value == "rbxassetid://120549670549494" and "logo"
			or value == "rbxassetid://99287950951825" and "float-logo"
		if not file then
			return value
		end
		local path = (options.Folder or "Universal_Ui") .. "/assets/v4/" .. file .. ".png"
		local ok, result = pcall(function()
			if not isfile(path) then
				writefile(path, game:HttpGet(assetUrl .. file .. ".png?v=4"))
			end
			return getcustomasset(path)
		end)
		return ok and result or value
	end

	local gui = make("ScreenGui", {
		Name = "UniversalUi",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 30,
	}, gethui() or player:WaitForChild("PlayerGui"))
	local root = make("Frame", {
		ClipsDescendants = false,
		Name = "Base",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(options.Width or 900, options.Height or 660),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
	}, gui)
	local scale = make("UIScale", { Scale = 1 }, root)
	local header = surface(root, "Header", UDim2.new(1, 0, 0, 76))
	header.Active = true
	round(header, 10)
	make("ImageLabel", {
		Name = "Logo",
		BackgroundTransparency = 1,
		Image = logoImage(options.Logo or "rbxassetid://120549670549494"),
		ScaleType = Enum.ScaleType.Fit,
		Position = UDim2.fromOffset(6, 3),
		Size = UDim2.fromOffset(64, 64),
	}, header)
	local heading = text(header, options.Title or "UNIVERSAL", UDim2.fromOffset(132, 23), UDim2.fromOffset(70, 16), 15)
	local crumb =
		text(header, options.Version or "v1.0", UDim2.fromOffset(150, 18), UDim2.fromOffset(70, 40), 11, palette.dim)
	local avatar = make("ImageLabel", {
		Name = "ProfileImage",
		ScaleType = Enum.ScaleType.Fit,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.new(1, -165, 0, 18),
		Image = options.ProfileImage or ("rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"),
	}, header)
	local displayInfo = text(header, player.DisplayName, UDim2.fromOffset(108, 18), UDim2.new(1, -117, 0, 22), 12)
	local usernameInfo =
		text(header, "@" .. player.Name, UDim2.fromOffset(108, 14), UDim2.new(1, -117, 0, 40), 9, palette.dim)
	local shadow = make("Frame", {
		Name = "Shadow",
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(38, 114),
		Size = UDim2.new(1, -76, 1, -116),
		ZIndex = 0,
	}, root)
	round(shadow, 12)
	local body = surface(root, "Workspace", UDim2.new(1, -84, 1, -116), UDim2.fromOffset(42, 110), palette.base)
	round(body, 10)
	local tabBar = make("ScrollingFrame", {
		Name = "Tabs",
		BackgroundColor3 = palette.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -12, 0, 64),
		Position = UDim2.fromOffset(6, 6),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
	}, body)
	round(tabBar, 8)
	local nav = make("ScrollingFrame", {
		Name = "Navigation",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -440, 0, 60),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
	}, header)
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 22),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}, nav)
	local navPadding = make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, nav)
	local pages = make("Frame", {
		Name = "Pages",
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(6, 78),
		Size = UDim2.new(1, -12, 1, -84),
	}, body)
	local popup = surface(root, "Dropdown", UDim2.fromOffset(260, 240))
	popup.Visible = false
	popup.ZIndex = 50
	round(popup, 6)
	local popupSearch = make("TextBox", {
		Name = "Search",
		BackgroundColor3 = palette.base,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -16, 0, 30),
		Position = UDim2.fromOffset(8, 8),
		PlaceholderText = "Search",
		Text = "",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = palette.text,
		PlaceholderColor3 = palette.dim,
		ZIndex = 51,
	}, popup)
	round(popupSearch, 4)
	local popupList = make("ScrollingFrame", {
		Name = "Options",
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -16, 1, -48),
		Position = UDim2.fromOffset(8, 44),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(82, 78, 91),
		ScrollBarImageTransparency = 0.3,
		ZIndex = 51,
	}, popup)
	make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, popupList)
	uiRuntimeConnect(popupList:GetPropertyChangedSignal("CanvasPosition"), function()
		local mouse = Input:GetMouseLocation()
		local bounds = popupList.AbsolutePosition
		local extent = popupList.AbsoluteSize
		local inside = popup.Visible
			and mouse.X >= bounds.X
			and mouse.X <= bounds.X + extent.X
			and mouse.Y >= bounds.Y
			and mouse.Y <= bounds.Y + extent.Y
		for _, entry in ipairs(popupList:GetDescendants()) do
			if entry:IsA("TextButton") then
				local fill = entry:FindFirstChild("HoverFill")
				if fill then
					local pos, size = entry.AbsolutePosition, entry.AbsoluteSize
					local over = inside
						and mouse.X >= pos.X
						and mouse.X <= pos.X + size.X
						and mouse.Y >= pos.Y
						and mouse.Y <= pos.Y + size.Y
					fill.BackgroundTransparency = over and 0.92 or 1
				end
			end
		end
	end)

	local activeDropdown
	local function closeDropdown()
		popup.Visible = false
		if activeDropdown and activeDropdown.Arrow then
			activeDropdown.Arrow.Rotation = 0
		end
		activeDropdown = nil
	end
	local alignNavigation
	local layoutTabs
	local entrance
	local appearance = {
		Theme = "Dark",
		Accent = "8D47FF",
		RGB = false,
		HideInfo = false,
		Background = "16141B",
		Panel = "0F0E14",
		Scale = 100,
		Blur = 0,
		Transparency = 0,
		FloatingSize = 54,
		FloatingEnabled = true,
		ToggleKey = "RightShift",
		Sound = true,
		Volume = 0.15,
		Motion = true,
		SmoothScroll = true,
	}
	for name, value in pairs(options.Appearance or {}) do
		appearance[name] = value
	end
	appearance.Motion = true
	appearance.Sound = true
	appearance.SmoothScroll = true
	local blur = make("BlurEffect", { Name = "UniversalBlur", Size = 0, Enabled = false }, game:GetService("Lighting"))
	local floating = make("ImageButton", {
		Name = "Menu",
		Image = options.FloatLogo or "rbxassetid://99287950951825",
		ScaleType = Enum.ScaleType.Fit,
		BackgroundColor3 = palette.panel,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(54, 54),
		Position = UDim2.new(0, 22, 0.5, -27),
	}, gui)
	round(floating, 10)
	local Window = {
		Gui = gui,
		Native = {},
		Tabs = {},
		Controls = {},
		Appearance = appearance,
		BackgroundBlur = blur,
		Flags = {},
		Groups = {},
		Selected = nil,
		Categories = {},
		Opened = true,
	}
	local NativeWindow = Window.Native
	function NativeWindow:GetState()
		return root.Visible
	end
	function NativeWindow:Toggle()
		Window:SetVisible(not Window.Opened)
	end
	function NativeWindow:SetKeybind(key)
		appearance.ToggleKey = key.Name
	end
	function NativeWindow:SetScale(value)
		scale.Scale = value
	end
	function Window:ApplyAppearance(viewportOverride)
		avatar.Visible = true
		avatar.Image = appearance.HideInfo and (options.FloatLogo or "rbxassetid://99287950951825")
			or options.ProfileImage
			or ("rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150")
		avatar.ImageColor3 = Color3.new(1, 1, 1)
		displayInfo.Visible = true
		displayInfo.Text = appearance.HideInfo and (options.Title or "UNIVERSAL") or player.DisplayName
		usernameInfo.Visible = not appearance.HideInfo
		local viewport = viewportOverride or workspace.CurrentCamera.ViewportSize
		local width = options.Width or 900
		local height = options.Height or 660
		root.Size = UDim2.fromOffset(width, height)
		heading.Visible = true
		crumb.Visible = true
		displayInfo.Visible = true
		usernameInfo.Visible = not appearance.HideInfo
		avatar.Position = UDim2.new(1, -165, 0, 18)
		nav.Size = UDim2.new(1, -440, 0, 60)
		if not body:GetAttribute("Dragged") then
			body.Position = UDim2.fromOffset(42, 110)
		end
		body.Size = UDim2.new(1, -84, 1, -116)
		scale.Scale =
			math.max(0.1, math.min(appearance.Scale / 100, (viewport.X - 24) / width, (viewport.Y - 24) / height))
		for _, f in ipairs(surfaces) do
			if f.Parent then
				f.BackgroundTransparency = (appearance.Transparency or 0) / 100
			end
		end
		blur.Size = appearance.Blur or 0
		blur.Enabled = root.Visible and blur.Size > 0
		if alignNavigation then
			alignNavigation()
		end
		if layoutTabs and self.Selected then
			layoutTabs(self.Selected.Group)
		end
		closeDropdown()
	end
	function Window:ApplyFloating()
		floating.Visible = appearance.FloatingEnabled ~= false
		floating.Size = UDim2.fromOffset(appearance.FloatingSize or 54, appearance.FloatingSize or 54)
		NativeWindow:SetKeybind(Enum.KeyCode[appearance.ToggleKey] or Enum.KeyCode.RightShift)
	end
	function Window:Unload()
		if self.Unloaded then
			return
		end
		self.Unloaded = true
		Runtime.Alive = false
		for _, conn in ipairs(Runtime.Connections) do
			conn:Disconnect()
		end
		closeDropdown()
		blur:Destroy()
		gui:Destroy()
	end
	function NativeWindow:Unload()
		Window:Unload()
	end
	local notices = {}
	local function arrangeNotices()
		for index, note in ipairs(notices) do
			TweenService:Create(
				note,
				TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.new(1, -22, 1, -22 - (index - 1) * 86) }
			):Play()
		end
	end
	function Window:Notify(opts)
		opts = type(opts) == "table" and opts or { Title = tostring(opts) }
		local life = math.max(0.5, opts.Duration or 3)
		local note = make("CanvasGroup", {
			Name = "Bubble",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, 340, 1, -22),
			Size = UDim2.fromOffset(320, 74),
			BackgroundColor3 = palette.panel,
			BorderSizePixel = 0,
			GroupTransparency = 1,
		}, gui)
		round(note, 12)
		make("UIStroke", { Color = palette.line, Thickness = 1 }, note)
		local dot = make("Frame", {
			Size = UDim2.fromOffset(7, 7),
			Position = UDim2.fromOffset(15, 17),
			BackgroundColor3 = palette.accent,
			BorderSizePixel = 0,
		}, note)
		round(dot, 4)
		text(note, opts.Title or options.Title or "Universal", UDim2.new(1, -64, 0, 22), UDim2.fromOffset(30, 9), 14)
		local bodyText = text(
			note,
			opts.Content or opts.Description or "",
			UDim2.new(1, -42, 0, 28),
			UDim2.fromOffset(15, 32),
			12,
			palette.dim
		)
		bodyText.TextWrapped = true
		local timer = make("Frame", {
			BackgroundColor3 = palette.accent,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -2),
			Size = UDim2.new(1, 0, 0, 2),
		}, note)
		local close = button(note, "×", UDim2.fromOffset(28, 28), UDim2.new(1, -32, 0, 4))
		table.insert(notices, 1, note)
		arrangeNotices()
		TweenService:Create(note, TweenInfo.new(0.2), { GroupTransparency = 0 }):Play()
		TweenService:Create(timer, TweenInfo.new(life, Enum.EasingStyle.Linear), { Size = UDim2.fromOffset(0, 2) })
			:Play()
		local closed = false
		local function dismiss()
			if closed then
				return
			end
			closed = true
			local index = table.find(notices, note)
			if index then
				table.remove(notices, index)
			end
			if note.Parent then
				local fade = TweenService:Create(
					note,
					TweenInfo.new(0.16),
					{ GroupTransparency = 1, Position = note.Position + UDim2.fromOffset(20, 0) }
				)
				fade.Completed:Once(function()
					note:Destroy()
				end)
				fade:Play()
			end
			arrangeNotices()
		end
		uiRuntimeConnect(close.Activated, dismiss)
		task.delay(life, function()
			if Runtime.Alive then
				dismiss()
			end
		end)
		return { Close = dismiss }
	end
	function Window:Bubble(opts)
		return self:Notify(opts)
	end
	function Window:SidebarSection(name)
		self.CurrentSection = name
	end
	function Window:SetVisible(value)
		self.Opened = value == true
		closeDropdown()
		if self.Opened then
			root.Visible = true
			self:ApplyAppearance()
			if entrance then
				entrance()
			end
		else
			local fade = TweenService:Create(scale, TweenInfo.new(0.14), { Scale = scale.Scale * 0.98 })
			fade.Completed:Once(function()
				if not self.Opened then
					root.Visible = false
					blur.Enabled = false
				end
			end)
			fade:Play()
		end
	end
	local draggedFloat = false
	make("UIStroke", { Color = palette.accent, Thickness = 1, Transparency = 0.55 }, floating)
	uiRuntimeConnect(floating.Activated, function()
		if draggedFloat then
			draggedFloat = false
			return
		end
		NativeWindow:Toggle()
	end)
	uiRuntimeConnect(Input.InputBegan, function(input, processed)
		if
			not processed
			and not Input:GetFocusedTextBox()
			and input.KeyCode == (Enum.KeyCode[appearance.ToggleKey] or Enum.KeyCode.RightShift)
		then
			NativeWindow:Toggle()
		end
		if
			popup.Visible
			and (
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local p = input.Position
			local a = popup.AbsolutePosition
			local b = a + popup.AbsoluteSize
			local trigger = activeDropdown and activeDropdown.Trigger
			if trigger then
				local t = trigger.AbsolutePosition
				local edge = t + trigger.AbsoluteSize
				if p.X >= t.X and p.X <= edge.X and p.Y >= t.Y and p.Y <= edge.Y then
					return
				end
			end
			if p.X < a.X or p.Y < a.Y or p.X > b.X or p.Y > b.Y then
				closeDropdown()
			end
		end
	end)
	local function draggable(handle, target)
		local start, origin, dragging
		uiRuntimeConnect(handle.InputBegan, function(input)
			if handle == header then
				local pos, size = nav.AbsolutePosition, nav.AbsoluteSize
				if
					input.Position.X >= pos.X
					and input.Position.X <= pos.X + size.X
					and input.Position.Y >= pos.Y
					and input.Position.Y <= pos.Y + size.Y
				then
					return
				end
			end
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				start = input.Position
				origin = target.Position
				dragging = true
			end
		end)
		uiRuntimeConnect(Input.InputChanged, function(input)
			if
				dragging
				and (
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				local d = input.Position - start
				if target == floating and d.Magnitude > 5 then
					draggedFloat = true
				end
				local factor = target == floating and 1 or scale.Scale
				target:SetAttribute("Dragged", true)
				closeDropdown()
				target.Position = UDim2.new(
					origin.X.Scale,
					origin.X.Offset + d.X / factor,
					origin.Y.Scale,
					origin.Y.Offset + d.Y / factor
				)
			end
		end)
		uiRuntimeConnect(Input.InputEnded, function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				dragging = false
			end
		end)
	end
	draggable(header, header)
	draggable(tabBar, body)
	draggable(floating, floating)
	local groups = {}
	alignNavigation = function()
		local count = #groups
		local width = count * 48 + math.max(0, count - 1) * 22
		local available = nav.AbsoluteSize.X / math.max(0.01, scale.Scale)
		navPadding.PaddingLeft = UDim.new(0, math.max(12, (available - width) / 2))
	end
	layoutTabs = function(group)
		local count = #group.pages
		local available = tabBar.AbsoluteSize.X / math.max(0.01, scale.Scale)
		for index, page in ipairs(group.pages) do
			local target = page.TabButton.Parent.Name == "HoverHost" and page.TabButton.Parent or page.TabButton
			if count * 140 <= available then
				target.Size = UDim2.new(1 / math.max(1, count), 0, 1, 0)
				target.Position = UDim2.fromScale((index - 1) / math.max(1, count), 0)
			else
				target.Size = UDim2.fromOffset(140, 64)
				target.Position = UDim2.fromOffset((index - 1) * 140, 0)
			end
		end
	end
	local selectPage
	selectPage = function(page)
		closeDropdown()
		Window.Selected = page
		page.Group.Last = page
		layoutTabs(page.Group)
		crumb.Text = page.Group.name .. " / " .. page.Title
		for _, p in pairs(Window.Tabs) do
			p.Frame.Visible = p == page
			p.TabButton.Visible = p.Group == page.Group
			p.TabButton.TextColor3 = p == page and palette.text or palette.dim
			p.Underline.Visible = true
			TweenService:Create(
				p.Underline,
				TweenInfo.new(0.18, Enum.EasingStyle.Quad),
				{ Size = UDim2.new(p == page and 0.48 or 0, 0, 0, 2), BackgroundTransparency = p == page and 0 or 1 }
			):Play()
			TweenService:Create(
				p.TabButton,
				TweenInfo.new(0.18),
				{ BackgroundColor3 = palette.accent, BackgroundTransparency = p == page and 0.9 or 1 }
			):Play()
		end
		for _, g in ipairs(groups) do
			local active = g == page.Group
			g.Button.BackgroundTransparency = active and 0 or 1
			g.Button.BackgroundColor3 = Color3.fromRGB(34, 27, 46)
			g.Image.ImageColor3 = active and palette.text or palette.dim
			g.Outline.Enabled = active
		end
		if appearance.Motion then
			page.Frame.GroupTransparency = 1
			page.Frame.Position = UDim2.fromOffset(0, 6)
			TweenService:Create(
				page.Frame,
				TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ GroupTransparency = 0, Position = UDim2.new() }
			):Play()
		else
			page.Frame.GroupTransparency = 0
			page.Frame.Position = UDim2.new()
		end
	end
	local flagIndex = 0
	local function register(section, title, control, kind)
		flagIndex += 1
		local key = section .. "/" .. title .. "/" .. flagIndex
		Window.Flags[key] = { control = control, kind = kind }
		return control
	end
	local populateConfig
	local function newSection(tab, o)
		local side = o.Side or (tab.SectionCount % 2 == 0 and "Left" or "Right")
		tab.SectionCount += 1
		local card = surface(tab.Columns[side], o.Title, UDim2.new(1, -2, 0, 0))
		card.AutomaticSize = Enum.AutomaticSize.Y
		card.LayoutOrder = tab.SectionCount
		round(card, 9)
		make("UIPadding", {
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
		}, card)
		make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, card)
		local title = text(card, o.Title, UDim2.new(1, 0, 0, 28), nil, 13)
		title.TextXAlignment = Enum.TextXAlignment.Center
		title.LayoutOrder = 0
		make("Frame", {
			Name = "SectionMark",
			BackgroundColor3 = Color3.fromRGB(82, 78, 91),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 1, -3),
			Size = UDim2.fromOffset(18, 1),
		}, title)
		local section = { _card = card, Native = {}, Order = 0 }
		local function row(height)
			section.Order += 1
			local f = make("Frame", {
				Name = "Row",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, height or 30),
				LayoutOrder = section.Order,
			}, card)
			section._lastRow = f
			return f
		end
		function section:Toggle(opts)
			local frame = row(36)
			local value = opts.Default == true
			text(frame, opts.Title, UDim2.new(1, -55, 1, 0), nil, 14)
			local track = button(frame, "", UDim2.fromOffset(38, 22), UDim2.new(1, -40, 0.5, -11))
			track.BackgroundTransparency = 0
			round(track, 11)
			local knob = make("Frame", {
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.fromOffset(3, 3),
				BackgroundColor3 = palette.text,
				BorderSizePixel = 0,
			}, track)
			round(knob, 8)
			local control = { Instance = frame, Native = { Class = "Toggle", Instance = frame } }
			control.Set = function(nextValue, fire)
				value = nextValue == true
				TweenService
					:Create(track, TweenInfo.new(0.16), { BackgroundColor3 = value and palette.accent or palette.line })
					:Play()
				TweenService:Create(knob, TweenInfo.new(0.16), { Position = UDim2.fromOffset(value and 19 or 3, 3) })
					:Play()
				if fire ~= false then
					callback(opts.Callback)(value)
				end
			end
			control.Get = function()
				return value
			end
			function control.Native:GetState()
				return value
			end
			uiRuntimeConnect(track.Activated, function()
				control.Set(not value)
			end)
			control.Set(value, false)
			return register(tab.Group.name .. "/" .. tab.Title .. "/" .. o.Title, opts.Title, control, "toggle")
		end
		function section:Button(opts)
			local f = row(opts.Primary and 38 or 32)
			local b = button(f, opts.Title, UDim2.fromScale(1, 1))
			b.TextXAlignment = opts.Primary and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
			if opts.Primary then
				b.BackgroundColor3 = palette.accent
				b.BackgroundTransparency = 0.12
				round(b, 6)
			end
			local arrow = text(f, "›", UDim2.fromOffset(16, 28), UDim2.new(1, -16, 0, 1), 18, palette.dim)
			arrow.Visible = not opts.Primary
			uiRuntimeConnect(b.Activated, opts.Callback)
			return { Instance = f }
		end
		function section:Textbox(opts)
			local f = row(61)
			text(f, opts.Title, UDim2.new(1, 0, 0, 24), nil, 13, palette.dim)
			local input = make("TextBox", {
				BackgroundColor3 = Color3.fromRGB(23, 23, 25),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				Position = UDim2.fromOffset(0, 27),
				Text = tostring(opts.Default or ""),
				PlaceholderText = opts.Placeholder or "",
				ClearTextOnFocus = false,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = palette.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClipsDescendants = true,
			}, f)
			round(input, 4)
			make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, input)
			local c = { Instance = f }
			c.Set = function(v, fire)
				input.Text = tostring(v or "")
				if fire ~= false then
					callback(opts.Callback)(input.Text)
				end
			end
			c.Get = function()
				return input.Text
			end
			uiRuntimeConnect(input.FocusLost, function()
				callback(opts.Callback)(input.Text)
			end)
			return register(tab.Group.name .. "/" .. tab.Title .. "/" .. o.Title, opts.Title, c, "input")
		end
		function section:Slider(opts)
			local f = row(53)
			local min, max = opts.Min, opts.Max
			local value = opts.Default or min
			text(f, opts.Title, UDim2.new(1, -65, 0, 24), nil, 14)
			local caption = text(f, "", UDim2.fromOffset(60, 24), UDim2.new(1, -60, 0, 0), 11, palette.dim)
			caption.TextXAlignment = Enum.TextXAlignment.Right
			local track = make("Frame", {
				BackgroundColor3 = palette.line,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 2),
				Position = UDim2.fromOffset(0, 36),
			}, f)
			local fill = make(
				"Frame",
				{ BackgroundColor3 = palette.accent, BorderSizePixel = 0, Size = UDim2.fromScale(0, 1) },
				track
			)
			local knob = make("Frame", {
				BackgroundColor3 = palette.accent,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(7, 7),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0, 0.5),
			}, track)
			round(knob, 4)
			make("UIStroke", { Color = palette.accent, Thickness = 3, Transparency = 0.78 }, knob)
			local hit = button(f, "", UDim2.new(1, 0, 0, 24), UDim2.fromOffset(0, 25))
			local c = { Instance = f }
			c.Set = function(v, fire)
				value = math.clamp(math.round(tonumber(v) or min), min, max)
				local alpha = (value - min) / math.max(1, max - min)
				fill.Size = UDim2.fromScale(alpha, 1)
				knob.Position = UDim2.fromScale(alpha, 0.5)
				caption.Text = tostring(value) .. (opts.Suffix or "")
				if fire ~= false then
					callback(opts.Callback)(value)
				end
			end
			c.Get = function()
				return value
			end
			local dragging = false
			local function move(x)
				c.Set(min + (max - min) * math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1), true)
			end
			uiRuntimeConnect(hit.InputBegan, function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					dragging = true
					move(input.Position.X)
				end
			end)
			uiRuntimeConnect(Input.InputChanged, function(input)
				if
					dragging
					and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					)
				then
					move(input.Position.X)
				end
			end)
			uiRuntimeConnect(Input.InputEnded, function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				then
					dragging = false
				end
			end)
			c.Set(value, false)
			return register(tab.Group.name .. "/" .. tab.Title .. "/" .. o.Title, opts.Title, c, "slider")
		end
		function section:Dropdown(opts)
			local f = row(opts.Thumbnail and 132 or 62)
			text(f, opts.Title, UDim2.new(1, 0, 0, 24), nil, 13, palette.dim)
			local b = button(f, "", UDim2.new(1, 0, 0, 30), UDim2.fromOffset(0, 27))
			b.BackgroundColor3 = Color3.fromRGB(23, 23, 25)
			b.BackgroundTransparency = 0
			round(b, 4)
			b:SetAttribute("HoverStyle", "Highlight")
			local caption = text(b, "", UDim2.new(1, -36, 1, 0), UDim2.fromOffset(8, 0), 13)
			local arrow = make("Frame", {
				Name = "Arrow",
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(12, 12),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(1, -16, 0.5, 0),
			}, b)
			for _, part in ipairs({ { -2, 45 }, { 2, -45 } }) do
				make("Frame", {
					BackgroundColor3 = palette.dim,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(6, 2),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, part[1], 0.5, 0),
					Rotation = part[2],
				}, arrow)
			end
			local options = opts.Options or {}
			local value = opts.Multi and table.clone(opts.Default or {}) or opts.Default or options[1]
			local preview, previewText
			if opts.Thumbnail then
				preview = make("ImageLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(88, 64),
					Position = UDim2.fromOffset(0, 65),
					ScaleType = Enum.ScaleType.Fit,
				}, f)
				previewText = text(f, "", UDim2.new(1, -100, 0, 64), UDim2.fromOffset(100, 65), 12, palette.dim)
				previewText.TextWrapped = true
			end
			local c = { Instance = f, Trigger = b, Arrow = arrow, Native = { Class = "Dropdown", Instance = f } }
			c.Set = function(v, fire)
				value = opts.Multi and table.clone(type(v) == "table" and v or {}) or v
				caption.Text = opts.Multi and table.concat(value, ", ") or tostring(value or "")
				if preview then
					local icon = opts.Icons and opts.Icons[value]
					preview.Image = type(icon) == "number" and ("rbxassetid://" .. icon)
						or type(icon) == "string" and icon:find("rbxasset", 1, true) and icon
						or ""
					previewText.Text = tostring(value or "")
				end
				if fire ~= false then
					callback(opts.Callback)(value)
				end
			end
			c.Get = function()
				return value
			end
			c.Refresh = function(list)
				options = list
				if not opts.Multi and not table.find(options, value) then
					c.Set(options[1], false)
				end
				if activeDropdown == c then
					closeDropdown()
				end
			end
			function c.Native:GetOptions()
				local out = {}
				for _, v in ipairs(options) do
					out[v] = true
				end
				return out
			end
			function c.Native:Close()
				closeDropdown()
			end
			c.Render = function()
				for _, child in ipairs(popupList:GetChildren()) do
					if child:IsA("TextButton") or child.Name == "HoverHost" then
						child:Destroy()
					end
				end
				local query = popupSearch.Text:lower()
				for i, name in ipairs(options) do
					if tostring(name):lower():find(query, 1, true) then
						local entry = button(popupList, tostring(name), UDim2.new(1, -4, 0, 30))
						entry:SetAttribute("HoverStyle", "Highlight")
						make("UIPadding", { PaddingLeft = UDim.new(0, 10) }, entry)
						round(entry, 5)
						local selected = opts.Multi and table.find(value, name) or not opts.Multi and value == name
						entry.BackgroundColor3 = palette.accent
						entry.BackgroundTransparency = selected and 0.88 or 1
						entry.LayoutOrder = i
						entry.ZIndex = 52
						entry.TextXAlignment = Enum.TextXAlignment.Left
						entry.TextColor3 = (opts.Multi and table.find(value, name) or not opts.Multi and value == name)
								and palette.accent
							or palette.text
						uiRuntimeConnect(entry.Activated, function()
							if opts.Multi then
								local nextValue = table.clone(value)
								local index = table.find(nextValue, name)
								if index then
									table.remove(nextValue, index)
								else
									table.insert(nextValue, name)
								end
								c.Set(nextValue, true)
								c.Render()
							else
								closeDropdown()
								c.Set(name, true)
							end
						end)
					end
				end
			end
			uiRuntimeConnect(b.Activated, function()
				if activeDropdown == c then
					closeDropdown()
					return
				end
				closeDropdown()
				activeDropdown = c
				arrow.Rotation = 180
				popupSearch.Text = ""
				local p = (b.AbsolutePosition - root.AbsolutePosition) / scale.Scale
                local minimum=-root.AbsolutePosition/scale.Scale
                local maximum=(workspace.CurrentCamera.ViewportSize-root.AbsolutePosition)/scale.Scale
				popup.Size =
					UDim2.fromOffset(b.AbsoluteSize.X / scale.Scale, math.min(232, math.max(94, #options * 33 + 52)))
				popup.Position = UDim2.fromOffset(
					math.clamp(p.X, minimum.X, maximum.X - popup.Size.X.Offset),
					math.clamp(p.Y + b.AbsoluteSize.Y / scale.Scale + 4, 0, root.Size.Y.Offset - popup.Size.Y.Offset)
				)
				popup.Visible = true
				c.Render()
			end)
			c.Set(value, false)
			register(tab.Group.name .. "/" .. tab.Title .. "/" .. o.Title, opts.Title, c, "dropdown")
			if opts.Refresh then
				section:Button({
					Title = "รีเฟรช" .. opts.Title,
					Callback = function()
						c.Refresh(opts.Refresh())
					end,
				})
				section._lastRow = f
			end
			return c
		end
		function section:Segmented(opts)
			local f = row(58)
			text(f, opts.Title, UDim2.new(1, 0, 0, 23), nil, 13, palette.dim)
			local buttons = {}
			local value = opts.Default
			local c = { Instance = f }
			c.Set = function(v, fire)
				value = v
				for name, b in pairs(buttons) do
					b.TextColor3 = name == value and palette.accent or palette.dim
				end
				if fire ~= false then
					callback(opts.Callback)(value)
				end
			end
			c.Get = function()
				return value
			end
			for i, name in ipairs(opts.Options) do
				local b = button(
					f,
					name,
					UDim2.new(1 / #opts.Options, -4, 0, 28),
					UDim2.new((i - 1) / #opts.Options, 0, 0, 27)
				)
				buttons[name] = b
				uiRuntimeConnect(b.Activated, function()
					c.Set(name, true)
				end)
			end
			c.Set(value, false)
			return c
		end
		function section:Label(value)
			local f = row(0)
			f.AutomaticSize = Enum.AutomaticSize.Y
			local label = text(f, value, UDim2.new(1, 0, 0, 20), nil, 14, palette.dim)
			label.AutomaticSize = Enum.AutomaticSize.Y
			label.TextWrapped = true
			label.TextTruncate = Enum.TextTruncate.None
			return f
		end
		function section:Banner(opts)
			local f = row(100)
			make("ImageLabel", {
				BackgroundTransparency = 1,
				Image = logoImage(options.Logo or "rbxassetid://120549670549494"),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromOffset(60, 60),
				Position = UDim2.fromOffset(0, 8),
			}, f)
			text(f, opts.Title, UDim2.new(1, -76, 0, 30), UDim2.fromOffset(76, 15), 16)
			text(
				f,
				opts.SubTitle or options.Version or "",
				UDim2.new(1, -76, 0, 22),
				UDim2.fromOffset(76, 46),
				12,
				palette.dim
			)
		end
		function section:UserInfo(opts)
			opts = opts or {}
			local frame = row(158)
			local photo = make("ImageLabel", {
				Name = "Avatar",
				BackgroundColor3 = palette.line,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(64, 64),
				Position = UDim2.fromOffset(0, 8),
				Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150",
				ScaleType = Enum.ScaleType.Fit,
			}, frame)
			round(photo, 14)
			text(frame, player.DisplayName, UDim2.new(1, -80, 0, 26), UDim2.fromOffset(80, 16), 17)
			text(frame, "@" .. player.Name, UDim2.new(1, -80, 0, 20), UDim2.fromOffset(80, 43), 12, palette.dim)
			make("Frame", {
				BackgroundColor3 = palette.line,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 1),
				Position = UDim2.fromOffset(0, 90),
			}, frame)
			text(frame, "Map", UDim2.new(1, 0, 0, 18), UDim2.fromOffset(0, 104), 11, palette.dim)
			local map = text(frame, opts.Map or game.Name, UDim2.new(1, -86, 0, 24), UDim2.fromOffset(0, 124), 13)
			local description = text(
				frame,
				opts.Description or ("V." .. game.PlaceVersion),
				UDim2.fromOffset(80, 24),
				UDim2.new(1, -80, 0, 124),
				11,
				palette.dim
			)
			description.TextXAlignment = Enum.TextXAlignment.Right
			return {
				Instance = frame,
				SetDescription = function(value)
					description.Text = tostring(value)
				end,
				SetMap = function(value)
					map.Text = tostring(value)
				end,
			}
		end
		function section:StatGrid(entries)
			local labels = {}
			for _, entry in ipairs(entries) do
				local f = row(30)
				text(f, entry.Label, UDim2.new(0.55, 0, 1, 0), nil, 13, palette.dim)
				local v = text(f, entry.Value, UDim2.new(0.45, 0, 1, 0), UDim2.fromScale(0.55, 0), 14)
				v.TextXAlignment = Enum.TextXAlignment.Right
				labels[entry.Label] = v
			end
			return {
				Set = function(name, value)
					if labels[name] then
						labels[name].Text = tostring(value)
					end
				end,
			}
		end
		function section:Progress(opts)
			local value = math.clamp(opts.Default or 0, 0, 1)
			local f = row(48)
			local label = text(f, opts.Title, UDim2.new(1, 0, 0, 26), nil, 13, palette.dim)
			local track = make("Frame", {
				BackgroundColor3 = palette.line,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 2),
				Position = UDim2.fromOffset(0, 35),
			}, f)
			local fill = make(
				"Frame",
				{ BackgroundColor3 = palette.accent, BorderSizePixel = 0, Size = UDim2.fromScale(opts.Default or 0, 1) },
				track
			)
			return {
				Get = function()
					return value
				end,
				Set = function(nextValue, title)
					value = math.clamp(nextValue or 0, 0, 1)
					TweenService:Create(fill, TweenInfo.new(0.2), { Size = UDim2.fromScale(value, 1) }):Play()
					label.Text = title or opts.Title
				end,
			}
		end
		function section.Native:Keybind(opts, key)
			local f = row(32)
			text(f, opts.Name, UDim2.new(1, -110, 1, 0), nil, 14)
			local value = opts.Default
			local b = button(f, value.Name, UDim2.fromOffset(104, 30), UDim2.new(1, -104, 0, 0))
			b.TextColor3 = palette.dim
			local binding = false
			local c = { Instance = f }
			function c:Bind(v)
				value = v
				b.Text = v.Name
			end
			c.Get = function()
				return value.Name
			end
			c.Set = function(v, fire)
				local k = Enum.KeyCode[tostring(v)] or opts.Default
				c:Bind(k)
				if fire ~= false then
					callback(opts.onBinded)(k)
				end
			end
			uiRuntimeConnect(b.Activated, function()
				binding = true
				b.Text = "…"
			end)
			uiRuntimeConnect(Input.InputBegan, function(input)
				if binding and input.KeyCode ~= Enum.KeyCode.Unknown then
					binding = false
					c:Bind(input.KeyCode)
					callback(opts.onBinded)(input.KeyCode)
				end
			end)
			Window.Flags[key] = { control = c, kind = "keybind" }
			return c
		end
		function section:ConfigManager()
			populateConfig(self)
		end
		function section:Keybind(opts)
			return self.Native:Keybind(
				{ Name = opts.Title, Default = opts.Default or Enum.KeyCode.RightShift, onBinded = opts.Callback },
				opts.Flag or opts.Title
			)
		end
		function section:Text(opts)
			opts = type(opts) == "table" and opts or { Text = opts }
			local frame = self:Label(opts.Text or opts.Title or "")
			local label = frame:FindFirstChildWhichIsA("TextLabel")
			return {
				Instance = frame,
				Set = function(value)
					label.Text = tostring(value)
				end,
				Get = function()
					return label.Text
				end,
			}
		end
		function section:Paragraph(opts)
			local frame = row(0)
			frame.AutomaticSize = Enum.AutomaticSize.Y
			make("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, frame)
			local title = text(frame, opts.Title or "", UDim2.new(1, 0, 0, 22), nil, 14)
			title.LayoutOrder = 1
			local body = text(frame, opts.Content or opts.Text or "", UDim2.new(1, 0, 0, 20), nil, 13, palette.dim)
			body.LayoutOrder = 2
			body.TextWrapped = true
			body.TextTruncate = Enum.TextTruncate.None
			body.AutomaticSize = Enum.AutomaticSize.Y
			return {
				Instance = frame,
				Set = function(value)
					body.Text = tostring(value)
				end,
				Get = function()
					return body.Text
				end,
			}
		end
		function section:Image(opts)
			local height = opts.Height or 120
			local frame = row(height + (opts.Caption and 24 or 0))
			local image = make("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, height),
				Image = logoImage(opts.Image or ""),
				ScaleType = opts.ScaleType or Enum.ScaleType.Fit,
			}, frame)
			if opts.Caption then
				local caption =
					text(frame, opts.Caption, UDim2.new(1, 0, 0, 24), UDim2.fromOffset(0, height), 12, palette.dim)
				caption.TextXAlignment = Enum.TextXAlignment.Center
			end
			return {
				Instance = frame,
				Set = function(value)
					image.Image = logoImage(value)
				end,
				Get = function()
					return image.Image
				end,
			}
		end
		function section:Divider(value)
			local frame = row(24)
			local function line(size, position)
				make(
					"Frame",
					{ BackgroundColor3 = palette.line, BorderSizePixel = 0, Size = size, Position = position },
					frame
				)
			end
			if value and tostring(value) ~= "" then
				local label = text(frame, tostring(value), UDim2.new(1, -24, 1, 0), nil, 11, palette.dim)
				label.TextXAlignment = Enum.TextXAlignment.Center
				local width = game:GetService("TextService")
					:GetTextSize(tostring(value), 11, Enum.Font.Gotham, Vector2.new(1000, 24)).X + 20
				line(UDim2.new(0.5, -width / 2, 0, 1), UDim2.fromOffset(0, 12))
				line(UDim2.new(0.5, -width / 2, 0, 1), UDim2.new(0.5, width / 2, 0, 12))
				label.Size = UDim2.fromScale(1, 1)
			else
				line(UDim2.new(1, 0, 0, 1), UDim2.fromOffset(0, 12))
			end
			return frame
		end
		function section:Select(opts)
			local items = opts.Options or {}
			local frame = row(64)
			local strip = make("Frame", {
				BackgroundColor3 = palette.line,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 27),
				Size = UDim2.new(1, 0, 0, 32),
			}, frame)
			round(strip, 6)
			text(frame, opts.Title or "Select", UDim2.new(1, 0, 0, 24), nil, 13, palette.dim)
			local value = opts.Multi and table.clone(opts.Default or {}) or opts.Default or items[1]
			local buttons = {}
			local control = { Instance = frame }
			control.Set = function(nextValue, fire)
				value = opts.Multi and table.clone(type(nextValue) == "table" and nextValue or {}) or nextValue
				for name, entry in pairs(buttons) do
					local selected = opts.Multi and table.find(value, name) ~= nil or not opts.Multi and name == value
					entry.Button.TextColor3 = selected and palette.text or palette.dim
					entry.Button.BackgroundTransparency = selected and 0 or 1
					entry.Button.BackgroundColor3 = palette.accent
				end
				if fire ~= false then
					callback(opts.Callback)(value)
				end
			end
			control.Get = function()
				return opts.Multi and table.clone(value) or value
			end
			for index, name in ipairs(items) do
				local b = button(
					strip,
					tostring(name),
					UDim2.new(1 / math.max(1, #items), -4, 1, -6),
					UDim2.new((index - 1) / math.max(1, #items), 2, 0, 3)
				)
				b:SetAttribute("HoverStyle", "Highlight")
				b.TextSize = 12
				round(b, 4)
				buttons[name] = { Button = b }
				uiRuntimeConnect(b.Activated, function()
					if opts.Multi then
						local nextValue = table.clone(value)
						local i = table.find(nextValue, name)
						if i then
							table.remove(nextValue, i)
						else
							nextValue[#nextValue + 1] = name
						end
						control.Set(nextValue, true)
					else
						control.Set(name, true)
					end
				end)
			end
			control.Set(value, false)
			return register(tab.Group.name .. "/" .. tab.Title .. "/" .. o.Title, opts.Title, control, "select")
		end
		function section:Checkbox(opts)
			return self:Toggle(opts)
		end
		function section:Radio(opts)
			opts = table.clone(opts)
			opts.Multi = false
			return self:Select(opts)
		end
		function section:Process(opts)
			return self:Progress(opts)
		end
		function section:ColorPicker(opts)
			local frame = row(36)
			text(frame, opts.Title or "Color", UDim2.new(1, -55, 0, 32), nil, 14)
			local chip = button(frame, "", UDim2.fromOffset(32, 20), UDim2.new(1, -34, 0, 6))
			chip.BackgroundTransparency = 0
			round(chip, 5)
			local panel = make("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 40),
				Size = UDim2.new(1, 0, 0, 174),
				Visible = false,
			}, frame)
			local square = button(panel, "", UDim2.new(1, -26, 0, 132))
			square.BackgroundTransparency = 0
			square.ClipsDescendants = true
			round(square, 5)
			local white = make(
				"Frame",
				{ BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
				square
			)
			make("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}, white)
			local black = make(
				"Frame",
				{ BackgroundColor3 = Color3.new(), BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) },
				square
			)
			make("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 0),
				}),
			}, black)
			local marker = make(
				"Frame",
				{ AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1 },
				square
			)
			round(marker, 5)
			make("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }, marker)
			local hue = button(panel, "", UDim2.fromOffset(16, 132), UDim2.new(1, -16, 0, 0))
			hue.BackgroundTransparency = 0
			hue.BackgroundColor3 = Color3.new(1, 1, 1)
			round(hue, 5)
			local keys = {}
			for i = 0, 6 do
				keys[#keys + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1))
			end
			make("UIGradient", { Rotation = 90, Color = ColorSequence.new(keys) }, hue)
			local hueMarker = make("Frame", {
				Size = UDim2.new(1, 4, 0, 3),
				Position = UDim2.fromOffset(-2, 0),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
			}, hue)
			local input = make("TextBox", {
				BackgroundColor3 = palette.line,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 28),
				Position = UDim2.fromOffset(0, 142),
				Text = "",
				ClearTextOnFocus = false,
				Font = Enum.Font.Gotham,
				TextColor3 = palette.text,
				TextSize = 13,
			}, panel)
			round(input, 4)
			local h, s, v = 0, 1, 1
			local value
			local control = { Instance = frame }
			control.Set = function(nextValue, fire, keepHue)
				value = typeof(nextValue) == "Color3" and nextValue or Color3.fromHex(tostring(nextValue):gsub("#", ""))
				if not keepHue then
					h, s, v = value:ToHSV()
				end
				chip.BackgroundColor3 = value
				square.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				marker.Position = UDim2.fromScale(s, 1 - v)
				hueMarker.Position = UDim2.new(0, -2, h, -1)
				input.Text = "#" .. value:ToHex()
				if fire ~= false then
					callback(opts.Callback)(value)
				end
			end
			control.Get = function()
				return value:ToHex()
			end
			local dragging
			local function update(position)
				if not panel.Visible then
					return
				end
				if dragging == "hue" then
					h = math.clamp((position.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 1)
				else
					s = math.clamp((position.X - square.AbsolutePosition.X) / square.AbsoluteSize.X, 0, 1)
					v = 1 - math.clamp((position.Y - square.AbsolutePosition.Y) / square.AbsoluteSize.Y, 0, 1)
				end
				control.Set(Color3.fromHSV(h, s, v), true, true)
			end
			for _, entry in ipairs({ { square, "square" }, { hue, "hue" } }) do
				uiRuntimeConnect(entry[1].InputBegan, function(event)
					if
						event.UserInputType == Enum.UserInputType.MouseButton1
						or event.UserInputType == Enum.UserInputType.Touch
					then
						dragging = entry[2]
						update(event.Position)
					end
				end)
			end
			uiRuntimeConnect(Input.InputChanged, function(event)
				if
					dragging
					and (
						event.UserInputType == Enum.UserInputType.MouseMovement
						or event.UserInputType == Enum.UserInputType.Touch
					)
				then
					update(event.Position)
				end
			end)
			uiRuntimeConnect(Input.InputEnded, function(event)
				if
					event.UserInputType == Enum.UserInputType.MouseButton1
					or event.UserInputType == Enum.UserInputType.Touch
				then
					dragging = nil
				end
			end)
			uiRuntimeConnect(chip.Activated, function()
				panel.Visible = not panel.Visible
				frame.Size = UDim2.new(1, 0, 0, panel.Visible and 218 or 36)
			end)
			uiRuntimeConnect(input.FocusLost, function()
				if not pcall(control.Set, input.Text, true) then
					input.Text = "#" .. value:ToHex()
				end
			end)
			control.Set(opts.Default or "8D47FF", false)
			return register(tab.Group.name .. "/" .. tab.Title .. "/" .. o.Title, opts.Title, control, "color")
		end
		function section:ButtonGroup(opts)
			local frame = row(34)
			local entries = opts.Buttons or {}
			for index, entry in ipairs(entries) do
				local b = button(
					frame,
					entry.Title,
					UDim2.new(1 / math.max(1, #entries), -4, 1, 0),
					UDim2.fromScale((index - 1) / math.max(1, #entries), 0)
				)
				b.BackgroundTransparency = 0
				b.BackgroundColor3 = palette.line
				round(b, 4)
				b:SetAttribute("HoverStyle", "Highlight")
				uiRuntimeConnect(b.Activated, entry.Callback)
			end
			return { Instance = frame }
		end

		return section
	end
	uiRuntimeConnect(popupSearch:GetPropertyChangedSignal("Text"), function()
		if activeDropdown then
			activeDropdown.Render()
		end
	end)
	local function newPage(group, opts)
		local page = { Title = opts.Title, Group = group, Columns = {}, SectionCount = 0, Native = {} }
		page.Frame = make(
			"CanvasGroup",
			{ Name = opts.Title, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false },
			pages
		)
		for i, side in ipairs({ "Left", "Right" }) do
			local column = make("ScrollingFrame", {
				Name = side,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ClipsDescendants = true,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0.5, -5, 1, 0),
				Position = UDim2.new((i - 1) * 0.5, i == 1 and 0 or 5, 0, 0),
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 2,
				ScrollBarImageColor3 = Color3.fromRGB(82, 78, 91),
				ScrollBarImageTransparency = 0.3,
			}, page.Frame)
			make("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder }, column)
			page.Columns[side] = column
		end
		page.TabButton = button(tabBar, opts.Title, UDim2.fromOffset(150, 64))
		page.TabButton:SetAttribute("HoverStyle", "Highlight")
		page.TabButton.Visible = false
		round(page.TabButton, 7)
		page.Underline = make("Frame", {
			BackgroundColor3 = palette.accent,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(66, 1),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 1, -12),
			Visible = false,
		}, page.TabButton)
		group.pages[#group.pages + 1] = page
		layoutTabs(group)
		function page:Section(settings)
			return newSection(self, settings)
		end
		function page:Tab(settings)
			return newPage(group, settings)
		end
		function page.Native:Select()
			selectPage(page)
		end
		function page.Native:Section(settings)
			return page:Section(settings)
		end
		local key = group.name .. "/" .. opts.Title
		Window.Tabs[key] = page
		uiRuntimeConnect(page.TabButton.Activated, function()
			selectPage(page)
		end)
		if opts.Default or not Window.Selected then
			selectPage(page)
		end
		return page
	end
	function Window:Category(opts)
		local group = { name = opts.Title, pages = {}, Section = self.CurrentSection }
		local b = button(nav, "", UDim2.fromOffset(48, 48))
		b.LayoutOrder = #groups + 1
		b.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
		round(b, 6)
		local icon = { Image = iconImage(opts.Icon) }
		local image = make("ImageLabel", {
			BackgroundTransparency = 1,
			Image = icon.Image,
			ImageRectSize = Vector2.zero,
			ImageRectOffset = Vector2.zero,
			Size = UDim2.fromOffset(28, 28),
			Position = UDim2.fromOffset(10, 10),
			ImageColor3 = palette.text,
		}, b)
		b:SetAttribute("HoverStyle", "Highlight")
		group.Button = b
		group.Image = image
		group.Outline =
			make("UIStroke", { Color = palette.accent, Thickness = 1, Transparency = 0.6, Enabled = false }, b)
		groups[#groups + 1] = group
		Window.Groups[opts.Title] = group
		uiRuntimeConnect(b.Activated, function()
			selectPage(group.Last or group.pages[1])
		end)
		function group:Tab(tabOptions)
			local page = newPage(self, tabOptions)
			if Window.Selected and Window.Selected.Group == self then
				selectPage(Window.Selected)
			end
			return page
		end
		Window.Categories[opts.Title] = group
		alignNavigation()
		return group
	end
	function Window:Tab(opts)
		local group = self:Category(opts)
		return group:Tab({ Title = opts.Title, Default = opts.Default })
	end
	local configFolder = (options.Folder or "Universal_Ui") .. "/configs"
	local function configName(value)
		return tostring(value or ""):gsub("[^%w _%-]", ""):sub(1, 60)
	end
	function Window:SaveConfig(name)
		name = configName(name)
		assert(name ~= "", "name")
		local values = {}
		for key, entry in pairs(self.Flags) do
			values[key] = entry.control.Get()
		end
		writefile(
			configFolder .. "/" .. name .. ".json",
			Http:JSONEncode({
				version = 2,
				values = values,
				appearance = {
					Theme = appearance.Theme,
					Accent = appearance.Accent,
					Scale = appearance.Scale,
					Transparency = appearance.Transparency,
					FloatingEnabled = appearance.FloatingEnabled,
					FloatingSize = appearance.FloatingSize,
					RGB = appearance.RGB,
					HideInfo = appearance.HideInfo,
					Background = appearance.Background,
					Panel = appearance.Panel,
				},
			})
		)
	end
	local function configPath(name)
		return configFolder .. "/" .. configName(name) .. ".json"
	end
	function Window:LoadConfig(name)
		local data = Http:JSONDecode(readfile(configPath(name)))
		local values = data.values or {}
		for _, entry in ipairs(data.objects or {}) do
			local value = entry.value
			if entry.type == "Toggle" then
				value = entry.state
			elseif entry.type == "Input" then
				value = entry.text
			elseif entry.type == "Keybind" then
				value = entry.bind
			end
			if value ~= nil then
				values[entry.flag] = value
			end
		end
		local keys = {}
		for key in pairs(values) do
			keys[#keys + 1] = key
		end
		table.sort(keys, function(a, b)
			return (tonumber(a:match("/(%d+)$")) or 0) < (tonumber(b:match("/(%d+)$")) or 0)
		end)
		for _, togglePass in ipairs({ false, true }) do
			for _, key in ipairs(keys) do
				local entry = self.Flags[key]
				if entry and (entry.kind == "toggle") == togglePass then
					local value = values[key]
					if entry.kind == "dropdown" and type(value) == "table" and #value == 0 then
						local list = {}
						for option, selected in pairs(value) do
							if selected then
								list[#list + 1] = option
							end
						end
						table.sort(list)
						value = list
					end
					entry.control.Set(value, true)
				end
			end
		end
		for key, value in pairs(data.appearance or {}) do
			if
				key == "Theme"
				or key == "Accent"
				or key == "Scale"
				or key == "Transparency"
				or key == "FloatingEnabled"
				or key == "FloatingSize"
				or key == "RGB"
				or key == "HideInfo"
				or key == "Background"
				or key == "Panel"
			then
				appearance[key] = value
			end
		end
		self:SetTheme(appearance.Theme or "Dark")
		self:SetAccent(appearance.Accent or "8D47FF")
		self:SetSurfaceColor("base", appearance.Background)
		self:SetSurfaceColor("panel", appearance.Panel)
		self:ApplyAppearance()
		self:ApplyFloating()
	end
	populateConfig = function(section)
		local firstFlag = flagIndex
		local name = "default"
		local chosen = "default"
		local list
		local function configs()
			makefolder(configFolder)
			local out = {}
			for _, path in ipairs(listfiles(configFolder)) do
				local file = path:match("([^/\\]+)%.json$")
				if file then
					out[#out + 1] = file
				end
			end
			table.sort(out)
			return out
		end
		section:Textbox({
			Title = "Name",
			Default = name,
			Callback = function(value)
				name = configName(value)
			end,
		})
		list = section:Dropdown({
			Title = "Config",
			Options = configs(),
			Default = chosen,
			Callback = function(value)
				chosen = value
			end,
		})
		section:Button({
			Title = "Save",
			Callback = function()
				Window:SaveConfig(name)
				list.Refresh(configs())
				list.Set(name, false)
				chosen = name
				Window:Notify({ Title = "Config", Content = "Saved" })
			end,
		})
		section:Button({
			Title = "Load",
			Callback = function()
				Window:LoadConfig(chosen)
				Window:Notify({ Title = "Config", Content = "Loaded" })
			end,
		})
		section:Button({
			Title = "Delete",
			Callback = function()
				local path = configPath(chosen)
				if isfile(path) then
					delfile(path)
				end
				list.Refresh(configs())
			end,
		})
		section:Button({
			Title = "Refresh",
			Callback = function()
				list.Refresh(configs())
			end,
		})
		for key in pairs(Window.Flags) do
			local index = tonumber(key:match("/(%d+)$"))
			if index and index > firstFlag then
				Window.Flags[key] = nil
			end
		end
	end
	function Window:LoadAutoload()
		local path = configFolder .. "/autoload.txt"
		if isfile(path) then
			local ok, err = pcall(self.LoadConfig, self, readfile(path))
			if not ok then
				self.LastConfigError = tostring(err)
				self:Notify({ Title = "Config", Content = "Load failed" })
			end
		end
	end
	local clickSound = make("Sound", {
		Name = "Click",
		SoundId = "rbxasset://sounds/electronicpingshort.wav",
		Volume = appearance.Volume,
		PlaybackSpeed = 2.8,
	}, gui)
	styleButton = function(b)
		if b:GetAttribute("HoverReady") then
			return
		end
		b:SetAttribute("HoverReady", true)
		local effect
		if b:IsA("TextButton") and b:GetAttribute("HoverStyle") ~= "Highlight" then
			local host = make("Frame", {
				Name = "HoverHost",
				BackgroundTransparency = 1,
				Size = b.Size,
				Position = b.Position,
				AnchorPoint = b.AnchorPoint,
				LayoutOrder = b.LayoutOrder,
				Visible = b.Visible,
				ZIndex = b.ZIndex,
			}, b.Parent)
			b.Parent = host
			b.AnchorPoint = Vector2.new(0.5, 0.5)
			b.Position = UDim2.fromScale(0.5, 0.5)
			b.Size = UDim2.fromScale(1, 1)
			effect = make("UIScale", { Scale = 1 }, b)
			local changing = false
			for _, property in ipairs({ "Size", "Position", "Visible", "LayoutOrder" }) do
				uiRuntimeConnect(b:GetPropertyChangedSignal(property), function()
					if
						changing
						or property == "Size" and b.Size == UDim2.fromScale(1, 1)
						or property == "Position" and b.Position == UDim2.fromScale(0.5, 0.5)
					then
						return
					end
					changing = true
					if property == "Size" then
						host.Size = b.Size
						b.Size = UDim2.fromScale(1, 1)
					elseif property == "Position" then
						host.Position = b.Position
						b.Position = UDim2.fromScale(0.5, 0.5)
					else
						host[property] = b[property]
					end
					changing = false
				end)
			end
			uiRuntimeConnect(b.Destroying, function()
				task.defer(function()
					if host.Parent then
						host:Destroy()
					end
				end)
			end)
		end
		if b:IsA("ImageButton") then
			local oldAnchor = b.AnchorPoint
			b.Position = b.Position
				+ UDim2.new(
					b.Size.X.Scale * (0.5 - oldAnchor.X),
					b.Size.X.Offset * (0.5 - oldAnchor.X),
					b.Size.Y.Scale * (0.5 - oldAnchor.Y),
					b.Size.Y.Offset * (0.5 - oldAnchor.Y)
				)
			b.AnchorPoint = Vector2.new(0.5, 0.5)
			effect = make("UIScale", { Scale = 1 }, b)
		end
		local hoverFill = make("Frame", {
			Name = "HoverFill",
			BackgroundColor3 = Color3.fromRGB(190, 181, 207),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = b.ZIndex + 1,
			Active = false,
		}, b)
		local hoverCorner = make("UICorner", { CornerRadius = UDim.new(0, 6) }, hoverFill)
		local hovered = false
		local function animate(value)
			if effect and b.Parent then
				if b:GetAttribute("HoverStyle") == "Highlight" then
					value = 1
				end
				TweenService:Create(effect, TweenInfo.new(0.14, Enum.EasingStyle.Quad), { Scale = value }):Play()
			end
		end
		uiRuntimeConnect(b.MouseEnter, function()
			hovered = true
			hoverFill.ZIndex = b.ZIndex + 1
			local padding = b:FindFirstChildOfClass("UIPadding")
			local left = padding and padding.PaddingLeft or UDim.new(0, 0)
			local right = padding and padding.PaddingRight or UDim.new(0, 0)
			local top = padding and padding.PaddingTop or UDim.new(0, 0)
			local bottom = padding and padding.PaddingBottom or UDim.new(0, 0)
			hoverFill.Position = UDim2.new(-left.Scale, -left.Offset, -top.Scale, -top.Offset)
			hoverFill.Size = UDim2.new(
				1 + left.Scale + right.Scale,
				left.Offset + right.Offset,
				1 + top.Scale + bottom.Scale,
				top.Offset + bottom.Offset
			)
			local corner = b:FindFirstChildOfClass("UICorner")
			hoverCorner.CornerRadius = corner and corner.CornerRadius or UDim.new(0, 6)
			TweenService:Create(hoverFill, TweenInfo.new(0.14), { BackgroundTransparency = 0.92 }):Play()
			animate(1.02)
		end)
		uiRuntimeConnect(b.MouseLeave, function()
			hovered = false
			TweenService:Create(hoverFill, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play()
			animate(1)
		end)
		uiRuntimeConnect(b.Activated, function()
			if b:GetAttribute("HoverStyle") == "Highlight" then
				if appearance.Sound then
					clickSound:Play()
				end
				return
			end
			if appearance.Motion then
				b.ClipsDescendants = true
				local ripple = make("Frame", {
					BackgroundColor3 = palette.accent,
					BackgroundTransparency = 0.8,
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(6, 6),
					ZIndex = b.ZIndex + 1,
				}, b)
				round(ripple, 100)
				local spread =
					TweenService:Create(ripple, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.fromOffset(
							math.max(b.AbsoluteSize.X, b.AbsoluteSize.Y) * 1.5,
							math.max(b.AbsoluteSize.X, b.AbsoluteSize.Y) * 1.5
						),
						BackgroundTransparency = 1,
					})
				spread.Completed:Once(function()
					ripple:Destroy()
				end)
				spread:Play()
			end
			if appearance.Sound then
				clickSound.Volume = appearance.Volume or 0.15
				clickSound.TimePosition = 0
				clickSound:Play()
			end
			animate(0.965)
			task.delay(0.09, function()
				if Runtime.Alive then
					animate(hovered and 1.02 or 1)
				end
			end)
		end)
	end
	local scrolls = {}
	local hoveredScroll
	trackScroll = function(frame)
		if scrolls[frame] then
			return
		end
		frame.Active = true
		frame.ClipsDescendants = true
		frame.ScrollingEnabled = true
		frame.ElasticBehavior = Enum.ElasticBehavior.Never
		local controller = { Frame = frame, Target = frame.CanvasPosition }
		scrolls[frame] = controller
		uiRuntimeConnect(frame.MouseEnter, function()
			hoveredScroll = controller
		end)
		uiRuntimeConnect(frame.MouseLeave, function()
			if hoveredScroll == controller then
				hoveredScroll = nil
			end
		end)
	end
	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("ScrollingFrame") then
			trackScroll(obj)
		end
		if obj:IsA("GuiButton") then
			styleButton(obj)
		end
	end
	uiRuntimeConnect(Input.InputChanged, function(input)
		local controller
		local mouse = Input:GetMouseLocation()
		for frame, candidate in pairs(scrolls) do
			local visible = frame.Parent ~= nil
			local ancestor = frame
			while visible and ancestor and ancestor ~= gui do
				if ancestor:IsA("GuiObject") and not ancestor.Visible then
					visible = false
				end
				ancestor = ancestor.Parent
			end
			if visible then
				local pos, extent = frame.AbsolutePosition, frame.AbsoluteSize
				if
					mouse.X >= pos.X
					and mouse.X <= pos.X + extent.X
					and mouse.Y >= pos.Y
					and mouse.Y <= pos.Y + extent.Y
				then
					if not controller or frame.ZIndex >= controller.Frame.ZIndex then
						controller = candidate
					end
				end
			end
		end
		if popup.Visible and controller and controller.Frame ~= popupList then
			return
		end
		if
			input.UserInputType ~= Enum.UserInputType.MouseWheel
			or not controller
			or not root.Visible
			or not appearance.SmoothScroll
		then
			return
		end
		local frame = controller.Frame
		local parent = frame
		while parent and parent ~= gui do
			if parent:IsA("GuiObject") and not parent.Visible then
				return
			end
			parent = parent.Parent
		end
		if not frame.Parent then
			return
		end
		local max = frame.AbsoluteCanvasSize - frame.AbsoluteSize
		if frame.ScrollingDirection == Enum.ScrollingDirection.X then
			controller.Target =
				Vector2.new(math.clamp(controller.Target.X - input.Position.Z * 72, 0, math.max(0, max.X)), 0)
		else
			controller.Target =
				Vector2.new(0, math.clamp(controller.Target.Y - input.Position.Z * 58, 0, math.max(0, max.Y)))
		end
	end)
	uiRuntimeConnect(RunService.RenderStepped, function(dt)
		for frame, controller in pairs(scrolls) do
			if not frame.Parent then
				scrolls[frame] = nil
			else
				local smooth = appearance.SmoothScroll and not Input.TouchEnabled
				frame.ScrollingEnabled = not smooth
				if smooth then
					local max = frame.AbsoluteCanvasSize - frame.AbsoluteSize
					controller.Target = Vector2.new(
						math.clamp(controller.Target.X, 0, math.max(0, max.X)),
						math.clamp(controller.Target.Y, 0, math.max(0, max.Y))
					)
					frame.CanvasPosition = appearance.Motion
							and frame.CanvasPosition:Lerp(controller.Target, 1 - math.exp(-18 * dt))
						or controller.Target
				else
					controller.Target = frame.CanvasPosition
				end
			end
		end
	end)
	function Window:SetMotion(value)
		appearance.Motion = value == true
	end
	function Window:SetSound(value)
		appearance.Sound = value == true
	end
	function Window:SetVolume(value)
		appearance.Volume = math.clamp(tonumber(value) or 0.15, 0, 1)
	end
	function Window:SetSmoothScroll(value)
		appearance.SmoothScroll = value == true
	end
	local function recolor(oldColors, newColors)
		for _, obj in ipairs(gui:GetDescendants()) do
			local properties = {}
			if obj:IsA("GuiObject") then
				properties[#properties + 1] = "BackgroundColor3"
			end
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				properties[#properties + 1] = "TextColor3"
			end

			if obj:IsA("UIStroke") then
				properties[#properties + 1] = "Color"
			end
			if obj:IsA("ScrollingFrame") then
				properties[#properties + 1] = "ScrollBarImageColor3"
			end
			for _, property in ipairs(properties) do
				for role, oldColor in pairs(oldColors) do
					if obj[property] == oldColor then
						obj[property] = newColors[role]
					end
				end
			end
		end
	end
	function Window:SetAccent(value)
		local color = typeof(value) == "Color3" and value or Color3.fromHex(tostring(value):gsub("#", ""))
		recolor({ accent = palette.accent }, { accent = color })
		palette.accent = color
		appearance.Accent = color:ToHex()
	end
	function Window:SetSurfaceColor(role, value)
		local color = typeof(value) == "Color3" and value or Color3.fromHex(value)
		recolor({ [role] = palette[role] }, { [role] = color })
		palette[role] = color
		appearance[role == "base" and "Background" or "Panel"] = color:ToHex()
	end

	function Window:SetTheme(name)
		local themes = {
			Dark = {
				base = Color3.fromRGB(22, 20, 27),
				panel = Color3.fromRGB(15, 14, 20),
				line = Color3.fromRGB(43, 39, 50),
			},
			Midnight = {
				base = Color3.fromRGB(19, 20, 29),
				panel = Color3.fromRGB(12, 13, 21),
				line = Color3.fromRGB(36, 38, 53),
			},
			Slate = {
				base = Color3.fromRGB(27, 30, 35),
				panel = Color3.fromRGB(18, 21, 25),
				line = Color3.fromRGB(45, 49, 56),
			},
		}
		local nextTheme = themes[name] or themes.Dark
		local old = {}
		for role in pairs(nextTheme) do
			old[role] = palette[role]
		end
		recolor(old, nextTheme)
		for role, color in pairs(nextTheme) do
			palette[role] = color
		end
		appearance.Theme = themes[name] and name or "Dark"
	end
	entrance = function()
		local target = scale.Scale
		scale.Scale = target * 0.97
		TweenService
			:Create(scale, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = target })
			:Play()
		for index = 1, 6 do
			local size = 5 + index % 3 * 3
			local bubble = make("Frame", {
				Name = "OpenBubble",
				BackgroundColor3 = palette.accent,
				BackgroundTransparency = 0.87,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(size, size),
				Position = UDim2.new(0.15 + index * 0.1, 0, 1, -18),
				ZIndex = 30,
			}, root)
			round(bubble, 20)
			local rise = TweenService:Create(
				bubble,
				TweenInfo.new(0.4 + index * 0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = bubble.Position - UDim2.fromOffset(0, 30 + index * 5), BackgroundTransparency = 1 }
			)
			rise.Completed:Once(function()
				bubble:Destroy()
			end)
			rise:Play()
		end
	end
	function Window:AddSettings(category)
		local app = category:Tab({ Title = "App" })
		local colors = app:Section({ Title = "Colors", Side = "Left" })
		colors:Dropdown({
			Title = "Theme",
			Options = { "Dark", "Midnight", "Slate" },
			Default = appearance.Theme,
			Callback = function(value)
				self:SetTheme(value)
			end,
		})
		colors:ColorPicker({
			Title = "Hightlight Color",
			Default = appearance.Accent,
			Callback = function(value)
				self:SetAccent(value)
			end,
		})
		colors:Toggle({
			Title = "RGB Mode",
			Default = appearance.RGB,
			Callback = function(value)
				appearance.RGB = value
				if not value then
					self:SetAccent(appearance.Accent)
				end
			end,
		})
		local size = app:Section({ Title = "Scale", Side = "Right" })
		size:Slider({
			Title = "UI Scale",
			Min = 60,
			Max = 110,
			Default = appearance.Scale,
			Suffix = "%",
			Callback = function(value)
				appearance.Scale = value
				self:ApplyAppearance()
			end,
		})
		size:Slider({
			Title = "Logo Button Size",
			Min = 32,
			Max = 96,
			Default = appearance.FloatingSize,
			Callback = function(value)
				appearance.FloatingSize = value
				self:ApplyFloating()
			end,
		})
		local background = app:Section({ Title = "Background", Side = "Right" })
		background:Slider({
			Title = "Background Opacity",
			Min = 0,
			Max = 100,
			Default = 100 - appearance.Transparency,
			Suffix = "%",
			Callback = function(value)
				appearance.Transparency = 100 - value
				self:ApplyAppearance()
			end,
		})
		local info = app:Section({ Title = "Display", Side = "Right" })
		info:Toggle({
			Title = "Logo Button",
			Default = appearance.FloatingEnabled,
			Callback = function(value)
				appearance.FloatingEnabled = value
				self:ApplyFloating()
			end,
		})
		info:Toggle({
			Title = "Hide Userinfo",
			Default = appearance.HideInfo,
			Callback = function(value)
				appearance.HideInfo = value
				self:ApplyAppearance()
			end,
		})
		local configs = category:Tab({ Title = "Configs" })
		configs:Section({ Title = "Configs", Side = "Left" }):ConfigManager()
		return app, configs
	end
	local rgbTime = 0
	uiRuntimeConnect(RunService.Heartbeat, function(dt)
		if not appearance.RGB then
			return
		end
		rgbTime += dt
		if rgbTime < 0.06 then
			return
		end
		rgbTime = 0
		local saved = appearance.Accent
		Window:SetAccent(Color3.fromHSV((os.clock() * 0.12) % 1, 0.75, 1))
		appearance.Accent = saved
	end)

	function Window:Icon(name)
		return iconImage(name)
	end

	function Window:GetLastError()
		return Runtime.LastUIError
	end
	Window:SetTheme(appearance.Theme)
	Window:SetAccent(appearance.Accent)

	Window:ApplyAppearance()
	Window:ApplyFloating()
	uiRuntimeConnect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
		Window:ApplyAppearance()
	end)

	env.__UniversalWindow = Window
	task.defer(function()
		if Runtime.Alive then
			Window:SetVisible(true)
		end
	end)
	return Window
end

return Library
