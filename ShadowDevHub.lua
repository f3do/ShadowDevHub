--// =========================================================
--//                   SHADOW DEV HUB
--//                 COMPLETE EDITION
--//
--// FEATURES
--// • Mobile / Desktop UI
--// • Animated startup
--// • Smooth Fly
--// • Mobile Fly up/down controls
--// • Fly speed control
--// • WalkSpeed control
--// • JumpPower control
--// • Infinite Jump
--// • Noclip
--// • Role ESP Manager
--// • Murderer = RED
--// • Sheriff = BLUE
--// • Innocent = GREEN
--// • Animated Nametags
--// • Nametag ON/OFF toggle
--// • FPS display
--// • Ping display
--// • Notifications
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

	Nametags = false,
ObjectTransparency = false,

	Notifications = true,

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

local openHub
local closeHub
local startFly
local stopFly

--============================================================
-- AIM TARGET STATE
--============================================================

local aimGui
local aimFrame
local aimReopen

local aiming = false
local selectedPlayer = nil
local aimTargetLabel
local aimToggle

local aimRenderConnection
--============================================================
-- HELPERS
--============================================================

local function connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(connections, connection)
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
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = object
	return corner
end

local function outline(object, color, transparency, thickness)
	local stroke = Instance.new("UIStroke")

	stroke.Color = color
	stroke.Transparency = transparency or 0
	stroke.Thickness = thickness or 1
	stroke.Parent = object

	return stroke
end

local function makeLabel(parent, text, size, font)
	local object = Instance.new("TextLabel")

	object.BackgroundTransparency = 1
	object.Text = text
	object.TextColor3 = COLORS.White
	object.TextSize = size or 14
	object.Font = font or Enum.Font.Gotham
	object.Parent = parent

	return object
end

local function makeGradient(object, color1, color2, rotation)
	local gradient = Instance.new("UIGradient")

	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(1, color2),
	})

	gradient.Rotation = rotation or 0
	gradient.Parent = object

	return gradient
end

--============================================================
-- SCREEN GUI
--============================================================

local gui = Instance.new("ScreenGui")

gui.Name = "ShadowDevHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

--============================================================
-- NOTIFICATIONS
--============================================================

notificationHolder = Instance.new("Frame")

notificationHolder.Name = "Notifications"
notificationHolder.AnchorPoint = Vector2.new(1, 0)
notificationHolder.Position = UDim2.new(1, -18, 0, 18)
notificationHolder.Size = UDim2.fromOffset(330, 400)
notificationHolder.BackgroundTransparency = 1
notificationHolder.Parent = gui

local notificationLayout = Instance.new("UIListLayout")

notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationLayout.Padding = UDim.new(0, 8)
notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notificationLayout.Parent = notificationHolder

local function notify(titleText, messageText, color)
	if not CONFIG.Notifications then
		return
	end

	local notification = Instance.new("Frame")

	notification.Size = UDim2.new(1, 0, 0, 70)
	notification.BackgroundColor3 = COLORS.Panel
	notification.BorderSizePixel = 0
	notification.Parent = notificationHolder

	round(notification, 14)
	outline(notification, color or COLORS.Accent, 0.35, 1.2)

	local accent = Instance.new("Frame")

	accent.Size = UDim2.new(0, 4, 1, 0)
	accent.BackgroundColor3 = color or COLORS.Accent
	accent.BorderSizePixel = 0
	accent.Parent = notification

	round(accent, 4)

	local title = makeLabel(
		notification,
		titleText,
		13,
		Enum.Font.GothamBold
	)

	title.Position = UDim2.fromOffset(16, 10)
	title.Size = UDim2.new(1, -30, 0, 20)
	title.TextXAlignment = Enum.TextXAlignment.Left

	local message = makeLabel(
		notification,
		messageText,
		10,
		Enum.Font.Gotham
	)

	message.Position = UDim2.fromOffset(16, 33)
	message.Size = UDim2.new(1, -30, 0, 25)
	message.TextColor3 = COLORS.Gray
	message.TextXAlignment = Enum.TextXAlignment.Left

	notification.Position = UDim2.new(1, 40, 0, 0)

	tween(
		notification,
		TWEEN_BACK,
		{
			Position = UDim2.new(0, 0, 0, 0)
		}
	)

	task.delay(3.5, function()
		if not notification.Parent then
			return
		end

		local animation = tween(
			notification,
			TWEEN_MED,
			{
				Position = UDim2.new(1, 40, 0, 0)
			}
		)

		animation.Completed:Once(function()
			notification:Destroy()
		end)
	end)
end

--============================================================
-- BACKGROUND
--============================================================

local background = Instance.new("Frame")

background.Size = UDim2.fromScale(1, 1)
background.BackgroundTransparency = 1
background.BorderSizePixel = 0
background.Parent = gui

for i = 1, 10 do
	local orb = Instance.new("Frame")

	local size = math.random(80, 180)

	orb.Size = UDim2.fromOffset(size, size)

	orb.Position = UDim2.fromScale(
		math.random(5, 95) / 100,
		math.random(5, 95) / 100
	)

	orb.BackgroundColor3 =
		i % 2 == 0
		and COLORS.Accent
		or COLORS.Accent2

	orb.BackgroundTransparency = 0.95
	orb.BorderSizePixel = 0
	orb.Parent = background

	round(orb, size)

	local scale = Instance.new("UIScale")
	scale.Scale = 0.7
	scale.Parent = orb

	task.spawn(function()
		while orb.Parent do
			tween(
				scale,
				TweenInfo.new(
					math.random(20, 35) / 10,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.InOut
				),
				{
					Scale = 1.2
				}
			)

			task.wait(math.random(20, 35) / 10)

			if not orb.Parent then
				break
			end

			tween(
				scale,
				TweenInfo.new(
					math.random(20, 35) / 10,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.InOut
				),
				{
					Scale = 0.7
				}
			)

			task.wait(math.random(20, 35) / 10)
		end
	end)
end

--============================================================
-- MAIN WINDOW
--============================================================

main = Instance.new("Frame")

main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.52)
main.Size = UDim2.fromOffset(0, 0)
main.BackgroundColor3 = COLORS.Background
main.BorderSizePixel = 0
main.Visible = false
main.ClipsDescendants = true
main.Parent = gui

round(main, 22)
outline(main, COLORS.Accent, 0.4, 1.5)

--============================================================
-- HEADER
--============================================================

local header = Instance.new("Frame")

header.Size = UDim2.new(1, 0, 0, 74)
header.BackgroundColor3 = COLORS.Panel
header.BorderSizePixel = 0
header.Parent = main

round(header, 22)

local headerAccent = Instance.new("Frame")

headerAccent.Position = UDim2.fromOffset(17, 18)
headerAccent.Size = UDim2.fromOffset(4, 38)
headerAccent.BackgroundColor3 = COLORS.Accent
headerAccent.BorderSizePixel = 0
headerAccent.Parent = header

round(headerAccent, 4)

local title = makeLabel(
	header,
	"SHADOW",
	21,
	Enum.Font.GothamBlack
)

title.Position = UDim2.fromOffset(30, 10)
title.Size = UDim2.fromOffset(160, 27)
title.TextXAlignment = Enum.TextXAlignment.Left

makeGradient(
	title,
	COLORS.Accent,
	COLORS.Accent2,
	0
)

local subtitle = makeLabel(
	header,
	"DEVELOPER HUB",
	9,
	Enum.Font.GothamBold
)

subtitle.Position = UDim2.fromOffset(31, 38)
subtitle.Size = UDim2.fromOffset(160, 17)
subtitle.TextColor3 = COLORS.Gray
subtitle.TextXAlignment = Enum.TextXAlignment.Left

--============================================================
-- FPS / PING
--============================================================

local performance = Instance.new("Frame")

performance.AnchorPoint = Vector2.new(1, 0.5)
performance.Position = UDim2.new(1, -112, 0.5, 0)
performance.Size = UDim2.fromOffset(95, 38)
performance.BackgroundColor3 = COLORS.Panel2
performance.BorderSizePixel = 0
performance.Parent = header

round(performance, 10)

local fpsLabel = makeLabel(
	performance,
	"FPS  --",
	9,
	Enum.Font.GothamBold
)

fpsLabel.Position = UDim2.fromOffset(8, 3)
fpsLabel.Size = UDim2.new(1, -16, 0, 14)
fpsLabel.TextColor3 = COLORS.Green
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center

local pingLabel = makeLabel(
	performance,
	"PING  --",
	9,
	Enum.Font.GothamBold
)

pingLabel.Position = UDim2.fromOffset(8, 19)
pingLabel.Size = UDim2.new(1, -16, 0, 14)
pingLabel.TextColor3 = COLORS.Gray
pingLabel.TextXAlignment = Enum.TextXAlignment.Center

--============================================================
-- CLOSE
--============================================================

local close = Instance.new("TextButton")

close.AnchorPoint = Vector2.new(1, 0.5)
close.Position = UDim2.new(1, -14, 0.5, 0)
close.Size = UDim2.fromOffset(36, 36)
close.BackgroundColor3 = COLORS.Panel3
close.Text = "×"
close.TextColor3 = COLORS.Gray
close.TextSize = 23
close.Font = Enum.Font.GothamBold
close.AutoButtonColor = false
close.Parent = header

round(close, 11)

connect(close.MouseEnter, function()
	tween(close, TWEEN_FAST, {
		BackgroundColor3 = COLORS.Red,
		TextColor3 = COLORS.White
	})
end)

connect(close.MouseLeave, function()
	tween(close, TWEEN_FAST, {
		BackgroundColor3 = COLORS.Panel3,
		TextColor3 = COLORS.Gray
	})
end)

--============================================================
-- TABS
--============================================================

local tabBar = Instance.new("Frame")

tabBar.Position = UDim2.fromOffset(13, 86)
tabBar.Size = UDim2.new(1, -26, 0, 44)
tabBar.BackgroundColor3 = COLORS.Panel
tabBar.BorderSizePixel = 0
tabBar.Parent = main

round(tabBar, 13)

