game.ReplicatedFirst:RemoveDefaultLoadingScreen()

local contentProvider = game:GetService("ContentProvider")
local player = game:GetService("Players").LocalPlayer
local loadingGui = script.Parent
local bar = loadingGui.Background.Bar.Fill
local loadingInfo = loadingGui.Background.Bar.LoadingInfo
local n = 0

loadingGui.Parent = player.PlayerGui

if game:IsLoaded() or not game.Loaded:Wait() then end

local assets = game.ReplicatedStorage:GetDescendants()
--local character = player.Character or player.CharacterAdded:Wait()

local function Update(Id, Status)
	n += 1
	
	local perc = n / #assets
	loadingInfo.Text = string.format("Loading Asset : %s  %s%%", Id, math.round(perc * 1e3) / 10)
	bar.Size = UDim2.fromScale(perc, 1)
end

for _, asset in ipairs(assets) do
	contentProvider:PreloadAsync({asset}, Update)
end

loadingInfo.Text = "Preparing terrain"

game.ReplicatedStorage.Remotes.Functions:InvokeServer("RequestStream", workspace.CameraCFrame:WaitForChild("Main").Position)

loadingGui.Background.Visible = false

require(game.ReplicatedStorage:WaitForChild("Modules").Util.InbetweenService){
	Object = loadingGui.Finish,
	Length = 1.5,
	Callback = loadingGui.Destroy,
	Args = {loadingGui},
	
	Goal = {
		Transparency = 1
	}
}
