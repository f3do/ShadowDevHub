--// =========================================================
--//                   SHADOW DEV HUB
--//              Roblox universal script
--//
--// FEATURES
--// • Responsive mobile / desktop UI
--// • Animated HUD
--// • Smooth Fly
--// • Mobile Fly up/down controls
--// • Fly speed slider
--// • WalkSpeed control
--// • JumpPower control
--// • Infinite Jump
--// • Noclip
--// • Player ESP
--// • Animated nametags
--// • FPS display
--// • Ping display
--// • Notification system
--// • Desktop keybinds
--// • Smooth tabs
--// • Smooth dragging
--// • Respawn handling
--// =========================================================

--============================================================
-- SERVICES
--============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--============================================================
-- CONFIG
--============================================================

local CONFIG = {

	WalkSpeed = 16,
	JumpPower = 50,
	FlySpeed = 55,
	SpeedEnabled = false,
	JumpEnabled = false,
	Fly = false,
	Noclip = false,
	InfiniteJump = false,
	ESP = false,
  Nametags = false,
	Notifications = true,
	-- Desktop keybinds
	FlyKey = Enum.KeyCode.F,
	MenuKey = Enum.KeyCode.RightShift,
	InfiniteJumpKey = Enum.KeyCode.Space,
}

--============================================================
-- COLORS
--============================================================

local COLORS = {

	Background = Color3.fromRGB(5, 7, 13),
	Panel = Color3.fromRGB(12, 16, 26),
	Panel2 = Color3.fromRGB(18, 23, 36),
	Panel3 = Color3.fromRGB(25, 31, 47),
	Accent = Color3.fromRGB(85, 145, 255),
	Accent2 = Color3.fromRGB(145, 90, 255),
	White = Color3.fromRGB(245, 247, 255),
	Gray = Color3.fromRGB(150, 159, 180),
	Green = Color3.fromRGB(65, 220, 135),
	Red = Color3.fromRGB(235, 70, 85),
	Yellow = Color3.fromRGB(255, 190, 75),
	Black = Color3.fromRGB(0, 0, 0),
}

--============================================================
-- TWEEN INFO
--============================================================

local TWEEN_FAST = TweenInfo.new(
	0.15,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.Out
)

local TWEEN_MED = TweenInfo.new(
	0.28,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.Out
)

local TWEEN_BACK = TweenInfo.new(
	0.45,
	Enum.EasingStyle.Back,
	Enum.EasingDirection.Out
)
--============================================================
-- STATE
--============================================================

local connections = {}

local highlights = {}
local nametags = {}

local flyConnection
local flyVelocity
local flyOrientation
local flyAttachment

local flyUpHeld = false
local flyDownHeld = false

local currentPage = "Movement"

local main
local reopen
local notificationHolder

local startFly
local stopFly

--============================================================
-- HELPERS
--============================================================

local function connect(signal, callback)

	local connection = signal:Connect(callback)
	table.insert(
		connections,
		connection
	)
	return connection
end

local function tween(object, info, properties)

	local animation = TweenService:Create(
		object,
		info,
		properties
	)
	animation:Play()
	return animation
end

local function round(object, radius)

	local corner = Instance.new("UICorner")
	corner.CornerRadius =
		UDim.new(0, radius)
	corner.Parent = object
	return corner
end

local function outline(
	object,
	color,
	transparency,
	thickness
)

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Transparency = transparency or 0
	stroke.Thickness = thickness or 1
	stroke.Parent = object
	return stroke
end

local function makeLabel(
	parent,
	text,
	size,
	font
)

	local object = Instance.new("TextLabel")
	object.BackgroundTransparency = 1
	object.Text = text
	object.TextColor3 =
		COLORS.White
	object.TextSize =
		size or 14
	object.Font =
		font or Enum.Font.Gotham
	object.Parent = parent
	return object
end

local function makeGradient(
	object,
	color1,
	color2,
	rotation
)

	local gradient =
		Instance.new("UIGradient")
	gradient.Color =
		ColorSequence.new({
			ColorSequenceKeypoint.new(
				0,
				color1
			),
			ColorSequenceKeypoint.new(
				1,
				color2
			),
		})
	gradient.Rotation =
		rotation or 0
	gradient.Parent = object
	return gradient
end

--============================================================
-- SCREEN GUI
--============================================================

local gui = Instance.new("ScreenGui")

gui.Name =
	"ShadowDevHub"

gui.ResetOnSpawn =
	false

gui.IgnoreGuiInset =
	false

gui.ZIndexBehavior =
	Enum.ZIndexBehavior.Sibling

gui.Parent =
	playerGui

--============================================================
-- NOTIFICATION SYSTEM
--============================================================

notificationHolder =
	Instance.new("Frame")

notificationHolder.Name =
	"Notifications"

notificationHolder.AnchorPoint =
	Vector2.new(1, 0)

notificationHolder.Position =
	UDim2.new(
		1,
		-18,
		0,
		18
	)

notificationHolder.Size =
	UDim2.fromOffset(
		330,
		400
	)

notificationHolder.BackgroundTransparency =
	1

notificationHolder.Parent =
	gui

local notificationLayout =
	Instance.new("UIListLayout")

notificationLayout.SortOrder =
	Enum.SortOrder.LayoutOrder

notificationLayout.Padding =
	UDim.new(0, 8)

notificationLayout.VerticalAlignment =
	Enum.VerticalAlignment.Top

notificationLayout.Parent =
	notificationHolder

local function notify(
	titleText,
	messageText,
	color
)

	if not CONFIG.Notifications then
		return
	end
	local notification =
		Instance.new("Frame")
	notification.Size =
		UDim2.new(
			1,
			0,
			0,
			70
		)
	notification.BackgroundColor3 =
		COLORS.Panel
	notification.BorderSizePixel =
		0
	notification.Parent =
		notificationHolder
	round(
		notification,
		14
	)
	outline(
		notification,
		color or COLORS.Accent,
		0.35,
		1.2
	)
	local accent =
		Instance.new("Frame")
	accent.Size =
		UDim2.new(
			0,
			4,
			1,
			0
		)
	accent.BackgroundColor3 =
		color or COLORS.Accent
	accent.BorderSizePixel =
		0
	accent.Parent =
		notification
	round(
		accent,
		4
	)
	local title =
		makeLabel(
			notification,
			titleText,
			13,
			Enum.Font.GothamBold
		)
	title.Position =
		UDim2.fromOffset(
			16,
			10
		)
	title.Size =
		UDim2.new(
			1,
			-30,
			0,
			20
		)
	title.TextXAlignment =
		Enum.TextXAlignment.Left
	local message =
		makeLabel(
			notification,
			messageText,
			10,
			Enum.Font.Gotham
		)
	message.Position =
		UDim2.fromOffset(
			16,
			33
		)
	message.Size =
		UDim2.new(
			1,
			-30,
			0,
			25
		)
	message.TextColor3 =
		COLORS.Gray
	message.TextXAlignment =
		Enum.TextXAlignment.Left
	notification.Position =
		UDim2.new(
			1,
			40,
			0,
			0
		)
	tween(
		notification,
		TWEEN_BACK,
		{
			Position =
				UDim2.new(
					0,
					0,
					0,
					0
				)
		}
	)
	task.delay(
		3.5,
		function()
			if not notification.Parent then
				return
			end
			local animation =
				tween(
					notification,
					TWEEN_MED,
					{
						Position =
							UDim2.new(
								1,
								40,
								0,
								0
							)
					}
				)
			animation.Completed:Once(
				function()
					notification:Destroy()
				end
			)
		end
	)
