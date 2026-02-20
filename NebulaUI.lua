-- ============================================================
--   NebulaUI — Fixed & Enhanced Roblox UI Library
--   Fixes: ZIndex text layering, shadow clipping
--   New: Info tab, resizable window, minimized floating icon,
--        improved mobile support (always-visible toggle btn)
-- ============================================================

local NebulaUI = {}
NebulaUI.__index = NebulaUI

-- ============================================================
-- SERVICES
-- ============================================================
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

-- ============================================================
-- THEME
-- ============================================================
NebulaUI.Themes = {
    Nebula = {
        Background       = Color3.fromRGB(14, 14, 20),
        SecondaryBg      = Color3.fromRGB(20, 20, 30),
        TertiaryBg       = Color3.fromRGB(27, 27, 40),
        Accent           = Color3.fromRGB(130, 90, 255),
        AccentDark       = Color3.fromRGB(90, 60, 180),
        AccentHover      = Color3.fromRGB(150, 110, 255),
        Text             = Color3.fromRGB(240, 240, 245),
        SubText          = Color3.fromRGB(155, 155, 175),
        Muted            = Color3.fromRGB(80, 80, 100),
        Border           = Color3.fromRGB(38, 38, 55),
        Success          = Color3.fromRGB(60, 210, 120),
        Warning          = Color3.fromRGB(240, 180, 40),
        Error            = Color3.fromRGB(225, 65, 65),
        Info             = Color3.fromRGB(65, 165, 255),
        Toggle_On        = Color3.fromRGB(130, 90, 255),
        Toggle_Off       = Color3.fromRGB(50, 50, 68),
        Slider_Fill      = Color3.fromRGB(130, 90, 255),
        Slider_BG        = Color3.fromRGB(38, 38, 55),
        Sidebar          = Color3.fromRGB(17, 17, 25),
        SidebarActive    = Color3.fromRGB(130, 90, 255),
        SidebarInactive  = Color3.fromRGB(17, 17, 25),
        Font             = Enum.Font.Gotham,
        FontBold         = Enum.Font.GothamBold,
        FontSize         = 13,
        CornerRadius     = UDim.new(0, 9),
    },
    Ocean = {
        Background       = Color3.fromRGB(10, 18, 28),
        SecondaryBg      = Color3.fromRGB(14, 24, 38),
        TertiaryBg       = Color3.fromRGB(18, 30, 48),
        Accent           = Color3.fromRGB(40, 160, 255),
        AccentDark       = Color3.fromRGB(20, 110, 200),
        AccentHover      = Color3.fromRGB(70, 180, 255),
        Text             = Color3.fromRGB(230, 240, 255),
        SubText          = Color3.fromRGB(140, 160, 190),
        Muted            = Color3.fromRGB(60, 80, 110),
        Border           = Color3.fromRGB(28, 45, 68),
        Success          = Color3.fromRGB(50, 210, 130),
        Warning          = Color3.fromRGB(240, 180, 40),
        Error            = Color3.fromRGB(220, 65, 65),
        Info             = Color3.fromRGB(40, 160, 255),
        Toggle_On        = Color3.fromRGB(40, 160, 255),
        Toggle_Off       = Color3.fromRGB(30, 50, 75),
        Slider_Fill      = Color3.fromRGB(40, 160, 255),
        Slider_BG        = Color3.fromRGB(28, 45, 68),
        Sidebar          = Color3.fromRGB(10, 16, 26),
        SidebarActive    = Color3.fromRGB(40, 160, 255),
        SidebarInactive  = Color3.fromRGB(10, 16, 26),
        Font             = Enum.Font.Gotham,
        FontBold         = Enum.Font.GothamBold,
        FontSize         = 13,
        CornerRadius     = UDim.new(0, 9),
    },
    Crimson = {
        Background       = Color3.fromRGB(18, 12, 14),
        SecondaryBg      = Color3.fromRGB(26, 16, 20),
        TertiaryBg       = Color3.fromRGB(34, 20, 26),
        Accent           = Color3.fromRGB(220, 55, 85),
        AccentDark       = Color3.fromRGB(160, 35, 60),
        AccentHover      = Color3.fromRGB(240, 75, 105),
        Text             = Color3.fromRGB(245, 235, 238),
        SubText          = Color3.fromRGB(175, 150, 158),
        Muted            = Color3.fromRGB(90, 65, 72),
        Border           = Color3.fromRGB(50, 30, 38),
        Success          = Color3.fromRGB(55, 205, 115),
        Warning          = Color3.fromRGB(240, 180, 40),
        Error            = Color3.fromRGB(220, 55, 85),
        Info             = Color3.fromRGB(65, 165, 255),
        Toggle_On        = Color3.fromRGB(220, 55, 85),
        Toggle_Off       = Color3.fromRGB(55, 30, 38),
        Slider_Fill      = Color3.fromRGB(220, 55, 85),
        Slider_BG        = Color3.fromRGB(50, 30, 38),
        Sidebar          = Color3.fromRGB(15, 10, 12),
        SidebarActive    = Color3.fromRGB(220, 55, 85),
        SidebarInactive  = Color3.fromRGB(15, 10, 12),
        Font             = Enum.Font.Gotham,
        FontBold         = Enum.Font.GothamBold,
        FontSize         = 13,
        CornerRadius     = UDim.new(0, 9),
    },
}

-- ============================================================
-- ZIndex CONSTANTS  (Global ZIndexBehavior — all values absolute)
-- ============================================================
local Z = {
    Shadow       = 8,
    Window       = 10,
    TitleBar     = 11,    -- title text, key hint
    Sidebar      = 30,    -- sidebar must be above ALL content
    SidebarChild = 31,
    Tooltip      = 40,
    Content      = 12,    -- content scroll frame
    ContentItem  = 13,    -- element background frames
    ContentText  = 14,    -- text labels inside elements
    ContentCtrl  = 15,    -- controls (switches, sliders)
    ContentKnob  = 16,    -- slider thumbs / toggle knobs
    ContentHit   = 17,    -- invisible hitbox buttons
    Dropdown     = 45,    -- dropdowns must float above everything
    DropdownItem = 46,
    ColorPanel   = 45,
    MobileBtn    = 35,
    MinimizeIcon = 36,
    Notification = 50,
    Intro        = 100,
}

-- ============================================================
-- UTILITIES
-- ============================================================
local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    for _, child in pairs(children or {}) do child.Parent = obj end
    return obj
end

local function Corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0, 9)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(40, 40, 55)
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function Padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 6)
    p.PaddingBottom = UDim.new(0, bottom or 6)
    p.PaddingLeft   = UDim.new(0, left   or 10)
    p.PaddingRight  = UDim.new(0, right  or 10)
    p.Parent = parent
    return p
end

local function ListLayout(parent, padding, align, halign)
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, padding or 6)
    if align  then l.VerticalAlignment   = align  end
    if halign then l.HorizontalAlignment = halign end
    l.Parent = parent
    return l
end

local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

-- ============================================================
-- DRAGGABLE UTILITY  (works for both window and icon)
-- ============================================================
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            local guiObjs = {}
            pcall(function()
                guiObjs = game:GetService("GuiService"):GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
            end)
            for _, obj in ipairs(guiObjs) do
                if obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("ImageButton") then
                    return
                end
            end
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- ============================================================
-- RESIZE UTILITY
-- ============================================================
local function MakeResizable(window, minW, minH, onResize)
    minW = minW or 340
    minH = minH or 280

    local handle = Create("TextButton", {
        Name = "ResizeHandle",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1,
        Text = "⟱",
        TextColor3 = Color3.fromRGB(80, 80, 100),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = Z.ContentHit,
        Parent = window,
    })

    local resizing = false
    local resizeStart, startSize, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing   = true
            resizeStart = input.Position
            startSize  = window.AbsoluteSize
            startPos   = window.AbsolutePosition
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newW = math.max(minW, startSize.X + delta.X)
            local newH = math.max(minH, startSize.Y + delta.Y)
            window.Size = UDim2.new(0, newW, 0, newH)
            if onResize then onResize(newW, newH) end
        end
    end)

    return handle
end

-- ============================================================
-- CONFIG SYSTEM
-- ============================================================
local ConfigSystem = {}
ConfigSystem.__index = ConfigSystem

function ConfigSystem.new(scriptName)
    local self = setmetatable({}, ConfigSystem)
    self.ScriptName = scriptName or "NebulaUI"
    self.Folder = "NebulaConfigs/" .. self.ScriptName
    self.Elements = {}
    if not isfolder then return self end
    if not isfolder("NebulaConfigs") then makefolder("NebulaConfigs") end
    if not isfolder(self.Folder)     then makefolder(self.Folder)     end
    return self
end

function ConfigSystem:Register(key, element) self.Elements[key] = element end

function ConfigSystem:Save(configName)
    if not writefile then return end
    configName = configName or "default"
    local data = {}
    for key, element in pairs(self.Elements) do
        if element.Get then
            local val = element:Get()
            if type(val) == "boolean" or type(val) == "number" or type(val) == "string" then
                data[key] = val
            elseif typeof(val) == "EnumItem" then
                data[key] = tostring(val)
            end
        end
    end
    writefile(self.Folder .. "/" .. configName .. ".json",
        game:GetService("HttpService"):JSONEncode(data))
