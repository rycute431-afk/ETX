-- ETX v2.3 — Project Delta | Custom UI + NPC scanner + Container ESP (fixed)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer

local Theme = {
    Bg=Color3.fromRGB(18,10,14), Sidebar=Color3.fromRGB(14,8,11),
    Card=Color3.fromRGB(30,16,22), Card2=Color3.fromRGB(40,22,30),
    Border=Color3.fromRGB(64,32,42), Accent=Color3.fromRGB(232,67,79),
    Accent2=Color3.fromRGB(180,50,60), Text=Color3.fromRGB(240,228,232),
    TextDim=Color3.fromRGB(150,125,135), White=Color3.fromRGB(255,255,255),
    Off=Color3.fromRGB(46,24,32), Track=Color3.fromRGB(38,20,28),
}

local function C(cls, props, parent)
    local i = Instance.new(cls)
    for k, v in pairs(props or {}) do if k ~= "Parent" then i[k] = v end end
    if parent then i.Parent = parent end
    return i
end
local function Corner(p, r) return C("UICorner", {CornerRadius=UDim.new(0,r or 6)}, p) end
local function Stroke(p, color, thick, trans)
    return C("UIStroke", {Color=color or Theme.Border, Thickness=thick or 1, Transparency=trans or 0.3}, p)
end

local ClearAllSkeletons
local ClearAllHats

-- ==================== NOTIFY ====================
local NotifyGui = C("ScreenGui", {Name="ETX_Notify", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, CoreGui)
local NotifyHolder = C("Frame", {Size=UDim2.new(0,300,1,-20), Position=UDim2.new(1,-320,0,10), BackgroundTransparency=1}, NotifyGui)
C("UIListLayout", {Padding=UDim.new(0,8), HorizontalAlignment=Enum.HorizontalAlignment.Right, VerticalAlignment=Enum.VerticalAlignment.Bottom, SortOrder=Enum.SortOrder.LayoutOrder}, NotifyHolder)
local NotifyQueue = {}
local function Notify(title, content, duration)
    duration = duration or 4
    while #NotifyQueue >= 5 do local old = table.remove(NotifyQueue,1); if old and old.Parent then old:Destroy() end end
    local f = C("Frame", {Size=UDim2.new(0,280,0,62), BackgroundColor3=Theme.Card, BorderSizePixel=0, BackgroundTransparency=1}, NotifyHolder)
    Corner(f,6); local st = Stroke(f,Theme.Border,1,1)
    local bar = C("Frame", {Size=UDim2.new(0,3,1,0), BackgroundColor3=Theme.Accent, BorderSizePixel=0, BackgroundTransparency=1}, f)
    Corner(bar,2)
    local t = C("TextLabel", {Size=UDim2.new(1,-22,0,20), Position=UDim2.new(0,14,0,8), BackgroundTransparency=1, Text=title or "ETX", TextColor3=Theme.Accent, TextSize=12, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, TextTransparency=1}, f)
    local b = C("TextLabel", {Size=UDim2.new(1,-22,0,28), Position=UDim2.new(0,14,0,28), BackgroundTransparency=1, Text=content or "", TextColor3=Theme.Text, TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, TextWrapped=true, TextTransparency=1}, f)
    table.insert(NotifyQueue,f)
    local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
    TS:Create(f,info,{BackgroundTransparency=0.05}):Play()
    TS:Create(bar,info,{BackgroundTransparency=0}):Play()
    TS:Create(st,info,{Transparency=0.2}):Play()
    TS:Create(t,info,{TextTransparency=0}):Play()
    TS:Create(b,info,{TextTransparency=0}):Play()
    task.delay(duration, function()
        for i,q in ipairs(NotifyQueue) do if q==f then table.remove(NotifyQueue,i); break end end
        if not f.Parent then return end
        TS:Create(f,info,{BackgroundTransparency=1}):Play()
        TS:Create(bar,info,{BackgroundTransparency=1}):Play()
        TS:Create(st,info,{Transparency=1}):Play()
        TS:Create(t,info,{TextTransparency=1}):Play()
        TS:Create(b,info,{TextTransparency=1}):Play()
        task.wait(0.3); f:Destroy()
    end)
end

-- ==================== SECTION ====================
local function CreateSection(parent, opts)
    local section = {}
    local card = C("Frame", {Size=UDim2.new(1,0,0,0), BackgroundColor3=Theme.Card, BorderSizePixel=0, AutomaticSize=Enum.AutomaticSize.Y, ClipsDescendants=true}, parent)
    Corner(card,8); Stroke(card,Theme.Border,1,0.5)
    local header = C("Frame", {Size=UDim2.new(1,0,0,34), BackgroundTransparency=1}, card)
    local hbar = C("Frame", {Size=UDim2.new(0,3,0,14), Position=UDim2.new(0,12,0.5,-7), BackgroundColor3=Theme.Accent, BorderSizePixel=0}, header)
    Corner(hbar,2)
    C("TextLabel", {Size=UDim2.new(1,-30,1,0), Position=UDim2.new(0,24,0,0), BackgroundTransparency=1, Text=opts.Title or "Section", TextColor3=Theme.Text, TextSize=13, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left}, header)
    local body = C("Frame", {Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,0,34), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y}, card)
    C("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder}, body)
    C("UIPadding", {PaddingBottom=UDim.new(0,10), PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,12)}, body)
    local function Row(title, h)
        local r = C("Frame", {Size=UDim2.new(1,0,0,h or 32), BackgroundTransparency=1}, body)
        C("TextLabel", {Size=UDim2.new(1,-160,1,0), BackgroundTransparency=1, Text=title or "", TextColor3=Theme.Text, TextSize=12, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Center}, r)
        return r
    end
    function section:Toggle(o)
        local r = Row(o.Title)
        local on = o.Value or false
        local track = C("Frame", {Size=UDim2.new(0,40,0,20), Position=UDim2.new(1,-40,0.5,-10), BackgroundColor3=on and Theme.Accent or Theme.Off, BorderSizePixel=0}, r)
        Corner(track,10)
        local knob = C("Frame", {Size=UDim2.new(0,16,0,16), Position=on and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8), BackgroundColor3=Theme.White, BorderSizePixel=0}, track)
        Corner(knob,8)
        C("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=""}, r).MouseButton1Click:Connect(function()
            on = not on
            TS:Create(track,TweenInfo.new(0.15),{BackgroundColor3=on and Theme.Accent or Theme.Off}):Play()
            TS:Create(knob,TweenInfo.new(0.15),{Position=on and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
            if o.Callback then o.Callback(on) end
        end)
    end
    function section:Slider(o)
        local r = Row(o.Title, 52)
        local minV = o.Min or 0; local maxV = o.Max or 100; local val = o.Value or minV
        local rnd = o.Rounding or 0; local sfx = o.Suffix or ""
        local function fmt(v) if rnd>0 then return string.format("%."..rnd.."f",v)..sfx end; return tostring(math.floor(v+0.5))..sfx end
        local vl = C("TextLabel", {Size=UDim2.new(0,100,0,20), Position=UDim2.new(1,-100,0,0), BackgroundTransparency=1, Text=fmt(val), TextColor3=Theme.Accent, TextSize=12, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right}, r)
        local track = C("Frame", {Size=UDim2.new(1,0,0,5), Position=UDim2.new(0,0,0,32), BackgroundColor3=Theme.Track, BorderSizePixel=0}, r)
        Corner(track,3)
        local pct = (val-minV)/math.max(maxV-minV,0.0001)
        local fill = C("Frame", {Size=UDim2.new(pct,0,1,0), BackgroundColor3=Theme.Accent, BorderSizePixel=0}, track)
        Corner(fill,3)
        local knob = C("Frame", {Size=UDim2.new(0,12,0,12), Position=UDim2.new(pct,-6,0.5,-6), BackgroundColor3=Theme.White, BorderSizePixel=0}, track)
        Corner(knob,6)
        local hit = C("TextButton", {Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,0,27), BackgroundTransparency=1, Text=""}, r)
        local drag = false
        local function upd(mx)
            local tp = track.AbsolutePosition.X; local tw = math.max(track.AbsoluteSize.X,1)
            local p = math.clamp((mx-tp)/tw,0,1)
            local v = minV + p*(maxV-minV)
            if rnd>0 then local m = 10^rnd; v = math.floor(v*m+0.5)/m else v = math.floor(v+0.5) end
            v = math.clamp(v,minV,maxV); val = v
            fill.Size = UDim2.new(p,0,1,0); knob.Position = UDim2.new(p,-6,0.5,-6); vl.Text = fmt(v)
            if o.Callback then o.Callback(v) end
        end
        hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; upd(UIS:GetMouseLocation().X) end end)
        UIS.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(UIS:GetMouseLocation().X) end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    end
    function section:Button(o)
        local r = Row(o.Title)
        local btn = C("TextButton", {Size=UDim2.new(0,90,0,24), Position=UDim2.new(1,-90,0.5,-12), BackgroundColor3=Theme.Accent, Text=o.ButtonText or "Run", TextColor3=Theme.White, TextSize=11, Font=Enum.Font.GothamBold, BorderSizePixel=0, AutoButtonColor=false}, r)
        Corner(btn,5)
        btn.MouseEnter:Connect(function() TS:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Theme.Accent2}):Play() end)
        btn.MouseLeave:Connect(function() TS:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Theme.Accent}):Play() end)
        btn.MouseButton1Click:Connect(function() if o.Callback then o.Callback() end end)
    end
    function section:Dropdown(o)
        local r = Row(o.Title)
        local options = o.Options or {}; local current = o.Value or options[1] or ""
        local btn = C("TextButton", {Size=UDim2.new(0,130,0,24), Position=UDim2.new(1,-130,0.5,-12), BackgroundColor3=Theme.Bg, Text=tostring(current).."  ▼", TextColor3=Theme.Text, TextSize=11, Font=Enum.Font.Gotham, BorderSizePixel=0, AutoButtonColor=false}, r)
        Corner(btn,5); Stroke(btn,Theme.Border,1,0.4)
        local list = C("Frame", {Size=UDim2.new(1,0,0,0), BackgroundColor3=Theme.Bg, BorderSizePixel=0, Visible=false, AutomaticSize=Enum.AutomaticSize.Y}, body)
        Corner(list,6); Stroke(list,Theme.Border,1,0.3)
        C("UIListLayout", {Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder}, list)
        C("UIPadding", {PaddingTop=UDim.new(0,4), PaddingBottom=UDim.new(0,4), PaddingLeft=UDim.new(0,4), PaddingRight=UDim.new(0,4)}, list)
        local open = false
        btn.MouseButton1Click:Connect(function() open=not open; list.Visible=open end)
        for _, opt in ipairs(options) do
            local ob = C("TextButton", {Size=UDim2.new(1,0,0,22), BackgroundColor3=Theme.Bg, Text=tostring(opt), TextColor3=Theme.Text, TextSize=11, Font=Enum.Font.Gotham, BorderSizePixel=0, AutoButtonColor=false}, list)
            Corner(ob,4)
            ob.MouseEnter:Connect(function() ob.BackgroundColor3=Theme.Card2 end)
            ob.MouseLeave:Connect(function() ob.BackgroundColor3=Theme.Bg end)
            ob.MouseButton1Click:Connect(function() current=opt; btn.Text=tostring(opt).."  ▼"; list.Visible=false; open=false; if o.Callback then o.Callback(opt) end end)
        end
    end
    function section:ColorPicker(o)
        local r = Row(o.Title, 88)
        local state = {R=(o.Color or Color3.fromRGB(255,255,255)).R, G=(o.Color or Color3.fromRGB(255,255,255)).G, B=(o.Color or Color3.fromRGB(255,255,255)).B}
        local function getColor() return Color3.new(state.R,state.G,state.B) end
        local swatch = C("Frame", {Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-28,0,0), BackgroundColor3=getColor(), BorderSizePixel=0}, r)
        Corner(swatch,5); Stroke(swatch,Theme.Border,1,0.3)
        local function mk(label, yOff, channel)
            C("TextLabel", {Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,0,0,yOff+6), BackgroundTransparency=1, Text=label, TextColor3=Theme.TextDim, TextSize=10, Font=Enum.Font.GothamBold}, r)
            local track = C("Frame", {Size=UDim2.new(1,-50,0,4), Position=UDim2.new(0,18,0,yOff+11), BackgroundColor3=Theme.Track, BorderSizePixel=0}, r)
            Corner(track,2)
            local fill = C("Frame", {Size=UDim2.new(state[channel],0,1,0), BackgroundColor3=Theme.Accent, BorderSizePixel=0}, track)
            Corner(fill,2)
            local hit = C("TextButton", {Size=UDim2.new(1,0,0,12), Position=UDim2.new(0,0,0,yOff+7), BackgroundTransparency=1, Text=""}, r)
            local drag = false
            local function upd(mx)
                local tp = track.AbsolutePosition.X; local tw = math.max(track.AbsoluteSize.X,1)
                local p = math.clamp((mx-tp)/tw,0,1)
                state[channel] = p; fill.Size = UDim2.new(p,0,1,0)
                local c = getColor(); swatch.BackgroundColor3 = c
                if o.Callback then o.Callback(c) end
            end
            hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; upd(UIS:GetMouseLocation().X) end end)
            UIS.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(UIS:GetMouseLocation().X) end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
        end
        mk("R",0,"R"); mk("G",24,"G"); mk("B",48,"B")
    end
    function section:Paragraph(o)
        local r = C("Frame", {Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y}, body)
        C("TextLabel", {Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, Text=o.Content or "", TextColor3=Theme.TextDim, TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, AutomaticSize=Enum.AutomaticSize.Y}, r)
    end
    return section
