# roexpress

A lightweight, easy-to-use networking module for Roblox, similar to express. 

## Installation
Wally
```
roexpress = sarimwastaken/roexpress@0.1.1
```

## Client
```lua
  roexpress.on(route: string, callback: (...) -> nil): nil
  roexpress.get(route: string, ...): Promise
  roexpress(route: string, ...): nil
  
  Example:
  
  roexpress.on("ping", function()
    print("pong!")
  end)
  
  roexpress.on("a/b/event", function()
    print("Received from the server")
  end)
  
  roexpress.get("catalog/getShirts"):andThen(function(response)
    print(response)
  end)
  
  roexpress("message", "Hello from client!")
```

## Server
```lua
  roexpress.get(route: string, callback: (player: Player) -> any): nil
  roexpress.on(route: string, callback: (player: Player) -> nil): nil
  roexpress(route: string, player: Player?, ...): nil 
  --// If a player is passed in as the second argument, the event is fired to that player, else, to all clients
  
  Example:
  
  roexpress.on("ping", function(player: Player)
    print("pong!")
  end)
  
  roexpress.on("a/b/event", function(player: Player)
    print("Received from", player.Name)
  end)
  
  roexpress.get("catalog/getShirts", function(player: Player)
    return {...}
  end)
  
  roexpress("message", "Hello to all clients from the server!")
  roexpress("message", game.Players["DevSarim"], "Hello from the server!")
```
