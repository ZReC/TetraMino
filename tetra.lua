tetra = class:new()

function tetra:init(p, w, c)
	self.piece 		= p

	self.world		= w

	self.k			= self.world.k
	self.position	= {["x"] = self.world.startPos, ["y"] = 0}
	self.yfloat		= 0
	self.c			= c or {love.math.random(64,255),love.math.random(64,255),love.math.random(64,255)}
	self.vel		= {2, 2}
	
	self.sStart		= {2,0}
	
	self.print		= true
	self.inGame		= true
end

function tetra:contact(piece, x, y)
	local touch = {["l"] = false, ["r"] = false, ["d"] = false}

	local piece = piece or self.piece

	for i=1,#piece do
		for j=1,#piece[i] do
			if self.world.grid[y+i] ~= nil then
				if piece[i][j] == true then
					if self.world.grid[y+i][x+(j-1)] == nil or self.world.grid[y+i][x+(j-1)][1] == true then
						if not touch.l then touch.l = true end
					end
					if self.world.grid[y+i][x+(j+1)] == nil or self.world.grid[y+i][x+(j+1)][1] == true then
						if not touch.r then touch.r = true end
					end
					
					if y+i == self.world.w then
						touch.d = true
					end
					
					if not touch.d then
						if piece[i][j] == true and (self.world.grid[y+i][x+j] == nil or self.world.grid[y+(i+1)][x+j][1] == true) then
							touch.d = true
						end
					end
				end
			end
		end
	end

	return touch
end

function tetra:rotate()
	local piece = arrayRotate(self.piece)

	if not self:contact(piece, self.position.x, self.position.y).d then
		local c = true
		
		for i=1,#piece do
			for j=1,#piece[i] do
				if self.world.grid[self.position.y+i][self.position.x+j][1] == true then
					c = false
				end
			end
		end
	
		if c then
			self.piece = piece
		end
	end
end

function arrayRotate(a)
	local _a = {}
	
	for i= 1 , #a[1] do
		_a[i] = {}
		local n = 0;
		for j=#a,1,-1 do
			n = n + 1;
			_a[i][n] = a[j][i]
		end
	end

	return _a

end

function tetra:keypressed(key,_,isrepeat)
	if self.world.gameOver then return end
	local touch = self:contact(self.piece, self.position.x, self.position.y)

	if not touch.l and key == self.k.l then
		self.position.x = self.position.x-1

	elseif not touch.r and  key == self.k.r then
		self.position.x = self.position.x+1

	elseif key == self.k.u then
		self:rotate()

	elseif not isrepeat and key == self.k.d then
		self.vel[2] = hZ*2

	elseif not isrepeat and key == self.k.s and self.inGame then
		self:putShadow()
	end
end

function tetra:keyreleased(key)
	if self.world.gameOver then return end
	if key == self.k.d then
		self.vel[2] = self.vel[1]
	end
end

function tetra:putShadow()
	for _y=1, #self.world.grid do
		if _y >= self.position.y and not self:contact(self.piece, self.position.x, _y-1).d and self:contact(self.piece, self.position.x, _y).d then
			self:setPiece(self.position.x,_y)
			break
		end
	end
end

function tetra:setPiece(x,y)
	self.print = false
	self.inGame = false
	
	for i=1,#self.piece do
		for j=1,#self.piece[i] do
			if self.piece[i][j] then
				self.world:set(y+i,x+j,self.c)
			end
		end
	end

	local setflash = false
	for i =1, #self.world.flashPiece+1 do
		if not self.world.flashPiece[i] then
			setflash = i
			break end
	end
	
	if setflash then
		self.world.flashPiece[setflash] = {}
		self.world.flashPiece[setflash].piece = self.piece
		self.world.flashPiece[setflash].pos = {x,y}
		self.world.flashPiece[setflash].t = {4,0}
	end
	
	
	self.world.test = true
end

function tetra:update(dt)
	local gSize = self.world.gSize

	local touch = self:contact(self.piece, self.position.x, self.position.y)

	self.yfloat = self.yfloat+(dt*self.vel[2])
	
	if self.print then
		if self.yfloat >= 1 then
			self.yfloat = 0

			if touch.d then
				self:setPiece(self.position.x, self.position.y)
			else
				self.position.y = self.position.y+1
			end
		end
	end
	
	if self.sStart[2] < 1 then
		self.sStart[2] = self.sStart[2]+dt*self.sStart[1] end
end

