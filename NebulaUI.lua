-- ============================================================
--   NebulaUI v3 — Roblox UI Library
--   • ZIndex Global layering fix
--   • Shadow outside window (no clipping)
--   • Title-bar controls: □ − ×  (fullscreen / minimize / close)
--   • Minimize → draggable floating icon
--   • Resizable via bottom-right corner
--   • Mobile ☰ button (all devices, draggable)
--   • Tab icons: emoji/text OR numeric rbxassetid (ImageLabel)
--   • CreateButton: cfg.ButtonText for custom action label
--   • Info tab: avatar, FPS, Ping, stats, game name, account age in days
--   • getgenv()._NebulaDestroy auto-set for re-execute cleanup
-- ============================================================

local NebulaUI = {}
NebulaUI.__index = NebulaUI

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local Stats            = game:GetService("Stats")
local LocalPlayer      = Players.LocalPlayer

-- ============================================================
-- THEMES
-- ============================================================
NebulaUI.Themes = {
    Nebula = {
        Background      = Color3.fromRGB(14, 14, 20),
        SecondaryBg     = Color3.fromRGB(20, 20, 30),
        TertiaryBg      = Color3.fromRGB(27, 27, 40),
        Accent          = Color3.fromRGB(130, 90, 255),
        AccentDark      = Color3.fromRGB(90, 60, 180),
        AccentHover     = Color3.fromRGB(150, 110, 255),
        Text            = Color3.fromRGB(240, 240, 245),
        SubText         = Color3.fromRGB(155, 155, 175),
        Muted           = Color3.fromRGB(80, 80, 100),
        Border          = Color3.fromRGB(38, 38, 55),
        Success         = Color3.fromRGB(60, 210, 120),
        Warning         = Color3.fromRGB(240, 180, 40),
        Error           = Color3.fromRGB(225, 65, 65),
        Info            = Color3.fromRGB(65, 165, 255),
        Toggle_On       = Color3.fromRGB(130, 90, 255),
        Toggle_Off      = Color3.fromRGB(50, 50, 68),
        Slider_Fill     = Color3.fromRGB(130, 90, 255),
        Slider_BG       = Color3.fromRGB(38, 38, 55),
        Sidebar         = Color3.fromRGB(17, 17, 25),
        SidebarActive   = Color3.fromRGB(130, 90, 255),
        SidebarInactive = Color3.fromRGB(17, 17, 25),
        Font            = Enum.Font.Gotham,
        FontBold        = Enum.Font.GothamBold,
        FontSize        = 13,
        CornerRadius    = UDim.new(0, 9),
    },
    Ocean = {
        Background      = Color3.fromRGB(10, 18, 28),
        SecondaryBg     = Color3.fromRGB(14, 24, 38),
        TertiaryBg      = Color3.fromRGB(18, 30, 48),
        Accent          = Color3.fromRGB(40, 160, 255),
        AccentDark      = Color3.fromRGB(20, 110, 200),
        AccentHover     = Color3.fromRGB(70, 180, 255),
        Text            = Color3.fromRGB(230, 240, 255),
        SubText         = Color3.fromRGB(140, 160, 190),
        Muted           = Color3.fromRGB(60, 80, 110),
        Border          = Color3.fromRGB(28, 45, 68),
        Success         = Color3.fromRGB(50, 210, 130),
        Warning         = Color3.fromRGB(240, 180, 40),
        Error           = Color3.fromRGB(220, 65, 65),
        Info            = Color3.fromRGB(40, 160, 255),
        Toggle_On       = Color3.fromRGB(40, 160, 255),
        Toggle_Off      = Color3.fromRGB(30, 50, 75),
        Slider_Fill     = Color3.fromRGB(40, 160, 255),
        Slider_BG       = Color3.fromRGB(28, 45, 68),
        Sidebar         = Color3.fromRGB(10, 16, 26),
        SidebarActive   = Color3.fromRGB(40, 160, 255),
        SidebarInactive = Color3.fromRGB(10, 16, 26),
        Font            = Enum.Font.Gotham,
        FontBold        = Enum.Font.GothamBold,
        FontSize        = 13,
        CornerRadius    = UDim.new(0, 9),
    },
    Crimson = {
        Background      = Color3.fromRGB(18, 12, 14),
        SecondaryBg     = Color3.fromRGB(26, 16, 20),
        TertiaryBg      = Color3.fromRGB(34, 20, 26),
        Accent          = Color3.fromRGB(220, 55, 85),
        AccentDark      = Color3.fromRGB(160, 35, 60),
        AccentHover     = Color3.fromRGB(240, 75, 105),
        Text            = Color3.fromRGB(245, 235, 238),
        SubText         = Color3.fromRGB(175, 150, 158),
        Muted           = Color3.fromRGB(90, 65, 72),
        Border          = Color3.fromRGB(50, 30, 38),
        Success         = Color3.fromRGB(55, 205, 115),
        Warning         = Color3.fromRGB(240, 180, 40),
        Error           = Color3.fromRGB(220, 55, 85),
        Info            = Color3.fromRGB(65, 165, 255),
        Toggle_On       = Color3.fromRGB(220, 55, 85),
        Toggle_Off      = Color3.fromRGB(55, 30, 38),
        Slider_Fill     = Color3.fromRGB(220, 55, 85),
        Slider_BG       = Color3.fromRGB(50, 30, 38),
        Sidebar         = Color3.fromRGB(15, 10, 12),
        SidebarActive   = Color3.fromRGB(220, 55, 85),
        SidebarInactive = Color3.fromRGB(15, 10, 12),
        Font            = Enum.Font.Gotham,
        FontBold        = Enum.Font.GothamBold,
        FontSize        = 13,
        CornerRadius    = UDim.new(0, 9),
    },
}

-- ============================================================
-- ZINDEX  (Global behavior — all values are absolute)
-- ============================================================
local Z = {
    Shadow       = 8,
    Window       = 10,
    TitleBar     = 11,
    TitleText    = 12,
    Sidebar      = 30,
    SidebarChild = 31,
    Tooltip      = 40,
    Content      = 13,
    ContentItem  = 14,
    ContentText  = 15,
    ContentCtrl  = 16,
    ContentKnob  = 17,
    ContentHit   = 18,
    Dropdown     = 45,
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
local function Corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = r or UDim.new(0,9); c.Parent = p; return c
end
local function Stroke(p, color, t)
    local s = Instance.new("UIStroke"); s.Color = color or Color3.fromRGB(40,40,55)
    s.Thickness = t or 1; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s
end
local function Padding(p, top, bot, left, right)
    local u = Instance.new("UIPadding")
    u.PaddingTop=UDim.new(0,top or 6); u.PaddingBottom=UDim.new(0,bot or 6)
    u.PaddingLeft=UDim.new(0,left or 10); u.PaddingRight=UDim.new(0,right or 10)
    u.Parent = p; return u
end
local function ListLayout(p, pad, align, halign)
    local l = Instance.new("UIListLayout"); l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, pad or 6)
    if align  then l.VerticalAlignment   = align  end
    if halign then l.HorizontalAlignment = halign end
    l.Parent = p; return l
end
local function Tween(obj, props, t, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(t or 0.2,
        style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
    tw:Play(); return tw
end
local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

-- ============================================================
-- DRAGGABLE  — fixed: doesn't cancel when handle itself is clicked
-- ============================================================
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    local function update(input)
        local d = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local guiObjs = {}
        pcall(function()
            guiObjs = game:GetService("GuiService"):GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
        end)
        for _, obj in ipairs(guiObjs) do
            -- Skip if the hit object IS the handle — allow dragging it
            if obj ~= handle and (obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("ImageButton")) then
                return
            end
        end
        dragging = true; dragStart = input.Position; startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- ============================================================
-- RESIZE
-- ============================================================
local function MakeResizable(window, minW, minH, onResize)
    local handle = Create("TextButton", {
        Size=UDim2.new(0,20,0,20), Position=UDim2.new(1,-20,1,-20),
        BackgroundTransparency=1, Text="⟱",
        TextColor3=Color3.fromRGB(80,80,100), TextSize=13, Font=Enum.Font.GothamBold,
        ZIndex=Z.ContentHit, Parent=window,
    })
    local resizing, resizeStart, startSize = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            resizing=true; resizeStart=input.Position; startSize=window.AbsoluteSize
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then resizing=false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType==Enum.UserInputType.MouseMovement
        or input.UserInputType==Enum.UserInputType.Touch) then
            local d=input.Position-resizeStart
            local nW=math.max(minW or 340, startSize.X+d.X)
            local nH=math.max(minH or 280, startSize.Y+d.Y)
            window.Size=UDim2.new(0,nW,0,nH)
            if onResize then onResize(nW,nH) end
        end
    end)
    return handle
