require("bit")
require("bmp")
local oo = require("loop.base")

GRAVITY = 0.05
MOVESPEED = 1
TERMINALVELOCITY = 10
JUMPSPEED = 2

bmp.isSolidRaw = bmp.isSolid
bmp.isSolid = function(b, x, y) return bmp.isSolidRaw(b, x or 0, y and col.height - y or 0) end

testCol = function(...)
	local t = {...}
	if #t == 1 then return bmp.isSolid(col, t[1].x, t[1].y) end
	return bmp.isSolid(col, t[1] + 7, t[2]) 
end

local Player = oo.class{
	x = 50,
	y = 50,
	xVel = 0,
	yVel = 0
}
function Player:__init(...)
	local t = {...}
	t = t[1]
	if not t.img then error("Missing image for player") end
	t.width = t.img:getWidth()
	t.height = t.img:getHeight()
	return oo.rawnew(self, t)
end
function Player:testCollisions()
	local modifier = 2
	local tl = {x = self.x + modifier, y = self.y + modifier}
	local tr = {x = self.x + self.width - modifier, y = self.y + modifier}
	local bl = {x = self.x + modifier, y = self.y + self.height - modifier}
	local br = {x = self.x + self.width - modifier, y = self.y + self.height - modifier}
	
	self.bounding = {tl = tl, tr = tr, bl = bl, br = br}
	
	local tlTest = testCol(tl.x, tl.y)
	local trTest = testCol(tr.x, tr.y)
	local blTest = testCol(bl.x, bl.y)
	local brTest = testCol(br.x, br.y)
	
	self.collisions = {tl = tlTest, tr = trTest, bl = blTest, br = brTest}
	
	return tlTest, trTest, blTest, brTest
end
function Player:tick()
	self:testCollisions()
	
	self.y = self.y + self.yVel
	
	local bl = {x = self.x, y = self.y + self.height}
	local br = {x = self.x + self.width, y = self.y + self.height}
	
	if self.yVel > 0 and (self.collisions.bl or self.collisions.br) then 
		self.yVel = 0
		self.inAir = false
	elseif not (self.collisions.bl or self.collisions.br) then
		self.yVel = math.min(TERMINALVELOCITY, self.yVel + GRAVITY)
		self.inAir = true
	end
	
	--Test ul and ur collisions
	if self.collisions.tl or self.collisions.tr then
		if self.inAir then
			self.yVel = (TERMINALVELOCITY / 8)
		end
	end
	
	local vel = (love.keyboard.isDown("left") and -1 or 0) + (love.keyboard.isDown("right") and 1 or 0)
	
	self.xVel = vel
	
	self:moveHorizontal()
end
function Player:jump()
	if not self.inAir then
		self.yVel = -JUMPSPEED
	end
end
function Player:moveHorizontal()
	if self.xVel == 0 then return end
	--Test the point (xVel) to the left, then if false, incrementally up until HEIGHT / 3
	local maxUp = math.floor(self.height / 3)
	local point = self.xVel < 0
		and {x = self.bounding.bl.x + self.xVel, y = self.bounding.bl.y - 1}
		or {x = self.bounding.br.x + self.xVel + 5, y = self.bounding.br.y - 1}
	
	if not testCol(point) then 
		if testCol(point.x, point.y + 1) then
			self.y = self.y + 1
		end
		self.x = self.x + self.xVel
		return
	end
	local yTest = point.y - 1
	local canMove = false
	while (point.y - yTest < maxUp) do
		if testCol(point.x, yTest) then
			yTest = yTest - 1
		else 
			canMove = true 
			break
		end
	end
	if canMove then
		self.x = self.x + self.xVel
		self.y = self.y + (yTest - point.y)
	end
end

function love.keypressed(k)
	if k == "up" then
		player:jump()
	end
end

function love.mousepressed(x, y, button)
	
end

function love.load()
	map = love.graphics.newImage("exile_2.jpg")
	col = bmp.load("exile_2_c.bmp")
	playerImg = love.graphics.newImage("player_idle.png")
	
	player = Player{img = playerImg, x = 150}
end

function love.update(dt)
	if not col then return end
	player:tick()
end

function love.draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(map)
	love.graphics.draw(playerImg, player.x, player.y)
	
	--[[for y = player.y - 50, player.y + 50 do
		for x = player.x - 50, player.x + 50 do
			if x > 0 and y > 0 or x < col.width and y > col.height then
				local test = testCol(x, y)
				if test then
					love.graphics.setColor(0, 0, 0, 150)
				else
					love.graphics.setColor(255, 255, 255, 150)
				end
				love.graphics.point(x, y)
			end
		end
	end]]
	
end