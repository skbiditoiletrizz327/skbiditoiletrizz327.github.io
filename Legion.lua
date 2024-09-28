local Buffer = {}
Buffer.__index = Buffer

function Buffer.new(size, autoFlushSize, autoFlushInterval)
	local self = setmetatable({
		size = size or 100,                    
		data = table.create(size or 100),     
		index = 1,                             
		full = false,                         
		autoFlushSize = autoFlushSize or nil,  
		autoFlushInterval = autoFlushInterval or nil, 
		lastFlushTime = tick(),              
	}, Buffer)

	if self.autoFlushInterval then
		self:startAutoFlush()
	end

	return self
end

function Buffer:write(value)
	local success,err = pcall(function()
		self.data[self.index] = value
		self.index = self.index + 1

		if self.index > self.size then
			self.index = 1
			self.full = true 
		end

		if self.autoFlushSize and self:getCurrentSize() >= self.autoFlushSize then
			self:flush()
		end
	end)

	if not success then 
		print("Couldn't create buffer returning to old method")
		return value()
	end 
end

function Buffer:getCurrentSize()
	return self.full and self.size or self.index - 1
end

function Buffer:flush(processFunction)
	processFunction = processFunction or self.defaultProcessFunction

	local start = self.full and self.index or 1
	local stop = self.full and self.size or self.index - 1

	if processFunction then
		for i = start, stop do
			local item = self.data[i]
			if type(item) == "function" then
				item()
			else
				processFunction(item)
			end
		end
	end

	self:clear(start, stop)

	self.lastFlushTime = tick()
end

function Buffer.defaultProcessFunction(data)
	print("Processing:", data)
end

function Buffer:clear(start, stop)
	if start and stop then
		for i = start, stop do
			self.data[i] = nil
		end
	else
		self.index = 1
		self.full = false
	end
end

function Buffer:startAutoFlush()
	coroutine.wrap(function()
		while true do
			wait(self.autoFlushInterval)
			local currentTime = tick()
			if currentTime - self.lastFlushTime >= self.autoFlushInterval then
				self:flush()
			end
		end
	end)()
end

function Buffer:resize(newSize)
	local newData = table.create(newSize)

	local currentSize = self:getCurrentSize()
	local start = self.full and self.index or 1
	local stop = self.full and self.size or self.index - 1

	for i = start, stop do
		newData[i - start + 1] = self.data[i]
	end

	self.size = newSize
	self.data = newData
	self.index = currentSize + 1
	self.full = false
end

function Buffer:addDeferredAction(action)
	self:write(function() action() end)
end

function Buffer:executeDeferredActions()
	self:flush(function(action)
		if type(action) == "function" then
			action()
		end
	end)
end

function Buffer:printState()
	print("Buffer State:")
	print("Size:", self.size)
	print("Current Index:", self.index)
	print("Is Full:", self.full)
	print("Data:", self.data)
end

function Buffer:safeWrite(value)
	local success, err = pcall(function() self:write(value) end)
	if not success then
		warn("Error writing to buffer:", err)
	end
end

function Buffer:delete()
	self:clear(1, self.size)

	self.size = 0
	self.data = nil
	self.index = 1
	self.full = false
	self.autoFlushSize = nil
	self.autoFlushInterval = nil
	self.lastFlushTime = nil

	if self.autoFlushInterval then
	end

	--> gcinfo("collect")
end