end

-- ==================== WINDOW ====================
local function CreateWindow(opts)
    opts = opts or {}
    local win = {Tabs={}, TabUsedLabels={}}
    local gui = C("ScreenGui", {Name="ETX_UI", ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, CoreGui)
    local main = C("Frame", {Size=UDim2.new(0,660,0,460), Position=UDim2.new(0.5,-330,0.5,-230), BackgroundColor3=Theme.Bg, BorderSizePixel=0, Active=true}, gui)
    Corner(main,10); Stroke(main,Theme.Border,1,0)
    local top = C("Frame", {Size=UDim2.new(1,0,0,44), BackgroundTransparency=1}, main)
    C("TextLabel", {Size=UDim2.new(0,200,0,22), Position=UDim2.new(0,20,0,8), BackgroundTransparency=1, Text=opts.Title or "ETX", TextColor3=Theme.Text, TextSize=16, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left}, top)
    C("TextLabel", {Size=UDim2.new(0,200,0,12), Position=UDim2.new(0,20,0,28), BackgroundTransparency=1, Text=opts.Subtitle or "", TextColor3=Theme.TextDim, TextSize=10, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left}, top)
    local close = C("TextButton", {Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-36,0,8), BackgroundColor3=Theme.Card, Text="×", TextColor3=Theme.Text, TextSize=20, Font=Enum.Font.GothamBold, BorderSizePixel=0, AutoButtonColor=false}, top)
    Corner(close,6)
    close.MouseEnter:Connect(function() TS:Create(close,TweenInfo.new(0.1),{BackgroundColor3=Theme.Accent}):Play() end)
    close.MouseLeave:Connect(function() TS:Create(close,TweenInfo.new(0.1),{BackgroundColor3=Theme.Card}):Play() end)
    close.MouseButton1Click:Connect(function() gui.Enabled=false end)
    C("Frame", {Size=UDim2.new(1,-20,0,1), Position=UDim2.new(0,10,0,44), BackgroundColor3=Theme.Border, BorderSizePixel=0, BackgroundTransparency=0.5}, main)
    local side = C("Frame", {Size=UDim2.new(0,74,1,-56), Position=UDim2.new(0,10,0,50), BackgroundColor3=Theme.Sidebar, BorderSizePixel=0}, main)
    Corner(side,8)
    local sideList = C("Frame", {Size=UDim2.new(1,0,1,-16), Position=UDim2.new(0,0,0,8), BackgroundTransparency=1}, side)
    C("UIListLayout", {Padding=UDim.new(0,6), HorizontalAlignment=Enum.HorizontalAlignment.Center, SortOrder=Enum.SortOrder.LayoutOrder}, sideList)
    local content = C("ScrollingFrame", {Size=UDim2.new(1,-104,1,-60), Position=UDim2.new(0,94,0,50), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3, ScrollBarImageColor3=Theme.Accent, ScrollBarImageTransparency=0.4, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollingDirection=Enum.ScrollingDirection.Y}, main)
    C("UIListLayout", {Padding=UDim.new(0,10), SortOrder=Enum.SortOrder.LayoutOrder}, content)
    C("UIPadding", {PaddingBottom=UDim.new(0,10), PaddingRight=UDim.new(0,6)}, content)
    do
        local drag, ds, sp = false, nil, nil
        top.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; ds=i.Position; sp=main.Position end end)
        top.InputChanged:Connect(function(i)
            if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d = i.Position-ds
                main.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    end
    UIS.InputBegan:Connect(function(i, gp) if gp then return end; if i.KeyCode==Enum.KeyCode.RightShift then gui.Enabled=not gui.Enabled end end)
    win.Gui = gui
    local function makeLabel(name, explicit)
        if explicit then return explicit end
        local base = string.sub(name,1,4):upper()
        local n = 4
        while win.TabUsedLabels[base] do
            n = n+1; base = string.sub(name,1,n):upper()
            if n > #name then base = base..tostring(math.random(1,99)); break end
        end
        win.TabUsedLabels[base] = true
        return base
    end
    function win:Tab(o)
        local tab = {Name=o.Title or "Tab"}
        local label = makeLabel(tab.Name, o.Short)
        local btn = C("TextButton", {Size=UDim2.new(1,-8,0,40), BackgroundColor3=Theme.Card, Text=label, TextColor3=Theme.TextDim, TextSize=11, Font=Enum.Font.GothamBold, BorderSizePixel=0, AutoButtonColor=false}, sideList)
        Corner(btn,6)
        local page = C("Frame", {Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y, Visible=false}, content)
        C("UIListLayout", {Padding=UDim.new(0,10), SortOrder=Enum.SortOrder.LayoutOrder}, page)
        tab.Button=btn; tab.Page=page
        btn.MouseButton1Click:Connect(function()
            for _,t in ipairs(win.Tabs) do t.Page.Visible=false; t.Button.BackgroundColor3=Theme.Card; t.Button.TextColor3=Theme.TextDim end
            page.Visible=true; btn.BackgroundColor3=Theme.Accent; btn.TextColor3=Theme.White
        end)
        table.insert(win.Tabs, tab)
        if #win.Tabs==1 then page.Visible=true; btn.BackgroundColor3=Theme.Accent; btn.TextColor3=Theme.White end
        function tab:Section(o2) return CreateSection(page, o2) end
        return tab
    end
    return win
end

-- ==================== STATE ====================
local AimbotMaster=false; local AimbotActive=false; local AimbotKeybind="Y"; local AimbotMode="Toggle"
local FOV=150; local TargetPart="Head"; local PredictionEnabled=true
local PredictionLead=true; local PredictionLeadMultiplier=1.0; local PredictionLeadVertical=false
local BulletSpeed=715; local BulletGravity=196.2; local Smoothness=0.15; local MaxDistance=3000  -- ← đổi 5000→3000
local CurrentBulletSpeed=nil; local CapturingKey=false; local CaptureConn=nil
local AutoSaveEnabled=true; local AutoSaveTimerEnabled=false
local TargetLockEnabled=true; local LockedTarget=nil; local ExcludedTarget=nil
local LockReleaseFOVMult=1.8; local LockLostFrames=0; local LockLostGraceFrames=30
local LockSwitchFrames=8; local PendingSwitchTarget=nil; local PendingSwitchCount=0
local TargetNPCEnabled=false
local ESPEnabled=false; local ESPTransparency=0.5; local ESPColor=Color3.fromRGB(0,255,0); local ESPObjects={}
local ESPNPCEnabled=true      -- toggle NPC ESP
local ESPNPCMasterEnabled=true -- master switch cho NPC trong render loop
local ESPDistanceEnabled=true
local ESPDynamicScale=true; local ESPMaxScale=1.0; local ESPMinScale=0.75
local ESPNearDistance=100; local ESPFarDistance=400
local HPBarEnabled=true; local HPBarWidth=120
local HPColorHigh=Color3.fromRGB(0,255,0); local HPColorMid=Color3.fromRGB(255,200,0); local HPColorLow=Color3.fromRGB(255,40,40)
local SkeletonEnabled=true; local SkeletonColor=Color3.fromRGB(255,255,255); local SkeletonThickness=1; local SkeletonObjects={}
local ChinaHatEnabled=true; local ChinaHatColor=Color3.fromRGB(220,30,30); local ChinaHatScale=1; local ChinaHatObjects={}
local ContainerESPEnabled=false; local ContainerESPMasterEnabled=true  -- master switch container
local ContainerESPColor=Color3.fromRGB(255,180,60); local ContainerESPTransparency=0.5; local ContainerObjects={}
local CONTAINER_KEYWORDS={"box","container","crate","case","loot","stash","chest","safe","abpopa","military box"}
local PreviewEnabled=true; local PreviewFrame=nil; local PreviewWorld=nil; local PreviewCam=nil; local PreviewTarget=nil
local ModeratorAlertEnabled=true; local InvisibleAlertEnabled=true; local INVIS_THRESHOLD=0.98
local FLAG_CONSECUTIVE_FRAMES=1; local InvisCounter={}; local Flagged={}
local MOD_GROUP_IDS={}; local MOD_KEYWORDS={"moderator","admin","owner","staff"}
local FullBrightEnabled=false; local OriginalLighting={}
local GrassRemoverEnabled=false; local LeavesRemoverEnabled=false; local HiddenObjects={}
local TargetLineEnabled=true
local TargetLine = Drawing and Drawing.new("Line") or nil
if TargetLine then TargetLine.Visible=false; TargetLine.Color=Theme.Accent; TargetLine.Thickness=1; TargetLine.Transparency=0.8 end
local FOVCircle = Drawing and Drawing.new("Circle") or nil
if FOVCircle then FOVCircle.Visible=false; FOVCircle.Color=Color3.fromRGB(255,255,255); FOVCircle.Thickness=1; FOVCircle.Transparency=0.5; FOVCircle.NumSides=64; FOVCircle.Radius=FOV; FOVCircle.Filled=false end

-- WIKI AMMO
local AMMO_VELOCITY = {
    ["9x18"]=359,["9x18 AP"]=383,["9x18 TFZ"]=404,["9x19"]=465,["9x19 AP"]=500,
    [".45"]=465,[".45 AP"]=515,["7.62x25"]=460,["7.62x25 AP"]=484,
    ["7.62x39"]=715,["7.62x39 AP"]=767,["5.56x45"]=940,["5.56x45 AP"]=990,
    ["5.45x39"]=890,["5.45x39 AP"]=940,["7.62x51"]=850,["7.62x51 AP"]=900,
    ["7.62x54R"]=885,["7.62x54R AP"]=935,["12ga Slug"]=405,["12ga Flechette"]=340,
    ["12ga AP-20"]=625,["9x39"]=450,["9x39 AP"]=490,[".300 BLK"]=550,[".300 BLK AP"]=600,["85mm PG-7V"]=200,
}
local GUN_CALIBER_MAP = {
    ["makarov"]="9x18",["pm"]="9x18",["mp443"]="9x19",["glock"]="9x19",["m1911"]=".45",["colt"]=".45",
    ["tt"]="7.62x25",["tokarev"]="7.62x25",["akmn"]="7.62x39",["akm"]="7.62x39",["ak74"]="5.45x39",
    ["aks74"]="5.45x39",["m4a1"]="5.56x45",["m16"]="5.56x45",["adar"]="5.56x45",["falm"]="7.62x51",
    ["fn fal"]="7.62x51",["svd"]="7.62x54R",["pkm"]="7.62x54R",["mosin"]="7.62x54R",
    ["saiga"]="12ga",["izh"]="12ga",["as val"]="9x39",["vss"]="9x39",["m700"]="7.62x51",["sr-25"]="7.62x51",
}

-- HELPERS
local function GetTargetPart(c, name)
    local h = c:FindFirstChildOfClass("Humanoid"); if not h then return nil end
    if name=="Head" then return c:FindFirstChild("Head")
    elseif name=="Torso" then
        if h.RigType==Enum.HumanoidRigType.R15 then return c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") end
        return c:FindFirstChild("Torso")
    elseif name=="HumanoidRootPart" then return c:FindFirstChild("HumanoidRootPart") end
    return c:FindFirstChild("Head")
end
function IsNPC(m) return Players:GetPlayerFromCharacter(m)==nil end
local function InputMatches(input)
    if input.UserInputType==Enum.UserInputType.Keyboard then return input.KeyCode.Name:upper()==AimbotKeybind
    elseif input.UserInputType==Enum.UserInputType.MouseButton1 then return AimbotKeybind=="MOUSEBUTTON1"
    elseif input.UserInputType==Enum.UserInputType.MouseButton2 then return AimbotKeybind=="MOUSEBUTTON2"
    elseif input.UserInputType==Enum.UserInputType.MouseButton3 then return AimbotKeybind=="MOUSEBUTTON3" end
    return false
end

-- NPC SCANNER
local NPCCache={}; local NPCCacheLastScan=0; local NPCCacheInterval=1.5
local function IsValidNPC(model)
    if not model or not model:IsA("Model") then return false end
    if model==LP.Character then return false end
    if Players:GetPlayerFromCharacter(model)~=nil then return false end
    local hum = model:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local hasPart = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
    if not hasPart then return false end
    return true
end
local function ScanAllNPCs(force)
    local now = tick()
    if not force and now-NPCCacheLastScan < NPCCacheInterval then return NPCCache end
    NPCCacheLastScan = now; NPCCache = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and IsValidNPC(obj) then table.insert(NPCCache, obj) end
    end
    return NPCCache
end

-- CONFIG
local CFG_FOLDER="ETX_Config"; local CFG_FILE=CFG_FOLDER.."/etx_config.json"
local function EnsureFolder() if not isfolder(CFG_FOLDER) then pcall(function() makefolder(CFG_FOLDER) end) end end
local function EncV(v)
    if type(v)=="boolean" then return tostring(v) end
    if type(v)=="number" then return tostring(v) end
    if type(v)=="string" then return '"'..v:gsub('"','\\"')..'"' end
    return '"'..tostring(v)..'"'
end
local function DecV(s)
    s = s:match("^%s*(.-)%s*$")
    if s=="true" then return true elseif s=="false" then return false
    elseif tonumber(s) then return tonumber(s)
    elseif s:sub(1,1)=='"' and s:sub(-1)=='"' then return s:sub(2,-2):gsub('\\"','"') end
    return s
end
local function ColStr(c) return string.format("%.3f,%.3f,%.3f", c.R, c.G, c.B) end
local function StrCol(s)
    local r,g,b = string.match(s, "([%d%.]+),([%d%.]+),([%d%.]+)")
    if r and g and b then return Color3.new(tonumber(r),tonumber(g),tonumber(b)) end
    return Color3.fromRGB(0,255,0)
end
local ConfigSchema = {
    AimbotMaster={get=function() return AimbotMaster end, set=function(v) AimbotMaster=v end},
    AimbotMode={get=function() return AimbotMode end, set=function(v) AimbotMode=v end},
    AimbotKeybind={get=function() return AimbotKeybind end, set=function(v) AimbotKeybind=v end},
    FOV={get=function() return FOV end, set=function(v) FOV=v end},
    TargetPart={get=function() return TargetPart end, set=function(v) TargetPart=v end},
    Smoothness={get=function() return Smoothness end, set=function(v) Smoothness=v end},
    TargetLineEnabled={get=function() return TargetLineEnabled end, set=function(v) TargetLineEnabled=v end},
    TargetNPCEnabled={get=function() return TargetNPCEnabled end, set=function(v) TargetNPCEnabled=v end},
    MaxDistance={get=function() return MaxDistance end, set=function(v) MaxDistance=v end},
    PredictionLead={get=function() return PredictionLead end, set=function(v) PredictionLead=v end},
    PredictionLeadMultiplier={get=function() return PredictionLeadMultiplier end, set=function(v) PredictionLeadMultiplier=v end},
    PredictionLeadVertical={get=function() return PredictionLeadVertical end, set=function(v) PredictionLeadVertical=v end},
    TargetLockEnabled={get=function() return TargetLockEnabled end, set=function(v) TargetLockEnabled=v end},
    LockReleaseFOVMult={get=function() return LockReleaseFOVMult end, set=function(v) LockReleaseFOVMult=v end},
    LockLostGraceFrames={get=function() return LockLostGraceFrames end, set=function(v) LockLostGraceFrames=v end},
    LockSwitchFrames={get=function() return LockSwitchFrames end, set=function(v) LockSwitchFrames=v end},
    PredictionEnabled={get=function() return PredictionEnabled end, set=function(v) PredictionEnabled=v end},
    BulletSpeed={get=function() return BulletSpeed end, set=function(v) BulletSpeed=v end},
    BulletGravity={get=function() return BulletGravity end, set=function(v) BulletGravity=v end},
    ESPEnabled={get=function() return ESPEnabled end, set=function(v) ESPEnabled=v end},
    ESPTransparency={get=function() return ESPTransparency end, set=function(v) ESPTransparency=v end},
    ESPColor={get=function() return ColStr(ESPColor) end, set=function(v) ESPColor=StrCol(v) end},
    ESPNPCEnabled={get=function() return ESPNPCEnabled end, set=function(v) ESPNPCEnabled=v end},
    ESPNPCMasterEnabled={get=function() return ESPNPCMasterEnabled end, set=function(v) ESPNPCMasterEnabled=v end},
    ESPDistanceEnabled={get=function() return ESPDistanceEnabled end, set=function(v) ESPDistanceEnabled=v end},
    ESPDynamicScale={get=function() return ESPDynamicScale end, set=function(v) ESPDynamicScale=v end},
    ESPMaxScale={get=function() return ESPMaxScale end, set=function(v) ESPMaxScale=v end},
    ESPMinScale={get=function() return ESPMinScale end, set=function(v) ESPMinScale=v end},
    ESPNearDistance={get=function() return ESPNearDistance end, set=function(v) ESPNearDistance=v end},
    ESPFarDistance={get=function() return ESPFarDistance end, set=function(v) ESPFarDistance=v end},
    HPBarEnabled={get=function() return HPBarEnabled end, set=function(v) HPBarEnabled=v end},
    HPBarWidth={get=function() return HPBarWidth end, set=function(v) HPBarWidth=v end},
    SkeletonEnabled={get=function() return SkeletonEnabled end, set=function(v) SkeletonEnabled=v end},
    SkeletonThickness={get=function() return SkeletonThickness end, set=function(v) SkeletonThickness=v end},
    SkeletonColor={get=function() return ColStr(SkeletonColor) end, set=function(v) SkeletonColor=StrCol(v) end},
    ChinaHatEnabled={get=function() return ChinaHatEnabled end, set=function(v) ChinaHatEnabled=v end},
    ChinaHatScale={get=function() return ChinaHatScale end, set=function(v) ChinaHatScale=v end},
    ChinaHatColor={get=function() return ColStr(ChinaHatColor) end, set=function(v) ChinaHatColor=StrCol(v) end},
    ContainerESPEnabled={get=function() return ContainerESPEnabled end, set=function(v) ContainerESPEnabled=v end},
    ContainerESPMasterEnabled={get=function() return ContainerESPMasterEnabled end, set=function(v) ContainerESPMasterEnabled=v end},
    ContainerESPTransparency={get=function() return ContainerESPTransparency end, set=function(v) ContainerESPTransparency=v end},
    ContainerESPColor={get=function() return ColStr(ContainerESPColor) end, set=function(v) ContainerESPColor=StrCol(v) end},
    PreviewEnabled={get=function() return PreviewEnabled end, set=function(v) PreviewEnabled=v end},
    ModeratorAlertEnabled={get=function() return ModeratorAlertEnabled end, set=function(v) ModeratorAlertEnabled=v end},
    InvisibleAlertEnabled={get=function() return InvisibleAlertEnabled end, set=function(v) InvisibleAlertEnabled=v end},
    FLAG_CONSECUTIVE_FRAMES={get=function() return FLAG_CONSECUTIVE_FRAMES end, set=function(v) FLAG_CONSECUTIVE_FRAMES=v end},
    FullBrightEnabled={get=function() return FullBrightEnabled end, set=function(v) FullBrightEnabled=v end},
    GrassRemoverEnabled={get=function() return GrassRemoverEnabled end, set=function(v) GrassRemoverEnabled=v end},
    LeavesRemoverEnabled={get=function() return LeavesRemoverEnabled end, set=function(v) LeavesRemoverEnabled=v end},
    AutoSaveEnabled={get=function() return AutoSaveEnabled end, set=function(v) AutoSaveEnabled=v end},
    AutoSaveTimerEnabled={get=function() return AutoSaveTimerEnabled end, set=function(v) AutoSaveTimerEnabled=v end},
}
local function SaveConfig()
    EnsureFolder(); local lines = {"{"}
    for k,e in pairs(ConfigSchema) do table.insert(lines, string.format('  "%s": %s,', k, EncV(e.get()))) end
    table.insert(lines,"}")
    pcall(function() writefile(CFG_FILE, table.concat(lines,"\n")) end)
end
local function LoadConfig()
    EnsureFolder(); if not isfile(CFG_FILE) then return false, 0 end
    local ok, content = pcall(function() return readfile(CFG_FILE) end)
    if not ok or not content then return false, 0 end
    local n = 0
    for k,v in content:gmatch('"([^"]+)":%s*([^,\n}]+)') do
        if ConfigSchema[k] then pcall(function() ConfigSchema[k].set(DecV(v)) end); n = n + 1 end
    end
    return true, n
end
local function ResetConfig() pcall(function() if isfile(CFG_FILE) then delfile(CFG_FILE) end end) end
local configLoaded, configCount = LoadConfig()

-- SCALE
local function GetDistanceScale(d)
    if not ESPDynamicScale then return 1 end
    if d<=ESPNearDistance then return ESPMaxScale end
    if d>=ESPFarDistance then return ESPMinScale end
    local t = (d-ESPNearDistance)/(ESPFarDistance-ESPNearDistance)
    return ESPMaxScale - t*(ESPMaxScale-ESPMinScale)
end
local function ApplyESPScale(data, s)
    data.Billboard.Size = UDim2.new(0, data.BaseBB.X*s, 0, data.BaseBB.Y*s)
    data.NameLabel.TextSize = math.max(11, data.BaseNameSize*s)
    data.DistLabel.TextSize = math.max(10, data.BaseDistSize*s)
    data.HPText.TextSize = math.max(10, data.BaseHPSize*s)
    data.HPBg.Size = UDim2.new(0, data.BaseHPWidth*s, 0, math.max(4, data.BaseHPHeight*s))
    data.HPBg.Position = UDim2.new(0.5, -data.BaseHPWidth*s/2, 0, 0)
    data.NameLabel.Position = UDim2.new(0, 0, 0, 7*s)
    data.DistLabel.Position = UDim2.new(0, 0, 0, 24*s)
    data.HPText.Position = UDim2.new(0, 0, 0, 39*s)
    data.Billboard.StudsOffset = Vector3.new(0, 3.2*math.max(0.8,s), 0)
end

-- GUN SCAN
local function GetAmmoKey(cal, typ)
    cal = string.lower(cal or ""):gsub("%s",""); typ = string.lower(typ or "")
    if cal:find("9x18") then
        if typ:find("tfz") then return "9x18 TFZ" elseif typ:find("ap") or typ:find("armor") then return "9x18 AP" else return "9x18" end
    elseif cal:find("9x19") then return (typ:find("ap") or typ:find("armor")) and "9x19 AP" or "9x19"
    elseif cal:find("45") then return (typ:find("ap") or typ:find("armor")) and ".45 AP" or ".45"
    elseif cal:find("7.62x25") then return (typ:find("ap") or typ:find("armor")) and "7.62x25 AP" or "7.62x25"
    elseif cal:find("7.62x39") then return (typ:find("ap") or typ:find("armor")) and "7.62x39 AP" or "7.62x39"
    elseif cal:find("5.56x45") then return (typ:find("ap") or typ:find("armor")) and "5.56x45 AP" or "5.56x45"
    elseif cal:find("5.45x39") then return (typ:find("ap") or typ:find("armor")) and "5.45x39 AP" or "5.45x39"
    elseif cal:find("7.62x51") then return (typ:find("ap") or typ:find("armor")) and "7.62x51 AP" or "7.62x51"
    elseif cal:find("7.62x54") then return (typ:find("ap") or typ:find("armor")) and "7.62x54R AP" or "7.62x54R"
    elseif cal:find("12ga") then
        if typ:find("slug") then return "12ga Slug" elseif typ:find("flechette") then return "12ga Flechette"
        elseif typ:find("ap") or typ:find("armor") then return "12ga AP-20" else return "12ga Slug" end
    elseif cal:find("9x39") then return (typ:find("ap") or typ:find("armor")) and "9x39 AP" or "9x39"
    elseif cal:find("300") or cal:find("blk") then return (typ:find("ap") or typ:find("armor")) and ".300 BLK AP" or ".300 BLK"
    elseif cal:find("85") then return "85mm PG-7V" end
    return nil
end
local function ScanGunVelocity()
    local char = LP.Character; if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool"); if not tool then return nil end
    local cal, typ = nil, nil
    for _, attr in ipairs(tool:GetAttributes()) do
        local l = string.lower(attr)
        if l:find("caliber") or l:find("ammotype") or l:find("ammo") then
            local v = tool:GetAttribute(attr)
            if type(v)=="string" then if l:find("caliber") then cal = v else typ = v end end
        end
    end
    for _, d in ipairs(tool:GetDescendants()) do
        if d:IsA("ValueBase") then
            local l = string.lower(d.Name)
            if l:find("caliber") then cal = tostring(d.Value)
            elseif l:find("ammotype") or l:find("ammo") then typ = tostring(d.Value) end
        elseif d:IsA("TextLabel") or d:IsA("TextButton") then
            local t = d.Text or ""; local l = string.lower(t)
            if l:find("caliber") then local c = t:match("[:%s]+([%w%.]+)"); if c then cal = c end
            elseif l:find("ammotype") or l:find("ammo") then local a = t:match("[:%s]+([%w%.]+)"); if a then typ = a end end
        end
    end
    if not cal then
        local n = string.lower(tool.Name)
        for pat, c in pairs(GUN_CALIBER_MAP) do if n:find(pat) then cal = c; break end end
    end
    if not cal then return nil end
    local key = GetAmmoKey(cal, typ)
    if key and AMMO_VELOCITY[key] then return AMMO_VELOCITY[key] end
    return nil
end
local function UpdateBulletSpeed()
    local s = ScanGunVelocity()
    if s then CurrentBulletSpeed = s; BulletSpeed = s; return true end
    return false
end

-- BALLISTIC
local function PredictTargetPosition(part, speed)
    if not part then return nil end
    local pos = part.Position
    if not PredictionEnabled then return pos end
    local dist = (pos - Camera.CFrame.Position).Magnitude
    if dist < 1 then return pos end
    local t = dist / speed
    if PredictionLead then
        local c = part:FindFirstAncestorOfClass("Model")
        local root = c and c:FindFirstChild("HumanoidRootPart")
        if root then
            local v = root.AssemblyLinearVelocity
            local hv = Vector3.new(v.X, 0, v.Z)
            if PredictionLeadVertical then hv = v end
            pos = pos + hv*t*PredictionLeadMultiplier
        end
    end
    return pos + Vector3.new(0, 0.5*BulletGravity*t*t, 0)
end

-- TARGET LOCK
local function IsTargetValid(c, mult)
    if not c or not c.Parent then return false end
    local h = c:FindFirstChildOfClass("Humanoid"); if not h or h.Health<=0 then return false end
    local r = c:FindFirstChild("HumanoidRootPart"); if not r then return false end
    local d = (r.Position-Camera.CFrame.Position).Magnitude; if d>MaxDistance then return false end
    local sp, on = Camera:WorldToViewportPoint(r.Position); if not on then return false end
    local m = UIS:GetMouseLocation()
    return (Vector2.new(sp.X,sp.Y)-m).Magnitude <= FOV*(mult or 1)
end
local function FindClosestInFOV(lim, skip)
    local best, short = nil, math.huge
    local mp = UIS:GetMouseLocation()
    for _, p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local c = p.Character; if not c or c==skip then continue end
        local h = c:FindFirstChildOfClass("Humanoid"); if not h or h.Health<=0 then continue end
        local r = c:FindFirstChild("HumanoidRootPart"); if not r then continue end
        local d = (r.Position-Camera.CFrame.Position).Magnitude; if d>MaxDistance then continue end
        local sp, on = Camera:WorldToViewportPoint(r.Position); if not on then continue end
        local dm = (Vector2.new(sp.X,sp.Y)-mp).Magnitude
        if dm<lim and dm<short then short=dm; best=c end
    end
    if TargetNPCEnabled then
        for _, npc in ipairs(ScanAllNPCs()) do
            if npc and npc~=skip and npc.Parent then
                local h = npc:FindFirstChildOfClass("Humanoid")
                if h and h.Health>0 then
                    local r = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head") or npc:FindFirstChild("UpperTorso") or npc:FindFirstChild("Torso")
                    if r then
                        local d = (r.Position-Camera.CFrame.Position).Magnitude
                        if d<=MaxDistance then
                            local sp, on = Camera:WorldToViewportPoint(r.Position)
                            if on then
                                local dm = (Vector2.new(sp.X,sp.Y)-mp).Magnitude
                                if dm<lim and dm<short then short=dm; best=npc end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end
local function GetClosestTarget()
    if ExcludedTarget and not ExcludedTarget.Parent then ExcludedTarget = nil end
    if not TargetLockEnabled then return FindClosestInFOV(FOV, ExcludedTarget) end
    if LockedTarget then
        if IsTargetValid(LockedTarget, LockReleaseFOVMult) then
            LockLostFrames = 0
            local cand = FindClosestInFOV(FOV, ExcludedTarget)
            if cand and cand~=LockedTarget then
                if PendingSwitchTarget==cand then PendingSwitchCount=PendingSwitchCount+1
                else PendingSwitchTarget=cand; PendingSwitchCount=1 end
                if PendingSwitchCount>=LockSwitchFrames then LockedTarget=cand; PendingSwitchTarget=nil; PendingSwitchCount=0 end
            else PendingSwitchTarget=nil; PendingSwitchCount=0 end
            return LockedTarget
        else
            LockLostFrames = LockLostFrames + 1
            if LockLostFrames < LockLostGraceFrames then return LockedTarget
            else LockedTarget=nil; LockLostFrames=0; PendingSwitchTarget=nil; PendingSwitchCount=0 end
        end
    end
    local f = FindClosestInFOV(FOV, ExcludedTarget)
    if f then LockedTarget=f; LockLostFrames=0 end
    return f
end
local function ClearTargetLock(ex)
    if ex and LockedTarget then ExcludedTarget = LockedTarget end
    LockedTarget=nil; LockLostFrames=0; PendingSwitchTarget=nil; PendingSwitchCount=0
end
local function ClearExclusion() ExcludedTarget = nil end

-- FULLBRIGHT
local function SaveLighting()
    OriginalLighting = {Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient, Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime, GlobalShadows=Lighting.GlobalShadows, FogEnd=Lighting.FogEnd, FogStart=Lighting.FogStart, FogColor=Lighting.FogColor, ExposureCompensation=Lighting.ExposureCompensation, EnvironmentDiffuseScale=Lighting.EnvironmentDiffuseScale, EnvironmentSpecularScale=Lighting.EnvironmentSpecularScale}
end
local function ApplyFullBright()
    SaveLighting()
    Lighting.Ambient=Color3.fromRGB(178,178,178); Lighting.OutdoorAmbient=Color3.fromRGB(178,178,178)
    Lighting.Brightness=3; Lighting.ClockTime=14; Lighting.GlobalShadows=false
    Lighting.FogEnd=1e6; Lighting.FogStart=1e6; Lighting.FogColor=Color3.fromRGB(200,200,200)
    Lighting.ExposureCompensation=0.5; Lighting.EnvironmentDiffuseScale=1; Lighting.EnvironmentSpecularScale=1
end
local function RestoreLighting()
    if not OriginalLighting.Ambient then return end
    for k,v in pairs(OriginalLighting) do pcall(function() Lighting[k]=v end) end
end

-- GRASS/LEAVES
local GRASS_KW={"grass","foliage","bush","shrub","plant"}
local LEAVES_KW={"leaf","leaves","tree","branch","pine","oak","canopy"}
function NameMatch(name, kws)
    local l = string.lower(name)
    for _, k in ipairs(kws) do if l:find(k,1,true) then return true end end
    return false
end
local function HideObject(obj, tag)
    if HiddenObjects[obj] then return end
    local store = {}
    if obj:IsA("BasePart") then
        store.Transparency=obj.Transparency; store.CanCollide=obj.CanCollide; store.CanQuery=obj.CanQuery; store.CanTouch=obj.CanTouch
        pcall(function() obj.Transparency=1 end); pcall(function() obj.CanCollide=false end)
        pcall(function() obj.CanQuery=false end); pcall(function() obj.CanTouch=false end)
    elseif obj:IsA("Model") then
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("BasePart") then
                store[d] = {Transparency=d.Transparency, CanCollide=d.CanCollide}
                pcall(function() d.Transparency=1 end); pcall(function() d.CanCollide=false end)
            end
        end
    end
    HiddenObjects[obj] = {store=store, tag=tag}
end
local function ShowObject(obj)
    local d = HiddenObjects[obj]; if not d then return end
    if obj:IsA("BasePart") then
        pcall(function() obj.Transparency=d.store.Transparency end); pcall(function() obj.CanCollide=d.store.CanCollide end)
        pcall(function() obj.CanQuery=d.store.CanQuery end); pcall(function() obj.CanTouch=d.store.CanTouch end)
    elseif obj:IsA("Model") then
        for part, s in pairs(d.store) do
            if part and part.Parent then
                pcall(function() part.Transparency=s.Transparency end); pcall(function() part.CanCollide=s.CanCollide end)
            end
        end
    end
    HiddenObjects[obj] = nil
end
local function ScanWorldFor(tag, kws)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("Model")) and NameMatch(obj.Name, kws) then HideObject(obj, tag) end
    end