end

--============================================================
-- BACKGROUND EFFECTS
--============================================================

local background =
	Instance.new("Frame")

background.Size =
	UDim2.fromScale(
		1,
		1
	)

background.BackgroundTransparency =
	1

background.BorderSizePixel =
	0

background.Parent =
	gui

for i = 1, 10 do

	local orb =
		Instance.new("Frame")
	local size =
		math.random(
			80,
			180
		)
	orb.Size =
		UDim2.fromOffset(
			size,
			size
		)
	orb.Position =
		UDim2.fromScale(
			math.random(
				5,
				95
			) / 100,
			math.random(
				5,
				95
			) / 100
		)
	orb.BackgroundColor3 =
		i % 2 == 0
		and COLORS.Accent
		or COLORS.Accent2
	orb.BackgroundTransparency =
		0.95
	orb.BorderSizePixel =
		0
	orb.Parent =
		background
	round(
		orb,
		size
	)
	local scale =
		Instance.new("UIScale")
	scale.Scale =
		0.7
	scale.Parent =
		orb
	task.spawn(
		function()
			while orb.Parent do
				tween(
					scale,
					TweenInfo.new(
						math.random(
							20,
							35
						) / 10,
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.InOut
					),
					{
						Scale = 1.2
					}
				)
				task.wait(
					math.random(
						20,
						35
					) / 10
				)
				if not orb.Parent then
					break
				end
				tween(
					scale,
					TweenInfo.new(
						math.random(
							20,
							35
						) / 10,
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.InOut
					),
					{
						Scale = 0.7
					}
				)
				task.wait(
					math.random(
						20,
						35
					) / 10
				)
			end
		end
	)
end

--============================================================
-- MAIN WINDOW
--============================================================

main =
	Instance.new("Frame")

main.Name =
	"Main"

main.AnchorPoint =
	Vector2.new(
		0.5,
		0.5
	)

main.Position =
	UDim2.fromScale(
		0.5,
		0.52
	)

main.Size =
	UDim2.fromOffset(
		0,
		0
	)

main.BackgroundColor3 =
	COLORS.Background

main.BorderSizePixel =
	0

main.Visible =
	false

main.ClipsDescendants =
	true

main.Parent =
	gui

round(
	main,
	22
)

outline(
	main,
	COLORS.Accent,
	0.4,
	1.5
)

--============================================================
-- HEADER
--============================================================

local header =
	Instance.new("Frame")

header.Size =
	UDim2.new(
		1,
		0,
		0,
		74
	)

header.BackgroundColor3 =
	COLORS.Panel

header.BorderSizePixel =
	0

header.Parent =
	main

round(
	header,
	22
)

local headerAccent =
	Instance.new("Frame")

headerAccent.Position =
	UDim2.fromOffset(
		17,
		18
	)

headerAccent.Size =
	UDim2.fromOffset(
		4,
		38
	)

headerAccent.BackgroundColor3 =
	COLORS.Accent

headerAccent.BorderSizePixel =
	0

headerAccent.Parent =
	header

round(
	headerAccent,
	4
)

local title =
	makeLabel(
		header,
		"SHADOW",
		21,
		Enum.Font.GothamBlack
	)

title.Position =
	UDim2.fromOffset(
		30,
		10
	)

title.Size =
	UDim2.fromOffset(
		160,
		27
	)

title.TextXAlignment =
	Enum.TextXAlignment.Left

makeGradient(
	title,
	COLORS.Accent,
	COLORS.Accent2,
	0
)

local subtitle =
	makeLabel(
		header,
		"DEVELOPER HUB",
		9,
		Enum.Font.GothamBold
	)

subtitle.Position =
	UDim2.fromOffset(
		31,
		38
	)

subtitle.Size =
	UDim2.fromOffset(
		160,
		17
	)

subtitle.TextColor3 =
	COLORS.Gray

subtitle.TextXAlignment =
	Enum.TextXAlignment.Left

--============================================================
-- FPS / PING HUD
--============================================================

local performance =
	Instance.new("Frame")

performance.AnchorPoint =
	Vector2.new(
		1,
		0.5
	)

performance.Position =
	UDim2.new(
		1,
		-112,
		0.5,
		0
	)

performance.Size =
	UDim2.fromOffset(
		95,
		38
	)

performance.BackgroundColor3 =
	COLORS.Panel2

performance.BorderSizePixel =
	0

performance.Parent =
	header

round(
	performance,
	10
)

local fpsLabel =
	makeLabel(
		performance,
		"FPS  --",
		9,
		Enum.Font.GothamBold
	)

fpsLabel.Position =
	UDim2.fromOffset(
		8,
		3
	)

fpsLabel.Size =
	UDim2.new(
		1,
		-16,
		0,
		14
	)

fpsLabel.TextColor3 =
	COLORS.Green

fpsLabel.TextXAlignment =
	Enum.TextXAlignment.Center

local pingLabel =
	makeLabel(
		performance,
		"PING  --",
		9,
		Enum.Font.GothamBold
	)

pingLabel.Position =
	UDim2.fromOffset(
		8,
		19
	)

pingLabel.Size =
	UDim2.new(
		1,
		-16,
		0,
		14
	)

pingLabel.TextColor3 =
	COLORS.Gray

pingLabel.TextXAlignment =
	Enum.TextXAlignment.Center

--============================================================
-- CLOSE BUTTON
--============================================================

local close =
	Instance.new("TextButton")

close.AnchorPoint =
	Vector2.new(
		1,
		0.5
	)

close.Position =
	UDim2.new(
		1,
		-14,
		0.5,
		0
	)

close.Size =
	UDim2.fromOffset(
		36,
		36
	)

close.BackgroundColor3 =
	COLORS.Panel3

close.Text =
	"×"

close.TextColor3 =
	COLORS.Gray

close.TextSize =
	23

close.Font =
	Enum.Font.GothamBold

close.AutoButtonColor =
	false

close.Parent =
	header

round(
	close,
	11
)

connect(
	close.MouseEnter,
	function()
		tween(
			close,
			TWEEN_FAST,
			{
				BackgroundColor3 =
					COLORS.Red,
				TextColor3 =
					COLORS.White
			}
		)
	end
)

connect(
	close.MouseLeave,
	function()
		tween(
			close,
			TWEEN_FAST,
			{
				BackgroundColor3 =
					COLORS.Panel3,
				TextColor3 =
					COLORS.Gray
			}
		)
	end
)

--============================================================
-- TABS
--============================================================

local tabBar =
	Instance.new("Frame")

tabBar.Position =
	UDim2.fromOffset(
		13,
		86
	)

tabBar.Size =
	UDim2.new(
		1,
		-26,
		0,
		44
	)

tabBar.BackgroundColor3 =
	COLORS.Panel

tabBar.BorderSizePixel =
	0

tabBar.Parent =
	main

round(
	tabBar,
	13
)

local tabLayout =
	Instance.new("UIListLayout")

