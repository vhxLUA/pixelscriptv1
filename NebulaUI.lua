-- ============================================================
--   NebulaUI v2 — Roblox UI Library
--   Fixes: ZIndex layering, sidebar behind content,
--          mobile touch support, resizable window,
--          minimize to floating icon, Info tab API
-- ============================================================

local NebulaUI = {}
NebulaUI.__index = NebulaUI

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

-- ============================================================
-- THEMES
-- ============================================================
NebulaUI.Themes = {
    Nebula = {
        Background=Color3.fromRGB(14,14,20), SecondaryBg=Color3.fromRGB(20,20,30),
        TertiaryBg=Color3.fromRGB(27,27,40), Accent=Color3.fromRGB(130,90,255),
        AccentDark=Color3.fromRGB(90,60,180), AccentHover=Color3.fromRGB(150,110,255),
        Text=Color3.fromRGB(240,240,245), SubText=Color3.fromRGB(155,155,175),
        Muted=Color3.fromRGB(80,80,100), Border=Color3.fromRGB(38,38,55),
        Success=Color3.fromRGB(60,210,120), Warning=Color3.fromRGB(240,180,40),
        Error=Color3.fromRGB(225,65,65), Info=Color3.fromRGB(65,165,255),
        Toggle_On=Color3.fromRGB(130,90,255), Toggle_Off=Color3.fromRGB(50,50,68),
        Slider_Fill=Color3.fromRGB(130,90,255), Slider_BG=Color3.fromRGB(38,38,55),
        Sidebar=Color3.fromRGB(17,17,25), Font=Enum.Font.Gotham,
        FontBold=Enum.Font.GothamBold, FontSize=13, CornerRadius=UDim.new(0,9),
    },
    Ocean = {
        Background=Color3.fromRGB(10,18,28), SecondaryBg=Color3.fromRGB(14,24,38),
        TertiaryBg=Color3.fromRGB(18,30,48), Accent=Color3.fromRGB(40,160,255),
        AccentDark=Color3.fromRGB(20,110,200), AccentHover=Color3.fromRGB(70,180,255),
        Text=Color3.fromRGB(230,240,255), SubText=Color3.fromRGB(140,160,190),
        Muted=Color3.fromRGB(60,80,110), Border=Color3.fromRGB(28,45,68),
        Success=Color3.fromRGB(50,210,130), Warning=Color3.fromRGB(240,180,40),
        Error=Color3.fromRGB(220,65,65), Info=Color3.fromRGB(40,160,255),
        Toggle_On=Color3.fromRGB(40,160,255), Toggle_Off=Color3.fromRGB(30,50,75),
        Slider_Fill=Color3.fromRGB(40,160,255), Slider_BG=Color3.fromRGB(28,45,68),
        Sidebar=Color3.fromRGB(10,16,26), Font=Enum.Font.Gotham,
        FontBold=Enum.Font.GothamBold, FontSize=13, CornerRadius=UDim.new(0,9),
    },
    Crimson = {
        Background=Color3.fromRGB(18,12,14), SecondaryBg=Color3.fromRGB(26,16,20),
        TertiaryBg=Color3.fromRGB(34,20,26), Accent=Color3.fromRGB(220,55,85),
        AccentDark=Color3.fromRGB(160,35,60), AccentHover=Color3.fromRGB(240,75,105),
        Text=Color3.fromRGB(245,235,238), SubText=Color3.fromRGB(175,150,158),
        Muted=Color3.fromRGB(90,65,72), Border=Color3.fromRGB(50,30,38),
        Success=Color3.fromRGB(55,205,115), Warning=Color3.fromRGB(240,180,40),
        Error=Color3.fromRGB(220,55,85), Info=Color3.fromRGB(65,165,255),
        Toggle_On=Color3.fromRGB(220,55,85), Toggle_Off=Color3.fromRGB(55,30,38),
        Slider_Fill=Color3.fromRGB(220,55,85), Slider_BG=Color3.fromRGB(50,30,38),
        Sidebar=Color3.fromRGB(15,10,12), Font=Enum.Font.Gotham,
        FontBold=Enum.Font.GothamBold, FontSize=13, CornerRadius=UDim.new(0,9),
    },
}

-- ============================================================
-- UTILITIES
-- ============================================================
local function New(class, props)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    return o
end
local function Corner(p,r)  local c=Instance.new("UICorner"); c.CornerRadius=r or UDim.new(0,9); c.Parent=p; return c end
local function Stroke(p,col,t) local s=Instance.new("UIStroke"); s.Color=col or Color3.fromRGB(40,40,55); s.Thickness=t or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s end
local function Pad(p,t,b,l,r) local u=Instance.new("UIPadding"); u.PaddingTop=UDim.new(0,t or 6); u.PaddingBottom=UDim.new(0,b or 6); u.PaddingLeft=UDim.new(0,l or 10); u.PaddingRight=UDim.new(0,r or 10); u.Parent=p; return u end
local function List(p,gap,va,ha) local l=Instance.new("UIListLayout"); l.SortOrder=Enum.SortOrder.LayoutOrder; l.Padding=UDim.new(0,gap or 6); if va then l.VerticalAlignment=va end; if ha then l.HorizontalAlignment=ha end; l.Parent=p; return l end
local function Tw(o,props,t,s,d) TweenService:Create(o,TweenInfo.new(t or 0.2,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out),props):Play() end
local function Mobile() return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled end

-- ============================================================
-- DRAGGABLE  — titlebar only, skips interactive children
-- ============================================================
local function Drag(frame, handle)
    handle = handle or frame
    local on, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType~=Enum.UserInputType.MouseButton1 and i.UserInputType~=Enum.UserInputType.Touch then return end
        -- bail if clicking a button/textbox
        for _,obj in ipairs(game:GetService("GuiService"):GetGuiObjectsAtPosition(i.Position.X,i.Position.Y)) do
            if (obj:IsA("TextButton") or obj:IsA("ImageButton") or obj:IsA("TextBox")) and obj~=handle then return end
        end
        on=true; ds=i.Position; sp=frame.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then on=false end end)
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then on=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if on and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