local MainBuffer = Buffer.new(10,4)
local Sound = Instance.new("Sound",game.ReplicatedStorage)
MainBuffer:write(function()
	

	local Legion = {}
	local Main = nil
	Legion.__index = Legion

	local Services = {
		CoreGui =  game:GetService("CoreGui"),
		HttpService = game:GetService("HttpService"),
		UserInputService = game:GetService("UserInputService"),
		TweenService = game:GetService("TweenService"),
	}

	local TabToggles = {}

	function Legion:ApplyStroke(where)
		local UiStroke = Instance.new("UIStroke", where)
		UiStroke.Color = Color3.fromRGB(30, 30, 30)
		UiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		UiStroke.Thickness = 1.25	
	end

	function Legion:DeleteOldUis()
		for index,gui in pairs(Services.CoreGui:GetChildren()) do 
			if gui.Name == "ScreenGui" then 
				gui:Destroy()
			end 
		end 
	end 

	Legion:DeleteOldUis()
	
	function Legion.new(options)
		local self = setmetatable({},Legion)

		self.Title = options.Title
		self.Credits = options.Credits

		self.Modules = {}

		self.MainScreen = Instance.new("ScreenGui",Services.CoreGui)
		self.Main = Instance.new("Frame",self.MainScreen)

		self.Tabs = Instance.new("ScrollingFrame",self.Main)
		self.TabsCorner = Instance.new("UICorner",self.Tabs)
		self.TabsLayout = Instance.new("UIListLayout",self.Tabs)
		self.TabsPadding = Instance.new("UIPadding",self.Tabs)

		Main = self.Main
		
		self.Main.Active = true 
		self.Main.Draggable = true 

		self.CreditsText = Instance.new("TextLabel",self.Main)

		self.TitleFrame = Instance.new("Frame",self.Main)
		self.TitleText = Instance.new("TextLabel",self.TitleFrame)
		self.TitleCorner = Instance.new("UICorner",self.TitleFrame)
		self.TitleStroke = Instance.new("UIStroke",self.TitleFrame)

		self.Corner = Instance.new("UICorner",self.Main)

		-- // Traffic Lights for ui toggle and shit \\--
		self.TrafficLights = Instance.new("Frame",self.Main)
		self.Red = Instance.new("TextButton",self.TrafficLights)
		self.Yellow = Instance.new("TextButton",self.TrafficLights)
		self.Green = Instance.new("TextButton",self.TrafficLights)

		self.RedCorner = Instance.new("UICorner",self.Red)
		self.YellowCorner = Instance.new("UICorner",self.Yellow)
		self.GreenCorner = Instance.new("UICorner",self.Green)

		-- // Line Seperators \\--
		self.lineseperator_1 = Instance.new("Frame",self.Main)
		self.lineSeperators_2 = Instance.new("Frame",self.Main)
		self.lineSeperators_3 = Instance.new("Frame",self.Main)
		self.lineSeperators_4 = Instance.new("Frame",self.Main)

		-- // Shadow \\--
		self.Shadow = Instance.new("Frame",self.Main)
		self.DropShadow = Instance.new("ImageLabel",self.Shadow)


		-- // Scripting ig? \\--
		self.Main.AnchorPoint = Vector2.new(0.5,0.5)
		self.Main.BackgroundColor3 = Color3.fromRGB(10,10,10)
		self.Main.BackgroundTransparency = 0.050
		self.Main.BorderColor3 = Color3.fromRGB(0,0,0)
		self.Main.BorderSizePixel = 0 
		self.Main.Position = UDim2.new(0.264524102, 452, 0.51184833, 43)
		self.Main.Size = UDim2.new(0, 750, 0, 450)


		self.Shadow.Name = "Shadow"
		self.Shadow.BackgroundTransparency = 1.000
		self.Shadow.BorderSizePixel = 0
		self.Shadow.Size = UDim2.new(1, 0, 1, 0)
		self.Shadow.ZIndex = 0

		self.DropShadow.Name = "DropShadow"
		self.DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
		self.DropShadow.BackgroundTransparency = 1.000
		self.DropShadow.BorderSizePixel = 0
		self.DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
		self.DropShadow.Size = UDim2.new(1, 47, 1, 47)
		self.DropShadow.ZIndex = 0
		self.DropShadow.Image = "rbxassetid://6014261993"
		self.DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
		self.DropShadow.ImageTransparency = 0.500
		self.DropShadow.ScaleType = Enum.ScaleType.Slice
		self.DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

		self.Corner.CornerRadius = UDim.new(0, 15)


		self.lineseperator_1.Name = "lineSeperators"
		self.lineseperator_1.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		self.lineseperator_1.BorderColor3 = Color3.fromRGB(30, 30, 30)
		self.lineseperator_1.BorderSizePixel = 0
		self.lineseperator_1.ClipsDescendants = true
		self.lineseperator_1.Position = UDim2.new(0, 0, 0, 50)
		self.lineseperator_1.Size = UDim2.new(0, 191, 0, 1)

		self.lineSeperators_2.Name = "lineSeperators"
		self.lineSeperators_2.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		self.lineSeperators_2.BorderColor3 = Color3.fromRGB(30, 30, 30)
		self.lineSeperators_2.BorderSizePixel = 0
		self.lineSeperators_2.ClipsDescendants = true
		self.lineSeperators_2.Position = UDim2.new(0, -29, 0, 225)
		self.lineSeperators_2.Rotation = 90.000
		self.lineSeperators_2.Size = UDim2.new(0, 445, 0, 1)

		self.lineSeperators_3.Name = "lineSeperators"
		self.lineSeperators_3.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		self.lineSeperators_3.BorderColor3 = Color3.fromRGB(30, 30, 30)
		self.lineSeperators_3.BorderSizePixel = 0
		self.lineSeperators_3.ClipsDescendants = true
		self.lineSeperators_3.Position = UDim2.new(0, 0, 0, 105)
		self.lineSeperators_3.Size = UDim2.new(0, 191, 0, 1)

		self.lineSeperators_4.Name = "lineSeperators"
		self.lineSeperators_4.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		self.lineSeperators_4.BorderColor3 = Color3.fromRGB(30, 30, 30)
		self.lineSeperators_4.BorderSizePixel = 0
		self.lineSeperators_4.ClipsDescendants = true
		self.lineSeperators_4.Position = UDim2.new(0, 0, 1, -65)
		self.lineSeperators_4.Size = UDim2.new(0, 191, 0, 1)

		self.TrafficLights.Name = "trafficLights"
		self.TrafficLights.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
		self.TrafficLights.BackgroundTransparency = 1.000
		self.TrafficLights.BorderColor3 = Color3.fromRGB(0, 0, 0)
		self.TrafficLights.BorderSizePixel = 0
		self.TrafficLights.Size = UDim2.new(0, 191, 0, 50)


		self.Red.Name = "Red"
		self.Red.BackgroundColor3 = Color3.fromRGB(255, 90, 82)
		self.Red.BorderColor3 = Color3.fromRGB(255, 255, 255)
		self.Red.BorderSizePixel = 0
		self.Red.Position = UDim2.new(0.0500000007, 0, 0.200000003, 0)
		self.Red.Size = UDim2.new(0, 12, 0, 12)
		self.Red.Font = Enum.Font.SourceSans
		self.Red.Text = ""
		self.Red.TextColor3 = Color3.fromRGB(0, 0, 0)
		self.Red.TextSize = 1.000

		self.RedCorner.CornerRadius = UDim.new(1, 0)

		self.Yellow.Name = "Yellow"
		self.Yellow.BackgroundColor3 = Color3.fromRGB(255, 192, 57)
		self.Yellow.BorderColor3 = Color3.fromRGB(255, 255, 255)
		self.Yellow.BorderSizePixel = 0
		self.Yellow.Position = UDim2.new(0.150000006, 0, 0.200000003, 0)
		self.Yellow.Size = UDim2.new(0, 12, 0, 12)
		self.Yellow.Font = Enum.Font.SourceSans
		self.Yellow.Text = ""
		self.Yellow.TextColor3 = Color3.fromRGB(0, 0, 0)
		self.Yellow.TextSize = 1.000

		self.YellowCorner.CornerRadius = UDim.new(1, 0)

		self.Green.Name = "Green"
		self.Green.BackgroundColor3 = Color3.fromRGB(81, 194, 58)
		self.Green.BorderColor3 = Color3.fromRGB(255, 255, 255)
		self.Green.BorderSizePixel = 0
		self.Green.Position = UDim2.new(0.25, 0, 0.200000003, 0)
		self.Green.Size = UDim2.new(0, 12, 0, 12)
		self.Green.Font = Enum.Font.SourceSans
		self.Green.Text = ""
		self.Green.TextColor3 = Color3.fromRGB(0, 0, 0)
		self.Green.TextSize = 1.000

		self.GreenCorner.CornerRadius = UDim.new(1, 0)

		self.TitleFrame.Name = "Title"
		self.TitleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self.TitleFrame.BackgroundTransparency = 1.000
		self.TitleFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		self.TitleFrame.BorderSizePixel = 0
		self.TitleFrame.Position = UDim2.new(0.0189999994, 0, 0.128999993, 0)
		self.TitleFrame.Size = UDim2.new(0, 163, 0, 40)

		self.TitleCorner.CornerRadius = UDim.new(0, 6)

		self.TitleText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self.TitleText.BackgroundTransparency = 1.000
		self.TitleText.BorderColor3 = Color3.fromRGB(255, 255, 255)
		self.TitleText.BorderSizePixel = 0
		self.TitleText.Size = UDim2.new(1, 0, 1, 0)
		self.TitleText.FontFace =  Font.new("rbxasset://fonts/families/Montserrat.json",  Enum.FontWeight.Bold,Enum.FontStyle.Normal)
		self.TitleText.Text = self.Title or "Unamed?"
		self.TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
		self.TitleText.TextSize = 20
		self.TitleText.TextStrokeTransparency = 0.000
		self.TitleText.TextWrapped = true

		self.TitleStroke.Color = Color3.fromRGB(30,30,30)
		self.TitleStroke.Thickness = 1.25


		self.CreditsText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self.CreditsText.BackgroundTransparency = 1.000
		self.CreditsText.BorderColor3 = Color3.fromRGB(0, 0, 0)
		self.CreditsText.BorderSizePixel = 0
		self.CreditsText.Position = UDim2.new(0.014, 0, 0.86833334, 0)
		self.CreditsText.Size = UDim2.new(0.220465988, 0, 0.106666669, 0)
		self.CreditsText.Font = Enum.Font.Unknown
		self.CreditsText.Text = self.Credits or "Solodev"
		self.CreditsText.TextColor3 = Color3.fromRGB(255, 255, 255)
		self.CreditsText.TextSize = 10
		self.CreditsText.TextWrapped = true
		self.TextScaled = false 

		self.Tabs.Name = "Tabs"
		self.Tabs.Active = true
		self.Tabs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		self.Tabs.BackgroundTransparency = 1.000
		self.Tabs.BorderColor3 = Color3.fromRGB(0, 0, 0)
		self.Tabs.BorderSizePixel = 0
		self.Tabs.Position = UDim2.new(0, 0, 0, 120)
		self.Tabs.Size = UDim2.new(0, 191, 0, 250)
		self.Tabs.CanvasSize = UDim2.new(0, 0, 0, 0)
		self.Tabs.ScrollingEnabled = true 

		self.TabsLayout.Name = "Layout"
		self.TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		self.TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		self.TabsLayout.Padding = UDim.new(0, 15)

		self.TabsPadding.Name = "Padding"
		self.TabsPadding.PaddingBottom = UDim.new(0, 5)
		self.TabsPadding.PaddingTop = UDim.new(0, 5)

		self.Red.MouseButton1Down:Connect(function()
			self.Main.Visible = false
		end)

		self.TabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			self.Tabs.CanvasSize = UDim2.new(0, 0, 0, self.TabsLayout.AbsoluteContentSize.Y + 5)
			self.Tabs.ScrollBarImageTransparency = 1 
		end)



		--self.Tabs =self.Tabs = {}
		return self 
	end

	function Legion:OpenClose()
		self.Main.Visible = not self.Main.Visible
	end

	function Legion:Tab(options)
		local Tab = {}
		Tab.Name = options.Name or "Undefined"
		Tab.Sections = {}

		if TabToggles[options.Name] then 
			return 
		end

		TabToggles[#TabToggles+1] = options.Name 


		--local AssignedTab = Instance.new("Frame",)
		local TabContainer = Instance.new("Frame",self.Main)
		local LineSeperator = Instance.new("Frame",TabContainer)




		local Left = Instance.new("ScrollingFrame",TabContainer)
		local Right = Instance.new("ScrollingFrame",TabContainer)

		local LeftList = Instance.new("UIListLayout",Left)
		local RightList = Instance.new("UIListLayout",Right)
		local LeftPadding = Instance.new("UIPadding",Left)
		local RightPadding = Instance.new("UIPadding",Right)

		local TabButton = Instance.new("TextButton",self.Tabs)
		local Logo = Instance.new("ImageLabel",TabButton)
		local TabCorner = Instance.new("UICorner",TabButton)


		local TabPadding = Instance.new("UIPadding",TabButton)
		local TabStroke = Instance.new("UIStroke",TabButton)
		local TabLabel = Instance.new("TextLabel",TabButton)
		local TabLogo = Instance.new("ImageLabel",TabButton)


		--Properties:

		Right.Name = "Right"
		Right.Active = true
		Right.AnchorPoint = Vector2.new(0.5, 0.5)
		Right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Right.BackgroundTransparency = 1.000
		Right.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Right.BorderSizePixel = 0
		Right.ClipsDescendants = false
		Right.Position = UDim2.new(0.75, 0, 0.5, 0)
		Right.Size = UDim2.new(0.49000001, 0, 1, 0)
		Right.CanvasSize = UDim2.new(0, 0, 0, 0)

		RightList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		RightList.SortOrder = Enum.SortOrder.LayoutOrder
		RightList.Padding = UDim.new(0, 20)
		RightPadding.PaddingBottom = UDim.new(0, 5)
		RightPadding.PaddingTop = UDim.new(0, 5)

		TabContainer.Name = options.Name
		TabContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabContainer.BackgroundTransparency = 1.000
		TabContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabContainer.BorderSizePixel = 0
		TabContainer.ClipsDescendants = true
		TabContainer.Position = UDim2.new(0.254999995, 0, 0.0250000004, 0)
		TabContainer.Size = UDim2.new(0.745000005, 0, 0.949999988, 0)
		TabContainer.Visible = false

		LineSeperator.Name = Services.HttpService:GenerateGUID(true)
		LineSeperator.AnchorPoint = Vector2.new(0.5, 0.5)
		LineSeperator.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
		LineSeperator.BorderColor3 = Color3.fromRGB(30, 30, 30)
		LineSeperator.BorderSizePixel = 0
		LineSeperator.Position = UDim2.new(0.5, 0, 0.5, 0)
		LineSeperator.Rotation = 90.000
		LineSeperator.Size = UDim2.new(0, 445, 0, 1)


		Left.Name = "Left"
		Left.Active = true
		Left.AnchorPoint = Vector2.new(0.5, 0.5)
		Left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Left.BackgroundTransparency = 1.000
		Left.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Left.BorderSizePixel = 0
		Left.ClipsDescendants = false
		Left.Position = UDim2.new(0.25, 0, 0.5, 0)
		Left.Size = UDim2.new(0.49000001, 0, 1, 0)
		Left.CanvasSize = UDim2.new(0, 0, 0, 0)

		LeftList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		LeftList.SortOrder = Enum.SortOrder.LayoutOrder
		LeftList.Padding = UDim.new(0, 20)

		LeftPadding.PaddingBottom = UDim.new(0, 5)
		LeftPadding.PaddingTop = UDim.new(0, 5)

		TabStroke.Color = Color3.fromRGB(30,30,30)
		TabStroke.Thickness = 1.25
		TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		TabStroke.Enabled = false 

		TabCorner.CornerRadius = UDim.new(0, 6)
		TabPadding.PaddingLeft = UDim.new(0, 10)



		TabButton.Name = options.Name or "Undefined"
		TabButton.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
		TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabButton.Position = UDim2.new(0.0683000013, 0, 0.515999973, 0)
		TabButton.Size = UDim2.new(0, 150, 0, 35)
		TabButton.AutoButtonColor = false
		TabButton.Font = Enum.Font.Unknown
		TabButton.Text = ""
		TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabButton.TextSize = 14.000

		TabLabel.Name = Services.HttpService:GenerateGUID(true)
		TabLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabLabel.BackgroundTransparency = 1.000
		TabLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabLabel.BorderSizePixel = 0
		TabLabel.Size = UDim2.new(1, 0, 1, 0)
		TabLabel.Position = UDim2.new(0.05, 0, 0, 0)
		TabLabel.FontFace =  Font.new("rbxasset://fonts/families/Montserrat.json",  Enum.FontWeight.Medium,Enum.FontStyle.Normal)
		TabLabel.Text = options.Name or "Undefined"
		TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabLabel.TextSize = 16
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left

		--[[
		TabLogo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabLogo.BackgroundTransparency = 1.000
		TabLogo.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TabLogo.BorderSizePixel = 0
		TabLogo.Position = UDim2.new(0.0200554, 0, 0.25, 0)
		TabLogo.Size = UDim2.new(0, 18,0,18)
		TabLogo.Image = options.Image
		]]


		function Tab:Section(options)
			local Sections = {}
			Sections.Name = options.Name
			Sections.Where = options.Side or "Left"
			-- Create the section frame
			local Section = Instance.new("Frame", TabContainer[Sections.Where])
			local UiCorner = Instance.new("UICorner", Section)
			local UIListLayout = Instance.new("UIListLayout", Section)
			local UiPadding = Instance.new("UIPadding", Section)
			local UiStroke = Instance.new("UIStroke", Section)

			Section.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
			Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Section.BorderSizePixel = 0
			Section.Position = UDim2.new(0.0500000007, 0, -0.354999989, 0)
			Section.Size = UDim2.new(0.899999976, 0, 0, 0)
			Section.SizeConstraint = Enum.SizeConstraint.RelativeXX

			UiCorner.CornerRadius = UDim.new(0, 6)

			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Padding = UDim.new(0, 15)

			UiPadding.PaddingBottom = UDim.new(0, 10)
			UiPadding.PaddingTop = UDim.new(0, 10)

			UiStroke.Color = Color3.fromRGB(30, 30, 30)
			UiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			UiStroke.Thickness = 1.25		

			function Sections:Button(options)
				local ButtonModule = {}

				local Name = options.Text or "Undefined"
				local Callback = options.Callback or function ()
					warn("Callback wasnt defined yet") 
				end 

				local TextButton = Instance.new("TextButton",Section)
				local UICorner = Instance.new("UICorner",TextButton)
				local Text = Instance.new("TextLabel",TextButton)
				local UIPadding = Instance.new("UIPadding",TextButton)
				local UiStroke = Instance.new("UIStroke", TextButton)
				UiStroke.Color = Color3.fromRGB(30, 30, 30)
				UiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UiStroke.Thickness = 1.25	

				TextButton.Name = Name
				TextButton.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
				TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextButton.BorderSizePixel = 0
				TextButton.Position = UDim2.new(0.0250000004, 0, 0, 0)
				TextButton.Size = UDim2.new(0.949999988, 0, 0, 35)
				TextButton.AutoButtonColor = false
				TextButton.Font = Enum.Font.Unknown
				TextButton.Text = ""
				TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextButton.TextSize = 14.000

				Text.Name = "Text"
				Text.Parent = TextButton
				Text.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
				Text.BackgroundTransparency = 1.000
				Text.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Text.BorderSizePixel = 0
				Text.Size = UDim2.new(1, 0, 1, 0)
				Text.Font = Enum.Font.Unknown
				Text.Text = Name
				Text.TextColor3 = Color3.fromRGB(175, 175, 175)
				Text.TextSize = 10
				Text.TextXAlignment = Enum.TextXAlignment.Left

				UIPadding.PaddingLeft = UDim.new(0, 15)
				UICorner.CornerRadius = UDim.new(0, 4)

				TextButton.MouseButton1Down:Connect(function()
					local success,err = pcall(function()
						Callback()
					end)

					if not success then 
						print("A error occured: "..err)
					end
				end)

				TextButton.MouseEnter:Connect(function()
					Services.TweenService:Create(TextButton,TweenInfo.new(.45),{BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play()
				end)
				TextButton.MouseLeave:Connect(function()
					Services.TweenService:Create(TextButton,TweenInfo.new(.45),{BackgroundColor3 = Color3.fromRGB(18,18,18)}):Play()
				end)

				function ButtonModule:UpdateText(options)
					local NewText = options.Text or " "

					Text.Text = NewText
				end

				function ButtonModule:Destroy()
					TextButton:Destroy()
				end


				return ButtonModule
			end


			function Sections:Toggle(options)
				local Text = options.Text or "Toggle"
				local ToggleModule = {}
				local Callback = options.Callback or function()
					warn("Callback wasnt defined")
				end

				local Default = options.Default 
				local State = options.Default 
				local Start = true 

				local TextButton = Instance.new("TextButton",Section)
				local UICorner = Instance.new("UICorner",TextButton)
				local ToggleText = Instance.new("TextLabel",TextButton)
				local UIPadding = Instance.new("UIPadding",TextButton)
				local ToggleStatus = Instance.new("TextButton",TextButton)
				local UICorner_2 = Instance.new("UICorner",ToggleStatus)

				local UiStroke = Instance.new("UIStroke", TextButton)
				UiStroke.Color = Color3.fromRGB(30, 30, 30)
				UiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UiStroke.Thickness = 1.25	

				TextButton.Name = ""
				TextButton.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
				TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextButton.BorderSizePixel = 0
				TextButton.Position = UDim2.new(0.0250000004, 0, 0, 0)
				TextButton.Size = UDim2.new(0.949999988, 0, 0, 35)
				TextButton.AutoButtonColor = false
				TextButton.Font = Enum.Font.Unknown
				TextButton.Text = ""
				TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				TextButton.TextSize = 14.000

				UICorner.CornerRadius = UDim.new(0, 4)

				ToggleText.Name = "ToggleText"
				ToggleText.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
				ToggleText.BackgroundTransparency = 1.000
				ToggleText.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ToggleText.BorderSizePixel = 0
				ToggleText.Size = UDim2.new(1, 0, 1, 0)
				ToggleText.Font = Enum.Font.Unknown
				ToggleText.Text = options.Text
				ToggleText.TextColor3 = Color3.fromRGB(175, 175, 175)
				ToggleText.TextSize = 10
				ToggleText.TextXAlignment = Enum.TextXAlignment.Left

				UIPadding.PaddingLeft = UDim.new(0, 15)

				ToggleStatus.Name = "ToggleStatus"
				ToggleStatus.AnchorPoint = Vector2.new(0.5, 0.5)
				ToggleStatus.BackgroundColor3 = Color3.fromRGB(0,0,0) -- 81, 194, 58
				ToggleStatus.BorderColor3 = Color3.fromRGB(255, 255, 255)
				ToggleStatus.BorderSizePixel = 0
				ToggleStatus.Position = UDim2.new(0.899999976, 0, 0.5, 0)
				ToggleStatus.Size = UDim2.new(0, 12, 0, 12)
				ToggleStatus.AutoButtonColor = false
				ToggleStatus.Font = Enum.Font.SourceSans
				ToggleStatus.Text = ""
				ToggleStatus.TextColor3 = Color3.fromRGB(0, 0, 0)
				ToggleStatus.TextSize = 1.000

				UICorner_2.CornerRadius = UDim.new(1,0)

				if options.Default  then
					Services.TweenService:Create(ToggleStatus,TweenInfo.new(.45),{BackgroundColor3=Color3.fromRGB(81,194,58)}):Play()
					Callback(State)
				end

				ToggleStatus.MouseButton1Down:Connect(function()
					if not Start then 
						State = not State 

						if not State then 
							Services.TweenService:Create(ToggleStatus,TweenInfo.new(.45),{BackgroundColor3=Color3.fromRGB(0,0,0)}):Play()
						else 
							Services.TweenService:Create(ToggleStatus,TweenInfo.new(.45),{BackgroundColor3=Color3.fromRGB(81,194,58)}):Play()					
						end

						Callback(State)
						return
					end 
				end)
				TextButton.MouseButton1Down:Connect(function()
					if not Start then 
						State = not State 

						if not State then 
							Services.TweenService:Create(ToggleStatus,TweenInfo.new(.45),{BackgroundColor3=Color3.fromRGB(0,0,0)}):Play()
						else 
							Services.TweenService:Create(ToggleStatus,TweenInfo.new(.45),{BackgroundColor3=Color3.fromRGB(81,194,58)}):Play()					
						end

						Callback(State)
						return
					end 
				end)
				TextButton.MouseEnter:Connect(function()
					Services.TweenService:Create(TextButton,TweenInfo.new(.45),{BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play()
				end)
				TextButton.MouseLeave:Connect(function()
					Services.TweenService:Create(TextButton,TweenInfo.new(.45),{BackgroundColor3 = Color3.fromRGB(18,18,18)}):Play()
				end)

				function ToggleModule:Update(options)
					local state = options.State 

					State = state 
					if not state then 
						Services.TweenService:Create(ToggleStatus,TweenInfo.new(.45),{BackgroundColor3=Color3.fromRGB(0,0,0)}):Play()
					else 
						Services.TweenService:Create(ToggleStatus,TweenInfo.new(.45),{BackgroundColor3=Color3.fromRGB(81,194,58)}):Play()	
					end

					Callback(state)
				end

				function ToggleModule:Delete()
					Callback(false)

					TextButton:Destroy()
				end 

				Start = false 
				return ToggleModule
			end

			function Sections:Slider(options)
				local SliderFunctions = {}
				local SliderConnections = {}
				local Text = options.Text or "Undefined"
				local Min = options.Min or 0 
				local Max = options.Max or 10 
				local Increment = options.Increment or 1
				local Value = options.Value or Min

				local Slider = Instance.new("Frame",Section)
				local UICorner = Instance.new("UICorner",Slider)
				local SliderName = Instance.new("TextLabel",Slider)
				local UIPadding = Instance.new("UIPadding",SliderName)
				local SliderNumber = Instance.new("TextLabel",Slider)
				local UIPadding_2 = Instance.new("UIPadding",SliderNumber)
				local SliderBar = Instance.new("Frame",Slider)
				local UICorner_2 = Instance.new("UICorner",SliderBar)
				local SliderDot = Instance.new("TextButton",SliderBar)
				local UICorner_3 = Instance.new("UICorner",SliderDot)
				local isSliding = false


				Slider.Name = "Slider"
				Slider.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
				Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Slider.Size = UDim2.new(0.95, 0, 0, 65)

				UICorner.CornerRadius = UDim.new(0, 4)

				SliderName.Name = "SliderName"
				SliderName.BackgroundTransparency = 1.0
				SliderName.Size = UDim2.new(1, 0, 0, 20)
				SliderName.Position = UDim2.new(0, 0, 0.17, 0)
				SliderName.Text = Text
				SliderName.TextSize = 10
				SliderName.TextXAlignment = Enum.TextXAlignment.Left
				SliderName.TextColor3 = Color3.fromRGB(175, 175, 175)

				UIPadding.PaddingLeft = UDim.new(0, 15)

				SliderNumber.Name = "SliderNumber"
				SliderNumber.AnchorPoint = Vector2.new(0.5, 0.5)
				SliderNumber.BackgroundTransparency = 1.0
				SliderNumber.Position = UDim2.new(0.85, 0, 0.3, 0)
				SliderNumber.Size = UDim2.new(0, 50, 0, 12)
				SliderNumber.Text = tostring(Value)
				SliderNumber.TextColor3 = Color3.fromRGB(175, 175, 175)
				SliderNumber.TextSize = 10
				SliderNumber.TextXAlignment = Enum.TextXAlignment.Right

				SliderBar.Name = "SliderBar"
				SliderBar.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
				SliderBar.Size = UDim2.new(0.85, 0, 0, 4)
				SliderBar.Position = UDim2.new(0.075, 0, 0.7, 0)

				UICorner_2.CornerRadius = UDim.new(0, 4)

				SliderDot.Name = "SliderDot"
				SliderDot.Text = ""
				SliderDot.AnchorPoint = Vector2.new(0.5, 0.5)
				SliderDot.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
				SliderDot.Size = UDim2.new(0, 12, 0, 12)
				SliderDot.Position = UDim2.new((Value - Min) / (Max - Min), 0, 0.5, 0)
				Legion:ApplyStroke(SliderDot)
				Legion:ApplyStroke(Slider)
				UICorner_3.CornerRadius = UDim.new(0, 5)

				local function UpdateSlider(value)
					value = math.clamp(value, Min, Max)
					Services.TweenService:Create(SliderDot,TweenInfo.new(.2),{Position = UDim2.new((value - Min) / (Max - Min), 0, 0.5, 0)}):Play()

					SliderNumber.Text = tostring(math.floor(value))
					Value = value
					if options.Callback then
						options.Callback(math.floor(Value))  
					end
				end

				SliderConnections[#SliderConnections+1] = SliderDot.MouseButton1Down:Connect(function()
					isSliding = true
				end)

				SliderConnections[#SliderConnections+1] = game:GetService("UserInputService").InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						isSliding = false
					end
				end)

				SliderConnections[#SliderConnections+1] = game:GetService("UserInputService").InputChanged:Connect(function(input)
					if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
						local mousePos = input.Position.X
						local sliderBarPos = SliderBar.AbsolutePosition.X
						local sliderBarSize = SliderBar.AbsoluteSize.X
						local newValue = Min + ((mousePos - sliderBarPos) / sliderBarSize) * (Max - Min)
						UpdateSlider(newValue)
					end
				end)

				UpdateSlider(Value)

				function SliderFunctions:Delete()
					for index,connection in pairs(SliderConnections) do 
						connection:Disconnect()
					end 

					Slider:Destroy()
				end 

				return SliderFunctions
			end

			function Sections:KeyBind(options)
				local KeybindFunction = {}
				local Connections = {}
				local WhitelistedKeys = {
					Enum.KeyCode.A,
					Enum.KeyCode.B,
					Enum.KeyCode.C,
					Enum.KeyCode.D,
					Enum.KeyCode.E,
					Enum.KeyCode.F,
					Enum.KeyCode.G,
					Enum.KeyCode.H,
					Enum.KeyCode.I,
					Enum.KeyCode.J,
					Enum.KeyCode.K,
					Enum.KeyCode.L,
					Enum.KeyCode.M,
					Enum.KeyCode.N,
					Enum.KeyCode.O,
					Enum.KeyCode.P,
					Enum.KeyCode.Q,
					Enum.KeyCode.R,
					Enum.KeyCode.T,
					Enum.KeyCode.S,
					Enum.KeyCode.U,
					Enum.KeyCode.V,
					Enum.KeyCode.W,
					Enum.KeyCode.X,
					Enum.KeyCode.Y,
					Enum.KeyCode.Z,
					Enum.KeyCode.F1,
					Enum.KeyCode.F2,
					Enum.KeyCode.F3,
					Enum.KeyCode.F4,
					Enum.KeyCode.F5,
					Enum.KeyCode.F6,
					Enum.KeyCode.Insert,
				}
				local CurrentKey = options.Default or Enum.KeyCode.World21
				local Text = options.Text or "Undefined"
				local Default = options.Default or Enum.KeyCode.World21

				local Keybind = Instance.new("TextButton",Section)
				local UICorner = Instance.new("UICorner",Keybind)
				local KeyBindText = Instance.new("TextLabel",Keybind)
				local UIPadding = Instance.new("UIPadding",Keybind)
				local KeyBindValueText = Instance.new("TextLabel",Keybind)

				Legion:ApplyStroke(Keybind)


				Keybind.Name = "Keybind"
				Keybind.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
				Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Keybind.BorderSizePixel = 0
				Keybind.Position = UDim2.new(0.0250000004, 0, 0, 0)
				Keybind.Size = UDim2.new(0.949999988, 0, 0, 35)
				Keybind.AutoButtonColor = false
				Keybind.Font = Enum.Font.Unknown
				Keybind.Text = ""
				Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
				Keybind.TextSize = 10

				UICorner.CornerRadius = UDim.new(0, 4)

				KeyBindText.Name = "KeyBindText"
				KeyBindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				KeyBindText.BackgroundTransparency = 1.000
				KeyBindText.BorderColor3 = Color3.fromRGB(0, 0, 0)
				KeyBindText.BorderSizePixel = 0
				KeyBindText.Size = UDim2.new(0.598999977, 0, 1, 0)
				KeyBindText.Font = Enum.Font.Unknown
				KeyBindText.Text = options.Text
				KeyBindText.TextColor3 = Color3.fromRGB(175, 175, 175)
				KeyBindText.TextSize = 10
				KeyBindText.TextXAlignment = Enum.TextXAlignment.Left

				UIPadding.PaddingLeft = UDim.new(0, 15)

				KeyBindValueText.Name = "KeyBindValueText"
				KeyBindValueText.AnchorPoint = Vector2.new(0.5, 0.5)
				KeyBindValueText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				KeyBindValueText.BackgroundTransparency = 1.000
				KeyBindValueText.BorderColor3 = Color3.fromRGB(0, 0, 0)
				KeyBindValueText.BorderSizePixel = 0
				KeyBindValueText.Position = UDim2.new(0.899999976, 0, 0.5, 0)
				KeyBindValueText.Size = UDim2.new(0, 12, 1, 0)
				KeyBindValueText.Font = Enum.Font.Unknown
				KeyBindValueText.Text = tostring((string.split(tostring(options.Default),"KeyCode")[2]):split(".")[2])
				KeyBindValueText.TextColor3 = Color3.fromRGB(130, 130, 130)
				KeyBindValueText.TextSize = 10
				KeyBindValueText.TextXAlignment = Enum.TextXAlignment.Right

				Keybind.MouseButton1Down:Connect(function()
					KeyBindValueText.Text = "..."
					for index,connection in pairs(Connections) do 
						connection:Disconnect()
					end

					Connections[#Connections+1] = Services.UserInputService.InputEnded:Connect(function(key)

						if table.find(WhitelistedKeys,key.KeyCode) then 
							CurrentKey = key.KeyCode
							KeyBindValueText.Text = tostring((string.split(tostring(CurrentKey),"KeyCode")[2]):split(".")[2])
							for index,connection in pairs(Connections) do 
								connection:Disconnect()
							end
						end 
					end)
				end)

				Services.UserInputService.InputEnded:Connect(function(key)
					if key.KeyCode == CurrentKey then 
						options.Callback(key.KeyCode)
					end
				end)

				function KeybindFunction:Delete()
					for index,connection in pairs(Connections) do 
						connection:Disconnect()
					end 

					Keybind:Destroy()
				end 

				return KeybindFunction

			end

			function Sections:Dropdown(options)
				local Text = options.Text or "Undefined"
				local Options = options.Options or {"Undefined..."}
				local CurrentValue = Options[1]
				local Callback = options.Callback or function()
					warn("Callback is not defined")
				end

				local Open = false 

				local Dropdown = Instance.new("TextButton")
				local UICorner = Instance.new("UICorner")
				local ToggleText = Instance.new("TextLabel")
				local ImageLabel = Instance.new("ImageLabel")
				local Dropdown_2 = Instance.new("ScrollingFrame")
				local Dropdown_3 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local UICorner_3 = Instance.new("UICorner")
				local ButtonText = Instance.new("TextLabel")
				local UIPadding = Instance.new("UIPadding")
				local UIListLayout = Instance.new("UIListLayout")
				local UIPadding_2 = Instance.new("UIPadding")
				local UIListLayout_2 = Instance.new("UIListLayout")
				local UIPadding_3 = Instance.new("UIPadding")



				Legion:ApplyStroke(Dropdown)
				Legion:ApplyStroke(Dropdown_3)


				Dropdown.Name = "Dropdown"
				Dropdown.Parent = Section
				Dropdown.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
				Dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Dropdown.BorderSizePixel = 0
				Dropdown.Position = UDim2.new(0.0250000004, 0, 0, 0)
				Dropdown.Size = UDim2.new(0.949999988, 0, 0, 40)
				Dropdown.AutoButtonColor = false
				Dropdown.Font = Enum.Font.Unknown
				Dropdown.Text = ""
				Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
				Dropdown.TextSize = 14.000

				UICorner.CornerRadius = UDim.new(0, 4)
				UICorner.Parent = Dropdown

				ToggleText.Name = "ToggleText"
				ToggleText.Parent = Dropdown
				ToggleText.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
				ToggleText.BackgroundTransparency = 1.000
				ToggleText.BorderColor3 = Color3.fromRGB(0, 0, 0)
				ToggleText.BorderSizePixel = 0
				ToggleText.Size = UDim2.new(1, 0, 1, 0)
				ToggleText.Font = Enum.Font.Unknown
				ToggleText.Text = Text
				ToggleText.TextColor3 = Color3.fromRGB(175, 175, 175)
				ToggleText.TextSize = 10
				ToggleText.TextXAlignment = Enum.TextXAlignment.Left

				ImageLabel.Parent = Dropdown
				ImageLabel.BackgroundTransparency = 1.000
				ImageLabel.BorderSizePixel = 0
				ImageLabel.Position = UDim2.new(0.803328991, 0, 0, 0)
				ImageLabel.Size = UDim2.new(0, 35, 0, 40)
				ImageLabel.Image = "http://www.roblox.com/asset/?id=6031091004"
				ImageLabel.ImageColor3 = Color3.fromRGB(143, 143, 143)

				Dropdown_2.Name = "Dropdown"
				Dropdown_2.Parent = Dropdown
				Dropdown_2.Active = true
				Dropdown_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Dropdown_2.BackgroundTransparency = 1.000
				Dropdown_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Dropdown_2.BorderSizePixel = 0
				Dropdown_2.Position = UDim2.new(0, -15, 1.20000005, 0)
				Dropdown_2.Size = UDim2.new(0, 234, 0, 100)
				Dropdown_2.ScrollBarThickness = 2
				Dropdown_2.ScrollBarImageColor3 = Color3.fromRGB(255,255,255)
				Dropdown_2.Visible = false 
				Dropdown_2.ZIndex = 8


				Dropdown_3.Name = "Dropdown"
				Dropdown_3.Parent = Dropdown_2
				Dropdown_3.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
				Dropdown_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Dropdown_3.BorderSizePixel = 0
				Dropdown_3.Position = UDim2.new(-0.00641025649, 0, -0.0825000033, 0)
				Dropdown_3.Size = UDim2.new(0, 237, 0, 101)
				Dropdown_3.ZIndex = 5
				Dropdown_3.Visible = true
				Dropdown_3.AutomaticSize = Enum.AutomaticSize.Y

				UICorner_2.Parent = Dropdown_3

				UIListLayout.Parent = Dropdown_3
				UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout.Padding = UDim.new(0, 10)

				UIPadding_2.Parent = Dropdown_3
				UIPadding_2.PaddingBottom = UDim.new(0, 10)
				UIPadding_2.PaddingTop = UDim.new(0, 5)

				UIListLayout_2.Parent = Dropdown_2
				UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
				UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_2.Padding = UDim.new(0, 20)

				UIPadding_3.Parent = Dropdown
				UIPadding_3.PaddingLeft = UDim.new(0, 15)

				Dropdown.MouseEnter:Connect(function()
					Services.TweenService:Create(Dropdown,TweenInfo.new(.45),{BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play()
				end)
				Dropdown.MouseLeave:Connect(function()
					Services.TweenService:Create(Dropdown,TweenInfo.new(.45),{BackgroundColor3 = Color3.fromRGB(18,18,18)}):Play()
				end)

				local function CreateButton(text)
					local Button = Instance.new("TextButton")
					local ButtonText = Instance.new("TextLabel")
					local UIPadding = Instance.new("UIPadding")
					local UICorner_3 = Instance.new("UICorner")

					Button.Name = "Button"
					Button.Parent = Dropdown_3
					Button.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
					Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
					Button.BorderSizePixel = 0
					Button.Position = UDim2.new(0.0249998942, 0, 0.0582191795, 0)
					Button.Size = UDim2.new(0.949999988, 0, -0.0582191795, 40)
					Button.ZIndex = 6
					Button.AutoButtonColor = false
					Button.Font = Enum.Font.Unknown
					Button.Text = ""
					Button.TextColor3 = Color3.fromRGB(255, 255, 255)
					Button.TextSize = 14.000

					UICorner_3.CornerRadius = UDim.new(0, 4)
					UICorner_3.Parent = Button

					ButtonText.Name = "ButtonText"
					ButtonText.Parent = Button
					ButtonText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					ButtonText.BackgroundTransparency = 1.000
					ButtonText.BorderColor3 = Color3.fromRGB(0, 0, 0)
					ButtonText.BorderSizePixel = 0
					ButtonText.Size = UDim2.new(0.598999977, 0, 1, 0)
					ButtonText.ZIndex = 7
					ButtonText.Font = Enum.Font.Unknown
					ButtonText.Text = text
					ButtonText.TextColor3 = Color3.fromRGB(175, 175, 175)
					ButtonText.TextSize = 10
					ButtonText.TextXAlignment = Enum.TextXAlignment.Left

					UIPadding.Parent = ButtonText
					UIPadding.PaddingLeft = UDim.new(0, 6)
					UIPadding.PaddingRight = UDim.new(0, 2)

					Legion:ApplyStroke(Button)

					Button.MouseEnter:Connect(function()
						Services.TweenService:Create(Button,TweenInfo.new(.45),{BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play()
					end)
					Button.MouseLeave:Connect(function()
						Services.TweenService:Create(Button,TweenInfo.new(.45),{BackgroundColor3 = Color3.fromRGB(18,18,18)}):Play()
					end)

					return Button
				end

				for _, option in pairs(Options) do
					local Button = CreateButton(option)
					Button.MouseButton1Down:Connect(function()
						Callback(Button.ButtonText.Text)
					end)
				end

				local function UpdateDropdownSize()
					local contentHeight = UIListLayout.AbsoluteContentSize.Y + UIPadding_2.PaddingTop.Offset + UIPadding_2.PaddingBottom.Offset
					local maxHeight = 200 
					if contentHeight > maxHeight then
						Dropdown_2.CanvasSize = UDim2.new(0, 0, 0, contentHeight)

					else
						Dropdown_2.CanvasSize = UDim2.new(0, 0, #Options, 0)
					end
				end

				UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateDropdownSize)

				local DropdownConnection = Dropdown.MouseButton1Down:Connect(function()
					Open = not Open
					if Open then
						Dropdown_2.Visible = true
						Services.TweenService:Create(ImageLabel, TweenInfo.new(0.2), {Rotation = 180}):Play()
					else
						Dropdown_2.Visible = false
						Services.TweenService:Create(ImageLabel, TweenInfo.new(0.2), {Rotation = 0}):Play()
					end
				end)

				UpdateDropdownSize()

				local DropdownFunctions = {}
				function DropdownFunctions:Refresh(NewOptions)
					assert(type(NewOptions)=="table","New options are not a table")

					for index,option in pairs(Dropdown_3:GetChildren()) do 
						if option:IsA("TextButton") then 
							option:Destroy()
						end
					end

					for _, option in pairs(NewOptions) do
						local Button = CreateButton(option)
						Button.MouseButton1Down:Connect(function()
							Callback(Button.ButtonText.Text)
						end)


					end

					UpdateDropdownSize()
				end

				function DropdownFunctions:Delete()
					if DropdownConnection then 
						DropdownConnection:Disconnect()
					end 

					Dropdown:Destroy()
				end 

				return DropdownFunctions
			end

			function Sections:Input(options)
				local Text = options.Text or "Undefined"
				local PlaceHolder = options.PlaceHolder or "..."
				local Callback = options.Callback or function ()
					warn("Callback wasnt defined")
				end
				

				local Input = Instance.new("TextButton")
				local UICorner = Instance.new("UICorner")
				local Name = Instance.new("TextLabel")
				local UIPadding = Instance.new("UIPadding")
				local Frame = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local TextBox = Instance.new("TextBox")
				local UICorner_3 = Instance.new("UICorner")


				Legion:ApplyStroke(Input)
				Legion:ApplyStroke(Frame)

				Input.Name = "Input"
				Input.Parent = Section
				Input.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
				Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Input.BorderSizePixel = 0
				Input.Position = UDim2.new(0.0250000004, 0, 0, 0)
				Input.Size = UDim2.new(0.949999988, 0, 0, 40)
				Input.AutoButtonColor = false
				Input.Font = Enum.Font.Unknown
				Input.Text = ""
				Input.TextColor3 = Color3.fromRGB(255, 255, 255)
				Input.TextSize = 14.000

				UICorner.CornerRadius = UDim.new(0, 4)
				UICorner.Parent = Input

				Name.Name = "Name"
				Name.Parent = Input
				Name.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
				Name.BackgroundTransparency = 1.000
				Name.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Name.BorderSizePixel = 0
				Name.Size = UDim2.new(1, 0, 1, 0)
				Name.Font = Enum.Font.Unknown
				Name.Text = Text
				Name.TextColor3 = Color3.fromRGB(175, 175, 175)
				Name.TextSize = 10
				Name.TextXAlignment = Enum.TextXAlignment.Left

				UIPadding.Parent = Input
				UIPadding.PaddingLeft = UDim.new(0, 15)

				Frame.Parent = Input
				Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Frame.BackgroundTransparency = 1.000
				Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				Frame.BorderSizePixel = 0
				Frame.Position = UDim2.new(0.415049493, 0, 0.119999692, 0)
				Frame.Size = UDim2.new(0, 120, 0, 30)

				UICorner_2.CornerRadius = UDim.new(0, 4)
				UICorner_2.Parent = Frame

				TextBox.Parent = Frame
				TextBox.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
				TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
				TextBox.BorderSizePixel = 0
				TextBox.Position = UDim2.new(0.0553334542, 0, 0.0200002026, 0)
				TextBox.Size = UDim2.new(0, 104, 0, 28)
				TextBox.Font = Enum.Font.SourceSans
				TextBox.Text = ""
				TextBox.PlaceholderText = PlaceHolder
				TextBox.TextColor3 = Color3.fromRGB(159, 159, 159)
				TextBox.TextScaled = true
				TextBox.ClearTextOnFocus = false 
				TextBox.TextSize = 10
				TextBox.TextWrapped = true

				UICorner_3.CornerRadius = UDim.new(0, 4)
				UICorner_3.Parent = TextBox
				
				TextBox.FocusLost:Connect(function(enterPressed)
					if enterPressed then
						Callback(TextBox.Text)
					end
				end)
			end

			UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Section.Size = UDim2.new(0.9, 0, 0, UIListLayout.AbsoluteContentSize.Y + UiPadding.PaddingTop.Offset + UiPadding.PaddingBottom.Offset)
			end)

			return Sections
		end

		LeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Left.CanvasSize = UDim2.new(0, 0, 0, LeftList.AbsoluteContentSize.Y + 5)
			Left.ScrollBarImageTransparency = 1 
		end)

		RightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Right.CanvasSize = UDim2.new(0, 0, 0, RightList.AbsoluteContentSize.Y + 5)
			Right.ScrollBarImageTransparency = 1 
		end)

		TabButton.MouseButton1Down:Connect(function()
			for index,button in pairs(TabToggles) do 
				if button ~= TabButton.Name then 
					self.Main[button].Visible = false 
					Services.TweenService:Create(self.Tabs[button]:FindFirstChildOfClass("UIStroke"),TweenInfo.new(.45),{Transparency = 1})
					self.Tabs[button]:FindFirstChildOfClass("UIStroke").Enabled = false 
				else 
					self.Main[button].Visible = true 
					Services.TweenService:Create(self.Tabs[button]:FindFirstChildOfClass("UIStroke"),TweenInfo.new(.45),{Transparency = 0})
					self.Tabs[button]:FindFirstChildOfClass("UIStroke").Enabled = true
				end
			end
		end)

		return Tab
	end

	local Ui = Instance.new("ScreenGui",game.CoreGui)
    local Frame = Instance.new("Frame",Ui)
	local Toggle = Instance.new("TextButton",Frame)
	local Name = Instance.new("TextLabel")
	local UICorner = Instance.new("UICorner")
	local DropShadow = Instance.new("ImageLabel")
	
	Frame.Position =  UDim2.new(0.0133004952, 0, 0.539033115, 0)
	Frame.Transparency = 1

	Toggle.Name = "Toggle"
	Toggle.Parent = Frame
	Toggle.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Toggle.Position = UDim2.new(0.0133004952, 0, 0.539033115, 0)
	Toggle.Size = UDim2.new(0, 58, 0, 45)
	Toggle.ZIndex = 3
	Toggle.AutoButtonColor = false
	Toggle.Font = Enum.Font.Unknown
	Toggle.Text = ""
	Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	Toggle.TextSize = 12
	
	Name.Name = "Name"
	Name.Parent = Toggle
	Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Name.BackgroundTransparency = 1.000
	Name.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Name.BorderSizePixel = 0
	Name.Position = UDim2.new(0.128844455, 0, 6.78168419e-05, 0)
	Name.Size = UDim2.new(0.729729712, 0, 1, 0)
	Name.ZIndex = 3
	Name.Font = Enum.Font.Unknown
	Name.Text = "Toggle"
	Name.TextColor3 = Color3.fromRGB(255, 255, 255)
	Name.TextSize = 11.2
	Name.TextXAlignment = Enum.TextXAlignment.Left
	
	UICorner.CornerRadius = UDim.new(0, 6)
	UICorner.Parent = Toggle
	
	DropShadow.Name = "DropShadow"
	DropShadow.Parent = Toggle
	DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow.BackgroundTransparency = 1.000
	DropShadow.BorderSizePixel = 0
	DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	DropShadow.Size = UDim2.new(1, 47, 1, 47)
	DropShadow.ZIndex = 0
	DropShadow.Image = "rbxassetid://6014261993"
	DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	DropShadow.ImageTransparency = 0.500
	DropShadow.ScaleType = Enum.ScaleType.Slice
	DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

	Toggle.MouseButton1Down:Connect(function()
		if Main then 
			Main.Visible = not Main.Visible
		end 
	end)


	local EspLibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Sirius/request/library/sense/source.lua'))()
	local NotificationHolder = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
    local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

	local Bolt = loadstring(game:HttpGet("https://femboys-for.rent/p/raw/tlzqiyz8wh"))()

	local legion = Legion.new({Title="Legion ",Credits = "Solo,Percent,Iux"})
	local Holder = Instance.new("Model",workspace)

	for index,name in pairs({"Settings","Document","Folder","Code","User","Custom","Wallet","Player","Target","File","Globe","Bank","Settings_2","Eye","volume","at"}) do 
		writefile("Legion/Assets/"..name..".png",game:HttpGet("https://www.getlegion.lol/Ui/Assets/"..name..".png"))
	end 

	local function getAsset(name)
		local path = "Legion/Assets/"..name..".png"
		if isfile(path) then 
			return getcustomasset(path)
		end 
	end


	print("\n\n\n"..[[
		 _                _             
		| |              (_)            
		| |     ___  __ _ _  ___  _ __  
		| |    / _ \/ _` | |/ _ \| '_ \ 
		| |___|  __/ (_| | | (_) | | | |
		|______\___|\__, |_|\___/|_| |_|
					__/ |              
					|___/               
		--------------------------------
		  https://discord.gg/Yh8GPhQK9r


		[ // Introduction \\ ]
		[+] When trying to use any grabs please make sure to enable grab before it and also to grab the player do ctrl+g over the torso (or basically crouch and then grab)

		[ // Possible errors \\ ]
		[+] Since Legion is currently still in beta it is possible that some errors might occur so please report them to the devs

		[ // Possible Fixies \\ ]
		[+] Grab not Grabbing? -> Try to grab them over the torso or around that area and not by the head, or try to reenable "Grab"
		[+] Target Stuff being weird? -> Either click "Disable kill" or rejoin since it is currently still a bit brocken
	]])

	local Start = true 
	local Clone = nil
	local Virtualize = function(...) 
		return ... 
	end;
	-- Variables
	local LiveConnections = {}
	local Tabs = {
		Player = legion:Tab({ Name = "Player", Image = getAsset("Player")}),

		Target = legion:Tab({ Name = "Target", Image = getAsset("Target")}),

		Grabs = legion:Tab({ Name = "Grabs", Image = getAsset("Folder")}),

		Teleports = legion:Tab({ Name = "Teleport", Image = getAsset("Globe")}),

		Visuals = legion:Tab({ Name = "Visuals", Image = getAsset("Eye")}),

		VoiceLines = legion:Tab({ Name = "Voicelines", Image = getAsset("volume")}),

		Credits = legion:Tab({Name = "Credits", Image = getAsset("Bank")}),
	}
   
	local Cache = {
		["Tools"] = {},
		["Items"] = {},
		["Loops"] = {
			["Grab"] = nil,
			["CFrameSpeed"]=nil,
			["Box"] = nil,
			["Knock_Player"] = nil,
			["TP"] = nil,
			["Grenade"] = nil,
			["Control"] = nil,
			["Orbit"] = nil,
			["Ora"] = nil,
			["Minion"] = nil,
			["OldPosLoop"] = nil,
			["AutoDodge"] = nil,
			["Anti slow"] = nil,
			["Mind Control"] = nil,
			["Make Player Stand"] = nil,
			["Invis Desync"] = nil,
			["Portal"] = nil,

		},
		["Connections"] = {
			["Grab"] = nil,
			["AutoRespawnConnection"] = nil, 
			["ChattedConnection"] = nil,
			["ControlKeybinds"] = nil,
			["ControlKeybindsUp"] = nil,
			["ControlCombat"] = nil,
			["CheckKey"] = nil,
			["AntiGrab"] = nil,

			["HoverboardDown"] = nil,
			["HoverboardUp"] = nil,

			["InvisDesync"] = nil,

		},
		["Players"] = {},
		["Char_Map"] = {
			["A"] = "🅐", ["B"] = "🅑", ["C"] = "🅒", ["D"] = "🅓", ["E"] = "🅔",
			["F"] = "🅕", ["G"] = "🅖", ["H"] = "🅗", ["I"] = "🅘", ["J"] = "🅙",
			["K"] = "🅚", ["L"] = "🅛", ["M"] = "🅜", ["N"] = "🅝", ["O"] = "🅞",
			["P"] = "🅟", ["Q"] = "🅠", ["R"] = "🅡", ["S"] = "🅢", ["T"] = "🅣",
			["U"] = "🅤", ["V"] = "🅥", ["W"] = "🅦", ["X"] = "🅧", ["Y"] = "🅨",
			["Z"] = "🅩", ["a"] = "🅐", ["b"] = "🅑", ["c"] = "🅒", ["d"] = "🅓",
			["e"] = "🅔", ["f"] = "🅕", ["g"] = "🅖", ["h"] = "🅗", ["i"] = "🅘",
			["j"] = "🅙", ["k"] = "🅚", ["l"] = "🅛", ["m"] = "🅜", ["n"] = "🅝",
			["o"] = "🅞", ["p"] = "🅟", ["q"] = "🅠", ["r"] = "🅡", ["s"] = "🅢",
			["t"] = "🅣", ["u"] = "🅤", ["v"] = "🅥", ["w"] = "🅦", ["x"] = "🅧",
			["y"] = "🅨", ["z"] = "🅩", ["0"] = "⓪", ["1"] = "①", ["2"] = "②",
			["3"] = "③", ["4"] = "④", ["5"] = "⑤", ["6"] = "⑥", ["7"] = "⑦",
			["8"] = "⑧", ["9"] = "⑨"
		},

		["Command"] = nil,
		["Invis Desync"] = false,
		["Accesories"] = {}
	}

	local Settings = {
		["Grab"] = {
			["Grab"] = false,
			["Control"] = false,
			["Time Stop"] = false,
			["Get Over Here"] = false,
			["Portal"] = false,
			["Punch"] = false,
			["Make Player Invisible"] = false,
			["Chezburger"] = false,
			["Orbit"] = false,
			["Made In Heaven"] = false,
			["C Moon"] = false,
			["Hado 90"] = false,
			["Sex"] = false,
			["Sex Speed"] = 8,

			["Domain Expansion"] = false,
			["Minion"] = false,
			["Make Player Stand"] = false,
			["Punch Back"] = false,

			["Mind Control"] = false,
			["Mind Control Color"] = Color3.fromRGB(255,255,255),
			["Mind Control Thickness"] = 1,
			["Mind Control Frequency"] = 1,


			["Effects"] = true,

			["Hoverboard"] = false,
			["GrabbedCharacter"] = nil, -- um später zu accessen
		},

		["Player"] = {
			["CFrameSpeed"] = false,
			["Speed"] = 2,
			["AutoBox"] = false,
			["AntiStomp"] = false,
			["AntiGrab"] = false,
			["AutoDodge"] = false,
			["Anti slow"] = false,
			["Invis Desync"] = false,
			["Invis Desync Keybind"] = Enum.KeyCode.F,
			["Chat"] = true,
		},
		["Target"] = {
			["Player"] = nil,
			["Kill"] = false,
			["Grenade"] = false,
			["Mode"] = "Default",
			["AttackMode"] = "Combat",
		},
		["ESP"] = {
			["Color"] = nil,
		}
	}


	--> I INFACT do not know why I defined Services twice lmao 
	local Services = {
		Players = game:GetService("Players"),
		LocalPlayer = game:GetService("Players").LocalPlayer,

		RunService = game:GetService("RunService"),
		Workspace = game:GetService("Workspace"),
		Lighting = game:GetService("Lighting"),
		TweenService = game:GetService("TweenService"),
		HttpService = game:GetService("HttpService"),
		ReplicatedStorage = game:GetService("ReplicatedStorage"),
		UserInputService = game:GetService("UserInputService"),
		VirtualInputManager = game:GetService("VirtualInputManager"),
	}


	local Modules = {

		--[[ Grab ]]--
		["Grab"] = function(character,grabAnimation)
			assert(character ~= nil,"Character is nil")
			assert(Settings["Grab"]["Grab"] == true,"Grab is false cant continue")

			Settings["Grab"]["GrabbedCharacter"] = character

			if Cache["Loops"]["Grab"] ~= nil then 
				Cache["Loops"]["Grab"]:Disconnect()
			end 

			for index,part in pairs(Settings["Grab"]["GrabbedCharacter"]:GetDescendants()) do 
				if part:IsA("BodyVelocity") or part:IsA("BodyGyro") or part:IsA("BodyPosition") then 
					part:Destroy()
				end
			end 

			for index, anim in pairs(Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
				if anim.Animation.AnimationId:match("rbxassetid://" .. tostring("11075367458")) then
					anim:Stop()
				end
			end

			repeat task.wait() until Settings["Grab"]["GrabbedCharacter"]:FindFirstChild("GRABBING_CONSTRAINT")

			if not Settings["Grab"]["GrabbedCharacter"]:FindFirstChild("GRABBING_CONSTRAINT"):FindFirstChild("H") then 
				return 
			end 

			local BodyPosition = Instance.new("BodyPosition",Settings["Grab"]["GrabbedCharacter"]:FindFirstChild("UpperTorso"))
			local BodyGyro = Instance.new("BodyGyro",Settings["Grab"]["GrabbedCharacter"]:FindFirstChild("UpperTorso"))
			local GrabAnim = Services.LocalPlayer.Character.Humanoid:LoadAnimation(grabAnimation)

			BodyPosition.D = 200
			BodyGyro.D = 100 

			BodyPosition.MaxForce = Vector3.new(10000, 10000, 10000)
			BodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)

			local Position = Services.LocalPlayer.Character:FindFirstChild("RightHand").Position - Vector3.new(0,1,0)
			local Orientation = CFrame.new(character:FindFirstChild("UpperTorso").Position,Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position)

			BodyGyro.CFrame = Orientation
			BodyPosition.Position = Position

			Settings["Grab"]["GrabbedCharacter"]["GRABBING_CONSTRAINT"]:FindFirstChild("H").Length = 9e9

			GrabAnim.Priority = Enum.AnimationPriority.Action4
			GrabAnim:Play()
			GrabAnim:AdjustSpeed(0) 
			GrabAnim.TimePosition = .1

			Cache["Loops"]["Grab"] = Services.RunService.Heartbeat:Connect(Virtualize(function ()
				if Settings["Grab"]["GrabbedCharacter"] ~= nil and  Services.LocalPlayer.Character ~= nil and Services.LocalPlayer.Character:FindFirstChild("BodyEffects") and Services.LocalPlayer.Character:FindFirstChild("BodyEffects").Grabbed.Value ~= nil and Settings["Grab"]["Grab"] then 
					local Character = Services.LocalPlayer.Character

					local Position = Character:FindFirstChild("RightHand").Position - Vector3.new(0,1,0)
					local Orientation = CFrame.new(character:FindFirstChild("UpperTorso").Position,Character:FindFirstChild("HumanoidRootPart").Position)

					BodyGyro.CFrame = Orientation
					BodyPosition.Position = Position                 
				end 
			end))
		end,
		["CreateTool"] = function (name,func)

			local Tool = Instance.new("Tool",Services.LocalPlayer.Backpack)
			Tool.Name = name 
			Tool.RequiresHandle = false 

			if not Settings["Grab"]["Grab"] then 
				Notification:Notify(
					{Title = "Important!", Description = "Please enable grab before using any other tools, for further information press F9 or type /console in chat"},
					{OutlineColor = Color3.fromRGB(30,30,30),Time = 10, Type = "image"},
					{Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
				)
				return 
			end 

			Cache["Tools"][name] = Tool.Activated:Connect(function()
				if Settings["Grab"]["GrabbedCharacter"] == nil then 
					return 
				end 

				func()
			end) 
			return Tool 
		end,

		["CreateAnimation"] = function (id)
			local Animation = Instance.new("Animation")
			Animation.AnimationId = "rbxassetid://"..id 
			return Animation
		end,

		["StopAnimation"] = function(character,id)
			pcall(function()
				for index, anim in pairs(character:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
					if anim.Animation.AnimationId:match("rbxassetid://" .. tostring(id)) then
						anim:Stop()
					end
				end

				if Cache["Connections"]["Clone"] then 
					for index, anim in pairs(Cache["Connections"]["Clone"]:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
										if anim.Animation.AnimationId:match("rbxassetid://" .. tostring(id)) then
											anim:Stop()
										end
									end
				end 
			end)
		end,
		["CheckForAnimation"] = function(character,id)
			for index, anim in pairs(character:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
				if anim.Animation.AnimationId:match("rbxassetid://" .. tostring(id)) then
					return true 
				end
				return false 
			end
		end,
		["ImpactFrame"] = function ()
			if Settings["Grab"]["Effects"] then 
				local black = Instance.new("ColorCorrectionEffect")
				black.TintColor = Color3.fromRGB(0,0,0)
				local white = Instance.new("Highlight")
				white.FillColor = Color3.fromRGB(255,255,255)
				white.FillTransparency = 0
				task.wait(.1)
				black.Parent = game.Lighting
				white.Parent = Services.LocalPlayer.Character
				task.wait(.1)
				white.FillColor = Color3.fromRGB(0,0,0)
				black.TintColor = Color3.fromRGB(255,255,255)
				black.Brightness = 1
				task.wait(.1)
				black:Destroy()
				white:Destroy()
			end 
        end,
		["AnimPlay"] = function(character,id,speed,time,smoothing)
			for index, anim in pairs(character:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
				if anim.Animation.AnimationId:match("rbxassetid://" .. tostring(id)) then
					anim:Stop()
				end
			end

			Cache["Connections"]["Yes"] = true


			if Cache["Connections"]["Clone"] then 
				repeat task.wait() until Cache["Connections"]["Clone"]:FindFirstChildOfClass("Humanoid")

				local Animation = Instance.new("Animation")
				Animation.AnimationId = "rbxassetid://"..tostring(id)
				local LoadedAnim = Cache["Connections"]["Clone"]:FindFirstChildOfClass("Humanoid"):LoadAnimation(Animation)
				LoadedAnim.Priority = Enum.AnimationPriority.Action4
				if smoothing ~= nil then 
					LoadedAnim:Play(tonumber(smoothing))
				else 
					LoadedAnim:Play()
				end 

				if speed ~= nil then 
					LoadedAnim:AdjustSpeed(tonumber(speed))
				end

				if time ~= nil then 
					LoadedAnim.TimePosition = tonumber(time)
				end 

				Animation:Destroy()

				LoadedAnim.Ended:Connect(function()
					Cache["Connections"]["Yes"] = false 
				end)

				return 
			end 

			local Animation = Instance.new("Animation")
			Animation.AnimationId = "rbxassetid://"..tostring(id)
			local LoadedAnim = character:FindFirstChildOfClass("Humanoid"):LoadAnimation(Animation)
			LoadedAnim.Priority = Enum.AnimationPriority.Action4
			if smoothing ~= nil then 
				LoadedAnim:Play(tonumber(smoothing))
			else 
				LoadedAnim:Play()
			end 

			if speed ~= nil then 
				LoadedAnim:AdjustSpeed(tonumber(speed))
			end

			if time ~= nil then 
				LoadedAnim.TimePosition = tonumber(time)
			end 

			LoadedAnim.Ended:Connect(function()
				Cache["Connections"]["Yes"] = false 
			end)

			Animation:Destroy()
		end,
		["Remove"] = function(path, bodypart)
			if bodypart == "all" then
				path.LeftUpperLeg.Position = Vector3.new(0, -1200, 0)
				path.RightUpperLeg.Position = Vector3.new(0, -1200, 0)
				path.LeftUpperArm.Position = Vector3.new(0, -1200, 0)
				path.RightUpperArm.Position = Vector3.new(0, -1200, 0)
			else
				path[bodypart].Position = Vector3.new(0, -1200, 0)
			end
		end,

		["NoVelocity"] = function(player)
			for index,part in pairs(player:GetChildren()) do 
				if part:IsA("Part") or part:IsA("BasePart") then 
					part.AssemblyLinearVelocity = Vector3.zero
					part.AssemblyAngularVelocity = Vector3.zero 

					part.Velocity = Vector3.zero 
				end 
			end 
		end,

		["CanCollide"] = function (player,value)
			for index,part in pairs(player:GetChildren()) do 
				if part:IsA("Part") or part:IsA("BasePart") then 
					part.CanCollide = value 
				end 
			end
		end,

		["StopAudio"] = function()
			Sound:Stop()
			Services.ReplicatedStorage:WaitForChild("MainEvent"):FireServer("BoomboxStop")
		end,
		["Play"] = function (Id)
			Id = tonumber(Id)
			local OriginalKeyUpValue = 0 
			if Services.LocalPlayer.Backpack:FindFirstChild("[Boombox]") then
				Services.LocalPlayer.Backpack["[Boombox]"].Parent = Services.LocalPlayer.Character
				Services.ReplicatedStorage.MainEvent:FireServer("Boombox", Id)
				Services.LocalPlayer.Character["[Boombox]"].RequiresHandle = false
				Services.LocalPlayer.Character["[Boombox]"].Parent = Services.LocalPlayer.Backpack
				Services.LocalPlayer.PlayerGui.MainScreenGui.BoomboxFrame.Visible = false

				Services.LocalPlayer.Character.LowerTorso:WaitForChild("BOOMBOXSOUND")

				coroutine.wrap(function()
					repeat
						task.wait()
					until Services.LocalPlayer.Character.LowerTorso.BOOMBOXSOUND.SoundId == "rbxassetid://" .. Id and Services.LocalPlayer.Character.LowerTorso.BOOMBOXSOUND.TimeLength > 0.01
					OriginalKeyUpValue = OriginalKeyUpValue + 1
					task.wait(Services.LocalPlayer.Character.LowerTorso.BOOMBOXSOUND.TimeLength - 0.1)
					if Services.LocalPlayer.Character.LowerTorso.BOOMBOXSOUND.SoundId == "rbxassetid://" .. Id and OriginalKeyUpValue == OriginalKeyUpValue then
						Services.ReplicatedStorage:WaitForChild("MainEvent"):FireServer("BoomboxStop")
					end
				end)()
			else 
				Sound.SoundId = "rbxassetid://" .. Id
           	 	Sound:Play()
			end 
		end,

		["CFrame Speed"] = function ()
			if Cache["Loops"]["CFrameSpeed"] ~= nil then
				Cache["Loops"]["CFrameSpeed"]:Disconnect()
				Cache["Loops"]["CFrameSpeed"] = nil 
			end

			Cache["Loops"]["CFrameSpeed"] = Services.RunService.Heartbeat:Connect(Virtualize(function ()
				if Settings["Player"]["CFrameSpeed"] and Services.LocalPlayer.Character and Services.LocalPlayer.Character.Humanoid then 
					local Character = Services.LocalPlayer.Character
					if not Character:FindFirstChild("Humanoid") then return end 

					Character:FindFirstChild("HumanoidRootPart").CFrame = Character:FindFirstChild("HumanoidRootPart").CFrame + Character:FindFirstChild("Humanoid").MoveDirection * Settings["Player"]["Speed"]
				end 
			end))
		end,

		["InvisDesync"] = function(key)
			--> Kinda "Invis"

			local Char = Services.LocalPlayer.Character
			local AnimTracks = {}
			local currentAnim = nil
			local Clone = nil
			local Loop = nil
			local isToggled = false
			Char.Archivable = true

			local function novel(part)
				part.AssemblyLinearVelocity = Vector3.zero
				part.AssemblyAngularVelocity = Vector3.zero
				part.Velocity = Vector3.zero
			end

			local function IsAnimPlaying(humanoid, anim)
				for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
					if track.Animation == anim then
						return true
					end
				end
				return false
			end

			local function AnimPlay(humanoid, anim, speed)
				if not IsAnimPlaying(humanoid, anim) then
					if currentAnim then
						currentAnim:Stop()
					end
					currentAnim = humanoid:LoadAnimation(anim)
					currentAnim:Play()
					currentAnim:AdjustSpeed(speed or 1)
				end
			end

			local function AnimStop()
				if currentAnim then
					currentAnim:Stop()
					currentAnim = nil
				end
			end

			local function AnimCheck(humanoid, moveDirection)
				local state = humanoid:GetState()
				if state == Enum.HumanoidStateType.Jumping then
					AnimPlay(humanoid, AnimTracks["Jump"])
				elseif state == Enum.HumanoidStateType.Freefall then
					AnimPlay(humanoid, AnimTracks["Fall"])
				elseif moveDirection.Magnitude > 0 then
					AnimPlay(humanoid, AnimTracks["Run"], 1.2) 
				else
					AnimPlay(humanoid, AnimTracks["Idle"])
				end
			end

			local function LoadAnimations()
				local AnimateScript = Char:FindFirstChild("Animate")
				if AnimateScript then
					AnimTracks["Run"] = AnimateScript.run.RunAnim
					AnimTracks["Idle"] = AnimateScript.idle.Animation1
					AnimTracks["Jump"] = AnimateScript.jump.JumpAnim
					AnimTracks["Fall"] = AnimateScript.fall.FallAnim
				end
			end

			if getgenv().storedPosition == nil then 
				getgenv().storedPosition = nil
			end 

			local function StartClone()
				Char = Services.LocalPlayer.Character
				Clone = Char:Clone()
				Clone.Parent = workspace
				workspace.Camera.CameraSubject = Clone.Humanoid

				Loop = Services.RunService.Heartbeat:Connect(function()
					Char.HumanoidRootPart.CFrame = Clone.HumanoidRootPart.CFrame * CFrame.new(math.random(55555), math.random(55555), math.random(55555))

					for index,part in pairs(Char:GetChildren()) do 
						if part:IsA("BasePart") then 
							novel(part)
						end
					end 

					Clone.Humanoid:Move(Char.Humanoid.MoveDirection, false)
					Clone.Humanoid.Jump = Char.Humanoid.Jump
					AnimCheck(Clone.Humanoid, Char.Humanoid.MoveDirection)

					storedPosition = Clone.HumanoidRootPart.CFrame
				end)
			end

			local function StopClone()
				workspace.Camera.CameraSubject = Char.Humanoid

				if Loop then
					Loop:Disconnect()
					Loop = nil
				end

				if Clone then
					Clone:Destroy()
					Char.HumanoidRootPart.CFrame = storedPosition
				end
			end

			local function ToggleClone()
				isToggled = not isToggled
				if isToggled then
					StartClone()
				else
					StopClone()
				end
			end

			LoadAnimations()

			Cache["Connections"]["Invis Desync"] = Services.UserInputService.InputBegan:Connect(function(input)
				if input.KeyCode == key then
					ToggleClone()
				end
			end)
		end,

		["CameraEffect"] = function(char,waitTime)
			--> only useful for "Portal"

			local camera = workspace.CurrentCamera
			camera.CameraType = Enum.CameraType.Scriptable

			local fakePart = Instance.new("Part", workspace)
			fakePart.Size, fakePart.Anchored, fakePart.CanCollide, fakePart.Transparency = Vector3.new(1, 1, 1), true, false, 1
			fakePart.Position = char.HumanoidRootPart.Position
			Instance.new("Humanoid", fakePart)

			local initialCF, focusCF, headCF = 
				CFrame.new(char.HumanoidRootPart.Position + Vector3.new(0, 5, 10), char.HumanoidRootPart.Position),
				CFrame.new(char.HumanoidRootPart.Position + Vector3.new(0, 2, 30), char.HumanoidRootPart.Position),
				CFrame.new(char.Head.Position, char.HumanoidRootPart.Position) + Vector3.new(0, 5, 0)

			local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

			local cameraTween = Services.TweenService:Create(camera, tweenInfo, {CFrame = focusCF})
			local partTween = Services.TweenService:Create(fakePart, tweenInfo, {CFrame = focusCF})

			camera.CFrame = initialCF
			camera.CameraSubject = fakePart

			cameraTween:Play()
			partTween:Play()

			cameraTween.Completed:Connect(function()
				fakePart:Destroy()

				task.wait(waitTime)

				local headTween = Services.TweenService:Create(camera, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = headCF})
				headTween:Play()
				
				headTween.Completed:Connect(function()
					camera.CameraType = Enum.CameraType.Custom
					camera.CameraSubject = char.Humanoid
				end)
			end)

			
		end,


		["GrenadeTp"] = function()
			if Cache["Loops"]["Grenade"] ~= nil then 
				Cache["Loops"]["Grenade"]:Disconnect()
				Cache["Loops"]["Grenade"] = nil 
			end 

			Cache["Loops"]["Grenade"] = Services.RunService.Heartbeat:Connect(Virtualize(function ()
				if Services.Workspace.Ignored:FindFirstChild("Handle") and Settings["Target"]["Grenade"] then 
					local Grenade = Services.Workspace.Ignored:FindFirstChild("Handle")
					Grenade.CustomPhysicalProperties = PhysicalProperties.new(100, 2, .5, 100, 1)
					Grenade.Massless = false 
					if not Grenade:FindFirstChild("BodyVelocity") then 
						local BodyVelocity = Instance.new("BodyVelocity",Grenade)
						BodyVelocity.Velocity = Vector3.new(2,2,2) 
						BodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
					end 
					if Grenade:FindFirstChild("Mesh") then 
						Grenade:FindFirstChild("Mesh"):Destroy()
					end
					Grenade.Velocity = Vector3.zero 
					Grenade.AssemblyLinearVelocity = Vector3.zero 
					Grenade.AssemblyAngularVelocity = Vector3.zero 

					Grenade.CanCollide = false 
					
					Grenade.CFrame = CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("HumanoidRootPart").Position + Vector3.new(0, 0, 0) + (Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").MoveDirection*math.random(.12,.57)*Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").WalkSpeed)) * CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").MoveDirection * 5)
				end
			end))
		end, 
		["AutoBox"] = function ()
			if Cache["Loops"]["Box"] ~= nil then 
				Cache["Loops"]["Box"]:Disconnect()
				Cache["Loops"]["Box"] = nil 
			end 

			Cache["Loops"]["Box"] = Services.RunService.Heartbeat:Connect(Virtualize(function ()
				if Settings["Player"]["AutoBox"] and Services.LocalPlayer.Character then 
					local BoxPart = Services.Workspace:FindFirstChild("MAP").Map["Punching(BAGS)"]:GetChildren()[5]:GetChildren()[8]
					for index,part in pairs(Services.Workspace:FindFirstChild("MAP").Map["Punching(BAGS)"]:GetChildren()[5]:GetChildren()) do 
						if part:IsA("Part") or part:IsA("BasePart") or part:IsA("MeshPart") then 
							part.CanCollide = false 
						end 
					end 
					Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = (BoxPart.CFrame  * CFrame.Angles(90,0,math.rad(180))) - Vector3.new(0,2,0)

					if Services.LocalPlayer.Character:FindFirstChild("Combat") then 
						Services.LocalPlayer.Character:FindFirstChild("Combat"):Activate() 
						Services.LocalPlayer.Character:FindFirstChild("Combat"):Deactivate()
						return 
					end 

					Services.LocalPlayer.Backpack:FindFirstChild("Combat").Parent = Services.LocalPlayer.Character
				end 
			end))
		end,

		["AntiStomp"] = function ()
			if not Settings["Player"]["AntiStomp"] and Cache["Connections"]["AutoRespawnConnection"] ~= nil then 
				Cache["Connections"]["AutoRespawnConnection"]:Disconnect()
				Cache["Connections"]["AutoRespawnConnection"] = nil
				return 
			end 
			Cache["Connections"]["AutoRespawnConnection"] = Services.LocalPlayer.Character.BodyEffects["K.O"]:GetPropertyChangedSignal("Value"):Connect(function()
				if Services.LocalPlayer.Character.BodyEffects["K.O"].Value and Settings["Player"]["AntiStomp"]  then
					Services.LocalPlayer.Character.Humanoid:ChangeState("Dead")
				end
			end)
		end,
		["Kill"] = function ()

			--> this is the ugliest kill source holy shit lmao
			--> I never really worked on so its shitty, anyways byee 

			getgenv().Old = Services.LocalPlayer.Character.HumanoidRootPart.CFrame
			local Countdown = 1.5
			if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["K.O"].Value then 
				return 
			end 
			if Cache["Loops"]["Kill_Player"] ~= nil then 
				Cache["Loops"]["Kill_Player"]:Disconnect()
				Cache["Loops"]["Kill_Player"] = nil 
			end 

			if Cache["Loops"]["TP"] ~= nil then 
				Cache["Loops"]["TP"]:Disconnect()
				Cache["Loops"]["TP"] = nil 
			end 
			if Settings["Target"]["Kill"] then
				repeat task.wait()
					if not Settings["Target"]["Kill"] then 
						Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
						break 
					end
					Cache["Loops"]["TP"] = Services.RunService.Heartbeat:Connect(Virtualize(function ()
						if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["K.O"].Value then 
							Cache["Loops"]["TP"]:Disconnect()
							Settings["Target"]["Kill"] = false 
							if Cache["Loops"]["Kill_Player"] ~= nil then 
								Cache["Loops"]["Kill_Player"]:Disconnect()
								Cache["Loops"]["Kill_Player"] = nil 
							end 
						end 
						if Cache["Loops"]["Kill_Player"] ~= nil then 

							Cache["Loops"]["Kill_Player"]:Disconnect()
							Cache["Loops"]["Kill_Player"] = nil 
						end 
						Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(math.random(math.pi),math.random(200,600),math.random(400))
						if not Services.LocalPlayer.Character:FindFirstChild(Settings["Target"]["AttackMode"]) then
							Services.LocalPlayer.Backpack:FindFirstChild(Settings["Target"]["AttackMode"]).Parent = Services.LocalPlayer.Character
						end
						Services.LocalPlayer.Character:FindFirstChild(Settings["Target"]["AttackMode"]):Activate()

					end))

					task.wait(1.5)
					if not Settings["Target"]["Kill"] then 
						Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
						break 
					end
					Cache["Loops"]["Kill_Player"] = Services.RunService.Heartbeat:Connect(Virtualize(function ()
						if Services.Players:FindFirstChild(Settings["Target"]["Player"]) and Services.Workspace.Players:FindFirstChild(Settings["Target"]["Player"]) then
							if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("HumanoidRootPart") and Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
								if not Services.LocalPlayer.Character.BodyEffects:FindFirstChild("Attacking").Value then 
									return 
								end 
								if Cache["Loops"]["TP"] ~= nil then 
									Cache["Loops"]["TP"]:Disconnect()
									Cache["Loops"]["TP"] = nil 
								end 
								if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["K.O"].Value then
									Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
									Settings["Target"]["Kill"] = false 
									Cache["Loops"]["Kill_Player"]:Disconnect()
									return
								end
								if not Settings["Target"]["Kill"] then 
									Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
									Cache["Loops"]["Kill_Player"]:Disconnect()
									return
								end 
								if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["Attacking"].Value then 
									return 
								end 
								if Services.LocalPlayer.Character:FindFirstChild("Humanoid").Sit then
									Services.LocalPlayer.Character:FindFirstChild("Humanoid").Sit = false 
								end
								local success,err = pcall(function()
									local Pos = CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("HumanoidRootPart").Position + Vector3.new(0, 0, 0) + (Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").MoveDirection*math.random(.12,.57)*Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").WalkSpeed)) * CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").MoveDirection * 5)

									Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").AssemblyLinearVelocity = Vector3.zero 
									Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").AssemblyAngularVelocity = Vector3.zero 
									Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity = Vector3.zero  

									if string.lower(Settings["Target"]["Mode"]) == "under" then 
										Pos = (Pos * CFrame.Angles(math.rad(90),0,math.rad(180))) - Vector3.new(0,5,0)
									elseif string.lower(Settings["Target"]["Mode"]) == "above"then 
										Pos = (Pos * CFrame.Angles(math.rad(-90),0,math.rad(-180))) * CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").MoveDirection / 2) + Vector3.new(0,5,0)
									end 
									Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = Pos 
								end)

								if not success then 
									print("A error occured ["..tostring(err).."] disconnecting loop")
									Cache["Loops"]["Kill_Player"]:Disconnect()
								end 
							end
						end  
					end))
					task.wait(1.7)
					if not Settings["Target"]["Kill"] then 
						Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
						break 
					end
				until not Settings["Target"]["Kill"] or  Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["K.O"].Value
				return 
			end 
			if Cache["Loops"]["Kill_Player"] ~= nil then 
				Cache["Loops"]["Kill_Player"]:Disconnect()
				Cache["Loops"]["Kill_Player"] = nil 
			end 
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
		end,
		["Bring"] = function ()
			getgenv().Old = Services.LocalPlayer.Character.HumanoidRootPart.CFrame
			if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["K.O"].Value then 
				return 
			end 
			if Cache["Loops"]["Kill_Player"] ~= nil then 
				Cache["Loops"]["Kill_Player"]:Disconnect()
				Cache["Loops"]["Kill_Player"] = nil 
			end 

			if Cache["Loops"]["TP"] ~= nil then 
				Cache["Loops"]["TP"]:Disconnect()
				Cache["Loops"]["TP"] = nil 
			end 
			if Settings["Target"]["Kill"] then
				repeat task.wait()
					if not Settings["Target"]["Kill"] then 
						Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
						break 
					end
					Cache["Loops"]["TP"] = Services.RunService.Heartbeat:Connect(Virtualize(function ()
						if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["K.O"].Value then 
							Cache["Loops"]["TP"]:Disconnect()
							Settings["Target"]["Kill"] = false 
							if Cache["Loops"]["Kill_Player"] ~= nil then 
								Cache["Loops"]["Kill_Player"]:Disconnect()
								Cache["Loops"]["Kill_Player"] = nil 
							end 
						end 
						if Cache["Loops"]["Kill_Player"] ~= nil then 

							Cache["Loops"]["Kill_Player"]:Disconnect()
							Cache["Loops"]["Kill_Player"] = nil 
						end 
						Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(math.random(math.pi),math.random(200,600),math.random(400))
						if not Services.LocalPlayer.Character:FindFirstChild(Settings["Target"]["AttackMode"]) then
							Services.LocalPlayer.Backpack:FindFirstChild(Settings["Target"]["AttackMode"]).Parent = Services.LocalPlayer.Character
						end
						Services.LocalPlayer.Character:FindFirstChild(Settings["Target"]["AttackMode"]):Activate()
					end))

					task.wait(1.5)
					if not Settings["Target"]["Kill"] then 
						Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
						break 
					end
					Cache["Loops"]["Kill_Player"] = Services.RunService.Heartbeat:Connect(Virtualize(function ()
						if Services.Players:FindFirstChild(Settings["Target"]["Player"]) and Services.Workspace.Players:FindFirstChild(Settings["Target"]["Player"]) then
							if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("HumanoidRootPart") and Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
								if not Services.LocalPlayer.Character.BodyEffects:FindFirstChild("Attacking").Value then 
									return 
								end 

								if Cache["Loops"]["TP"] ~= nil then 
									Cache["Loops"]["TP"]:Disconnect()
									Cache["Loops"]["TP"] = nil 
								end 

								if not Services.Workspace.Players:FindFirstChild(Settings["Target"]["Player"]) then 
									Cache["Loops"]["Kill_Player"]:Disconnect()
								end 

								if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["K.O"].Value then
									Cache["Loops"]["Kill_Player"]:Disconnect()
								end
								
								if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["Attacking"].Value then 
									return 
								end 
								if Services.LocalPlayer.Character:FindFirstChild("Humanoid").Sit then
									Services.LocalPlayer.Character:FindFirstChild("Humanoid").Sit = false 
								end
								local success,err = pcall(function()
									local Pos = CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("HumanoidRootPart").Position + Vector3.new(0, 0, 0) + (Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").MoveDirection*math.random(.12,.57)*Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").WalkSpeed)) * CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").MoveDirection * 5)

									Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").AssemblyLinearVelocity = Vector3.zero 
									Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").AssemblyAngularVelocity = Vector3.zero 
									Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity = Vector3.zero  

									if string.lower(Settings["Target"]["Mode"]) == "under" then 
										Pos = (Pos * CFrame.Angles(math.rad(90),0,math.rad(180))) - Vector3.new(0,5,0)
									elseif string.lower(Settings["Target"]["Mode"]) == "above"then 
										Pos = (Pos * CFrame.Angles(math.rad(-90),0,math.rad(-180))) * CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").MoveDirection / 2) + Vector3.new(0,5,0)
									end 
									Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = Pos 
								end)

								if not success then 
									print("A error occured ["..tostring(err).."] disconnecting loop")
									Cache["Loops"]["Kill_Player"]:Disconnect()
								end 
							end
						end  
					end))
					task.wait(1.7)
					if not Settings["Target"]["Kill"] then 
						Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
						break 
					end
				until  Settings["Target"]["Kill"] == false or  Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["K.O"].Value

				Services.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]].UpperTorso.Position) * CFrame.new(0,1,0)
				task.wait(.2)
				Services.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]].UpperTorso.Position) * CFrame.new(0,1,0)
				Services.ReplicatedStorage.MainEvent:FireServer("Grabbing")
				task.wait(0.4)
				Settings["Target"]["Kill"] = false 
				Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
				return 

			end 
			if Cache["Loops"]["Kill_Player"] ~= nil then 
				Cache["Loops"]["Kill_Player"]:Disconnect()
				Cache["Loops"]["Kill_Player"] = nil 
			end 
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
		end,
		["Stomp"] = function ()
			getgenv().Old = Services.LocalPlayer.Character.HumanoidRootPart.CFrame
			if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["K.O"].Value then 
				return 
			end 
			if Cache["Loops"]["Kill_Player"] ~= nil then 
				Cache["Loops"]["Kill_Player"]:Disconnect()
				Cache["Loops"]["Kill_Player"] = nil 
			end 

			if Cache["Loops"]["TP"] ~= nil then 
				Cache["Loops"]["TP"]:Disconnect()
				Cache["Loops"]["TP"] = nil 
			end 
			if Settings["Target"]["Kill"] then
				repeat task.wait()
					if not Settings["Target"]["Kill"] then 
						Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
						break 
					end
					Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(math.random(math.pi),math.random(200,600),math.random(400))

					Cache["Loops"]["TP"] = Services.RunService.Heartbeat:Connect(Virtualize(function ()
						if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["K.O"].Value then 
							Cache["Loops"]["TP"]:Disconnect()
							Settings["Target"]["Kill"] = false 
							if Cache["Loops"]["Kill_Player"] ~= nil then 
								Cache["Loops"]["Kill_Player"]:Disconnect()
								Cache["Loops"]["Kill_Player"] = nil 
							end 
						end 
						if Cache["Loops"]["Kill_Player"] ~= nil then 

							Cache["Loops"]["Kill_Player"]:Disconnect()
							Cache["Loops"]["Kill_Player"] = nil 
						end 
						Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(math.random(math.pi),math.random(200,600),math.random(400))
						if not Services.LocalPlayer.Character:FindFirstChild(Settings["Target"]["AttackMode"]) then
							Services.LocalPlayer.Backpack:FindFirstChild(Settings["Target"]["AttackMode"]).Parent = Services.LocalPlayer.Character
						end
						Services.LocalPlayer.Character:FindFirstChild(Settings["Target"]["AttackMode"]):Activate()
					end))

					task.wait(1.5)
					if not Settings["Target"]["Kill"] then 
						Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
						break 
					end
					Cache["Loops"]["Kill_Player"] = Services.RunService.Heartbeat:Connect(Virtualize(function ()
						if Services.Players:FindFirstChild(Settings["Target"]["Player"]) and Services.Workspace.Players:FindFirstChild(Settings["Target"]["Player"]) then
							if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("HumanoidRootPart") and Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
								if not Services.LocalPlayer.Character.BodyEffects:FindFirstChild("Attacking").Value then 
									return 
								end 
								if Cache["Loops"]["TP"] ~= nil then 
									Cache["Loops"]["TP"]:Disconnect()
									Cache["Loops"]["TP"] = nil 
								end 
								if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["K.O"].Value then
									if not  Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["SDeath"].Value then 
										Services.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]].UpperTorso.Position) * CFrame.new(0,1.2,0) * CFrame.Angles(math.rad(90),0,math.rad(180))
										Services.ReplicatedStorage.MainEvent:FireServer("Stomp")
									end 
									Cache["Loops"]["Kill_Player"]:Disconnect()
								end

								
								if Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["Attacking"].Value then 
									return 
								end 
								
								if Services.LocalPlayer.Character:FindFirstChild("Humanoid").Sit then
									Services.LocalPlayer.Character:FindFirstChild("Humanoid").Sit = false 
								end
								local success,err = pcall(function()
									local Pos = CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("HumanoidRootPart").Position + Vector3.new(0, 0, 0) + (Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").MoveDirection*math.random(.12,.57)*Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").WalkSpeed)) * CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").MoveDirection * 5)

									Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").AssemblyLinearVelocity = Vector3.zero 
									Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").AssemblyAngularVelocity = Vector3.zero 
									Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Velocity = Vector3.zero  

									if string.lower(Settings["Target"]["Mode"]) == "under" then 
										Pos = (Pos * CFrame.Angles(math.rad(90),0,math.rad(180))) - Vector3.new(0,5,0)
									elseif string.lower(Settings["Target"]["Mode"]) == "above"then 
										Pos = (Pos * CFrame.Angles(math.rad(-90),0,math.rad(-180))) * CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("Humanoid").MoveDirection / 2) + Vector3.new(0,5,0)
									end 
									Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = Pos 
								end)

								if not success then 
									print("A error occured ["..tostring(err).."] disconnecting loop")
									Cache["Loops"]["Kill_Player"]:Disconnect()
								end 
							end
						end  
					end))
					task.wait(1.7)
					if not Settings["Target"]["Kill"] then 
						Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
						break 
					end
					Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(math.random(math.pi),math.random(200,600),math.random(400))
				until Settings["Target"]["Kill"] == false  or  Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["K.O"].Value
				repeat task.wait()
					if not Settings["Target"]["Kill"] then 
						break 
					end 
					Services.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Services.Workspace.Players[Settings["Target"]["Player"]].UpperTorso.Position) * CFrame.new(0,1.2,0) * CFrame.Angles(math.rad(90),0,math.rad(180))
					Services.ReplicatedStorage.MainEvent:FireServer("Stomp")
				until Services.Workspace.Players[Settings["Target"]["Player"]]:FindFirstChild("BodyEffects")["SDeath"].Value or Settings["Target"]["Kill"] == false

				Settings["Target"]["Kill"] = false 
				Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
				return 

			end 
			if Cache["Loops"]["Kill_Player"] ~= nil then 
				Cache["Loops"]["Kill_Player"]:Disconnect()
				Cache["Loops"]["Kill_Player"] = nil 
			end 
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old
		end,



		["GetPlayers"] = function ()
			for index,player in pairs(game.Players:GetPlayers()) do
				if player.Name ~= game.Players.LocalPlayer.Name then
					Cache["Players"][#Cache["Players"]+1] = player.Name.." ("..player.DisplayName..")"
				end
			end
		end,

		["GetUser"] = function (name)
			for _,player in pairs(Services.Players:GetPlayers()) do
				if string.find(string.lower(player.Name),string.lower(name)) or string.find(string.lower(player.DisplayName),string.lower(name)) or player.Name == name then 
					return player.Name 
				end 
			end
		end, 

		["Disguise"] = function(char,userid)
			--assert(char:FindFirstChild("HumanoidRootPart")==true,"Char is invalid")

			if Cache["Loops"]["Disguise"] ~= nil then 
				Cache["Loops"]["Disguise"]:Disconnect()
				Cache["Loops"]["Disguise"] = nil 
			end 
			

			local AnimTracks = {}
			local CurrentAnim = nil 

			local Humanoid = char:FindFirstChild("Humanoid") 
			local Description = Services.Players:GetHumanoidDescriptionFromUserId(userid)  

			local Camera = Services.Workspace.Camera 
			local Loop = nil 

			

			local function IsAnimPlaying(humanoid, anim)
			    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
			        if track.Animation == anim then
			            return true
			        end
			    end
			    return false
			end

			local function AnimPlay(humanoid, anim, speed)
			    if not IsAnimPlaying(humanoid, anim) then
			        if CurrentAnim then
			            CurrentAnim:Stop()
			        end
			        CurrentAnim = humanoid:LoadAnimation(anim)
			        CurrentAnim:Play()
			        CurrentAnim:AdjustSpeed(speed or 1)
			    end
			end

			local function AnimStop(walk)
			    if CurrentAnim and not walk then
			        CurrentAnim:Stop()
			        CurrentAnim = nil
			    elseif currentAnim and walk then 
			    	CurrentAnim:AdjustSpeed(0.1)
			    	task.wait(.1)
			    	CurrentAnim:Stop(0.2)
			    	CurrentAnim = nil 
			    end
			end

			local function AnimCheck(humanoid, moveDirection)
			    local state = humanoid:GetState()
			    if state == Enum.HumanoidStateType.Jumping and not Cache["Connections"]["Yes"] then
			        AnimPlay(humanoid, AnimTracks["Jump"])
			    elseif state == Enum.HumanoidStateType.Freefall and not Cache["Connections"]["Yes"] then
			        AnimPlay(humanoid, AnimTracks["Fall"])
			    elseif moveDirection.Magnitude > 0  and not Cache["Connections"]["Yes"] then
			        AnimPlay(humanoid, AnimTracks["Run"], 1.2)
			    elseif  not Cache["Connections"]["Yes"] then 
			        AnimPlay(humanoid, AnimTracks["Idle"])
			    end
			end

			char.Archivable = true 



			for index,accessory in pairs(char:GetDescendants()) do 
				if accessory:IsA("Accessory") or accessory:IsA("ShirtGraphic") or accessory:IsA("Shirt") or accessory:IsA("Pants") then
					accessory:Destroy()
            	end
			end 


			local ClonedChar = char:Clone()
			local FakeHandle = Instance.new("Part",ClonedChar)

			FakeHandle.Name = "BOOMBOXHANDLE"
			FakeHandle.CFrame = CFrame.new(255,255,255)
			FakeHandle.Anchored = true 
			FakeHandle.Transparency = 1 

			ClonedChar.Parent = workspace

			ClonedChar:FindFirstChildOfClass("Humanoid"):ApplyDescription(Description)
			ClonedChar.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

			if ClonedChar:FindFirstChild("ForceField") then 
            	ClonedChar:FindFirstChild("ForceField"):Destroy()
        	end 

			local AnimateScript = ClonedChar:FindFirstChild("Animate")
	        if AnimateScript then
	            AnimTracks["Run"] = AnimateScript.run.RunAnim 
	            AnimTracks["Idle"] = AnimateScript.idle.Animation1
	            AnimTracks["Jump"] = AnimateScript.jump.JumpAnim
	            AnimTracks["Fall"] = AnimateScript.fall.FallAnim 
	        end

        	Camera.CameraSubject = ClonedChar.Humanoid

        	Cache["Loops"]["Disguise"] = Services.RunService.Heartbeat:Connect(function()
        		local success,err = pcall(function()
        			char.HumanoidRootPart.CFrame = ClonedChar.HumanoidRootPart.CFrame

        			for index, part in pairs(char:GetChildren()) do 
						if part:IsA("BasePart") then 
	        				part.CanCollide = false 
	        				part.Transparency = 1 

	        				ClonedChar[part.Name].CanCollide = false     
	        			end 
        			end 
        			for index,part in pairs(char:GetDescendants()) do 
	        			if part:IsA("Decal") then 
        					part.Transparency = 1 
        				end 
	        		end 

	        		ClonedChar.Humanoid:Move(char.Humanoid.MoveDirection,false)
	        		ClonedChar.Humanoid.Jump = char.Humanoid.Jump 

	        		AnimCheck(ClonedChar.Humanoid, char.Humanoid.MoveDirection)  

	        		if char == nil then 
						for index, part in pairs(char:GetChildren()) do 
							if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
		        				part.CanCollide = false 
		        				part.Transparency = 0 
		        			end 
	        			end 

	        			for index,part in pairs(char:GetDescendants()) do 
		        			if part:IsA("Decal") then 
	        					part.Transparency = 0 
	        				end 
		        		end

	        			


	        			ClonedChar:Destroy()
						Cache["Loops"]["Disguise"]:Disconnect()
	        		end 
        		end)

        		if not success then 
        			for index, part in pairs(char:GetChildren()) do 
						if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
	        				part.CanCollide = false 
	        				part.Transparency = 0 
	        			end 
        			end 
        			for index,part in pairs(char:GetDescendants()) do 
	        			if part:IsA("Decal") then 
        					part.Transparency = 0 
        				end 
	        		end 

	        		  

	        		Camera.CameraSubject = char.Humanoid

        			ClonedChar:Destroy()
					Cache["Loops"]["Disguise"]:Disconnect()

					print("A error occured: "..err)
				end       		 
        	end)

        	return Cache["Loops"]["Disguise"],ClonedChar

		end,

		["BuyItem"] = function (item)
			local Shop = Services.Workspace:FindFirstChild("Ignored"):FindFirstChild("Shop")
			local OldText = Services.LocalPlayer.PlayerGui.MainScreenGui:FindFirstChild("MoneyText").Text 
			local Old = Services.LocalPlayer.Character.HumanoidRootPart.CFrame
			local Part = nil 
			if Shop then 
				for index,part in pairs(Shop[item]:GetChildren()) do 
					if part:IsA("Part") or part:IsA("BasePart") or part:IsA("MeshPart") then 
						Part = part 
					end 
				end 
				repeat task.wait()
					if Shop[item]:FindFirstChild("ClickDetector") and Part ~= nil then 
						Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = Part.CFrame - Vector3.new(0,2,0)
						fireclickdetector(Shop[item].ClickDetector)
					end 
				until Services.LocalPlayer.PlayerGui.MainScreenGui:FindFirstChild("MoneyText").Text ~= OldText
				Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old 
			end 
		end,

		["AntiGrab"] = function()
			-- Disconnecting old loops
			if Cache["Connections"]["AntiGrab"] ~= nil then 
				Cache["Connections"]["AntiGrab"]:Disconnect()
				Cache["Connections"]["AntiGrab"] = nil 
			end

			if Settings["Player"]["AntiGrab"] then 
				Cache["Connections"]["AntiGrab"] = Services.LocalPlayer.Character.ChildAdded:Connect(function(item)
					if string.lower(item.Name) == "grabbing_constraint" then 
						item:Destroy()
						task.wait(.4)
						Services.LocalPlayer.Character.Humanoid:ChangeState("Dead")
						Cache["Connections"]["AntiGrab"]:Disconnect()
						Cache["Connections"]["AntiGrab"] = nil
					end 
				end)
				return 
			end 

			if Cache["Connections"]["AntiGrab"] ~= nil then 
				Cache["Connections"]["AntiGrab"]:Disconnect()
				Cache["Connections"]["AntiGrab"] = nil 
			end 
		end ,

		["AutoDodge"] = function()
			--> ignore this 

			if Cache["Loops"]["AutoDodge"] ~= nil then 
				Cache["Loops"]["AutoDodge"]:Disconnect()
				Cache["Loops"]["AutoDodge"] = nil 
			end

			if Settings["Player"]["AutoDodge"] then 
				Cache["Loops"]["AutoDodge"] = Services.RunService.Heartbeat:Connect(function()
					local Launcher = Services.Workspace.Ignored:FindFirstChild("Launcher")
					local oldPos = nil  
					local Attacked = false 
					if Launcher and not Attacked then 
						local mag = (Launcher.Position - Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position).magnitude

						if mag < 10 then 
							print("yes")
							Attacked = true 
							Services.LocalPlayer.HumanoidRootPart.CFrame = CFrame.new(100,100,100)
							oldPos = Services.LocalPlayer.HumanoidRootPart.CFrame
						end 
					end 
					if not Launcher and Attacked then 
						Attacked = false 
						Services.LocalPlayer.HumanoidRootPart.CFrame = oldPos 
					end 

				end)
				return 
			end 
			if Cache["Loops"]["AutoDodge"] ~= nil then 
				Cache["Loops"]["AutoDodge"]:Disconnect()
				Cache["Loops"]["AutoDodge"] = nil 
			end
		end,

		["GetPlayer"] = function(name)
			for index,player in pairs(Services.Players:GetPlayers()) do 
				if string.find(string.lower(player.Name),string.lower(name)) or string.find(string.lower(player.DisplayName),string.lower(name))  then
					if player.Name ~= Services.LocalPlayer.Name then 
						return player.Name 
					end 
				end 
			end 
		end,

		["GetTps"] = function ()
			if not isfolder("Legion/TP") then return {} end 
			return listfiles("Legion/TP")
		end,

		["Chat"] = function (message)
			assert(type(message) == "string", "Message should be a string")
			Services.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents").SayMessageRequest:FireServer(message, "All")
		end, 

		["Void"] = function (character, part,drop)
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
			BodyVelocity.Velocity = Vector3.new(9e9,-9e9,9e9)
			if part ~= nil then 
				BodyVelocity.Parent = character[part]
			else
				BodyVelocity.Parent = character.UpperTorso
			end
			task.wait(0.1)
			if not drop or drop ~= nil then 
				Services.ReplicatedStorage:FindFirstChild("MainEvent"):FireServer("Grabbing",false)
			end 
		end,

		["Stop"] = function(id,key)
			Services.ReplicatedStorage:WaitForChild("MainEvent"):FireServer("BoomboxStop")
		end,

		["TweenPosition"] = function(Part,Speed,Position)
			Services.TweenService:Create(Part,TweenInfo.new(Speed,Enum.EasingStyle.Linear),{Position = Position}):Play()
		end, 
		["TweenCFrame"] = function(Part,Speed,Position)
			Services.TweenService:Create(Part,TweenInfo.new(Speed,Enum.EasingStyle.Linear),{CFrame = Position}):Play()
		end, 
		["View"] = function (target)
			if target ~= nil and Services.Workspace.Players:FindFirstChild(target) then
				Services.Workspace:FindFirstChild("Camera").CameraSubject =  Services.Workspace.Players:FindFirstChild(target).Humanoid
			end 
		end,

		["CFrameToString"] = function(cf)
			return table.concat({cf:GetComponents()},",")
		end,

		["AddEnv"] = function(variable,setting)
			local env = getgenv() or _ENV or getfenv()

			if env[variable] or env[variable] == setting then
				print(`[❌] Variable "[{varaible}]" was already found in the env`)
				return 
			end 
			
			local success,err = pcall(function()
				env[variable] = setting 
			end)

			if success then 
				print(`[✅] Successfully added "[{variable}] to the env"`)
				return 
			end 

			print(`[❌] Something went wrong when trying to add "[{variable}]" to the env: {err}`)
		end ,

		["StringToCFrame"] = function (str)
			local components = {}
			for value in string.gmatch(str,"([^,]+)") do 
				table.insert(components,tonumber(value))
			end 
			if #components ~= 12 then return print("Error") end 
			return CFrame.new(unpack(components))
		end,

		["TurnTextToFont"] = function(text)
			local output = ""
			for i = 1, #text do
				local char = text:sub(i, i)
				output = output .. (Cache["Char_Map"][char] or char)
			end
			return output
		end,


		-- [[ Control set up ]]--
		["CloneCharacter"] = function(character)
			character.Archivable = true 

			local Clone = character:Clone()
			Clone:FindFirstChild("HumanoidRootPart").Anchored = false 
			Clone:FindFirstChild("Humanoid").Health = 9e9 
			Clone:FindFirstChild("Humanoid").MaxHealth = 9e9

			if Clone:FindFirstChild("RagdollConstraints") then 
				Clone:FindFirstChild("RagdollConstraints"):Destroy()
			end

			if Clone:FindFirstChild("BodyEffects") then 
				Clone:FindFirstChild("BodyEffects"):Destroy()
			end

			if Clone:FindFirstChild("GRABBING_CONSTRAINT") then 
				Clone:FindFirstChild("GRABBING_CONSTRAINT"):Destroy()
			end

			for index,part in pairs(Clone:GetDescendants()) do 
				if part:IsA("BasePart") then 
					if part.Name ~= "Head" and
						part.Name ~= "HumanoidRootPart" and
						part.Name ~= "UpperTorso" and
						part.Name ~= "LowerTorso" and
						part.Name ~= "LeftUpperArm" and
						part.Name ~= "RightUpperArm" and
						part.Name ~= "LeftLowerArm" and
						part.Name ~= "RightLowerArm" and
						part.Name ~= "LeftHand" and
						part.Name ~= "RightHand" and
						part.Name ~= "LeftUpperLeg" and
						part.Name ~= "RightUpperLeg" and
						part.Name ~= "LeftLowerLeg" and
						part.Name ~= "RightLowerLeg" and
						part.Name ~= "LeftFoot" and
						part.Name ~= "RightFoot" then
						part.Massless = false
						part:Destroy()
					end
					part.CustomPhysicalProperties = PhysicalProperties.new(100, 2, .5, 100, 1)
					part.Transparency = 1
				end

				if part:IsA("Decal") then 
					part.Transparency = 1
				end

				if part:IsA("Motor6D") then 
					part:Destroy()
				end
			end

			Clone.Parent = Services.LocalPlayer.Character
			Clone:FindFirstChild("Humanoid"):ChangeState("GettingUp")

			character.LeftHand:FindFirstChildOfClass("Motor6D").Enabled = false
			character.RightHand:FindFirstChildOfClass("Motor6D").Enabled = false
			character.LeftFoot:FindFirstChildOfClass("Motor6D").Enabled = false
			character.RightFoot:FindFirstChildOfClass("Motor6D").Enabled = false

			return Clone

		end,

		["DestroyClone"] = function(clone,orgincharacter)
			if clone ~= nil then 
				clone:Destroy()
			end 

			if orgincharacter ~= nil then 
				orgincharacter.LeftHand:FindFirstChildOfClass("Motor6D").Enabled = true
				orgincharacter.RightHand:FindFirstChildOfClass("Motor6D").Enabled = true
				orgincharacter.LeftFoot:FindFirstChildOfClass("Motor6D").Enabled = true
				orgincharacter.RightFoot:FindFirstChildOfClass("Motor6D").Enabled = true
			end 
		end,

		["AlignControl"] = function(Part1,Part2,Offset)
			Part1.AssemblyLinearVelocity = Vector3.zero
			Part1.AssemblyAngularVelocity = Vector3.zero
			Part1.Velocity = Vector3.zero
			Part1.CFrame = Part2.CFrame * (Offset or CFrame.new())
			Part1.CanCollide = false
			Part2.CanCollide = false
		end,

		-- [[ Destroy Tool ]]--
		["DestroyTool"] = function(toolName)
			local Tool = Services.LocalPlayer.Backpack:FindFirstChild(toolName)  or Services.LocalPlayer.Character:FindFirstChild(toolName)
			if Tool then 
				Tool:Destroy()
			end

			if Cache[toolName] then 
				Cache[toolName]:Disconnect()
				Cache[toolName] = nil
			end
		end,

		["GetForwardPosition"] = function(distance)
			return Services.LocalPlayer.Character.HumanoidRootPart.Position + (Services.LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * distance)
		end,

		["LoadAnimation"] = function(character,anim)
			return character:FindFirstChildOfClass("Humanoid"):LoadAnimation(anim)
		end,

		["Anti Slow"] = function()
			if Cache["Loops"]["Anti Slow"] ~= nil then 
				Cache["Loops"]["Anti Slow"]:Disconnect()
				Cache["Loops"]["Anti Slow"] = nil 
			end 

			if Settings["Player"]["Anti Slow"] then 
				Cache["Loops"]["Anti Slow"] = Services.RunService.Heartbeat:Connect(function()
					if not Settings["Player"]["Anti Slow"] then 
						Cache["Loops"]["Anti Slow"]:Disconnect()
						Cache["Loops"]["Anti Slow"] = nil
					end 
					if Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("BodyEffects") then 
						for index,slow in pairs(Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("BodyEffects").Movement:GetDescendants()) do 
							if slow.Name == "NoWalkSpeed" or slow.Name == "ReduceWalk" or slow.Name == "NoJumping" then 
								slow:Destroy()
							end 
						end 

						Services.LocalPlayer.Character:FindFirstChild("BodyEffects").Reload.Value = false 
					end
				end)
				return 
			end 
			if Cache["Loops"]["Anti Slow"] ~= nil then 
				Cache["Loops"]["Anti Slow"]:Disconnect()
				Cache["Loops"]["Anti Slow"] = nil 
			end 
		end,
	} 

	local Animations = {
		--Basic
		["Grab"] = Modules["CreateAnimation"]("3135389157"),
		["Roll"] = Modules["CreateAnimation"]("2791328524"),
		["Angry"] = Modules["CreateAnimation"]("2788838708"),
		["Punch"] = Modules["CreateAnimation"]("3354696735"),
		["Elevate"] = Modules["CreateAnimation"]("11394033602"),

		--Niggers
		["Double_Handle"] = Modules["CreateAnimation"]("4784557631"),
		["Get Over Here"] = Modules["CreateAnimation"]("16768625968"),

		--Iron Man
		["IM_Freefall"] = Modules["CreateAnimation"]("13850654420"),
		["IM_Land"] = Modules["CreateAnimation"]("13850663836"),
		["IM_Rizzler"] = Modules["CreateAnimation"]("13850680182"),

		-- Ora
		["Ora1"] = Modules["CreateAnimation"]("8254787838"),
		["Ora2"] = Modules["CreateAnimation"]("8254794168"),

		-- Punch back 
		["Punch back"] = Modules["CreateAnimation"]("17360699557"),

		["Time Stop Charging"] = Modules["CreateAnimation"]("10714177846"),


	}

	local Sounds = {

		["Rip"] = "429400881",
		["Ora"] = "6889746326",
		["Kick"] = "6899466638",
		["Punch"] = "3280066384",
		["Lightning"] = "6955233353",

		["LoudPunch"] = "2319521125",
		["Loud Za Warudo"] = "8981087259",
		["N Word Spam"] = "5986485937",

		-- Get Over Here
		["Get Over Here!"] = "8643750815",
		["Chain"] = "7592607446",

		-- Barrages, JoJo
		["Dora"] = "6995347277", -- Josuke
		["Ora Barrage"] = "6678126154", -- Jotaro
		["SaW Ora Barrage"] = "6599245588", -- Josuke P8
		["Short Muda"] = "6564057272", -- Diego AU 



		-- Time Stop 
		["Time Stop"] = "5455437798",
		["Time Resume"] = "3084539117",
		["When Time is Stopped, There is Only Dio!"] = "6964764259",
		["Muda Muda Muda"] = "6889746326",
		["Muda!"] = "6191764144",
		["Countdown"] = "6675055864",
		["Zero."] = "7099835652",    
		["Loud Time Resume"] = "6995347277",

		["VoiceLines"] = {
				["This is a test"] = "6949881467", -- Doppio
				["Impossible!? I can't Move"] = "6946266008", -- Dio
				["The one who misread one move... were You."] = "6665016112", -- Funny Valentine
				["Weakling, Weakling!"] = "6924545163", -- Dio
				["I'll teach you the meaning of the word 'retire'"] = "7075003019", -- Diego AU
				["but for you, I feel no pity at all."] = "5842011186",
				["I've been possessed by an evil spirit."] = "5463102834",
				["The one to Judge you is my Stand!"] = "5807033225",
				["I'll smash you to pieces."] = "5584305519",
				["Hm."] = "9127269834",
				["Hm? Not bad."] = "4894428927",
				["Haha!"] = "9127270745",
				["ZA WARUDO!"] = "1571597070",
				["yare yare."] = "8657023668",
				["This is The Greatest High!"] = "6177204732",
				["Monions, Monions"] = "5986485937",
				["IMMORTALITY, ETERNAL STANDO POWER!"] = "4580050667",
				["In the name of GOD I will smite you!"] = "5114781956",
				["Do you understand?"] = "8925079995",
				["Good Grief. I made it in time."] = "6520270988",
			
				["You did well on your own."] = "5554488284",
				["But even if u stop time, I'm still going to blow your head off!"] = "6520346428",
				["Why you? I will fight u later.."] = "4894016902",
				["I, Jotaro, shall show no mercy!"] = "6186957635",
				["Star Platinum Over Heaven!"] = "5684695930",
				["Star Platinum!"] = "5059176420",
				["Barrage!"] = "5487424124",
				["Ora!"] = "5867741895",
				["I'll be the judge!"] = "5344619446",
				["What you Just saw, What just hit you, was ME!"] = "5258899114",
				["😴"] = "9084006093",
				["Ho ho ho ho"] = "8974931854",
				["Ben."] = "8974933491",
				["Yes"] = "8974932300",
				["No"] = "8974931344",
				["IP leaked? NO"] = "9074550320",
				["😜😜😜"] = "5531057176",
				["I love monions"] = "9087418452",
				["The hell you keep yammering about.."] = "8397361051",
				["Hey! What do you mean?"] = "8322982206",
				["Shut up! You're damn annyoing..."] = "6066726827",
				["Yarou.."] = "8366318357",
				["He can come."] = "4903897880",
				["You're done for.."] = "8404022704",
				["What's wrong?"] = "8600140455",

			

				["You will definitely pay!"] = "4903895449",
				["I, Jotara will end you myself."] = "5296176563",
				["Ally or Enemy? It's your choice."] = "8825179323",
				["Do you want a fight? I'll give you a fight."] = "5111658124",
				["What did you just call me?"] = "8322803654",
				["Hold it."] = "8404017376",
				["Star Platinum ! ZA WARUDO!"] = "5736107502",
				["Time Has Begun to Move again."] = "6678124632",
				["Time shall resume!"] = "6678124632",
			

		},
		-- Voicelines idk 

	}

	--> Removed: Control,Sex and Hoverboard because we do not want skids
	
	local Tools = {
	

		["Time Stop"] = function()
			local success,err = pcall(function()
				if Settings["Grab"]["Time Stop"] then 
					Modules["CreateTool"]("Time Stop",function()

						if Settings["Grab"]["GrabbedCharacter"] == nil then 
							return 
						end

						if Cache["Loops"]["Ora"] ~= nil then 
							Cache["Loops"]["Ora"]:Disconnect()
							Cache["Loops"]["Ora"] = nil 
						end 

						Settings["Grab"]["Grab"] = false 

						Modules["StopAnimation"](Services.LocalPlayer.Character,"3135389157")
						Modules["StopAnimation"](Services.LocalPlayer.Character,"11075367458")

						Modules["Play"](Sounds["Time Stop"])

						local Load = Modules["LoadAnimation"](Services.LocalPlayer.Character,Animations["Time Stop Charging"])
						Load.Priority = Enum.AnimationPriority.Action4
						Load:Play()
						task.wait(2.5)

						Modules["StopAnimation"](Services.LocalPlayer.Character,"10714177846") -- time stop charging
						Modules["StopAudio"]()
						task.wait(0.3)

						Modules["Play"](Sounds["When Time is Stopped, There is Only Dio!"])
						Modules["Chat"]("When Time is Stopped, There is Only Dio!")
						if Settings["Grab"]["Effects"] then 
							Services.TweenService:Create(Services.Lighting.ColorCorrection, TweenInfo.new(1), {Contrast = -1.8}):Play()
						end 
						task.wait(4)

						Modules["StopAudio"]()
						Modules["Play"](Sounds["Countdown"])

						for i,v in pairs({4,3,2,1}) do 
							if tostring(v) == "1" then
								Modules["Chat"]("1 Second left...")

							else  
								Modules["Chat"](tostring(v).." Seconds left...")
							end 
							task.wait(1.5)
						end
						task.wait(1)
						Modules["StopAudio"]()
						task.wait(0.2)
						Modules["Play"](Sounds["Muda Muda Muda"])

						Cache["Loops"]["Ora"] = Services.RunService.Heartbeat:Connect(function()
							if Settings["Grab"]["GrabbedCharacter"] ~= nil then 
								Settings["Grab"]["GrabbedCharacter"].UpperTorso:FindFirstChild("BodyPosition").Position = Modules["GetForwardPosition"](2.8)
								return
							end 

							Cache["Loops"]["Ora"]:Disconnect()
						end)

						for i = 1,10 do 
							Modules["StopAnimation"](Services.LocalPlayer.Character,8254794168)
							Modules["AnimPlay"](Services.LocalPlayer.Character,8254787838,9)
							task.wait(0.2)
							Modules["StopAnimation"](Services.LocalPlayer.Character,8254787838)
							Modules["AnimPlay"](Services.LocalPlayer.Character,8254794168,9)
							task.wait(0.2)
						end

						Modules["StopAnimation"](Services.LocalPlayer.Character,"8254794168")
						task.wait(0.1)

						Cache["Loops"]["Ora"]:Disconnect()

						Modules["Play"](Sounds["Muda!"])
						Modules["AnimPlay"](Services.LocalPlayer.Character,"3354696735",1.5)
						task.wait(1)

						Modules["Play"](Sounds["Zero."])
						task.wait(0.3)

						Modules["Chat"]("Zero.")
						task.wait(3)

						Modules["Play"](Sounds["Time Resume"])
						Modules["Chat"]("The time shall move again!")
						task.wait(2)

						Modules["Play"](Sounds["LoudPunch"])
						Modules["TweenPosition"](Settings["Grab"]["GrabbedCharacter"].UpperTorso:FindFirstChild("BodyPosition"),0.8, Modules["GetForwardPosition"](19))
						task.wait(1)

						Modules["Remove"](Settings["Grab"]["GrabbedCharacter"],"all")
						Modules["Play"](Sounds["Rip"])
						Services.TweenService:Create(Services.Lighting.ColorCorrection, TweenInfo.new(1), {Contrast = 0}):Play()
						task.wait(0.3)

						Services.ReplicatedStorage.MainEvent:FireServer("Grabbing",false)
						task.wait(0.7)

						Modules["StopAudio"]()
						Settings["Grab"]["Grab"] = true 

					end)
					return
				end 
				Modules["DestroyTool"]("Time Stop")
			end)

			if not success then 
				print("A error occured when trying to use Time stop : ["..tostring(err).."]")
			end
		end,

		["Hado 90"] = function()
			if Settings["Grab"]["Hado 90"] then
				Modules["CreateTool"]("Hado 90", function()
					if Settings["Grab"]["GrabbedCharacter"] == nil then
						return
					end
					Settings["Grab"]["Grab"] = false 
					Modules["Chat"]("Watashi no Reiatsu de jikai-shiro")
					Modules["Play"]("4743237673")
					
					if Services.LocalPlayer.Character.LowerTorso:FindFirstChild("BOOMBOXSOUND") then
						task.wait(2.5)
						Modules["Play"]("18641380807")
						Modules["Chat"]("Hado 90")
					end
					if Settings["Grab"]["Effects"] then 
						local Part = Instance.new("Part")
						Part.Anchored = true
						Part.BottomSurface = Enum.SurfaceType.Smooth
						Part.CanCollide = false
						Part.TopSurface = Enum.SurfaceType.Smooth
						Part.Color = Color3.fromRGB(17, 17, 17)
						Part.Material = Enum.Material.Neon
						Part.Size = Vector3.new(9, 25, 9)
						
						
						local Highlight = Instance.new("Highlight")
						Highlight.OutlineColor = Color3.fromRGB(170, 0, 255)
						Highlight.FillColor = Color3.fromRGB(0, 0, 0)
						Highlight.Parent = Part
						
						Part.Parent = workspace
						
						Part.CFrame = CFrame.new(Settings["Grab"]["GrabbedCharacter"].UpperTorso.Position + Vector3.new(0, -50, 0))
						
						Services.TweenService:Create(Part, TweenInfo.new(1), {CFrame = CFrame.new(Settings["Grab"]["GrabbedCharacter"].UpperTorso.Position + Vector3.new(0, 5, 0))}):Play()
					end
					task.wait(5)
					if Settings["Grab"]["Effects"] then 
						Services.TweenService:Create(Part, TweenInfo.new(1), {CFrame = CFrame.new(Settings["Grab"]["GrabbedCharacter"].UpperTorso.Position + Vector3.new(0, 50, 0))}):Play()
					end
					Modules["Void"](Settings["Grab"]["GrabbedCharacter"])
					task.wait(1)
					Part:Destroy()
					Settings["Grab"]["Grab"] = true
				end)
				return
			end
			Modules["DestroyTool"]("Hado 90")
		end,
		
		["C Moon"] = function()
			if Settings["Grab"]["C Moon"] then
				Modules["CreateTool"]("C Moon", function()
					if Settings["Grab"]["GrabbedCharacter"] == nil then 
						return 
					end
					Services.LocalPlayer.Character.Humanoid.WalkSpeed = 0
					Settings["Grab"]["Grab"] = false 
					Modules["Play"]("8063279487")
					if Settings["Grab"]["Effects"] then 
						Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {ColorShift_Bottom = Color3.fromRGB(0,255,0)}):Play()
						Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {ColorShift_Top = Color3.fromRGB(0,255,0)}):Play()
						Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {Brightness = 100}):Play()
						Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {Ambient = Color3.fromRGB(0,255,0)}):Play()
					end 
					Modules["Chat"]("C MOON: GRAVITY MOON")
					Modules["AnimPlay"](Services.LocalPlayer.Character,8254789608)
					Settings["Grab"]["GrabbedCharacter"].UpperTorso.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,2000,0)
					task.wait(3.5)

					Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {ColorShift_Bottom = Color3.fromRGB(0,0,0)}):Play()
					Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {ColorShift_Top = Color3.fromRGB(0,0,0)}):Play()
					Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {Brightness = 1}):Play()
					Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {Ambient = Color3.fromRGB(0,0,0)}):Play()
					Settings["Grab"]["Grab"] = true	
				end)
				return
			end
			Modules["DestroyTool"]("C Moon")
		end,

		["Made In Heaven"] = function()
			if Settings["Grab"]["Made In Heaven"] then
				Modules["CreateTool"]("Made In Heaven", function()
					if Settings["Grab"]["GrabbedCharacter"] == nil then 
						return 
					end

					local old_fov = workspace.CurrentCamera.FieldOfView
					local old_fog = game.Lighting.FogEnd
					local old_fog_color = game.Lighting.FogColor

					Services.LocalPlayer.Character.Humanoid.WalkSpeed = 0
					Modules["StopAnimation"](Services.LocalPlayer.Character,"3135389157")
					Settings["Grab"]["Grab"] = false 
					Modules["Play"]("8004825017")
					Modules["Chat"]("Made In Heaven..")

					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Settings["Grab"]["GrabbedCharacter"].UpperTorso.CFrame * CFrame.new(1, 0, 3)

					Services.LocalPlayer.Character.BodyEffects.Grabbed:GetPropertyChangedSignal("Value"):Connect(function()
						if Services.LocalPlayer.Character.BodyEffects.Grabbed.Value == nil then
							Services.TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1), {FieldOfView = old_fov}):Play()
							Services.TweenService:Create(game.Lighting, TweenInfo.new(1), {FogEnd = old_fog}):Play()
							Services.TweenService:Create(game.Lighting, TweenInfo.new(1), {FogColor =old_fog_color}):Play()
							Services.TweenService:Create(Services.LocalPlayer.Character.Humanoid, TweenInfo.new(1), {HipHeight = 2}):Play()
							task.wait(0.2)
							Modules["StopAnimation"](Services.LocalPlayer.Character,"11394033602")

						end
					end)
					Modules["AnimPlay"](Services.LocalPlayer.Character,11394033602)
					if Settings["Grab"]["Effects"] then 
						Services.TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1), {FieldOfView = 120}):Play()
						Services.TweenService:Create(game.Lighting, TweenInfo.new(1), {FogEnd = 20}):Play()
						Services.TweenService:Create(game.Lighting, TweenInfo.new(1), {FogColor = Color3.fromRGB(255,255,255)}):Play()
					end
					Services.TweenService:Create(Services.LocalPlayer.Character.Humanoid, TweenInfo.new(1), {HipHeight = 3.5}):Play()

					repeat wait() until Services.LocalPlayer.Character.Humanoid.HipHeight == 3.5

					Modules["Chat"]("Heaven Has Arrived...")
					Modules["TweenPosition"](Settings["Grab"]["GrabbedCharacter"].UpperTorso.BodyPosition,0.5,Modules["GetForwardPosition"](10)+ Vector3.new(0,10,0))
					task.wait(7)
					Modules["Void"](Settings["Grab"]["GrabbedCharacter"])
					task.wait(0.8)
					Modules["StopAnimation"](Services.LocalPlayer.Character,"11394033602")
					Settings["Grab"]["Grab"] = true				
				end)
				return 
			end
			Modules["DestroyTool"]("Made In Heaven")
		end,

		

		

		["Chezburger"] = function()
			if Settings["Grab"]["Chezburger"] then 
				Modules["CreateTool"]("Mmm.. chezburger",function()
					if Settings["Grab"]["GrabbedCharacter"] == nil then 
						return 
					end

					local success,err = pcall(function()
						Modules["Play"]("6647570")
						Modules["Chat"]("Can i haz chezburger ples?")
						task.wait(3)

						Modules["StopAnimation"](Services.LocalPlayer.Character,3135389157)
						Modules["AnimPlay"](Services.LocalPlayer.Character,2953512033)

						Modules["Play"]("3043029786")
						Modules["Remove"](Settings["Grab"]["GrabbedCharacter"],"all")
						task.wait(0.2)
						Services.ReplicatedStorage.MainEvent:FireServer("Grabbing",false)
						task.wait(1.5)

						Modules["Play"]("16647579")
                    	Modules["Chat"]("Mmm... chezburger!")
					end)

					if not success then 
						print("A error occured when using Chezburger [ "..err.." ]")
					end
				end)
				return 
			end 
			Modules["DestroyTool"]("Mmm.. chezburger")
		end,

		["Orbit"] = function ()
			if Settings["Grab"]["Orbit"] then 
				local success,err = pcall(function()
					Modules["CreateTool"]("Orbit",function()
						
						if Cache["Loops"]["Orbit"] ~= nil then 
							Cache["Loops"]["Orbit"]:Disconnect()
							Cache["Loops"]["Orbit"]  =nil 
						end 
						local currentTime = 0
						Modules["StopAnimation"](Services.LocalPlayer.Character,"3135389157")
						Modules["StopAnimation"](Services.LocalPlayer.Character,"11075367458")

						Cache["Loops"]["Orbit"] = Services.RunService.Heartbeat:Connect(function(delta)
							currentTime = currentTime + delta
							if Services.LocalPlayer.Character.BodyEffects:FindFirstChild("Grabbed").Value == nil then 
								Cache["Loops"]["Orbit"]:Disconnect()
								Cache["Loops"]["Orbit"]  = nil
							end 
							
							Settings["Grab"]["GrabbedCharacter"].UpperTorso.CFrame      = CFrame.Angles(math.pi * 0.1, 1.5 * math.pi * currentTime, 0)* CFrame.new(1, 2, 5) + Services.LocalPlayer.Character.HumanoidRootPart.Position
							Settings["Grab"]["GrabbedCharacter"].LowerTorso.CFrame      = CFrame.Angles(math.pi * -0.1, 1.5 * math.pi * -currentTime, 0)* CFrame.new(1, 2, 5) + Services.LocalPlayer.Character.HumanoidRootPart.Position
							Settings["Grab"]["GrabbedCharacter"].LeftUpperArm.CFrame    = CFrame.Angles(math.pi * .25, 3 * math.pi * currentTime, 0)* CFrame.new(1, 2, 5) + Services.LocalPlayer.Character.HumanoidRootPart.Position
							Settings["Grab"]["GrabbedCharacter"].RightUpperArm.CFrame   = CFrame.Angles(math.pi * -.25, 3 * math.pi * -currentTime, 0)* CFrame.new(1, 2, 5) + Services.LocalPlayer.Character.HumanoidRootPart.Position
							Settings["Grab"]["GrabbedCharacter"].LeftUpperLeg.CFrame    = CFrame.Angles(math.pi * .3, 2.5 * math.pi * currentTime, 0)* CFrame.new(1, 2, 5) + Services.LocalPlayer.Character.HumanoidRootPart.Position
							Settings["Grab"]["GrabbedCharacter"].RightUpperLeg.CFrame   = CFrame.Angles(math.pi * -.3, 2.5 * math.pi * -currentTime, 0)* CFrame.new(1, 0, 5) + Services.LocalPlayer.Character.HumanoidRootPart.Position
							Settings["Grab"]["GrabbedCharacter"].LeftLowerLeg.CFrame    = CFrame.Angles(math.pi * .7, 2 * math.pi * currentTime, 0)* CFrame.new(1, 2, 7) + Services.LocalPlayer.Character.HumanoidRootPart.Position
							Settings["Grab"]["GrabbedCharacter"].RightLowerLeg.CFrame   = CFrame.Angles(math.pi * .8, 2 * math.pi * -currentTime, 0)* CFrame.new(1, 2, 7) + Services.LocalPlayer.Character.HumanoidRootPart.Position
							Settings["Grab"]["GrabbedCharacter"].LeftLowerArm.CFrame    = CFrame.Angles(math.pi * .9, 2 * math.pi * currentTime, 0)* CFrame.new(1, 2, 7) + Services.LocalPlayer.Character.HumanoidRootPart.Position
							Settings["Grab"]["GrabbedCharacter"].RightLowerArm.CFrame   = CFrame.Angles(math.pi * 1, 2 * math.pi * -currentTime, 0)* CFrame.new(1, 2, 7) + Services.LocalPlayer.Character.HumanoidRootPart.Position
						end)
					end)
				end)
				if not success then 
					print("A error occured when using Orbit : [ "..err.." ]")
				end 
				return 
			end 
			Modules["DestroyTool"]("Orbit")
		end,
		["Get Over Here"] = function()
			if Settings["Grab"]["Get Over Here"] then 
				Modules["CreateTool"]("Get Over Here",function()
					local success,err = pcall(function()
						Settings["Grab"]["Grab"] = false 
						
						Modules["StopAnimation"](Services.LocalPlayer.Character,"3135389157")
						Modules["StopAnimation"](Services.LocalPlayer.Character,"11075367458")


						Modules["Play"]("8643750815")
						task.wait(1.6)
						Modules["StopAudio"]()
						Modules["Play"]("7592607446")
						Modules["LoadAnimation"](Services.LocalPlayer.Character,Animations["Get Over Here"]):Play()
						task.wait(1.1)
						Modules["TweenPosition"](Settings["Grab"]["GrabbedCharacter"].UpperTorso.BodyPosition,0.6,Services.LocalPlayer.Character.HumanoidRootPart.Position)
						task.wait(0.6)
						Modules["StopAudio"]()
					end)

					if not success then 
						print("An error happend while trying to use Get Over Here: "..err)
					end 
				end)
				return 
			end 
			Modules["DestroyTool"]("Get Over Here")
		end,
		["Make Player Stand"] = function()
			if Settings["Grab"]["Make Player Stand"] then 
				Modules["CreateTool"]("Make Player Stand",function()
					Settings["Grab"]["Grab"] = false
					local success,err = pcall(function()
						if Settings["Grab"]["GrabbedCharacter"] == nil then 
							return 
						end 
						
						if Cache["Loops"]["Make Player Stand"] ~= nil then 
							Cache["Loops"]["Make Player Stand"]:Disconnect()
							Cache["Loops"]["Make Player Stand"] = nil 
						end 

						local Clone = Modules["CloneCharacter"](Settings["Grab"]["GrabbedCharacter"])

						Modules["StopAnimation"](Services.LocalPlayer.Character,"3135389157")
						Modules["StopAnimation"](Services.LocalPlayer.Character,"11075367458")

						local OldChar = Settings["Grab"]["GrabbedCharacter"]

						for index,part in pairs(Settings["Grab"]["GrabbedCharacter"]:GetDescendants()) do 
							if part:IsA("BodyPosition") or part:IsA("BodyGyro") then 
								part:Destroy()
							end 
						end 

						local rootPart = Services.LocalPlayer.Character.HumanoidRootPart

						Cache["Loops"]["Make Player Stand"] = Services.RunService.Heartbeat:Connect(function()
							
							if Services.LocalPlayer.Character.BodyEffects.Grabbed.Value == nil then 
								Settings["Grab"]["Grab"] = true
								Modules["DestroyClone"](Clone,OldChar)
								Cache["Loops"]["Make Player Stand"]:Disconnect()
								Cache["Loops"]["Make Player Stand"] = nil  
							end 
							for index, part in pairs(Settings["Grab"]["GrabbedCharacter"]:GetChildren()) do 
								if part:IsA("BasePart") then 
									Modules["AlignControl"](part,Clone[part.Name],CFrame.new(0,0,0))
								end 
							end 
							
							
							

							Modules["NoVelocity"](Clone)
							Modules["NoVelocity"](Settings["Grab"]["GrabbedCharacter"])
							
							for index, anim in pairs(Clone:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
								if not anim.Animation.AnimationId:match("rbxassetid://" .. tostring(3541044388)) and not anim.Animation.AnimationId:match("rbxassetid://" .. tostring(3541114300)) then
									anim:Stop()
								end
							end

							local BodyGyro =  Clone.UpperTorso:FindFirstChild("BodyGyro") or nil 
							if not Clone.UpperTorso:FindFirstChild("BodyGyro") then 
								BodyGyro = Instance.new("BodyGyro")
								BodyGyro.D = 100 
							end 
							BodyGyro.CFrame = Services.LocalPlayer.Character.HumanoidRootPart.CFrame 
							
							Services.TweenService:Create(Clone.HumanoidRootPart, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = CFrame.new(rootPart.Position+ rootPart.CFrame.LookVector * -3+ rootPart.CFrame.RightVector * -1+ Vector3.new(0, math.random(3,4.2), 0))}):Play()
							--[[
							if Services.LocalPlayer.Character.Humanoid.MoveDirection.Magnitude  > 0 and not Modules["CheckForAnimation"](Clone,3541044388) then 
								Modules["StopAnimation"](Clone,3541114300)
								Modules["AnimPlay"](Clone,3541044388)
							elseif not Modules["CheckForAnimation"](Clone,3541114300) and Services.LocalPlayer.Character.Humanoid.MoveDirection.Magnitude == 0 then 
								Modules["StopAnimation"](Clone,3541044388)
								Modules["AnimPlay"](Clone,3541114300)
							end ]]--

						end)
						Modules["AnimPlay"](Clone,3541114300)

						
					end)
					
					if not success then 
						print("A error occured when trying to use Make Player Stand: "..err)
					end 
				end)
				return 
			end 
			if Cache["Loops"]["Make Player Stand"] ~= nil then 
				Cache["Loops"]["Make Player Stand"]:Disconnect()
				Cache["Loops"]["Make Player Stand"] = nil 
			end 
			Settings["Grab"]["Grab"] = true
			Modules["DestroyTool"]("Make Player Stand")
		end ,
		["Punch Back"] = function()
			if Settings["Grab"]["Punch Back"] then 
				Modules["CreateTool"]("Punch Back",function()
					local success,err = pcall(function()
						Settings["Grab"]["Grab"] = false 
						local ForwardPosition = Modules["GetForwardPosition"](50)
						local Name = Settings["Grab"]["GrabbedCharacter"]

						local Clones = {}
						Modules["StopAnimation"](Services.LocalPlayer.Character,"3135389157")
						Modules["StopAnimation"](Services.LocalPlayer.Character,"11075367458")

						local function PushBackClone(where)
							task.spawn(function()
								local Clone = Modules["CloneCharacter"](Settings["Grab"]["GrabbedCharacter"])
								local FallBackAnimation = Modules["LoadAnimation"](Clone,Animations["Punch back"])
	
								Clones[#Clones+1] = Clone

								for index, part in pairs(Clone:GetChildren()) do 
									if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
	
										part.Material = "ForceField"
										part.Transparency = 0.3
										part.Color = Color3.fromRGB(255,255,255)
	
										part.CanCollide = false 
									end 
								end
	
								FallBackAnimation.Priority = Enum.AnimationPriority.Action4
								Clone.HumanoidRootPart.CFrame = where 
								
	
	
								FallBackAnimation:Play()
								task.wait(0.545)
								FallBackAnimation:AdjustSpeed(0)
							end)	
						end 

						local PunchAnim = Modules["LoadAnimation"](Services.LocalPlayer.Character,Animations["Punch"])
						PunchAnim:Play()
						task.wait(.3)
						PunchAnim:AdjustSpeed(0.05)
						Modules["Play"]("8578316223")
						task.wait(11.1)
						PunchAnim:AdjustSpeed(1)
						Modules["StopAudio"]()
						Modules["Play"]("6290067239")
						Modules["TweenPosition"](Settings["Grab"]["GrabbedCharacter"].UpperTorso:FindFirstChild("BodyPosition"),0.3,ForwardPosition)
						if Settings["Grab"]["Effects"] then 
							for i = 1,4 do 
								PushBackClone(CFrame.new(Settings["Grab"]["GrabbedCharacter"].UpperTorso:FindFirstChild("BodyPosition").Position))
								task.wait()
							end 
						end 
						task.wait(.08)
						Modules["Void"](Settings["Grab"]["GrabbedCharacter"])
						
						task.wait(6)
						if Settings["Grab"]["Effects"] then 
							for index,clone in pairs(Clones) do 
								for index,part in pairs(clone:GetChildren()) do 
									if part:IsA("BasePart") then 
										
										Services.TweenService:Create(part, TweenInfo.new(2), {Transparency = 1}):Play()
									end 
								end 
							end 
						end
					end)

					if not success then 
						print("A error occured when trying to use Punch Back: "..err)
					end 
				end)
				return 
			end 
			Modules["DestroyTool"]("Punch Back")
		end,

		["Domain Expansion"] = function()
            if Settings["Grab"]["Domain Expansion"] then
                Modules["CreateTool"]("Domain Expansion", function()
                    if Settings["Grab"]["GrabbedCharacter"] == nil then
                        return
                    end
					local Animation = game:GetObjects("rbxassetid://15554016057")[1]
                    local loaded_Animation = Services.LocalPlayer.Character.Humanoid:LoadAnimation(Animation)

					Modules["StopAnimation"](Services.LocalPlayer.Character,"3135389157")
					Modules["StopAnimation"](Services.LocalPlayer.Character,"11075367458")

                    Services.LocalPlayer.Character.BodyEffects.Grabbed:GetPropertyChangedSignal("Value"):Connect(function()
                        if Settings["Grab"]["GrabbedCharacter"] == nil then
                            Services.TweenService:Create(Services.Lighting, TweenInfo.new(1), {FogColor = Color3.fromRGB(100,87,72)}):Play()
                            Services.TweenService:Create(Services.Lighting, TweenInfo.new(1), {FogEnd = 500}):Play()
                        end
                    end)
                    Settings["Grab"]["Grab"] = false 
                    Services.LocalPlayer.Character.Humanoid.WalkSpeed = 0
                    Modules["Play"]("7817341182")
                    Modules["Chat"]("Domain Expansion..")
                    task.wait(1.8)
                    Modules["Play"]("7817367014")
                    Modules["Chat"]("Malevolent Shrine.")
                    task.wait(5)
                    Modules["Play"]("7817336081")
                    task.wait(2.8)
                    loaded_Animation:Play()
                    loaded_Animation.Looped = false
                    task.wait(2.5)
					if Settings["Grab"]["Effects"] then 
						Services.TweenService:Create(Services.Lighting, TweenInfo.new(1), {FogColor = Color3.fromRGB(0,0,0)}):Play()
						Services.TweenService:Create(Services.Lighting, TweenInfo.new(1), {FogEnd = 50}):Play()
					end
					Services.TweenService:Create(Services.LocalPlayer.Character.Humanoid, TweenInfo.new(1), {HipHeight = 10}):Play()
                    task.wait(1)
                    Modules["TweenPosition"](Settings["Grab"]["GrabbedCharacter"].UpperTorso.BodyPosition,0.5,Modules["GetForwardPosition"](10)+ Vector3.new(0,0,0))
                    loaded_Animation.Stopped:Wait()
                    Modules["Void"](Settings["Grab"]["GrabbedCharacter"])
                    Settings["Grab"]["Grab"] = true
                    Services.TweenService:Create(Services.LocalPlayer.Character.Humanoid, TweenInfo.new(1), {HipHeight = 2.008}):Play()
                end)
                return
            end
            Modules["DestroyTool"]("Domain Expansion")
        end,

		["Portal"] = function()
			if Settings["Grab"]["Portal"] then 
				Modules["CreateTool"]("Portal",function()
					if Cache["Loops"]["Portal"] then 
						return 
					end 
					local StoredPos = Services.LocalPlayer.Character.HumanoidRootPart.CFrame
					Settings["Grab"]["Grab"] = false 
					local Storage = Services.ReplicatedStorage
					local Lighting = game:GetService("Lighting")
					local Assets = {}
					local Cloud = {}
					local StoredAssets = {}
					local function LoadAsset(delete,where)
						if delete then 
							for index,effect in pairs(StoredAssets) do 
								effect:Destroy()
							end
					
							for index,cloud in pairs(game:GetService("Workspace"):GetChildren()) do 
								if cloud.Name == "Clouds" then 
									cloud:Destroy()
								end 
							end
					
							return 
						end 
						for index,asset in pairs(Assets:GetChildren()) do 
							local Clone = asset:Clone()
							Clone.Parent = Lighting

							StoredAssets[#StoredAssets+1] = Clone 
						end 
						local Clone = Cloud:Clone()
						Clone.Parent = workspace
						Clone.CFrame = where
						Clone.Anchored = true
						
						return Clone
					end  
					
					if not Storage:FindFirstChild("Assets") then 
						Assets = game:GetObjects("rbxassetid://81123099704912")[1]
						Assets.Parent = Storage
					else
						Assets = Storage:FindFirstChild("Assets")
					end 
					
					if not Storage:FindFirstChild("Clouds") then 
						Cloud = game:GetObjects("rbxassetid://96210417036558")[1]
						Cloud.Parent = Storage
					else 
						Cloud = Storage:FindFirstChild("Clouds")
					end 
					
					local GrabbedChar = Settings["Grab"]["GrabbedCharacter"]

					for index,vel in pairs(GrabbedChar:GetDescendants()) do 
						if vel:IsA("BodyGyro") or vel:IsA("BodyPosition") then 
							vel:Destroy()
						end 
					end 

					local Clone = Modules["CloneCharacter"](GrabbedChar)
					Clone.Parent = workspace 
					local yes = false
					Clone.HumanoidRootPart.CFrame = Services.LocalPlayer.Character.HumanoidRootPart.CFrame
					Cache["Loops"]["Portal"] = Services.RunService.Heartbeat:Connect(function()
						for index,part in pairs(GrabbedChar:GetChildren()) do 
							if part:IsA("BasePart")  and not yes and Clone then 
								Modules["AlignControl"](part,Clone[part.Name],CFrame.new(0,0,0))
							end 
						end 
						Modules["NoVelocity"](GrabbedChar)
						Modules["CanCollide"](GrabbedChar,false)

						if Clone then 
							Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Clone.HumanoidRootPart.CFrame - Vector3.new(0,15,0)
						else
							Cache["Loops"]["Portal"]:Disconnect()
							Cache["Loops"]["Portal"] = nil
						end 

						if Services.LocalPlayer.Character.BodyEffects.Grabbed.Value == nil then 
							LoadAsset(true)
							Settings["Grab"]["Grab"] = true 
							Cache["Loops"]["Portal"]:Disconnect()
							Cache["Loops"]["Portal"] = nil
						end
					end)
					Services.Workspace.Camera.CameraSubject = Clone.Humanoid
					Modules["AnimPlay"](Clone,10714360343)
					task.wait(2)
					Modules["StopAnimation"](Clone,10714360343)
					Modules["CameraEffect"](Clone,3)
					if Settings["Grab"]["Effects"] then 
						LoadAsset(false,Clone.HumanoidRootPart.CFrame + Vector3.new(0,20,0))
					end
					Modules["AnimPlay"](Clone,4940561610)
					Modules["Play"](7224830040)
					task.wait(6)
					local BodyPos = Instance.new("BodyPosition",GrabbedChar.UpperTorso)
					local NewPart = Instance.new("Part",Services.Workspace)
					local Hum = Instance.new("Humanoid",NewPart)
					NewPart.CFrame = Services.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,20,0)
					NewPart.Transparency = 1
					NewPart.Anchored = true 

					
					
					BodyPos.D = 200

					BodyPos.Position = Clone.UpperTorso.Position

					Modules["StopAnimation"](Clone,4940561610)
					yes = true 
					--Services.Workspace.Camera.CameraSubject = Hum
					Modules["NoVelocity"](GrabbedChar)
					Modules["TweenPosition"](BodyPos,6, Clone.UpperTorso.Position + Vector3.new(0,20,0))

					task.wait(3.5)
					Modules["Void"](GrabbedChar)
					Modules["DestroyClone"](GrabbedChar,Clone)
					Clone = nil
					Cache["Loops"]["Portal"]:Disconnect()
					LoadAsset(true)
					Services.Workspace.Camera.CameraSubject = Services.LocalPlayer.Character.Humanoid

					for i = 1,40 do 
						Services.LocalPlayer.Character.HumanoidRootPart.CFrame = StoredPos
					end 
					Settings["Grab"]["Grab"] = true
				end)
				return 
			end
			Settings["Grab"]["Grab"] = true
			Modules["DestroyTool"]("Portal")
		end,
        ["Whirlwind Kick"] = function()
            if Settings["Grab"]["Whirlwind Kick"] then
                Modules["CreateTool"]("Whirlwind Kick",function()
                    if Settings["Grab"]["GrabbedCharacter"] == nil then 
                        return 
                    end
                    Settings["Grab"]["Grab"] = false
					task.wait(.1)
                    Modules["AnimPlay"](Services.LocalPlayer.Character,2791328524,.15,.42)
                    Modules["Play"]("4752664208")
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Settings["Grab"]["GrabbedCharacter"].UpperTorso.CFrame * CFrame.new(0, 0, 3)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(game.Players.LocalPlayer.Character.HumanoidRootPart.Position, Settings["Grab"]["GrabbedCharacter"].HumanoidRootPart.Position)
                    task.wait(1)
                    Modules["ImpactFrame"]()
                    Modules["Void"](Settings["Grab"]["GrabbedCharacter"])
                    Settings["Grab"]["Grab"] = true    
                end)
                return
            end
            Modules["DestroyTool"]("Whirlwind Kick")
        end,
	}


	

	Modules["AddEnv"]("Legion",Tabs)

	-- Visuals Page 
	local ESPSection = Tabs.Visuals:Section({Side = "Left"})
	
	ESPSection:Toggle({Text = "ESP", Default = false, Callback = function(state)
		EspLibrary.teamSettings.enemy.enabled = state
		if state then
			EspLibrary.Load()		
			--> print("yes")	was for debugging 
		else
			EspLibrary.Unload()
		end
	end})
	ESPSection:Toggle({Text = "ESP Boxes", Default = false, Callback = function(state)
		EspLibrary.teamSettings.enemy.box = state
	end})
	ESPSection:Toggle({Text = "ESP Tracers", Default = false, Callback = function(state)
		EspLibrary.teamSettings.enemy.tracer = state
	end})
	ESPSection:Toggle({Text = "ESP Healthbar", Default = false, Callback = function(state)
		EspLibrary.teamSettings.enemy.healthBar = state
	end})
	ESPSection:Toggle({Text = "ESP Name", Default = false, Callback = function(state)
		EspLibrary.teamSettings.enemy.name = state
	end})
	ESPSection:Toggle({Text = "ESP Distance", Default = false, Callback = function(state)
		EspLibrary.teamSettings.enemy.distance = state
	end})
	ESPSection:Toggle({Text = "ESP Chams", Default = false, Callback = function(state)
		EspLibrary.teamSettings.enemy.chams = state
	end})
	--[[
	brocken rn
	Tabs.Visuals:AddToggle("Esp",{Title = "Esp",Description="Enables Esp",Default = false,Callback = function(state)
	    EspLibrary:Toggle(state) 
	end})
	Tabs.Visuals:AddToggle("Tracers",{Title = "Tracers",Description="Enables Tracers",Default = false,Callback = function(state)
	    EspLibrary.Tracers = state
	end})
	Tabs.Visuals:AddToggle("Names",{Title = "Names",Description="Enables Names",Default = false,Callback = function(state)
	    EspLibrary.Names = state
	end})
	Tabs.Visuals:AddColorpicker("Colorpicker", {
	    Title = "Esp Color",
	    Description = "Change the color of the esp",
	    Default = Color3.fromRGB(96, 205, 255),
	    Callback = function (value)
	        EspLibrary.Color = value 
	    end
	})]]
	-- Voicelines Page
	-- Voicelines Section
	local voiceLinesSections = {
		Tabs.VoiceLines:Section({Side = "Left"}),
		Tabs.VoiceLines:Section({Side = "Right"})
	}

	voiceLinesSections[1]:Toggle({Text = "Toggle Chatted", Default = true, Callback = function(state)
		Settings["Player"]["Chat"] = state 
	end})

	for index,voiceline in pairs(Sounds["VoiceLines"]) do 
		voiceLinesSections[math.random(#voiceLinesSections)]:Button({Text=index,Callback = function()
			Modules["Play"](Sounds["VoiceLines"][index])
			if Settings["Player"]["Chat"] then 
				Modules["Chat"](index)
			end 
			
		end})
	end 


	-- Teleports Section
	local teleportsSection = Tabs.Teleports:Section({Side = "Left"})

	-- Dropdown for Saved Teleports
	local TeleportList = teleportsSection:Dropdown({Text = "Saved Teleports...", Options = Modules["GetTps"]() or {"Nil"}, Callback = function(item)
		if not Start then 
			Services.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = Modules["StringToCFrame"](readfile(item))
		end 
	end})

	-- Custom Teleport Input
	teleportsSection:Input({Text="Save tp", PlaceHolder = "Enter your Name for your custom TP", Callback = function(name)
		if isfolder("Legion/TP") then
			writefile("Legion/TP/"..name..".txt", Modules["CFrameToString"](Services.LocalPlayer.Character.HumanoidRootPart.CFrame))
			TeleportList:Refresh(Modules["GetTps"]())
			return 
		end 
		makefolder("Legion/TP")
		writefile("Legion/TP/"..name..".txt", Modules["CFrameToString"](Services.LocalPlayer.Character.HumanoidRootPart.CFrame))
		TeleportList:Refresh(Modules["GetTps"]())
	end})

	-- Dropdown for Bank Teleport
	teleportsSection:Dropdown({Text = "Bank", Options = {"Food from bank", "Bank"}, Callback = function(option)
		if option == "Food from bank" then
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-336.5518493652344, 23.645301818847656, -294.3374328613281)
		elseif option == "Bank" then
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-414.3941345214844, 21.712656021118164, -283.980224609375)
		end
	end})

	-- Dropdown for Downhill Teleport
	teleportsSection:Dropdown({Text = "Downhill",Options = {"Armor Downhill", "Gunz Downhill"}, Callback = function(option)
		if option == "Armor Downhill" then
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-591.8069458007812, 10.312345504760742, -791.7643432617188)
		elseif option == "Gunz Downhill" then
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-580.78466796875, 8.277433395385742, -735.6378784179688)
		end
	end})

	-- Dropdown for Uphill Teleport
	teleportsSection:Dropdown({Text = "Uphill", Options = {"Armor Uphill", "Food Uphill", "Gunz Uphill", "Uphill Park"}, Callback = function(option)
		if option == "Armor Uphill" then
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(549.1211547851562, 50.519630432128906, -627.4512939453125)
		elseif option == "Food Uphill" then
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(299.30242919921875, 47.967655181884766, -596.6179809570312)
		elseif option == "Gunz Uphill" then
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(482.1736145019531, 47.96764373779297, -608.7100830078125)
		elseif option == "Uphill Park" then
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(402.515625, 48.46266174316406, -399.5998229980469)
		end
	end})

	-- Target Section
	local targetSection = Tabs.Target:Section({Side = "Left"})

	-- Target Player Input
	targetSection:Input({Text="Target", PlaceHolder = "Enter the target's name", Callback = function(name)
		local targetPlayer = Modules["GetPlayer"](name)
		if targetPlayer then
			Settings["Target"]["Player"] = targetPlayer
			Notification:Notify(
				{Title = "Set Target", Description = string.format("Set target to: %s",targetPlayer)},
				{OutlineColor = Color3.fromRGB(30,30,30),Time = 10, Type = "image"},
				{Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
			) 
		end
	end})

	-- Dropdown for Target Mode
	targetSection:Dropdown({Text = "Target mode...", Options = {"Default", "Under", "Above"}, Callback = function(item)
		if item then 
			Settings["Target"]["Mode"] = item
			
		end 
	end})

	-- Knock Player Toggle
	targetSection:Toggle({Text = "Knock Player...", Default = false, Callback = function(state)
		if Settings["Target"]["Player"] then 
			Settings["Target"]["Kill"] = state 
			Modules["Kill"]()
		end 
	end})

	-- Bring Player Toggle
	targetSection:Toggle({Text = "Bring Player...", Default = false, Callback = function(state)
		if Settings["Target"]["Player"] then 
			Settings["Target"]["Kill"] = state 
			Modules["Bring"]()
		end 
	end})

	-- Stomp Player Toggle
	targetSection:Toggle({Text = "Stomp Player...", Default = false, Callback = function(state)
		if Settings["Target"]["Player"] then 
			Settings["Target"]["Kill"] = state 
			Modules["Stomp"]()
		end 
	end})

	-- View Player Toggle
	targetSection:Toggle({Text = "View Player...", Default = false, Callback = function(state)
		if state then 
			Modules["View"](Settings["Target"]["Player"])
			return
		end 
		Modules["View"](Services.LocalPlayer.Name)
	end})

	-- Grenade TP Toggle
	--[[
	targetSection:Toggle({Name = "Grenade TP...", Flag = "grenade_tp", Default = false, Callback = function(state)
		if Settings["Target"]["Player"] then 
			Settings["Target"]["Grenade"] = state
			Modules["GrenadeTp"]()
		end 
	end})
	]]

	-- Teleport to Player Button
	targetSection:Button({Text = "Teleport to Player", Callback = function()
		if Settings["Target"]["Player"] then 
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Services.Workspace.Players:FindFirstChild(Settings["Target"]["Player"]).HumanoidRootPart.CFrame 
		end
	end})
	targetSection:Button({Text = "Disable kill", Callback = function()
		Settings["Target"]["Kill"] = false 

		if Cache["Loops"]["Kill_Player"] ~= nil then 
			Cache["Loops"]["Kill_Player"]:Disconnect()
			Cache["Loops"]["Kill_Player"] = nil 
		end 

		if Cache["Loops"]["TP"] ~= nil then 
			Cache["Loops"]["TP"]:Disconnect()
			Cache["Loops"]["TP"] = nil 
		end 

		if Old ~= nil then 
			Services.LocalPlayer.Character.HumanoidRootPart.CFrame = Old 
		end 
	end})
	-- Player Section
	local playerSection = Tabs.Player:Section({Side="Left"})


	



	playerSection:Input({Text="Chat Bypass", PlaceHolder = "bypass chat filter", Callback = function(text)
		Modules["Chat"](Modules["TurnTextToFont"](text))
	end})

	-- CFrame Speed Toggle
	

	-- Auto Box Toggle
	playerSection:Toggle({Text = "Auto Box", Default = false, Callback = function(state)
		Settings["Player"]["AutoBox"] = state
	end})

	-- Anti Stomp Toggle
	playerSection:Toggle({Text = "Anti Stomp", Default = false, Callback = function(state)
		Settings["Player"]["AntiStomp"] = state 
	end}) 
	
	playerSection:Toggle({Text = "Anti fling",Default=false,Callback=function(state)
		repeat task.wait()
			if state then 	
				for index,player in pairs(Services.Workspace.Players:GetChildren()) do 
					Modules["CanCollide"](player,false)
				end 
				return  
			end 
		until state == false 
		for index,player in pairs(Services.Workspace.Players:GetChildren()) do 
			Modules["CanCollide"](player,true)
		end 
	end})

	playerSection:Toggle({Text = "Anti Grab",Default=false,Callback=function(state)
		Settings["Player"]["AntiGrab"] = state 
		Modules["AntiGrab"]()
	end})
	playerSection:Toggle({Text = "Anti Slow",Default=false,Callback=function(state)
		Settings["Player"]["Anti Slow"] = state 
		Modules["Anti Slow"]()
	end})

	local Key  = ""
	
	playerSection:KeyBind({Text="Car Fly",Default=Enum.KeyCode.N,Callback=function(key)
		actualKey = tostring((string.split(tostring(key),"KeyCode")[2]):split(".")[2])
		if Key ~= actualKey then 
			Key = key
			
			local mouse = Services.LocalPlayer:GetMouse()
			Key = tostring((string.split(tostring(Key),"KeyCode")[2]):split(".")[2])
			local flying = false
			local deb = true 
			local ctrl = {f = 0, b = 0, l = 0, r = 0} 
			local lastctrl = {f = 0, b = 0, l = 0, r = 0} 
			local maxspeed = 5
			local speed = 2

			function Fly() 
				local Car =  workspace.Vehicles:FindFirstChild(Services.LocalPlayer.Name)
				local Humanoid = Instance.new("Humanoid",Car)

				if not Car then 
					return 
				end 

				if Car:FindFirstChild("BodyVelocity") then 
					Car.BodyVelocity:Destroy()
				end 

				if Car:FindFirstChild("BodyGyro") then 
					Car.BodyGyro:Destroy()
				end 

				local BodyGyro = Instance.new("BodyGyro", Car) 
				local BodyVelocity = Instance.new("BodyVelocity", Car) 


				BodyGyro.P = 9e4 
				BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9) 
				BodyGyro.cframe = Car.CFrame 

				BodyVelocity.velocity = Vector3.new(0,0.1,0) 
				BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9) 

				repeat task.wait() 
					Humanoid.PlatformStand = true 
					if ctrl.l + ctrl.r ~= 100000 or ctrl.f + ctrl.b ~= 10000 then 
						speed = speed + 0.0 + 100000 
						if speed > maxspeed then 
							speed = maxspeed 
						end 
					elseif not (ctrl.l + ctrl.r ~= 5 or ctrl.f + ctrl.b ~= 5) and speed ~= 5 then 
						speed = speed - 5
						if speed > 5 then 
							speed = -2 
						end 
					end 
					if (ctrl.l + ctrl.r) ~= 5 or (ctrl.f + ctrl.b) ~= 5 then 
						BodyVelocity.velocity = ((Workspace.CurrentCamera.CFrame.lookVector * (ctrl.f + ctrl.b)) + ((Workspace.CurrentCamera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * .2, 0).p) - Workspace.CurrentCamera.CFrame.p)) * speed 
						lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r} 
					elseif (ctrl.l + ctrl.r) == 5 and (ctrl.f + ctrl.b) == 5 and speed ~= 5 then 
						BodyVelocity.velocity = ((Workspace.CurrentCamera.CFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((Workspace.CurrentCamera.CFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * .2, 0).p) - Workspace.CurrentCamera.CFrame.p)) * speed 
					else 
						BodyVelocity.velocity = Vector3.new(0, 0.1, 0) 
					end 
					BodyGyro.cframe = Workspace.CurrentCamera.CFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed/maxspeed), 0, 0) 
				until not flying 
				ctrl = {f = 0, b = 0, l = 0, r = 0} 
				lastctrl = {f = 0, b = 0, l = 0, r = 0} 
				speed = 5 
				BodyGyro:Destroy() 
				BodyVelocity:Destroy() 
				Humanoid.PlatformStand = false 
			end 

			mouse.KeyDown:Connect(function(key) 
				if key:lower() == Key:lower() then 
					if flying then 
						flying = false 
					else 
						flying = true 
						Fly() 
					end 
				elseif key:lower() == "w" then 
					ctrl.f = 45
				elseif key:lower() == "s" then 
					ctrl.b = -45 
				elseif key:lower() == "a" then 
					ctrl.l = -45 
				elseif key:lower() == "d" then 
					ctrl.r = 45
				end 
			end) 

			mouse.KeyUp:Connect(function(key) 
				if key:lower() == "w" then 
					ctrl.f = 0
				elseif key:lower() == "s" then 
					ctrl.b = 0
				elseif key:lower() == "a" then 
					ctrl.l = 0
				elseif key:lower() == "d" then 
					ctrl.r = 0
				end 
			end)

			Fly()
			
		end 
	end})

	--[[
	playerSection:Toggle({Name = "Auto Dodge",Flag="auto_dodge",Default=false,Callback=function(state)
		Settings["Player"]["AutoDodge"] = state 
		Modules["AutoDodge"]()
	end})
	]]
	

	
	-- Speed Slider
	local CFrame = Tabs.Player:Section({Side = "Right"})
	CFrame:Toggle({Text = "CFrame Speed",Default = false, Callback = function(state)
		Settings["Player"]["CFrameSpeed"] = state
	end})
	CFrame:Slider({Text = "Speed", Flag = "speed_slider", Min = 1, Max = 10, Callback = function(value)
		if not Start then 
			Settings["Player"]["Speed"] = value
		end 
	end})
	
	CFrame:KeyBind({Text = "Keybind", Default = Enum.KeyCode.X, Callback = function(key)
		if not Start then 
			Settings["Player"]["CFrameSpeed"] = not Settings["Player"]["CFrameSpeed"]
		end
	end});
	local AlreadyCalled = false
	local CurrentKey = nil
	local Invis = Tabs.Player:Section({Side = "Right"})
	Invis:Toggle({Text = "Invis Desync",Default = false, Callback = function(state)
		Settings["Player"]["Invis Desync"] = state

		if not Settings["Player"]["Invis Desync"] then 
			if Cache["Connections"]["Invis Desync"] ~= nil then 
				Cache["Connections"]["Invis Desync"]:Disconnect()
				Cache["Connections"]["Invis Desync"] = nil 
			end 
			if Cache["Loops"]["Invis Desync"] ~= nil  then
				Cache["Loops"]["Invis Desync"]:Disconnect()
				Cache["Loops"]["Invis Desync"] = nil
			end
		end 

		if not State then 
			AlreadyCalled = false 
		end 
	end})
	Invis:KeyBind({
		Text = "Invis Keybind", 
		Default = Enum.KeyCode.V, 
		Callback = function(key)			
			if Settings["Player"]["Invis Desync"] and not AlreadyCalled or not key == CurrentKey then 
				Modules["InvisDesync"](key)
				AlreadyCalled = true 
				CurrentKey = key
			end
		end
	})

	local Disguise = Tabs.Player:Section({Side = "Right"})
	Disguise:Input({Text="Disguise", PlaceHolder = "Enter the target's userid", Callback = function(name)
		if Cache["Connections"]["Loop"] then 
			Cache["Connections"]["Loop"]:Disconnect()
			Cache["Connections"]["Loop"] = nil 
		end 

		if Cache["Connections"]["Clone"] then 
			Cache["Connections"]["Clone"]:Destroy()
			Cache["Connections"]["Clone"] = nil 
		end 

		Cache["Connections"]["Loop"],Cache["Connections"]["Clone"] = Modules["Disguise"](Services.LocalPlayer.Character,name)	
		
	end})

	Disguise:Button({Text="Destroy Disguise",Callback = function()
		if Cache["Connections"]["Loop"] then 
			Cache["Connections"]["Loop"]:Disconnect()
			Cache["Connections"]["Loop"] = nil 
		end 

		if Cache["Connections"]["Clone"] then 
			Cache["Connections"]["Clone"]:Destroy()
			Cache["Connections"]["Clone"] = nil 
		end 

			for index, part in pairs(Services.LocalPlayer.Character:GetChildren()) do 
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
	        		part.CanCollide = false 
	        		part.Transparency = 0 
	        	end 
        	end 
        	for index,part in pairs(Services.LocalPlayer.Character:GetDescendants()) do 
	        	if part:IsA("Decal") then 
        			part.Transparency = 0 
        		end 
	        end 

	        Services.Workspace.Camera.CameraSubject = Services.LocalPlayer.Character.Humanoid
	     
	end})

	-- Grabs Section
	local GrabSections = {
		Tabs.Grabs:Section({Side = "Left"}),
	}
	local old_fov = workspace.CurrentCamera.FieldOfView
	local old_fog = game.Lighting.FogEnd
	local old_fog_color = game.Lighting.FogColor

	-- Grabs Page
	GrabSections[1]:Toggle({Text = "Grab",Default = false,Callback = function (state)
		Settings["Grab"]["Grab"] = state 
		if not Settings["Grab"]["Grab"] then 
			if Settings["Grab"]["GrabbedCharacter"] ~= nil then
				Services.ReplicatedStorage.MainEvent:FireServer("Grabbing", false)
				Modules["StopAnimation"](Services.LocalPlayer.Character,"3135389157")
			end

			if Cache["Loops"]["Grab"] ~= nil then 
				Settings["Grab"]["GrabbedCharacter"] = nil 
				

				Cache["Loops"]["Grab"]:Disconnect()
				Cache["Loops"]["Grab"] = nil 
			end 

			if Cache["Connections"]["Grab"] ~= nil then 
				Cache["Connections"]["Grab"]:Disconnect()
				Cache["Connections"]["Grab"] = nil 
			end 
			return 
		end 

		Cache["Connections"]["Grab"] = Services.LocalPlayer.Character.BodyEffects.Grabbed:GetPropertyChangedSignal("Value"):Connect(function()
			if Cache["Loops"]["Grab"] ~= nil then 
				for index,part in pairs(Settings["Grab"]["GrabbedCharacter"]:GetDescendants()) do 
					if part:IsA("BodyVelocity") or part:IsA("BodyGyro") or part:IsA("BodyPosition") then 
						part:Destroy()
					end
				end 
				Settings["Grab"]["GrabbedCharacter"] = nil 

				Cache["Loops"]["Grab"]:Disconnect()
				Cache["Loops"]["Grab"] = nil 
			end
			if Services.LocalPlayer.Character.BodyEffects.Grabbed.Value ~= nil then 
				Modules["Grab"](Services.LocalPlayer.Character.BodyEffects.Grabbed.Value,Animations["Grab"])
				Modules["CanCollide"](Services.LocalPlayer.Character.BodyEffects.Grabbed.Value,false)
				Modules["NoVelocity"](Services.LocalPlayer.Character.BodyEffects.Grabbed.Value)
				return 
			end    
			Services.TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1), {FieldOfView = old_fov}):Play()
				Services.TweenService:Create(game.Lighting, TweenInfo.new(1), {FogEnd = old_fog}):Play()
				Services.TweenService:Create(game.Lighting, TweenInfo.new(1), {FogColor =old_fog_color}):Play()
					
                Services.TweenService:Create(Services.LocalPlayer.Character.Humanoid, TweenInfo.new(1), {HipHeight = 2}):Play()
				if Services.Lighting.ColorCorrection then 
					Services.TweenService:Create(Services.Lighting.ColorCorrection, TweenInfo.new(1), {Contrast = 0}):Play()
				end
				Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {ColorShift_Bottom = Color3.fromRGB(0,0,0)}):Play()
				Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {ColorShift_Top = Color3.fromRGB(0,0,0)}):Play()
				Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {Brightness = 1}):Play()
				Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {Ambient = Color3.fromRGB(0,0,0)}):Play()

			Modules["StopAnimation"](Services.LocalPlayer.Character,"3135389157")
		end)
	end})
	GrabSections[1]:Toggle({Text = "Effects",Default = true,Callback = function (state)
		Settings["Grab"]["Effects"] = state 
	end})

	--> I do NOT wanna manually add the fucking tools lmao 
	for name,func in pairs(Tools) do 
		if name == "Mind Control" then 
			
			local Section = Tabs.Grabs:Section({Side = "Right"})
			Section:Toggle({Text=tostring(name),Default=false,Callback=function(state)
				Settings["Grab"][name] = state 
				Tools[name]()
			end})
			Section:Slider({Text = "Mind Thickness", Min = 0,Max = 10,Callback = function(v)
				if not Start then 
					Settings["Grab"]["Mind Control Thickness"] = v
				end 
			end});
			Section:Slider({Text = "Mind Frequency", Min = 0,Max = 15,Callback = function(v)
				if not Start then 
					Settings["Grab"]["Mind Control Frequency"] = v
				end 
			end});
		else
			GrabSections[1]:Toggle({Text=tostring(name),Default=false,Callback=function(state)
				Settings["Grab"][name] = state 
				Tools[name]()
			end})
		end
	end

	local CreditsSection = Tabs.Credits:Section({Side = "Left"})
	-- Credits 
	CreditsSection:Button({Text="Percent [6prozent on dc]",Callback = function() print("hi") end })
	CreditsSection:Button({Text="Iux [youtube.com on dc]",Callback = function() print("hi") end })
	CreditsSection:Button({Text="Solo [literallysolodev on dc]",Callback = function() print("hi") end })
	CreditsSection:KeyBind({Text = "UI Toggle", Default = Enum.KeyCode.Insert, Callback = function(key)
		if Main then
			Main.Visible = not Main.Visible
		end 
	end});

	-- final shit and stuff

	Modules["CFrame Speed"]()
	Modules["AntiStomp"]()
	Modules["AutoBox"]()

	Start = false 



	--> this will give you eye cancer reading cause I wrote this at 3 am :sob_praying:
	Services.LocalPlayer.CharacterAdded:Connect(function (char)
		repeat task.wait() until char:FindFirstChild("BodyEffects")
		if Cache["Connections"]["Grab"] ~= nil then 
			Cache["Connections"]["Grab"]:Disconnect()
			Cache["Connections"]["Grab"] = nil 
		end 
		if Cache["Connections"]["AutoRespawnConnection"] ~= nil then 
			Cache["Connections"]["AutoRespawnConnection"]:Disconnect()
			Cache["Connections"]["AutoRespawnConnection"] = nil 
		end 
		if Cache["Loops"]["Box"] ~= nil then 
			Cache["Loops"]["Box"]:Disconnect()
			Cache["Loops"]["Box"] = nil 
		end 

		if Settings["Grab"]["Grab"] then 
			Cache["Connections"]["Grab"] = Services.LocalPlayer.Character.BodyEffects.Grabbed:GetPropertyChangedSignal("Value"):Connect(function()
			if Cache["Loops"]["Grab"] ~= nil then 
				for index,part in pairs(Settings["Grab"]["GrabbedCharacter"]:GetDescendants()) do 
					if part:IsA("BodyVelocity") or part:IsA("BodyGyro") or part:IsA("BodyPosition") then 
						part:Destroy()
					end
				end 
				Settings["Grab"]["GrabbedCharacter"] = nil 

				Cache["Loops"]["Grab"]:Disconnect()
				Cache["Loops"]["Grab"] = nil 
			end
			if Services.LocalPlayer.Character.BodyEffects.Grabbed.Value ~= nil then 
				Modules["Grab"](Services.LocalPlayer.Character.BodyEffects.Grabbed.Value,Animations["Grab"])
				Modules["CanCollide"](Services.LocalPlayer.Character.BodyEffects.Grabbed.Value,false)
				Modules["NoVelocity"](Services.LocalPlayer.Character.BodyEffects.Grabbed.Value)
				return 
			end    
			Services.TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1), {FieldOfView = old_fov}):Play()
			Services.TweenService:Create(game.Lighting, TweenInfo.new(1), {FogEnd = old_fog}):Play()
			Services.TweenService:Create(game.Lighting, TweenInfo.new(1), {FogColor =old_fog_color}):Play()
					
            Services.TweenService:Create(Services.LocalPlayer.Character.Humanoid, TweenInfo.new(1), {HipHeight = 2}):Play()
			Services.TweenService:Create(Services.Lighting.ColorCorrection, TweenInfo.new(1), {Contrast = 0}):Play()

			Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {ColorShift_Bottom = Color3.fromRGB(0,0,0)}):Play()
			Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {ColorShift_Top = Color3.fromRGB(0,0,0)}):Play()
			Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {Brightness = 1}):Play()
			Services.TweenService:Create(game.Lighting, TweenInfo.new(.7), {Ambient = Color3.fromRGB(0,0,0)}):Play()
				
			Modules["StopAnimation"](Services.LocalPlayer.Character,"3135389157")
			
		end)
		end 
		Modules["AntiStomp"]()
		Modules["AutoBox"]()
		Modules["AntiGrab"]()
		Modules["Anti Slow"]()

		for name,func in pairs(Tools) do 
			func()
		end
	end)

	-- stop throwing animation for rip tools 
	Services.RunService.Heartbeat:Connect(function()
		Modules["StopAnimation"](Services.LocalPlayer.Character,"4798175381")
	end)

end)

pcall(function()
	MainBuffer:flush()
	MainBuffer:delete()
	--> gcinfo("collect")
end)