end

-- ============================================================
-- CONFIG SYSTEM
-- ============================================================
local ConfigSystem = {}; ConfigSystem.__index = ConfigSystem
function ConfigSystem.new(scriptName)
    local self = setmetatable({}, ConfigSystem)
    self.ScriptName = scriptName or "NebulaUI"
    self.Folder   = "NebulaConfigs/"..self.ScriptName
    self.Elements = {}
    if not isfolder then return self end
    if not isfolder("NebulaConfigs") then makefolder("NebulaConfigs") end
    if not isfolder(self.Folder)     then makefolder(self.Folder)     end
    return self
end
function ConfigSystem:Register(k, e) self.Elements[k] = e end
function ConfigSystem:Save(n)
    if not writefile then return end; n = n or "default"
    local d = {}
    for k, e in pairs(self.Elements) do
        if e.Get then
            local v = e:Get()
            if type(v)=="boolean" or type(v)=="number" or type(v)=="string" then d[k]=v
            elseif typeof(v)=="EnumItem" then d[k]=tostring(v) end
        end
    end
    writefile(self.Folder.."/"..n..".json", game:GetService("HttpService"):JSONEncode(d))
end
function ConfigSystem:Load(n)
    if not readfile then return end; n = n or "default"
    local path = self.Folder.."/"..n..".json"
    if not isfile(path) then return end
    local ok, d = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(path)) end)
    if not ok then return end
    for k, v in pairs(d) do
        local e = self.Elements[k]
        if e and e.Set then
            if type(v)=="string" and v:find("Enum.") then
                local ev = pcall(function() return Enum.KeyCode[v:match("%.(%w+)$")] end)
                if ev then e:Set(ev) end
            else e:Set(v) end
        end
    end
end
function ConfigSystem:ListConfigs()
    if not listfiles then return {} end
    local files = listfiles(self.Folder); local names = {}
    for _, f in pairs(files) do
        local name = f:match("([^/\\]+)%.json$")
        if name then table.insert(names, name) end
    end
    return names
end
function ConfigSystem:Delete(n)
    if not delfile then return end
    local p = self.Folder.."/"..n..".json"
    if isfile(p) then delfile(p) end
end

-- ============================================================
-- INTRO
-- ============================================================
local function PlayIntro(screenGui, config, theme, onFinish)
    local title=config.Title or "Script"; local subtitle=config.Subtitle or "Loading..."
    local logo=config.LogoId; local duration=config.Duration or 3.5
    local overlay = Create("Frame",{Name="Intro",Size=UDim2.new(1,0,1,0),
        BackgroundColor3=Color3.fromRGB(8,8,12),ZIndex=Z.Intro,Parent=screenGui})
    local grad=Instance.new("UIGradient")
    grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(8,8,14)),
        ColorSequenceKeypoint.new(0.5,Color3.fromRGB(18,12,30)),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,8,14))})
    grad.Rotation=135; grad.Parent=overlay
    local center=Create("Frame",{Size=UDim2.new(0,320,0,200),Position=UDim2.new(0.5,-160,0.5,-100),
        BackgroundTransparency=1,ZIndex=Z.Intro+1,Parent=overlay})
    if logo then
        Tween(Create("ImageLabel",{Size=UDim2.new(0,64,0,64),Position=UDim2.new(0.5,-32,0,0),
            BackgroundTransparency=1,Image="rbxassetid://"..tostring(logo),
            ImageColor3=theme.Accent,ImageTransparency=1,ZIndex=Z.Intro+1,Parent=center}),{ImageTransparency=0},0.6)
    end
    local tL=Create("TextLabel",{Size=UDim2.new(1,0,0,48),Position=UDim2.new(0,0,0,logo and 72 or 30),
        BackgroundTransparency=1,Text=title,TextColor3=theme.Text,TextSize=28,Font=theme.FontBold,
        TextTransparency=1,ZIndex=Z.Intro+1,Parent=center})
    local sL=Create("TextLabel",{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,logo and 124 or 82),
        BackgroundTransparency=1,Text=subtitle,TextColor3=theme.SubText,TextSize=14,Font=theme.Font,
        TextTransparency=1,ZIndex=Z.Intro+1,Parent=center})
    local barBG=Create("Frame",{Size=UDim2.new(0,240,0,3),Position=UDim2.new(0.5,-120,1,-30),
        BackgroundColor3=theme.Border,BorderSizePixel=0,BackgroundTransparency=1,ZIndex=Z.Intro+1,Parent=overlay})
    Corner(barBG,UDim.new(1,0))
    local barFill=Create("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=theme.Accent,
        BorderSizePixel=0,ZIndex=Z.Intro+1,Parent=barBG})
    Corner(barFill,UDim.new(1,0))
    task.spawn(function()
        task.wait(0.2); Tween(tL,{TextTransparency=0},0.5)
        task.wait(0.2); Tween(sL,{TextTransparency=0},0.4)
        task.wait(0.1); Tween(barBG,{BackgroundTransparency=0},0.3)
        task.wait(0.2); Tween(barFill,{Size=UDim2.new(1,0,1,0)},duration-1.2)
        task.wait(duration-1.2)
        Tween(overlay,{BackgroundTransparency=1},0.5); Tween(tL,{TextTransparency=1},0.4)
        Tween(sL,{TextTransparency=1},0.4); Tween(barBG,{BackgroundTransparency=1},0.4)
        task.wait(0.5); overlay:Destroy(); onFinish()
    end)
end

-- ============================================================
-- MAIN INIT
-- ============================================================
function NebulaUI.new(config)
    local self = setmetatable({}, NebulaUI)
    config = config or {}
    local themeName = config.Theme or "Nebula"
    self.Theme   = type(config.Theme)=="table" and config.Theme
                   or (NebulaUI.Themes[themeName] or NebulaUI.Themes.Nebula)
    self.Config  = ConfigSystem.new(config.Title or "NebulaScript")
    self.Windows = {}
    self._totalExecutions = 0
    self._sessionStart    = os.time()

    -- ScreenGui with Global ZIndex so sidebar (Z:30) always beats content (Z:13-18)
    self.ScreenGui = Create("ScreenGui", {
        Name           = config.Title or "NebulaUI",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true,
    })
    pcall(function() self.ScreenGui.Parent = game:GetService("CoreGui") end)
    if not self.ScreenGui.Parent or self.ScreenGui.Parent ~= game:GetService("CoreGui") then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    self._notifHolder = Create("Frame",{Name="Notifications",BackgroundTransparency=1,
        Size=UDim2.new(0,300,1,0),Position=UDim2.new(1,-310,0,0),
        ZIndex=Z.Notification,Parent=self.ScreenGui})
    ListLayout(self._notifHolder,8,Enum.VerticalAlignment.Bottom)
    Padding(self._notifHolder,8,8,0,0)

    -- Re-execute cleanup hook
    if getgenv then
        getgenv()._NebulaDestroy = function()
            pcall(function() self:Destroy() end)
            getgenv()._NebulaDestroy = nil
        end
    end

    return self
end

