local Raritytimes = {
    ["Common"] = 15,
    ["Uncommon"] = 10,
    ["Rare"] = 2,
	["Epic"] = 1,
	["Legendary"] = 0.1,
	["God"] = 0.025,
	["Unknown"] = 0.00000001
}
player = script.Parent.Parent.Parent
common = Color3.fromRGB(200,200,200)
uncommon = Color3.fromRGB(85, 170, 255)
rare = Color3.fromRGB(226, 155, 64)
epic = Color3.fromRGB(255,255,0)
legendary = Color3.fromRGB(255,0,0)
god = Color3.fromRGB(0,255,0)
 
local CrateInude = false
local CaseRewards = game.ReplicatedStorage.Items.CaseRewards
local function opencrate(Chance)
    if CrateInude == false then
        CrateInude = true
        local items = {}
        local frametimes = math.random(30,32)
        local rewardbutton
        for i,v in pairs(CaseRewards:GetChildren()) do
            local rarnumber = Raritytimes[v.Rarity.Value] or 1
            local mathmatical = math.max(rarnumber+Chance)
            for i = 1,mathmatical do
                table.insert(items,v)
            end
        end
       
        math.randomseed(tick())    
       
        for i = 1,frametimes+5 do
            local item = items[math.random(#items)]
            local newsapme = script.Parent.Unboxing.SampleItem:Clone()
            newsapme.Visible =true
newsapme.Parent = script.Parent.Unboxing.inner
            newsapme.Icon.Image = item.Image.Value
            newsapme.ItemName.Text = item.Name
			if CaseRewards:FindFirstChild(newsapme.ItemName.Text).Rarity.Value == "Common" then
				newsapme.Rarity.BackgroundColor3 = common
			elseif CaseRewards:FindFirstChild(newsapme.ItemName.Text).Rarity.Value == "Uncommon" then
				newsapme.Rarity.BackgroundColor3 = uncommon
				elseif CaseRewards:FindFirstChild(newsapme.ItemName.Text).Rarity.Value == "Rare" then
				newsapme.Rarity.BackgroundColor3 = rare
			elseif CaseRewards:FindFirstChild(newsapme.ItemName.Text).Rarity.Value == "Epic" then
				newsapme.Rarity.BackgroundColor3 = epic
			elseif CaseRewards:FindFirstChild(newsapme.ItemName.Text).Rarity.Value == "Legendary" then
				newsapme.Rarity.BackgroundColor3 = legendary
			elseif CaseRewards:FindFirstChild(newsapme.ItemName.Text).Rarity.Value == "God" then
				newsapme.Rarity.BackgroundColor3 = god
			end
			
            newsapme.Position = UDim2.new(0,100*(i-1),0,0)
            if i == frametimes then
                rewardbutton = newsapme
            end
        end

        for num = 1,(rewardbutton.Position.X.Offset - (255+math.random(-40,40)))/15 do
            for i,v in pairs(script.Parent.Unboxing.inner:GetChildren()) do
      if v.Position.X.Offset <= 245 and v.Position.X.Offset >= 165 then
        script.Parent.Item.Value = v.ItemName.Text
    end
                v.Position = UDim2.new(0,v.Position.X.Offset-15,0,0)
                if v.Position.X.Offset <= -150 then
                    v:Destroy()
                end
            end
            wait(0.01 * 1.05 ^ (num-105)/2)
            script.Tick:Play()
        end
    end
			end

opencrate(1)
script.Parent.OOF:Play()
game.ReplicatedStorage.GameRemotes.OpenCaseEvent:FireServer(player,script.Parent,script.Parent.Item.Value,game.ReplicatedStorage.Items.CaseRewards[script.Parent.Item.Value].Type.Value,script.Parent.Name)