tabLayout.FillDirection =
	Enum.FillDirection.Horizontal

tabLayout.HorizontalAlignment =
	Enum.HorizontalAlignment.Center

tabLayout.VerticalAlignment =
	Enum.VerticalAlignment.Center

tabLayout.Padding =
	UDim.new(
		0,
		5
	)

tabLayout.Parent =
	tabBar

--============================================================
-- CONTENT
--============================================================

local content =
	Instance.new("Frame")

content.Position =
	UDim2.fromOffset(
		13,
		141
	)

content.Size =
	UDim2.new(
		1,
		-26,
		1,
		-153
	)

content.BackgroundTransparency =
	1

content.Parent =
	main

local pages = {}

local function createPage(name)

	local page =
		Instance.new("ScrollingFrame")
	page.Name =
		name
	page.Size =
		UDim2.fromScale(
			1,
			1
		)
	page.BackgroundTransparency =
		1
	page.BorderSizePixel =
		0
	page.ScrollBarThickness =
		3
	page.ScrollBarImageColor3 =
		COLORS.Accent
	page.AutomaticCanvasSize =
		Enum.AutomaticSize.Y
	page.CanvasSize =
		UDim2.new(
			0,
			0,
			0,
			0
		)
	page.ScrollingDirection =
		Enum.ScrollingDirection.Y
	page.Visible =
		false
	page.Parent =
		content
	local layout =
		Instance.new("UIListLayout")
	layout.Padding =
		UDim.new(
			0,
			9
		)
	layout.SortOrder =
		Enum.SortOrder.LayoutOrder
	layout.Parent =
		page
	local padding =
		Instance.new("UIPadding")
	padding.PaddingBottom =
		UDim.new(
			0,
			18
		)
	padding.PaddingLeft =
		UDim.new(
			0,
			2
		)
	padding.PaddingRight =
		UDim.new(
			0,
			2
		)
	padding.Parent =
		page
	pages[name] =
		page
	return page
end

local movementPage =
	createPage(
		"Movement"
	)

local visualPage =
	createPage(
		"Visual"
	)

local serverPage =
	createPage(
		"Server"
	)

local settingsPage =
	createPage(
		"Settings"
	)

--============================================================
-- TOGGLE CREATOR
--============================================================

local function createToggle(
	parent,
	titleText,
	descriptionText,
	default,
	callback
)

	local button =
		Instance.new("TextButton")
	button.Size =
		UDim2.new(
			1,
			-2,
			0,
			66
		)
	button.BackgroundColor3 =
		COLORS.Panel
	button.Text =
		""
	button.AutoButtonColor =
		false
	button.Parent =
		parent
	round(
		button,
		14
	)
	local accent =
		Instance.new("Frame")
	accent.Position =
		UDim2.fromOffset(
			0,
			12
		)
	accent.Size =
		UDim2.fromOffset(
			3,
			42
		)
	accent.BackgroundColor3 =
		COLORS.Accent
	accent.BackgroundTransparency =
		0.7
	accent.BorderSizePixel =
		0
	accent.Parent =
		button
	round(
		accent,
		3
	)
	local titleLabel =
		makeLabel(
			button,
			titleText,
			14,
			Enum.Font.GothamBold
		)
	titleLabel.Position =
		UDim2.fromOffset(
			15,
			9
		)
	titleLabel.Size =
		UDim2.new(
			1,
			-100,
			0,
			22
		)
	titleLabel.TextXAlignment =
		Enum.TextXAlignment.Left
	local descLabel =
		makeLabel(
			button,
			descriptionText,
			10,
			Enum.Font.Gotham
		)
	descLabel.Position =
		UDim2.fromOffset(
			15,
			35
		)
	descLabel.Size =
		UDim2.new(
			1,
			-100,
			0,
			18
		)
	descLabel.TextColor3 =
		COLORS.Gray
	descLabel.TextXAlignment =
		Enum.TextXAlignment.Left
	local switch =
		Instance.new("Frame")
	switch.AnchorPoint =
		Vector2.new(
			1,
			0.5
		)
	switch.Position =
		UDim2.new(
			1,
			-15,
			0.5,
			0
		)
	switch.Size =
		UDim2.fromOffset(
			46,
			25
		)
	switch.BackgroundColor3 =
		Color3.fromRGB(
			42,
			48,
			65
		)
	switch.BorderSizePixel =
		0
	switch.Parent =
		button
	round(
		switch,
		20
	)
	local knob =
		Instance.new("Frame")
	knob.Position =
		UDim2.fromOffset(
			3,
			3
		)
	knob.Size =
		UDim2.fromOffset(
			19,
			19
		)
	knob.BackgroundColor3 =
		COLORS.White
	knob.BorderSizePixel =
		0
	knob.Parent =
		switch
	round(
		knob,
		20
	)
	local enabled =
		default or false
	local function refresh()
		tween(
			switch,
			TWEEN_FAST,
			{
				BackgroundColor3 =
					enabled
					and COLORS.Accent
					or COLORS.Pane13
			}
		)
		tween(
			knob,
			TWEEN_FAST,
			{
				Position =
					enabled
					and UDim2.fromOffset(
						24,
						3
					)
					or UDim2.fromOffset(
						3,
						3
					)
			}
		)
		tween(
			accent,
			TWEEN_FAST,
			{
				BackgroundTransparency =
					enabled
					and 0.1
					or 0.7
			}
		)
		callback(
			enabled
		)
	end
	connect(
		button.MouseButton1Click,
		function()
			enabled =
				not enabled
			refresh()
		end
	)
	connect(
		button.MouseEnter,
		function()
			tween(
				button,
				TWEEN_FAST,
				{
					BackgroundColor3 =
						COLORS.Panel2
				}
			)
		end
	)
	connect(
		button.MouseLeave,
		function()
			tween(
				button,
				TWEEN_FAST,
				{
					BackgroundColor3 =
						COLORS.Panel
				}
			)
		end
	)
	return {
		Set = function(state)
			enabled =
				state
			refresh()
		end,
		Get = function()
			return enabled
		end,
	}
end

--============================================================
-- VALUE CONTROL
--============================================================