local tabLayout = Instance.new("UIListLayout")

tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabBar

--============================================================
-- CONTENT
--============================================================

local content = Instance.new("Frame")

content.Position = UDim2.fromOffset(13, 141)
content.Size = UDim2.new(1, -26, 1, -153)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}

local function createPage(name)
	local page = Instance.new("ScrollingFrame")

	page.Name = name
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = COLORS.Accent
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.ScrollingDirection = Enum.ScrollingDirection.Y
	page.Visible = false
	page.Parent = content

	local layout = Instance.new("UIListLayout")

	layout.Padding = UDim.new(0, 9)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	local padding = Instance.new("UIPadding")

	padding.PaddingBottom = UDim.new(0, 18)
	padding.PaddingLeft = UDim.new(0, 2)
	padding.PaddingRight = UDim.new(0, 2)
	padding.Parent = page

	pages[name] = page

	return page
end

local movementPage = createPage("Movement")
local visualPage = createPage("Visual")
local serverPage = createPage("Server")
local settingsPage = createPage("Settings")

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

	local button = Instance.new("TextButton")

	button.Size = UDim2.new(1, -2, 0, 66)
	button.BackgroundColor3 = COLORS.Panel
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = parent

	round(button, 14)

	local accent = Instance.new("Frame")

	accent.Position = UDim2.fromOffset(0, 12)
	accent.Size = UDim2.fromOffset(3, 42)
	accent.BackgroundColor3 = COLORS.Accent
	accent.BackgroundTransparency = 0.7
	accent.BorderSizePixel = 0
	accent.Parent = button

	round(accent, 3)

	local titleLabel = makeLabel(
		button,
		titleText,
		14,
		Enum.Font.GothamBold
	)

	titleLabel.Position = UDim2.fromOffset(15, 9)
	titleLabel.Size = UDim2.new(1, -100, 0, 22)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local descLabel = makeLabel(
		button,
		descriptionText,
		10,
		Enum.Font.Gotham
	)

	descLabel.Position = UDim2.fromOffset(15, 35)
	descLabel.Size = UDim2.new(1, -100, 0, 18)
	descLabel.TextColor3 = COLORS.Gray
	descLabel.TextXAlignment = Enum.TextXAlignment.Left

	local switch = Instance.new("Frame")

	switch.AnchorPoint = Vector2.new(1, 0.5)
	switch.Position = UDim2.new(1, -15, 0.5, 0)
	switch.Size = UDim2.fromOffset(46, 25)
	switch.BackgroundColor3 = Color3.fromRGB(42, 48, 65)
	switch.BorderSizePixel = 0
	switch.Parent = button

	round(switch, 20)

	local knob = Instance.new("Frame")

	knob.Position = UDim2.fromOffset(3, 3)
	knob.Size = UDim2.fromOffset(19, 19)
	knob.BackgroundColor3 = COLORS.White
	knob.BorderSizePixel = 0
	knob.Parent = switch

	round(knob, 20)

	local enabled = default or false

	local function refresh()
		tween(
			switch,
			TWEEN_FAST,
			{
				BackgroundColor3 =
					enabled
					and COLORS.Accent
					or COLORS.Panel3
			}
		)

		tween(
			knob,
			TWEEN_FAST,
			{
				Position =
					enabled
					and UDim2.fromOffset(24, 3)
					or UDim2.fromOffset(3, 3)
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

		callback(enabled)
	end

	connect(button.MouseButton1Click, function()
		enabled = not enabled
		refresh()
	end)

	connect(button.MouseEnter, function()
		tween(button, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Panel2
		})
	end)

	connect(button.MouseLeave, function()
		tween(button, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Panel
		})
	end)

	return {
		Set = function(state)
			enabled = state
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

	local container = Instance.new("Frame")

	container.Size = UDim2.new(1, -2, 0, 66)
	container.BackgroundColor3 = COLORS.Panel
	container.BorderSizePixel = 0
	container.ClipsDescendants = true
	container.Parent = parent

	round(container, 14)

	local headerButton = Instance.new("TextButton")

	headerButton.Size = UDim2.new(1, 0, 0, 66)
	headerButton.BackgroundTransparency = 1
	headerButton.Text = ""
	headerButton.Parent = container

	local titleLabel = makeLabel(
		headerButton,
		titleText,
		14,
		Enum.Font.GothamBold
	)

	titleLabel.Position = UDim2.fromOffset(15, 9)
	titleLabel.Size = UDim2.new(1, -100, 0, 22)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local descLabel = makeLabel(
		headerButton,
		descriptionText,
		10,
		Enum.Font.Gotham
	)

	descLabel.Position = UDim2.fromOffset(15, 35)
	descLabel.Size = UDim2.new(1, -100, 0, 18)
	descLabel.TextColor3 = COLORS.Gray
	descLabel.TextXAlignment = Enum.TextXAlignment.Left

	local valueLabel = makeLabel(
		headerButton,
		tostring(startValue),
		14,
		Enum.Font.GothamBold
	)

	valueLabel.AnchorPoint = Vector2.new(1, 0.5)
	valueLabel.Position = UDim2.new(1, -16, 0.5, 0)
	valueLabel.Size = UDim2.fromOffset(70, 25)
	valueLabel.TextColor3 = COLORS.Accent
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right

	local controls = Instance.new("Frame")

	controls.Position = UDim2.fromOffset(12, 72)
	controls.Size = UDim2.new(1, -24, 0, 50)
	controls.BackgroundColor3 = COLORS.Panel2
	controls.BorderSizePixel = 0
	controls.Parent = container

	round(controls, 10)

	local minus = Instance.new("TextButton")

	minus.Position = UDim2.fromOffset(8, 8)
	minus.Size = UDim2.fromOffset(90, 34)
	minus.BackgroundColor3 = COLORS.Panel3
	minus.Text = "-" .. tostring(step)
	minus.TextColor3 = COLORS.White
	minus.TextSize = 13
	minus.Font = Enum.Font.GothamBold
	minus.AutoButtonColor = false
	minus.Parent = controls

	round(minus, 8)

	local current = makeLabel(
		controls,
		tostring(startValue),
		13,
		Enum.Font.GothamBold
	)

	current.AnchorPoint = Vector2.new(0.5, 0.5)
	current.Position = UDim2.fromScale(0.5, 0.5)
	current.Size = UDim2.fromOffset(80, 30)
	current.TextColor3 = COLORS.Accent
	current.TextXAlignment = Enum.TextXAlignment.Center

	local plus = Instance.new("TextButton")

	plus.AnchorPoint = Vector2.new(1, 0)
	plus.Position = UDim2.new(1, -8, 0, 8)
	plus.Size = UDim2.fromOffset(90, 34)
	plus.BackgroundColor3 = COLORS.Accent
	plus.Text = "+" .. tostring(step)
	plus.TextColor3 = COLORS.White
	plus.TextSize = 13
	plus.Font = Enum.Font.GothamBold
	plus.AutoButtonColor = false
	plus.Parent = controls

	round(plus, 8)

	local value = startValue
	local expanded = false

	local function update(newValue)
		value = math.clamp(newValue, minimum, maximum)

		valueLabel.Text = tostring(value)
		current.Text = tostring(value)

		callback(value)
	end

	connect(minus.MouseButton1Click, function()
		update(value - step)
	end)

	connect(plus.MouseButton1Click, function()
		update(value + step)
	end)

	connect(headerButton.MouseButton1Click, function()
		expanded = not expanded

		tween(
			container,
			TWEEN_MED,
			{
				Size = UDim2.new(
					1,
					-2,
					0,
					expanded and 130 or 66
				)
			}
		)
	end)

	return {
		SetValue = function(v)
			update(v)
		end,

		GetValue = function()
			return value
		end,
	}
end

--============================================================
-- MOVEMENT
--============================================================

local walkControl = createValueControl(
	movementPage,
	"WalkSpeed",
	"Adjust character movement speed.",
	16,
	0,
	216,
	10,
	function(value)
		CONFIG.WalkSpeed = value

		if CONFIG.SpeedEnabled then
			local character = player.Character
			local humanoid = character
				and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.WalkSpeed = value
			end
		end
	end
)

local jumpControl = createValueControl(
	movementPage,
	"JumpPower",
	"Adjust character jump power.",
	50,
	0,
	200,
	10,
	function(value)
		CONFIG.JumpPower = value

		if CONFIG.JumpEnabled then
			local character = player.Character
			local humanoid = character
				and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.UseJumpPower = true
				humanoid.JumpPower = value
			end
		end
	end
)

local flySpeedControl = createValueControl(
	movementPage,
	"Fly Speed",
	"Adjust your flight movement speed.",
	55,
	10,
	200,
	10,
	function(value)
		CONFIG.FlySpeed = value
	end
)

createToggle(
	movementPage,
	"Speed Boost",
	"Apply the selected WalkSpeed.",
	false,
	function(state)
		CONFIG.SpeedEnabled = state

		local character = player.Character
		local humanoid = character
			and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.WalkSpeed =
				state and CONFIG.WalkSpeed or 16
		end
	end
)

createToggle(
	movementPage,
	"Jump Power",
	"Apply the selected JumpPower.",
	false,
	function(state)
		CONFIG.JumpEnabled = state

		local character = player.Character
		local humanoid = character
			and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.UseJumpPower = true
			humanoid.JumpPower =
				state and CONFIG.JumpPower or 50
		end
	end
)

createToggle(
	movementPage,
	"Infinite Jump",
	"Toggles Infinite Jump.",
	false,
	function(state)
		CONFIG.InfiniteJump = state

		notify(
			"Infinite Jump",
			state and "Enabled" or "Disabled",
			state and COLORS.Green or COLORS.Red
		)
	end
)

--============================================================
-- FLY BUTTON
--============================================================

createToggle(
	movementPage,
	"Fly",
	"Use the joystick to fly around.",
	false,
	function(state)
		CONFIG.Fly = state

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
		CONFIG.Noclip = state
	end
)

--============================================================
-- STATIC MYSTERY 2 — AIM TARGET SYSTEM
--============================================================

local function getValidAimPlayers()
	local list = {}

	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then

			local character = target.Character

			local humanoid =
				character
				and character:FindFirstChildOfClass("Humanoid")

			local root =
				character
				and character:FindFirstChild("HumanoidRootPart")

			if humanoid and root and humanoid.Health > 0 then
				table.insert(list, target)
			end
		end
	end

	return list
end

local function getClosestAimPlayer()
	local character = player.Character

	if not character then
		return nil
	end

	local root =
		character:FindFirstChild("HumanoidRootPart")

	if not root then
		return nil
	end

	local closest = nil
	local closestDistance = math.huge

	for _, target in ipairs(getValidAimPlayers()) do

		local targetCharacter = target.Character

		local targetRoot =
			targetCharacter
			and targetCharacter:FindFirstChild("HumanoidRootPart")

		if targetRoot then

			local distance =
				(root.Position - targetRoot.Position).Magnitude

			if distance < closestDistance then
				closestDistance = distance
				closest = target
			end
		end
	end

	return closest
end

local function updateAimTargetLabel()
	if not aimTargetLabel then
		return
	end

	if selectedPlayer then
		aimTargetLabel.Text =
			"Target: " .. selectedPlayer.DisplayName
	else
		aimTargetLabel.Text = "Target: None"
	end
end

local function selectClosestAimPlayer()
	selectedPlayer = getClosestAimPlayer()
	updateAimTargetLabel()
end

local function cycleAimTarget(direction)
	local players = getValidAimPlayers()

	if #players == 0 then
		selectedPlayer = nil
		updateAimTargetLabel()
		return
	end

	if not selectedPlayer then
		selectedPlayer = players[1]
		updateAimTargetLabel()
		return
	end

	local currentIndex =
		table.find(players, selectedPlayer)

	if not currentIndex then
		currentIndex = 1
	else
		currentIndex += direction

		if currentIndex > #players then
			currentIndex = 1
		elseif currentIndex < 1 then
			currentIndex = #players
		end
	end

	selectedPlayer = players[currentIndex]

	updateAimTargetLabel()
end

local function aimAtSelectedPlayer()
	if not selectedPlayer then
		return
	end

	local character =
		selectedPlayer.Character

	if not character then
		return
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return
	end

	local targetPart =
		character:FindFirstChild("Head")
		or character:FindFirstChild("HumanoidRootPart")

	if not targetPart then
		return
	end

	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	camera.CFrame =
		CFrame.lookAt(
			camera.CFrame.Position,
			targetPart.Position
		)
end

local function stopAim()
	aiming = false

	if aimToggle then
		aimToggle.Text = "AIM: OFF"
		aimToggle.BackgroundColor3 = COLORS.Panel3
	end

	local character = player.Character

	if character then

		local humanoid =
			character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			workspace.CurrentCamera.CameraSubject =
				humanoid
		end
	end
end

--============================================================
-- AIM TARGET MINI GUI
--============================================================

local function createAimTargetGui()

	if aimGui then
		aimGui.Enabled = true

		if aimFrame then
			aimFrame.Visible = true
		end

		if aimReopen then
			aimReopen.Visible = false
		end

		return
	end

	--========================================================
	-- SCREEN GUI
	--========================================================

	aimGui = Instance.new("ScreenGui")

	aimGui.Name = "ShadowAimTarget"
	aimGui.ResetOnSpawn = false
	aimGui.IgnoreGuiInset = true
	aimGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	aimGui.Parent = playerGui

	--========================================================
	-- MAIN FRAME
	--========================================================

	aimFrame = Instance.new("Frame")

	aimFrame.Name = "AimFrame"
	aimFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	aimFrame.Position = UDim2.fromScale(0.5, 0.25)
	aimFrame.Size = UDim2.fromOffset(310, 155)
	aimFrame.BackgroundColor3 = COLORS.Background
	aimFrame.BorderSizePixel = 0
	aimFrame.Parent = aimGui

	round(aimFrame, 16)

	outline(
		aimFrame,
		COLORS.Accent2,
		0.15,
		1.5
	)

	--========================================================
	-- HEADER
	--========================================================

	local aimHeader = Instance.new("Frame")

	aimHeader.Size =
		UDim2.new(1, 0, 0, 45)

	aimHeader.BackgroundColor3 =
		COLORS.Panel

	aimHeader.BorderSizePixel = 0
	aimHeader.Parent = aimFrame

	round(aimHeader, 16)

	local aimTitle = makeLabel(
		aimHeader,
		"STATIC MYSTERY 2",
		17,
		Enum.Font.GothamBlack
	)

	aimTitle.Position =
		UDim2.fromOffset(12, 4)

	aimTitle.Size =
		UDim2.new(1, -80, 0, 30)

	aimTitle.TextXAlignment =
		Enum.TextXAlignment.Center

	makeGradient(
		aimTitle,
		COLORS.Accent,
		COLORS.Accent2,
		0
	)

	local targetIcon = makeLabel(
		aimHeader,
		"🎯",
		20,
		Enum.Font.GothamBold
	)

	targetIcon.Position =
		UDim2.new(0.5, 58, 0, 2)

	targetIcon.Size =
		UDim2.fromOffset(35, 35)

	--========================================================
	-- CLOSE
	--========================================================

	local aimClose = Instance.new("TextButton")

	aimClose.Size =
		UDim2.fromOffset(32, 32)

	aimClose.Position =
		UDim2.new(1, -40, 0, 7)

	aimClose.BackgroundColor3 =
		COLORS.Panel3

	aimClose.BorderSizePixel = 0
	aimClose.Text = "×"
	aimClose.TextColor3 = COLORS.Gray
	aimClose.TextSize = 21
	aimClose.Font = Enum.Font.GothamBold
	aimClose.AutoButtonColor = false
	aimClose.Parent = aimHeader

	round(aimClose, 9)

	connect(aimClose.MouseEnter, function()
		tween(aimClose, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Red,
			TextColor3 = COLORS.White
		})
	end)

	connect(aimClose.MouseLeave, function()
		tween(aimClose, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Panel3,
			TextColor3 = COLORS.Gray
		})
	end)

	connect(aimClose.MouseButton1Click, function()
		stopAim()

		aimFrame.Visible = false

		if aimReopen then
			aimReopen.Visible = true
		end
	end)

	--========================================================
	-- TARGET LABEL
	--========================================================

	aimTargetLabel = makeLabel(
		aimFrame,
		"Target: None",
		13,
		Enum.Font.GothamMedium
	)

	aimTargetLabel.Position =
		UDim2.fromOffset(15, 48)

	aimTargetLabel.Size =
		UDim2.new(1, -30, 0, 27)

	aimTargetLabel.TextColor3 =
		COLORS.Gray

	aimTargetLabel.TextXAlignment =
		Enum.TextXAlignment.Center

	--========================================================
	-- PREVIOUS
	--========================================================

	local previous = Instance.new("TextButton")

	previous.Size =
		UDim2.fromOffset(50, 42)

	previous.Position =
		UDim2.fromOffset(15, 92)

	previous.BackgroundColor3 =
		COLORS.Panel2

	previous.BorderSizePixel = 0
	previous.Text = "◀"
	previous.TextColor3 = COLORS.White
	previous.TextSize = 18
	previous.Font = Enum.Font.GothamBold
	previous.AutoButtonColor = false
	previous.Parent = aimFrame

	round(previous, 10)

	connect(previous.MouseButton1Click, function()
		cycleAimTarget(-1)
	end)

	--========================================================
	-- AIM TOGGLE
	--========================================================

	aimToggle = Instance.new("TextButton")

	aimToggle.Size =
		UDim2.fromOffset(160, 42)

	aimToggle.Position =
		UDim2.fromOffset(75, 92)

	aimToggle.BackgroundColor3 =
		COLORS.Panel3

	aimToggle.BorderSizePixel = 0
	aimToggle.Text = "AIM: OFF"
	aimToggle.TextColor3 = COLORS.White
	aimToggle.TextSize = 13
	aimToggle.Font = Enum.Font.GothamBold
	aimToggle.AutoButtonColor = false
	aimToggle.Parent = aimFrame

	round(aimToggle, 10)

	connect(aimToggle.MouseButton1Click, function()

		aiming = not aiming

		if aiming then

			if not selectedPlayer then
				selectClosestAimPlayer()
			end

			aimToggle.Text = "AIM: ON"

			aimToggle.BackgroundColor3 =
				COLORS.Green

			notify(
				"Aim Target",
				"Aim enabled.",
				COLORS.Green
			)

		else

			stopAim()

			notify(
				"Aim Target",
				"Aim disabled.",
				COLORS.Red
			)
		end
	end)

	--========================================================
	-- NEXT
	--========================================================

	local nextButton = Instance.new("TextButton")

	nextButton.Size =
		UDim2.fromOffset(50, 42)

	nextButton.Position =
		UDim2.fromOffset(245, 92)

	nextButton.BackgroundColor3 =
		COLORS.Panel2

	nextButton.BorderSizePixel = 0
	nextButton.Text = "▶"
	nextButton.TextColor3 = COLORS.White
	nextButton.TextSize = 18
	nextButton.Font = Enum.Font.GothamBold
	nextButton.AutoButtonColor = false
	nextButton.Parent = aimFrame

	round(nextButton, 10)

	connect(nextButton.MouseButton1Click, function()
		cycleAimTarget(1)
	end)

	--========================================================
	-- REOPEN BUTTON
	--========================================================

	aimReopen = Instance.new("TextButton")

	aimReopen.Name = "AimReopen"
	aimReopen.Size =
		UDim2.fromOffset(52, 52)

	aimReopen.Position =
		UDim2.new(0, 18, 1, -72)

	aimReopen.BackgroundColor3 =
		COLORS.Panel

	aimReopen.BorderSizePixel = 0
	aimReopen.Text = "🎯"
	aimReopen.TextSize = 23
	aimReopen.Font = Enum.Font.GothamBold
	aimReopen.AutoButtonColor = false
	aimReopen.Visible = false
	aimReopen.Parent = aimGui

	round(aimReopen, 26)

	outline(
		aimReopen,
		COLORS.Accent2,
		0.25,
		1.4
	)

	connect(aimReopen.MouseButton1Click, function()

		aimFrame.Visible = true
		aimReopen.Visible = false

	end)

	--========================================================
	-- DRAGGING
	--========================================================

	local dragging = false
	local dragStart
	local startPosition

	connect(aimHeader.InputBegan, function(input)

		if
			input.UserInputType ==
				Enum.UserInputType.MouseButton1
			or
			input.UserInputType ==
				Enum.UserInputType.Touch
		then

			dragging = true
			dragStart = input.Position
			startPosition = aimFrame.Position

			connect(input.Changed, function()

				if input.UserInputState ==
					Enum.UserInputState.End
				then
					dragging = false
				end

			end)
		end
	end)

	connect(UserInputService.InputChanged, function(input)

		if not dragging then
			return
		end

		if
			input.UserInputType ~=
				Enum.UserInputType.MouseMovement
			and
			input.UserInputType ~=
				Enum.UserInputType.Touch
		then
			return
		end

		local delta =
			input.Position - dragStart

		aimFrame.Position =
			UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
	end)

	--========================================================
	-- INITIAL TARGET
	--========================================================

	selectClosestAimPlayer()
