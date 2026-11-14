local Library = {}

function Library:CreateWindow(options)
	options = options or {}
	local env = getgenv()
	local player = game:GetService("Players").LocalPlayer
	local previous = env.__UniversalWindow
	local lastAppearance = previous and previous.Appearance
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
		base = Color3.fromRGB(20, 20, 20),
		panel = Color3.fromRGB(14, 14, 14),
		text = Color3.fromRGB(238, 238, 240),
		dim = Color3.fromRGB(133, 133, 138),
		line = Color3.fromRGB(38, 38, 41),
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
			Font = Enum.Font.BuilderSans,
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
			Font = Enum.Font.BuilderSans,
			TextSize = 14,
			TextColor3 = palette.text,
			AutoButtonColor = false,
		}, parent)
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
	local assetUrl = options.AssetUrl or "https://raw.githubusercontent.com/Taryouknow/Universal_Ui/main/"
	for _, name in ipairs({ "home", "main", "settings" }) do
		local path = (options.Folder or "Universal_Ui") .. "/assets/" .. name .. ".png"
		if not isfile(path) then
			writefile(path, game:HttpGet(assetUrl .. name .. ".png"))
		end
		icons[name] = { Image = getcustomasset(path) }
	end

	local gui = make("ScreenGui", {
		Name = "UniversalUi",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 30,
	}, gethui() or player:WaitForChild("PlayerGui"))
	local root = make("Frame", {
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
		Image = options.Logo or "rbxassetid://120549670549494",
		ScaleType = Enum.ScaleType.Fit,
		Position = UDim2.fromOffset(18, 17),
		Size = UDim2.fromOffset(40, 40),
	}, header)
	local heading = text(header, options.Title or "UNIVERSAL", UDim2.fromOffset(132, 23), UDim2.fromOffset(70, 16), 15)
	local crumb =
		text(header, options.Version or "v1.0", UDim2.fromOffset(150, 18), UDim2.fromOffset(70, 40), 11, palette.dim)
	local avatar = make("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(40, 40),
		Position = UDim2.new(1, -165, 0, 18),
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150",
	}, header)
	round(avatar, 20)
	text(header, player.DisplayName, UDim2.fromOffset(108, 18), UDim2.new(1, -117, 0, 22), 12)
	text(header, options.Author or "Universal", UDim2.fromOffset(108, 14), UDim2.new(1, -117, 0, 40), 9, palette.dim)
	local shadow = make(
		"Frame",
		{
			Name = "Shadow",
			BackgroundColor3 = Color3.new(),
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(38, 114),
			Size = UDim2.new(1, -76, 1, -116),
			ZIndex = 0,
		},
		root
	)
	round(shadow, 12)
	local body = surface(root, "Workspace", UDim2.new(1, -84, 1, -116), UDim2.fromOffset(42, 110), palette.base)
	round(body, 10)
	local tabBar = make("ScrollingFrame", {
		Name = "Categories",
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
		Size = UDim2.new(1, -422, 0, 60),
		Position = UDim2.fromOffset(230, 8),
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
	make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, nav)
	local pages = make("Frame", {
		Name = "Pages",
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
		Font = Enum.Font.BuilderSans,
		TextSize = 14,
		TextColor3 = palette.text,
		PlaceholderColor3 = palette.dim,
		ZIndex = 51,
	}, popup)
	round(popupSearch, 4)
	local popupList = make("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -16, 1, -48),
		Position = UDim2.fromOffset(8, 44),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = palette.accent,
		ZIndex = 51,
	}, popup)
	make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, popupList)
	local activeDropdown
	local function closeDropdown()
		popup.Visible = false
		activeDropdown = nil
	end
	local appearance = {
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
	for name, value in pairs(lastAppearance or {}) do
		appearance[name] = value
	end
	for name, value in pairs(options.Appearance or {}) do
		appearance[name] = value
	end
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
	}
	local NativeWindow = Window.Native
	function NativeWindow:GetState()
		return root.Visible
	end
	function NativeWindow:Toggle()
		root.Visible = not root.Visible
		closeDropdown()
		Window:ApplyAppearance()
	end
	function NativeWindow:SetKeybind(key)
		appearance.ToggleKey = key.Name
	end
	function NativeWindow:SetScale(value)
		scale.Scale = value
	end
	function Window:ApplyAppearance()
		local viewport = workspace.CurrentCamera.ViewportSize
		scale.Scale = math.max(
			0.3,
			math.min(
				appearance.Scale / 100,
				(viewport.X - 28) / (options.Width or 900),
				(viewport.Y - 28) / (options.Height or 660)
			)
		)
		for _, f in ipairs(surfaces) do
			if f.Parent then
				f.BackgroundTransparency = (appearance.Transparency or 0) / 100
			end
		end
		blur.Size = appearance.Blur or 0
		blur.Enabled = root.Visible and blur.Size > 0
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
	function Window:Notify(o)
		local toast = surface(gui, "Notice", UDim2.fromOffset(330, 74), UDim2.new(1, -350, 1, -94))
		round(toast, 8)
		text(toast, o.Title or options.Title or "Universal", UDim2.new(1, -28, 0, 22), UDim2.fromOffset(14, 8), 13)
		local msg = text(
			toast,
			o.Content or o.Description or "",
			UDim2.new(1, -28, 0, 34),
			UDim2.fromOffset(14, 30),
			12,
			palette.dim
		)
		msg.TextWrapped = true
		task.delay(o.Duration or 5, function()
			if toast.Parent then
				toast:Destroy()
			end
		end)
	end
	function Window:SidebarSection(name)
		self.CurrentSection = name
	end
	function Window:SetVisible(value)
		root.Visible = value
		self:ApplyAppearance()
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
			if p.X < a.X or p.Y < a.Y or p.X > b.X or p.Y > b.Y then
				closeDropdown()
			end
		end
	end)
	local function draggable(handle, target)
		local start, origin, dragging
		uiRuntimeConnect(handle.InputBegan, function(input)
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
				local factor = target == root and scale.Scale or 1
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
	draggable(header, root)
	draggable(floating, floating)
	local groups = {}
	local selectPage
	selectPage = function(page)
		closeDropdown()
		Window.Selected = page
		page.Group.Last = page
		crumb.Text = page.Group.name .. " / " .. page.Title
		for _, p in pairs(Window.Tabs) do
			p.Frame.Visible = p == page
			p.Tab.Visible = p.Group == page.Group
			p.Tab.TextColor3 = p == page and palette.text or palette.dim
			p.Underline.Visible = p == page
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
			BackgroundColor3 = palette.accent,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 1, -3),
			Size = UDim2.fromOffset(34, 1),
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
			local f = row()
			local value = opts.Default == true
			text(f, opts.Title, UDim2.new(1, -32, 1, 0), nil, 14)
			local hit = button(f, "", UDim2.fromScale(1, 1))
			local square = make("Frame", {
				Size = UDim2.fromOffset(11, 11),
				Position = UDim2.new(1, -13, 0.5, -5),
				BackgroundColor3 = palette.check,
				BorderSizePixel = 0,
			}, f)
			round(square, 1)
			local glow = make("UIStroke", { Color = palette.check, Thickness = 3, Transparency = 0.85 }, square)
			local c = { Instance = f, Native = { Class = "Toggle", Instance = f } }
			c.Set = function(v, fire)
				value = v == true
				square.BackgroundColor3 = value and palette.check or Color3.fromRGB(24, 24, 24)
				glow.Enabled = value
				if fire ~= false then
					callback(opts.Callback)(value)
				end
			end
			c.Get = function()
				return value
			end
			function c.Native:GetState()
				return value
			end
			uiRuntimeConnect(hit.Activated, function()
				c.Set(not value, true)
			end)
			c.Set(value, false)
			return register(o.Title, opts.Title, c, "toggle")
		end
		function section:Button(opts)
			local f = row(32)
			local b = button(f, opts.Title, UDim2.fromScale(1, 1))
			b.TextXAlignment = Enum.TextXAlignment.Left
			text(f, "›", UDim2.fromOffset(16, 28), UDim2.new(1, -16, 0, 1), 18, palette.dim)
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
				Font = Enum.Font.BuilderSans,
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
			return register(o.Title, opts.Title, c, "input")
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
			return register(o.Title, opts.Title, c, "slider")
		end
		function section:Dropdown(opts)
			local f = row(opts.Thumbnail and 132 or 62)
			text(f, opts.Title, UDim2.new(1, 0, 0, 24), nil, 13, palette.dim)
			local b = button(f, "", UDim2.new(1, 0, 0, 30), UDim2.fromOffset(0, 27))
			b.BackgroundColor3 = Color3.fromRGB(23, 23, 25)
			b.BackgroundTransparency = 0
			round(b, 4)
			local caption = text(b, "", UDim2.new(1, -36, 1, 0), UDim2.fromOffset(8, 0), 13)
			text(b, "⌄", UDim2.fromOffset(24, 28), UDim2.new(1, -24, 0, 0), 15, palette.dim)
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
			local c = { Instance = f, Native = { Class = "Dropdown", Instance = f } }
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
					if child:IsA("TextButton") then
						child:Destroy()
					end
				end
				local query = popupSearch.Text:lower()
				for i, name in ipairs(options) do
					if tostring(name):lower():find(query, 1, true) then
						local entry = button(popupList, tostring(name), UDim2.new(1, -4, 0, 30))
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
				popupSearch.Text = ""
				local p = (b.AbsolutePosition - root.AbsolutePosition) / scale.Scale
				popup.Size =
					UDim2.fromOffset(b.AbsoluteSize.X / scale.Scale, math.min(260, math.max(110, #options * 33 + 52)))
				popup.Position = UDim2.fromOffset(
					math.clamp(p.X, 0, (options.Width or 900) - popup.Size.X.Offset),
					math.clamp(
						p.Y + b.AbsoluteSize.Y / scale.Scale + 4,
						0,
						(options.Height or 660) - popup.Size.Y.Offset
					)
				)
				popup.Visible = true
				c.Render()
			end)
			c.Set(value, false)
			register(o.Title, opts.Title, c, "dropdown")
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
				Image = options.Logo or "rbxassetid://120549670549494",
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromOffset(60, 60),
				Position = UDim2.fromOffset(0, 8),
			}, f)
			text(f, opts.Title, UDim2.new(1, -76, 0, 30), UDim2.fromOffset(76, 15), 16)
			text(f, "RACING", UDim2.new(1, -76, 0, 22), UDim2.fromOffset(76, 46), 12, palette.dim)
		end
		function section:UserInfo() end
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
				Set = function(value, title)
					fill.Size = UDim2.fromScale(math.clamp(value or 0, 0, 1), 1)
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
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0.5, -5, 1, 0),
				Position = UDim2.new((i - 1) * 0.5, i == 1 and 0 or 5, 0, 0),
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 2,
				ScrollBarImageColor3 = palette.accent,
			}, page.Frame)
			make("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder }, column)
			page.Columns[side] = column
		end
		page.Tab = button(tabBar, opts.Title, UDim2.fromOffset(150, 64))
		page.Tab.Visible = false
		page.Underline = make("Frame", {
			BackgroundColor3 = palette.accent,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(66, 1),
			Position = UDim2.new(0.5, -33, 1, -15),
			Visible = false,
		}, page.Tab)
		group.pages[#group.pages + 1] = page
		for i, p in ipairs(group.pages) do
			p.Tab.Position = UDim2.fromOffset((i - 1) * 150, 0)
		end
		function page:Section(settings)
			return newSection(self, settings)
		end
		function page:Category(settings)
			return newPage(group, settings)
		end
		function page.Native:Select()
			selectPage(page)
		end
		function page.Native:Section(settings)
			return page:Section(settings)
		end
		local key = #group.pages == 1 and group.name or group.name .. "/" .. opts.Title
		Window.Tabs[key] = page
		uiRuntimeConnect(page.Tab.Activated, function()
			selectPage(page)
		end)
		if opts.Default or not Window.Selected then
			selectPage(page)
		end
		return page
	end
	function Window:Tab(opts)
		local group = { name = opts.Title, pages = {}, Section = self.CurrentSection }
		local b = button(nav, "", UDim2.fromOffset(48, 48))
		b.LayoutOrder = #groups + 1
		b.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
		round(b, 6)
		local icon = icons[opts.Icon] or icons.main
		local image = make("ImageLabel", {
			BackgroundTransparency = 1,
			Image = icon.Image,
			ImageRectSize = Vector2.zero,
			ImageRectOffset = Vector2.zero,
			Size = UDim2.fromOffset(28, 28),
			Position = UDim2.fromOffset(10, 10),
			ImageColor3 = palette.text,
		}, b)
		group.Button = b
		group.Image = image
		group.Outline =
			make("UIStroke", { Color = palette.accent, Thickness = 1, Transparency = 0.6, Enabled = false }, b)
		groups[#groups + 1] = group
		Window.Groups[opts.Title] = group
		uiRuntimeConnect(b.Activated, function()
			selectPage(group.Last or group.pages[1])
		end)
		return newPage(group, opts)
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
			Http:JSONEncode({ version = 1, values = values, appearance = appearance })
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
			appearance[key] = value
		end
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
			end,
		})
		section:Button({
			Title = "Load",
			Callback = function()
				Window:LoadConfig(chosen)
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
		section:Button({
			Title = "Set autoload",
			Callback = function()
				writefile(configFolder .. "/autoload.txt", chosen)
			end,
		})
		section:Button({
			Title = "Clear autoload",
			Callback = function()
				local path = configFolder .. "/autoload.txt"
				if isfile(path) then
					delfile(path)
				end
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
			self:LoadConfig(readfile(path))
		end
	end
	local clickSound = make("Sound", {
		Name = "Click",
		SoundId = "rbxasset://sounds/electronicpingshort.wav",
		Volume = appearance.Volume,
		PlaybackSpeed = 2.8,
	}, gui)
	styleButton = function(b)
		local effect = make("UIScale", { Scale = 1 }, b)
		local hovered = false
		local function animate(value)
			if not b.Parent then
				return
			end
			if appearance.Motion then
				TweenService
					:Create(
						effect,
						TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Scale = value }
					)
					:Play()
			else
				effect.Scale = 1
			end
		end
		uiRuntimeConnect(b.MouseEnter, function()
			hovered = true
			animate(1.025)
		end)
		uiRuntimeConnect(b.MouseLeave, function()
			hovered = false
			animate(1)
		end)
		uiRuntimeConnect(b.Activated, function()
			if appearance.Motion then
				b.ClipsDescendants = true
				local ripple = make(
					"Frame",
					{
						BackgroundColor3 = palette.accent,
						BackgroundTransparency = 0.8,
						BorderSizePixel = 0,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(6, 6),
						ZIndex = b.ZIndex + 1,
					},
					b
				)
				round(ripple, 100)
				local spread = TweenService:Create(
					ripple,
					TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Size = UDim2.fromOffset(
							math.max(b.AbsoluteSize.X, b.AbsoluteSize.Y) * 1.5,
							math.max(b.AbsoluteSize.X, b.AbsoluteSize.Y) * 1.5
						),
						BackgroundTransparency = 1,
					}
				)
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
					animate(hovered and 1.025 or 1)
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
		if obj:IsA("TextButton") then
			styleButton(obj)
		end
	end
	uiRuntimeConnect(Input.InputChanged, function(input)
		local controller = hoveredScroll
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
	Window:ApplyAppearance()
	Window:ApplyFloating()
	uiRuntimeConnect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
		Window:ApplyAppearance()
	end)

	env.__UniversalWindow = Window
	return Window
end

return Library