local function createValueControl(
	parent,
	titleText,
	descriptionText,
	startValue,
	minimum,
	maximum,
	step,
	callback
)

	local container =
		Instance.new("Frame")
	container.Size =
		UDim2.new(
			1,
			-2,
			0,
			66
		)
	container.BackgroundColor3 =
		COLORS.Panel
	container.BorderSizePixel =
		0
	container.ClipsDescendants =
		true
	container.Parent =
		parent
	round(
		container,
		14
	)
	local headerButton =
		Instance.new("TextButton")
	headerButton.Size =
		UDim2.new(
			1,
			0,
			0,
			66
		)
	headerButton.BackgroundTransparency =
		1
	headerButton.Text =
		""
	headerButton.Parent =
		container
	local titleLabel =
		makeLabel(
			headerButton,
			titleText,
			14,
			Enum.Font.GothamBold
		)
	titleLabel.Position =
		UDim2.fromOffset(
			15,
			9
		)
	titleLabel.Size =
		UDim2.new(
			1,
			-100,
			0,
			22
		)
	titleLabel.TextXAlignment =
		Enum.TextXAlignment.Left
	local descLabel =
		makeLabel(
			headerButton,
			descriptionText,
			10,
			Enum.Font.Gotham
		)
	descLabel.Position =
		UDim2.fromOffset(
			15,
			35
		)
	descLabel.Size =
		UDim2.new(
			1,
			-100,
			0,
			18
		)
	descLabel.TextColor3 =
		COLORS.Gray
	descLabel.TextXAlignment =
		Enum.TextXAlignment.Left
	local valueLabel =
		makeLabel(
			headerButton,
			tostring(startValue),
			14,
			Enum.Font.GothamBold
		)
	valueLabel.AnchorPoint =
		Vector2.new(
			1,
			0.5
		)
	valueLabel.Position =
		UDim2.new(
			1,
			-16,
			0.5,
			0
		)
	valueLabel.Size =
		UDim2.fromOffset(
			70,
			25
		)
	valueLabel.TextColor3 =
		COLORS.Accent
	valueLabel.TextXAlignment =
		Enum.TextXAlignment.Right
	local controls =
		Instance.new("Frame")
	controls.Position =
		UDim2.fromOffset(
			12,
			72
		)
	controls.Size =
		UDim2.new(
			1,
			-24,
			0,
			50
		)
	controls.BackgroundColor3 =
		COLORS.Panel2
	controls.BorderSizePixel =
		0
	controls.Parent =
		container
	round(
		controls,
		10
	)
	local minus =
		Instance.new("TextButton")
	minus.Position =
		UDim2.fromOffset(
			8,
			8
		)
	minus.Size =
		UDim2.fromOffset(
			90,
			34
		)
	minus.BackgroundColor3 =
		COLORS.Panel3
	minus.Text =
		"-" .. tostring(step)
	minus.TextColor3 =
		COLORS.White
	minus.TextSize =
		13
	minus.Font =
		Enum.Font.GothamBold
	minus.AutoButtonColor =
		false
	minus.Parent =
		controls
	round(
		minus,
		8
	)
	local current =
		makeLabel(
			controls,
			tostring(startValue),
			13,
			Enum.Font.GothamBold
		)
	current.AnchorPoint =
		Vector2.new(
			0.5,
			0.5
		)
	current.Position =
		UDim2.fromScale(
			0.5,
			0.5
		)
	current.Size =
		UDim2.fromOffset(
			80,
			30
		)
	current.TextColor3 =
		COLORS.Accent
	current.TextXAlignment =
		Enum.TextXAlignment.Center
	local plus =
		Instance.new("TextButton")
	plus.AnchorPoint =
		Vector2.new(
			1,
			0
		)
	plus.Position =
		UDim2.new(
			1,
			-8,
			0,
			8
		)
	plus.Size =
		UDim2.fromOffset(
			90,
			34
		)
	plus.BackgroundColor3 =
		COLORS.Accent
	plus.Text =
		"+" .. tostring(step)
	plus.TextColor3 =
		COLORS.White
	plus.TextSize =
		13
	plus.Font =
		Enum.Font.GothamBold
	plus.AutoButtonColor =
		false
	plus.Parent =
		controls
	round(
		plus,
		8
	)
	local value =
		startValue
	local expanded =
		false
	local function update(
		newValue
	)
		value =
			math.clamp(
				newValue,
				minimum,
				maximum
			)
		valueLabel.Text =
			tostring(value)
		current.Text =
			tostring(value)
		callback(
			value
		)
	end
	connect(
		minus.MouseButton1Click,
		function()
			update(
				value - step
			)
		end
	)
	connect(
		plus.MouseButton1Click,
		function()
			update(
				value + step
			)
		end
	)
	connect(
		headerButton.MouseButton1Click,
		function()
			expanded =
				not expanded
			tween(
				container,
				TWEEN_MED,
				{
					Size =
						UDim2.new(
							1,
							-2,
							0,
							expanded
							and 130
							or 66
						)
				}
			)
		end
	)
	return {
		SetValue =
			function(v)
				update(v)
			end,
		GetValue =
			function()
				return value
			end,
	}
end

--============================================================
-- MOVEMENT PAGE
--============================================================

local walkControl =
	createValueControl(
		movementPage,
		"WalkSpeed",
		"Adjust character movement speed.",
		16,
		0,
		216,
		10,
		function(value)
			CONFIG.WalkSpeed =
				value
			if CONFIG.SpeedEnabled then
				local character =
					player.Character
				local humanoid =
					character
					and character:FindFirstChildOfClass(
						"Humanoid"
					)
				if humanoid then
					humanoid.WalkSpeed =
						value
				end
			end
		end
	)

local jumpControl =
	createValueControl(
		movementPage,
		"JumpPower",
		"Adjust character jump power.",
		50,
		0,
		200,
		10,
		function(value)
			CONFIG.JumpPower =
				value
			if CONFIG.JumpEnabled then
				local character =
					player.Character
				local humanoid =
					character
					and character:FindFirstChildOfClass(
						"Humanoid"
					)
				if humanoid then
					humanoid.UseJumpPower =
						true
					humanoid.JumpPower =
						value
				end
			end
		end
	)

local flySpeedControl =
	createValueControl(
		movementPage,
		"Fly Speed",
		"Adjust your flight movement speed.",
		55,
		10,
		200,
		10,
		function(value)
			CONFIG.FlySpeed =
				value
		end
	)

createToggle(
	movementPage,
	"Speed Boost",
	"Apply the selected WalkSpeed.",
	false,
	function(state)
		CONFIG.SpeedEnabled =
			state
		local character =
			player.Character
		local humanoid =
			character
			and character:FindFirstChildOfClass(
				"Humanoid"
			)
		if humanoid then
			humanoid.WalkSpeed =
				state
				and CONFIG.WalkSpeed
				or 16
		end
	end
)

createToggle(
	movementPage,
	"Jump Power",
	"Apply the selected JumpPower.",
	false,
	function(state)
		CONFIG.JumpEnabled =
			state
		local character =
			player.Character
		local humanoid =
			character
			and character:FindFirstChildOfClass(
				"Humanoid"
			)
		if humanoid then
			humanoid.UseJumpPower =
				true
			humanoid.JumpPower =
				state
				and CONFIG.JumpPower
				or 50
		end
	end
)

createToggle(
	movementPage,
	"Infinite Jump",
	"Toggles Infinite Jump.",
	false,
	function(state)
		CONFIG.InfiniteJump =
			state
		notify(
			"Infinite Jump",
			state
			and "Enabled"
			or "Disabled",
			state
			and COLORS.Green
			or COLORS.Red
		)
	end
)

createToggle(
	movementPage,
	"Fly",
	"Use the joystick to fly around.",
	false,
	function(state)
		CONFIG.Fly =
			state
		if state then
			startFly()
			notify(
				"Flight Enabled",
				"Use the joystick to move.",
				COLORS.Accent
			)
		else
			stopFly()
			notify(
				"Flight Disabled",
				"Flight has been turned off.",
				COLORS.Red
			)
		end
	end
)

createToggle(
	movementPage,
	"Noclip",
	"Toggles Noclip.",
	false,
	function(state)
		CONFIG.Noclip =
			state
	end
)

--============================================================
-- VISUAL PAGE
--============================================================