end

--============================================================
-- AIM LOOP
--============================================================

aimRenderConnection =
	RunService.RenderStepped:Connect(function()

		if not aiming then
			return
		end

		if not selectedPlayer then
			selectClosestAimPlayer()
			return
		end

		local character =
			selectedPlayer.Character

		local humanoid =
			character
			and character:FindFirstChildOfClass("Humanoid")

		if
			not character
			or not humanoid
			or humanoid.Health <= 0
		then

			cycleAimTarget(1)
			return
		end

		aimAtSelectedPlayer()
	end)
--============================================================
-- NAMETAG SYSTEM
--============================================================

local function removeNametag(target)
	if nametags[target] then
		nametags[target]:Destroy()
		nametags[target] = nil
	end
end

local function createNametag(target)
	if target == player then
		return
	end

	removeNametag(target)

	if not CONFIG.Nametags then
		return
	end

	local character = target.Character

	if not character then
		return
	end

	local head = character:FindFirstChild("Head")

	if not head then
		return
	end

	local billboard = Instance.new("BillboardGui")

	billboard.Name = "ShadowNametag"
	billboard.Adornee = head
	billboard.Size = UDim2.fromOffset(235, 72)
	billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 250
	billboard.Parent = head

	local card = Instance.new("Frame")

	card.Size = UDim2.fromScale(1, 1)
	card.BackgroundColor3 = COLORS.Panel
	card.BackgroundTransparency = 0.1
	card.BorderSizePixel = 0
	card.Parent = billboard

	round(card, 12)

	local cardStroke = outline(
		card,
		COLORS.Accent,
		0.18,
		1.4
	)

	local accent = Instance.new("Frame")

	accent.Size = UDim2.fromOffset(4, 72)
	accent.BackgroundColor3 = COLORS.Accent
	accent.BorderSizePixel = 0
	accent.Parent = card

	round(accent, 5)

	local display = makeLabel(
		card,
		target.DisplayName,
		15,
		Enum.Font.GothamBold
	)

	display.Position = UDim2.fromOffset(15, 7)
	display.Size = UDim2.new(1, -25, 0, 22)
	display.TextXAlignment = Enum.TextXAlignment.Left

	local username = makeLabel(
		card,
		"@" .. target.Name,
		10,
		Enum.Font.GothamMedium
	)

	username.Position = UDim2.fromOffset(15, 30)
	username.Size = UDim2.new(1, -25, 0, 15)
	username.TextColor3 = COLORS.Gray
	username.TextXAlignment = Enum.TextXAlignment.Left

	local branding = makeLabel(
		card,
		"SHADOW DEV",
		8,
		Enum.Font.GothamBlack
	)

	branding.Position = UDim2.fromOffset(15, 49)
	branding.Size = UDim2.new(1, -25, 0, 14)
	branding.TextColor3 = COLORS.Accent
	branding.TextXAlignment = Enum.TextXAlignment.Left

	local online = Instance.new("Frame")

	online.AnchorPoint = Vector2.new(1, 0.5)
	online.Position = UDim2.new(1, -10, 0, 17)
	online.Size = UDim2.fromOffset(6, 6)
	online.BackgroundColor3 = COLORS.Green
	online.BorderSizePixel = 0
	online.Parent = card

	round(online, 6)

	task.spawn(function()
		while billboard.Parent and CONFIG.Nametags do
			tween(
				cardStroke,
				TweenInfo.new(
					1.2,
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.InOut
				),
				{
					Transparency = 0.48
				}
			)

			task.wait(1.2)

			if not billboard.Parent or not CONFIG.Nametags then
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
					Transparency = 0.12
				}
			)

			task.wait(1.2)
		end
	end)

	nametags[target] = billboard