function tetra:draw()
	local p = self.piece
	local gSize = self.world.gSize
	local wx,wy = self.world.position.x, self.world.position.y
	
	if self.print then
		local r,g,b = unpack(self.c) 
	
		for _y=1, #self.world.grid do
			if _y >= self.position.y and not self:contact(self.piece, self.position.x, _y-1).d and self:contact(self.piece, self.position.x, _y).d then
				if _y ~= self.position.y and _y > 2 then
					for i=1, #p do
						for j=1, #p[i] do
							if p[i][j] then					
								local x, y = wx+(((self.position.x*gSize)+gSize*j)-gSize),wy+(((_y*gSize)+gSize*i)-gSize)
								
								love.graphics.setColor(r,g,b,128*self.sStart[2])
								love.graphics.draw(gfx.shadow, x, y, 0, gSize/64)
							end
						end
					end
				end

				break
			end
		end


		for i=1, #p do
			for j=1, #p[i] do
				if p[i][j] then					
					local x, y = wx+(((self.position.x*gSize)+gSize*j)-gSize),wy+(((self.position.y*gSize)+gSize*i)-gSize)
					
					love.graphics.setColor(r,g,b, self.position.y>0 and 255 or 128+(128*self.yfloat))
					love.graphics.draw(gfx.tetra, x, y, 0, gSize/64)
				end
			end
		end
	end
end

tetraForms = {
	--cube
	[1] =	{
		[1] = {true,true},
		[2] = {true,true}
	},

	-- l1
	
	[2] =	{
		[1] = {true,false,false},
		[2] = {true,true,true}
	},

	-- l2
	
	[3] =	{
		[1] = {false,false,true},
		[2] = {true,true,true}
	},
	
	-- s1
	
	[4] =	{
		[1] = {true,true,false},
		[2] = {false,true,true},
	},

	-- s2

	[5] =	{
		[1] = {false,true,true},
		[2] = {true,true,false}
	},
	
	-- t
	
	[6] =	{
		[1] = {true,true,true},
		[2] = {false,true,false}
	},

	-- g

	[7] =	{
		[1] = {false,false,false,false},
		[2] = {true,true,true,true},
		[3] = {false,false,false,false},
		[4] = {false,false,false,false}
	},	
}

--[[
tetraForms = {
	--cube
	[1] =	{
		{-- 0�
			[1] = {true,true},
			[2] = {true,true}
		}
	},

	-- l1
	
	[2] =	{
		{-- 0�
			[1] = {true,false,false},
			[2] = {true,true,true}
		},
		{-- 90�
			[1] = {true,true},
			[2] = {true,false},
			[3] = {true,false}
		},
		{-- 180�
			[1] = {true,true,true},
			[2] = {false,false,true}
		},
		{-- 270�
			[1] = {false,true},
			[2] = {false,true},
			[3] = {true,true}
		}
	},

	-- l2
	
	[3] =	{
		{-- 0�
			[1] = {false,false,true},
			[2] = {true,true,true}
		},
		{-- 90�
			[1] = {true,false},
			[2] = {true,false},
			[3] = {true,true}
		},
		{-- 180�
			[1] = {true,true,true},
			[2] = {true,false,false}
		},
		{-- 270�
			[1] = {true,true},
			[2] = {true,false},
			[3] = {true,false}
		}
	},
	
	-- s1
	
	[4] =	{
		{-- 0�
			[1] = {true,true,false},
			[2] = {false,true,true}
		},
		{-- 90�
			[1] = {false,true},
			[2] = {true,true},
			[3] = {true,false}
		}
	},

	-- s2

	[5] =	{
		{-- 0�
			[1] = {false,true,true},
			[2] = {true,true,false}
		},
		{-- 90�
			[1] = {true,false},
			[2] = {true,true,},
			[3] = {false,true}
		}
	},
	
	-- t
	
	[6] =	{
		{-- 0�
			[1] = {true,true,true},
			[2] = {false,true,false}		
		},
		{-- 90�
			[1] = {false,false,true},
			[2] = {false,true,true},
			[3] = {false,false,true}		
		},
		{-- 180�
			[1] = {false,true,false},
			[2] = {true,true,true}	
		},
		{-- 270�
			[1] = {true,false,false},
			[2] = {true,true,false},
			[3] = {true,false,false}
		}
	},

	-- g

	[7] =	{
		{-- 0�
			[1] = {true,true,true,true}
		},
		{-- 90�
			[1] = {true},
			[2] = {true},
			[3] = {true},
			[4] = {true}
		}
	},	
}
]]