local function clearESP()

	for target, object in pairs(
		highlights
	) do
		if object then
			object:Destroy()
		end
		highlights[target] =
			nil
	end
end

local function addESP(target)

	if target == player then
		return
	end
	local character =
		target.Character
	if not character then
		return
	end
	if highlights[target] then
		highlights[target]:Destroy()
	end
	local highlight =
		Instance.new("Highlight")
	highlight.Name =
		"ShadowESP"
	highlight.Adornee =
		character
	highlight.FillColor =
		COLORS.Accent
	highlight.OutlineColor =
		COLORS.White
	highlight.FillTransparency =
		0.78
	highlight.OutlineTransparency =
		0.08
	highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent =
		character
	highlights[target] =
		highlight
end

local function updateESP()

	clearESP()
	if not CONFIG.ESP then
		return
	end
	for _, target in ipairs(
		Players:GetPlayers()
	) do
		addESP(target)
	end
end

createToggle(
	visualPage,
	"Player ESP",
	"Highlight players ESP.",
	false,
	function(state)
		CONFIG.ESP =
			state
		updateESP()
	end
)

--============================================================
-- NAMETAGS
--============================================================

local function removeNametag(target)

	if nametags[target] then
		nametags[target]:Destroy()
		nametags[target] =
			nil
	end
end

local function createNametag(target)

	if target == player then
		return
	end
	removeNametag(target)
	local character =
		target.Character
	if not character then
		return
	end
	local head =
		character:FindFirstChild(
			"Head"
		)
	if not head then
		return
	end
	local billboard =
		Instance.new("BillboardGui")
	billboard.Name =
		"ShadowNametag"
	billboard.Adornee =
		head
	billboard.Size =
		UDim2.fromOffset(
			235,
			72
		)
	billboard.StudsOffset =
		Vector3.new(
			0,
			3.2,
			0
		)
	billboard.AlwaysOnTop =
		true
	billboard.MaxDistance =
		250
	billboard.Parent =
		head
	local card =
		Instance.new("Frame")
	card.Size =
		UDim2.fromScale(
			1,
			1
		)
	card.BackgroundColor3 =
		COLORS.Panel
	card.BackgroundTransparency =
		0.1
	card.BorderSizePixel =
		0
	card.Parent =
		billboard
	round(
		card,
		12
	)
	local cardStroke =
		outline(
			card,
			COLORS.Accent,
			0.18,
			1.4
		)
	local accent =
		Instance.new("Frame")
	accent.Size =
		UDim2.fromOffset(
			4,
			72
		)
	accent.BackgroundColor3 =
		COLORS.Accent
	accent.BorderSizePixel =
		0
	accent.Parent =
		card
	round(
		accent,
		5
	)
	local display =
		makeLabel(
			card,
			target.DisplayName,
			15,
			Enum.Font.GothamBold
		)
	display.Position =
		UDim2.fromOffset(
			15,
			7
		)
	display.Size =
		UDim2.new(
			1,
			-25,
			0,
			22
		)
	display.TextXAlignment =
		Enum.TextXAlignment.Left
	local username =
		makeLabel(
			card,
			"@" .. target.Name,
			10,
			Enum.Font.GothamMedium
		)
	username.Position =
		UDim2.fromOffset(
			15,
			30
		)
	username.Size =
		UDim2.new(
			1,
			-25,
			0,
			15
		)
	username.TextColor3 =
		COLORS.Gray
	username.TextXAlignment =
		Enum.TextXAlignment.Left
	local branding =
		makeLabel(
			card,
			"SHADOW DEV",
			8,
			Enum.Font.GothamBlack
		)
	branding.Position =
		UDim2.fromOffset(
			15,
			49
		)
	branding.Size =
		UDim2.new(
			1,
			-25,
			0,
			14
		)
	branding.TextColor3 =
		COLORS.Accent
	branding.TextXAlignment =
		Enum.TextXAlignment.Left
	local online =
		Instance.new("Frame")
	online.AnchorPoint =
		Vector2.new(
			1,
			0.5
		)
	online.Position =
		UDim2.new(
			1,
			-10,
			0,
			17
		)
	online.Size =
		UDim2.fromOffset(
			6,
			6
		)
	online.BackgroundColor3 =
		COLORS.Green
	online.BorderSizePixel =
		0
	online.Parent =
		card
	round(
		online,
		6
	)
	task.spawn(
		function()
			while billboard.Parent do
				tween(
					cardStroke,
					TweenInfo.new(
						1.2,
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.InOut
					),
					{
						Transparency =
							0.48
					}
				)
				task.wait(
					1.2
				)
				if not billboard.Parent then
					break
				end
				tween(
					cardStroke,
					TweenInfo.new(
						1.2,
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.InOut
					),
					{
						Transparency =
							0.12
					}
				)
				task.wait(
					1.2
				)
			end
		end
	)
	nametags[target] =
		billboard
end

local function setupPlayer(target)

	if target == player then
		return
	end
	if target.Character then
		task.defer(
			function()
				createNametag(
					target
				)
				if CONFIG.ESP then
					addESP(target)
				end
			end
		)
	end
	connect(
		target.CharacterAdded,
		function()
			task.wait(
				0.25
			)
			createNametag(
				target
			)
			if CONFIG.ESP then
				addESP(target)
			end
		end
	)
end

for _, target in ipairs(
	Players:GetPlayers()
) do

	setupPlayer(
		target
	)

end

connect(
	Players.PlayerAdded,
	setupPlayer
)

connect(
	Players.PlayerRemoving,
	function(target)
		removeNametag(
			target
		)
		if highlights[target] then
			highlights[target]:Destroy()
			highlights[target] =
				nil
		end
	end
)

--============================================================
-- COMMAND BUTTON
--============================================================

local function createCommandButton(
	parent,
	titleText,
	descriptionText,
	color,
	callback
)

	local button =
		Instance.new("TextButton")
	button.Size =
		UDim2.new(
			1,
			-2,
			0,
			72
		)
	button.BackgroundColor3 =
		COLORS.Panel
	button.Text =
		""
	button.AutoButtonColor =
		false
	button.Parent =
		parent
	round(
		button,
		14
	)
	local icon =
		Instance.new("Frame")
	icon.Position =
		UDim2.fromOffset(
			13,
			16
		)
	icon.Size =
		UDim2.fromOffset(
			40,
			40
		)
	icon.BackgroundColor3 =
		color
	icon.BackgroundTransparency =
		0.82
	icon.BorderSizePixel =
		0
	icon.Parent =
		button
	round(
		icon,
		11
	)
	local titleLabel =
		makeLabel(
			button,
			titleText,
			14,
			Enum.Font.GothamBold
		)
	titleLabel.Position =
		UDim2.fromOffset(
			65,
			13
		)
	titleLabel.Size =
		UDim2.new(
			1,
			-85,
			0,
			22
		)
	titleLabel.TextXAlignment =
		Enum.TextXAlignment.Left
	local descLabel =
		makeLabel(
			button,
			descriptionText,
			10,
			Enum.Font.Gotham
		)
	descLabel.Position =
		UDim2.fromOffset(
			65,
			38
		)
	descLabel.Size =
		UDim2.new(
			1,
			-85,
			0,
			18
		)
	descLabel.TextColor3 =
		COLORS.Gray
	descLabel.TextXAlignment =
		Enum.TextXAlignment.Left
	connect(
		button.MouseEnter,
		function()
			tween(
				button,
				TWEEN_FAST,
				{
					BackgroundColor3 =
						COLORS.Panel2
				}
			)
		end
	)
	connect(
		button.MouseLeave,
		function()
			tween(
				button,
				TWEEN_FAST,
				{
					BackgroundColor3 =
						COLORS.Panel
				}
			)
		end
	)
	connect(
		button.MouseButton1Click,
		callback
	)
	return button
