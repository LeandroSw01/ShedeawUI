local ShedeawLib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local isMobile = UserInputService.TouchEnabled

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or Color3.fromRGB(40, 40, 56)
    s.Thickness = thickness or 1
    return s
end

local function corner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 10)
    return c
end

function ShedeawLib:Window(hubTitle)
    local win = {
        tabs = {},
        currentTab = nil,
        AllUIElements = {},
        Binds = {},
        isRunning = true
    }

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShedeawUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    local panelSize = isMobile and UDim2.new(0.9, 0, 0.7, 0) or UDim2.new(0, 680, 0, 420)
    local fontSizeScale = isMobile and 0.8 or 1
    local titleBarHeight = isMobile and 44 or 48

    local panel = Instance.new("Frame")
    panel.Size = panelSize
    panel.Position = UDim2.new(0.5, -panelSize.X.Offset/2, 0.5, -panelSize.Y.Offset/2)
    panel.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    panel.Parent = screenGui
    corner(panel, 16)
    stroke(panel, Color3.fromRGB(30, 30, 42), 1)

    -- Dragging
    local dragging, dragStart, startPos
    panel.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, titleBarHeight)
    titleBar.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
    titleBar.Parent = panel
    corner(titleBar, 16)
    stroke(titleBar, Color3.fromRGB(22, 22, 31), 1)

    local titleFill = Instance.new("Frame")
    titleFill.Size = UDim2.new(1, 0, 0, 18)
    titleFill.Position = UDim2.new(0, 0, 1, -18)
    titleFill.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
    titleFill.BorderSizePixel = 0
    titleFill.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0, 200, 1, 0)
    titleText.Position = UDim2.new(0, 35, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = hubTitle
    titleText.TextColor3 = Color3.fromRGB(210, 210, 228)
    titleText.TextSize = 14 * fontSizeScale
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- Minimize, Search, Close
    local function toggleUI()
        screenGui.Enabled = not screenGui.Enabled
        if isMobile and win.reopenBtn then win.reopenBtn.Visible = not screenGui.Enabled end
    end
    win.ToggleUI = toggleUI
    win.Binds[Enum.KeyCode.RightControl] = {callback = toggleUI, name = "Abrir/Fechar Menu"}

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    corner(closeBtn, 8)
    stroke(closeBtn, Color3.fromRGB(80, 28, 28), 1)
    closeBtn.MouseButton1Click:Connect(toggleUI)

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -75, 0.5, -15)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 210)
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = titleBar
    corner(minimizeBtn, 8)
    stroke(minimizeBtn, Color3.fromRGB(40, 40, 55), 1)
    minimizeBtn.MouseButton1Click:Connect(toggleUI)

    local searchBtn = Instance.new("TextButton")
    searchBtn.Size = UDim2.new(0, 30, 0, 30)
    searchBtn.Position = UDim2.new(1, -110, 0.5, -15)
    searchBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    searchBtn.Text = "S"
    searchBtn.TextColor3 = Color3.fromRGB(180, 180, 210)
    searchBtn.Font = Enum.Font.GothamBold
    searchBtn.Parent = titleBar
    corner(searchBtn, 8)
    stroke(searchBtn, Color3.fromRGB(40, 40, 55), 1)

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0, 150, 0, 30)
    searchBox.Position = UDim2.new(1, -270, 0.5, -15)
    searchBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    searchBox.PlaceholderText = "Pesquisar..."
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Visible = false
    searchBox.Parent = titleBar
    corner(searchBox, 8)
    stroke(searchBox, Color3.fromRGB(61, 255, 160), 1)

    searchBtn.MouseButton1Click:Connect(function()
        searchBox.Visible = not searchBox.Visible
        if searchBox.Visible then searchBox:CaptureFocus() end
    end)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local filter = searchBox.Text:lower()
        for _, data in ipairs(win.AllUIElements) do
            if win.currentTab and data.scroll == win.currentTab.scroll then
                data.parent.Visible = data.name:lower():find(filter) ~= nil
            else
                data.parent.Visible = true
            end
        end
    end)

    if isMobile then
        local reopenBtn = Instance.new("TextButton")
        reopenBtn.Size = UDim2.new(0, 50, 0, 50)
        reopenBtn.Position = UDim2.new(0.05, 0, 0.5, -25)
        reopenBtn.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
        reopenBtn.Text = "S"
        reopenBtn.TextColor3 = Color3.fromRGB(61, 255, 160)
        reopenBtn.TextSize = 24
        reopenBtn.Font = Enum.Font.GothamBold
        reopenBtn.Visible = false
        reopenBtn.Parent = screenGui
        corner(reopenBtn, 999)
        stroke(reopenBtn, Color3.fromRGB(61, 255, 160), 2)
        reopenBtn.MouseButton1Click:Connect(toggleUI)
        win.reopenBtn = reopenBtn
        
        -- Dragging for reopen
        local rDragging, rDragStart, rStartPos
        reopenBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                rDragging = true rDragStart = input.Position rStartPos = reopenBtn.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if rDragging and input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - rDragStart
                reopenBtn.Position = UDim2.new(rStartPos.X.Scale, rStartPos.X.Offset + delta.X, rStartPos.Y.Scale, rStartPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then rDragging = false end end)
    end

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 160, 1, -titleBarHeight)
    sidebar.Position = UDim2.new(0, 0, 0, titleBarHeight)
    sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    sidebar.Parent = panel
    corner(sidebar, 16)
    Instance.new("UIListLayout", sidebar).Padding = UDim.new(0, 5)
    Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 10)

    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -165, 1, -titleBarHeight - 5)
    contentContainer.Position = UDim2.new(0, 165, 0, titleBarHeight)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = panel

    function win:Tab(name)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0.9, 0, 0, 32)
        tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        tabBtn.Text = name
        tabBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 13
        tabBtn.Parent = sidebar
        corner(tabBtn, 8)
        local s = stroke(tabBtn, Color3.fromRGB(35, 35, 45), 1)

        local scrolling = Instance.new("ScrollingFrame")
        scrolling.Size = UDim2.new(1, -10, 1, -10)
        scrolling.Position = UDim2.new(0, 5, 0, 5)
        scrolling.BackgroundTransparency = 1
        scrolling.BorderSizePixel = 0
        scrolling.ScrollBarThickness = 2
        scrolling.ScrollBarImageColor3 = Color3.fromRGB(61, 255, 160)
        scrolling.Visible = false
        scrolling.Parent = contentContainer
        local layout = Instance.new("UIListLayout", scrolling)
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        Instance.new("UIPadding", scrolling).PaddingTop = UDim.new(0, 5)

        local tabObj = {scroll = scrolling, layoutOrder = 0}
        
        local function nextOrder()
            tabObj.layoutOrder = tabObj.layoutOrder + 1
            return tabObj.layoutOrder
        end

        tabBtn.MouseButton1Click:Connect(function()
            if win.currentTab then
                win.currentTab.scroll.Visible = false
                win.currentTab.btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                win.currentTab.stroke.Color = Color3.fromRGB(35, 35, 45)
                win.currentTab.btn.TextColor3 = Color3.fromRGB(180, 180, 200)
            end
            win.currentTab = {scroll = scrolling, btn = tabBtn, stroke = s}
            scrolling.Visible = true
            tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            tabBtn.TextColor3 = Color3.fromRGB(61, 255, 160)
            s.Color = Color3.fromRGB(61, 255, 160)
        end)

        if not win.currentTab then
            win.currentTab = {scroll = scrolling, btn = tabBtn, stroke = s}
            scrolling.Visible = true
            tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            tabBtn.TextColor3 = Color3.fromRGB(61, 255, 160)
            s.Color = Color3.fromRGB(61, 255, 160)
        end

        function tabObj:Toggle(text, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 38)
            frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            frame.LayoutOrder = nextOrder()
            frame.Parent = scrolling
            corner(frame, 8)
            stroke(frame, Color3.fromRGB(25, 25, 35), 1)
            table.insert(win.AllUIElements, {name = text, parent = frame, scroll = scrolling})

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -60, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(220, 220, 235)
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 40, 0, 22)
            btn.Position = UDim2.new(1, -50, 0.5, -11)
            btn.BackgroundColor3 = default and Color3.fromRGB(61, 255, 160) or Color3.fromRGB(40, 40, 50)
            btn.Text = ""
            btn.Parent = frame
            corner(btn, 11)

            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 18, 0, 18)
            circle.Position = default and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            circle.Parent = btn
            corner(circle, 999)

            local enabled = default
            local function trigger()
                enabled = not enabled
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = enabled and Color3.fromRGB(61, 255, 160) or Color3.fromRGB(40, 40, 50)}):Play()
                TweenService:Create(circle, TweenInfo.new(0.2), {Position = enabled and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
                callback(enabled)
            end
            btn.MouseButton1Click:Connect(trigger)

            if not isMobile then
                local bLabel = Instance.new("TextLabel")
                bLabel.Size = UDim2.new(0, 60, 0, 20)
                bLabel.Position = UDim2.new(1, -120, 0.5, -10)
                bLabel.BackgroundTransparency = 1
                bLabel.Text = ""
                bLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
                bLabel.TextSize = 10
                bLabel.Font = Enum.Font.GothamBold
                bLabel.Parent = frame
                local binding = false
                frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 then binding = true bLabel.Text = "[...]" bLabel.TextColor3 = Color3.fromRGB(61, 255, 160) end end)
                UserInputService.InputBegan:Connect(function(input)
                    if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Return then binding = false bLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
                        elseif input.KeyCode == Enum.KeyCode.Backspace then for k,v in pairs(win.Binds) do if v.name == text then win.Binds[k] = nil end end bLabel.Text = "" binding = false
                        elseif input.KeyCode ~= Enum.KeyCode.Unknown then
                            for k,v in pairs(win.Binds) do if v.name == text then win.Binds[k] = nil end end
                            win.Binds[input.KeyCode] = {callback = trigger, name = text}
                            bLabel.Text = "[" .. input.KeyCode.Name .. "]"
                        end
                    end
                end)
            end
        end

        function tabObj:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 36)
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            btn.LayoutOrder = nextOrder()
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(220, 220, 240)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 13
            btn.Parent = scrolling
            corner(btn, 8)
            stroke(btn, Color3.fromRGB(40, 40, 60), 1)
            table.insert(win.AllUIElements, {name = text, parent = btn, scroll = scrolling})
            btn.MouseButton1Click:Connect(callback)
            
            if not isMobile then
                local bLabel = Instance.new("TextLabel")
                bLabel.Size = UDim2.new(0, 60, 1, 0)
                bLabel.Position = UDim2.new(1, -70, 0, 0)
                bLabel.BackgroundTransparency = 1
                bLabel.Text = ""
                bLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
                bLabel.TextSize = 10
                bLabel.Font = Enum.Font.GothamBold
                bLabel.Parent = btn
                local binding = false
                btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 then binding = true bLabel.Text = "[...]" bLabel.TextColor3 = Color3.fromRGB(61, 255, 160) end end)
                UserInputService.InputBegan:Connect(function(input)
                    if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Return then binding = false bLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
                        elseif input.KeyCode == Enum.KeyCode.Backspace then for k,v in pairs(win.Binds) do if v.name == text then win.Binds[k] = nil end end bLabel.Text = "" binding = false
                        elseif input.KeyCode ~= Enum.KeyCode.Unknown then
                            for k,v in pairs(win.Binds) do if v.name == text then win.Binds[k] = nil end end
                            win.Binds[input.KeyCode] = {callback = callback, name = text}
                            bLabel.Text = "[" .. input.KeyCode.Name .. "]"
                        end
                    end
                end)
            end
        end

        function tabObj:Section(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.LayoutOrder = nextOrder()
            label.Text = "--- " .. string.upper(text) .. " ---"
            label.TextColor3 = Color3.fromRGB(100, 100, 130)
            label.TextSize = 10
            label.Font = Enum.Font.GothamBold
            label.Parent = scrolling
        end

        function tabObj:Numberbox(text, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 38)
            frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            frame.LayoutOrder = nextOrder()
            frame.Parent = scrolling
            corner(frame, 8)
            stroke(frame, Color3.fromRGB(25, 25, 35), 1)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.6, 0, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(0, 60, 0, 24)
            box.Position = UDim2.new(1, -70, 0.5, -12)
            box.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            box.Text = tostring(default)
            box.TextColor3 = Color3.fromRGB(255, 255, 255)
            box.Font = Enum.Font.GothamBold
            box.Parent = frame
            corner(box, 6)
            stroke(box, Color3.fromRGB(40, 40, 55), 1)
            box.FocusLost:Connect(function() local val = tonumber(box.Text) if val then callback(val) else box.Text = tostring(default) end end)
        end

        function tabObj:Dropdown(text, options, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 38)
            frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            frame.LayoutOrder = nextOrder()
            frame.Parent = scrolling
            corner(frame, 8)
            stroke(frame, Color3.fromRGB(25, 25, 35), 1)
            frame.ClipsDescendants = true
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -40, 0, 38)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text .. ": " .. (options[1] or "None")
            lbl.TextColor3 = Color3.fromRGB(220, 220, 235)
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame
            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 30, 0, 38)
            arrow.Position = UDim2.new(1, -35, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "v"
            arrow.TextColor3 = Color3.fromRGB(150, 150, 170)
            arrow.Font = Enum.Font.GothamBold
            arrow.Parent = frame
            local list = Instance.new("ScrollingFrame")
            list.Size = UDim2.new(1, -10, 0, 120)
            list.Position = UDim2.new(0, 5, 0, 42)
            list.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
            list.BorderSizePixel = 0
            list.ScrollBarThickness = 2
            list.Visible = false
            list.AutomaticCanvasSize = Enum.AutomaticSize.Y
            list.Parent = frame
            corner(list, 6)
            stroke(list, Color3.fromRGB(30, 30, 40), 1)
            local listLayout = Instance.new("UIListLayout", list)
            listLayout.Padding = UDim.new(0, 2)
            local open = false
            local function toggle()
                open = not open
                TweenService:Create(frame, TweenInfo.new(0.2), {Size = open and UDim2.new(1, 0, 0, 170) or UDim2.new(1, 0, 0, 38)}):Play()
                list.Visible = open
                TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = open and 180 or 0}):Play()
            end
            local click = Instance.new("TextButton")
            click.Size = UDim2.new(1, 0, 0, 38)
            click.BackgroundTransparency = 1
            click.Text = ""
            click.Parent = frame
            click.MouseButton1Click:Connect(toggle)
            local tracked = {}
            local function add(opt)
                if tracked[opt] then return end
                tracked[opt] = true
                local oBtn = Instance.new("TextButton")
                oBtn.Size = UDim2.new(1, 0, 0, 28)
                oBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
                oBtn.Text = opt
                oBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
                oBtn.Font = Enum.Font.GothamMedium
                oBtn.TextSize = 12
                oBtn.Parent = list
                corner(oBtn, 4)
                oBtn.MouseButton1Click:Connect(function() lbl.Text = text .. ": " .. opt callback(opt) toggle() end)
            end
            for _, o in ipairs(options) do add(o) end
            return {Add = function(_, o) add(o) end, Clear = function() for _,v in ipairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end tracked = {} end}
        end

        return tabObj
    end

    -- Method to create the Global Binds Tab (Call this last to make it the last tab)
    function win:AddBindsTab()
        local bTab = win:Tab("Binds")
        bTab:Section("Teclas Atalho")
        local bList = Instance.new("Frame")
        bList.Size = UDim2.new(1, 0, 0, 0)
        bList.AutomaticSize = Enum.AutomaticSize.Y
        bList.BackgroundTransparency = 1
        bList.Parent = bTab.scroll
        task.spawn(function()
            while win.isRunning and task.wait(0.5) do
                if bTab.scroll.Visible then
                    for _,v in ipairs(bList:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
                    for key, data in pairs(win.Binds) do
                        local f = Instance.new("Frame")
                        f.Size = UDim2.new(1, 0, 0, 30)
                        f.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
                        f.Parent = bList
                        corner(f, 6)
                        stroke(f, Color3.fromRGB(25, 25, 35), 1)
                        local l = Instance.new("TextLabel")
                        l.Size = UDim2.new(1, -10, 1, 0)
                        l.Position = UDim2.new(0, 10, 0, 0)
                        l.BackgroundTransparency = 1
                        l.Text = "[" .. key.Name .. "] -> " .. data.name
                        l.TextColor3 = Color3.fromRGB(200, 200, 220)
                        l.Font = Enum.Font.Gotham
                        l.TextXAlignment = Enum.TextXAlignment.Left
                        l.Parent = f
                    end
                end
            end
        end)
    end

    -- Global Input Handler
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local b = win.Binds[input.KeyCode]
            if b then b.callback(true) end
        end
    end)

    function win:Cleanup()
        win.isRunning = false
        screenGui:Destroy()
    end

    return win
end

return ShedeawLib
