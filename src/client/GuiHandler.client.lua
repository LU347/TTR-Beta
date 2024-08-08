--Temporary Gui
local player = game.Players.LocalPlayer

local function updateGui()
    local gui = game.Players.LocalPlayer.PlayerGui:WaitForChild("PlayerCash")
    local textLabel = gui.Frame.CashLabel
    textLabel.Text = player:GetAttribute("Cash")
end

game.Players.LocalPlayer:GetAttributeChangedSignal("Cash"):Connect(updateGui)