end
local function RemoveAllGrass() ScanWorldFor("grass", GRASS_KW) end
local function RemoveAllLeaves() ScanWorldFor("leaves", LEAVES_KW) end
local function RestoreAllHidden()
    local list = {}
    for o in pairs(HiddenObjects) do table.insert(list, o) end
    for _, o in ipairs(list) do ShowObject(o) end
end

-- AIMBOT
local function AimAt(target)
    if not target then return end
    local part = GetTargetPart(target, TargetPart); if not part then return end
    local spd = CurrentBulletSpeed or BulletSpeed
    local p = PredictTargetPosition(part, spd); if not p then return end
    local cur = Camera.CFrame
    Camera.CFrame = cur:Lerp(CFrame.new(cur.Position, p), Smoothness)
end

-- ESP
local function CreateESP(c)
    if not c or ESPObjects[c] then return end
    local head = c:FindFirstChild("Head"); if not head then return end
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0,160,0,62); bb.StudsOffset = Vector3.new(0,3.2,0); bb.AlwaysOnTop=true; bb.Parent=head
    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(0,HPBarWidth,0,5); hpBg.Position = UDim2.new(0.5,-HPBarWidth/2,0,0)
    hpBg.BackgroundColor3 = Color3.fromRGB(20,20,20); hpBg.BorderSizePixel = 1; hpBg.BorderColor3 = Color3.fromRGB(0,0,0)
    hpBg.Visible = HPBarEnabled; hpBg.Parent = bb
    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1,0,1,0); hpFill.BackgroundColor3 = HPColorHigh; hpFill.BorderSizePixel = 0; hpFill.Parent = hpBg
    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1,0,0,16); nl.Position = UDim2.new(0,0,0,7); nl.BackgroundTransparency = 1
    nl.TextColor3 = ESPColor; nl.TextStrokeTransparency = 0.2; nl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    nl.TextSize = 15; nl.Font = Enum.Font.SourceSansBold; nl.Text = "Unknown"; nl.Parent = bb
    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1,0,0,14); dl.Position = UDim2.new(0,0,0,24); dl.BackgroundTransparency = 1
    dl.TextColor3 = ESPColor; dl.TextStrokeTransparency = 0.2; dl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    dl.TextSize = 13; dl.Font = Enum.Font.SourceSansBold; dl.Text = "[0m]"; dl.Parent = bb
    local hpText = Instance.new("TextLabel")
    hpText.Size = UDim2.new(1,0,0,13); hpText.Position = UDim2.new(0,0,0,39); hpText.BackgroundTransparency = 1
    hpText.TextColor3 = Color3.fromRGB(255,255,255); hpText.TextStrokeTransparency = 0.3; hpText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    hpText.TextSize = 12; hpText.Font = Enum.Font.SourceSansBold; hpText.Text = "100%"; hpText.Visible = HPBarEnabled; hpText.Parent = bb
    local hl = Instance.new("Highlight")
    hl.FillColor = ESPColor; hl.FillTransparency = ESPTransparency; hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.OutlineTransparency = 0.5; hl.Adornee = c; hl.Parent = c
    ESPObjects[c] = {Billboard=bb, NameLabel=nl, DistLabel=dl, HPBg=hpBg, HPFill=hpFill, HPText=hpText, Highlight=hl, Character=c, BaseBB=Vector2.new(160,62), BaseNameSize=15, BaseDistSize=13, BaseHPSize=12, BaseHPWidth=HPBarWidth, BaseHPHeight=5}