-- ============================================================
-- RESIZABLE
-- ============================================================
local function Resize(frame, minW, minH)
    minW=minW or 400; minH=minH or 300
    local grip = New("TextButton",{
        Name="ResizeGrip", Size=UDim2.new(0,18,0,18),
        Position=UDim2.new(1,-18,1,-18), BackgroundTransparency=1,
        Text="⌟", TextColor3=Color3.fromRGB(100,100,120), TextSize=16,
        Font=Enum.Font.GothamBold, BorderSizePixel=0, ZIndex=50, Parent=frame,
    })
    local on,rs,ss=false,nil,nil
    grip.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            on=true; rs=i.Position; ss=frame.AbsoluteSize
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then on=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if on and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-rs
            frame.Size=UDim2.new(0,math.max(minW,ss.X+d.X),0,math.max(minH,ss.Y+d.Y))
        end
    end)
end

-- ============================================================
-- CONFIG
-- ============================================================
local Cfg={}; Cfg.__index=Cfg
function Cfg.new(name)
    local s=setmetatable({},Cfg); s.Name=name; s.Folder="NebulaConfigs/"..name; s.Els={}
    pcall(function() if not isfolder("NebulaConfigs") then makefolder("NebulaConfigs") end; if not isfolder(s.Folder) then makefolder(s.Folder) end end)
    return s
end
function Cfg:Reg(k,el) self.Els[k]=el end
function Cfg:Save(n)
    n=n or "default"; local d={}
    for k,el in pairs(self.Els) do if el.Get then local ok,v=pcall(el.Get,el); if ok then local t=type(v); if t=="boolean" or t=="number" or t=="string" then d[k]=v elseif typeof(v)=="EnumItem" then d[k]=tostring(v) end end end end
    pcall(function() writefile(self.Folder.."/"..n..".json", game:GetService("HttpService"):JSONEncode(d)) end)
end
function Cfg:Load(n)
    n=n or "default"
    local ok,d=pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(self.Folder.."/"..n..".json")) end)
    if not ok or not d then return end
    for k,v in pairs(d) do local el=self.Els[k]; if el and el.Set then pcall(el.Set,el,v) end end
end
function Cfg:List()
    local r={}; pcall(function() for _,f in ipairs(listfiles(self.Folder)) do local n=f:match("([^/\\]+)%.json$"); if n then table.insert(r,n) end end end); return r
end

-- ============================================================
-- INTRO
-- ============================================================
local function Intro(gui, cfg, theme, done)
    local title=cfg.Title or "Script"; local sub=cfg.Subtitle or "Loading..."; local dur=cfg.Duration or 3
    local ov=New("Frame",{Name="Intro",Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(8,8,12),ZIndex=200,Parent=gui})
    local grad=Instance.new("UIGradient"); grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(8,8,14)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(18,12,30)),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,8,14))}); grad.Rotation=135; grad.Parent=ov
    local c=New("Frame",{Size=UDim2.new(0,300,0,160),Position=UDim2.new(0.5,-150,0.5,-80),BackgroundTransparency=1,ZIndex=201,Parent=ov})
    local tl=New("TextLabel",{Size=UDim2.new(1,0,0,46),Position=UDim2.new(0,0,0,16),BackgroundTransparency=1,Text=title,TextColor3=theme.Text,TextSize=28,Font=theme.FontBold,TextTransparency=1,ZIndex=201,Parent=c})
    local sl=New("TextLabel",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,70),BackgroundTransparency=1,Text=sub,TextColor3=theme.SubText,TextSize=13,Font=theme.Font,TextTransparency=1,ZIndex=201,Parent=c})
    local bb=New("Frame",{Size=UDim2.new(0,220,0,3),Position=UDim2.new(0.5,-110,1,-20),BackgroundColor3=theme.Border,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=201,Parent=ov}); Corner(bb,UDim.new(1,0))
    local bf=New("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=theme.Accent,BorderSizePixel=0,ZIndex=202,Parent=bb}); Corner(bf,UDim.new(1,0))
    task.spawn(function()
        task.wait(0.2); Tw(tl,{TextTransparency=0},0.5); task.wait(0.25); Tw(sl,{TextTransparency=0},0.35); Tw(bb,{BackgroundTransparency=0},0.3); task.wait(0.1)
        Tw(bf,{Size=UDim2.new(1,0,1,0)},dur-1); task.wait(dur-1)
        Tw(ov,{BackgroundTransparency=1},0.4); Tw(tl,{TextTransparency=1},0.3); Tw(sl,{TextTransparency=1},0.3)
        task.wait(0.45); ov:Destroy(); done()
    end)
end

-- ============================================================
-- LIBRARY
-- ============================================================
function NebulaUI.new(config)
    local self=setmetatable({},NebulaUI); config=config or {}
    local tn=config.Theme or "Nebula"
    self.Theme=type(config.Theme)=="table" and config.Theme or (NebulaUI.Themes[tn] or NebulaUI.Themes.Nebula)
    self.Config=Cfg.new(config.Title or "NebulaUI"); self.Windows={}
    self.Gui=New("ScreenGui",{Name=config.Title or "NebulaUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true,DisplayOrder=999})
    local ok=pcall(function() self.Gui.Parent=game:GetService("CoreGui") end)
    if not ok or not self.Gui.Parent then self.Gui.Parent=LocalPlayer:WaitForChild("PlayerGui") end
    self._nh=New("Frame",{Name="Notifs",BackgroundTransparency=1,Size=UDim2.new(0,300,1,0),Position=UDim2.new(1,-310,0,0),ZIndex=300,Parent=self.Gui})
    List(self._nh,8,Enum.VerticalAlignment.Bottom); Pad(self._nh,8,8,0,0)
    return self
end

-- ============================================================
-- NOTIFY
-- ============================================================
function NebulaUI:Notify(cfg)
    cfg=cfg or {}; local T=self.Theme
    local title=cfg.Title or "Notice"; local msg=cfg.Message or ""; local dur=cfg.Duration or 4; local nt=cfg.Type or "Info"
    local colors={Info=T.Info,Success=T.Success,Warning=T.Warning,Error=T.Error}
    local icons={Info="ℹ",Success="✓",Warning="⚠",Error="✕"}
    local col=colors[nt] or T.Info
    local n=New("Frame",{Size=UDim2.new(1,0,0,72),BackgroundColor3=T.SecondaryBg,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=300,Parent=self._nh}); Corner(n,UDim.new(0,9)); Stroke(n,col,1)
    New("Frame",{Size=UDim2.new(0,3,0.7,0),Position=UDim2.new(0,0,0.15,0),BackgroundColor3=col,BorderSizePixel=0,ZIndex=301,Parent=n})
    New("TextLabel",{Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,10,0.5,-11),BackgroundTransparency=1,Text=icons[nt] or "ℹ",TextColor3=col,TextSize=14,Font=T.FontBold,ZIndex=301,Parent=n})
    New("TextLabel",{Size=UDim2.new(1,-44,0,20),Position=UDim2.new(0,38,0,10),BackgroundTransparency=1,Text=title,TextColor3=T.Text,TextSize=13,Font=T.FontBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=301,Parent=n})
    New("TextLabel",{Size=UDim2.new(1,-44,0,26),Position=UDim2.new(0,38,0,32),BackgroundTransparency=1,Text=msg,TextColor3=T.SubText,TextSize=11,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=301,Parent=n})
    local pb=New("Frame",{Size=UDim2.new(1,-38,0,2),Position=UDim2.new(0,38,1,-6),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=301,Parent=n}); Corner(pb,UDim.new(1,0))
    local pf=New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=col,BorderSizePixel=0,ZIndex=302,Parent=pb}); Corner(pf,UDim.new(1,0))
    Tw(n,{BackgroundTransparency=0},0.3); Tw(pf,{Size=UDim2.new(0,0,1,0)},dur)
    task.delay(dur,function() Tw(n,{BackgroundTransparency=1},0.28); Tw(n,{Size=UDim2.new(1,0,0,0)},0.24); task.wait(0.32); n:Destroy() end)