end

function ConfigSystem:Load(configName)
    if not readfile then return end
    configName = configName or "default"
    local path = self.Folder .. "/" .. configName .. ".json"
    if not isfile(path) then return end
    local ok, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(path))
    end)
    if not ok then return end
    for key, val in pairs(data) do
        local element = self.Elements[key]
        if element and element.Set then
            if type(val) == "string" and val:find("Enum.") then
                local enumVal = pcall(function() return Enum.KeyCode[val:match("%.(%w+)$")] end)
                if enumVal then element:Set(enumVal) end
            else
                element:Set(val)
            end
        end
    end
end

function ConfigSystem:ListConfigs()
    if not listfiles then return {} end
    local files = listfiles(self.Folder)
    local names = {}
    for _, f in pairs(files) do
        local name = f:match("([^/\\]+)%.json$")
        if name then table.insert(names, name) end
    end
    return names
end

function ConfigSystem:Delete(configName)
    if not delfile then return end
    local path = self.Folder .. "/" .. configName .. ".json"
    if isfile(path) then delfile(path) end
end

-- ============================================================
-- INTRO ANIMATION
-- ============================================================
local function PlayIntro(screenGui, config, theme, onFinish)
    local title    = config.Title    or "Script"
    local subtitle = config.Subtitle or "Loading..."
    local logo     = config.LogoId   or nil
    local duration = config.Duration or 3.5

    local overlay = Create("Frame", {
        Name             = "Intro",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(8, 8, 12),
        ZIndex           = Z.Intro,
        Parent           = screenGui,
    })
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(8,  8,  14)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 12, 30)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(8,  8,  14)),
    })
    grad.Rotation = 135
    grad.Parent   = overlay

    local center = Create("Frame", {
        Size                = UDim2.new(0, 320, 0, 200),
        Position            = UDim2.new(0.5, -160, 0.5, -100),
        BackgroundTransparency = 1,
        ZIndex              = Z.Intro + 1,
        Parent              = overlay,
    })

    if logo then
        local logoImg = Create("ImageLabel", {
            Size               = UDim2.new(0, 64, 0, 64),
            Position           = UDim2.new(0.5, -32, 0, 0),
            BackgroundTransparency = 1,
            Image              = "rbxassetid://" .. tostring(logo),
            ImageColor3        = theme.Accent,
            ImageTransparency  = 1,
            ZIndex             = Z.Intro + 1,
            Parent             = center,
        })
        Tween(logoImg, {ImageTransparency = 0}, 0.6)
    end

    local titleLabel = Create("TextLabel", {
        Size               = UDim2.new(1, 0, 0, 48),
        Position           = UDim2.new(0, 0, 0, logo and 72 or 30),
        BackgroundTransparency = 1,
        Text               = title,
        TextColor3         = theme.Text,
        TextSize           = 28,
        Font               = theme.FontBold,
        TextTransparency   = 1,
        ZIndex             = Z.Intro + 1,
        Parent             = center,
    })

    local subLabel = Create("TextLabel", {
        Size               = UDim2.new(1, 0, 0, 24),
        Position           = UDim2.new(0, 0, 0, logo and 124 or 82),
        BackgroundTransparency = 1,
        Text               = subtitle,
        TextColor3         = theme.SubText,
        TextSize           = 14,
        Font               = theme.Font,
        TextTransparency   = 1,
        ZIndex             = Z.Intro + 1,
        Parent             = center,
    })

    local barBG = Create("Frame", {
        Size             = UDim2.new(0, 240, 0, 3),
        Position         = UDim2.new(0.5, -120, 1, -30),
        BackgroundColor3 = theme.Border,
        BorderSizePixel  = 0,
        BackgroundTransparency = 1,
        ZIndex           = Z.Intro + 1,
        Parent           = overlay,
    })
    Corner(barBG, UDim.new(1, 0))

    local barFill = Create("Frame", {
        Size            = UDim2.new(0, 0, 1, 0),
        BackgroundColor3= theme.Accent,
        BorderSizePixel = 0,
        ZIndex          = Z.Intro + 1,
        Parent          = barBG,
    })
    Corner(barFill, UDim.new(1, 0))

    task.spawn(function()
        task.wait(0.2)
        Tween(titleLabel, {TextTransparency = 0}, 0.5)
        task.wait(0.2)
        Tween(subLabel,   {TextTransparency = 0}, 0.4)
        task.wait(0.1)
        Tween(barBG,      {BackgroundTransparency = 0}, 0.3)
        task.wait(0.2)
        Tween(barFill, {Size = UDim2.new(1, 0, 1, 0)}, duration - 1.2)
        task.wait(duration - 1.2)
        Tween(overlay,    {BackgroundTransparency = 1}, 0.5)
        Tween(titleLabel, {TextTransparency = 1}, 0.4)
        Tween(subLabel,   {TextTransparency = 1}, 0.4)
        Tween(barBG,      {BackgroundTransparency = 1}, 0.4)
        task.wait(0.5)
        overlay:Destroy()
        onFinish()
    end)
end

-- ============================================================
-- MAIN LIBRARY INIT
-- ============================================================
function NebulaUI.new(config)
    local self = setmetatable({}, NebulaUI)
    config = config or {}
    local themeName = config.Theme or "Nebula"
    self.Theme   = type(config.Theme) == "table" and config.Theme
                   or (NebulaUI.Themes[themeName] or NebulaUI.Themes.Nebula)
    self.Config  = ConfigSystem.new(config.Title or "NebulaScript")
    self.Windows = {}
    self._notifQueue = {}
    self._totalExecutions = 0
    self._sessionStart    = os.time()

    -- ScreenGui — Global ZIndexBehavior so ZIndex values are absolute
    self.ScreenGui = Create("ScreenGui", {
        Name            = config.Title or "NebulaUI",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Global,  -- FIX: Global so ZIndex is absolute
        IgnoreGuiInset  = true,
    })

    pcall(function() self.ScreenGui.Parent = game:GetService("CoreGui") end)
    if not self.ScreenGui.Parent or self.ScreenGui.Parent ~= game:GetService("CoreGui") then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Notification container
    self._notifHolder = Create("Frame", {
        Name                = "Notifications",
        BackgroundTransparency = 1,
        Size                = UDim2.new(0, 300, 1, 0),
        Position            = UDim2.new(1, -310, 0, 0),
        ZIndex              = Z.Notification,
        Parent              = self.ScreenGui,
    })
    ListLayout(self._notifHolder, 8, Enum.VerticalAlignment.Bottom)
    Padding(self._notifHolder, 8, 8, 0, 0)

    return self
end

