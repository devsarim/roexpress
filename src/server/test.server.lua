local Players = game:GetService("Players")
local roexpress = require(game.ReplicatedStorage.shared.roexpress)

roexpress.on("ping") --[[
  Don't have to pass in a callback if you just want to create an event that can be fired
  by clients but this is kinda useless
]]--

roexpress.on("ping", function(player)
  print("server pong!")
end)

roexpress.get("serverMessage", function(player)
  return "This is a message from the server to " .. player.Name
end)

Players.PlayerAdded:Connect(function(player)
  roexpress("ping", player --[[,...]]) --> To fire to a specific client
  -- roexpress("ping" --[[, ...]]) --> To fire to all clients
end)