end

-- ============================================================
-- WINDOW
-- ============================================================
function NebulaUI:CreateWindow(config)
    config=config or {}; local T=self.Theme
    local title=config.Title or "NebulaUI"; local subtitle=config.Subtitle or ""
    local doIntro=config.Intro~=false; local toggleKey=config.ToggleKey or Enum.KeyCode.RightControl
    local mob=config.MobileButton~=false; local resizable=config.Resizable~=false
    local isMob=Mobile()
    local WW=isMob and 360 or 560; local WH=isMob and 360 or 430; local SBW=52

    -- ── MINI ICON (shown when minimised) ────────────────────
    local miniIcon=New("TextButton",{
        Name="MiniIcon",Size=UDim2.new(0,52,0,52),Position=UDim2.new(0.5,-26,0.5,-26),
        BackgroundColor3=T.Accent,Text=title:sub(1,2):upper(),TextColor3=Color3.fromRGB(255,255,255),
        TextSize=16,Font=T.FontBold,BorderSizePixel=0,Visible=false,ZIndex=100,Parent=self.Gui,
    }); Corner(miniIcon,UDim.new(1,0)); Drag(miniIcon)

    -- ── WINDOW ──────────────────────────────────────────────
    -- ClipsDescendants=false so sidebar tooltips & dropdowns
    -- are never clipped by the window boundary
    local win=New("Frame",{
        Name="Window",Size=UDim2.new(0,WW,0,WH),Position=UDim2.new(0.5,-WW/2,0.5,-WH/2),
        BackgroundColor3=T.Background,BorderSizePixel=0,Visible=false,
        ClipsDescendants=false, ZIndex=10,Parent=self.Gui,
    }); Corner(win,T.CornerRadius); Stroke(win,T.Border,1)

    -- Separate clipped BG so content clips but sidebar + tooltips don't
    local winBG=New("Frame",{
        Name="BG",Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Background,
        BorderSizePixel=0,ClipsDescendants=true,ZIndex=10,Parent=win,
    }); Corner(winBG,T.CornerRadius)

    New("ImageLabel",{Size=UDim2.new(1,48,1,48),Position=UDim2.new(0,-24,0,-24),BackgroundTransparency=1,
        Image="rbxassetid://5554236805",ImageColor3=Color3.fromRGB(0,0,0),ImageTransparency=0.55,
        ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(23,23,277,277),ZIndex=9,Parent=win})

    if resizable then Resize(win,420,300) end

    -- ── SIDEBAR ─────────────────────────────────────────────
    -- Parent = win (NOT winBG) and ZIndex=20 so it renders
    -- ON TOP of winBG content (which sits at ZIndex 11-15)
    local sb=New("Frame",{
        Name="Sidebar",Size=UDim2.new(0,SBW,1,0),BackgroundColor3=T.Sidebar,
        BorderSizePixel=0,ClipsDescendants=false,ZIndex=20,Parent=win,
    }); Corner(sb,T.CornerRadius)
    -- square off right corners of sidebar
    New("Frame",{Size=UDim2.new(0,T.CornerRadius.Offset,1,0),Position=UDim2.new(1,-T.CornerRadius.Offset,0,0),BackgroundColor3=T.Sidebar,BorderSizePixel=0,ZIndex=20,Parent=sb})
    New("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=21,Parent=sb})
    New("TextLabel",{Size=UDim2.new(1,0,0,52),BackgroundTransparency=1,Text=title:sub(1,2):upper(),TextColor3=T.Accent,TextSize=17,Font=T.FontBold,ZIndex=21,Parent=sb})
    New("Frame",{Size=UDim2.new(0.6,0,0,1),Position=UDim2.new(0.2,0,0,52),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=21,Parent=sb})

    local tabIcons=New("Frame",{Name="TabIcons",Size=UDim2.new(1,0,1,-110),Position=UDim2.new(0,0,0,56),BackgroundTransparency=1,ClipsDescendants=false,ZIndex=21,Parent=sb})
    List(tabIcons,4,nil,Enum.HorizontalAlignment.Center); Pad(tabIcons,4,4,0,0)

    local sbBot=New("Frame",{Size=UDim2.new(1,0,0,56),Position=UDim2.new(0,0,1,-56),BackgroundTransparency=1,ZIndex=21,Parent=sb})
    New("Frame",{Size=UDim2.new(0.6,0,0,1),Position=UDim2.new(0.2,0,0,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=21,Parent=sbBot})

    local function SBBtn(icon,yOff,cb)
        local b=New("TextButton",{Size=UDim2.new(0,32,0,26),Position=UDim2.new(0.5,-16,0,yOff),BackgroundColor3=T.TertiaryBg,Text=icon,TextColor3=T.SubText,TextSize=13,Font=T.FontBold,BorderSizePixel=0,ZIndex=22,Parent=sbBot}); Corner(b,UDim.new(0,6))
        b.MouseEnter:Connect(function() Tw(b,{TextColor3=T.Text},0.12) end); b.MouseLeave:Connect(function() Tw(b,{TextColor3=T.SubText},0.12) end); b.MouseButton1Click:Connect(cb); return b
    end

    local minimised=false; local visFlag=false
    SBBtn("−",6,function()
        minimised=true; Tw(win,{Size=UDim2.new(0,WW,0,0),BackgroundTransparency=1},0.22)
        task.wait(0.24); win.Visible=false; miniIcon.Visible=true
        Tw(win,{BackgroundTransparency=0},0)
    end)
    SBBtn("✕",32,function()
        Tw(win,{Size=UDim2.new(0,WW,0,0),BackgroundTransparency=1},0.22)
        task.wait(0.24); win.Visible=false; visFlag=false
        Tw(win,{BackgroundTransparency=0},0)
    end)

    miniIcon.MouseButton1Click:Connect(function()
        miniIcon.Visible=false; minimised=false; win.Visible=true; visFlag=true
        win.Size=UDim2.new(0,WW,0,0); Tw(win,{Size=UDim2.new(0,WW,0,WH),BackgroundTransparency=0},0.28,Enum.EasingStyle.Quart)
    end)

    -- ── TITLEBAR (child of winBG, clips with content) ───────
    local tb=New("Frame",{Name="TitleBar",Size=UDim2.new(1,-SBW,0,48),Position=UDim2.new(0,SBW,0,0),BackgroundColor3=T.SecondaryBg,BorderSizePixel=0,ZIndex=15,Parent=winBG})
    New("TextLabel",{Size=UDim2.new(0.65,0,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=title..(subtitle~="" and ("  ·  "..subtitle) or ""),TextColor3=T.Text,TextSize=14,Font=T.FontBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15,Parent=tb})
    New("TextLabel",{Size=UDim2.new(0,140,0,20),Position=UDim2.new(1,-146,0.5,-10),BackgroundTransparency=1,Text="["..toggleKey.Name.."] toggle",TextColor3=T.Muted,TextSize=10,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=15,Parent=tb})
    New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=15,Parent=tb})
    Drag(win, tb)   -- drag only from titlebar

    -- ── CONTENT HOLDER ──────────────────────────────────────
    local ch=New("Frame",{Name="ContentHolder",Size=UDim2.new(1,-SBW,1,-48),Position=UDim2.new(0,SBW,0,48),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=11,Parent=winBG})

    -- ── KEYBOARD TOGGLE ─────────────────────────────────────
    UserInputService.InputBegan:Connect(function(i,gpe)
        if gpe then return end
        if i.KeyCode==toggleKey then
            if minimised then
                miniIcon.Visible=false; minimised=false; win.Visible=true; visFlag=true
                win.Size=UDim2.new(0,WW,0,0); Tw(win,{Size=UDim2.new(0,WW,0,WH)},0.28,Enum.EasingStyle.Quart)
            else
                visFlag=not visFlag; win.Visible=visFlag
                if visFlag then win.Size=UDim2.new(0,WW,0,0); Tw(win,{Size=UDim2.new(0,WW,0,WH)},0.28,Enum.EasingStyle.Quart)
                else Tw(win,{Size=UDim2.new(0,WW,0,0)},0.22); task.wait(0.24); win.Visible=false end
            end
        end
    end)

    -- ── MOBILE TOGGLE BUTTON ────────────────────────────────
    if mob and isMob then
        local mb=New("TextButton",{Size=UDim2.new(0,50,0,50),Position=UDim2.new(0,10,0.5,-25),BackgroundColor3=T.Accent,Text="☰",TextColor3=Color3.fromRGB(255,255,255),TextSize=22,Font=T.FontBold,BorderSizePixel=0,ZIndex=100,Parent=self.Gui}); Corner(mb,UDim.new(1,0)); Drag(mb)
        mb.MouseButton1Click:Connect(function()
            if minimised then miniIcon.Visible=false; minimised=false; win.Visible=true; visFlag=true; Tw(win,{Size=UDim2.new(0,WW,0,WH)},0.28)
            else visFlag=not visFlag; win.Visible=visFlag end
        end)
    end

    -- ============================================================
    -- WINDOW OBJECT
    -- ============================================================
    local WO={Frame=win,Sidebar=sb,TabIcons=tabIcons,ContentHolder=ch,Theme=T,Tabs={},ActiveTab=nil,Config=self.Config,Library=self}

    function WO:_Select(tab)
        for _,t in pairs(self.Tabs) do
            t.Content.Visible=false; Tw(t.Button,{BackgroundColor3=T.TertiaryBg,TextColor3=T.Muted},0.13); t.Ind.Visible=false
        end
        tab.Content.Visible=true; tab.Ind.Visible=true
        Tw(tab.Button,{BackgroundColor3=Color3.fromRGB(math.floor(T.Accent.R*45),math.floor(T.Accent.G*45),math.floor(T.Accent.B*45)),TextColor3=T.Text},0.13)
        self.ActiveTab=tab
    end

    -- ============================================================
    -- CREATE TAB
    -- ============================================================
    function WO:CreateTab(cfg)
        cfg=cfg or {}; local tname=cfg.Name or "Tab"; local ticon=cfg.Icon or "◆"

        local btn=New("TextButton",{Name=tname,Size=UDim2.new(0,38,0,38),BackgroundColor3=T.TertiaryBg,Text=ticon,TextColor3=T.Muted,TextSize=16,Font=T.Font,BorderSizePixel=0,ZIndex=22,Parent=tabIcons}); Corner(btn,UDim.new(0,8))
        local ind=New("Frame",{Size=UDim2.new(0,3,0,18),Position=UDim2.new(0,-3,0.5,-9),BackgroundColor3=T.Accent,BorderSizePixel=0,Visible=false,ZIndex=23,Parent=btn}); Corner(ind,UDim.new(1,0))
        local tip=New("TextLabel",{Size=UDim2.new(0,0,0,24),Position=UDim2.new(1,8,0.5,-12),BackgroundColor3=T.TertiaryBg,Text="  "..tname.."  ",TextColor3=T.Text,TextSize=11,Font=T.Font,AutomaticSize=Enum.AutomaticSize.X,Visible=false,ZIndex=30,Parent=btn}); Corner(tip,UDim.new(0,5)); Stroke(tip,T.Border,1)
        btn.MouseEnter:Connect(function() tip.Visible=true end); btn.MouseLeave:Connect(function() tip.Visible=false end)

        local scroll=New("ScrollingFrame",{Name=tname.."_C",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.Accent,ScrollBarImageTransparency=0.4,CanvasSize=UDim2.new(0,0,0,0),Visible=false,ZIndex=11,Parent=ch})
        local lay=List(scroll,6); Pad(scroll,10,10,12,12)
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroll.CanvasSize=UDim2.new(0,0,0,lay.AbsoluteContentSize.Y+20) end)

        local TAB={Button=btn,Ind=ind,Content=scroll,Theme=T,Window=WO,Config=self.Config}
        btn.MouseButton1Click:Connect(function() WO:_Select(TAB) end)
        table.insert(WO.Tabs,TAB)
        if #WO.Tabs==1 then WO:_Select(TAB) end

        -- SECTION
        function TAB:CreateSection(n)
            n=(type(n)=="table" and n.Name) or n or "Section"
            local s=New("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,ZIndex=12,Parent=scroll})
            New("TextLabel",{Size=UDim2.new(0.5,0,1,0),BackgroundTransparency=1,Text=string.upper(n),TextColor3=T.Accent,TextSize=10,Font=T.FontBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12,Parent=s})
            New("Frame",{Size=UDim2.new(0.46,0,0,1),Position=UDim2.new(0.54,0,0.5,0),BackgroundColor3=T.Border,BorderSizePixel=0,ZIndex=12,Parent=s})
        end

        -- BUTTON
        function TAB:CreateButton(cfg)
            cfg=cfg or {}; local n=cfg.Name or "Button"; local d=cfg.Description or ""; local cb=cfg.Callback or function() end
            local f=New("Frame",{Size=UDim2.new(1,0,0,d~="" and 54 or 38),BackgroundColor3=T.SecondaryBg,BorderSizePixel=0,ZIndex=12,Parent=scroll}); Corner(f,T.CornerRadius); Stroke(f,T.Border,1); Pad(f,0,0,14,14)
            New("TextLabel",{Size=UDim2.new(1,-90,0,20),Position=UDim2.new(0,0,0,d~="" and 8 or 9),BackgroundTransparency=1,Text=n,TextColor3=T.Text,TextSize=T.FontSize,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=f})
            if d~="" then New("TextLabel",{Size=UDim2.new(1,-90,0,16),Position=UDim2.new(0,0,0,30),BackgroundTransparency=1,Text=d,TextColor3=T.SubText,TextSize=11,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=f}) end
            local b=New("TextButton",{Size=UDim2.new(0,76,0,28),Position=UDim2.new(1,-76,0.5,-14),BackgroundColor3=T.Accent,Text="Execute",TextColor3=Color3.fromRGB(255,255,255),TextSize=11,Font=T.FontBold,BorderSizePixel=0,ZIndex=13,Parent=f}); Corner(b,UDim.new(0,7))
            b.MouseEnter:Connect(function() Tw(b,{BackgroundColor3=T.AccentHover},0.12) end); b.MouseLeave:Connect(function() Tw(b,{BackgroundColor3=T.Accent},0.12) end)
            b.MouseButton1Click:Connect(function() Tw(b,{BackgroundColor3=T.AccentDark},0.07); task.wait(0.08); Tw(b,{BackgroundColor3=T.Accent},0.12); task.spawn(cb) end)
        end

        -- TOGGLE
        function TAB:CreateToggle(cfg)
            cfg=cfg or {}; local n=cfg.Name or "Toggle"; local d=cfg.Description or ""; local def=cfg.Default or false; local ck=cfg.ConfigKey; local cb=cfg.Callback or function() end
            local state=def; local h=d~="" and 54 or 38
            local f=New("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=T.SecondaryBg,BorderSizePixel=0,ZIndex=12,Parent=scroll}); Corner(f,T.CornerRadius); Stroke(f,T.Border,1); Pad(f,0,0,14,14)
            New("TextLabel",{Size=UDim2.new(1,-60,0,20),Position=UDim2.new(0,0,0,d~="" and 8 or 9),BackgroundTransparency=1,Text=n,TextColor3=T.Text,TextSize=T.FontSize,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=f})
            if d~="" then New("TextLabel",{Size=UDim2.new(1,-60,0,16),Position=UDim2.new(0,0,0,30),BackgroundTransparency=1,Text=d,TextColor3=T.SubText,TextSize=11,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=f}) end
            local sw=New("Frame",{Size=UDim2.new(0,44,0,24),Position=UDim2.new(1,-44,0.5,-12),BackgroundColor3=state and T.Toggle_On or T.Toggle_Off,BorderSizePixel=0,ZIndex=13,Parent=f}); Corner(sw,UDim.new(1,0))
            local kn=New("Frame",{Size=UDim2.new(0,18,0,18),Position=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=14,Parent=sw}); Corner(kn,UDim.new(1,0))
            New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=15,Parent=f}).MouseButton1Click:Connect(function()
                state=not state; Tw(sw,{BackgroundColor3=state and T.Toggle_On or T.Toggle_Off},0.18); Tw(kn,{Position=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.18); task.spawn(cb,state)
            end)
            local obj={}
            function obj:Set(v) state=v; Tw(sw,{BackgroundColor3=state and T.Toggle_On or T.Toggle_Off},0.18); Tw(kn,{Position=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.18); task.spawn(cb,state) end
            function obj:Get() return state end
            if ck then self.Config:Reg(ck,obj) end; return obj
        end

        -- SLIDER
        function TAB:CreateSlider(cfg)
            cfg=cfg or {}; local n=cfg.Name or "Slider"; local mn=cfg.Min or 0; local mx=cfg.Max or 100; local def=cfg.Default or mn; local suf=cfg.Suffix or ""; local dec=cfg.Decimals or 0; local ck=cfg.ConfigKey; local cb=cfg.Callback or function() end
            local val=math.clamp(def,mn,mx)
            local f=New("Frame",{Size=UDim2.new(1,0,0,54),BackgroundColor3=T.SecondaryBg,BorderSizePixel=0,ZIndex=12,Parent=scroll}); Corner(f,T.CornerRadius); Stroke(f,T.Border,1); Pad(f,0,0,14,14)
            New("TextLabel",{Size=UDim2.new(0.6,0,0,20),Position=UDim2.new(0,0,0,8),BackgroundTransparency=1,Text=n,TextColor3=T.Text,TextSize=T.FontSize,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=f})
            local vl=New("TextLabel",{Size=UDim2.new(0.4,0,0,20),Position=UDim2.new(0.6,0,0,8),BackgroundTransparency=1,Text=tostring(val)..suf,TextColor3=T.Accent,TextSize=T.FontSize,Font=T.FontBold,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=13,Parent=f})
            local trk=New("Frame",{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,1,-18),BackgroundColor3=T.Slider_BG,BorderSizePixel=0,ZIndex=13,Parent=f}); Corner(trk,UDim.new(1,0))
            local p0=(val-mn)/(mx-mn)
            local fl=New("Frame",{Size=UDim2.new(p0,0,1,0),BackgroundColor3=T.Slider_Fill,BorderSizePixel=0,ZIndex=14,Parent=trk}); Corner(fl,UDim.new(1,0))
            local th=New("Frame",{Size=UDim2.new(0,14,0,14),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(p0,0,0.5,0),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=15,Parent=trk}); Corner(th,UDim.new(1,0))
            -- TextButton hitbox consumes the click so it won't reach window drag
            local hit=New("TextButton",{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,1,-24),BackgroundTransparency=1,Text="",ZIndex=16,Parent=f})
            local drag=false
            local function Upd(ix) local w=math.max(trk.AbsoluteSize.X,1); local pct=math.clamp((ix-trk.AbsolutePosition.X)/w,0,1); local mult=10^dec; val=math.floor((mn+(mx-mn)*pct)*mult+0.5)/mult; vl.Text=tostring(val)..suf; Tw(fl,{Size=UDim2.new(pct,0,1,0)},0.04); Tw(th,{Position=UDim2.new(pct,0,0.5,0)},0.04); task.spawn(cb,val) end
            local function StartDrag(i) drag=true; Upd(i.Position.X) end
            hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then StartDrag(i) end end)
            trk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then StartDrag(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
            UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then Upd(i.Position.X) end end)
            local obj={}
            function obj:Set(v) val=math.clamp(v,mn,mx); local pct=(val-mn)/(mx-mn); vl.Text=tostring(val)..suf; Tw(fl,{Size=UDim2.new(pct,0,1,0)},0.1); Tw(th,{Position=UDim2.new(pct,0,0.5,0)},0.1); task.spawn(cb,val) end
            function obj:Get() return val end
            if ck then self.Config:Reg(ck,obj) end; return obj
        end

        -- DROPDOWN
        function TAB:CreateDropdown(cfg)
            cfg=cfg or {}; local n=cfg.Name or "Dropdown"; local opts=cfg.Options or {}; local def=cfg.Default or (opts[1] or "None"); local multi=cfg.MultiSelect or false; local ck=cfg.ConfigKey; local cb=cfg.Callback or function() end
            local sel=def; local ms={}; local open=false
            local f=New("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=T.SecondaryBg,BorderSizePixel=0,ClipsDescendants=false,ZIndex=14,Parent=scroll}); Corner(f,T.CornerRadius); Stroke(f,T.Border,1); Pad(f,0,0,14,14)
            New("TextLabel",{Size=UDim2.new(0.5,0,1,0),BackgroundTransparency=1,Text=n,TextColor3=T.Text,TextSize=T.FontSize,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15,Parent=f})
            local sl=New("TextLabel",{Size=UDim2.new(0.5,-20,1,0),Position=UDim2.new(0.5,0,0,0),BackgroundTransparency=1,Text=sel,TextColor3=T.Accent,TextSize=11,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=15,Parent=f})
            local ar=New("TextLabel",{Size=UDim2.new(0,16,1,0),Position=UDim2.new(1,-16,0,0),BackgroundTransparency=1,Text="▾",TextColor3=T.SubText,TextSize=13,Font=T.Font,ZIndex=15,Parent=f})
            local lh=math.min(#opts,6)*30+8
            local ddl=New("Frame",{Size=UDim2.new(1,0,0,lh),Position=UDim2.new(0,0,1,4),BackgroundColor3=T.TertiaryBg,BorderSizePixel=0,Visible=false,ClipsDescendants=true,ZIndex=25,Parent=f}); Corner(ddl,UDim.new(0,8)); Stroke(ddl,T.Border,1); Pad(ddl,4,4,4,4); List(ddl,2)
            local function Build()
                for _,c in pairs(ddl:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                for _,opt in ipairs(opts) do
                    local is=multi and table.find(ms,opt) or opt==sel
                    local ob=New("TextButton",{Size=UDim2.new(1,0,0,28),BackgroundColor3=is and T.AccentDark or T.TertiaryBg,Text=(multi and is and "✓  " or "    ")..opt,TextColor3=is and T.Text or T.SubText,TextSize=12,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,ZIndex=26,Parent=ddl}); Corner(ob,UDim.new(0,5))
                    ob.MouseEnter:Connect(function() if not(multi and table.find(ms,opt) or opt==sel) then Tw(ob,{BackgroundColor3=T.SecondaryBg},0.1) end end)
                    ob.MouseLeave:Connect(function() local s2=multi and table.find(ms,opt) or opt==sel; Tw(ob,{BackgroundColor3=s2 and T.AccentDark or T.TertiaryBg},0.1) end)
                    ob.MouseButton1Click:Connect(function()
                        if multi then local idx=table.find(ms,opt); if idx then table.remove(ms,idx) else table.insert(ms,opt) end; sl.Text=#ms==0 and "None" or table.concat(ms,", "); task.spawn(cb,ms)
                        else sel=opt; sl.Text=sel; open=false; ddl.Visible=false; Tw(ar,{Rotation=0},0.15); task.spawn(cb,sel) end; Build()
                    end)
                end
            end; Build()
            New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=16,Parent=f}).MouseButton1Click:Connect(function() open=not open; ddl.Visible=open; Tw(ar,{Rotation=open and 180 or 0},0.15) end)
            local obj={}
            function obj:Set(v) if multi then ms=type(v)=="table" and v or {v}; sl.Text=#ms==0 and "None" or table.concat(ms,", ") else sel=v; sl.Text=v end; Build(); task.spawn(cb,multi and ms or sel) end
            function obj:Get() return multi and ms or sel end
            function obj:Refresh(no) opts=no; lh=math.min(#opts,6)*30+8; ddl.Size=UDim2.new(1,0,0,lh); Build() end
            if ck then self.Config:Reg(ck,obj) end; return obj
        end

        -- TEXTBOX
        function TAB:CreateTextbox(cfg)
            cfg=cfg or {}; local n=cfg.Name or "Textbox"; local ph=cfg.Placeholder or "Enter text..."; local def=cfg.Default or ""; local ck=cfg.ConfigKey; local cb=cfg.Callback or function() end
            local f=New("Frame",{Size=UDim2.new(1,0,0,54),BackgroundColor3=T.SecondaryBg,BorderSizePixel=0,ZIndex=12,Parent=scroll}); Corner(f,T.CornerRadius); Stroke(f,T.Border,1); Pad(f,0,0,14,14)
            New("TextLabel",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,6),BackgroundTransparency=1,Text=n,TextColor3=T.Text,TextSize=T.FontSize,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=f})
            local ibg=New("Frame",{Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,1,-26),BackgroundColor3=T.Background,BorderSizePixel=0,ZIndex=13,Parent=f}); Corner(ibg,UDim.new(0,5)); local ist=Stroke(ibg,T.Border,1)
            local tb2=New("TextBox",{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,6,0,0),BackgroundTransparency=1,Text=def,PlaceholderText=ph,PlaceholderColor3=T.Muted,TextColor3=T.Text,TextSize=12,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=14,Parent=ibg})
            tb2.Focused:Connect(function() Tw(ist,{Color=T.Accent},0.15) end); tb2.FocusLost:Connect(function(e) Tw(ist,{Color=T.Border},0.15); task.spawn(cb,tb2.Text,e) end)
            local obj={}; function obj:Set(v) tb2.Text=v end; function obj:Get() return tb2.Text end
            if ck then self.Config:Reg(ck,obj) end; return obj
        end

        -- KEYBIND
        function TAB:CreateKeybind(cfg)
            cfg=cfg or {}; local n=cfg.Name or "Keybind"; local def=cfg.Default or Enum.KeyCode.RightShift; local ck=cfg.ConfigKey; local cb=cfg.Callback or function() end
            local bind=def; local listen=false
            local f=New("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=T.SecondaryBg,BorderSizePixel=0,ZIndex=12,Parent=scroll}); Corner(f,T.CornerRadius); Stroke(f,T.Border,1); Pad(f,0,0,14,14)
            New("TextLabel",{Size=UDim2.new(0.6,0,1,0),BackgroundTransparency=1,Text=n,TextColor3=T.Text,TextSize=T.FontSize,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=f})
            local kb=New("TextButton",{Size=UDim2.new(0,90,0,26),Position=UDim2.new(1,-90,0.5,-13),BackgroundColor3=T.TertiaryBg,Text="[ "..bind.Name.." ]",TextColor3=T.Accent,TextSize=11,Font=T.FontBold,BorderSizePixel=0,ZIndex=13,Parent=f}); Corner(kb,UDim.new(0,6)); Stroke(kb,T.Border,1)
            kb.MouseButton1Click:Connect(function() listen=true; kb.Text="[ ... ]"; kb.TextColor3=T.SubText end)
            UserInputService.InputBegan:Connect(function(i,gpe)
                if listen and i.UserInputType==Enum.UserInputType.Keyboard then bind=i.KeyCode; kb.Text="[ "..bind.Name.." ]"; kb.TextColor3=T.Accent; listen=false
                elseif not listen and not gpe and i.KeyCode==bind then task.spawn(cb) end
            end)
            local obj={}; function obj:Set(k) bind=k; kb.Text="[ "..k.Name.." ]" end; function obj:Get() return bind end
            if ck then self.Config:Reg(ck,obj) end; return obj
        end

        -- LABEL
        function TAB:CreateLabel(text, col)
            local l=New("TextLabel",{Size=UDim2.new(1,0,0,30),BackgroundColor3=T.SecondaryBg,Text="  "..(text or ""),TextColor3=col or T.SubText,TextSize=12,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,ZIndex=12,Parent=scroll}); Corner(l,T.CornerRadius); Stroke(l,T.Border,1)
            local obj={}; function obj:Set(v) l.Text="  "..v end; function obj:Get() return l.Text:sub(3) end; return obj
        end

        -- COLOR PICKER
        function TAB:CreateColorPicker(cfg)
            cfg=cfg or {}; local n=cfg.Name or "Color"; local def=cfg.Default or Color3.fromRGB(255,100,100); local ck=cfg.ConfigKey; local cb=cfg.Callback or function() end
            local col=def; local open=false; local r,g,b=col.R*255,col.G*255,col.B*255
            local f=New("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=T.SecondaryBg,BorderSizePixel=0,ClipsDescendants=false,ZIndex=12,Parent=scroll}); Corner(f,T.CornerRadius); Stroke(f,T.Border,1); Pad(f,0,0,14,14)
            New("TextLabel",{Size=UDim2.new(1,-40,1,0),BackgroundTransparency=1,Text=n,TextColor3=T.Text,TextSize=T.FontSize,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=f})
            local pv=New("Frame",{Size=UDim2.new(0,28,0,20),Position=UDim2.new(1,-28,0.5,-10),BackgroundColor3=col,BorderSizePixel=0,ZIndex=13,Parent=f}); Corner(pv,UDim.new(0,5)); Stroke(pv,T.Border,1)
            local panel=New("Frame",{Size=UDim2.new(1,0,0,96),Position=UDim2.new(0,0,1,4),BackgroundColor3=T.TertiaryBg,BorderSizePixel=0,Visible=false,ZIndex=20,Parent=f}); Corner(panel,UDim.new(0,8)); Stroke(panel,T.Border,1); Pad(panel,6,6,10,10); List(panel,4)
            local function RRow(ch,val,cc)
                local row=New("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,ZIndex=21,Parent=panel})
                New("TextLabel",{Size=UDim2.new(0,14,1,0),BackgroundTransparency=1,Text=ch,TextColor3=T.SubText,TextSize=11,Font=T.FontBold,ZIndex=21,Parent=row})
                local trk=New("Frame",{Size=UDim2.new(1,-54,0,6),Position=UDim2.new(0,18,0.5,-3),BackgroundColor3=T.Slider_BG,BorderSizePixel=0,ZIndex=21,Parent=row}); Corner(trk,UDim.new(1,0))
                local fl=New("Frame",{Size=UDim2.new(val/255,0,1,0),BackgroundColor3=cc,BorderSizePixel=0,ZIndex=22,Parent=trk}); Corner(fl,UDim.new(1,0))
                local nl=New("TextLabel",{Size=UDim2.new(0,34,1,0),Position=UDim2.new(1,-34,0,0),BackgroundTransparency=1,Text=tostring(math.floor(val)),TextColor3=T.Text,TextSize=11,Font=T.Font,ZIndex=21,Parent=row})
                return trk,fl,nl
            end
            local rT,rF,rN=RRow("R",r,Color3.fromRGB(220,60,60)); local gT,gF,gN=RRow("G",g,Color3.fromRGB(60,200,60)); local bT,bF,bN=RRow("B",b,Color3.fromRGB(60,60,220))
            local function MkS(trk,fl,nl,setter)
                local drag=false
                trk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
                UserInputService.InputChanged:Connect(function(i)
                    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        local pct=math.clamp((i.Position.X-trk.AbsolutePosition.X)/math.max(trk.AbsoluteSize.X,1),0,1); setter(math.floor(pct*255)); fl.Size=UDim2.new(pct,0,1,0); nl.Text=tostring(math.floor(pct*255)); col=Color3.fromRGB(r,g,b); pv.BackgroundColor3=col; task.spawn(cb,col)
                    end
                end)
            end
            MkS(rT,rF,rN,function(v) r=v end); MkS(gT,gF,gN,function(v) g=v end); MkS(bT,bF,bN,function(v) b=v end)
            New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=14,Parent=f}).MouseButton1Click:Connect(function() open=not open; panel.Visible=open end)
            local obj={}; function obj:Set(c) col=c; r,g,b=c.R*255,c.G*255,c.B*255; pv.BackgroundColor3=col; task.spawn(cb,col) end; function obj:Get() return col end
            if ck then self.Config:Reg(ck,obj) end; return obj
        end

        -- INFO CARD  ← new: for Info tab
        function TAB:CreateInfoCard(cfg)
            cfg=cfg or {}; local lbl=cfg.Label or "Info"; local val=cfg.Value or "—"; local icon=cfg.Icon or ""
            local f=New("Frame",{Size=UDim2.new(1,0,0,40),BackgroundColor3=T.SecondaryBg,BorderSizePixel=0,ZIndex=12,Parent=scroll}); Corner(f,T.CornerRadius); Stroke(f,T.Border,1); Pad(f,0,0,14,14)
            New("TextLabel",{Size=UDim2.new(0.55,0,1,0),BackgroundTransparency=1,Text=(icon~="" and icon.."  " or "")..lbl,TextColor3=T.SubText,TextSize=12,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=f})
            local vl=New("TextLabel",{Size=UDim2.new(0.45,0,1,0),Position=UDim2.new(0.55,0,0,0),BackgroundTransparency=1,Text=tostring(val),TextColor3=T.Text,TextSize=12,Font=T.FontBold,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=13,Parent=f})
            local obj={}; function obj:Set(v) vl.Text=tostring(v) end; function obj:Get() return vl.Text end; return obj
        end

        -- AVATAR CARD  ← new: for Info tab
        function TAB:CreateAvatar()
            local lp=Players.LocalPlayer
            local f=New("Frame",{Size=UDim2.new(1,0,0,80),BackgroundColor3=T.SecondaryBg,BorderSizePixel=0,ZIndex=12,Parent=scroll}); Corner(f,T.CornerRadius); Stroke(f,T.Border,1)
            local img=New("ImageLabel",{Size=UDim2.new(0,60,0,60),Position=UDim2.new(0,10,0.5,-30),BackgroundColor3=T.TertiaryBg,Image="rbxthumb://type=AvatarHeadShot&id="..tostring(lp.UserId).."&w=150&h=150",ZIndex=13,Parent=f}); Corner(img,UDim.new(1,0))
            New("TextLabel",{Size=UDim2.new(1,-84,0,22),Position=UDim2.new(0,80,0,12),BackgroundTransparency=1,Text=lp.DisplayName,TextColor3=T.Text,TextSize=14,Font=T.FontBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=f})
            New("TextLabel",{Size=UDim2.new(1,-84,0,18),Position=UDim2.new(0,80,0,36),BackgroundTransparency=1,Text="@"..lp.Name,TextColor3=T.SubText,TextSize=11,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=f})
            New("TextLabel",{Size=UDim2.new(1,-84,0,16),Position=UDim2.new(0,80,0,56),BackgroundTransparency=1,Text="ID: "..tostring(lp.UserId),TextColor3=T.Muted,TextSize=10,Font=T.Font,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=f})
        end

        -- CONFIG SECTION
        function TAB:CreateConfigSection()
            self:CreateSection("Config")
            local configs=WO.Config:List()
            local ddObj=self:CreateDropdown({Name="Load Config",Options=#configs>0 and configs or {"No configs"}})
            local tbObj=self:CreateTextbox({Name="Config Name",Placeholder="my_config",Default="default"})
            self:CreateButton({Name="Save Config",Callback=function()
                local nm=tbObj:Get(); if nm and nm~="" then WO.Config:Save(nm); ddObj:Refresh(WO.Config:List()); WO.Library:Notify({Title="Saved",Message="\""..nm.."\" saved.",Type="Success",Duration=3}) end
            end})
            self:CreateButton({Name="Load Config",Callback=function()
                local nm=ddObj:Get(); if nm and nm~="No configs" then WO.Config:Load(nm); WO.Library:Notify({Title="Loaded",Message="\""..nm.."\" applied.",Type="Info",Duration=3}) end
            end})
        end

        return TAB
    end -- CreateTab

    local function Show()
        win.Visible=true; visFlag=true; win.Size=UDim2.new(0,WW,0,0)
        Tw(win,{Size=UDim2.new(0,WW,0,WH)},0.32,Enum.EasingStyle.Quart)
    end
    if doIntro then Intro(self.Gui,config,T,Show) else Show() end

    table.insert(self.Windows,WO)
    return WO
end

function NebulaUI:Destroy() self.Gui:Destroy() end

return NebulaUI

--[[
==============================================================
PIXEL BLADE — INFO TAB EXAMPLE
==============================================================

local InfoTab = Window:CreateTab({ Name = "Info", Icon = "👤" })

InfoTab:CreateAvatar()  -- shows avatar + username + display name + ID
InfoTab:CreateSection("Statistics")

local execCount = 0
local execCard = InfoTab:CreateInfoCard({ Label="Total Executions", Value=0, Icon="⚡" })
local useCard  = InfoTab:CreateInfoCard({ Label="Script Uses",      Value=1, Icon="🔁" })

InfoTab:CreateSection("Account")
InfoTab:CreateInfoCard({ Label="Account Age", Value=game.Players.LocalPlayer.AccountAge.." days", Icon="📅" })
InfoTab:CreateInfoCard({ Label="Team",        Value=tostring(game.Players.LocalPlayer.Team),       Icon="🏳" })

-- increment executions each kill:
-- execCount = execCount + 1
-- execCard:Set(execCount)
==============================================================
]]