end
local function RemoveESP(c)
    local d = ESPObjects[c]
    if d then if d.Billboard then d.Billboard:Destroy() end; if d.Highlight then d.Highlight:Destroy() end; ESPObjects[c]=nil end
end
local function UpdateESP()
    if not ESPEnabled then
        for c in pairs(ESPObjects) do RemoveESP(c) end
        if ClearAllSkeletons then ClearAllSkeletons() end
        if ClearAllHats then ClearAllHats() end
        return
    end
    -- player ESP selalu jalan kalau ESPEnabled
    for _, p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then CreateESP(p.Character) end end
    -- NPC ESP hanya kalau dua flag aktif
    if ESPNPCEnabled and ESPNPCMasterEnabled then
        for _, n in ipairs(ScanAllNPCs()) do if n and n.Parent then CreateESP(n) end end
    end
    for c, d in pairs(ESPObjects) do
        if not c or not c.Parent then RemoveESP(c); continue end
        -- nếu là NPC và NPC ESP tắt thì xóa
        local isNPC = Players:GetPlayerFromCharacter(c) == nil
        if isNPC and (not ESPNPCEnabled or not ESPNPCMasterEnabled) then RemoveESP(c); continue end
        local h = c:FindFirstChildOfClass("Humanoid")
        local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Head") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")
        if r and d.Billboard then
            local dist = (r.Position-Camera.CFrame.Position).Magnitude
            if dist > MaxDistance then
                d.Billboard.Enabled = false
                if d.Highlight then d.Highlight.Enabled = false end
            else
                d.Billboard.Enabled = true
                if d.Highlight then d.Highlight.Enabled = true end
                d.DistLabel.Text = "["..math.floor(dist).."m]"
                d.DistLabel.Visible = ESPDistanceEnabled
                local pl = Players:GetPlayerFromCharacter(c)
                d.NameLabel.Text = pl and pl.Name or (c.Name.." (NPC)")
                ApplyESPScale(d, GetDistanceScale(dist))
                if h and d.HPFill then
                    local pct = math.clamp(h.Health/math.max(h.MaxHealth,1), 0, 1)
                    d.HPFill.Size = UDim2.new(pct,0,1,0)
                    d.HPText.Text = math.floor(pct*100).."%"
                    if pct>0.6 then d.HPFill.BackgroundColor3 = HPColorHigh
                    elseif pct>0.3 then d.HPFill.BackgroundColor3 = HPColorMid
                    else d.HPFill.BackgroundColor3 = HPColorLow end
                    d.HPBg.Visible = HPBarEnabled; d.HPText.Visible = HPBarEnabled
                end
            end
        end
    end
