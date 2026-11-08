local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer

-- الـ IDs الستة بالترتيب الصحيح
local bombIds = {
    "rbxassetid://72634649711269",
    "rbxassetid://101785080415896",
    "rbxassetid://87195137432081",
    "rbxassetid://75764270519412",
    "rbxassetid://133744095064808",
    "rbxassetid://72795881681356"
}

local currentTexture = bombIds[1]
local selectedButton = nil

-- دالة قوية جداً لفرض الصورة على القنبلة أينما كانت
local function modifyBomb(obj)
	if not obj then return end
	local name = obj.Name:lower()
	
	if not (name:find("bomb") or name:find("prank")) then return end
	
	for _, part in ipairs(obj:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = currentTexture
		elseif part:IsA("BasePart") then
			for _, sub in ipairs(part:GetChildren()) do
				if sub:IsA("Decal") or sub:IsA("Texture") then
					sub.Texture = currentTexture
				elseif sub:IsA("SpecialMesh") then
					sub.TextureId = currentTexture
				end
			end
		end
	end
	if obj:IsA("MeshPart") then
		obj.TextureID = currentTexture
	end
end

-- مراقبة يد الحقيبة والشخصية بالأحداث
local function onCharacterAdded(char)
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			task.spawn(function()
				task.wait(0.05)
				modifyBomb(child)
			end)
		end
	end)
end

if localPlayer.Character then
	onCharacterAdded(localPlayer.Character)
end
localPlayer.CharacterAdded:Connect(onCharacterAdded)

if localPlayer:FindFirstChild("Backpack") then
	localPlayer.Backpack.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			task.spawn(function()
				task.wait(0.05)
				modifyBomb(child)
			end)
		end
	end)
end

-- ============================
-- نظام السحب (Drag) العام
-- ============================
local function makeDraggable(guiObject, dragHandle)
	dragHandle = dragHandle or guiObject
	local dragging = false
	local dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- واجهة المستخدم (UI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GoldBombGui"
screenGui.Parent = CoreGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 130, 0, 40)
toggleBtn.Position = UDim2.new(0, 20, 0, 120)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Text = "قائمة Gold Bomb 💣"
toggleBtn.Parent = screenGui
toggleBtn.Active = true

local c1 = Instance.new("UICorner")
c1.CornerRadius = UDim.new(0, 8)
c1.Parent = toggleBtn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 340)
mainFrame.Position = UDim2.new(0, 20, 0, 170)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
mainFrame.Active = true

local c2 = Instance.new("UICorner")
c2.CornerRadius = UDim.new(0, 10)
c2.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "اختر صورة قنبلة Gold Prank Bomb"
titleLabel.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Text = "X"
closeBtn.Parent = mainFrame

local c3 = Instance.new("UICorner")
c3.CornerRadius = UDim.new(0, 6)
c3.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

toggleBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- جعل زر الفتح قابل للسحب
makeDraggable(toggleBtn)

-- جعل الصندوق قابل للسحب من الهيدر (العنوان) عشان ما يتعارض مع الأزرار
makeDraggable(mainFrame, titleLabel)

-- إنشاء الأزرار للـ IDs الستة
for i, idAsset in ipairs(bombIds) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 35)
	btn.Position = UDim2.new(0.05, 0, 0, 45 + (i * 42))
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 12
	btn.Font = Enum.Font.SourceSansBold
	btn.Text = "صورة ID " .. i
	btn.Parent = mainFrame

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = btn

	btn.MouseButton1Click:Connect(function()
		currentTexture = idAsset

		if selectedButton then
			selectedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		end
		selectedButton = btn
		btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)

		if localPlayer.Character then
			for _, item in ipairs(localPlayer.Character:GetChildren()) do
				if item:IsA("Tool") then modifyBomb(item) end
			end
		end

		print("تم تغيير وتثبيت الصورة: " .. idAsset)
	end)
end

print("تم تفعيل السكريبت المحدث بنجاح!")
