local Minesweeper = {}
Minesweeper.__index = Minesweeper

export type Tile = {
	isMine: boolean,
	isFlagged: boolean,
	isRevealed: boolean,
	adjacentMines: number,
}

local function makeRow(size: number)
	local row: { Tile } = {}
	for _ = 1, size do
		table.insert(row, {
			isMine = false,
			isFlagged = false,
			isRevealed = false,
			adjacentMines = 0,
		})
	end

	setmetatable(row, {
		-- in order to prevent out of bounds errors
		__index = function()
			return {
				isMine = false,
				isFlagged = true,
				isRevealed = true,
				adjacentMines = 0,
			}
		end,
	})

	return row
end

local function makeBoard(size: number)
	local board: { { Tile } } = {}
	for i = 1, size do
		board[i] = makeRow(size)
	end

	setmetatable(board, {
		-- in order to prevent out of bounds errors
		-- board{} returns an empty row, which can then return 0 for any nil index
		__index = function()
			print("Out of bounds access detected!")
			return makeRow(0)
		end,
	})

	return board
end

function Minesweeper.new(size: number, mineProbability: number?)
	local self = setmetatable({}, Minesweeper)

	self.board = makeBoard(size)
	self.size = size
	self.mineProbability = mineProbability or 0.13

	return self
end

local neighborOffsets = {
	{ -1, -1 },
	{ -1, 0 },
	{ -1, 1 },
	{ 0, -1 },
	{ 0, 1 },
	{ 1, -1 },
	{ 1, 0 },
	{ 1, 1 },
}
function Minesweeper:Init()
	print("Initializing Minesweeper board...")

	print("Placing mines... (1/2)")
	for i = 1, self.size do
		for j = 1, self.size do
			if math.random() < self.mineProbability then
				self.board[i][j].isMine = true
			end
		end
	end

	print("Calculating adjacent mines... (2/2)")
	for i = 1, self.size do
		for j = 1, self.size do
			-- only calculate adjacent mines for actual mines
			if not self.board[i][j].isMine then
				continue
			end
			-- increment adjacentMines for all neighbors
			for _, offset in neighborOffsets do
				self.board[i + offset[1]][j + offset[2]].adjacentMines += 1
			end
		end
	end

	print("Minesweeper board initialized!")
	return self
end

function Minesweeper:PrintBoard()
	for i = 1, self.size do
		local rowStr = ""
		for j = 1, self.size do
			local tile = self.board[i][j]
			if tile.isMine then
				rowStr ..= "X "
			elseif tile.adjacentMines > 0 then
				rowStr ..= tostring(tile.adjacentMines) .. " "
			else
				rowStr ..= ". "
			end
		end
		print(rowStr)
	end
end

--[[
    Reveals the tile at (x,y)

    Returns false if the tile is a mine, ending the game
    Returns true if the tile is not a mine
]]
function Minesweeper:RevealTile(x: number, y: number)
	local tile = self.board[x][y]
	if tile.isRevealed or tile.isFlagged then
		return
	end

	tile.isRevealed = true
	-- todo add real world changes

	if tile.isMine then
		print("Game Over! You hit a mine at (" .. x .. ", " .. y .. ")")
		return false
	end

	if tile.adjacentMines == 0 then
		for _, offset in neighborOffsets do
			self:RevealTile(x + offset[1], y + offset[2])
		end
	end

	return true
end

return Minesweeper