end

-- CONTAINER ESP
function NameMatchContainer(n)
    local l = string.lower(n)
    for _, k in ipairs(CONTAINER_KEYWORDS) do if l:find(k,1,true) then return true end end
    return false
end
local function IsContainer(m)
    if not m or not m:IsA("Model") then return false end
    if m:FindFirstChildOfClass("Humanoid") then return false end
    if Players:GetPlayerFromCharacter(m) then return false end
    local size = m:GetAttribute("ContainerSize") or m:GetAttribute("Size")
    if size and type(size)=="string" then
        local l = string.lower(size)
        if l:find("big") or l:find("large") or l:find("small") or l:find("medium") then return true end
    end
    if m:GetAttribute("StorageSlots") or m:GetAttribute("Storage Slots") then return true end
    if NameMatchContainer(m.Name) then return true end
    for _, d in ipairs(m:GetChildren()) do
        if d:IsA("BasePart") and NameMatchContainer(d.Name) then return true end
    end
    return false
end
local function CreateContainerESP(m)
    if ContainerObjects[m] then return end
    local a = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart"); if not a then return end
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0,170,0,38); bb.StudsOffset = Vector3.new(0,4,0); bb.AlwaysOnTop = true; bb.Parent = a
    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1,0,0,18); nl.BackgroundTransparency = 1; nl.TextColor3 = ContainerESPColor
    nl.TextStrokeTransparency = 0.2; nl.TextStrokeColor3 = Color3.fromRGB(0,0,0); nl.TextSize = 14
    nl.Font = Enum.Font.SourceSansBold; nl.Text = m.Name; nl.Parent = bb
    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1,0,0,14); dl.Position = UDim2.new(0,0,0,18); dl.BackgroundTransparency = 1
    dl.TextColor3 = ContainerESPColor; dl.TextStrokeTransparency = 0.2; dl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    dl.TextSize = 12; dl.Font = Enum.Font.SourceSans; dl.Text = "[0m]"; dl.Parent = bb
    local hl = Instance.new("Highlight")
    hl.FillColor = ContainerESPColor; hl.FillTransparency = ContainerESPTransparency
    hl.OutlineColor = Color3.fromRGB(255,255,255); hl.OutlineTransparency = 0.4; hl.Adornee = m; hl.Parent = m
    ContainerObjects[m] = {Billboard=bb, NameLabel=nl, DistLabel=dl, Highlight=hl, Model=m, Anchor=a, BaseBB=Vector2.new(170,38), BaseNameSize=14, BaseDistSize=12}
end
local function RemoveContainerESP(m)
    local d = ContainerObjects[m]
    if d then if d.Billboard then d.Billboard:Destroy() end; if d.Highlight then d.Highlight:Destroy() end; ContainerObjects[m]=nil end
end
local function UpdateContainerESP()
    if not ContainerESPEnabled or not ContainerESPMasterEnabled or not ESPEnabled then
        for m in pairs(ContainerObjects) do RemoveContainerESP(m) end; return
    end
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("Model") and IsContainer(o) then CreateContainerESP(o) end
    end
    for m, d in pairs(ContainerObjects) do
        if not m or not m.Parent then RemoveContainerESP(m); continue end
        local a = m.PrimaryPart or d.Anchor
        if a and a.Parent and d.Billboard then
            local dist = (a.Position-Camera.CFrame.Position).Magnitude
            if dist > MaxDistance then d.Billboard.Enabled = false; d.Highlight.Enabled = false
            else
                d.Billboard.Enabled = true; d.Highlight.Enabled = true; d.Billboard.Adornee = a
                d.DistLabel.Text = "["..math.floor(dist).."m]"
                d.DistLabel.Visible = ESPDistanceEnabled
                d.NameLabel.Text = m.Name
                local s = GetDistanceScale(dist)
                d.Billboard.Size = UDim2.new(0, d.BaseBB.X*s, 0, d.BaseBB.Y*s)
                d.NameLabel.TextSize = math.max(10, d.BaseNameSize*s)
                d.DistLabel.TextSize = math.max(9, d.BaseDistSize*s)
                d.DistLabel.Position = UDim2.new(0,0,0, 18*s)
            end
        end
    end
end

-- SKELETON
local SKEL15 = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local SKEL6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
function GetBones(c)
    local h = c:FindFirstChildOfClass("Humanoid")
    if h and h.RigType==Enum.HumanoidRigType.R15 then return SKEL15 end
    return SKEL6
end
local function CreateSkeleton(c)
    if SkeletonObjects[c] then return end
    local bones = GetBones(c); local lines = {}
    for _ = 1, #bones do
        local l = Drawing.new("Line")
        l.Visible = false; l.Color = SkeletonColor; l.Thickness = SkeletonThickness; l.Transparency = 1
        table.insert(lines, l)
    end
    SkeletonObjects[c] = {Lines=lines, Bones=bones}
end
local function RemoveSkeleton(c)
    local d = SkeletonObjects[c]
    if d then for _, l in ipairs(d.Lines) do l:Remove() end; SkeletonObjects[c]=nil end
end
local function UpdateSkeleton(c)
    local d = SkeletonObjects[c]; if not d then return end
    if not c.Parent then RemoveSkeleton(c); return end
    for i, b in ipairs(d.Bones) do
        local a = c:FindFirstChild(b[1]); local b2 = c:FindFirstChild(b[2]); local l = d.Lines[i]
        if a and b2 then
            local ap = a.Position + Vector3.new(0, (a.Size.Y/2-0.3)*(b[1]=="Head" and -1 or 0), 0)
            local bp = b2.Position + Vector3.new(0, b2.Size.Y/2-0.3, 0)
            local a2d, aOn = Camera:WorldToViewportPoint(ap)
            local b2d, bOn = Camera:WorldToViewportPoint(bp)
            if aOn and bOn then
                l.From = Vector2.new(a2d.X, a2d.Y); l.To = Vector2.new(b2d.X, b2d.Y)
                l.Color = SkeletonColor; l.Thickness = SkeletonThickness; l.Visible = true
            else l.Visible = false end
        else l.Visible = false end
    end
