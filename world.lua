world = class:new()

function world:init(x,y, w, h, gSize, k, pName)

	self.grid = {}
	self.gSize = gSize

	self.k = k
	self.position = {["x"] = x, ["y"] = y}

	self.w = w
	self.h = h

	self.imageq = love.graphics.newQuad(0, 0, h*gSize, w*gSize, gfx.tetra:getWidth()*(gSize/64), gfx.tetra:getHeight()*(gSize/64))
	
	self.lW = gSize/2

	self.startPos = math.floor(h/2)-1

	self.pName = {}
	self.pName.d = pName or "ZReC"
	self.pName.t = love.graphics.newText(font.ariblk, "")
	bText(self.pName.t, self.pName.d)
	
	self.gameOver = false
	self.finish = false

	self.colorT = {1,0}

	self.test = false
	self.lineN = false
	self.olineN = 0
	self.wLTime = {2,0}
	
	self.tetra = tetra:new(tetraForms[love.math.random(7)], self, {love.math.random(64,255),love.math.random(64,255),love.math.random(64,255)})
	self.tetranext = tetraForms[love.math.random(7)]
	self.tetranextC = {love.math.random(64,255),love.math.random(64,255),love.math.random(64,255)}
	
	self.sText = {}

	self.sText.d = "SCORE: "
	self.sText.t = love.graphics.newText(font.ariblk, "")
	self.sText.v = 0
	bText(self.sText.t, self.sText.d..self.sText.v)
	
	self.bPoints = {}
	for i = 1, self.h*gSize do
		self.bPoints[i] = math.sin(((i/(self.h*gSize))*2)/1 * math.pi/2)*128
	end
	
	self.combo = {}
	self.combo.m = {0, 0, 0, current = 0, ammount = 0, equal = false}
	self.combo.d = {"COMBO !","DOUBLE ","TRIPLE ","MASTER ", "ULTRA\n", "MIX "}
	self.combo.t = love.graphics.newText(font.ariblk2, "")
	self.combo.w = {false, .75,0}
	self.combo.n = {[1] = 0, [2] = 0, [3] = 0, [4] = 0}
	
	self.endGame = {}
	self.endGame.t = love.graphics.newText(font.ariblk2, "")
	self.endGame.w = {.75,0}
	bText(self.endGame.t, "GAME OVER!")

	self.timeInGame = {}
	self.timeInGame.ms = 0
	self.timeInGame.t = love.graphics.newText(font.ariblk, "00:00")

	
	self.flashPiece = {}
	
	self:clear()
end

function world:clear()
	for i=1, self.w do
		self.grid[i] = {}
		for j=1, self.h do
			self.grid[i][j] = {false, {0,0,0}}
		end
	end
end

function world:set(x,y,c)
	if not self.grid[x][y][1] then
		self.grid[x][y] = {true, c}
	end
end

function world:dLine(l)
	for j=l,3, -1 do
		for k=1, #self.grid[j] do
			self.grid[j][k] = self.grid[j-1][k]
		end
	end
end

