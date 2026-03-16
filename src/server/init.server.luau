local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Minesweeper = require(ReplicatedStorage.Shared.Minesweeper)

local a = Minesweeper.new(10):Init()

print(a:PrintBoard())
