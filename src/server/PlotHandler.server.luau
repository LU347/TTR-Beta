local Plots = game.Workspace.Plots

local TemplatePlot = game.Workspace.TemplatePlot

game.Players.PlayerAdded:Connect(function(player)
    for _, plot in Plots:GetChildren() do
        if plot:GetAttribute("Taken") then continue end
        plot:SetAttribute("Taken", true)
        plot:SetAttribute("Owner", player.UserId)

        local itemsFolder = Instance.new("Folder")
        itemsFolder.Name = "Items"
        itemsFolder.Parent = plot

        local TemplateButtons = TemplatePlot.Buttons:Clone()
        local TemplateItems = TemplatePlot.Items

        for _, Button in TemplateButtons:GetChildren() do
            --model:GetPivot() part.CFrame
            local RelativeCFrame = TemplatePlot.CFrame:ToObjectSpace(Button.CFrame)
            Button.CFrame = plot.CFrame:ToWorldSpace(RelativeCFrame)
            
            Button.Touched:Connect(function(hit)
                local player = game.Players:GetPlayerFromCharacter(hit.Parent)
                if not player then return end
                if plot:GetAttribute("Owner") ~= player.UserId then return end

                local itemToUnlockId = Button:GetAttribute("IdOfItemToUnlock")
                if not itemToUnlockId then warn("No IdOfItemToUnlock Attr") return end

                for _, item in TemplateItems:GetChildren() do
                    if item:GetAttribute("Id") ~= itemToUnlockId then continue end

                    local itemClone = item:Clone()
                    local itemCFrame 

                    if itemClone:IsA("Model") then
                        itemCFrame = itemClone:GetPivot()
                    elseif itemClone:IsA("BasePart") then
                        itemCFrame = itemClone.CFrame
                    else
                        itemCFrame = itemClone.CFrame
                    end
                    
                    local relativeItemCFrame = TemplatePlot.CFrame:ToObjectSpace(itemCFrame)
                    local worldCFrameOfNewPlot = plot.CFrame:ToWorldSpace(relativeItemCFrame)
                    
                    if itemClone:IsA("Model") then
                        itemClone:PivotTo(worldCFrameOfNewPlot)
                    elseif itemClone:IsA("BasePart") then
                        itemClone.CFrame = worldCFrameOfNewPlot
                    else
                        itemClone.CFrame = worldCFrameOfNewPlot
                    end

                    itemClone.Parent = itemsFolder
                    break
                end
            end)

            Button.Parent = TemplateButtons
        end

        TemplateButtons.Parent = plot
        break
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    for _, plot in Plots:GetChildren() do
        if not plot:GetAttribute("Owner") then continue end
        if plot:GetAttribute("Owner") ~= player.UserId then continue end
        
        plot:SetAttribute("Taken", false)
        plot:SetAttribute("Owner", nil)
        break
    end
end)