end

local function updateNametags()
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			if CONFIG.Nametags then
				createNametag(target)
			else
				removeNametag(target)
			end
		end
	end
end

--============================================================
-- OBJECT TRANSPARENCY
--============================================================

local OBJECT_TRANSPARENCY_AMOUNT = 0.65
local originalObjectTransparency = {}

local function setObjectTransparency(enabled)
	CONFIG.ObjectTransparency = enabled

	if enabled then

		for _, object in ipairs(workspace:GetDescendants()) do

			if object:IsA("BasePart") then

				-- Don't affect your own character
				if not (
					player.Character
					and object:IsDescendantOf(player.Character)
				) then

					if originalObjectTransparency[object] == nil then
						originalObjectTransparency[object] =
							object.LocalTransparencyModifier
					end

					object.LocalTransparencyModifier =
						OBJECT_TRANSPARENCY_AMOUNT
				end
			end
		end

	else

		-- Restore original transparency
		for object, original in pairs(originalObjectTransparency) do

			if object and object.Parent then
				object.LocalTransparencyModifier = original
			end

			originalObjectTransparency[object] = nil
		end
	end
end

-- Handle objects created after the toggle is enabled
connect(workspace.DescendantAdded, function(object)

	if not CONFIG.ObjectTransparency then
		return
	end

	if not object:IsA("BasePart") then
		return
	end

	if player.Character
		and object:IsDescendantOf(player.Character) then
		return
	end

	if originalObjectTransparency[object] == nil then
		originalObjectTransparency[object] =
			object.LocalTransparencyModifier
	end

	object.LocalTransparencyModifier =
		OBJECT_TRANSPARENCY_AMOUNT
end)
--============================================================
-- VISUAL PAGE
--============================================================

createToggle(
	visualPage,
	"Nametags",
	"Show animated player nametags.",
	false,
	function(state)
		CONFIG.Nametags = state

		updateNametags()

		notify(
			"Nametags",
			state and "Nametags enabled." or "Nametags disabled.",
			state and COLORS.Green or COLORS.Red
		)
	end
)
createToggle(
	visualPage,
	"X-ray",
	"Make the map transparent.",
	false,
	function(state)

		setObjectTransparency(state)

		notify(
			"X-ray",
			state
				and "Objects are now 65% transparent."
				or "Object transparency disabled.",
			state and COLORS.Green or COLORS.Red
		)
	end
)
--============================================================
-- ESP MANAGER BUTTON
--============================================================

local function createCommandButton(
	parent,
	titleText,
	descriptionText,
	color,
	callback
)

	local button = Instance.new("TextButton")

	button.Size = UDim2.new(1, -2, 0, 72)
	button.BackgroundColor3 = COLORS.Panel
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = parent

	round(button, 14)

	local icon = Instance.new("Frame")

	icon.Position = UDim2.fromOffset(13, 16)
	icon.Size = UDim2.fromOffset(40, 40)
	icon.BackgroundColor3 = color
	icon.BackgroundTransparency = 0.82
	icon.BorderSizePixel = 0
	icon.Parent = button

	round(icon, 11)

	local titleLabel = makeLabel(
		button,
		titleText,
		14,
		Enum.Font.GothamBold
	)

	titleLabel.Position = UDim2.fromOffset(65, 13)
	titleLabel.Size = UDim2.new(1, -85, 0, 22)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local descLabel = makeLabel(
		button,
		descriptionText,
		10,
		Enum.Font.Gotham
	)

	descLabel.Position = UDim2.fromOffset(65, 38)
	descLabel.Size = UDim2.new(1, -85, 0, 18)
	descLabel.TextColor3 = COLORS.Gray
	descLabel.TextXAlignment = Enum.TextXAlignment.Left

	connect(button.MouseEnter, function()
		tween(button, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Panel2
		})
	end)

	connect(button.MouseLeave, function()
		tween(button, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Panel
		})
	end)

	connect(button.MouseButton1Click, callback)

	return button
end

--============================================================
-- MURD TP MINI GUI
--============================================================

local murdTPGui
local murdTPFrame

local function getClosestPlayer()
	local character = player.Character

	if not character then
		return nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		return nil
	end

	local closestPlayer = nil
	local closestDistance = math.huge

	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then

			local targetCharacter = target.Character
			local targetRoot = targetCharacter
				and targetCharacter:FindFirstChild("HumanoidRootPart")

			local targetHumanoid = targetCharacter
				and targetCharacter:FindFirstChildOfClass("Humanoid")

			if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then

				local distance =
					(root.Position - targetRoot.Position).Magnitude

				if distance < closestDistance then
					closestDistance = distance
					closestPlayer = target
				end
			end
		end
	end

	return closestPlayer
end