-- ============================================================
-- NOTIFICATION
-- ============================================================
function NebulaUI:Notify(config)
    local theme   = self.Theme
    config        = config or {}
    local title   = config.Title    or "Notification"
    local message = config.Message  or ""
    local duration= config.Duration or 4
    local ntype   = config.Type     or "Info"

    local typeColor = {
        Info = theme.Info, Success = theme.Success,
        Warning = theme.Warning, Error = theme.Error,
    }
    local color = typeColor[ntype] or theme.Info

    local notif = Create("Frame", {
        Name             = "Notif",
        Size             = UDim2.new(1, 0, 0, 74),
        BackgroundColor3 = theme.SecondaryBg,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex           = Z.Notification,
        Parent           = self._notifHolder,
    })
    Corner(notif, UDim.new(0, 9))
    Stroke(notif, color, 1)

    Create("Frame", {
        Size            = UDim2.new(0, 3, 0.7, 0),
        Position        = UDim2.new(0, 0, 0.15, 0),
        BackgroundColor3= color,
        BorderSizePixel = 0,
        ZIndex          = Z.Notification + 1,
        Parent          = notif,
    })

    local icons = { Info="ℹ", Success="✓", Warning="⚠", Error="✕" }
    Create("TextLabel", {
        Size               = UDim2.new(0, 28, 0, 28),
        Position           = UDim2.new(0, 10, 0.5, -14),
        BackgroundTransparency = 1,
        Text               = icons[ntype] or "ℹ",
        TextColor3         = color,
        TextSize           = 16,
        Font               = theme.FontBold,
        ZIndex             = Z.Notification + 1,
        Parent             = notif,
    })
    Create("TextLabel", {
        Size               = UDim2.new(1, -50, 0, 20),
        Position           = UDim2.new(0, 44, 0, 12),
        BackgroundTransparency = 1,
        Text               = title,
        TextColor3         = theme.Text,
        TextSize           = 13,
        Font               = theme.FontBold,
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = Z.Notification + 1,
        Parent             = notif,
    })
    Create("TextLabel", {
        Size               = UDim2.new(1, -50, 0, 28),
        Position           = UDim2.new(0, 44, 0, 34),
        BackgroundTransparency = 1,
        Text               = message,
        TextColor3         = theme.SubText,
        TextSize           = 11,
        Font               = theme.Font,
        TextXAlignment     = Enum.TextXAlignment.Left,
        TextWrapped        = true,
        ZIndex             = Z.Notification + 1,
        Parent             = notif,
    })

    local progBG = Create("Frame", {
        Size            = UDim2.new(1, -44, 0, 2),
        Position        = UDim2.new(0, 44, 1, -6),
        BackgroundColor3= theme.Border,
        BorderSizePixel = 0,
        ZIndex          = Z.Notification + 1,
        Parent          = notif,
    })
    Corner(progBG, UDim.new(1, 0))
    local progFill = Create("Frame", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundColor3= color,
        BorderSizePixel = 0,
        ZIndex          = Z.Notification + 2,
        Parent          = progBG,
    })
    Corner(progFill, UDim.new(1, 0))

    Tween(notif,    {BackgroundTransparency = 0}, 0.3)
    Tween(progFill, {Size = UDim2.new(0, 0, 1, 0)}, duration)

    task.delay(duration, function()
        Tween(notif, {BackgroundTransparency = 1}, 0.3)
        Tween(notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.35)
        notif:Destroy()
    end)
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
function NebulaUI:CreateWindow(config)
    config = config or {}
    local theme      = self.Theme
    local title      = config.Title     or "NebulaUI"
    local subtitle   = config.Subtitle  or ""
    local intro      = config.Intro     ~= false
    local toggleKey  = config.ToggleKey or Enum.KeyCode.RightControl
    local showMobile = config.MobileButton ~= false

    local WIN_W    = IsMobile() and 380 or 560
    local WIN_H    = IsMobile() and 340 or 420
    local SIDEBAR_W= IsMobile() and 52  or 48
    local MIN_W    = 340
    local MIN_H    = 280

    -- ── Drop shadow (sibling of window — NOT a child — so it isn't clipped)
    local shadow = Create("ImageLabel", {
        Name               = "Shadow",
        Size               = UDim2.new(0, WIN_W + 40, 0, WIN_H + 40),
        BackgroundTransparency = 1,
        Image              = "rbxassetid://5554236805",
        ImageColor3        = Color3.fromRGB(0, 0, 0),
        ImageTransparency  = 0.55,
        ScaleType          = Enum.ScaleType.Slice,
        SliceCenter        = Rect.new(23, 23, 277, 277),
        ZIndex             = Z.Shadow,
        Parent             = self.ScreenGui,
    })

    -- ── Main window (ClipsDescendants FALSE — use inner frame to clip content)
    local window = Create("Frame", {
        Name             = "Window",
        Size             = UDim2.new(0, WIN_W, 0, WIN_H),
        Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
        BackgroundColor3 = theme.Background,
        BorderSizePixel  = 0,
        Visible          = false,
        ClipsDescendants = false,      -- FIX: allow shadow sibling to show
        ZIndex           = Z.Window,
        Parent           = self.ScreenGui,
    })
    Corner(window, theme.CornerRadius)
    Stroke(window, theme.Border, 1)

    -- Keep shadow aligned to window position/size
    RunService.RenderStepped:Connect(function()
        if not window or not window.Parent then return end
        local ap = window.AbsolutePosition
        local as = window.AbsoluteSize
        shadow.Position = UDim2.new(0, ap.X - 20, 0, ap.Y - 20)
        shadow.Size     = UDim2.new(0, as.X + 40, 0, as.Y + 40)
        shadow.Visible  = window.Visible
    end)

    -- ── SIDEBAR  (high ZIndex so it always layers above content)
    local sidebar = Create("Frame", {
        Name            = "Sidebar",
        Size            = UDim2.new(0, SIDEBAR_W, 1, 0),
        BackgroundColor3= theme.Sidebar,
        BorderSizePixel = 0,
        ClipsDescendants= false,
        ZIndex          = Z.Sidebar,
        Parent          = window,
    })
    Corner(sidebar, theme.CornerRadius)
    -- Cover right rounded corners of sidebar
    Create("Frame", {
        Size            = UDim2.new(0, theme.CornerRadius.Offset, 1, 0),
        Position        = UDim2.new(1, -theme.CornerRadius.Offset, 0, 0),
        BackgroundColor3= theme.Sidebar,
        BorderSizePixel = 0,
        ZIndex          = Z.Sidebar,
        Parent          = sidebar,
    })

    -- Logo / title area at top of sidebar
    local sideTop = Create("Frame", {
        Size               = UDim2.new(1, 0, 0, 58),
        BackgroundTransparency = 1,
        ZIndex             = Z.SidebarChild,
        Parent             = sidebar,
    })
    Create("TextLabel", {
        Size               = UDim2.new(1, -4, 0, 22),
        Position           = UDim2.new(0, 2, 0, 12),
        BackgroundTransparency = 1,
        Text               = title:sub(1,2):upper(),
        TextColor3         = theme.Accent,
        TextSize           = 18,
        Font               = theme.FontBold,
        ZIndex             = Z.SidebarChild,
        Parent             = sideTop,
    })
    Create("Frame", {
        Size            = UDim2.new(0.7, 0, 0, 1),
        Position        = UDim2.new(0.15, 0, 0, 54),
        BackgroundColor3= theme.Border,
        BorderSizePixel = 0,
        ZIndex          = Z.SidebarChild,
        Parent          = sidebar,
    })

    -- Tab icon container
    local tabIconContainer = Create("Frame", {
        Name               = "TabIcons",
        Size               = UDim2.new(1, 0, 1, -68),
        Position           = UDim2.new(0, 0, 0, 62),
        BackgroundTransparency = 1,
        ClipsDescendants   = false,
        ZIndex             = Z.SidebarChild,
        Parent             = sidebar,
    })
    ListLayout(tabIconContainer, 4, nil, Enum.HorizontalAlignment.Center)
    Padding(tabIconContainer, 4, 4, 0, 0)

    -- Minimize / close buttons at sidebar bottom
    local sideBottom = Create("Frame", {
        Size               = UDim2.new(1, 0, 0, 64),
        Position           = UDim2.new(0, 0, 1, -64),
        BackgroundTransparency = 1,
        ZIndex             = Z.SidebarChild,
        Parent             = sidebar,
    })

    local function SideBtn(icon, yOff, callback)
        local btn = Create("TextButton", {
            Size            = UDim2.new(0, 32, 0, 28),
            Position        = UDim2.new(0.5, -16, 0, yOff),
            BackgroundColor3= theme.TertiaryBg,
            Text            = icon,
            TextColor3      = theme.SubText,
            TextSize        = 14,
            Font            = theme.FontBold,
            BorderSizePixel = 0,
            ZIndex          = Z.SidebarChild,
            Parent          = sideBottom,
        })
        Corner(btn, UDim.new(0, 6))
        btn.MouseButton1Click:Connect(callback)
        btn.MouseEnter:Connect(function() Tween(btn, {TextColor3 = theme.Text}, 0.15) end)
        btn.MouseLeave:Connect(function() Tween(btn, {TextColor3 = theme.SubText}, 0.15) end)
        return btn
    end

    -- ── MINIMIZE FLOATING ICON (shown when minimized instead of shrinking)
    local minimizeIcon = Create("TextButton", {
        Name            = "MinimizeIcon",
        Size            = UDim2.new(0, 52, 0, 52),
        Position        = UDim2.new(0, 16, 0.5, -26),
        BackgroundColor3= theme.Accent,
        Text            = title:sub(1,2):upper(),
        TextColor3      = Color3.fromRGB(255,255,255),
        TextSize        = 16,
        Font            = theme.FontBold,
        BorderSizePixel = 0,
        Visible         = false,
        ZIndex          = Z.MinimizeIcon,
        Parent          = self.ScreenGui,
    })
    Corner(minimizeIcon, UDim.new(1, 0))
    Stroke(minimizeIcon, theme.AccentDark, 2)
    -- Pulsing accent border
    local function PulseIcon()
        task.spawn(function()
            while minimizeIcon.Visible do
                Tween(minimizeIcon, {BackgroundColor3 = theme.AccentHover}, 0.8)
                task.wait(0.8)
                Tween(minimizeIcon, {BackgroundColor3 = theme.Accent}, 0.8)
                task.wait(0.8)
            end
        end)
    end
    MakeDraggable(minimizeIcon)

    local minimized = false

    SideBtn("−", 4, function()
        minimized = true
        -- Hide window, show floating icon
        Tween(window, {Size = UDim2.new(0, WIN_W, 0, 0), BackgroundTransparency = 1}, 0.25,
            Enum.EasingStyle.Quart)
        task.wait(0.28)
        window.Visible = false
        Tween(window, {BackgroundTransparency = 0}, 0)
        minimizeIcon.Visible = true
        PulseIcon()
    end)

    minimizeIcon.MouseButton1Click:Connect(function()
        minimized = false
        minimizeIcon.Visible = false
        window.Visible = true
        window.Size = UDim2.new(0, WIN_W, 0, 0)
        Tween(window, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.3, Enum.EasingStyle.Quart)
    end)

    SideBtn("✕", 34, function()
        minimizeIcon.Visible = false
        Tween(window, {Size = UDim2.new(0, WIN_W, 0, 0), BackgroundTransparency = 1}, 0.25)
        task.wait(0.3)
        window.Visible = false
        Tween(window, {BackgroundTransparency = 0}, 0)
    end)

    -- ── TITLEBAR
    local titleBar = Create("Frame", {
        Name            = "TitleBar",
        Size            = UDim2.new(1, -SIDEBAR_W, 0, 48),
        Position        = UDim2.new(0, SIDEBAR_W, 0, 0),
        BackgroundColor3= theme.SecondaryBg,
        BorderSizePixel = 0,
        ZIndex          = Z.TitleBar,
        Parent          = window,
    })
    -- Clip corners on the top side
    Create("TextLabel", {
        Size               = UDim2.new(0.6, 0, 1, 0),
        Position           = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text               = title .. (subtitle ~= "" and ("  ·  " .. subtitle) or ""),
        TextColor3         = theme.Text,
        TextSize           = 14,
        Font               = theme.FontBold,
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = Z.TitleBar + 1,
        Parent             = titleBar,
    })
    Create("TextLabel", {
        Size               = UDim2.new(0, 130, 0, 20),
        Position           = UDim2.new(1, -140, 0.5, -10),
        BackgroundTransparency = 1,
        Text               = "[" .. tostring(toggleKey.Name) .. "] to toggle",
        TextColor3         = theme.Muted,
        TextSize           = 11,
        Font               = theme.Font,
        TextXAlignment     = Enum.TextXAlignment.Right,
        ZIndex             = Z.TitleBar + 1,
        Parent             = titleBar,
    })
    Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 1),
        Position        = UDim2.new(0, 0, 1, -1),
        BackgroundColor3= theme.Border,
        BorderSizePixel = 0,
        ZIndex          = Z.TitleBar,
        Parent          = titleBar,
    })

    MakeDraggable(window, titleBar)

    -- ── CONTENT AREA  (clips its children so nothing bleeds into sidebar)
    local contentHolder = Create("Frame", {
        Name               = "ContentHolder",
        Size               = UDim2.new(1, -SIDEBAR_W, 1, -48),
        Position           = UDim2.new(0, SIDEBAR_W, 0, 48),
        BackgroundTransparency = 1,
        ClipsDescendants   = true,   -- clip content to its bounds
        ZIndex             = Z.Content,
        Parent             = window,
    })

    -- ── RESIZE HANDLE
    local resizeHandle = MakeResizable(window, MIN_W, MIN_H, function(newW, newH)
        WIN_W = newW
        WIN_H = newH
        titleBar.Size        = UDim2.new(1, -SIDEBAR_W, 0, 48)
        contentHolder.Size   = UDim2.new(1, -SIDEBAR_W, 1, -48)
    end)
    resizeHandle.ZIndex = Z.ContentHit

    -- ── KEYBOARD TOGGLE
    local visible = false
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            if minimized then
                -- Restore from minimized
                minimized = false
                minimizeIcon.Visible = false
                visible = true
                window.Visible = true
                window.Size = UDim2.new(0, WIN_W, 0, 0)
                Tween(window, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.3, Enum.EasingStyle.Quart)
            else
                visible = not visible
                window.Visible = visible
                if visible then
                    window.Size = UDim2.new(0, WIN_W, 0, 0)
                    Tween(window, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.3, Enum.EasingStyle.Quart)
                end
            end
        end
    end)

    -- ── MOBILE TOGGLE BUTTON  (always visible when MobileButton = true)
    if showMobile then
        local mobileBtn = Create("TextButton", {
            Name            = "MobileToggle",
            Size            = UDim2.new(0, 52, 0, 52),
            Position        = IsMobile() and UDim2.new(0, 10, 0.5, -26)
                                          or UDim2.new(0, 10, 1, -62),
            BackgroundColor3= theme.Accent,
            Text            = "☰",
            TextColor3      = Color3.fromRGB(255,255,255),
            TextSize        = 22,
            Font            = theme.FontBold,
            BorderSizePixel = 0,
            ZIndex          = Z.MobileBtn,
            Parent          = self.ScreenGui,
        })
        Corner(mobileBtn, UDim.new(1, 0))
        MakeDraggable(mobileBtn)

        mobileBtn.MouseButton1Click:Connect(function()
            if minimized then
                minimized = false
                minimizeIcon.Visible = false
                visible = true
                window.Visible = true
                window.Size = UDim2.new(0, WIN_W, 0, 0)
                Tween(window, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.3, Enum.EasingStyle.Quart)
            else
                visible = not visible
                window.Visible = visible
                if visible then
                    window.Size = UDim2.new(0, WIN_W, 0, 0)
                    Tween(window, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.3, Enum.EasingStyle.Quart)
                end
            end
        end)
    end

    -- ── WINDOW OBJECT
    local windowObj = {
        Frame         = window,
        Sidebar       = sidebar,
        TabIcons      = tabIconContainer,
        ContentHolder = contentHolder,
        Theme         = theme,
        Tabs          = {},
        ActiveTab     = nil,
        Config        = self.Config,
        Library       = self,
        _visible      = false,
    }

    -- Show window (after intro if enabled)
    local function ShowWindow()
        window.Visible = true
        visible        = true
        windowObj._visible = true
        window.Size = UDim2.new(0, WIN_W, 0, 0)
        Tween(window, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.35, Enum.EasingStyle.Quart)
    end

    if intro then
        PlayIntro(self.ScreenGui, config, theme, ShowWindow)
    else
        ShowWindow()
    end

    -- ── CREATE TAB
    function windowObj:CreateTab(tabConfig)
        tabConfig  = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or "◆"

        -- Sidebar icon button
        local iconBtn = Create("TextButton", {
            Name            = tabName,
            Size            = UDim2.new(0, 36, 0, 36),
            BackgroundColor3= theme.SidebarInactive,
            Text            = tabIcon,
            TextColor3      = theme.SubText,
            TextSize        = IsMobile() and 16 or 14,
            Font            = theme.Font,
            BorderSizePixel = 0,
            ZIndex          = Z.SidebarChild,
            Parent          = tabIconContainer,
        })
        Corner(iconBtn, UDim.new(0, 8))

        -- Tooltip
        local tooltip = Create("TextLabel", {
            Size               = UDim2.new(0, 0, 0, 24),
            Position           = UDim2.new(1, 6, 0.5, -12),
            BackgroundColor3   = theme.TertiaryBg,
            Text               = " " .. tabName .. " ",
            TextColor3         = theme.Text,
            TextSize           = 11,
            Font               = theme.Font,
            AutomaticSize      = Enum.AutomaticSize.X,
            Visible            = false,
            ZIndex             = Z.Tooltip,
            Parent             = iconBtn,
        })
        Corner(tooltip, UDim.new(0, 5))
        Stroke(tooltip, theme.Border, 1)

        iconBtn.MouseEnter:Connect(function() tooltip.Visible = true  end)
        iconBtn.MouseLeave:Connect(function() tooltip.Visible = false end)

        -- Active indicator
        local indicator = Create("Frame", {
            Size            = UDim2.new(0, 3, 0, 18),
            Position        = UDim2.new(0, -3, 0.5, -9),
            BackgroundColor3= theme.Accent,
            BorderSizePixel = 0,
            Visible         = false,
            ZIndex          = Z.SidebarChild,
            Parent          = iconBtn,
        })
        Corner(indicator, UDim.new(1, 0))

        -- Content scroll frame
        local content = Create("ScrollingFrame", {
            Name                   = tabName .. "_Content",
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            ScrollBarThickness     = 3,
            ScrollBarImageColor3   = theme.Accent,
            ScrollBarImageTransparency = 0.4,
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            Visible                = false,
            ZIndex                 = Z.Content,
            Parent                 = contentHolder,
        })
        local cLayout = ListLayout(content, 6)
        Padding(content, 10, 10, 12, 12)

        cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, cLayout.AbsoluteContentSize.Y + 20)
        end)

        local tabObj = {
            Button    = iconBtn,
            Indicator = indicator,
            Content   = content,
            Theme     = theme,
            Window    = windowObj,
            Config    = self.Config,
            _id       = tabName,
        }

        iconBtn.MouseButton1Click:Connect(function()
            windowObj:_SelectTab(tabObj)
        end)

        table.insert(windowObj.Tabs, tabObj)
        if #windowObj.Tabs == 1 then windowObj:_SelectTab(tabObj) end

        -- ================================================
        -- ELEMENT BUILDERS
        -- ================================================

        -- SECTION
        function tabObj:CreateSection(cfg)
            cfg = cfg or {}
            local name = type(cfg) == "string" and cfg or (cfg.Name or "Section")
            local sec = Create("Frame", {
                Size               = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                ZIndex             = Z.ContentItem,
                Parent             = content,
            })
            Create("TextLabel", {
                Size               = UDim2.new(0.5, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = string.upper(name),
                TextColor3         = theme.Accent,
                TextSize           = 10,
                Font               = theme.FontBold,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = Z.ContentText,
                Parent             = sec,
            })
            Create("Frame", {
                Size            = UDim2.new(0.48, 0, 0, 1),
                Position        = UDim2.new(0.52, 0, 0.5, 0),
                BackgroundColor3= theme.Border,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentItem,
                Parent          = sec,
            })
        end

        -- BUTTON
        function tabObj:CreateButton(cfg)
            cfg = cfg or {}
            local name     = cfg.Name        or "Button"
            local desc     = cfg.Description or ""
            local callback = cfg.Callback    or function() end

            local h = desc ~= "" and 54 or 38
            local frame = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, h),
                BackgroundColor3= theme.SecondaryBg,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentItem,
                Parent          = content,
            })
            Corner(frame, theme.CornerRadius)
            Stroke(frame, theme.Border, 1)
            Padding(frame, 0, 0, 14, 14)

            Create("TextLabel", {
                Size               = UDim2.new(1, -90, 0, 20),
                Position           = UDim2.new(0, 0, 0, desc ~= "" and 8 or 9),
                BackgroundTransparency = 1,
                Text               = name,
                TextColor3         = theme.Text,
                TextSize           = theme.FontSize,
                Font               = theme.Font,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = Z.ContentText,
                Parent             = frame,
            })
            if desc ~= "" then
                Create("TextLabel", {
                    Size               = UDim2.new(1, -90, 0, 16),
                    Position           = UDim2.new(0, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Text               = desc,
                    TextColor3         = theme.SubText,
                    TextSize           = 11,
                    Font               = theme.Font,
                    TextXAlignment     = Enum.TextXAlignment.Left,
                    ZIndex             = Z.ContentText,
                    Parent             = frame,
                })
            end

            local btn = Create("TextButton", {
                Size            = UDim2.new(0, 76, 0, 28),
                Position        = UDim2.new(1, -76, 0.5, -14),
                BackgroundColor3= theme.Accent,
                Text            = "Execute",
                TextColor3      = Color3.fromRGB(255,255,255),
                TextSize        = 11,
                Font            = theme.FontBold,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentCtrl,
                Parent          = frame,
            })
            Corner(btn, UDim.new(0, 7))
            btn.MouseEnter:Connect(function()   Tween(btn,{BackgroundColor3=theme.AccentHover},0.15) end)
            btn.MouseLeave:Connect(function()   Tween(btn,{BackgroundColor3=theme.Accent},0.15)     end)
            btn.MouseButton1Click:Connect(function()
                self.Library._totalExecutions = self.Library._totalExecutions + 1
                Tween(btn,{BackgroundColor3=theme.AccentDark},0.08)
                task.wait(0.08)
                Tween(btn,{BackgroundColor3=theme.Accent},0.15)
                task.spawn(callback)
            end)
        end

        -- TOGGLE
        function tabObj:CreateToggle(cfg)
            cfg = cfg or {}
            local name      = cfg.Name        or "Toggle"
            local desc      = cfg.Description or ""
            local default   = cfg.Default     or false
            local configKey = cfg.ConfigKey
            local callback  = cfg.Callback    or function() end
            local state     = default
            local h = desc ~= "" and 54 or 38

            local frame = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, h),
                BackgroundColor3= theme.SecondaryBg,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentItem,
                Parent          = content,
            })
            Corner(frame, theme.CornerRadius)
            Stroke(frame, theme.Border, 1)
            Padding(frame, 0, 0, 14, 14)

            Create("TextLabel", {
                Size               = UDim2.new(1, -60, 0, 20),
                Position           = UDim2.new(0, 0, 0, desc ~= "" and 8 or 9),
                BackgroundTransparency = 1,
                Text               = name,
                TextColor3         = theme.Text,
                TextSize           = theme.FontSize,
                Font               = theme.Font,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = Z.ContentText,
                Parent             = frame,
            })
            if desc ~= "" then
                Create("TextLabel", {
                    Size               = UDim2.new(1, -60, 0, 16),
                    Position           = UDim2.new(0, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Text               = desc,
                    TextColor3         = theme.SubText,
                    TextSize           = 11,
                    Font               = theme.Font,
                    TextXAlignment     = Enum.TextXAlignment.Left,
                    ZIndex             = Z.ContentText,
                    Parent             = frame,
                })
            end

            local switchBG = Create("Frame", {
                Size            = UDim2.new(0, 44, 0, 24),
                Position        = UDim2.new(1, -44, 0.5, -12),
                BackgroundColor3= state and theme.Toggle_On or theme.Toggle_Off,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentCtrl,
                Parent          = frame,
            })
            Corner(switchBG, UDim.new(1, 0))

            local knob = Create("Frame", {
                Size            = UDim2.new(0, 18, 0, 18),
                Position        = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
                BackgroundColor3= Color3.fromRGB(255,255,255),
                BorderSizePixel = 0,
                ZIndex          = Z.ContentKnob,
                Parent          = switchBG,
            })
            Corner(knob, UDim.new(1, 0))

            -- Full-frame hitbox so tap anywhere on the row toggles it
            local hitbox = Create("TextButton", {
                Size               = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = "",
                ZIndex             = Z.ContentHit,
                Parent             = frame,
            })

            local obj = {}
            local function Refresh()
                Tween(switchBG, {BackgroundColor3 = state and theme.Toggle_On or theme.Toggle_Off}, 0.2)
                Tween(knob, {Position = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}, 0.2)
            end
            Refresh()

            hitbox.MouseButton1Click:Connect(function()
                state = not state
                Refresh()
                task.spawn(callback, state)
            end)

            function obj:Set(v) state = v Refresh() task.spawn(callback, state) end
            function obj:Get() return state end

            if configKey then self.Config:Register(configKey, obj) end
            return obj
        end

        -- SLIDER
        function tabObj:CreateSlider(cfg)
            cfg = cfg or {}
            local name      = cfg.Name     or "Slider"
            local min       = cfg.Min      or 0
            local max       = cfg.Max      or 100
            local default   = cfg.Default  or min
            local suffix    = cfg.Suffix   or ""
            local decimals  = cfg.Decimals or 0
            local configKey = cfg.ConfigKey
            local callback  = cfg.Callback or function() end
            local value     = math.clamp(default, min, max)

            local frame = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 54),
                BackgroundColor3= theme.SecondaryBg,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentItem,
                Parent          = content,
            })
            Corner(frame, theme.CornerRadius)
            Stroke(frame, theme.Border, 1)
            Padding(frame, 0, 0, 14, 14)

            Create("TextLabel", {
                Size               = UDim2.new(0.6, 0, 0, 20),
                Position           = UDim2.new(0, 0, 0, 8),
                BackgroundTransparency = 1,
                Text               = name,
                TextColor3         = theme.Text,
                TextSize           = theme.FontSize,
                Font               = theme.Font,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = Z.ContentText,
                Parent             = frame,
            })

            local valLabel = Create("TextLabel", {
                Size               = UDim2.new(0.4, 0, 0, 20),
                Position           = UDim2.new(0.6, 0, 0, 8),
                BackgroundTransparency = 1,
                Text               = tostring(value) .. suffix,
                TextColor3         = theme.Accent,
                TextSize           = theme.FontSize,
                Font               = theme.FontBold,
                TextXAlignment     = Enum.TextXAlignment.Right,
                ZIndex             = Z.ContentText,
                Parent             = frame,
            })

            local trackBG = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 6),
                Position        = UDim2.new(0, 0, 1, -18),
                BackgroundColor3= theme.Slider_BG,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentCtrl,
                Parent          = frame,
            })
            Corner(trackBG, UDim.new(1, 0))

            local pct0 = (value - min) / (max - min)
            local trackFill = Create("Frame", {
                Size            = UDim2.new(pct0, 0, 1, 0),
                BackgroundColor3= theme.Slider_Fill,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentKnob,
                Parent          = trackBG,
            })
            Corner(trackFill, UDim.new(1, 0))

            local thumb = Create("Frame", {
                Size            = UDim2.new(0, 14, 0, 14),
                AnchorPoint     = Vector2.new(0.5, 0.5),
                Position        = UDim2.new(pct0, 0, 0.5, 0),
                BackgroundColor3= Color3.fromRGB(255,255,255),
                BorderSizePixel = 0,
                ZIndex          = Z.ContentKnob + 1,
                Parent          = trackBG,
            })
            Corner(thumb, UDim.new(1, 0))

            local dragging = false
            local function UpdateSlider(inputX)
                local abs = trackBG.AbsolutePosition.X
                local w   = trackBG.AbsoluteSize.X
                local pct = math.clamp((inputX - abs) / w, 0, 1)
                local raw = min + (max - min) * pct
                local mult = 10^decimals
                value = math.floor(raw * mult + 0.5) / mult
                valLabel.Text = tostring(value) .. suffix
                Tween(trackFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.04)
                Tween(thumb, {Position = UDim2.new(pct, 0, 0.5, 0)}, 0.04)
                task.spawn(callback, value)
            end

            local sliderHit = Create("TextButton", {
                Size               = UDim2.new(1, 0, 0, 20),
                Position           = UDim2.new(0, 0, 1, -22),
                BackgroundTransparency = 1,
                Text               = "",
                ZIndex             = Z.ContentHit,
                Parent             = frame,
            })
            sliderHit.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(i.Position.X)
                end
            end)
            trackBG.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                or i.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(i.Position.X)
                end
            end)

            local obj = {}
            function obj:Set(v)
                value = math.clamp(v, min, max)
                local pct = (value - min) / (max - min)
                valLabel.Text = tostring(value) .. suffix
                Tween(trackFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1)
                Tween(thumb,     {Position = UDim2.new(pct, 0, 0.5, 0)}, 0.1)
                task.spawn(callback, value)
            end
            function obj:Get() return value end

            if configKey then self.Config:Register(configKey, obj) end
            return obj
        end

        -- DROPDOWN
        function tabObj:CreateDropdown(cfg)
            cfg = cfg or {}
            local name      = cfg.Name        or "Dropdown"
            local options   = cfg.Options     or {}
            local default   = cfg.Default     or (options[1] or "None")
            local multiSel  = cfg.MultiSelect or false
            local configKey = cfg.ConfigKey
            local callback  = cfg.Callback    or function() end
            local selected  = default
            local multiSelected = {}
            local open = false

            local frame = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 38),
                BackgroundColor3= theme.SecondaryBg,
                BorderSizePixel = 0,
                ClipsDescendants= false,
                ZIndex          = Z.ContentItem,
                Parent          = content,
            })
            Corner(frame, theme.CornerRadius)
            Stroke(frame, theme.Border, 1)
            Padding(frame, 0, 0, 14, 14)

            Create("TextLabel", {
                Size               = UDim2.new(0.5, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = name,
                TextColor3         = theme.Text,
                TextSize           = theme.FontSize,
                Font               = theme.Font,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = Z.ContentText,
                Parent             = frame,
            })

            local selLabel = Create("TextLabel", {
                Size               = UDim2.new(0.5, -24, 1, 0),
                Position           = UDim2.new(0.5, 0, 0, 0),
                BackgroundTransparency = 1,
                Text               = selected,
                TextColor3         = theme.Accent,
                TextSize           = 11,
                Font               = theme.Font,
                TextXAlignment     = Enum.TextXAlignment.Right,
                TextTruncate       = Enum.TextTruncate.AtEnd,
                ZIndex             = Z.ContentText,
                Parent             = frame,
            })

            local arrowLabel = Create("TextLabel", {
                Size               = UDim2.new(0, 18, 1, 0),
                Position           = UDim2.new(1, -18, 0, 0),
                BackgroundTransparency = 1,
                Text               = "▾",
                TextColor3         = theme.SubText,
                TextSize           = 13,
                Font               = theme.Font,
                ZIndex             = Z.ContentText,
                Parent             = frame,
            })

            local listH = math.min(#options, 6) * 30 + 8
            local ddList = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, listH),
                Position        = UDim2.new(0, 0, 1, 4),
                BackgroundColor3= theme.TertiaryBg,
                BorderSizePixel = 0,
                Visible         = false,
                ZIndex          = Z.Dropdown,
                ClipsDescendants= true,
                Parent          = frame,
            })
            Corner(ddList, UDim.new(0, 8))
            Stroke(ddList, theme.Border, 1)
            Padding(ddList, 4, 4, 4, 4)
            ListLayout(ddList, 2)

            local function BuildOptions()
                for _, c in pairs(ddList:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local isSel = multiSel and table.find(multiSelected, opt) or (opt == selected)
                    local optBtn = Create("TextButton", {
                        Size            = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3= isSel and theme.AccentDark or theme.TertiaryBg,
                        Text            = (multiSel and isSel and "✓ " or "  ") .. opt,
                        TextColor3      = isSel and theme.Text or theme.SubText,
                        TextSize        = 12,
                        Font            = theme.Font,
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        BorderSizePixel = 0,
                        ZIndex          = Z.DropdownItem,
                        Parent          = ddList,
                    })
                    Corner(optBtn, UDim.new(0, 6))
                    Padding(optBtn, 0, 0, 8, 0)
                    optBtn.MouseEnter:Connect(function()
                        if not (multiSel and table.find(multiSelected,opt) or opt==selected) then
                            Tween(optBtn,{BackgroundColor3=theme.SecondaryBg},0.1)
                        end
                    end)
                    optBtn.MouseLeave:Connect(function()
                        local sel = multiSel and table.find(multiSelected,opt) or opt==selected
                        Tween(optBtn,{BackgroundColor3=sel and theme.AccentDark or theme.TertiaryBg},0.1)
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        if multiSel then
                            local idx = table.find(multiSelected, opt)
                            if idx then table.remove(multiSelected, idx)
                            else table.insert(multiSelected, opt) end
                            selLabel.Text = #multiSelected==0 and "None" or table.concat(multiSelected,", ")
                            task.spawn(callback, multiSelected)
                        else
                            selected = opt
                            selLabel.Text = selected
                            open = false
                            ddList.Visible = false
                            Tween(arrowLabel,{Rotation=0},0.15)
                            task.spawn(callback, selected)
                        end
                        BuildOptions()
                    end)
                end
            end
            BuildOptions()

            local hitbox = Create("TextButton", {
                Size               = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = "",
                ZIndex             = Z.ContentHit,
                Parent             = frame,
            })
            hitbox.MouseButton1Click:Connect(function()
                open = not open
                ddList.Visible = open
                Tween(arrowLabel, {Rotation = open and 180 or 0}, 0.15)
            end)

            local obj = {}
            function obj:Set(v)
                if multiSel then
                    multiSelected = type(v)=="table" and v or {v}
                    selLabel.Text = #multiSelected==0 and "None" or table.concat(multiSelected,", ")
                else
                    selected = v
                    selLabel.Text = v
                end
                BuildOptions()
                task.spawn(callback, multiSel and multiSelected or selected)
            end
            function obj:Get() return multiSel and multiSelected or selected end
            function obj:Refresh(newOptions)
                options = newOptions
                listH   = math.min(#options,6)*30+8
                ddList.Size = UDim2.new(1,0,0,listH)
                BuildOptions()
            end

            if configKey then self.Config:Register(configKey, obj) end
            return obj
        end

        -- TEXTBOX
        function tabObj:CreateTextbox(cfg)
            cfg = cfg or {}
            local name         = cfg.Name         or "Textbox"
            local placeholder  = cfg.Placeholder  or "Enter text..."
            local default      = cfg.Default      or ""
            local configKey    = cfg.ConfigKey
            local callback     = cfg.Callback     or function() end
            local clearOnFocus = cfg.ClearOnFocus ~= false

            local frame = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 54),
                BackgroundColor3= theme.SecondaryBg,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentItem,
                Parent          = content,
            })
            Corner(frame, theme.CornerRadius)
            Stroke(frame, theme.Border, 1)
            Padding(frame, 0, 0, 14, 14)

            Create("TextLabel", {
                Size               = UDim2.new(1, 0, 0, 20),
                Position           = UDim2.new(0, 0, 0, 6),
                BackgroundTransparency = 1,
                Text               = name,
                TextColor3         = theme.Text,
                TextSize           = theme.FontSize,
                Font               = theme.Font,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = Z.ContentText,
                Parent             = frame,
            })

            local inputBG = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 24),
                Position        = UDim2.new(0, 0, 1, -26),
                BackgroundColor3= theme.Background,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentCtrl,
                Parent          = frame,
            })
            Corner(inputBG, UDim.new(0, 6))
            local inputStroke = Stroke(inputBG, theme.Border, 1)

            local tb = Create("TextBox", {
                Size             = UDim2.new(1, -12, 1, 0),
                Position         = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1,
                Text             = default,
                PlaceholderText  = placeholder,
                PlaceholderColor3= theme.Muted,
                TextColor3       = theme.Text,
                TextSize         = 12,
                Font             = theme.Font,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ClearTextOnFocus = clearOnFocus,
                ZIndex           = Z.ContentKnob,
                Parent           = inputBG,
            })
            tb.Focused:Connect(function()    Tween(inputStroke,{Color=theme.Accent},0.15) end)
            tb.FocusLost:Connect(function(e) Tween(inputStroke,{Color=theme.Border},0.15)
                task.spawn(callback, tb.Text, e) end)

            local obj = {}
            function obj:Set(v) tb.Text = v end
            function obj:Get()  return tb.Text end

            if configKey then self.Config:Register(configKey, obj) end
            return obj
        end

        -- KEYBIND
        function tabObj:CreateKeybind(cfg)
            cfg = cfg or {}
            local name      = cfg.Name    or "Keybind"
            local default   = cfg.Default or Enum.KeyCode.RightShift
            local configKey = cfg.ConfigKey
            local callback  = cfg.Callback or function() end
            local binding   = default
            local listening = false

            local frame = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 38),
                BackgroundColor3= theme.SecondaryBg,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentItem,
                Parent          = content,
            })
            Corner(frame, theme.CornerRadius)
            Stroke(frame, theme.Border, 1)
            Padding(frame, 0, 0, 14, 14)

            Create("TextLabel", {
                Size               = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = name,
                TextColor3         = theme.Text,
                TextSize           = theme.FontSize,
                Font               = theme.Font,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = Z.ContentText,
                Parent             = frame,
            })

            local keyBtn = Create("TextButton", {
                Size            = UDim2.new(0, 86, 0, 26),
                Position        = UDim2.new(1, -86, 0.5, -13),
                BackgroundColor3= theme.TertiaryBg,
                Text            = "[ " .. binding.Name .. " ]",
                TextColor3      = theme.Accent,
                TextSize        = 11,
                Font            = theme.FontBold,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentCtrl,
                Parent          = frame,
            })
            Corner(keyBtn, UDim.new(0, 6))
            Stroke(keyBtn, theme.Border, 1)

            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text      = "[ ... ]"
                keyBtn.TextColor3= theme.SubText
            end)
            UserInputService.InputBegan:Connect(function(input, gpe)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    binding = input.KeyCode
                    keyBtn.Text      = "[ " .. binding.Name .. " ]"
                    keyBtn.TextColor3= theme.Accent
                    listening = false
                elseif not listening and not gpe and input.KeyCode == binding then
                    task.spawn(callback)
                end
            end)

            local obj = {}
            function obj:Set(k) binding = k; keyBtn.Text = "[ "..k.Name.." ]" end
            function obj:Get()  return binding end

            if configKey then self.Config:Register(configKey, obj) end
            return obj
        end

        -- LABEL
        function tabObj:CreateLabel(text, labelColor)
            local lbl = Create("TextLabel", {
                Size            = UDim2.new(1, 0, 0, 30),
                BackgroundColor3= theme.SecondaryBg,
                Text            = "  " .. (text or ""),
                TextColor3      = labelColor or theme.SubText,
                TextSize        = 12,
                Font            = theme.Font,
                TextXAlignment  = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentText,
                Parent          = content,
            })
            Corner(lbl, theme.CornerRadius)
            Stroke(lbl, theme.Border, 1)
            local obj = {}
            function obj:Set(v) lbl.Text = "  "..v end
            function obj:Get()  return lbl.Text:sub(3) end
            return obj
        end

        -- COLOR PICKER
        function tabObj:CreateColorPicker(cfg)
            cfg = cfg or {}
            local name      = cfg.Name    or "Color"
            local default   = cfg.Default or Color3.fromRGB(255,100,100)
            local configKey = cfg.ConfigKey
            local callback  = cfg.Callback or function() end
            local color     = default
            local open      = false

            local frame = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 38),
                BackgroundColor3= theme.SecondaryBg,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentItem,
                Parent          = content,
            })
            Corner(frame, theme.CornerRadius)
            Stroke(frame, theme.Border, 1)
            Padding(frame, 0, 0, 14, 14)

            Create("TextLabel", {
                Size               = UDim2.new(1, -50, 1, 0),
                BackgroundTransparency = 1,
                Text               = name,
                TextColor3         = theme.Text,
                TextSize           = theme.FontSize,
                Font               = theme.Font,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = Z.ContentText,
                Parent             = frame,
            })

            local preview = Create("Frame", {
                Size            = UDim2.new(0, 28, 0, 20),
                Position        = UDim2.new(1, -28, 0.5, -10),
                BackgroundColor3= color,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentCtrl,
                Parent          = frame,
            })
            Corner(preview, UDim.new(0, 5))
            Stroke(preview, theme.Border, 1)

            local panel = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 90),
                Position        = UDim2.new(0, 0, 1, 4),
                BackgroundColor3= theme.TertiaryBg,
                BorderSizePixel = 0,
                Visible         = false,
                ZIndex          = Z.ColorPanel,
                Parent          = frame,
            })
            Corner(panel, UDim.new(0, 8))
            Stroke(panel, theme.Border, 1)
            Padding(panel, 6, 6, 10, 10)
            ListLayout(panel, 4)

            local function RGBRow(channel, val)
                local row = Create("Frame", {
                    Size               = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    ZIndex             = Z.ColorPanel + 1,
                    Parent             = panel,
                })
                Create("TextLabel", {
                    Size               = UDim2.new(0, 16, 1, 0),
                    BackgroundTransparency = 1,
                    Text               = channel,
                    TextColor3         = theme.SubText,
                    TextSize           = 11,
                    Font               = theme.FontBold,
                    ZIndex             = Z.ColorPanel + 1,
                    Parent             = row,
                })
                local trackBG = Create("Frame", {
                    Size            = UDim2.new(1, -60, 0, 6),
                    Position        = UDim2.new(0, 20, 0.5, -3),
                    BackgroundColor3= theme.Slider_BG,
                    BorderSizePixel = 0,
                    ZIndex          = Z.ColorPanel + 1,
                    Parent          = row,
                })
                Corner(trackBG, UDim.new(1, 0))
                local pct  = val/255
                local fill = Create("Frame", {
                    Size            = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3= channel=="R" and Color3.fromRGB(220,60,60)
                                    or channel=="G" and Color3.fromRGB(60,200,60)
                                    or Color3.fromRGB(60,60,220),
                    BorderSizePixel = 0,
                    ZIndex          = Z.ColorPanel + 2,
                    Parent          = trackBG,
                })
                Corner(fill, UDim.new(1, 0))
                local numLabel = Create("TextLabel", {
                    Size               = UDim2.new(0, 36, 1, 0),
                    Position           = UDim2.new(1, -36, 0, 0),
                    BackgroundTransparency = 1,
                    Text               = tostring(math.floor(val)),
                    TextColor3         = theme.Text,
                    TextSize           = 11,
                    Font               = theme.Font,
                    ZIndex             = Z.ColorPanel + 1,
                    Parent             = row,
                })
                return trackBG, fill, numLabel
            end

            local r, g, b = color.R*255, color.G*255, color.B*255
            local rTrack,rFill,rNum = RGBRow("R", r)
            local gTrack,gFill,gNum = RGBRow("G", g)
            local bTrack,bFill,bNum = RGBRow("B", b)

            local function MakeSlider(track, fill, numLabel, chGet, chSet)
                local drag = false
                track.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then drag = true end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
                    or i.UserInputType == Enum.UserInputType.Touch) then
                        local pct = math.clamp((i.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
                        chSet(math.floor(pct*255))
                        fill.Size      = UDim2.new(pct, 0, 1, 0)
                        numLabel.Text  = tostring(math.floor(pct*255))
                        color = Color3.fromRGB(r, g, b)
                        preview.BackgroundColor3 = color
                        task.spawn(callback, color)
                    end
                end)
            end

            MakeSlider(rTrack,rFill,rNum,function() return r end,function(v) r=v end)
            MakeSlider(gTrack,gFill,gNum,function() return g end,function(v) g=v end)
            MakeSlider(bTrack,bFill,bNum,function() return b end,function(v) b=v end)

            Create("TextButton", {
                Size               = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = "",
                ZIndex             = Z.ContentHit,
                Parent             = frame,
            }).MouseButton1Click:Connect(function()
                open = not open
                panel.Visible = open
            end)

            local obj = {}
            function obj:Set(c)
                color = c
                r,g,b = c.R*255, c.G*255, c.B*255
                preview.BackgroundColor3 = color
                task.spawn(callback, color)
            end
            function obj:Get() return color end

            if configKey then self.Config:Register(configKey, obj) end
            return obj
        end

        -- CONFIG PANEL
        function tabObj:CreateConfigSection()
            self:CreateSection("Config")
            local configs  = windowObj.Config:ListConfigs()
            local configDD = self:CreateDropdown({
                Name = "Load Config",
                Options = #configs > 0 and configs or {"No configs"},
                Callback = function() end
            })
            local configInput = self:CreateTextbox({
                Name = "Config Name",
                Placeholder = "my_config",
                Default = "default",
            })
            self:CreateButton({
                Name = "Save Config",
                Callback = function()
                    local name = configInput:Get()
                    if name and name ~= "" then
                        windowObj.Config:Save(name)
                        local newList = windowObj.Config:ListConfigs()
                        configDD:Refresh(newList)
                        windowObj.Library:Notify({Title="Config Saved",Message='Saved as "'..name..'"',Type="Success",Duration=3})
                    end
                end
            })
            self:CreateButton({
                Name = "Load Config",
                Callback = function()
                    local name = configDD:Get()
                    if name and name ~= "No configs" then
                        windowObj.Config:Load(name)
                        windowObj.Library:Notify({Title="Config Loaded",Message='Loaded "'..name..'"',Type="Info",Duration=3})
                    end
                end
            })
        end

        -- ── INFO TAB BUILDER  (call CreateInfoTab on windowObj, not tabObj)
        return tabObj
    end

    -- ============================================================
    -- INFO TAB  — Shows avatar, username, session stats
    -- ============================================================
    function windowObj:CreateInfoTab(tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Info"
        tabConfig.Icon = tabConfig.Icon or "ℹ"

        local infoTab = self:CreateTab(tabConfig)
        local lib     = self.Library

        infoTab:CreateSection("Player Info")

        -- Avatar image row
        local avatarRow = Create("Frame", {
            Size            = UDim2.new(1, 0, 0, 72),
            BackgroundColor3= theme.SecondaryBg,
            BorderSizePixel = 0,
            ZIndex          = Z.ContentItem,
            Parent          = infoTab.Content,
        })
        Corner(avatarRow, theme.CornerRadius)
        Stroke(avatarRow, theme.Border, 1)
        Padding(avatarRow, 0, 0, 14, 14)

        -- Avatar thumbnail
        local avatarImg = Create("ImageLabel", {
            Size               = UDim2.new(0, 52, 0, 52),
            Position           = UDim2.new(0, 0, 0.5, -26),
            BackgroundColor3   = theme.TertiaryBg,
            BackgroundTransparency = 0,
            Image              = "",
            ZIndex             = Z.ContentCtrl,
            Parent             = avatarRow,
        })
        Corner(avatarImg, UDim.new(1, 0))
        -- Load avatar async
        task.spawn(function()
            local ok, content2 = pcall(function()
                return game:GetService("Players"):GetUserThumbnailAsync(
                    LocalPlayer.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size100x100
                )
            end)
            if ok then avatarImg.Image = content2 end
        end)

        -- Name / display name
        local nameCol = Create("Frame", {
            Size               = UDim2.new(1, -62, 1, 0),
            Position           = UDim2.new(0, 62, 0, 0),
            BackgroundTransparency = 1,
            ZIndex             = Z.ContentItem,
            Parent             = avatarRow,
        })
        Create("TextLabel", {
            Size               = UDim2.new(1, 0, 0, 22),
            Position           = UDim2.new(0, 0, 0, 12),
            BackgroundTransparency = 1,
            Text               = LocalPlayer.DisplayName,
            TextColor3         = theme.Text,
            TextSize           = 14,
            Font               = theme.FontBold,
            TextXAlignment     = Enum.TextXAlignment.Left,
            ZIndex             = Z.ContentText,
            Parent             = nameCol,
        })
        Create("TextLabel", {
            Size               = UDim2.new(1, 0, 0, 16),
            Position           = UDim2.new(0, 0, 0, 36),
            BackgroundTransparency = 1,
            Text               = "@" .. LocalPlayer.Name,
            TextColor3         = theme.SubText,
            TextSize           = 11,
            Font               = theme.Font,
            TextXAlignment     = Enum.TextXAlignment.Left,
            ZIndex             = Z.ContentText,
            Parent             = nameCol,
        })

        infoTab:CreateSection("Session Stats")

        -- Stat card helper
        local function StatCard(labelText, getValue, accentColor)
            local card = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 44),
                BackgroundColor3= theme.SecondaryBg,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentItem,
                Parent          = infoTab.Content,
            })
            Corner(card, theme.CornerRadius)
            Stroke(card, theme.Border, 1)
            Padding(card, 0, 0, 14, 14)

            -- Accent left bar
            Create("Frame", {
                Size            = UDim2.new(0, 3, 0.6, 0),
                Position        = UDim2.new(0, 0, 0.2, 0),
                BackgroundColor3= accentColor or theme.Accent,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentCtrl,
                Parent          = card,
            })

            Create("TextLabel", {
                Size               = UDim2.new(0.55, 0, 1, 0),
                Position           = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text               = labelText,
                TextColor3         = theme.SubText,
                TextSize           = 12,
                Font               = theme.Font,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = Z.ContentText,
                Parent             = card,
            })

            local valLbl = Create("TextLabel", {
                Size               = UDim2.new(0.45, 0, 1, 0),
                Position           = UDim2.new(0.55, 0, 0, 0),
                BackgroundTransparency = 1,
                Text               = tostring(getValue()),
                TextColor3         = accentColor or theme.Accent,
                TextSize           = 13,
                Font               = theme.FontBold,
                TextXAlignment     = Enum.TextXAlignment.Right,
                ZIndex             = Z.ContentText,
                Parent             = card,
            })
            return valLbl
        end

        local execLbl = StatCard("Total Executions", function() return lib._totalExecutions end, theme.Success)
        local timeLbl = StatCard("Session Time",      function() return "0s" end, theme.Info)
        local uidLbl  = StatCard("User ID",           function() return tostring(LocalPlayer.UserId) end, theme.Accent)

        -- Account age
        StatCard("Account Age", function()
            local age = LocalPlayer.AccountAge
            if age >= 365 then return math.floor(age/365).."y "..math.floor((age%365)/30).."m"
            elseif age >= 30 then return math.floor(age/30).."m "..age%30 .."d"
            else return age.." days" end
        end, theme.Warning)

        -- Update live stats every second
        RunService.Heartbeat:Connect(function()
            if not infoTab.Content or not infoTab.Content.Parent then return end
            execLbl.Text = tostring(lib._totalExecutions)
            local elapsed = os.time() - lib._sessionStart
            local h = math.floor(elapsed/3600)
            local m = math.floor((elapsed%3600)/60)
            local s = elapsed % 60
            if h > 0 then
                timeLbl.Text = h.."h "..m.."m"
            elseif m > 0 then
                timeLbl.Text = m.."m "..s.."s"
            else
                timeLbl.Text = s.."s"
            end
        end)

        infoTab:CreateSection("Script Info")

        -- Script name / version display
        local function InfoRow(label, value)
            local row = Create("Frame", {
                Size            = UDim2.new(1, 0, 0, 32),
                BackgroundColor3= theme.SecondaryBg,
                BorderSizePixel = 0,
                ZIndex          = Z.ContentItem,
                Parent          = infoTab.Content,
            })
            Corner(row, theme.CornerRadius)
            Stroke(row, theme.Border, 1)
            Padding(row, 0, 0, 14, 14)
            Create("TextLabel", {
                Size               = UDim2.new(0.45, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = label,
                TextColor3         = theme.SubText,
                TextSize           = 11,
                Font               = theme.Font,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = Z.ContentText,
                Parent             = row,
            })
            Create("TextLabel", {
                Size               = UDim2.new(0.55, 0, 1, 0),
                Position           = UDim2.new(0.45, 0, 0, 0),
                BackgroundTransparency = 1,
                Text               = value,
                TextColor3         = theme.Text,
                TextSize           = 11,
                Font               = theme.FontBold,
                TextXAlignment     = Enum.TextXAlignment.Right,
                ZIndex             = Z.ContentText,
                Parent             = row,
            })
        end

        InfoRow("Script",    self.Library.Config.ScriptName or "Unknown")
        InfoRow("Library",   "NebulaUI v2")
        InfoRow("Game",      tostring(game.PlaceId))

        return infoTab
    end

    -- Select tab
    function windowObj:_SelectTab(tabObj)
        for _, t in pairs(self.Tabs) do
            t.Content.Visible = false
            Tween(t.Button, {BackgroundColor3=theme.SidebarInactive, TextColor3=theme.SubText}, 0.15)
            t.Indicator.Visible = false
        end
        tabObj.Content.Visible  = true
        Tween(tabObj.Button, {BackgroundColor3=theme.SecondaryBg, TextColor3=theme.Text}, 0.15)
        tabObj.Indicator.Visible = true
        self.ActiveTab = tabObj
    end

    table.insert(self.Windows, windowObj)
    return windowObj
end

-- ============================================================
-- DESTROY
-- ============================================================
function NebulaUI:Destroy()
    self.ScreenGui:Destroy()
end

return NebulaUI

--[[
================================================================
  NEBULA UI v2 — USAGE EXAMPLE
================================================================

local NebulaUI = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()

local Library = NebulaUI.new({
    Title         = "Pixel Blade",
    Subtitle      = "By vhxLUA",
    Theme         = "Nebula",
    Intro         = true,
    IntroTitle    = "Pixel Blade",
    IntroSubtitle = "Loading features...",
    Duration      = 3,
    ToggleKey     = Enum.KeyCode.RightControl,
    MobileButton  = true,
})

local Window = Library:CreateWindow({
    Title         = "Pixel Blade",
    Subtitle      = "By vhxLUA",
    ToggleKey     = Enum.KeyCode.RightControl,
    MobileButton  = true,
})

-- ── KILL AURA TAB
local KillAuraTab = Window:CreateTab({ Name = "Kill Aura", Icon = "⚔" })

KillAuraTab:CreateSection("Kill Aura")

local kaToggle = KillAuraTab:CreateToggle({
    Name        = "Kill Aura",
    Description = "Press [L] to toggle",
    Default     = false,
    ConfigKey   = "ka_enabled",
    Callback    = function(state) print("Kill Aura:", state) end
})

KillAuraTab:CreateSlider({
    Name    = "Aura Range",
    Min     = 10, Max = 100, Default = 50,
    Suffix  = " studs",
    ConfigKey = "ka_range",
    Callback  = function(val) print("Range:", val) end
})

KillAuraTab:CreateSlider({
    Name    = "Attack Speed",
    Min     = 50, Max = 500, Default = 100,
    Suffix  = " ms",
    ConfigKey = "ka_speed",
    Callback  = function(val) print("Speed:", val) end
})

-- ── INFO TAB  (new feature — shows player stats)
local InfoTab = Window:CreateInfoTab({ Icon = "👤" })

-- ── SETTINGS TAB
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "⚙" })
SettingsTab:CreateKeybind({
    Name     = "Toggle UI",
    Default  = Enum.KeyCode.RightControl,
    Callback = function() print("Toggled!") end
})
SettingsTab:CreateConfigSection()

Library:Notify({
    Title    = "Pixel Blade",
    Message  = "Welcome! Press RCtrl to toggle.",
    Type     = "Success",
    Duration = 5,
})

================================================================
WHAT CHANGED FROM v1:
  • ZIndexBehavior.Global — sidebar ZIndex 30+ always renders
    above content ZIndex 12-17, fixing "text on back" layering
  • Shadow moved outside window (no longer clipped)
  • Minimize → floating draggable icon (not window shrink)
  • Resize handle at bottom-right corner
  • Mobile button shown on all devices (not just touch-only)
  • MobileButton is draggable
  • Info tab with avatar, username, live session stats
================================================================
]]
