--Temporary Gui
local player = game.Players.LocalPlayer

local function updateGui()
    local gui = game.Players.LocalPlayer.PlayerGui:WaitForChild("PlayerUI")
    local textLabel = gui.Cash.TextLabel
    textLabel.Text = player:GetAttribute("Cash")
end

updateGui()

game.Players.LocalPlayer:GetAttributeChangedSignal("Cash"):Connect(updateGui)