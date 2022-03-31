--!strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(script.Parent.t)
local Promise = require(script.Parent.Promise)

if (RunService:IsServer()) then
  local roexpressDir = Instance.new("Folder")
  roexpressDir.Name = "_roexpressNetworking"
  roexpressDir.Parent = ReplicatedStorage

  local roexpress = {}
  
  local function GetRoute(route: string): RemoteEvent | RemoteFunction | nil
    local routePath = route:split("/")
  
    if (#routePath == 1) then
      return roexpressDir:FindFirstChild(route)
    elseif (#routePath > 1) then
      local currentParent = roexpressDir
      local foundRoute
  
      for index, path in ipairs(routePath) do
        currentParent = currentParent:FindFirstChild(path)
        if (currentParent:IsA("RemoteEvent") or currentParent:IsA("RemoteFunction")) then
          foundRoute = currentParent
        end
      end
  
      return foundRoute
    end
  end

  local function CreateRoute(route: string, type: string): RemoteFunction | RemoteEvent
    local routePath = route:split("/")

    if (#routePath == 1) then
      local func = Instance.new(type)
      func.Name = route
      func.Parent = roexpressDir
      
      return func
    elseif (#routePath > 1) then
      local currentParent = roexpressDir

      for i = 1, #routePath - 1 do
        local subDir = currentParent:FindFirstChild(routePath[i]) or Instance.new("Folder")
        subDir.Name = routePath[i]
        subDir.Parent = currentParent
        currentParent = subDir
      end

      local func = Instance.new(type)
      func.Name = routePath[#routePath]
      func.Parent = currentParent

      return func
    end
  end
  
  function roexpress.get(route: string, callback: (player: Player) -> any)
    local func: RemoteFunction = GetRoute(route) or CreateRoute(route, "RemoteFunction")

    func.OnServerInvoke = callback
  end

  function roexpress.on(route: string, callback: (player: Player) -> nil?)
    local event: RemoteEvent = GetRoute(route) or CreateRoute(route, "RemoteEvent")
    
    if (not callback) then return end
    event.OnServerEvent:Connect(callback)
  end

  setmetatable(roexpress, {
    __call = function(self, route: string, player: Player?, ...)
      local event: RemoteEvent = GetRoute(route) or CreateRoute(route, "RemoteEvent")

      if (t.instanceIsA("Player")(player)) then
        event:FireClient(player, ...)
      else
        event:FireAllClients(player, ...)
      end
    end
  })

  return roexpress
elseif (RunService:IsClient()) then
  local roexpressDir: Folder = ReplicatedStorage:WaitForChild("_roexpressNetworking")

  local roexpress = {}

  local function GetRoute(route: string): RemoteEvent | RemoteFunction | nil
    local routePath = route:split("/")
  
    if (#routePath == 1) then
      return roexpressDir:WaitForChild(route)
    elseif (#routePath > 1) then
      local currentParent = roexpressDir
      local foundRoute
  
      for index, path in ipairs(routePath) do
        currentParent = currentParent:WaitForChild(path)
        if (currentParent:IsA("RemoteEvent") or currentParent:IsA("RemoteFunction")) then
          foundRoute = currentParent
        end
      end
  
      return foundRoute
    end
  end

  function roexpress.on(route: string, callback: (any) -> nil)
    local event: RemoteEvent = GetRoute(route)

    event.OnClientEvent:Connect(callback)
  end

  function roexpress.get(route: string, ...): Promise
    local func: RemoteFunction = GetRoute(route)
    local args = ...

    return Promise.new(function(resolve, reject)
      local success, dataOrError = pcall(func.InvokeServer, func, args)
      if (success) then
        resolve(dataOrError)
      else
        reject(dataOrError)
      end
    end)
  end

  setmetatable(roexpress, {
    __call = function(self, route: string, ...)
      local event: RemoteEvent = GetRoute(route)
     
      event:FireServer(...)
    end
  })

  return roexpress
end