local roexpress = require(game.ReplicatedStorage.shared.roexpress)

--> Request data from the server
roexpress.get("serverMessage"):andThen(function(data)
  print(data)
end)

--> When an event is fired by the server
roexpress.on("ping", function(player)
  print("client pong")
end)

--> Fire an event to the server
roexpress("ping")