local function createMurdTPGui()

	-- Already created
	if murdTPGui then
		murdTPGui.Enabled = true
		murdTPFrame.Visible = true
		return
	end

	--========================================================
	-- SCREEN GUI
	--========================================================

	murdTPGui = Instance.new("ScreenGui")

	murdTPGui.Name = "ShadowMurdTP"
	murdTPGui.ResetOnSpawn = false
	murdTPGui.IgnoreGuiInset = true
	murdTPGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	murdTPGui.Parent = playerGui

	--========================================================
	-- MAIN FRAME
	--========================================================

	murdTPFrame = Instance.new("Frame")

	murdTPFrame.Name = "MurdTPFrame"
	murdTPFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	murdTPFrame.Position = UDim2.fromScale(0.5, 0.5)
	murdTPFrame.Size = UDim2.fromOffset(280, 175)
	murdTPFrame.BackgroundColor3 = COLORS.Background
	murdTPFrame.BorderSizePixel = 0
	murdTPFrame.Parent = murdTPGui

	round(murdTPFrame, 18)
	outline(murdTPFrame, COLORS.Red, 0.25, 1.5)

	--========================================================
	-- HEADER
	--========================================================

	local header = Instance.new("Frame")

	header.Size = UDim2.new(1, 0, 0, 55)
	header.BackgroundColor3 = COLORS.Panel
	header.BorderSizePixel = 0
	header.Parent = murdTPFrame

	round(header, 18)

	local title = makeLabel(
		header,
		"murd TP",
		19,
		Enum.Font.GothamBlack
	)

	title.Position = UDim2.fromOffset(16, 7)
	title.Size = UDim2.new(1, -65, 0, 25)
	title.TextXAlignment = Enum.TextXAlignment.Left

	makeGradient(
		title,
		COLORS.Red,
		COLORS.Accent2,
		0
	)

	local subtitle = makeLabel(
		header,
		"Teleport GUI (don't shiftlock)",
		9,
		Enum.Font.Gotham
	)

	subtitle.Position = UDim2.fromOffset(17, 32)
	subtitle.Size = UDim2.new(1, -65, 0, 15)
	subtitle.TextColor3 = COLORS.Gray
	subtitle.TextXAlignment = Enum.TextXAlignment.Left

	--========================================================
	-- CLOSE BUTTON
	--========================================================

	local closeButton = Instance.new("TextButton")

	closeButton.AnchorPoint = Vector2.new(1, 0.5)
	closeButton.Position = UDim2.new(1, -10, 0.5, 0)
	closeButton.Size = UDim2.fromOffset(32, 32)
	closeButton.BackgroundColor3 = COLORS.Panel3
	closeButton.Text = "×"
	closeButton.TextColor3 = COLORS.Gray
	closeButton.TextSize = 21
	closeButton.Font = Enum.Font.GothamBold
	closeButton.AutoButtonColor = false
	closeButton.Parent = header

	round(closeButton, 9)

	connect(closeButton.MouseEnter, function()
		tween(closeButton, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Red,
			TextColor3 = COLORS.White
		})
	end)

	connect(closeButton.MouseLeave, function()
		tween(closeButton, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Panel3,
			TextColor3 = COLORS.Gray
		})
	end)

	connect(closeButton.MouseButton1Click, function()
		murdTPFrame.Visible = false
	end)

	--========================================================
	-- TP CLOSEST BUTTON
	--========================================================

	local tpButton = Instance.new("TextButton")

	tpButton.Position = UDim2.fromOffset(15, 72)
	tpButton.Size = UDim2.new(1, -30, 0, 55)
	tpButton.BackgroundColor3 = COLORS.Red
	tpButton.BackgroundTransparency = 0.08
	tpButton.Text = "TP CLOSEST"
	tpButton.TextColor3 = COLORS.White
	tpButton.TextSize = 15
	tpButton.Font = Enum.Font.GothamBlack
	tpButton.AutoButtonColor = false
	tpButton.Parent = murdTPFrame

	round(tpButton, 12)

	outline(
		tpButton,
		COLORS.Red,
		0.15,
		1.2
	)

	connect(tpButton.MouseEnter, function()
		tween(tpButton, TWEEN_FAST, {
			BackgroundColor3 = Color3.fromRGB(255, 95, 105)
		})
	end)

	connect(tpButton.MouseLeave, function()
		tween(tpButton, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Red
		})
	end)

	connect(tpButton.MouseButton1Click, function()

		local target = getClosestPlayer()

		if not target then

			notify(
				"Murd TP",
				"No player was found.",
				COLORS.Red
			)

			return
		end

		local character = player.Character
		local targetCharacter = target.Character

		if not character or not targetCharacter then
			return
		end

		local root =
			character:FindFirstChild("HumanoidRootPart")

		local targetRoot =
			targetCharacter:FindFirstChild("HumanoidRootPart")

		if not root or not targetRoot then
			return
		end

		root.CFrame =
			targetRoot.CFrame * CFrame.new(0, 0, 3)

		notify(
			"Murd TP",
			"Teleported next to " .. target.DisplayName,
			COLORS.Red
		)
	end)

	--========================================================
	-- DRAGGING
	--========================================================

	local dragging = false
	local dragStart
	local startPosition

	connect(header.InputBegan, function(input)

		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or
			input.UserInputType == Enum.UserInputType.Touch
		then

			dragging = true
			dragStart = input.Position
			startPosition = murdTPFrame.Position

			connect(input.Changed, function()

				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end

			end)
		end
	end)

	connect(UserInputService.InputChanged, function(input)

		if not dragging then
			return
		end

		if
			input.UserInputType ~= Enum.UserInputType.MouseMovement
			and
			input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local delta = input.Position - dragStart

		murdTPFrame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)
end

--============================================================
-- MURD TP BUTTON IN MOVEMENT
--============================================================

createCommandButton(
	movementPage,
	"Murd TP",
	"Open the closest-player teleport menu.",
	COLORS.Red,
	function()

		createMurdTPGui()

		notify(
			"Murd TP",
			"Teleport menu opened.",
			COLORS.Red
		)
	end
)
--============================================================
-- ROLE ESP GUI
--============================================================

local roleESPGui
local roleESPFrame

local roleESPEnabled = false
local roleESPHighlights = {}

local ROLE_REFRESH_TIME = 0.5

local ROLE_COLORS = {
	Murderer = Color3.fromRGB(255, 0, 0),
	Sheriff = Color3.fromRGB(0, 120, 255),
	Innocent = Color3.fromRGB(0, 255, 0),
}

local function removeRoleESP(target)
	if roleESPHighlights[target] then
		roleESPHighlights[target]:Destroy()
		roleESPHighlights[target] = nil
	end

	if target.Character then
		local head = target.Character:FindFirstChild("Head")

		if head then
			local tag = head:FindFirstChild("ShadowRoleName")

			if tag then
				tag:Destroy()
			end
		end

		local highlight =
			target.Character:FindFirstChild("ShadowRoleHighlight")

		if highlight then
			highlight:Destroy()
		end
	end
end

local function getRole(target)
	local backpack = target:FindFirstChild("Backpack")
	local character = target.Character

	if
		(backpack and backpack:FindFirstChild("Knife"))
		or
		(character and character:FindFirstChild("Knife"))
	then
		return "Murderer", ROLE_COLORS.Murderer
	end

	if
		(backpack and backpack:FindFirstChild("Gun"))
		or
		(character and character:FindFirstChild("Gun"))
	then
		return "Sheriff", ROLE_COLORS.Sheriff
	end

	return "Innocent", ROLE_COLORS.Innocent
end