end

--============================================================
-- SERVER / UTILITY PAGE
--============================================================

createCommandButton(
	serverPage,
	"Reset Character",
	"Respawns your character instantly.",
	COLORS.Accent,
	function()
		local character =
			player.Character
		local humanoid =
			character
			and character:FindFirstChildOfClass(
				"Humanoid"
			)
		if humanoid then
			humanoid.Health =
				0
		end
		notify(
			"Character Reset",
			"Your character was reset.",
			COLORS.Accent
		)
	end
)

createCommandButton(
	serverPage,
	"Kick",
	"Kick yourself from the game.",
	COLORS.Green,
	function()
		player:Kick("kicked by ShadowDev !")
	end
)

--============================================================
-- SETTINGS PAGE
--============================================================

createCommandButton(
	settingsPage,
	"Reset Movement",
	"Restore default movement values.",
	COLORS.Accent,
	function()
		CONFIG.WalkSpeed =
			16
		CONFIG.JumpPower =
			50
		CONFIG.FlySpeed =
			55
		walkControl.SetValue(
			16
		)
		jumpControl.SetValue(
			50
		)
		flySpeedControl.SetValue(
			55
		)
		local character =
			player.Character
		local humanoid =
			character
			and character:FindFirstChildOfClass(
				"Humanoid"
			)
		if humanoid then
			humanoid.WalkSpeed =
				16
			humanoid.UseJumpPower =
				true
			humanoid.JumpPower =
				50
		end
		notify(
			"Movement Reset",
			"Movement values restored.",
			COLORS.Green
		)
	end
)

createCommandButton(
	settingsPage,
	"Clear ESP",
	"Remove all player highlights.",
	COLORS.Red,
	function()
		CONFIG.ESP =
			false
		clearESP()
		notify(
			"ESP Cleared",
			"Player highlights removed.",
			COLORS.Red
		)
	end
)

--============================================================
-- TAB SYSTEM
--============================================================

local tabButtons = {}

local function switchPage(name)

	currentPage =
		name
	for pageName, page in pairs(
		pages
	) do
		page.Visible =
			pageName == name
	end
	for tabName, tab in pairs(
		tabButtons
	) do
		local selected =
			tabName == name
		tween(
			tab,
			TWEEN_FAST,
			{
				BackgroundColor3 =
					selected
					and COLORS.Accent
					or COLORS.Panel2,
				TextColor3 =
					selected
					and COLORS.White
					or COLORS.Gray
			}
		)
	end
end

for _, name in ipairs({

	"Movement",
	"Visual",
	"Server",
	"Settings",

}) do

	local tab =
		Instance.new("TextButton")
	tab.Name =
		name
	tab.Size =
		UDim2.fromOffset(
			105,
			32
		)
	tab.BackgroundColor3 =
		COLORS.Panel2
	tab.Text =
		name
	tab.TextColor3 =
		COLORS.Gray
	tab.TextSize =
		10
	tab.Font =
		Enum.Font.GothamBold
	tab.AutoButtonColor =
		false
	tab.Parent =
		tabBar
	round(
		tab,
		9
	)
	tabButtons[name] =
		tab
	connect(
		tab.MouseButton1Click,
		function()
			switchPage(
				name
			)
		end
	)
end

switchPage(
	"Movement"
)

--============================================================
-- DRAGGING
--============================================================

local dragging =
	false

local dragStart
local startPosition

connect(
	header.InputBegan,
	function(input)
		if
			input.UserInputType ==
				Enum.UserInputType.MouseButton1
			or
			input.UserInputType ==
				Enum.UserInputType.Touch
		then
			dragging =
				true
			dragStart =
				input.Position
			startPosition =
				main.Position
			connect(
				input.Changed,
				function()
					if
						input.UserInputState ==
							Enum.UserInputState.End
					then
						dragging =
							false
					end
				end
			)
		end
	end
)

connect(
	UserInputService.InputChanged,
	function(input)
		if not dragging then
			return
		end
		if
			input.UserInputType ==
				Enum.UserInputType.MouseMovement
			or
			input.UserInputType ==
				Enum.UserInputType.Touch
		then
			local delta =
				input.Position -
				dragStart
			main.Position =
				UDim2.new(
					startPosition.X.Scale,
					startPosition.X.Offset +
						delta.X,
					startPosition.Y.Scale,
					startPosition.Y.Offset +
						delta.Y
				)
		end
	end
)

--============================================================
-- REOPEN BUTTON
--============================================================

reopen =
	Instance.new("TextButton")

reopen.Position =
	UDim2.fromOffset(
		12,
		62
	)

reopen.Size =
	UDim2.fromOffset(
		50,
		50
	)

reopen.BackgroundColor3 =
	COLORS.Panel

reopen.Text =
	"S"

reopen.TextColor3 =
	COLORS.White

reopen.TextSize =
	20

reopen.Font =
	Enum.Font.GothamBlack

reopen.AutoButtonColor =
	false

reopen.Visible =
	false

reopen.Parent =
	gui

round(
	reopen,
	15
)

outline(
	reopen,
	COLORS.Accent,
	0.3,
	1.5
)

--============================================================
-- FLY DOWN / UP CONTROLS
--============================================================

local function createFlyControl(
	text,
	position
)

	local button =
		Instance.new("TextButton")
	button.AnchorPoint =
		Vector2.new(
			1,
			1
		)
	button.Position =
		position
	button.Size =
		UDim2.fromOffset(
			62,
			62
		)
	button.BackgroundColor3 =
		COLORS.Panel
	button.BackgroundTransparency =
		0.08
	button.Text =
		text
	button.TextColor3 =
		COLORS.White
	button.TextSize =
		24
	button.Font =
		Enum.Font.GothamBlack
	button.AutoButtonColor =
		false
	button.Visible =
		false
	button.ZIndex =
		50
	button.Parent =
		gui
	round(
		button,
		18
	)
	outline(
		button,
		COLORS.Accent,
		0.2,
		1.5
	)
	return button
end

local flyUpButton =
	createFlyControl(
		"▲",
		UDim2.new(
			1,
			-28,
			1,
			-214
		)
	)

local flyDownButtonLocal =
	createFlyControl(
		"▼",
		UDim2.new(
			1,
			-28,
			1,
			-145
		)
	)

connect(
	flyUpButton.InputBegan,
	function(input)
		if
			input.UserInputType ==
				Enum.UserInputType.Touch
			or
			input.UserInputType ==
				Enum.UserInputType.MouseButton1
		then
			flyUpHeld =
				true
			tween(
				flyUpButton,
				TWEEN_FAST,
				{
					BackgroundColor3 =
						COLORS.Accent
				}
			)
		end
	end
)