-- ============================================================
-- NOTIFY
-- ============================================================
function NebulaUI:Notify(cfg)
    local theme=self.Theme; cfg=cfg or {}
    local title=cfg.Title or "Notification"; local msg=cfg.Message or ""
    local dur=cfg.Duration or 4; local ntype=cfg.Type or "Info"
    local color={Info=theme.Info,Success=theme.Success,Warning=theme.Warning,Error=theme.Error}[ntype] or theme.Info
    local notif=Create("Frame",{Name="Notif",Size=UDim2.new(1,0,0,74),
        BackgroundColor3=theme.SecondaryBg,BackgroundTransparency=1,
        ClipsDescendants=true,ZIndex=Z.Notification,Parent=self._notifHolder})
    Corner(notif,UDim.new(0,9)); Stroke(notif,color,1)
    Create("Frame",{Size=UDim2.new(0,3,0.7,0),Position=UDim2.new(0,0,0.15,0),
        BackgroundColor3=color,BorderSizePixel=0,ZIndex=Z.Notification+1,Parent=notif})
    local icons={Info="ℹ",Success="✓",Warning="⚠",Error="✕"}
    Create("TextLabel",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,10,0.5,-14),
        BackgroundTransparency=1,Text=icons[ntype] or "ℹ",TextColor3=color,TextSize=16,
        Font=theme.FontBold,ZIndex=Z.Notification+1,Parent=notif})
    Create("TextLabel",{Size=UDim2.new(1,-50,0,20),Position=UDim2.new(0,44,0,12),
        BackgroundTransparency=1,Text=title,TextColor3=theme.Text,TextSize=13,
        Font=theme.FontBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.Notification+1,Parent=notif})
    Create("TextLabel",{Size=UDim2.new(1,-50,0,28),Position=UDim2.new(0,44,0,34),
        BackgroundTransparency=1,Text=msg,TextColor3=theme.SubText,TextSize=11,
        Font=theme.Font,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
        ZIndex=Z.Notification+1,Parent=notif})
    local progBG=Create("Frame",{Size=UDim2.new(1,-44,0,2),Position=UDim2.new(0,44,1,-6),
        BackgroundColor3=theme.Border,BorderSizePixel=0,ZIndex=Z.Notification+1,Parent=notif})
    Corner(progBG,UDim.new(1,0))
    local progFill=Create("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=color,
        BorderSizePixel=0,ZIndex=Z.Notification+2,Parent=progBG})
    Corner(progFill,UDim.new(1,0))
    Tween(notif,{BackgroundTransparency=0},0.3); Tween(progFill,{Size=UDim2.new(0,0,1,0)},dur)
    task.delay(dur,function()
        Tween(notif,{BackgroundTransparency=1},0.3); Tween(notif,{Size=UDim2.new(1,0,0,0)},0.3)
        task.wait(0.35); notif:Destroy()
    end)
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
function NebulaUI:CreateWindow(config)
    config=config or {}
    local theme=self.Theme
    local title=config.Title or "NebulaUI"; local subtitle=config.Subtitle or ""
    local intro=config.Intro~=false; local toggleKey=config.ToggleKey or Enum.KeyCode.RightControl
    local showMobile=config.MobileButton~=false

    local WIN_W=IsMobile() and 380 or 560; local WIN_H=IsMobile() and 340 or 420
    local SIDEBAR_W=IsMobile() and 52 or 48

    -- Shadow (sibling of window, tracked via RenderStepped)
    local shadow=Create("ImageLabel",{Name="Shadow",Size=UDim2.new(0,WIN_W+40,0,WIN_H+40),
        BackgroundTransparency=1,Image="rbxassetid://5554236805",
        ImageColor3=Color3.fromRGB(0,0,0),ImageTransparency=0.55,
        ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(23,23,277,277),
        ZIndex=Z.Shadow,Parent=self.ScreenGui})

    -- Main window (ClipsDescendants=false so shadow sibling is visible)
    local window=Create("Frame",{Name="Window",Size=UDim2.new(0,WIN_W,0,WIN_H),
        Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2),
        BackgroundColor3=theme.Background,BorderSizePixel=0,
        Visible=false,ClipsDescendants=false,ZIndex=Z.Window,Parent=self.ScreenGui})
    Corner(window,theme.CornerRadius); Stroke(window,theme.Border,1)

    RunService.RenderStepped:Connect(function()
        if not window or not window.Parent then return end
        local ap=window.AbsolutePosition; local as=window.AbsoluteSize
        shadow.Position=UDim2.new(0,ap.X-20,0,ap.Y-20)
        shadow.Size=UDim2.new(0,as.X+40,0,as.Y+40)
        shadow.Visible=window.Visible
    end)

    -- ── SIDEBAR (ZIndex 30 — always above content at 13-18)
    local sidebar=Create("Frame",{Name="Sidebar",Size=UDim2.new(0,SIDEBAR_W,1,0),
        BackgroundColor3=theme.Sidebar,BorderSizePixel=0,
        ClipsDescendants=false,ZIndex=Z.Sidebar,Parent=window})
    Corner(sidebar,theme.CornerRadius)
    Create("Frame",{Size=UDim2.new(0,theme.CornerRadius.Offset,1,0),
        Position=UDim2.new(1,-theme.CornerRadius.Offset,0,0),
        BackgroundColor3=theme.Sidebar,BorderSizePixel=0,ZIndex=Z.Sidebar,Parent=sidebar})
    Create("TextLabel",{Size=UDim2.new(1,-4,0,22),Position=UDim2.new(0,2,0,12),
        BackgroundTransparency=1,Text=title:sub(1,2):upper(),
        TextColor3=theme.Accent,TextSize=18,Font=theme.FontBold,
        ZIndex=Z.SidebarChild,Parent=sidebar})
    Create("Frame",{Size=UDim2.new(0.7,0,0,1),Position=UDim2.new(0.15,0,0,54),
        BackgroundColor3=theme.Border,BorderSizePixel=0,ZIndex=Z.SidebarChild,Parent=sidebar})

    local tabIconContainer=Create("Frame",{Name="TabIcons",Size=UDim2.new(1,0,1,-62),
        Position=UDim2.new(0,0,0,62),BackgroundTransparency=1,
        ClipsDescendants=false,ZIndex=Z.SidebarChild,Parent=sidebar})
    ListLayout(tabIconContainer,4,nil,Enum.HorizontalAlignment.Center)
    Padding(tabIconContainer,6,6,0,0)

    -- ── TITLEBAR
    local titleBar=Create("Frame",{Name="TitleBar",Size=UDim2.new(1,-SIDEBAR_W,0,48),
        Position=UDim2.new(0,SIDEBAR_W,0,0),BackgroundColor3=theme.SecondaryBg,
        BorderSizePixel=0,ZIndex=Z.TitleBar,Parent=window})
    Create("TextLabel",{Size=UDim2.new(0.52,0,1,0),Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,
        Text=title..(subtitle~="" and ("  ·  "..subtitle) or ""),
        TextColor3=theme.Text,TextSize=14,Font=theme.FontBold,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.TitleText,Parent=titleBar})
    Create("TextLabel",{Size=UDim2.new(0,95,0,16),Position=UDim2.new(0.52,0,0.5,-8),
        BackgroundTransparency=1,Text="["..tostring(toggleKey.Name).."] toggle",
        TextColor3=theme.Muted,TextSize=10,Font=theme.Font,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.TitleText,Parent=titleBar})
    Create("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=theme.Border,BorderSizePixel=0,ZIndex=Z.TitleBar,Parent=titleBar})

    -- ── WINDOW CONTROLS  [□][−][×]  top-right of titlebar
    local ctrlFrame=Create("Frame",{Size=UDim2.new(0,90,0,30),
        Position=UDim2.new(1,-96,0.5,-15),BackgroundTransparency=1,
        ZIndex=Z.TitleText,Parent=titleBar})
    local ctrlList=Instance.new("UIListLayout")
    ctrlList.FillDirection=Enum.FillDirection.Horizontal
    ctrlList.SortOrder=Enum.SortOrder.LayoutOrder
    ctrlList.Padding=UDim.new(0,4)
    ctrlList.VerticalAlignment=Enum.VerticalAlignment.Center
    ctrlList.Parent=ctrlFrame

    local function CtrlBtn(icon, col)
        local btn=Create("TextButton",{Size=UDim2.new(0,26,0,26),
            BackgroundColor3=theme.TertiaryBg,Text=icon,
            TextColor3=col or theme.SubText,TextSize=12,Font=theme.FontBold,
            BorderSizePixel=0,ZIndex=Z.TitleText+1,Parent=ctrlFrame})
        Corner(btn,UDim.new(0,5))
        btn.MouseEnter:Connect(function() Tween(btn,{BackgroundColor3=theme.SecondaryBg},0.12) end)
        btn.MouseLeave:Connect(function() Tween(btn,{BackgroundColor3=theme.TertiaryBg},0.12) end)
        return btn
    end

    -- Floating icon shown when minimized
    local minimizeIcon=Create("TextButton",{Name="MinimizeIcon",
        Size=UDim2.new(0,52,0,52),Position=UDim2.new(0,16,0.5,-26),
        BackgroundColor3=theme.Accent,Text=title:sub(1,2):upper(),
        TextColor3=Color3.fromRGB(255,255,255),TextSize=16,Font=theme.FontBold,
        BorderSizePixel=0,Visible=false,ZIndex=Z.MinimizeIcon,Parent=self.ScreenGui})
    Corner(minimizeIcon,UDim.new(1,0))
    Stroke(minimizeIcon,theme.AccentDark,2)
    MakeDraggable(minimizeIcon)  -- now works because handle≠child button

    local function PulseIcon()
        task.spawn(function()
            while minimizeIcon.Visible do
                Tween(minimizeIcon,{BackgroundColor3=theme.AccentHover},0.8); task.wait(0.8)
                Tween(minimizeIcon,{BackgroundColor3=theme.Accent},0.8); task.wait(0.8)
            end
        end)
    end

    local visible=false; local minimized=false; local fullscreen=false

    local function DoShow(w,h)
        window.Visible=true; visible=true
        window.Size=UDim2.new(0,w or WIN_W,0,0)
        Tween(window,{Size=UDim2.new(0,w or WIN_W,0,h or WIN_H)},0.3,Enum.EasingStyle.Quart)
    end
    local function DoHide()
        Tween(window,{Size=UDim2.new(0,WIN_W,0,0),BackgroundTransparency=1},0.25)
        task.wait(0.28); window.Visible=false; window.BackgroundTransparency=0
    end

    -- □ Fullscreen toggle
    local btnFull=CtrlBtn("□", theme.Info)
    btnFull.MouseButton1Click:Connect(function()
        if fullscreen then
            fullscreen=false
            Tween(window,{Size=UDim2.new(0,WIN_W,0,WIN_H)},0.3,Enum.EasingStyle.Quart)
        else
            fullscreen=true
            local vp=workspace.CurrentCamera.ViewportSize
            window.Position=UDim2.new(0,10,0,10)
            Tween(window,{Size=UDim2.new(0,vp.X-20,0,vp.Y-20)},0.3,Enum.EasingStyle.Quart)
        end
    end)

    -- − Minimize to icon
    local btnMin=CtrlBtn("−", theme.Warning)
    btnMin.MouseButton1Click:Connect(function()
        minimized=true; visible=false; DoHide()
        minimizeIcon.Visible=true; PulseIcon()
    end)

    -- × Close
    local btnClose=CtrlBtn("×", theme.Error)
    btnClose.MouseButton1Click:Connect(function()
        minimized=false; visible=false
        minimizeIcon.Visible=false; DoHide()
    end)

    minimizeIcon.MouseButton1Click:Connect(function()
        minimized=false; minimizeIcon.Visible=false; DoShow()
    end)

    -- Drag from titlebar only (not ctrl buttons)
    MakeDraggable(window, titleBar)

    -- Content area
    local contentHolder=Create("Frame",{Name="ContentHolder",
        Size=UDim2.new(1,-SIDEBAR_W,1,-48),Position=UDim2.new(0,SIDEBAR_W,0,48),
        BackgroundTransparency=1,ClipsDescendants=true,
        ZIndex=Z.Content,Parent=window})

    MakeResizable(window,340,280,function(nW,nH) WIN_W=nW; WIN_H=nH end)

    -- Keyboard toggle
    UserInputService.InputBegan:Connect(function(input,gpe)
        if gpe then return end
        if input.KeyCode==toggleKey then
            if minimized then
                minimized=false; minimizeIcon.Visible=false; DoShow()
            else
                visible=not visible
                if visible then DoShow() else window.Visible=false end
            end
        end
    end)

    -- Mobile button
    if showMobile then
        local mobileBtn=Create("TextButton",{Name="MobileToggle",
            Size=UDim2.new(0,52,0,52),
            Position=IsMobile() and UDim2.new(0,10,0.5,-26) or UDim2.new(0,10,1,-62),
            BackgroundColor3=theme.Accent,Text="☰",
            TextColor3=Color3.fromRGB(255,255,255),TextSize=22,Font=theme.FontBold,
            BorderSizePixel=0,ZIndex=Z.MobileBtn,Parent=self.ScreenGui})
        Corner(mobileBtn,UDim.new(1,0))
        MakeDraggable(mobileBtn)
        mobileBtn.MouseButton1Click:Connect(function()
            if minimized then
                minimized=false; minimizeIcon.Visible=false; DoShow()
            else
                visible=not visible
                if visible then DoShow() else window.Visible=false end
            end
        end)
    end

    local windowObj={
        Frame=window,Sidebar=sidebar,TabIcons=tabIconContainer,
        ContentHolder=contentHolder,Theme=theme,Tabs={},
        ActiveTab=nil,Config=self.Config,Library=self,_visible=false,
    }

    if intro then PlayIntro(self.ScreenGui,config,theme,function() DoShow() end)
    else DoShow() end

    -- ============================================================
    -- CREATE TAB
    -- ============================================================
    function windowObj:CreateTab(tabConfig)
        tabConfig=tabConfig or {}
        local tabName=tabConfig.Name or "Tab"
        local tabIcon=tabConfig.Icon or "◆"
        local isImage=tonumber(tabIcon)~=nil  -- numeric = rbxassetid

        local iconBtn=Create("TextButton",{Name=tabName,
            Size=UDim2.new(0,36,0,36),BackgroundColor3=theme.SidebarInactive,
            Text=isImage and "" or tostring(tabIcon),
            TextColor3=theme.SubText,TextSize=IsMobile() and 16 or 14,
            Font=theme.Font,BorderSizePixel=0,
            ZIndex=Z.SidebarChild,Parent=tabIconContainer})
        Corner(iconBtn,UDim.new(0,8))

        -- Image icon for numeric asset IDs
        if isImage then
            Create("ImageLabel",{Size=UDim2.new(0,22,0,22),
                Position=UDim2.new(0.5,-11,0.5,-11),BackgroundTransparency=1,
                Image="rbxassetid://"..tostring(tabIcon),
                ImageColor3=theme.SubText,ZIndex=Z.SidebarChild+1,Parent=iconBtn})
        end

        local tooltip=Create("TextLabel",{Size=UDim2.new(0,0,0,24),
            Position=UDim2.new(1,6,0.5,-12),BackgroundColor3=theme.TertiaryBg,
            Text=" "..tabName.." ",TextColor3=theme.Text,TextSize=11,Font=theme.Font,
            AutomaticSize=Enum.AutomaticSize.X,Visible=false,
            ZIndex=Z.Tooltip,Parent=iconBtn})
        Corner(tooltip,UDim.new(0,5)); Stroke(tooltip,theme.Border,1)
        iconBtn.MouseEnter:Connect(function() tooltip.Visible=true  end)
        iconBtn.MouseLeave:Connect(function() tooltip.Visible=false end)

        local indicator=Create("Frame",{Size=UDim2.new(0,3,0,18),
            Position=UDim2.new(0,-3,0.5,-9),BackgroundColor3=theme.Accent,
            BorderSizePixel=0,Visible=false,ZIndex=Z.SidebarChild,Parent=iconBtn})
        Corner(indicator,UDim.new(1,0))

        local content=Create("ScrollingFrame",{Name=tabName.."_Content",
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,
            ScrollBarThickness=3,ScrollBarImageColor3=theme.Accent,
            ScrollBarImageTransparency=0.4,CanvasSize=UDim2.new(0,0,0,0),
            Visible=false,ZIndex=Z.Content,Parent=contentHolder})
        local cLayout=ListLayout(content,6)
        Padding(content,10,10,12,12)
        cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize=UDim2.new(0,0,0,cLayout.AbsoluteContentSize.Y+20)
        end)

        local tabObj={Button=iconBtn,Indicator=indicator,Content=content,
            Theme=theme,Window=windowObj,Config=self.Config,_id=tabName}

        iconBtn.MouseButton1Click:Connect(function() windowObj:_SelectTab(tabObj) end)
        table.insert(windowObj.Tabs,tabObj)
        if #windowObj.Tabs==1 then windowObj:_SelectTab(tabObj) end

        -- ── SECTION
        function tabObj:CreateSection(cfg)
            cfg=cfg or {}; local name=type(cfg)=="string" and cfg or (cfg.Name or "Section")
            local sec=Create("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,
                ZIndex=Z.ContentItem,Parent=content})
            Create("TextLabel",{Size=UDim2.new(0.5,0,1,0),BackgroundTransparency=1,
                Text=string.upper(name),TextColor3=theme.Accent,TextSize=10,Font=theme.FontBold,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=sec})
            Create("Frame",{Size=UDim2.new(0.48,0,0,1),Position=UDim2.new(0.52,0,0.5,0),
                BackgroundColor3=theme.Border,BorderSizePixel=0,ZIndex=Z.ContentItem,Parent=sec})
        end

        -- ── BUTTON  (cfg.ButtonText = custom action label)
        function tabObj:CreateButton(cfg)
            cfg=cfg or {}
            local name=cfg.Name or "Button"; local desc=cfg.Description or ""
            local callback=cfg.Callback or function() end
            local btnText=cfg.ButtonText or "Execute"
            local h=desc~="" and 54 or 38
            local frame=Create("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=theme.SecondaryBg,
                BorderSizePixel=0,ZIndex=Z.ContentItem,Parent=content})
            Corner(frame,theme.CornerRadius); Stroke(frame,theme.Border,1)
            Padding(frame,0,0,14,14)
            Create("TextLabel",{Size=UDim2.new(1,-98,0,20),
                Position=UDim2.new(0,0,0,desc~="" and 8 or 9),
                BackgroundTransparency=1,Text=name,TextColor3=theme.Text,
                TextSize=theme.FontSize,Font=theme.Font,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=frame})
            if desc~="" then
                Create("TextLabel",{Size=UDim2.new(1,-98,0,16),Position=UDim2.new(0,0,0,30),
                    BackgroundTransparency=1,Text=desc,TextColor3=theme.SubText,
                    TextSize=11,Font=theme.Font,
                    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=frame})
            end
            local btn=Create("TextButton",{Size=UDim2.new(0,82,0,28),
                Position=UDim2.new(1,-82,0.5,-14),BackgroundColor3=theme.Accent,
                Text=btnText,TextColor3=Color3.fromRGB(255,255,255),
                TextSize=11,Font=theme.FontBold,BorderSizePixel=0,
                ZIndex=Z.ContentCtrl,Parent=frame})
            Corner(btn,UDim.new(0,7))
            btn.MouseEnter:Connect(function() Tween(btn,{BackgroundColor3=theme.AccentHover},0.15) end)
            btn.MouseLeave:Connect(function() Tween(btn,{BackgroundColor3=theme.Accent},0.15) end)
            btn.MouseButton1Click:Connect(function()
                self.Library._totalExecutions=self.Library._totalExecutions+1
                Tween(btn,{BackgroundColor3=theme.AccentDark},0.08); task.wait(0.08)
                Tween(btn,{BackgroundColor3=theme.Accent},0.15); task.spawn(callback)
            end)
        end

        -- ── TOGGLE
        function tabObj:CreateToggle(cfg)
            cfg=cfg or {}
            local name=cfg.Name or "Toggle"; local desc=cfg.Description or ""
            local default=cfg.Default or false; local configKey=cfg.ConfigKey
            local callback=cfg.Callback or function() end; local state=default
            local h=desc~="" and 54 or 38
            local frame=Create("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=theme.SecondaryBg,
                BorderSizePixel=0,ZIndex=Z.ContentItem,Parent=content})
            Corner(frame,theme.CornerRadius); Stroke(frame,theme.Border,1); Padding(frame,0,0,14,14)
            Create("TextLabel",{Size=UDim2.new(1,-60,0,20),
                Position=UDim2.new(0,0,0,desc~="" and 8 or 9),
                BackgroundTransparency=1,Text=name,TextColor3=theme.Text,
                TextSize=theme.FontSize,Font=theme.Font,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=frame})
            if desc~="" then
                Create("TextLabel",{Size=UDim2.new(1,-60,0,16),Position=UDim2.new(0,0,0,30),
                    BackgroundTransparency=1,Text=desc,TextColor3=theme.SubText,TextSize=11,
                    Font=theme.Font,TextXAlignment=Enum.TextXAlignment.Left,
                    ZIndex=Z.ContentText,Parent=frame})
            end
            local switchBG=Create("Frame",{Size=UDim2.new(0,44,0,24),
                Position=UDim2.new(1,-44,0.5,-12),
                BackgroundColor3=state and theme.Toggle_On or theme.Toggle_Off,
                BorderSizePixel=0,ZIndex=Z.ContentCtrl,Parent=frame})
            Corner(switchBG,UDim.new(1,0))
            local knob=Create("Frame",{Size=UDim2.new(0,18,0,18),
                Position=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
                BackgroundColor3=Color3.fromRGB(255,255,255),
                BorderSizePixel=0,ZIndex=Z.ContentKnob,Parent=switchBG})
            Corner(knob,UDim.new(1,0))
            local hitbox=Create("TextButton",{Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=1,Text="",ZIndex=Z.ContentHit,Parent=frame})
            local obj={}
            local function Refresh()
                Tween(switchBG,{BackgroundColor3=state and theme.Toggle_On or theme.Toggle_Off},0.2)
                Tween(knob,{Position=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.2)
            end
            Refresh()
            hitbox.MouseButton1Click:Connect(function() state=not state; Refresh(); task.spawn(callback,state) end)
            function obj:Set(v) state=v; Refresh(); task.spawn(callback,state) end
            function obj:Get() return state end
            if configKey then self.Config:Register(configKey,obj) end
            return obj
        end

        -- ── SLIDER
        function tabObj:CreateSlider(cfg)
            cfg=cfg or {}
            local name=cfg.Name or "Slider"; local min=cfg.Min or 0; local max=cfg.Max or 100
            local default=cfg.Default or min; local suffix=cfg.Suffix or ""
            local decimals=cfg.Decimals or 0; local configKey=cfg.ConfigKey
            local callback=cfg.Callback or function() end
            local value=math.clamp(default,min,max)
            local frame=Create("Frame",{Size=UDim2.new(1,0,0,54),BackgroundColor3=theme.SecondaryBg,
                BorderSizePixel=0,ZIndex=Z.ContentItem,Parent=content})
            Corner(frame,theme.CornerRadius); Stroke(frame,theme.Border,1); Padding(frame,0,0,14,14)
            Create("TextLabel",{Size=UDim2.new(0.6,0,0,20),Position=UDim2.new(0,0,0,8),
                BackgroundTransparency=1,Text=name,TextColor3=theme.Text,
                TextSize=theme.FontSize,Font=theme.Font,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=frame})
            local valLabel=Create("TextLabel",{Size=UDim2.new(0.4,0,0,20),Position=UDim2.new(0.6,0,0,8),
                BackgroundTransparency=1,Text=tostring(value)..suffix,
                TextColor3=theme.Accent,TextSize=theme.FontSize,Font=theme.FontBold,
                TextXAlignment=Enum.TextXAlignment.Right,ZIndex=Z.ContentText,Parent=frame})
            local trackBG=Create("Frame",{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,1,-18),
                BackgroundColor3=theme.Slider_BG,BorderSizePixel=0,ZIndex=Z.ContentCtrl,Parent=frame})
            Corner(trackBG,UDim.new(1,0))
            local pct0=(value-min)/(max-min)
            local trackFill=Create("Frame",{Size=UDim2.new(pct0,0,1,0),BackgroundColor3=theme.Slider_Fill,
                BorderSizePixel=0,ZIndex=Z.ContentKnob,Parent=trackBG})
            Corner(trackFill,UDim.new(1,0))
            local thumb=Create("Frame",{Size=UDim2.new(0,14,0,14),AnchorPoint=Vector2.new(0.5,0.5),
                Position=UDim2.new(pct0,0,0.5,0),BackgroundColor3=Color3.fromRGB(255,255,255),
                BorderSizePixel=0,ZIndex=Z.ContentKnob+1,Parent=trackBG})
            Corner(thumb,UDim.new(1,0))
            local dragging=false
            local function UpdateSlider(ix)
                local pct=math.clamp((ix-trackBG.AbsolutePosition.X)/trackBG.AbsoluteSize.X,0,1)
                local raw=min+(max-min)*pct; local mult=10^decimals
                value=math.floor(raw*mult+0.5)/mult
                valLabel.Text=tostring(value)..suffix
                Tween(trackFill,{Size=UDim2.new(pct,0,1,0)},0.04)
                Tween(thumb,{Position=UDim2.new(pct,0,0.5,0)},0.04)
                task.spawn(callback,value)
            end
            local sliderHit=Create("TextButton",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,1,-22),
                BackgroundTransparency=1,Text="",ZIndex=Z.ContentHit,Parent=frame})
            local function beginDrag(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1
                or i.UserInputType==Enum.UserInputType.Touch then
                    dragging=true; UpdateSlider(i.Position.X) end
            end
            sliderHit.InputBegan:Connect(beginDrag); trackBG.InputBegan:Connect(beginDrag)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1
                or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
                or i.UserInputType==Enum.UserInputType.Touch) then UpdateSlider(i.Position.X) end
            end)
            local obj={}
            function obj:Set(v)
                value=math.clamp(v,min,max); local pct=(value-min)/(max-min)
                valLabel.Text=tostring(value)..suffix
                Tween(trackFill,{Size=UDim2.new(pct,0,1,0)},0.1)
                Tween(thumb,{Position=UDim2.new(pct,0,0.5,0)},0.1)
                task.spawn(callback,value)
            end
            function obj:Get() return value end
            if configKey then self.Config:Register(configKey,obj) end
            return obj
        end

        -- ── DROPDOWN
        function tabObj:CreateDropdown(cfg)
            cfg=cfg or {}
            local name=cfg.Name or "Dropdown"; local options=cfg.Options or {}
            local default=cfg.Default or (options[1] or "None")
            local multiSel=cfg.MultiSelect or false; local configKey=cfg.ConfigKey
            local callback=cfg.Callback or function() end
            local selected=default; local multiSelected={}; local open=false
            local frame=Create("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=theme.SecondaryBg,
                BorderSizePixel=0,ClipsDescendants=false,ZIndex=Z.ContentItem,Parent=content})
            Corner(frame,theme.CornerRadius); Stroke(frame,theme.Border,1); Padding(frame,0,0,14,14)
            Create("TextLabel",{Size=UDim2.new(0.5,0,1,0),BackgroundTransparency=1,
                Text=name,TextColor3=theme.Text,TextSize=theme.FontSize,Font=theme.Font,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=frame})
            local selLabel=Create("TextLabel",{Size=UDim2.new(0.5,-24,1,0),Position=UDim2.new(0.5,0,0,0),
                BackgroundTransparency=1,Text=selected,TextColor3=theme.Accent,TextSize=11,Font=theme.Font,
                TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=Enum.TextTruncate.AtEnd,
                ZIndex=Z.ContentText,Parent=frame})
            local arrowLabel=Create("TextLabel",{Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-18,0,0),
                BackgroundTransparency=1,Text="▾",TextColor3=theme.SubText,TextSize=13,Font=theme.Font,
                ZIndex=Z.ContentText,Parent=frame})
            local listH=math.min(#options,6)*30+8
            local ddList=Create("Frame",{Size=UDim2.new(1,0,0,listH),Position=UDim2.new(0,0,1,4),
                BackgroundColor3=theme.TertiaryBg,BorderSizePixel=0,Visible=false,
                ZIndex=Z.Dropdown,ClipsDescendants=true,Parent=frame})
            Corner(ddList,UDim.new(0,8)); Stroke(ddList,theme.Border,1)
            Padding(ddList,4,4,4,4); ListLayout(ddList,2)
            local function BuildOptions()
                for _,c in pairs(ddList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                for _,opt in ipairs(options) do
                    local isSel=multiSel and table.find(multiSelected,opt) or opt==selected
                    local optBtn=Create("TextButton",{Size=UDim2.new(1,0,0,28),
                        BackgroundColor3=isSel and theme.AccentDark or theme.TertiaryBg,
                        Text=(multiSel and isSel and "✓ " or "  ")..opt,
                        TextColor3=isSel and theme.Text or theme.SubText,
                        TextSize=12,Font=theme.Font,TextXAlignment=Enum.TextXAlignment.Left,
                        BorderSizePixel=0,ZIndex=Z.DropdownItem,Parent=ddList})
                    Corner(optBtn,UDim.new(0,6)); Padding(optBtn,0,0,8,0)
                    optBtn.MouseEnter:Connect(function()
                        if not(multiSel and table.find(multiSelected,opt) or opt==selected) then
                            Tween(optBtn,{BackgroundColor3=theme.SecondaryBg},0.1) end
                    end)
                    optBtn.MouseLeave:Connect(function()
                        local sel=multiSel and table.find(multiSelected,opt) or opt==selected
                        Tween(optBtn,{BackgroundColor3=sel and theme.AccentDark or theme.TertiaryBg},0.1)
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        if multiSel then
                            local idx=table.find(multiSelected,opt)
                            if idx then table.remove(multiSelected,idx) else table.insert(multiSelected,opt) end
                            selLabel.Text=#multiSelected==0 and "None" or table.concat(multiSelected,", ")
                            task.spawn(callback,multiSelected)
                        else
                            selected=opt; selLabel.Text=selected; open=false; ddList.Visible=false
                            Tween(arrowLabel,{Rotation=0},0.15); task.spawn(callback,selected)
                        end
                        BuildOptions()
                    end)
                end
            end
            BuildOptions()
            Create("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",
                ZIndex=Z.ContentHit,Parent=frame}).MouseButton1Click:Connect(function()
                open=not open; ddList.Visible=open
                Tween(arrowLabel,{Rotation=open and 180 or 0},0.15)
            end)
            local obj={}
            function obj:Set(v)
                if multiSel then multiSelected=type(v)=="table" and v or {v}
                    selLabel.Text=#multiSelected==0 and "None" or table.concat(multiSelected,", ")
                else selected=v; selLabel.Text=v end
                BuildOptions(); task.spawn(callback,multiSel and multiSelected or selected)
            end
            function obj:Get() return multiSel and multiSelected or selected end
            function obj:Refresh(newOpts)
                options=newOpts; listH=math.min(#options,6)*30+8
                ddList.Size=UDim2.new(1,0,0,listH); BuildOptions()
            end
            if configKey then self.Config:Register(configKey,obj) end
            return obj
        end

        -- ── TEXTBOX
        function tabObj:CreateTextbox(cfg)
            cfg=cfg or {}
            local name=cfg.Name or "Textbox"; local placeholder=cfg.Placeholder or "Enter text..."
            local default=cfg.Default or ""; local configKey=cfg.ConfigKey
            local callback=cfg.Callback or function() end
            local clearOnFocus=cfg.ClearOnFocus~=false
            local frame=Create("Frame",{Size=UDim2.new(1,0,0,54),BackgroundColor3=theme.SecondaryBg,
                BorderSizePixel=0,ZIndex=Z.ContentItem,Parent=content})
            Corner(frame,theme.CornerRadius); Stroke(frame,theme.Border,1); Padding(frame,0,0,14,14)
            Create("TextLabel",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,6),
                BackgroundTransparency=1,Text=name,TextColor3=theme.Text,
                TextSize=theme.FontSize,Font=theme.Font,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=frame})
            local inputBG=Create("Frame",{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,1,-26),
                BackgroundColor3=theme.Background,BorderSizePixel=0,ZIndex=Z.ContentCtrl,Parent=frame})
            Corner(inputBG,UDim.new(0,6))
            local inputStroke=Stroke(inputBG,theme.Border,1)
            local tb=Create("TextBox",{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,6,0,0),
                BackgroundTransparency=1,Text=default,PlaceholderText=placeholder,
                PlaceholderColor3=theme.Muted,TextColor3=theme.Text,TextSize=12,Font=theme.Font,
                TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=clearOnFocus,
                ZIndex=Z.ContentKnob,Parent=inputBG})
            tb.Focused:Connect(function() Tween(inputStroke,{Color=theme.Accent},0.15) end)
            tb.FocusLost:Connect(function(e) Tween(inputStroke,{Color=theme.Border},0.15)
                task.spawn(callback,tb.Text,e) end)
            local obj={}
            function obj:Set(v) tb.Text=v end; function obj:Get() return tb.Text end
            if configKey then self.Config:Register(configKey,obj) end
            return obj
        end

        -- ── KEYBIND
        function tabObj:CreateKeybind(cfg)
            cfg=cfg or {}
            local name=cfg.Name or "Keybind"; local default=cfg.Default or Enum.KeyCode.RightShift
            local configKey=cfg.ConfigKey; local callback=cfg.Callback or function() end
            local binding=default; local listening=false
            local frame=Create("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=theme.SecondaryBg,
                BorderSizePixel=0,ZIndex=Z.ContentItem,Parent=content})
            Corner(frame,theme.CornerRadius); Stroke(frame,theme.Border,1); Padding(frame,0,0,14,14)
            Create("TextLabel",{Size=UDim2.new(0.6,0,1,0),BackgroundTransparency=1,
                Text=name,TextColor3=theme.Text,TextSize=theme.FontSize,Font=theme.Font,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=frame})
            local keyBtn=Create("TextButton",{Size=UDim2.new(0,86,0,26),Position=UDim2.new(1,-86,0.5,-13),
                BackgroundColor3=theme.TertiaryBg,Text="[ "..binding.Name.." ]",
                TextColor3=theme.Accent,TextSize=11,Font=theme.FontBold,
                BorderSizePixel=0,ZIndex=Z.ContentCtrl,Parent=frame})
            Corner(keyBtn,UDim.new(0,6)); Stroke(keyBtn,theme.Border,1)
            keyBtn.MouseButton1Click:Connect(function()
                listening=true; keyBtn.Text="[ ... ]"; keyBtn.TextColor3=theme.SubText end)
            UserInputService.InputBegan:Connect(function(input,gpe)
                if listening and input.UserInputType==Enum.UserInputType.Keyboard then
                    binding=input.KeyCode; keyBtn.Text="[ "..binding.Name.." ]"
                    keyBtn.TextColor3=theme.Accent; listening=false
                elseif not listening and not gpe and input.KeyCode==binding then
                    task.spawn(callback)
                end
            end)
            local obj={}
            function obj:Set(k) binding=k; keyBtn.Text="[ "..k.Name.." ]" end
            function obj:Get() return binding end
            if configKey then self.Config:Register(configKey,obj) end
            return obj
        end

        -- ── LABEL
        function tabObj:CreateLabel(text, labelColor)
            local lbl=Create("TextLabel",{Size=UDim2.new(1,0,0,30),BackgroundColor3=theme.SecondaryBg,
                Text="  "..(text or ""),TextColor3=labelColor or theme.SubText,
                TextSize=12,Font=theme.Font,TextXAlignment=Enum.TextXAlignment.Left,
                BorderSizePixel=0,ZIndex=Z.ContentText,Parent=content})
            Corner(lbl,theme.CornerRadius); Stroke(lbl,theme.Border,1)
            local obj={}
            function obj:Set(v) lbl.Text="  "..v end; function obj:Get() return lbl.Text:sub(3) end
            return obj
        end

        -- ── COLOR PICKER
        function tabObj:CreateColorPicker(cfg)
            cfg=cfg or {}
            local name=cfg.Name or "Color"; local default=cfg.Default or Color3.fromRGB(255,100,100)
            local configKey=cfg.ConfigKey; local callback=cfg.Callback or function() end
            local color=default; local open=false
            local frame=Create("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=theme.SecondaryBg,
                BorderSizePixel=0,ZIndex=Z.ContentItem,Parent=content})
            Corner(frame,theme.CornerRadius); Stroke(frame,theme.Border,1); Padding(frame,0,0,14,14)
            Create("TextLabel",{Size=UDim2.new(1,-50,1,0),BackgroundTransparency=1,
                Text=name,TextColor3=theme.Text,TextSize=theme.FontSize,Font=theme.Font,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=frame})
            local preview=Create("Frame",{Size=UDim2.new(0,28,0,20),Position=UDim2.new(1,-28,0.5,-10),
                BackgroundColor3=color,BorderSizePixel=0,ZIndex=Z.ContentCtrl,Parent=frame})
            Corner(preview,UDim.new(0,5)); Stroke(preview,theme.Border,1)
            local panel=Create("Frame",{Size=UDim2.new(1,0,0,90),Position=UDim2.new(0,0,1,4),
                BackgroundColor3=theme.TertiaryBg,BorderSizePixel=0,Visible=false,
                ZIndex=Z.ColorPanel,Parent=frame})
            Corner(panel,UDim.new(0,8)); Stroke(panel,theme.Border,1)
            Padding(panel,6,6,10,10); ListLayout(panel,4)
            local function RGBRow(channel,val)
                local row=Create("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,
                    ZIndex=Z.ColorPanel+1,Parent=panel})
                Create("TextLabel",{Size=UDim2.new(0,16,1,0),BackgroundTransparency=1,
                    Text=channel,TextColor3=theme.SubText,TextSize=11,Font=theme.FontBold,
                    ZIndex=Z.ColorPanel+1,Parent=row})
                local trackBG=Create("Frame",{Size=UDim2.new(1,-60,0,6),Position=UDim2.new(0,20,0.5,-3),
                    BackgroundColor3=theme.Slider_BG,BorderSizePixel=0,ZIndex=Z.ColorPanel+1,Parent=row})
                Corner(trackBG,UDim.new(1,0))
                local pct=val/255
                local fill=Create("Frame",{Size=UDim2.new(pct,0,1,0),BorderSizePixel=0,
                    BackgroundColor3=channel=="R" and Color3.fromRGB(220,60,60)
                                    or channel=="G" and Color3.fromRGB(60,200,60)
                                    or Color3.fromRGB(60,60,220),
                    ZIndex=Z.ColorPanel+2,Parent=trackBG})
                Corner(fill,UDim.new(1,0))
                local numLabel=Create("TextLabel",{Size=UDim2.new(0,36,1,0),Position=UDim2.new(1,-36,0,0),
                    BackgroundTransparency=1,Text=tostring(math.floor(val)),
                    TextColor3=theme.Text,TextSize=11,Font=theme.Font,
                    ZIndex=Z.ColorPanel+1,Parent=row})
                return trackBG,fill,numLabel
            end
            local r,g,b=color.R*255,color.G*255,color.B*255
            local rT,rF,rN=RGBRow("R",r); local gT,gF,gN=RGBRow("G",g); local bT,bF,bN=RGBRow("B",b)
            local function MkSlider(track,fill,numLabel,chGet,chSet)
                local drag=false
                track.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1
                    or i.UserInputType==Enum.UserInputType.Touch then drag=true end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement
                    or i.UserInputType==Enum.UserInputType.Touch) then
                        local pct=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                        chSet(math.floor(pct*255)); fill.Size=UDim2.new(pct,0,1,0)
                        numLabel.Text=tostring(math.floor(pct*255))
                        color=Color3.fromRGB(r,g,b); preview.BackgroundColor3=color
                        task.spawn(callback,color)
                    end
                end)
            end
            MkSlider(rT,rF,rN,function() return r end,function(v) r=v end)
            MkSlider(gT,gF,gN,function() return g end,function(v) g=v end)
            MkSlider(bT,bF,bN,function() return b end,function(v) b=v end)
            Create("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text="",ZIndex=Z.ContentHit,Parent=frame}).MouseButton1Click:Connect(function()
                open=not open; panel.Visible=open end)
            local obj={}
            function obj:Set(c)
                color=c; r,g,b=c.R*255,c.G*255,c.B*255
                preview.BackgroundColor3=color; task.spawn(callback,color)
            end
            function obj:Get() return color end
            if configKey then self.Config:Register(configKey,obj) end
            return obj
        end

        -- ── CONFIG SECTION
        function tabObj:CreateConfigSection()
            self:CreateSection("Config")
            local configs=windowObj.Config:ListConfigs()
            local configDD=self:CreateDropdown({Name="Load Config",
                Options=#configs>0 and configs or {"No configs"},Callback=function() end})
            local configInput=self:CreateTextbox({Name="Config Name",Placeholder="my_config",Default="default"})
            self:CreateButton({Name="Save Config",ButtonText="Save",Callback=function()
                local name=configInput:Get()
                if name and name~="" then
                    windowObj.Config:Save(name); configDD:Refresh(windowObj.Config:ListConfigs())
                    windowObj.Library:Notify({Title="Saved",Message='"'..name..'"',Type="Success",Duration=3})
                end
            end})
            self:CreateButton({Name="Load Config",ButtonText="Load",Callback=function()
                local name=configDD:Get()
                if name and name~="No configs" then
                    windowObj.Config:Load(name)
                    windowObj.Library:Notify({Title="Loaded",Message='"'..name..'"',Type="Info",Duration=3})
                end
            end})
        end

        return tabObj
    end

    -- ============================================================
    -- INFO TAB
    -- ============================================================
    function windowObj:CreateInfoTab(tabConfig)
        tabConfig=tabConfig or {}
        tabConfig.Name=tabConfig.Name or "Info"
        tabConfig.Icon=tabConfig.Icon or "👤"

        local infoTab=self:CreateTab(tabConfig)
        local lib=self.Library

        infoTab:CreateSection("Player")

        -- ── Player card: avatar + name + FPS + Ping
        local playerCard=Create("Frame",{Size=UDim2.new(1,0,0,82),
            BackgroundColor3=theme.SecondaryBg,BorderSizePixel=0,
            ZIndex=Z.ContentItem,Parent=infoTab.Content})
        Corner(playerCard,theme.CornerRadius); Stroke(playerCard,theme.Border,1)
        Padding(playerCard,0,0,14,14)

        -- Avatar
        local avatarImg=Create("ImageLabel",{Size=UDim2.new(0,56,0,56),
            Position=UDim2.new(0,0,0.5,-28),BackgroundColor3=theme.TertiaryBg,
            BackgroundTransparency=0,Image="",
            ZIndex=Z.ContentCtrl,Parent=playerCard})
        Corner(avatarImg,UDim.new(1,0))
        task.spawn(function()
            local ok,img=pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId,
                    Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
            end)
            if ok then avatarImg.Image=img end
        end)

        -- Right column
        local rightCol=Create("Frame",{Size=UDim2.new(1,-70,1,0),Position=UDim2.new(0,68,0,0),
            BackgroundTransparency=1,ZIndex=Z.ContentItem,Parent=playerCard})
        Create("TextLabel",{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,8),
            BackgroundTransparency=1,Text=LocalPlayer.DisplayName,
            TextColor3=theme.Text,TextSize=15,Font=theme.FontBold,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=rightCol})
        Create("TextLabel",{Size=UDim2.new(1,0,0,15),Position=UDim2.new(0,0,0,32),
            BackgroundTransparency=1,Text="@"..LocalPlayer.Name,
            TextColor3=theme.SubText,TextSize=11,Font=theme.Font,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=rightCol})

        -- FPS and Ping side by side
        local fpsLabel=Create("TextLabel",{Size=UDim2.new(0,62,0,16),Position=UDim2.new(0,0,1,-20),
            BackgroundTransparency=1,Text="FPS: --",TextColor3=theme.Success,
            TextSize=11,Font=theme.FontBold,TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=Z.ContentText,Parent=rightCol})
        local pingLabel=Create("TextLabel",{Size=UDim2.new(0,80,0,16),Position=UDim2.new(0,64,1,-20),
            BackgroundTransparency=1,Text="Ping: --ms",TextColor3=theme.Info,
            TextSize=11,Font=theme.FontBold,TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=Z.ContentText,Parent=rightCol})

        -- FPS counter
        local fpsCount=0; local lastFpsTick=tick()
        RunService.RenderStepped:Connect(function()
            fpsCount=fpsCount+1
            local now=tick()
            if now-lastFpsTick>=1 then
                local fps=fpsCount; fpsCount=0; lastFpsTick=now
                fpsLabel.TextColor3=fps>50 and theme.Success or fps>25 and theme.Warning or theme.Error
                fpsLabel.Text="FPS: "..fps
            end
        end)
        -- Ping
        RunService.Heartbeat:Connect(function()
            local ok,ping=pcall(function()
                return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            if ok then
                pingLabel.TextColor3=ping<80 and theme.Success or ping<150 and theme.Warning or theme.Error
                pingLabel.Text="Ping: "..ping.."ms"
            end
        end)

        infoTab:CreateSection("Session Stats")

        local function StatCard(label,getValue,accentColor)
            local card=Create("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=theme.SecondaryBg,
                BorderSizePixel=0,ZIndex=Z.ContentItem,Parent=infoTab.Content})
            Corner(card,theme.CornerRadius); Stroke(card,theme.Border,1); Padding(card,0,0,14,14)
            Create("Frame",{Size=UDim2.new(0,3,0.55,0),Position=UDim2.new(0,0,0.22,0),
                BackgroundColor3=accentColor or theme.Accent,BorderSizePixel=0,
                ZIndex=Z.ContentCtrl,Parent=card})
            Create("TextLabel",{Size=UDim2.new(0.55,0,1,0),Position=UDim2.new(0,10,0,0),
                BackgroundTransparency=1,Text=label,TextColor3=theme.SubText,TextSize=12,Font=theme.Font,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=card})
            local valLbl=Create("TextLabel",{Size=UDim2.new(0.45,0,1,0),Position=UDim2.new(0.55,0,0,0),
                BackgroundTransparency=1,Text=tostring(getValue()),
                TextColor3=accentColor or theme.Accent,TextSize=13,Font=theme.FontBold,
                TextXAlignment=Enum.TextXAlignment.Right,ZIndex=Z.ContentText,Parent=card})
            return valLbl
        end

        local execLbl=StatCard("Total Executions",function() return lib._totalExecutions end,theme.Success)
        local timeLbl=StatCard("Session Time",function() return "0s" end,theme.Info)
        -- Account age in days (not months/years)
        StatCard("Account Age",function() return LocalPlayer.AccountAge.." days" end,theme.Warning)
        StatCard("User ID",function() return tostring(LocalPlayer.UserId) end,theme.Accent)

        RunService.Heartbeat:Connect(function()
            if not infoTab.Content or not infoTab.Content.Parent then return end
            execLbl.Text=tostring(lib._totalExecutions)
            local el=os.time()-lib._sessionStart
            local h=math.floor(el/3600); local m=math.floor((el%3600)/60); local s=el%60
            timeLbl.Text=h>0 and (h.."h "..m.."m") or m>0 and (m.."m "..s.."s") or s.."s"
        end)

        infoTab:CreateSection("Script Info")

        local function InfoRow(label,value)
            local row=Create("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=theme.SecondaryBg,
                BorderSizePixel=0,ZIndex=Z.ContentItem,Parent=infoTab.Content})
            Corner(row,theme.CornerRadius); Stroke(row,theme.Border,1); Padding(row,0,0,14,14)
            Create("TextLabel",{Size=UDim2.new(0.42,0,1,0),BackgroundTransparency=1,
                Text=label,TextColor3=theme.SubText,TextSize=11,Font=theme.Font,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=Z.ContentText,Parent=row})
            Create("TextLabel",{Size=UDim2.new(0.58,0,1,0),Position=UDim2.new(0.42,0,0,0),
                BackgroundTransparency=1,Text=value,TextColor3=theme.Text,
                TextSize=11,Font=theme.FontBold,
                TextXAlignment=Enum.TextXAlignment.Right,ZIndex=Z.ContentText,Parent=row})
        end

        -- Game name as text string
        local gameName="Unknown"
        pcall(function()
            gameName=game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)

        InfoRow("Script",  lib.Config.ScriptName or "Unknown")
        InfoRow("Library", "NebulaUI v3")
        InfoRow("Game",    gameName)
        InfoRow("Place ID",tostring(game.PlaceId))

        return infoTab
    end

    -- Select tab  (update image icon brightness too)
    function windowObj:_SelectTab(tabObj)
        for _,t in pairs(self.Tabs) do
            t.Content.Visible=false
            Tween(t.Button,{BackgroundColor3=theme.SidebarInactive,TextColor3=theme.SubText},0.15)
            t.Indicator.Visible=false
            local img=t.Button:FindFirstChildOfClass("ImageLabel")
            if img then Tween(img,{ImageColor3=theme.SubText},0.15) end
        end
        tabObj.Content.Visible=true
        Tween(tabObj.Button,{BackgroundColor3=theme.SecondaryBg,TextColor3=theme.Text},0.15)
        tabObj.Indicator.Visible=true
        local img=tabObj.Button:FindFirstChildOfClass("ImageLabel")
        if img then Tween(img,{ImageColor3=theme.Text},0.15) end
        self.ActiveTab=tabObj
    end

    table.insert(self.Windows,windowObj)
    return windowObj
end

-- ============================================================
-- DESTROY
-- ============================================================
function NebulaUI:Destroy()
    if self.ScreenGui and self.ScreenGui.Parent then
        self.ScreenGui:Destroy()
    end
end

return NebulaUI