local function createRoleTag(target, role, color)
	if not target.Character then
		return
	end

	local head = target.Character:FindFirstChild("Head")

	if not head then
		return
	end

	local oldTag = head:FindFirstChild("ShadowRoleName")

	if oldTag then
		oldTag:Destroy()
	end

	local billboard = Instance.new("BillboardGui")

	billboard.Name = "ShadowRoleName"
	billboard.Adornee = head
	billboard.Size = UDim2.fromOffset(190, 70)
	billboard.StudsOffset = Vector3.new(0, 3.1, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 250
	billboard.Parent = head

	local nameLabel = Instance.new("TextLabel")

nameLabel.BackgroundTransparency = 1
nameLabel.Size = UDim2.new(1, 0, 0, 23)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.Text = "@" .. target.DisplayName
nameLabel.TextColor3 = COLORS.White
nameLabel.TextSize = 13
nameLabel.TextStrokeTransparency = 0.25
nameLabel.Parent = billboard

local usernameLabel = Instance.new("TextLabel")

usernameLabel.BackgroundTransparency = 1
usernameLabel.Position = UDim2.new(0, 0, 0, 20)
usernameLabel.Size = UDim2.new(1, 0, 0, 18)
usernameLabel.Font = Enum.Font.GothamMedium
usernameLabel.Text = "@" .. target.Name
usernameLabel.TextColor3 = COLORS.Gray
usernameLabel.TextSize = 10
usernameLabel.TextStrokeTransparency = 0.35
usernameLabel.Parent = billboard

	local roleLabel = Instance.new("TextLabel")

	roleLabel.BackgroundTransparency = 1
	roleLabel.Position = UDim2.new(0, 0, 0, 37)
	roleLabel.Size = UDim2.new(1, 0, 0, 25)
	roleLabel.Font = Enum.Font.GothamBlack
	roleLabel.Text = string.upper(role)
	roleLabel.TextColor3 = color
	roleLabel.TextSize = 14
	roleLabel.TextStrokeTransparency = 0.2
	roleLabel.Parent = billboard
end

local function createRoleESP(target, color, role)
	if not target.Character then
		return
	end

	removeRoleESP(target)

	local highlight = Instance.new("Highlight")

	highlight.Name = "ShadowRoleHighlight"
	highlight.Adornee = target.Character
	highlight.FillColor = color
	highlight.FillTransparency = 0.55
	highlight.OutlineColor = color
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = target.Character

	roleESPHighlights[target] = highlight

	createRoleTag(target, role, color)
end

local function updateRoleESP()
	if not roleESPEnabled then
		return
	end

	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player and target.Character then
			local role, color = getRole(target)

			createRoleESP(
				target,
				color,
				role
			)
		end
	end
end

local function roleESPOn()
	roleESPEnabled = true

	if roleESPFrame then
		roleESPFrame.StatusText.Text = "ON"
		roleESPFrame.StatusText.TextColor3 = COLORS.Green

		roleESPFrame.StatusDot.BackgroundColor3 = COLORS.Green
		roleESPFrame.Accent.BackgroundColor3 = COLORS.Green

		roleESPFrame.RefreshLabel.Text =
			"↻  ESP active • refreshing every 0.5 seconds"
	end

	updateRoleESP()
end

local function roleESPOff()
	roleESPEnabled = false

	if roleESPFrame then
		roleESPFrame.StatusText.Text = "OFF"
		roleESPFrame.StatusText.TextColor3 = COLORS.Gray

		roleESPFrame.StatusDot.BackgroundColor3 = COLORS.Red
		roleESPFrame.Accent.BackgroundColor3 = COLORS.Red

		roleESPFrame.RefreshLabel.Text =
			"↻  Auto-refreshing every 0.5 seconds"
	end

	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			removeRoleESP(target)
		end
	end
end

local function createRoleESPWindow()

	if roleESPGui then
		roleESPGui.Enabled = true
		roleESPFrame.Frame.Visible = true
		return
	end

	roleESPGui = Instance.new("ScreenGui")

	roleESPGui.Name = "ShadowRoleESP"
	roleESPGui.ResetOnSpawn = false
	roleESPGui.IgnoreGuiInset = true
	roleESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	roleESPGui.Parent = playerGui

	local frame = Instance.new("Frame")

	frame.Name = "Frame"
	frame.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
	frame.BorderSizePixel = 0
	frame.Position = UDim2.new(0, 25, 0.5, -145)
	frame.Size = UDim2.fromOffset(290, 290)
	frame.Parent = roleESPGui

	round(frame, 18)

	outline(
		frame,
		Color3.fromRGB(55, 60, 75),
		0.15,
		1.5
	)

	local accent = Instance.new("Frame")

	accent.BackgroundColor3 = COLORS.Red
	accent.BorderSizePixel = 0
	accent.Position = UDim2.new(0, 0, 0, 0)
	accent.Size = UDim2.new(1, 0, 0, 4)
	accent.Parent = frame

	round(accent, 18)

	local header = Instance.new("Frame")

	header.BackgroundTransparency = 1
	header.Position = UDim2.fromOffset(18, 13)
	header.Size = UDim2.new(1, -36, 0, 50)
	header.Parent = frame

	local roleTitle = Instance.new("TextLabel")

	roleTitle.BackgroundTransparency = 1
	roleTitle.Size = UDim2.new(1, -85, 0, 27)
	roleTitle.Font = Enum.Font.GothamBold
	roleTitle.Text = "SHADOW ESP"
	roleTitle.TextColor3 = COLORS.White
	roleTitle.TextSize = 20
	roleTitle.TextXAlignment = Enum.TextXAlignment.Left
	roleTitle.Parent = header

	local roleSubtitle = Instance.new("TextLabel")

	roleSubtitle.BackgroundTransparency = 1
	roleSubtitle.Position = UDim2.new(0, 0, 0, 27)
	roleSubtitle.Size = UDim2.new(1, -85, 0, 18)
	roleSubtitle.Font = Enum.Font.Gotham
	roleSubtitle.Text = "MM2 ESP made by ShadowDev"
	roleSubtitle.TextColor3 = COLORS.Gray
	roleSubtitle.TextSize = 11
	roleSubtitle.TextXAlignment = Enum.TextXAlignment.Left
	roleSubtitle.Parent = header

	local statusFrame = Instance.new("Frame")

	statusFrame.BackgroundColor3 = Color3.fromRGB(35, 28, 30)
	statusFrame.BorderSizePixel = 0
	statusFrame.Position = UDim2.new(1, -72, 0, 8)
	statusFrame.Size = UDim2.fromOffset(72, 29)
	statusFrame.Parent = header

	round(statusFrame, 9)

	local statusDot = Instance.new("Frame")

	statusDot.BackgroundColor3 = COLORS.Red
	statusDot.BorderSizePixel = 0
	statusDot.Position = UDim2.new(0, 9, 0.5, -4)
	statusDot.Size = UDim2.fromOffset(8, 8)
	statusDot.Parent = statusFrame

	round(statusDot, 8)

	local statusText = Instance.new("TextLabel")

	statusText.BackgroundTransparency = 1
	statusText.Position = UDim2.new(0, 23, 0, 0)
	statusText.Size = UDim2.new(1, -25, 1, 0)
	statusText.Font = Enum.Font.GothamBold
	statusText.Text = "OFF"
	statusText.TextColor3 = COLORS.Gray
	statusText.TextSize = 10
	statusText.TextXAlignment = Enum.TextXAlignment.Left
	statusText.Parent = statusFrame

	local divider = Instance.new("Frame")

	divider.BackgroundColor3 = Color3.fromRGB(40, 43, 53)
	divider.BorderSizePixel = 0
	divider.Position = UDim2.new(0, 18, 0, 73)
	divider.Size = UDim2.new(1, -36, 0, 1)
	divider.Parent = frame

	local espOn = Instance.new("TextButton")

	espOn.BackgroundColor3 = Color3.fromRGB(29, 53, 39)
	espOn.BorderSizePixel = 0
	espOn.Position = UDim2.fromOffset(18, 88)
	espOn.Size = UDim2.new(1, -36, 0, 48)
	espOn.AutoButtonColor = false
	espOn.Font = Enum.Font.GothamBold
	espOn.Text = "✓    ESP ON"
	espOn.TextColor3 = COLORS.Green
	espOn.TextSize = 14
	espOn.Parent = frame

	round(espOn, 11)
	outline(espOn, COLORS.Green, 0.55, 1)

	local espOff = Instance.new("TextButton")

	espOff.BackgroundColor3 = Color3.fromRGB(53, 29, 32)
	espOff.BorderSizePixel = 0
	espOff.Position = UDim2.fromOffset(18, 145)
	espOff.Size = UDim2.new(1, -36, 0, 48)
	espOff.AutoButtonColor = false
	espOff.Font = Enum.Font.GothamBold
	espOff.Text = "×    ESP OFF"
	espOff.TextColor3 = COLORS.Red
	espOff.TextSize = 14
	espOff.Parent = frame

	round(espOff, 11)
	outline(espOff, COLORS.Red, 0.55, 1)

	local refreshLabel = Instance.new("TextLabel")

	refreshLabel.BackgroundTransparency = 1
	refreshLabel.Position = UDim2.fromOffset(18, 200)
	refreshLabel.Size = UDim2.new(1, -36, 0, 22)
	refreshLabel.Font = Enum.Font.Gotham
	refreshLabel.Text = "↻  Auto-refreshing every 0.5 seconds"
	refreshLabel.TextColor3 = COLORS.Gray
	refreshLabel.TextSize = 11
	refreshLabel.TextXAlignment = Enum.TextXAlignment.Center
	refreshLabel.Parent = frame

	local keyInfo = Instance.new("TextLabel")

	keyInfo.BackgroundTransparency = 1
	keyInfo.Position = UDim2.fromOffset(18, 222)
	keyInfo.Size = UDim2.new(1, -36, 0, 18)
	keyInfo.Font = Enum.Font.GothamBold
	keyInfo.Text = "E  ENABLE       •       F  DISABLE"
	keyInfo.TextColor3 = Color3.fromRGB(115, 120, 135)
	keyInfo.TextSize = 9
	keyInfo.TextXAlignment = Enum.TextXAlignment.Center
	keyInfo.Parent = frame

	local hide = Instance.new("TextButton")

	hide.BackgroundColor3 = COLORS.Panel2
	hide.BorderSizePixel = 0
	hide.Position = UDim2.new(0, 18, 1, -32)
	hide.Size = UDim2.new(1, -36, 0, 23)
	hide.AutoButtonColor = false
	hide.Font = Enum.Font.GothamBold
	hide.Text = "HIDE MENU"
	hide.TextColor3 = COLORS.Gray
	hide.TextSize = 9
	hide.Parent = frame

	round(hide, 8)

	--========================================================
	-- OPEN BUTTON
	--========================================================

	local open = Instance.new("TextButton")

	open.BackgroundColor3 = COLORS.Panel
	open.BorderSizePixel = 0
	open.Position = UDim2.new(0, 20, 0.5, -25)
	open.Size = UDim2.fromOffset(135, 44)
	open.Visible = false
	open.AutoButtonColor = false
	open.Font = Enum.Font.GothamBold
	open.Text = "◈   OPEN ESP"
	open.TextColor3 = COLORS.White
	open.TextSize = 12
	open.Parent = roleESPGui

	round(open, 11)
	outline(open, COLORS.Green, 0.35, 1.2)

	--========================================================
	-- HOVER
	--========================================================

	local function addHover(button, normalColor, hoverColor)
		connect(button.MouseEnter, function()
			tween(button, TWEEN_FAST, {
				BackgroundColor3 = hoverColor
			})
		end)

		connect(button.MouseLeave, function()
			tween(button, TWEEN_FAST, {
				BackgroundColor3 = normalColor
			})
		end)
	end

	addHover(
		espOn,
		Color3.fromRGB(29, 53, 39),
		Color3.fromRGB(39, 70, 51)
	)

	addHover(
		espOff,
		Color3.fromRGB(53, 29, 32),
		Color3.fromRGB(72, 38, 42)
	)

	addHover(
		hide,
		COLORS.Panel2,
		COLORS.Panel3
	)

	addHover(
		open,
		COLORS.Panel,
		COLORS.Panel2
	)

	--========================================================
	-- DRAG
	--========================================================

	local dragging = false
	local dragStart
	local startPosition

	connect(header.InputBegan, function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or
			input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragStart = input.Position
			startPosition = frame.Position

			connect(input.Changed, function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	connect(UserInputService.InputChanged, function(input)
		if not dragging then
			return
		end

		if
			input.UserInputType ~= Enum.UserInputType.MouseMovement
			and
			input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)

	--========================================================
	-- BUTTON EVENTS
	--========================================================

	connect(espOn.MouseButton1Click, function()
		roleESPOn()
	end)

	connect(espOff.MouseButton1Click, function()
		roleESPOff()
	end)

	connect(hide.MouseButton1Click, function()
		frame.Visible = false
		open.Visible = true

		open.Position = UDim2.new(
			0,
			20,
			frame.Position.Y.Scale,
			frame.Position.Y.Offset
		)
	end)

	connect(open.MouseButton1Click, function()
		open.Visible = false
		frame.Visible = true
	end)

	roleESPFrame = {
		Frame = frame,
		Accent = accent,
		StatusText = statusText,
		StatusDot = statusDot,
		RefreshLabel = refreshLabel,
	}
end

--============================================================
-- ESP BUTTON IN VISUALS
--============================================================

createCommandButton(
	visualPage,
	"Role ESP",
	"Open the Murderer / Sheriff / Innocent ESP.",
	COLORS.Accent,
	function()
		createRoleESPWindow()

		notify(
			"Role ESP",
			"ESP manager opened.",
			COLORS.Accent
		)
	end
)
--============================================================
-- AIM TARGET BUTTON
--============================================================

createCommandButton(
	visualPage,
	"Aim Target",
	"Open the Static Mystery 2 target selector.",
	COLORS.Accent2,
	function()

		createAimTargetGui()

		notify(
			"Aim Target",
			"Aim target menu opened.",
			COLORS.Accent2
		)
	end
)
--============================================================
-- SERVER PAGE
--============================================================

createCommandButton(
	serverPage,
	"Reset Character",
	"Respawns your character instantly.",
	COLORS.Accent,
	function()
		local character = player.Character

		local humanoid = character
			and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.Health = 0
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
-- SETTINGS
--============================================================

createCommandButton(
	settingsPage,
	"Reset Movement",
	"Restore default movement values.",
	COLORS.Accent,
	function()
		CONFIG.WalkSpeed = 16
		CONFIG.JumpPower = 50
		CONFIG.FlySpeed = 55

		walkControl.SetValue(16)
		jumpControl.SetValue(50)
		flySpeedControl.SetValue(55)

		local character = player.Character

		local humanoid = character
			and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.WalkSpeed = 16
			humanoid.UseJumpPower = true
			humanoid.JumpPower = 50
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
	"Close Role ESP",
	"Close the separate role ESP window.",
	COLORS.Red,
	function()
		if roleESPGui then
			roleESPOff()
			roleESPGui.Enabled = false
		end

		notify(
			"Role ESP",
			"ESP manager closed.",
			COLORS.Red
		)
	end
)

--============================================================
-- TAB SYSTEM
--============================================================

local tabButtons = {}

local function switchPage(name)
	currentPage = name

	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end

	for tabName, tab in pairs(tabButtons) do
		local selected = tabName == name

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

	local tab = Instance.new("TextButton")

	tab.Name = name
	tab.Size = UDim2.fromOffset(105, 32)
	tab.BackgroundColor3 = COLORS.Panel2
	tab.Text = name
	tab.TextColor3 = COLORS.Gray
	tab.TextSize = 10
	tab.Font = Enum.Font.GothamBold
	tab.AutoButtonColor = false
	tab.Parent = tabBar

	round(tab, 9)

	tabButtons[name] = tab

	connect(tab.MouseButton1Click, function()
		switchPage(name)
	end)
end

switchPage("Movement")

--============================================================
-- DRAG MAIN HUB
--============================================================

local dragging = false
local dragStart
local startPosition

connect(header.InputBegan, function(input)
	if
		input.UserInputType == Enum.UserInputType.MouseButton1
		or
		input.UserInputType == Enum.UserInputType.Touch
	then
		dragging = true
		dragStart = input.Position
		startPosition = main.Position

		connect(input.Changed, function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

connect(UserInputService.InputChanged, function(input)
	if not dragging then
		return
	end

	if
		input.UserInputType ~= Enum.UserInputType.MouseMovement
		and
		input.UserInputType ~= Enum.UserInputType.Touch
	then
		return
	end

	local delta = input.Position - dragStart

	main.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

--============================================================
-- REOPEN BUTTON
--============================================================

reopen = Instance.new("TextButton")

reopen.Position = UDim2.fromOffset(12, 62)
reopen.Size = UDim2.fromOffset(50, 50)
reopen.BackgroundColor3 = COLORS.Panel
reopen.Text = "S"
reopen.TextColor3 = COLORS.White
reopen.TextSize = 20
reopen.Font = Enum.Font.GothamBlack
reopen.AutoButtonColor = false
reopen.Visible = false
reopen.Parent = gui

round(reopen, 15)
outline(reopen, COLORS.Accent, 0.3, 1.5)

--============================================================
-- FLY CONTROLS
--============================================================

local function createFlyControl(text, position)
	local button = Instance.new("TextButton")

	button.AnchorPoint = Vector2.new(1, 1)
	button.Position = position
	button.Size = UDim2.fromOffset(62, 62)
	button.BackgroundColor3 = COLORS.Panel
	button.BackgroundTransparency = 0.08
	button.Text = text
	button.TextColor3 = COLORS.White
	button.TextSize = 24
	button.Font = Enum.Font.GothamBlack
	button.AutoButtonColor = false
	button.Visible = false
	button.ZIndex = 50
	button.Parent = gui

	round(button, 18)
	outline(button, COLORS.Accent, 0.2, 1.5)

	return button
end

local flyUpButton = createFlyControl(
	"▲",
	UDim2.new(1, -28, 1, -214)
)

local flyDownButton = createFlyControl(
	"▼",
	UDim2.new(1, -28, 1, -145)
)

connect(flyUpButton.InputBegan, function(input)
	if
		input.UserInputType == Enum.UserInputType.Touch
		or
		input.UserInputType == Enum.UserInputType.MouseButton1
	then
		flyUpHeld = true

		tween(flyUpButton, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Accent
		})
	end
end)

connect(flyUpButton.InputEnded, function(input)
	if
		input.UserInputType == Enum.UserInputType.Touch
		or
		input.UserInputType == Enum.UserInputType.MouseButton1
	then
		flyUpHeld = false

		tween(flyUpButton, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Panel
		})
	end
end)

connect(flyDownButton.InputBegan, function(input)
	if
		input.UserInputType == Enum.UserInputType.Touch
		or
		input.UserInputType == Enum.UserInputType.MouseButton1
	then
		flyDownHeld = true

		tween(flyDownButton, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Accent
		})
	end
end)

connect(flyDownButton.InputEnded, function(input)
	if
		input.UserInputType == Enum.UserInputType.Touch
		or
		input.UserInputType == Enum.UserInputType.MouseButton1
	then
		flyDownHeld = false

		tween(flyDownButton, TWEEN_FAST, {
			BackgroundColor3 = COLORS.Panel
		})
	end
end)

--============================================================
-- FLY SYSTEM — V4 CAMERA DIRECTION
--============================================================

local flyAnimationDisabled = false
local flySavedAutoRotate = true
local flySavedPlatformStand = false

local function setFlyAnimations(enabled)
	local character = player.Character
	if not character then
		return
	end

	local animate = character:FindFirstChild("Animate")

	if animate then
		animate.Disabled = enabled
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
			if enabled then
				track:AdjustSpeed(0)
			else
				track:AdjustSpeed(1)
			end
		end
	end

	flyAnimationDisabled = enabled
end

stopFly = function()
	CONFIG.Fly = false

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	if flyVelocity then
		flyVelocity:Destroy()
		flyVelocity = nil
	end

	if flyOrientation then
		flyOrientation:Destroy()
		flyOrientation = nil
	end

	if flyAttachment then
		flyAttachment:Destroy()
		flyAttachment = nil
	end

	flyUpHeld = false
	flyDownHeld = false

	-- Hide old vertical buttons
	if flyUpButton then
		flyUpButton.Visible = false
	end

	if flyDownButton then
		flyDownButton.Visible = false
	end

	local character = player.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.PlatformStand = flySavedPlatformStand
			humanoid.AutoRotate = flySavedAutoRotate

			humanoid:ChangeState(
				Enum.HumanoidStateType.GettingUp
			)
		end

		setFlyAnimations(false)
	end
end

startFly = function()

	--========================================================
	-- CLEAN PREVIOUS FLIGHT
	--========================================================

	stopFly()

	local character = player.Character

	if not character then
		return
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	local root =
		character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		return
	end

	CONFIG.Fly = true

	--========================================================
	-- SAVE HUMANOID SETTINGS
	--========================================================

	flySavedAutoRotate = humanoid.AutoRotate
	flySavedPlatformStand = humanoid.PlatformStand

	humanoid.AutoRotate = false
	humanoid.PlatformStand = true

	-- Disable normal animations
	setFlyAnimations(true)

	--========================================================
	-- ATTACHMENT
	--========================================================

	flyAttachment = Instance.new("Attachment")
	flyAttachment.Name = "ShadowFlyAttachment"
	flyAttachment.Parent = root

	--========================================================
	-- VELOCITY
	--========================================================

	flyVelocity = Instance.new("LinearVelocity")

	flyVelocity.Name = "ShadowFlyVelocity"
	flyVelocity.Attachment0 = flyAttachment
	flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	flyVelocity.MaxForce = math.huge
	flyVelocity.VectorVelocity = Vector3.zero
	flyVelocity.Parent = root

	--========================================================
	-- ORIENTATION
	--========================================================

	flyOrientation = Instance.new("AlignOrientation")

	flyOrientation.Name = "ShadowFlyOrientation"
	flyOrientation.Attachment0 = flyAttachment
	flyOrientation.Mode =
		Enum.OrientationAlignmentMode.OneAttachment

	flyOrientation.MaxTorque = math.huge
	flyOrientation.Responsiveness = 35
	flyOrientation.RigidityEnabled = false
	flyOrientation.Parent = root

	--========================================================
	-- HIDE UP / DOWN BUTTONS
	--========================================================

	if flyUpButton then
		flyUpButton.Visible = false
	end

	if flyDownButton then
		flyDownButton.Visible = false
	end

	--========================================================
	-- FLIGHT
	--========================================================

	local currentVelocity = Vector3.zero

	flyConnection =
		RunService.RenderStepped:Connect(function(deltaTime)

			if not CONFIG.Fly then
				return
			end

			if
				not character.Parent
				or not root.Parent
				or not humanoid.Parent
				or humanoid.Health <= 0
			then
				stopFly()
				return
			end

			local camera = workspace.CurrentCamera

			if not camera then
				return
			end

			--================================================
			-- MOBILE / PC JOYSTICK INPUT
			--================================================

			local moveDirection = humanoid.MoveDirection

			local joystickAmount =
				math.clamp(moveDirection.Magnitude, 0, 1)

			--================================================
			-- CAMERA DIRECTION
			--================================================

			local cameraLook =
				camera.CFrame.LookVector

			local cameraRight =
				camera.CFrame.RightVector

			--================================================
			-- CAMERA-BASED MOVEMENT
			--================================================
			--
			-- Forward/backward follows the CAMERA'S FULL
			-- LookVector, meaning looking up/down changes
			-- the flight altitude.
			--
			-- Left/right still follows the camera's RightVector.
			--

			local forwardAmount = 0
			local rightAmount = 0

			if moveDirection.Magnitude > 0.01 then

				forwardAmount =
					moveDirection:Dot(cameraLook)

				rightAmount =
					moveDirection:Dot(cameraRight)

			end

			--================================================
			-- FINAL CAMERA MOVEMENT
			--================================================

			local flightDirection =
				(cameraLook * forwardAmount)
				+
				(cameraRight * rightAmount)

			-- Normalize so diagonal movement isn't faster
			if flightDirection.Magnitude > 1 then
				flightDirection =
					flightDirection.Unit
			end

			-- Apply joystick magnitude
			local targetVelocity =
				flightDirection
				* CONFIG.FlySpeed
				* joystickAmount

			--================================================
			-- SMOOTH ACCELERATION
			--================================================

			local smoothing =
				math.clamp(
					deltaTime * 9,
					0,
					1
				)

			currentVelocity =
				currentVelocity:Lerp(
					targetVelocity,
					smoothing
				)

			flyVelocity.VectorVelocity =
				currentVelocity

			--================================================
			-- FACE CAMERA
			--================================================

			if cameraLook.Magnitude > 0.01 then

				flyOrientation.CFrame =
					CFrame.lookAt(
						root.Position,
						root.Position + cameraLook
					)

			end

			--================================================
			-- KEEP ANIMATIONS DISABLED
			--================================================

			if not flyAnimationDisabled then
				setFlyAnimations(true)
			end

		end)
end

--============================================================
-- NOCLIP
--============================================================

connect(RunService.Stepped, function()
	if not CONFIG.Noclip then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			object.CanCollide = false
		end
	end
end)

--============================================================
-- INFINITE JUMP
--============================================================

connect(UserInputService.JumpRequest, function()
	if not CONFIG.InfiniteJump then
		return
	end

	local character = player.Character

	local humanoid =
		character
		and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid:ChangeState(
			Enum.HumanoidStateType.Jumping
		)
	end
end)

--============================================================
-- PERFORMANCE
--============================================================

local frames = 0
local elapsed = 0

connect(RunService.RenderStepped, function(deltaTime)
	frames += 1
	elapsed += deltaTime

	if elapsed >= 1 then
		local fps = math.floor(frames / elapsed)

		fpsLabel.Text = "FPS  " .. tostring(fps)

		frames = 0
		elapsed = 0
	end
end)

task.spawn(function()
	while gui.Parent do
		task.wait(1)

		local success, value = pcall(function()
			return Stats
				.Network
				.ServerStatsItem["Data Ping"]
				:GetValueString()
		end)

		if success then
			local ping = tostring(value):match("%d+")

			if ping then
				pingLabel.Text =
					"PING  " .. ping .. " ms"
			end
		end
	end
end)

--============================================================
-- ROLE ESP REFRESH
--============================================================

task.spawn(function()
	while gui.Parent do
		task.wait(2)

		if roleESPEnabled then
			updateRoleESP()
		end
	end
end)

--============================================================
-- PLAYER SETUP
--============================================================

local function setupPlayer(target)
	if target == player then
		return
	end

	connect(target.CharacterAdded, function()
		task.wait(0.5)

		if CONFIG.Nametags then
			createNametag(target)
		end

		if roleESPEnabled and target.Character then
			local role, color = getRole(target)

			createRoleESP(
				target,
				color,
				role
			)
		end
	end)

	if target.Character then
		task.defer(function()
			if CONFIG.Nametags then
				createNametag(target)
			end

			if roleESPEnabled then
				local role, color = getRole(target)

				createRoleESP(
					target,
					color,
					role
				)
			end
		end)
	end
end

for _, target in ipairs(Players:GetPlayers()) do
	setupPlayer(target)
end

connect(Players.PlayerAdded, setupPlayer)

connect(Players.PlayerRemoving, function(target)
	removeNametag(target)
	removeRoleESP(target)
end)

--============================================================
-- KEYBINDS
--============================================================

connect(UserInputService.InputBegan, function(input, processed)
	if processed then
		return
	end

	-- Main menu
	if input.KeyCode == CONFIG.MenuKey then
		if main.Visible then
			closeHub()
		else
			openHub()
		end
	end

	-- Main fly key
	if input.KeyCode == CONFIG.FlyKey then
		CONFIG.Fly = not CONFIG.Fly

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

	-- Role ESP controls
	if input.KeyCode == Enum.KeyCode.E then
		if roleESPGui then
			roleESPOn()
		end
	end

	-- F is already the main Fly key.
	-- Use the ESP OFF button to disable role ESP
	-- so the two systems don't conflict.
end)

--============================================================
-- OPEN / CLOSE MAIN HUB
--============================================================

openHub = function()
	reopen.Visible = false

	main.Visible = true

	main.Size = UDim2.fromOffset(0, 0)

	tween(
		main,
		TWEEN_BACK,
		{
			Size = UDim2.fromOffset(590, 485)
		}
	)
end

closeHub = function()
	local animation = tween(
		main,
		TWEEN_MED,
		{
			Size = UDim2.fromOffset(0, 0)
		}
	)

	animation.Completed:Once(function()
		main.Visible = false

		reopen.Visible = true
		reopen.Size = UDim2.fromOffset(0, 0)

		tween(
			reopen,
			TWEEN_BACK,
			{
				Size = UDim2.fromOffset(50, 50)
			}
		)
	end)
end

connect(close.MouseButton1Click, closeHub)
connect(reopen.MouseButton1Click, openHub)

--============================================================
-- RESPAWN HANDLING
--============================================================

connect(player.CharacterAdded, function(character)
	stopFly()

	local humanoid =
		character:WaitForChild("Humanoid")

	task.wait(0.15)

	if CONFIG.SpeedEnabled then
		humanoid.WalkSpeed =
			CONFIG.WalkSpeed
	end

	if CONFIG.JumpEnabled then
		humanoid.UseJumpPower = true
		humanoid.JumpPower =
			CONFIG.JumpPower
	end
end)

--============================================================
-- STARTUP OVERLAY
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

makeGradient(
	introText,
	COLORS.Accent,
	COLORS.Accent2,
	0
)

--============================================================
-- STARTUP SOUND
--============================================================

local startupSound = Instance.new("Sound")

startupSound.Name = "ShadowStartupSound"
startupSound.SoundId = "rbxassetid://1846869595"
startupSound.Volume = 0.85
startupSound.PlaybackSpeed = 1
startupSound.Parent = intro

--============================================================
-- GLITCH
--============================================================

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

task.spawn(function()
	while glitchRunning and introText.Parent do
		introText.Text = originalText
		introText.TextTransparency = 0

		task.wait(0.35)

		if not glitchRunning or not introText.Parent then
			break
		end

		for i = 1, 4 do
			introText.Text =
				glitchCharacters[
					math.random(
						1,
						#glitchCharacters
					)
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

		introText.Text = originalText
		introText.Position =
			UDim2.fromScale(0.5, 0.5)

		introText.TextTransparency = 0

		task.wait(0.6)
	end
end)

startupSound:Play()

--============================================================
-- STARTUP
--============================================================

task.delay(3, function()
	glitchRunning = false

	introText.Text = "SHADOW DEV HUB"
	introText.Position =
		UDim2.fromScale(0.5, 0.5)

	tween(
		introGlow,
		TWEEN_MED,
		{
			Size = UDim2.fromOffset(650, 650),
			BackgroundTransparency = 1
		}
	)

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

	tween(
		introText,
		TWEEN_MED,
		{
			TextTransparency = 1
		}
	)

	task.wait(0.25)

	tween(
		intro,
		TWEEN_MED,
		{
			BackgroundTransparency = 1
		}
	)

	task.wait(0.4)

	if startupSound then
		startupSound:Stop()
	end

	if intro then
		intro:Destroy()
	end

	openHub()
end)

--============================================================
-- MOVEMENT VALUE PROTECTION
-- Reapplies Speed + JumpPower every 0.1 seconds
--============================================================

task.spawn(function()
	while gui.Parent do
		task.wait(0.1)

		local character = player.Character
		local humanoid = character
			and character:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health > 0 then

			-- Keep WalkSpeed applied
			if CONFIG.SpeedEnabled then
				if humanoid.WalkSpeed ~= CONFIG.WalkSpeed then
					humanoid.WalkSpeed = CONFIG.WalkSpeed
				end
			end

			-- Keep JumpPower applied
			if CONFIG.JumpEnabled then
				humanoid.UseJumpPower = true

				if humanoid.JumpPower ~= CONFIG.JumpPower then
					humanoid.JumpPower = CONFIG.JumpPower
				end
			end

		end
	end
end)

--============================================================
-- CLEANUP
--============================================================

gui.Destroying:Connect(function()
	stopFly()
	stopAim()
	roleESPOff()

	if aimRenderConnection then
		aimRenderConnection:Disconnect()
		aimRenderConnection = nil
	end

	for target in pairs(nametags) do
		removeNametag(target)
	end

	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end
end)

print("[ShadowDevHub] Loaded successfully.")