connect(
	flyUpButton.InputEnded,
	function(input)
		if
			input.UserInputType ==
				Enum.UserInputType.Touch
			or
			input.UserInputType ==
				Enum.UserInputType.MouseButton1
		then
			flyUpHeld =
				false
			tween(
				flyUpButton,
				TWEEN_FAST,
				{
					BackgroundColor3 =
						COLORS.Panel
				}
			)
		end
	end
)

connect(
	flyDownButtonLocal.InputBegan,
	function(input)
		if
			input.UserInputType ==
				Enum.UserInputType.Touch
			or
			input.UserInputType ==
				Enum.UserInputType.MouseButton1
		then
			flyDownHeld =
				true
			tween(
				flyDownButtonLocal,
				TWEEN_FAST,
				{
					BackgroundColor3 =
						COLORS.Accent
				}
			)
		end
	end
)

connect(
	flyDownButtonLocal.InputEnded,
	function(input)
		if
			input.UserInputType ==
				Enum.UserInputType.Touch
			or
			input.UserInputType ==
				Enum.UserInputType.MouseButton1
		then
			flyDownHeld =
				false
			tween(
				flyDownButtonLocal,
				TWEEN_FAST,
				{
					BackgroundColor3 =
						COLORS.Panel
				}
			)
		end
	end
)

--============================================================
-- FLY SYSTEM
--============================================================

stopFly =
	function()
		CONFIG.Fly =
			false
		if flyConnection then
			flyConnection:Disconnect()
			flyConnection =
				nil
		end
		if flyVelocity then
			flyVelocity:Destroy()
			flyVelocity =
				nil
		end
		if flyOrientation then
			flyOrientation:Destroy()
			flyOrientation =
				nil
		end
		if flyAttachment then
			flyAttachment:Destroy()
			flyAttachment =
				nil
		end
		flyUpHeld =
			false
		flyDownHeld =
			false
		flyUpButton.Visible =
			false
		flyDownButtonLocal.Visible =
			false
		local character =
			player.Character
		if character then
			local humanoid =
				character:FindFirstChildOfClass(
					"Humanoid"
				)
			if humanoid then
				humanoid.PlatformStand =
					false
				humanoid.AutoRotate =
					true
			end
		end
	end

startFly =
	function()
		stopFly()
		local character =
			player.Character
		if not character then
			return
		end
		local humanoid =
			character:FindFirstChildOfClass(
				"Humanoid"
			)
		local root =
			character:FindFirstChild(
				"HumanoidRootPart"
			)
		if
			not humanoid
			or
			not root
		then
			return
		end
		CONFIG.Fly =
			true
		humanoid.PlatformStand =
			true
		humanoid.AutoRotate =
			false
		flyAttachment =
			Instance.new(
				"Attachment"
			)
		flyAttachment.Name =
			"ShadowFlyAttachment"
		flyAttachment.Parent =
			root
		flyVelocity =
			Instance.new(
				"LinearVelocity"
			)
		flyVelocity.Name =
			"ShadowFlyVelocity"
		flyVelocity.Attachment0 =
			flyAttachment
		flyVelocity.RelativeTo =
			Enum.ActuatorRelativeTo.World
		flyVelocity.MaxForce =
			math.huge
		flyVelocity.VectorVelocity =
			Vector3.zero
		flyVelocity.Parent =
			root
		flyOrientation =
			Instance.new(
				"AlignOrientation"
			)
		flyOrientation.Name =
			"ShadowFlyOrientation"
		flyOrientation.Attachment0 =
			flyAttachment
		flyOrientation.Mode =
			Enum.OrientationAlignmentMode.OneAttachment
		flyOrientation.MaxTorque =
			math.huge
		flyOrientation.Responsiveness =
			30
		flyOrientation.RigidityEnabled =
			false
		flyOrientation.Parent =
			root
		flyUpButton.Visible =
			true
		flyDownButtonLocal.Visible =
			true
		local velocity =
			Vector3.zero
		flyConnection =
			RunService.RenderStepped:Connect(
				function(deltaTime)
					if not CONFIG.Fly then
						return
					end
					if
						not root.Parent
						or
						not humanoid.Parent
						or
						humanoid.Health <= 0
					then
						stopFly()
						return
					end
					local camera =
						workspace.CurrentCamera
					if not camera then
						return
					end
					--============================================
					-- JOYSTICK MOVEMENT
					--============================================
					local move =
						humanoid.MoveDirection
					local target =
						move *
						CONFIG.FlySpeed
					--============================================
					-- VERTICAL MOVEMENT
					--============================================
					local vertical =
						0
					if
						flyUpHeld
						or
						humanoid.Jump
						or
						UserInputService:IsKeyDown(
							Enum.KeyCode.Space
						)
					then
						vertical =
							CONFIG.FlySpeed
					elseif flyDownHeld then
						vertical =
							-CONFIG.FlySpeed
					end
					target =
						Vector3.new(
							target.X,
							vertical,
							target.Z
						)
					--============================================
					-- SMOOTH FLIGHT
					--============================================
					local alpha =
						math.clamp(
							deltaTime * 10,
							0,
							1
						)
					velocity =
						velocity:Lerp(
							target,
							alpha
						)
					flyVelocity.VectorVelocity =
						velocity
					--============================================
					-- FACE CAMERA
					--============================================
					local look =
						camera.CFrame.LookVector
					local flat =
						Vector3.new(
							look.X,
							0,
							look.Z
						)
					if flat.Magnitude > 0.01 then
						flat =
							flat.Unit
						flyOrientation.CFrame =
							CFrame.lookAt(
								root.Position,
								root.Position +
									flat
							)
					end
				end
			)
	end

--============================================================
-- NOCLIP
--============================================================

connect(
	RunService.Stepped,
	function()
		if not CONFIG.Noclip then
			return
		end
		local character =
			player.Character
		if not character then
			return
		end
		for _, object in ipairs(
			character:GetDescendants()
		) do
			if object:IsA("BasePart") then
				object.CanCollide =
					false
			end
		end
	end
)

--============================================================
-- INFINITE JUMP
--============================================================

connect(
	UserInputService.JumpRequest,
	function()
		if not CONFIG.InfiniteJump then
			return
		end
		local character =
			player.Character
		local humanoid =
			character
			and character:FindFirstChildOfClass(
				"Humanoid"
			)
		if humanoid then
			humanoid:ChangeState(
				Enum.HumanoidStateType.Jumping
			)
		end
	end
)

--============================================================
-- PERFORMANCE MONITOR
--============================================================

local frames =
	0

local elapsed =
	0

connect(
	RunService.RenderStepped,
	function(deltaTime)
		frames +=
			1
		elapsed +=
			deltaTime
		if elapsed >= 1 then
			local fps =
				math.floor(
					frames /
					elapsed
				)
			fpsLabel.Text =
				"FPS  " ..
				tostring(fps)
			frames =
				0
			elapsed =
				0
		end
	end
)

task.spawn(
	function()
		while gui.Parent do
			task.wait(
				1
			)
			local success,
				value =
				pcall(
					function()
						return Stats
							.Network
							.ServerStatsItem[
								"Data Ping"
							]:GetValueString()
					end
				)
			if success then
				local ping =
					tostring(
						value
					):match(
						"%d+"
					)
				if ping then
					pingLabel.Text =
						"PING  " ..
						ping ..
						" ms"
				end
			end
		end
	end
)

