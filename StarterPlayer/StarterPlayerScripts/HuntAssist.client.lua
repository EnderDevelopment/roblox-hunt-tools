local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local config = require(ReplicatedStorage:WaitForChild("HuntAssistConfig"))

local espEnabled = config.EspEnabledByDefault
local aimAssistEnabled = false
local aimInputHeld = false
local highlights = {}

local function getAnimalModels()
	local animals = {}
	local seen = {}

	for _, instance in ipairs(CollectionService:GetTagged(config.AnimalTag)) do
		local model = instance:IsA("Model") and instance or instance:FindFirstAncestorOfClass("Model")
		if model and model ~= player.Character and not seen[model] then
			seen[model] = true
			table.insert(animals, model)
		end
	end

	local folder = Workspace:FindFirstChild(config.AnimalFolderName)
	if folder then
		for _, instance in ipairs(folder:GetChildren()) do
			if instance:IsA("Model") and not seen[instance] then
				seen[instance] = true
				table.insert(animals, instance)
			end
		end
	end

	return animals
end

local function getModelPosition(model)
	local part = model:FindFirstChild("HumanoidRootPart")
		or model.PrimaryPart
		or model:FindFirstChildWhichIsA("BasePart", true)
	return part and part.Position or nil
end

local function refreshHighlights()
	local current = {}
	for _, model in ipairs(getAnimalModels()) do
		current[model] = true
		local highlight = highlights[model]
		if not highlight or not highlight.Parent then
			highlight = Instance.new("Highlight")
			highlight.Name = "HuntAssistAnimalHighlight"
			highlight.Adornee = model
			highlight.FillColor = config.EspColor
			highlight.OutlineColor = config.EspColor
			highlight.FillTransparency = 0.72
			highlight.OutlineTransparency = 0
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = model
			highlights[model] = highlight
		end

		local position = getModelPosition(model)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local inRange = position and root and (position - root.Position).Magnitude <= config.EspMaxDistance
		highlight.Enabled = espEnabled and inRange == true
	end

	for model, highlight in pairs(highlights) do
		if not current[model] or not model.Parent then
			highlight:Destroy()
			highlights[model] = nil
		end
	end
end

local function isVisible(targetModel, targetPosition)
	local character = player.Character
	local origin = camera.CFrame.Position
	local direction = targetPosition - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character, targetModel }
	params.IgnoreWater = true
	return Workspace:Raycast(origin, direction, params) == nil
end

local function getAimTarget()
	local center = camera.ViewportSize / 2
	local bestModel = nil
	local bestPosition = nil
	local bestScreenDistance = math.huge
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end

	for _, model in ipairs(getAnimalModels()) do
		local position = getModelPosition(model)
		if position and (position - root.Position).Magnitude <= config.AimAssistMaxDistance then
			local screenPoint, onScreen = camera:WorldToViewportPoint(position)
			if onScreen and screenPoint.Z > 0 then
				local screenDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude
				if screenDistance <= config.AimAssistFieldOfView and screenDistance < bestScreenDistance
					and isVisible(model, position) then
					bestModel = model
					bestPosition = position
					bestScreenDistance = screenDistance
				end
			end
		end
	end

	return bestModel, bestPosition
end

local function setEspAction(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		espEnabled = not espEnabled
		refreshHighlights()
	end
	return Enum.ContextActionResult.Sink
end

local function setAimToggleAction(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		aimAssistEnabled = not aimAssistEnabled
	end
	return Enum.ContextActionResult.Sink
end

local function setAimHoldAction(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		aimInputHeld = true
	elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
		aimInputHeld = false
	end
	return Enum.ContextActionResult.Pass
end

ContextActionService:BindAction("HuntAssistToggleESP", setEspAction, false, config.EspToggleKey)
ContextActionService:BindAction("HuntAssistToggleAim", setAimToggleAction, false, config.AimAssistToggleKey)
ContextActionService:BindAction("HuntAssistAimHold", setAimHoldAction, false, config.AimAssistHoldInput)

RunService.RenderStepped:Connect(function(deltaTime)
	refreshHighlights()
	if not aimAssistEnabled or not aimInputHeld or UserInputService:GetFocusedTextBox() then
		return
	end

	local _, targetPosition = getAimTarget()
	if not targetPosition then
		return
	end

	local desired = CFrame.lookAt(camera.CFrame.Position, targetPosition)
	local alpha = 1 - math.exp(-config.AimAssistResponsiveness * deltaTime)
	camera.CFrame = camera.CFrame:Lerp(desired, alpha)
end)

player.CharacterRemoving:Connect(function()
	aimInputHeld = false
end)

refreshHighlights()