function world:check()
	local repeatCheck = false

	local ls = {}
	
	for i=3, #self.grid do
		local l = true
		for j=1, #self.grid[i] do
			if not self.grid[i][j][1] then
				l = false
			end
		end
		if l then
			ls[#ls+1] = i
		end
	end
	
	if #ls > 0 then
		self.lineN = ls
		self.olineN = #ls
		repeatCheck = true
	end

	if not repeatCheck then
		self.test = false
		self.lineN = false
	else
		return
	end

	for i=1, #self.grid[2] do
		if self.grid[2][i][1] == true then
			self.gameOver = true
			break
		end
	end
end

function world:keypressed(key,_,isrepeat)
	
	if self.tetra.inGame then
		self.tetra:keypressed(key,_,isrepeat)
	end
end

function world:keyreleased(key)
	if self.tetra.inGame then
		self.tetra:keyreleased(key)
	end
end

function world:update(dt)
	if not self.gameOver then
		self.timeInGame.ms = self.timeInGame.ms+dt
		local m, s = math.floor( self.timeInGame.ms / 60 ), math.floor( self.timeInGame.ms % 60 )
		bText(self.timeInGame.t, string.format("%02d:%02d",m,s))
 
		if self.tetra.inGame then
			self.tetra:update(dt)
		elseif not self.test then
			self.tetra:init(self.tetranext, self, self.tetranextC)
			self.tetranext = tetraForms[love.math.random(7)]
			self.tetranextC = {love.math.random(64,255),love.math.random(64,255),love.math.random(64,255)}
		end
	end
	
	if self.test and not self.lineN then
		self:check()
	elseif self.test and self.lineN then
		if self.wLTime[2] >= 1 then
			self.wLTime[2] = 0

			for n=1,#self.lineN do self:dLine(self.lineN[n]) end


			-- Chequea ULTRA COMBO
			-- Administra el número de combos
			
			if #self.lineN > 1 then
				if self.combo.m.current < 3 then
					self.combo.m.current = self.combo.m.current+1
					self.combo.m[self.combo.m.current] = #self.lineN
				end
				
				if self.combo.m.current == 3 then
					self.combo.m.equal = (self.combo.m[1] == self.combo.m[2] and self.combo.m[2] == self.combo.m[3])
					for i=1, 3 do
						self.combo.m.ammount = self.combo.m[i]+self.combo.m.ammount end
				end
			
				-- Pre actualización del SCORE (ULTRA)
				if self.combo.m.ammount ~= 0 then
					self.sText.v = self.sText.v+(self.combo.m.equal and self.combo.m.ammount*100 or self.combo.m.ammount*50)
				end
			
				self.combo.n[#self.lineN] = self.combo.n[#self.lineN]+1
			end
			self.combo.n[1] = self.combo.n[1]+#self.lineN

			-- Actualización de SCORE
			self.sText.v = self.sText.v+((#self.lineN*self.h)*#self.lineN)

			bText(self.sText.t, self.sText.d..self.sText.v)
			
			if #self.lineN > 1 then
				local txt
				
				if self.combo.m.current == 3 then
					txt = self.combo.d[5]
					
					if self.combo.m.equal then
						txt = txt..self.combo.d[#self.lineN]
					else
						txt = txt..self.combo.d[6]
					end
				else
					txt = self.combo.d[#self.lineN]
				end
				
				txt = txt..self.combo.d[1]
				
				bText(self.combo.t, txt, _, "center")
				self.combo.w[1] = true
			end			
			
			self:check()
		else
			self.wLTime[2] = self.wLTime[2]+(dt*self.wLTime[1])
		end
	end
	
	if self.combo.w[1] then
		if self.combo.w[3] >= 1 then
			self.combo.w[1] = false
			self.combo.w[3] = 0
			if self.combo.m.current == 3 then
				self.combo.m = {0, 0, 0, current = 0, ammount = 0, equal = false}
			end
		else
			self.combo.w[3] = self.combo.w[3]+(dt*self.combo.w[2])
		end
	end
	
	if self.gameOver and self.colorT[2] < 1 then
		self.colorT[2] = self.colorT[2]+(dt*self.colorT[1])
	end
	if self.gameOver and not self.finish then
		if self.endGame.w[2] < 1 then
			self.endGame.w[2] = self.endGame.w[2]+dt*self.endGame.w[1]
		else
			if #self.flashPiece == 0 then
				self.finish = true
			end
		end
	end
	if #self.flashPiece > 0 then
		for i in pairs(self.flashPiece) do
			if self.flashPiece[i] and self.flashPiece[i].t[2] <= 1 then
				self.flashPiece[i].t[2] = self.flashPiece[i].t[2]+dt*self.flashPiece[i].t[1]
			else
				self.flashPiece[i] = nil
			end
		end
	end
end

function world:draw()
	local gSize = self.gSize
	local x,y = self.position.x, self.position.y
	
	love.graphics.setColor(16,16,16,32)
	love.graphics.rectangle("fill",x,y,self.h*gSize,self.w*gSize)
	love.graphics.draw(gfx.tetra, self.imageq, x, y)
	
	for i=1, #self.grid do
		for j=1, #self.grid[i] do
			local nDL = true
			if self.lineN then 
				for n=1, #self.lineN do
					if i == self.lineN[n] then nDL = false end
				end
			end
			if self.grid[i][j][1] then
				local r,g,b = unpack(self.grid[i][j][2])

				if #self.flashPiece > 0 then
					local EOL = false
					for idx in pairs(self.flashPiece) do
						for _i=1,#self.flashPiece[idx].piece do
							for _j=1,#self.flashPiece[idx].piece[_i] do
								if self.flashPiece[idx].piece[_i][_j] then
									if self.flashPiece[idx].pos[2]+_i == i and self.flashPiece[idx].pos[1]+_j == j then
										local h,s,v =  rgbToHsv(r, g, b)
										local l = math.cos(math.min(math.max(self.flashPiece[idx].t[2]*2,0),2)/1 * math.pi/2)+1
										r,g,b = hsvToRgb(h,s-s*l,v+(1-v)*l)
										EOL = true
										break
									end
								end
							end
							if EOL then break end
						end
					end
				end

				if self.gameOver then
					local h,s,v =  rgbToHsv(r, g, b)
					r,g,b = hsvToRgb(h,math.max(s-self.colorT[2]*s, 0),v)
				end
				
				love.graphics.setColor(r,g,b,nDL and 255 or (1-self.wLTime[2])*255)				
				love.graphics.draw(gfx.tetra, (x+(gSize*j)-gSize),(y+(gSize*i)-gSize), 0, gSize/64)
			end
		end
	end

	self.tetra:draw()

	if self.tetra.position.y > 1 then

		for i=1, #self.tetranext do
			for j=1, #self.tetranext[i] do
				if self.tetranext[i][j] then	
					local r,g,b = unpack(self.tetranextC)
					love.graphics.setColor(r,g,b,self.tetra.position.y > 2 and 128 or 128*self.tetra.yfloat)
					love.graphics.draw(gfx.tetra, x+(((self.startPos*gSize)+gSize*j)-gSize), y+((gSize*i)-gSize), 0, gSize/64)
				end
			end
		end			
	end

	love.graphics.setLineWidth(self.lW)
	love.graphics.setColor(255,255,255,64)
	love.graphics.rectangle("line",x-self.lW/2,y-self.lW/2,self.h*gSize+self.lW,self.w*gSize+self.lW)
	love.graphics.setColor(255,255,255,128)
	love.graphics.rectangle("line",x-self.lW/1.2,y-self.lW/1.2,self.h*gSize+self.lW/.6,self.w*gSize+self.lW/.6)

	love.graphics.setLineWidth(1)
	for i=1, self.h*gSize do
		love.graphics.setColor(255,255,255,self.bPoints[i])
		love.graphics.points(x+i,y+gSize*2)
	end

	love.graphics.setColor(255,255,255,192)
	love.graphics.draw(self.sText.t,x-self.lW,y-self.sText.t:getHeight()-self.lW)
	love.graphics.draw(self.pName.t,x+self.h*gSize-self.pName.t:getWidth()+self.lW,y-self.sText.t:getHeight()-self.lW)
	
	for i=1, 3 do
		local x,y = x+(self.h-i)*gSize+self.lW-(self.lW/2*i)+self.lW/2,y+self.w*gSize+self.lW+self.lW/2
	
		love.graphics.setColor(255,255,255,128)
		love.graphics.draw(gfx.combo, x, y, 0, gSize/64)
		if self.combo.m[i] ~= 0 then
			
			love.graphics.setColor(	
						self.combo.m[i] == 2 and {0,0,255} or
						self.combo.m[i] == 3 and {0,255,0} or {255,0,0} )
			
			love.graphics.draw(gfx.comboI, x, y,0, gSize/64)
		end
	end
	
	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.timeInGame.t, x-self.lW,y+self.w*gSize+self.lW)
	
	if self.combo.w[1] then
		local n = math.sin((self.combo.w[3]*2)/1 * math.pi/2)
		local rN = self.olineN
		local r = rN == 4 and ((self.w*gSize)/2)*n or rN == 3 and self.w*gSize-(self.w*gSize/2)*n or (self.w*gSize)/2 

		if self.combo.m.ammount ~= 0 then
			if self.combo.m.equal then
				love.graphics.setColor(rN == 4 and 255 or 64,rN == 3 and 255 or 64,rN == 2 and 255 or 64)
			else
				love.graphics.setColor(255,255,255)
			end
		else
			love.graphics.setColor(rN == 4 and 255 or 64,rN == 3 and 255 or 64,rN == 2 and 255 or 64)
		end
		love.graphics.draw(self.combo.t, x+(self.h*gSize)/2, y+r, 0, n, n, sW/2, self.combo.t:getHeight()/2)
	end
	
	if self.gameOver then
		love.graphics.setColor(255,255,255)
		local sx = math.sin((self.endGame.w[2]*1.5)/1 * math.pi/2)
		local sy = math.sin((self.endGame.w[2]*.8)/1 * math.pi/2)
		love.graphics.draw(self.endGame.t, x+(self.h*gSize)/2, y+(self.w*gSize)/2, r, sx, sy, self.endGame.t:getWidth()/2, self.endGame.t:getHeight()/2)
	end
	
	love.graphics.setColor(255,255,255)
	
	local idx = 1
	for i,v in pairs(self.combo.m) do
		love.graphics.print(tostring(i).." | "..tostring(v), 50, idx*25)
		idx = idx+1
	end
end