--============================================================
-- KEYBINDS
--============================================================

connect(
	UserInputService.InputBegan,
	function(
		input,
		processed
	)
		if processed then
			return
		end
		-- Toggle menu
		if
			input.KeyCode ==
				CONFIG.MenuKey
		then
			if main.Visible then
				closeHub()
			else
				openHub()
			end
		end
		-- Fly
		if
			input.KeyCode ==
				CONFIG.FlyKey
		then
			CONFIG.Fly =
				not CONFIG.Fly
			if CONFIG.Fly then
				startFly()
				notify(
					"Flight",
					"Enabled with F.",
					COLORS.Accent
				)
			else
				stopFly()
				notify(
					"Flight",
					"Disabled.",
					COLORS.Red
				)
			end
		end
	end
)

--============================================================
-- OPEN / CLOSE
--============================================================

local function openHub()

	reopen.Visible =
		false
	main.Visible =
		true
	main.Size =
		UDim2.fromOffset(
			0,
			0
		)
	tween(
		main,
		TWEEN_BACK,
		{
			Size =
				UDim2.fromOffset(
					590,
					485
				)
		}
	)
end

local function closeHub()

	local animation =
		tween(
			main,
			TWEEN_MED,
			{
				Size =
					UDim2.fromOffset(
						0,
						0
					)
			}
		)
	animation.Completed:Once(
		function()
			main.Visible =
				false
			reopen.Visible =
				true
			reopen.Size =
				UDim2.fromOffset(
					0,
					0
				)
			tween(
				reopen,
				TWEEN_BACK,
				{
					Size =
						UDim2.fromOffset(
							50,
							50
						)
				}
			)
		end
	)
end

connect(
	close.MouseButton1Click,
	closeHub
)

connect(
	reopen.MouseButton1Click,
	openHub
)

--============================================================
-- RESPAWN HANDLING
--============================================================

connect(
	player.CharacterAdded,
	function(character)
		stopFly()
		local humanoid =
			character:WaitForChild(
				"Humanoid"
			)
		task.wait(
			0.15
		)
		if CONFIG.SpeedEnabled then
			humanoid.WalkSpeed =
				CONFIG.WalkSpeed
		end
		if CONFIG.JumpEnabled then
			humanoid.UseJumpPower =
				true
			humanoid.JumpPower =
				CONFIG.JumpPower
		end
		task.wait(
			0.3
		)
		if CONFIG.ESP then
			updateESP()
		end
	end
)

--============================================================
-- STARTUP OVERLAY (BOOT INTRO)
--============================================================

local intro = Instance.new("Frame")
intro.Size = UDim2.fromScale(1, 1)
intro.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
intro.BackgroundTransparency = 0
intro.BorderSizePixel = 0
intro.ZIndex = 999
intro.Parent = gui

local introGlow = Instance.new("Frame")
introGlow.AnchorPoint = Vector2.new(0.5, 0.5)
introGlow.Position = UDim2.fromScale(0.5, 0.5)
introGlow.Size = UDim2.fromOffset(0, 0)
introGlow.BackgroundColor3 = COLORS.Accent
introGlow.BackgroundTransparency = 0.85
introGlow.BorderSizePixel = 0
introGlow.ZIndex = 1000
introGlow.Parent = intro

round(introGlow, 999)

local introText = Instance.new("TextLabel")
introText.BackgroundTransparency = 1
introText.AnchorPoint = Vector2.new(0.5, 0.5)
introText.Position = UDim2.fromScale(0.5, 0.5)
introText.Size = UDim2.fromOffset(400, 80)
introText.Text = "SHADOW DEV HUB"
introText.TextColor3 = COLORS.White
introText.TextSize = 28
introText.Font = Enum.Font.GothamBlack
introText.ZIndex = 1001
introText.Parent = intro

makeGradient(introText, COLORS.Accent, COLORS.Accent2, 0)
--============================================================
-- GLITCH TEXT + STARTUP SOUND
--============================================================

-- Startup sound
local startupSound = Instance.new("Sound")
startupSound.Name = "ShadowStartupSound"

-- Replace this with your own Roblox audio asset ID
startupSound.SoundId = "rbxassetid://1846869595"

startupSound.Volume = 0.85
startupSound.PlaybackSpeed = 1
startupSound.Parent = intro

-- Glitch settings
local glitchRunning = true

local originalText = introText.Text

local glitchCharacters = {
	"SHADOW DEV HUB",
	"SH4DOW DEV HUB",
	"SHADOW D3V HUB",
	"SHADOW DEV_HUB",
	"SHADOW//DEV HUB",
	"SHADOW DEV HUB",
}

-- Glitch animation
task.spawn(function()

	while glitchRunning and introText.Parent do
		-- Normal text
		introText.Text = originalText
		introText.TextTransparency = 0
		task.wait(0.35)
		if not glitchRunning or not introText.Parent then
			break
		end
		-- Quick glitch burst
		for i = 1, 4 do
			introText.Text =
				glitchCharacters[
					math.random(1, #glitchCharacters)
				]
			introText.Position =
				UDim2.fromScale(
					0.5 + math.random(-2, 2) / 1000,
					0.5 + math.random(-2, 2) / 1000
				)
			introText.TextTransparency =
				math.random(0, 20) / 100
			task.wait(0.045)
		end
		-- Restore
		introText.Text = originalText
		introText.Position = UDim2.fromScale(0.5, 0.5)
		introText.TextTransparency = 0
		task.wait(0.6)
	end

end)

-- Play startup sound
startupSound:Play()
--============================================================
-- STARTUP
--============================================================

task.delay(3, function()

	-- Stop glitching before the intro disappears
	glitchRunning = false
	-- Restore text position
	introText.Text = "SHADOW DEV HUB"
	introText.Position = UDim2.fromScale(0.5, 0.5)
	-- Big cinematic glow burst
	tween(
		introGlow,
		TWEEN_MED,
		{
			Size = UDim2.fromOffset(650, 650),
			BackgroundTransparency = 1
		}
	):Play()
	-- Glitch-out effect
	for i = 1, 5 do
		introText.Position =
			UDim2.fromScale(
				0.5 + math.random(-4, 4) / 1000,
				0.5 + math.random(-4, 4) / 1000
			)
		introText.TextTransparency =
			math.random(0, 70) / 100
		task.wait(0.035)
	end
	-- Fade text
	tween(
		introText,
		TWEEN_MED,
		{
			TextTransparency = 1
		}
	):Play()
	task.wait(0.25)
	-- Fade entire intro
	tween(
		intro,
		TWEEN_MED,
		{
			BackgroundTransparency = 1
		}
	):Play()
	task.wait(0.4)
	-- Clean up
	if startupSound then
		startupSound:Stop()
	end
	if intro then
		intro:Destroy()
	end
	-- Open the hub
	openHub()

end)

--============================================================
-- CLEANUP
--============================================================

gui.Destroying:Connect(
	function()
		stopFly()
		clearESP()
		for _, target in pairs(
			nametags
		) do
			if target then
				target:Destroy()
			end
		end
		for _, connection in ipairs(
			connections
		) do
			if connection then
				connection:Disconnect()
			end
		end
	end
)