end
function ClearAllSkeletons() for c in pairs(SkeletonObjects) do RemoveSkeleton(c) end end

-- CHINA HAT
local CONE = "rbxassetid://1033714"
local function CreateChinaHat(c)
    if ChinaHatObjects[c] then return end
    local h = c:FindFirstChild("Head"); if not h then return end
    local hat = Instance.new("Part")
    hat.Shape = Enum.PartType.Cylinder; hat.Size = Vector3.new(2,2.4,2.4)*ChinaHatScale
    hat.Anchored = true; hat.CanCollide = false; hat.CanQuery = false; hat.CanTouch = false
    hat.Massless = true; hat.CastShadow = false; hat.Material = Enum.Material.SmoothPlastic
    hat.Color = ChinaHatColor; hat.Transparency = 0.05
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh; mesh.MeshId = CONE
    mesh.Scale = Vector3.new(ChinaHatScale, ChinaHatScale, ChinaHatScale)
    mesh.Parent = hat
    hat.Parent = Workspace
    ChinaHatObjects[c] = hat
end
local function UpdateChinaHat(c)
    local h = ChinaHatObjects[c]; if not h then return end
    if not c.Parent then h:Destroy(); ChinaHatObjects[c]=nil; return end
    local head = c:FindFirstChild("Head"); if not head then h.Transparency = 1; return end
    h.Transparency = 0.05; h.Color = ChinaHatColor
    h.CFrame = head.CFrame * CFrame.new(0, head.Size.Y/2 + 2.5*ChinaHatScale, 0) * CFrame.Angles(0,0,math.rad(90))
end
local function RemoveChinaHat(c)
    local h = ChinaHatObjects[c]
    if h then h:Destroy(); ChinaHatObjects[c]=nil end
end
function ClearAllHats() for c in pairs(ChinaHatObjects) do RemoveChinaHat(c) end end

-- INVIS / MOD
function PartIsVisible(p)
    if p.Transparency < INVIS_THRESHOLD then return true end
    local l = p.LocalTransparencyModifier
    if l and l < INVIS_THRESHOLD then return true end
    return false
end
function IsFullyInvisible(c)
    if not c then return false end
    local hasAny = false
    for _, d in ipairs(c:GetDescendants()) do
        if d:IsA("BasePart") then
            hasAny = true
            if PartIsVisible(d) then return false end
        elseif d:IsA("Decal") or d:IsA("Texture") then
            if d.Transparency < INVIS_THRESHOLD then return false end
        elseif d:IsA("Accessory") then
            local h = d:FindFirstChild("Handle")
            if h and h:IsA("BasePart") and PartIsVisible(h) then return false end
        elseif d:IsA("Shirt") or d:IsA("Pants") then return false end
    end
    if not hasAny then return false end
    return true
end
local function EvaluateVisibility(c)
    if not InvisibleAlertEnabled or not c then return false end
    local pl = Players:GetPlayerFromCharacter(c)
    local name = pl and pl.Name or (c.Name.." (NPC)")
    local invis = IsFullyInvisible(c)
    if invis then InvisCounter[name] = (InvisCounter[name] or 0) + 1
    else
        InvisCounter[name] = 0
        if Flagged[name] then
            Flagged[name] = nil
            local d = ESPObjects[c]
            if d and d.Highlight then d.Highlight.FillColor = ESPColor; d.Highlight.FillTransparency = ESPTransparency end
        end
    end
    if InvisCounter[name] >= FLAG_CONSECUTIVE_FRAMES and not Flagged[name] then
        Flagged[name] = true
        Notify("⚠ MODERATOR DETECTED", name.." — model tàng hình", 10)
        local d = ESPObjects[c]
        if d and d.Highlight then d.Highlight.FillColor = Color3.fromRGB(255,0,0); d.Highlight.FillTransparency = 0.1 end
    end
    return invis
end
local function CheckModerator(p)
    if not ModeratorAlertEnabled then return false end
    for _, gid in ipairs(MOD_GROUP_IDS) do
        local ok, rank = pcall(function() return p:GetRankInGroup(gid) end)
        if ok and rank and rank >= 200 then return true end
    end
    local l = string.lower(p.Name)
    for _, k in ipairs(MOD_KEYWORDS) do if l:find(k) then return true end end
    local dn = string.lower(p.DisplayName or "")
    for _, k in ipairs(MOD_KEYWORDS) do if dn:find(k) then return true end end
    return false
end
local function ScanForModerators(notify)
    local found = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p~=LP and CheckModerator(p) then table.insert(found, p.Name) end
    end
    if notify and #found>0 then Notify("⚠ MODERATOR", table.concat(found, ", "), 8) end
    return found
end
Players.PlayerAdded:Connect(function(p)
    task.wait(1)
    if CheckModerator(p) then Notify("⚠ MODERATOR JOINED", p.Name, 8) end
end)

-- PREVIEW
local function SafeClone(c)
    local states = {}; local targets = {c}
    for _, d in ipairs(c:GetDescendants()) do
        if d:IsA("BasePart") or d:IsA("Model") or d:IsA("Accessory") or d:IsA("Decal") or d:IsA("Shirt") or d:IsA("Pants") then table.insert(targets, d) end
    end
    for _, d in ipairs(targets) do states[d] = d.Archivable; pcall(function() d.Archivable = true end) end
    local ok, cl = pcall(function() return c:Clone() end)
    for d, s in pairs(states) do if d and d.Parent then pcall(function() d.Archivable = s end) end end
    if not ok or not cl then return nil end
    return cl
end
local function CreatePreviewFrame()
    if PreviewFrame then return end
    local sg = C("ScreenGui", {Name="ETX_Preview", ResetOnSpawn=false, IgnoreGuiInset=true}, CoreGui)
    local f = C("Frame", {Size=UDim2.new(0,200,0,200), Position=UDim2.new(0,20,1,-220), BackgroundColor3=Theme.Card, BorderSizePixel=0, Active=true}, sg)
    Corner(f,8); Stroke(f,Theme.Accent,1,0.5)
    C("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, TextColor3=Theme.Accent, TextSize=13, Font=Enum.Font.GothamBold, Text="No target", Name="Title"}, f)
    local vp = C("ViewportFrame", {Size=UDim2.new(1,-8,1,-28), Position=UDim2.new(0,4,0,24), BackgroundColor3=Theme.Bg, BackgroundTransparency=0.5, Ambient=Color3.fromRGB(180,180,180), LightColor=Color3.fromRGB(255,255,255)}, f)
    local world = C("WorldModel", {}, vp)
    local cam = C("Camera", {FieldOfView=30}, vp); vp.CurrentCamera = cam
    PreviewFrame=f; PreviewWorld=world; PreviewCam=cam
    local drag, ds, sp = false, nil, nil
    f.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; ds=i.Position; sp=f.Position end end)
    f.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d = i.Position-ds
            f.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
end
local function ClearPreview()
    if not PreviewWorld then return end
    for _, c in ipairs(PreviewWorld:GetChildren()) do if c:IsA("Model") then c:Destroy() end end
    PreviewTarget = nil
    if PreviewFrame then PreviewFrame.Title.Text = "No target"; PreviewFrame.Title.TextColor3 = Theme.Accent end
end
local function SetPreviewTarget(c)
    if not PreviewWorld then return end
    if PreviewTarget==c then return end
    ClearPreview(); if not c then return end
    local cl = SafeClone(c); if not cl then return end
    for _, d in ipairs(cl:GetDescendants()) do if d:IsA("BasePart") then pcall(function() d.Anchored = false end) end end
    cl.Parent = PreviewWorld
    local h = cl:FindFirstChildOfClass("Humanoid")
    if h then if not h:FindFirstChildOfClass("Animator") then C("Animator", {}, h) end; h.PlatformStand = true end
    local ok, center = pcall(function() return cl:GetPivot().Position end)
    if not ok or not center then center = Vector3.new(0,0,0) end
    local ok2, size = pcall(function() return cl:GetExtentsSize() end)
    if not ok2 or not size then size = Vector3.new(4,6,4) end
    local dist = math.max(size.X,size.Y,size.Z)*2.2
    PreviewCam.CFrame = CFrame.new(center + Vector3.new(0, size.Y*0.2, dist), center)
    PreviewTarget = c
    local pl = Players:GetPlayerFromCharacter(c)
    local name = pl and pl.Name or (c.Name.." (NPC)")
    if PreviewFrame then PreviewFrame.Title.Text = name; PreviewFrame.Title.TextColor3 = Theme.Accent end
end
local function SyncPreviewAnimation()
    if not PreviewTarget or not PreviewTarget.Parent then return end
    if not PreviewWorld then return end
    local cl = nil
    for _, c in ipairs(PreviewWorld:GetChildren()) do if c:IsA("Model") then cl = c; break end end
    if not cl then return end
    for _, om in ipairs(PreviewTarget:GetDescendants()) do
        if om:IsA("Motor6D") then
            local pn = om.Parent and om.Parent.Name
            if pn then
                local cp = cl:FindFirstChild(pn, true)
                if cp then
                    local cm = cp:FindFirstChild(om.Name)
                    if cm and cm:IsA("Motor6D") then pcall(function() cm.C0=om.C0; cm.C1=om.C1; cm.Transform=om.Transform end) end
                end
            end
        end
    end
    local oh = PreviewTarget:FindFirstChildOfClass("Humanoid")
    local ch = cl:FindFirstChildOfClass("Humanoid")
    if oh and ch then
        local oa = oh:FindFirstChildOfClass("Animator")
        local ca = ch:FindFirstChildOfClass("Animator")
        if oa and ca then
            local ot = oa:GetPlayingAnimationTracks()
            local ct = ca:GetPlayingAnimationTracks()
            local reload = (#ot ~= #ct)
            if not reload then
                for i, t in ipairs(ot) do if not ct[i] or ct[i].Animation.AnimationId ~= t.Animation.AnimationId then reload = true; break end end
            end
            if reload then
                for _, t in ipairs(ct) do pcall(function() t:Stop() end) end
                for _, t in ipairs(ot) do
                    local ok, nt = pcall(function() return ca:LoadAnimation(t.Animation) end)
                    if ok and nt then pcall(function() nt.Priority=t.Priority; nt:Play(t.TimePosition); nt:AdjustSpeed(t.Speed) end) end
                end
            else
                for i, t in ipairs(ot) do
                    local c2 = ct[i]
                    if c2 then
                        pcall(function()
                            if math.abs(c2.TimePosition - t.TimePosition) > 0.05 then c2.TimePosition = t.TimePosition end
                            c2:AdjustSpeed(t.Speed)
                        end)
                    end
                end
            end
        end
    end
end

-- ==================== BUILD UI ====================
local Window = CreateWindow({Title="ETX v2.3", Subtitle="Project Delta"})

do
local CombatTab = Window:Tab({Title="Combat", Short="CMBT"})
local AIM = CombatTab:Section({Title="Aimbot"})
AIM:Toggle({Title="Bật Aimbot (Master)", Value=AimbotMaster, Callback=function(v) AimbotMaster=v; if not v then AimbotActive=false; ClearTargetLock(true) end; SaveConfig() end})
AIM:Dropdown({Title="Chế độ Keybind", Options={"Toggle","Hold","Always"}, Value=AimbotMode, Callback=function(o) AimbotMode=o; if o=="Always" then AimbotActive=true else AimbotActive=false; ClearTargetLock(true) end; SaveConfig() end})
AIM:Button({Title="Gán phím ("..AimbotKeybind..")", ButtonText="Đổi", Callback=function()
    if CapturingKey then return end
    CapturingKey = true; Notify("ETX", "Nhấn phím để gán...", 3)
    if CaptureConn then CaptureConn:Disconnect() end
    CaptureConn = UIS.InputBegan:Connect(function(input)
        if not CapturingKey then return end
        local k = nil
        if input.UserInputType==Enum.UserInputType.Keyboard then k = input.KeyCode.Name:upper()
        elseif input.UserInputType==Enum.UserInputType.MouseButton1 then k = "MOUSEBUTTON1"
        elseif input.UserInputType==Enum.UserInputType.MouseButton2 then k = "MOUSEBUTTON2"
        elseif input.UserInputType==Enum.UserInputType.MouseButton3 then k = "MOUSEBUTTON3" end
        if k then AimbotKeybind=k; CapturingKey=false; CaptureConn:Disconnect(); SaveConfig(); Notify("ETX", "Đã gán: "..k, 3) end
    end)
    task.delay(5, function() if CapturingKey then CapturingKey=false; if CaptureConn then CaptureConn:Disconnect() end end end)
end})
AIM:Slider({Title="FOV", Value=FOV, Min=10, Max=500, Rounding=0, Suffix="px", Callback=function(v) FOV=v; SaveConfig() end})
AIM:Dropdown({Title="Target Part", Options={"Head","Torso","HumanoidRootPart"}, Value=TargetPart, Callback=function(o) TargetPart=o; SaveConfig() end})
AIM:Slider({Title="Smoothness", Value=Smoothness, Min=0.01, Max=1, Rounding=2, Callback=function(v) Smoothness=v; SaveConfig() end})
AIM:Toggle({Title="Hiện Targetline", Value=TargetLineEnabled, Callback=function(v) TargetLineEnabled=v; SaveConfig() end})
AIM:Toggle({Title="Target NPC (bandit, boss)", Value=TargetNPCEnabled, Callback=function(v) TargetNPCEnabled=v; SaveConfig() end})

local LEAD = CombatTab:Section({Title="Dự đoán hướng đi"})
LEAD:Toggle({Title="Bật Lead Prediction", Value=PredictionLead, Callback=function(v) PredictionLead=v; SaveConfig() end})
LEAD:Slider({Title="Hệ số lead", Value=PredictionLeadMultiplier, Min=0.5, Max=2, Rounding=2, Suffix="x", Callback=function(v) PredictionLeadMultiplier=v; SaveConfig() end})
LEAD:Toggle({Title="Lead trục Y", Value=PredictionLeadVertical, Callback=function(v) PredictionLeadVertical=v; SaveConfig() end})

local LOCK = CombatTab:Section({Title="Target Lock"})
LOCK:Toggle({Title="Ghim mục tiêu", Value=TargetLockEnabled, Callback=function(v) TargetLockEnabled=v; if not v then ClearTargetLock() end; SaveConfig() end})
LOCK:Slider({Title="FOV nhả lock", Value=LockReleaseFOVMult, Min=1, Max=3, Rounding=1, Suffix="x", Callback=function(v) LockReleaseFOVMult=v; SaveConfig() end})
LOCK:Slider({Title="Grace mất dấu", Value=LockLostGraceFrames, Min=5, Max=120, Rounding=0, Suffix="f", Callback=function(v) LockLostGraceFrames=v; SaveConfig() end})
LOCK:Slider({Title="Frame đổi target", Value=LockSwitchFrames, Min=1, Max=30, Rounding=0, Suffix="f", Callback=function(v) LockSwitchFrames=v; SaveConfig() end})
LOCK:Button({Title="Nhả lock ngay", ButtonText="Nhả", Callback=function() ClearTargetLock(false) end})
LOCK:Button({Title="Xóa exclusion", ButtonText="Clear", Callback=function() ClearExclusion(); Notify("ETX", "Đã xóa exclusion.", 3) end})

local PredTab = Window:Tab({Title="Prediction", Short="PRED"})
local PRED = PredTab:Section({Title="Bullet Drop"})
PRED:Toggle({Title="Bật Bullet Drop", Value=PredictionEnabled, Callback=function(v) PredictionEnabled=v; SaveConfig() end})
PRED:Slider({Title="Tốc độ đạn", Value=BulletSpeed, Min=100, Max=2000, Rounding=0, Suffix="m/s", Callback=function(v) BulletSpeed=v; SaveConfig() end})
PRED:Button({Title="Quét từ súng", ButtonText="Scan", Callback=function()
    if UpdateBulletSpeed() then Notify("ETX | Wiki", "Đã quét: "..CurrentBulletSpeed.." m/s", 3); SaveConfig()
    else Notify("ETX", "Không tìm thấy, nhập tay.", 3) end
end})
PRED:Slider({Title="Trọng lực", Value=BulletGravity, Min=50, Max=500, Rounding=0, Suffix="s/s²", Callback=function(v) BulletGravity=v; SaveConfig() end})

local ESPTab = Window:Tab({Title="ESP", Short="ESP"})
local EV = ESPTab:Section({Title="Visuals"})
EV:Toggle({Title="Bật ESP", Value=ESPEnabled, Callback=function(v) ESPEnabled=v; SaveConfig() end})
EV:Toggle({Title="Hiện khoảng cách [Xm]", Value=ESPDistanceEnabled, Callback=function(v)
    ESPDistanceEnabled = v
    for _, d in pairs(ESPObjects) do if d.DistLabel then d.DistLabel.Visible = v end end
    for _, d in pairs(ContainerObjects) do if d.DistLabel then d.DistLabel.Visible = v end end
    SaveConfig()
end})
EV:Slider({Title="Khoảng cách tối đa", Value=MaxDistance, Min=100, Max=3000, Rounding=0, Suffix="m", Callback=function(v) MaxDistance=v; SaveConfig() end})
EV:Slider({Title="Độ trong suốt", Value=ESPTransparency, Min=0, Max=1, Rounding=2, Callback=function(v) ESPTransparency=v; for _, d in pairs(ESPObjects) do if d.Highlight then d.Highlight.FillTransparency = v end end; SaveConfig() end})
EV:ColorPicker({Title="Màu ESP", Color=ESPColor, Callback=function(c) ESPColor=c; for _, d in pairs(ESPObjects) do if d.NameLabel then d.NameLabel.TextColor3 = c end; if d.DistLabel then d.DistLabel.TextColor3 = c end; if d.Highlight then d.Highlight.FillColor = c end end; SaveConfig() end})

-- NPC ESP section riêng với toggle bật/tắt
local NPC_SEC = ESPTab:Section({Title="NPC ESP"})
NPC_SEC:Toggle({Title="Bật ESP NPC", Value=ESPNPCMasterEnabled, Callback=function(v)
    ESPNPCMasterEnabled = v
    if not v then
        -- xóa hết NPC ESP đang active
        for c in pairs(ESPObjects) do
            if Players:GetPlayerFromCharacter(c) == nil then RemoveESP(c) end
        end
        ClearAllSkeletons(); ClearAllHats()
    end
    SaveConfig()
end})
NPC_SEC:Toggle({Title="Aimbot target NPC", Value=ESPNPCEnabled, Callback=function(v) ESPNPCEnabled=v; SaveConfig() end})

local SCALE = ESPTab:Section({Title="Dynamic Scale"})
SCALE:Toggle({Title="Scale theo khoảng cách", Value=ESPDynamicScale, Callback=function(v) ESPDynamicScale=v; SaveConfig() end})
SCALE:Slider({Title="Scale tối đa", Value=ESPMaxScale, Min=0.8, Max=1.5, Rounding=2, Suffix="x", Callback=function(v) ESPMaxScale=v; SaveConfig() end})
SCALE:Slider({Title="Scale tối thiểu", Value=ESPMinScale, Min=0.5, Max=1, Rounding=2, Suffix="x", Callback=function(v) ESPMinScale=v; SaveConfig() end})
SCALE:Slider({Title="Bắt đầu thu nhỏ", Value=ESPNearDistance, Min=50, Max=300, Rounding=0, Suffix="m", Callback=function(v) ESPNearDistance=v; SaveConfig() end})
SCALE:Slider({Title="Nhỏ nhất từ", Value=ESPFarDistance, Min=200, Max=2000, Rounding=0, Suffix="m", Callback=function(v) ESPFarDistance=v; SaveConfig() end})

local HP = ESPTab:Section({Title="Health Bar"})
HP:Toggle({Title="Hiện HP %", Value=HPBarEnabled, Callback=function(v) HPBarEnabled=v; for _, d in pairs(ESPObjects) do if d.HPBg then d.HPBg.Visible = v end; if d.HPText then d.HPText.Visible = v end end; SaveConfig() end})
HP:Slider({Title="Chiều rộng", Value=HPBarWidth, Min=60, Max=240, Rounding=0, Suffix="px", Callback=function(v) HPBarWidth=v; for _, d in pairs(ESPObjects) do if d.HPBg then d.BaseHPWidth = v; d.HPBg.Size = UDim2.new(0,v,0,5); d.HPBg.Position = UDim2.new(0.5,-v/2,0,0) end end; SaveConfig() end})

local SKEL = ESPTab:Section({Title="Skeleton"})
SKEL:Toggle({Title="Bật Skeleton", Value=SkeletonEnabled, Callback=function(v) SkeletonEnabled=v; if not v then ClearAllSkeletons() end; SaveConfig() end})
SKEL:Slider({Title="Độ dày", Value=SkeletonThickness, Min=1, Max=4, Rounding=0, Suffix="px", Callback=function(v) SkeletonThickness=v; SaveConfig() end})
SKEL:ColorPicker({Title="Màu Skeleton", Color=SkeletonColor, Callback=function(c) SkeletonColor=c; SaveConfig() end})

local HAT = ESPTab:Section({Title="China Hat"})
HAT:Toggle({Title="Bật China Hat", Value=ChinaHatEnabled, Callback=function(v) ChinaHatEnabled=v; if not v then ClearAllHats() end; SaveConfig() end})
HAT:Slider({Title="Scale", Value=ChinaHatScale, Min=0.5, Max=3, Rounding=1, Suffix="x", Callback=function(v) ChinaHatScale=v; for _, h in pairs(ChinaHatObjects) do h.Size = Vector3.new(2,2.4,2.4)*v; local m = h:FindFirstChildOfClass("SpecialMesh"); if m then m.Scale = Vector3.new(v,v,v) end end; SaveConfig() end})
HAT:ColorPicker({Title="Màu China Hat", Color=ChinaHatColor, Callback=function(c) ChinaHatColor=c; SaveConfig() end})

-- Container ESP section với toggle riêng
local CONT = ESPTab:Section({Title="Container / Loot Box"})
CONT:Toggle({Title="Bật ESP Container", Value=ContainerESPMasterEnabled, Callback=function(v)
    ContainerESPMasterEnabled = v
    if not v then for m in pairs(ContainerObjects) do RemoveContainerESP(m) end end
    SaveConfig()
end})
CONT:Toggle({Title="Hiện Container", Value=ContainerESPEnabled, Callback=function(v) ContainerESPEnabled=v; if not v then for m in pairs(ContainerObjects) do RemoveContainerESP(m) end end; SaveConfig() end})
CONT:Slider({Title="Độ trong suốt", Value=ContainerESPTransparency, Min=0, Max=1, Rounding=2, Callback=function(v) ContainerESPTransparency=v; for _, d in pairs(ContainerObjects) do if d.Highlight then d.Highlight.FillTransparency = v end end; SaveConfig() end})
CONT:ColorPicker({Title="Màu Container ESP", Color=ContainerESPColor, Callback=function(c) ContainerESPColor=c; for _, d in pairs(ContainerObjects) do if d.NameLabel then d.NameLabel.TextColor3 = c end; if d.DistLabel then d.DistLabel.TextColor3 = c end; if d.Highlight then d.Highlight.FillColor = c end end; SaveConfig() end})
CONT:Paragraph({Content="Nhận diện qua tên (Box, Container, Crate...) hoặc attribute ContainerSize / StorageSlots."})

local VisTab = Window:Tab({Title="Visuals", Short="VIS"})
local LIGHT = VisTab:Section({Title="Lighting"})
LIGHT:Toggle({Title="FullBright", Value=FullBrightEnabled, Callback=function(v) FullBrightEnabled=v; if v then ApplyFullBright() else RestoreLighting() end; SaveConfig() end})
LIGHT:Button({Title="Reset Lighting", ButtonText="Reset", Callback=function() FullBrightEnabled=false; RestoreLighting(); SaveConfig() end})

local MAP = VisTab:Section({Title="Map Cleanup"})
MAP:Toggle({Title="Xóa cỏ", Value=GrassRemoverEnabled, Callback=function(v)
    GrassRemoverEnabled = v
    if v then RemoveAllGrass()
    else
        local list = {}
        for o, d in pairs(HiddenObjects) do if d.tag=="grass" then table.insert(list, o) end end
        for _, o in ipairs(list) do ShowObject(o) end
    end
    SaveConfig()
end})
MAP:Toggle({Title="Xóa lá cây", Value=LeavesRemoverEnabled, Callback=function(v)
    LeavesRemoverEnabled = v
    if v then RemoveAllLeaves()
    else
        local list = {}
        for o, d in pairs(HiddenObjects) do if d.tag=="leaves" then table.insert(list, o) end end
        for _, o in ipairs(list) do ShowObject(o) end
    end
    SaveConfig()
end})
MAP:Button({Title="Khôi phục toàn bộ", ButtonText="Restore", Callback=function()
    RestoreAllHidden(); GrassRemoverEnabled=false; LeavesRemoverEnabled=false; SaveConfig()
    Notify("ETX", "Đã khôi phục map.", 3)
end})

local PrevTab = Window:Tab({Title="Preview", Short="PREV"})
local PREV = PrevTab:Section({Title="Target Preview"})
PREV:Toggle({Title="Bật Preview 3D", Value=PreviewEnabled, Callback=function(v) PreviewEnabled=v; if PreviewFrame then PreviewFrame.Visible = v end; if not v then ClearPreview() end; SaveConfig() end})
PREV:Button({Title="Reset vị trí", ButtonText="Reset", Callback=function() if PreviewFrame then PreviewFrame.Position = UDim2.new(0,20,1,-220) end end})

local SecTab = Window:Tab({Title="Security", Short="SEC"})
local MOD = SecTab:Section({Title="Moderator / Ghost"})
MOD:Toggle({Title="Cảnh báo Moderator", Value=ModeratorAlertEnabled, Callback=function(v) ModeratorAlertEnabled=v; SaveConfig() end})
MOD:Toggle({Title="Cảnh báo tàng hình", Value=InvisibleAlertEnabled, Callback=function(v)
    InvisibleAlertEnabled = v
    if not v then
        for k in pairs(InvisCounter) do InvisCounter[k]=nil end
        for k in pairs(Flagged) do Flagged[k]=nil end
        for _, d in pairs(ESPObjects) do if d.Highlight then d.Highlight.FillColor = ESPColor; d.Highlight.FillTransparency = ESPTransparency end end
    end
    SaveConfig()
end})
MOD:Slider({Title="Ngưỡng frame", Value=FLAG_CONSECUTIVE_FRAMES, Min=1, Max=60, Rounding=0, Suffix="f", Callback=function(v) FLAG_CONSECUTIVE_FRAMES=v; SaveConfig() end})
MOD:Button({Title="Quét Moderator", ButtonText="Scan", Callback=function()
    local found = ScanForModerators(true)
    if #found==0 then Notify("ETX", "Không có moderator.", 3) end
end})
MOD:Button({Title="Debug: liệt kê NPC", ButtonText="Debug", Callback=function()
    local list = ScanAllNPCs(true)
    local names = {}
    for _, m in ipairs(list) do table.insert(names, m.Name); if #names>=10 then break end end
    if #names==0 then Notify("ETX | Debug", "Không tìm thấy NPC nào.", 5)
    else Notify("ETX | Debug", #list.." NPC: "..table.concat(names,", "), 6) end
end})

local SetTab = Window:Tab({Title="Settings", Short="SET"})
local CFG = SetTab:Section({Title="Config"})
CFG:Button({Title="Lưu config", ButtonText="Save", Callback=function() SaveConfig(); Notify("ETX", "Đã lưu config.", 3) end})
CFG:Button({Title="Đọc lại config", ButtonText="Load", Callback=function()
    local ok, n = LoadConfig()
    if ok then Notify("ETX", "Đã load "..(n or 0).." giá trị. Restart để áp dụng.", 5)
    else Notify("ETX", "Không có config.", 3) end
end})
CFG:Button({Title="Xóa config", ButtonText="Delete", Callback=function() ResetConfig(); Notify("ETX", "Đã xóa config. Restart để reset.", 4) end})
CFG:Toggle({Title="Auto-save khi đổi", Value=AutoSaveEnabled, Callback=function(v) AutoSaveEnabled=v; SaveConfig() end})
CFG:Toggle({Title="Auto-save mỗi 30s", Value=AutoSaveTimerEnabled, Callback=function(v) AutoSaveTimerEnabled=v; SaveConfig() end})

local CLEAN = SetTab:Section({Title="Cleanup"})
CLEAN:Button({Title="Xóa tất cả visuals", ButtonText="Clear", Callback=function()
    for c in pairs(ESPObjects) do RemoveESP(c) end
    for m in pairs(ContainerObjects) do RemoveContainerESP(m) end
    ClearAllSkeletons(); ClearAllHats()
    Notify("ETX", "Đã xóa visuals.", 3)
end})
CLEAN:Button({Title="Ẩn UI (RightShift mở lại)", ButtonText="Ẩn", Callback=function() Window.Gui.Enabled = false end})
end

-- ==================== RENDER LOOP ====================
RunService:BindToRenderStep("ETX_Aimbot", Enum.RenderPriority.Camera.Value+1, function()
    if FOVCircle then
        FOVCircle.Visible = AimbotMaster
        FOVCircle.Radius = FOV
        local vp = Camera.ViewportSize
        FOVCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
        FOVCircle.Color = AimbotActive and Theme.Accent or Color3.fromRGB(255,255,255)
    end
    if AimbotMaster and AimbotActive then
        local target = GetClosestTarget()
        if target then AimAt(target) end
    end
    if TargetLine then
        if AimbotMaster and TargetLineEnabled then
            local lt = LockedTarget or GetClosestTarget()
            if lt then
                local part = GetTargetPart(lt, TargetPart)
                if part then
                    local spd = CurrentBulletSpeed or BulletSpeed
                    local ap = PredictTargetPosition(part, spd) or part.Position
                    local sp, on = Camera:WorldToViewportPoint(ap)
                    if on then
                        local vp = Camera.ViewportSize
                        TargetLine.From = Vector2.new(vp.X/2, vp.Y/2)
                        TargetLine.To = Vector2.new(sp.X, sp.Y)
                        TargetLine.Visible = true
                    else TargetLine.Visible = false end
                end
            else TargetLine.Visible = false end
        else TargetLine.Visible = false end
    end
    if PreviewEnabled and PreviewFrame then
        local pt = nil
        if AimbotMaster and TargetLineEnabled then pt = LockedTarget or GetClosestTarget() end
        SetPreviewTarget(pt)
    end
end)

RunService.RenderStepped:Connect(function()
    UpdateESP(); UpdateContainerESP(); SyncPreviewAnimation()

    if InvisibleAlertEnabled then
        for c in pairs(ESPObjects) do if c.Parent then EvaluateVisibility(c) end end
        if AimbotMaster and TargetLineEnabled then
            local t = LockedTarget or GetClosestTarget()
            if t then EvaluateVisibility(t) end
        end
    end

    if PreviewFrame and PreviewTarget and PreviewTarget.Parent then
        local pl = Players:GetPlayerFromCharacter(PreviewTarget)
        local name = pl and pl.Name or (PreviewTarget.Name.." (NPC)")
        local isF = Flagged[name]
        PreviewFrame.Title.TextColor3 = isF and Color3.fromRGB(255,50,50) or Theme.Accent
    end

    if SkeletonEnabled and ESPEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then CreateSkeleton(p.Character); UpdateSkeleton(p.Character) end
        end
        if ESPNPCEnabled and ESPNPCMasterEnabled then
            for _, n in ipairs(ScanAllNPCs()) do if n and n.Parent then CreateSkeleton(n); UpdateSkeleton(n) end end
        end
        for c in pairs(SkeletonObjects) do if not c.Parent then RemoveSkeleton(c) end end
    else ClearAllSkeletons() end

    if ChinaHatEnabled and ESPEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then CreateChinaHat(p.Character); UpdateChinaHat(p.Character) end
        end
        if ESPNPCEnabled and ESPNPCMasterEnabled then
            for _, n in ipairs(ScanAllNPCs()) do if n and n.Parent then CreateChinaHat(n); UpdateChinaHat(n) end end
        end
        for c in pairs(ChinaHatObjects) do if not c.Parent then RemoveChinaHat(c) end end
    else ClearAllHats() end
end)

-- INPUT
UIS.InputBegan:Connect(function(input, gp)
    if CapturingKey then return end
    if gp and input.UserInputType==Enum.UserInputType.Keyboard then return end
    if InputMatches(input) then
        if AimbotMode=="Toggle" then AimbotActive = not AimbotActive; if not AimbotActive then ClearTargetLock(true) end
        elseif AimbotMode=="Hold" then AimbotActive = true end
    end
end)
UIS.InputEnded:Connect(function(input, gp)
    if CapturingKey then return end
    if InputMatches(input) then
        if AimbotMode=="Hold" then AimbotActive = false; ClearTargetLock(true) end
    end
end)

-- GUN WATCH
local function HookChar(char)
    task.wait(1)
    if UpdateBulletSpeed() then Notify("ETX | Wiki", "Đã quét: "..CurrentBulletSpeed.." m/s", 2) end
    char.ChildAdded:Connect(function(c)
        if c:IsA("Tool") then task.wait(0.3); if UpdateBulletSpeed() then Notify("ETX | Wiki", "Đã quét: "..CurrentBulletSpeed.." m/s", 2) end end
    end)
    char.ChildRemoved:Connect(function(c) if c:IsA("Tool") then CurrentBulletSpeed = nil end end)
end
LP.CharacterAdded:Connect(HookChar)
if LP.Character then HookChar(LP.Character) end

-- INIT
CreatePreviewFrame()

task.spawn(function()
    task.wait(1)
    if FullBrightEnabled then ApplyFullBright() end
    if GrassRemoverEnabled then RemoveAllGrass() end
    if LeavesRemoverEnabled then RemoveAllLeaves() end
end)
task.spawn(function() task.wait(3); ScanForModerators(true) end)
task.spawn(function()
    task.wait(2)
    if configLoaded then Notify("ETX | Config", "Đã load "..(configCount or 0).." giá trị.", 5)
    else Notify("ETX | Config", "Không có config — dùng mặc định.", 4) end
end)
task.spawn(function()
    while true do task.wait(30); if AutoSaveTimerEnabled then SaveConfig() end end
end)
pcall(function() game:BindToClose(function() if AutoSaveEnabled then SaveConfig() end end) end)

Notify("ETX v2.3 loaded", "MaxDist 3000m | NPC+Container toggle. RightShift mở UI.", 6)
print("[ETX v2.3] Project Delta loaded.")
