game = {}

game.version = "1.1.0.9"
game.state = "start"
game.oldstate = "start"

game.worlds		= {}

game.play		= {}

game.pause		= {}

game.pause.t	= {2,0,0,0,false}
game.pause.s	= 1
game.pause.m	= false
game.pause.q	= false

game.greetings	= {"See you next time!", "Bye Bye :;D", "Have fun!", "See you!", "Take care :;)", "Seeks the Tri;;for;;ce..", "\n\t\tGoodbye, ;Player, ;honey! ;;;It'll be okay. ;;;Just read the note!"}

game.exit		= {start = false, fade = 0, greeting = 0}

function game.start(t, v)
	t = t or 1 -- 1 player
	v = v or {["worldW"] = 27, ["worldH"] = 12, ["gridSize"] = sH/32}

	if t == 1 then
		local wW, wH, gS = v.worldW, v.worldH, v.gridSize
		game.worlds[#game.worlds+1] = world:new((sW/2)-((wH*gS)/2), (sH/2)-((wW*gS)/2), wW, wH, gS, {["u"] = "w", ["d"] = "s", ["l"] = "a", ["r"] = "d", ["s"] = "space"}, "Player 1")		
	elseif t == 2 then
		local wW, wH, gS = v.worldW, v.worldH, v.gridSize
		game.worlds[#game.worlds+1] = world:new((sW/4)-((wH*gS)/2), (sH/2)-((wW*gS)/2), wW, wH, gS, {["u"] = "w", ["d"] = "s", ["l"] = "a", ["r"] = "d", ["s"] = "space"}, "Player 1")
		game.worlds[#game.worlds+1] = world:new(sW-(sW/4)-((wH*gS)/2), (sH/2)-((wW*gS)/2), wW, wH, gS, {["u"] = "up", ["d"] = "down", ["l"] = "left", ["r"] = "right", ["s"] = "kp0"}, "Player 2")
	end

	if not game.pause.text then
		game.pause.text = {}
		game.pause.text.p = love.graphics.newText(font.ariblk1, "Pause Menu")
		game.pause.text.r = love.graphics.newText(font.ariblk, "Resume")
		game.pause.text.q = love.graphics.newText(font.ariblk, "Quit Menu")
	end
	game.state = "pause"
	game.pause.s = 1
	game.bg = {32,32,64}
	love.graphics.setBackgroundColor(game.bg)

	game.pause.m = true
	game.pause.t[2] = 1
	game.pause.t[4] = 0
	game.pause.t[5] = false

	if not game.play.tP then
		game.play.tP = love.graphics.newParticleSystem(gfx.star, 256)
		game.play.tP:setParticleLifetime(16)
		game.play.tP:setEmissionRate(8)
		game.play.tP:setSizes(0,wScale,wScale)
		game.play.tP:setColors(255,255,255,255, 255,255,255,0)
		game.play.tP:setLinearAcceleration(1, 1, -1, -1)
		game.play.tP:setAreaSpread("uniform", sW, sH)
		game.play.tP:setPosition(0,0)
	end

	game.pause.e = false
	game.pause.eA = false
	game.pause.win = {}
	game.pause.win.w = {}
	game.pause.win.t = {}
	game.pause.win.s = {1,0}
	game.pause.win.st = {}
	game.pause.win.c = {1,0,0,0,0}
	game.pause.win.cp = {false,false,false,false,false,false,-1,0}
	game.pause.win.cpt = {}
	game.pause.win.tim = {}
	game.pause.win.tim.t = {}
	game.pause.win.tim.s = {1,0}
	game.pause.win.bPoints = {}
	game.pause.win.textWinner = {}

	game.pause.drawEND = false
	game.pause.drawENDa = false
	
	game.pause.blur = {}
	game.pause.blur.h = love.graphics.newShader
							[[
								extern vec2 screen;
								extern float steps = 2;

								vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
									vec4 col = Texel(texture, texture_coords);
									for(int i = 1; i <= steps; i++) {
										col = col + Texel(texture, vec2(texture_coords.x, texture_coords.y - screen.y * i));
										col = col + Texel(texture, vec2(texture_coords.x, texture_coords.y + screen.y * i));
									}
									col = col / (steps * 2.0 + 1.0);
									return vec4(col.r, col.g, col.b, 1.0);
								}
							]]
	game.pause.blur.v = love.graphics.newShader
							[[
								extern vec2 screen;
								extern float steps = 4;

								vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
									vec4 col = Texel(texture, texture_coords);
									for(int i = 1; i <= steps; i++) {
										col = col + Texel(texture, vec2(texture_coords.x - screen.x * i, texture_coords.y));
										col = col + Texel(texture, vec2(texture_coords.x + screen.x * i, texture_coords.y));
									}
									col = col / (steps * 2.0 + 1.0);
									return vec4(col.r, col.g, col.b, col.a);
								}
							]]
	game.pause.blur.c1 = {love.graphics.newCanvas(),love.graphics.newCanvas()}
	game.pause.blur.c2 = {love.graphics.newCanvas(),love.graphics.newCanvas()}
	game.pause.blur.t1 = {100,0}
	game.pause.blur.t2 = {1000,0}
	
	game.pause.blur.h:send("screen",{1/sW,1/sH})
	game.pause.blur.v:send("screen",{1/sW,1/sH})
end

local mask_shader = love.graphics.newShader[[
							   vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
								  if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
									 // a discarded pixel wont be applied as the stencil.
									 discard;
								  }
								  return vec4(1.0);
							   }
							]]

function game.play.update(dt)
	game.play.tP:update(dt)
end

function game.play.draw()
	love.graphics.setColor(255,255,255,game.pause.q and 255*(1-game.pause.t[3]) or 255)
	love.graphics.draw(game.play.tP, 0,0)
end

function game.pause.update(dt)
	local isAllGameover = true
	for i=1, #game.worlds do
		if not game.worlds[i].finish then isAllGameover = false end
	end

	if game.pause.e then
		if game.pause.t[4] < 1 and not game.pause.t[5] then
			game.pause.t[4] = game.pause.t[4]+dt*game.pause.t[1]
		elseif game.pause.t[4] > 1 and not game.pause.t[5] then

			game.pause.t[5] = true
			game.pause.win.w = game.worlds
			game.worlds = {}

			local winner,bestScore,tie = false,0,true
			
			if #game.pause.win.w>1 then
				for i=1, #game.pause.win.w-1 do
					if game.pause.win.w[i].sText.v ~= game.pause.win.w[i+1].sText.v then
						tie = false
						break
					end
				end
			
				if not tie then
					for i=1, #game.pause.win.w do
						if game.pause.win.w[i].sText.v > bestScore then
							bestScore = game.pause.win.w[i].sText.v
							winner = i
						end
					end
				game.pause.win.winner = winner
				else
					game.pause.win.winner = false
				end
			end
			
			for i=1, #game.pause.win.w do
				game.pause.win.t[i] = love.graphics.newText(font.ariblk3, "")
				bText(game.pause.win.t[i],game.pause.win.w[i].pName.d)
				game.pause.win.st[i] = {love.graphics.newText(font.ariblk1, ""),love.graphics.newText(font.ariblk1, "")}
				bText(game.pause.win.st[i][1],game.pause.win.w[i].sText.d)
			
				game.pause.win.cpt[i] = {}
				for j=1, 4 do
					game.pause.win.cpt[i][j] = {love.graphics.newText(font.ariblk1, ""),love.graphics.newText(font.ariblk1, "")}
					bText(game.pause.win.cpt[i][j][1],j==1 and "Lines" or "Combo x"..j)
				end
				
				game.pause.win.tim.t[i] = {love.graphics.newText(font.ariblk1, ""),love.graphics.newText(font.ariblk1, "")}
				bText(game.pause.win.tim.t[i][1],"Time")
				
				game.pause.win.bPoints[i] = {}
				for j = 1, game.pause.win.t[i]:getWidth() do
					game.pause.win.bPoints[i][j] = math.sin(((j/game.pause.win.t[i]:getWidth())*2)/1 * math.pi/2)*128
				end
			end
			game.pause.win.textWinner.t = love.graphics.newText(font.ariblk4, #game.pause.win.w==1 and "GAME OVER" or game.pause.win.winner==false and "TIED" or game.pause.win.w[game.pause.win.winner].pName.d)
			game.pause.win.textWinner.c = love.graphics.newCanvas(sW,sH,"normal",0)
			game.pause.win.textWinner.c:setFilter("nearest", "nearest",0)
			
			if #game.pause.win.w>1 and game.pause.win.winner~=false then
				game.pause.win.textWinner.yW = love.graphics.newText(font.ariblk4,"WIN!")
			end

		elseif game.pause.t[4] > 0 and game.pause.t[5] then
			game.pause.t[4] = game.pause.t[4]-dt*game.pause.t[1]
		else
			if game.pause.win.s[2] < 1 then
				game.pause.win.s[2] = game.pause.win.s[2]+dt*game.pause.win.s[1]
				for i=1, #game.pause.win.w do
					bText(game.pause.win.st[i][2],math.floor(game.pause.win.w[i].sText.v*game.pause.win.s[2]))
				end
			else
				if game.pause.win.s[2] ~= 1 then
					for i=1, #game.pause.win.w do
						bText(game.pause.win.st[i][2],game.pause.win.w[i].sText.v)
					end
					game.pause.win.s[2] = 1
				end
				
				for i=1, 4 do
					if not game.pause.win.cp[i] then
						if game.pause.win.c[i+1] < 1 then
							game.pause.win.c[i+1] = game.pause.win.c[i+1]+dt*game.pause.win.c[1]
							for j=1, #game.pause.win.w do
								bText(game.pause.win.cpt[j][i][2],math.floor(game.pause.win.w[j].combo.n[i]*game.pause.win.c[i+1]))
							end						
							break
						else
							for j=1, #game.pause.win.w do
								bText(game.pause.win.cpt[j][i][2],game.pause.win.w[j].combo.n[i])
							end
							game.pause.win.cp[i] = true
						end
					end				
				end
				if not game.pause.win.cp[5] and game.pause.win.cp[4] then
					for i=1, #game.pause.win.w do
						local ms = game.pause.win.w[i].timeInGame.ms
						local m, s = 0,0
						if game.pause.win.tim.s[2]< 1 then
							game.pause.win.tim.s[2] = game.pause.win.tim.s[2]+dt*game.pause.win.tim.s[1]
							m, s = math.floor((ms/60)*game.pause.win.tim.s[2]), math.floor((ms%60)*game.pause.win.tim.s[2])
						else
							m, s = math.floor(ms/60), math.floor(ms%60)
							game.pause.win.cp[5] = true
							game.pause.win.cp[6] = true
						end
						bText(game.pause.win.tim.t[i][2],string.format("%02d:%02d",m,s))
					end
				elseif game.pause.win.cp[6] then
					if game.pause.win.cp[7] < 1 then
						game.pause.win.cp[7] = game.pause.win.cp[7]+dt*2
					elseif game.pause.win.cp[8] < 1 then
						game.pause.win.cp[8] = game.pause.win.cp[8]+dt*2
					end
				end
			end
		end
	elseif isAllGameover then
		game.pause.e = true
		game.state = "pause"
	end

	if game.pause.t[5] then
		game.play.update(dt)
	end
	
	if game.pause.q then
		game.pause.t[3] = game.pause.t[3]+dt*game.pause.t[1]
		if game.pause.t[3] > 1 then
			game.pause.t[3] = 0
			game.pause.q = false
			game.pause.drawENDa = false
			game.state = "menu"
		end
	elseif game.pause.m then
		if game.pause.t[2] > 0 then
			game.pause.t[2] = game.pause.t[2]-dt*game.pause.t[1]
		else
			game.state = "play"
			game.pause.m = false
		end
		
	else
		if game.state == "pause" and game.pause.t[2] < 1 then
			game.pause.t[2] = game.pause.t[2]+dt*game.pause.t[1]
		elseif game.state == "play" and game.pause.t[2] > 0 then
			game.pause.t[2] = game.pause.t[2]-dt*game.pause.t[1]
		end
	end
end

function game.pause.draw()
	if game.pause.drawEND and not game.pause.drawENDa then
		love.graphics.setCanvas(game.pause.blur.c2[1])
		game.pause.blur.h:send("steps",4)
		game.pause.blur.v:send("steps",4)
	end

	love.graphics.setColor(255,255,255)

	if game.pause.eA then
		love.graphics.draw(game.pause.blur.c1[1])
	end

	if game.pause.t[5] and not game.pause.drawENDa then
		if game.pause.drawEND then game.pause.drawENDa = true end

		for i=1, #game.pause.win.t do
			local s = outBounce(1-game.pause.t[4])
			local mW = math.min(math.max(game.pause.win.t[i]:getWidth()/2,sW/6),sW/5)
			local mH = (sH-(game.pause.win.t[i]:getHeight()*6+game.pause.win.tim.t[i][1]:getHeight()/2))/2
			love.graphics.draw(game.pause.win.t[i], ((sW/(#game.pause.win.t*2))+(sW/(#game.pause.win.t))*(i-1)), mH*s, 0, 1,1, game.pause.win.t[i]:getWidth()/2, game.pause.win.t[i]:getHeight()/2-1)
			love.graphics.draw(game.pause.win.t[i], ((sW/(#game.pause.win.t*2))+(sW/(#game.pause.win.t))*(i-1)), mH*s, 0, 1,1, game.pause.win.t[i]:getWidth()/2, game.pause.win.t[i]:getHeight()/2)

			for j=1, #game.pause.win.bPoints[i] do
				love.graphics.setColor(255,255,255,game.pause.win.bPoints[i][j]*(1-game.pause.t[4]))
				love.graphics.points(((sW/(#game.pause.win.t*2))+(sW/(#game.pause.win.t))*(i-1))+j-game.pause.win.t[i]:getWidth()/2, mH+game.pause.win.t[i]:getHeight()/2+game.pause.win.st[i][1]:getHeight()/2)
				love.graphics.points(((sW/(#game.pause.win.t*2))+(sW/(#game.pause.win.t))*(i-1))+j-game.pause.win.t[i]:getWidth()/2, mH+game.pause.win.t[i]:getHeight()/2+game.pause.win.st[i][1]:getHeight()/2+1)
			end

			for j=1, #game.pause.win.bPoints[i] do
				love.graphics.setColor(255,255,255,game.pause.win.bPoints[i][j]*(1-game.pause.t[4]))
				love.graphics.points(((sW/(#game.pause.win.t*2))+(sW/(#game.pause.win.t))*(i-1))+j-game.pause.win.t[i]:getWidth()/2, mH+game.pause.win.t[i]:getHeight()*6+game.pause.win.tim.t[i][1]:getHeight()/2)
			end
			
			love.graphics.setColor(255,255,255)
			if game.pause.t[4] < 0 then
				s = outBounce(game.pause.win.s[2])
				love.graphics.draw(game.pause.win.st[i][1], ((sW/(#game.pause.win.t*2))+(sW/(#game.pause.win.t))*(i-1))-mW, mH+game.pause.win.t[i]:getHeight(), 0, s,s, 0, game.pause.win.st[i][1]:getHeight()/2)
				love.graphics.draw(game.pause.win.st[i][2], ((sW/(#game.pause.win.t*2))+(sW/(#game.pause.win.t))*(i-1))+mW, mH+game.pause.win.t[i]:getHeight(), 0, s,s, game.pause.win.st[i][2]:getWidth(), game.pause.win.st[i][2]:getHeight()/2)
				for j=1, 4 do
					s = outBounce(game.pause.win.c[j+1])
					love.graphics.draw(game.pause.win.cpt[i][j][1], ((sW/(#game.pause.win.t*2))+(sW/(#game.pause.win.t))*(i-1))-mW, mH+game.pause.win.t[i]:getHeight()*(j+1), 0, s,s, 0, game.pause.win.cpt[i][j][1]:getHeight()/2)
					love.graphics.draw(game.pause.win.cpt[i][j][2], ((sW/(#game.pause.win.t*2))+(sW/(#game.pause.win.t))*(i-1))+mW, mH+game.pause.win.t[i]:getHeight()*(j+1), 0, s,s, game.pause.win.cpt[i][j][2]:getWidth(), game.pause.win.cpt[i][j][2]:getHeight()/2)
				end
				if game.pause.win.cp[4] then
					s = outBounce(game.pause.win.tim.s[2])
					love.graphics.draw(game.pause.win.tim.t[i][1], ((sW/(#game.pause.win.t*2))+(sW/(#game.pause.win.t))*(i-1))-mW, mH+game.pause.win.t[i]:getHeight()*6, 0, s,s, 0, game.pause.win.tim.t[i][1]:getHeight()/2)
					love.graphics.draw(game.pause.win.tim.t[i][2], ((sW/(#game.pause.win.t*2))+(sW/(#game.pause.win.t))*(i-1))+mW, mH+game.pause.win.t[i]:getHeight()*6, 0, s,s, game.pause.win.tim.t[i][2]:getWidth(), game.pause.win.tim.t[i][2]:getHeight()/2)
				end
				if game.pause.win.cp[6] and game.pause.win.cp[7] > 0 then
					game.pause.drawEND = true
				end
			end
		 end
	end
	
	love.graphics.setCanvas()
	
	if game.pause.drawEND then
		if game.pause.drawENDa then
			if game.pause.blur.t2[2] < game.pause.blur.t2[1] then
				game.pause.blur.t2[2] = game.pause.blur.t2[2]+1

				game.pause.blur.c2[2]:renderTo(
					function()
						love.graphics.setShader(game.pause.blur.v)
						love.graphics.draw(game.pause.blur.c2[1])
						love.graphics.setShader()
					end)
				game.pause.blur.c2[1]:renderTo(
					function()
						love.graphics.setShader(game.pause.blur.h)
						love.graphics.draw(game.pause.blur.c2[2])
						love.graphics.setShader()
					end)
			end
			love.graphics.draw(game.pause.blur.c2[1],sW/2,sH/2,0,1+game.pause.blur.t2[2]/100,1+game.pause.blur.t2[2]/100,sW/2,sH/2)
		end
		
		game.pause.win.textWinner.c:renderTo(
			function()
				love.graphics.clear()
				love.graphics.draw(game.pause.win.textWinner.t,sW/2,(sH/6)*game.pause.win.cp[7],0,1,1,game.pause.win.textWinner.t:getWidth()/2,game.pause.win.textWinner.t:getHeight()/2)
				if game.pause.win.textWinner.yW then
					love.graphics.draw(game.pause.win.textWinner.yW,sW/2,sH/4+game.pause.win.textWinner.t:getHeight()/2,0,game.pause.win.cp[8] ,game.pause.win.cp[8], game.pause.win.textWinner.yW:getWidth()/2,0)
				end
			end
		)
		
		love.graphics.setColor(0,0,0,64*game.pause.win.cp[7])
		love.graphics.rectangle("fill",0,0,sW,sH)
		love.graphics.setColor(255,255,255)
		
		love.graphics.stencil(
			function()
				love.graphics.setShader(mask_shader)
				love.graphics.setColor(255,255,255)
				love.graphics.draw(game.pause.win.textWinner.c)
				love.graphics.setShader()
			end, "replace", 1)

		love.graphics.setStencilTest("equal", 0)

		local h,s,v = rgbToHsv(love.graphics.getBackgroundColor())
		h,s,v = hsvToRgb(h,s,v)
		love.graphics.setColor(h,s,v,192*game.pause.win.cp[7])		
		love.graphics.rectangle("fill",0,0,sW,sH)

		love.graphics.setStencilTest()

		local redraw = function(f)
							love.graphics.setColor(255,255,255,255*f)
							love.graphics.draw(game.pause.text.q,sW/2,sH/1.3,0,1,1,game.pause.text.q:getWidth()/2,game.pause.text.q:getHeight()/2)
						end
		if game.pause.win.textWinner.yW then
			redraw(game.pause.win.cp[8])
		else
			redraw(game.pause.win.cp[7])
		end
	end
	
	if game.pause.m then
		love.graphics.setColor(255,255,255,255*game.pause.t[2])
		love.graphics.rectangle("fill",0,0,sW,sH)
	elseif game.pause.e then
		
	elseif game.pause.t[2] > 0 then
		love.graphics.setColor(0,0,0,128*game.pause.t[2])
		love.graphics.push()
		love.graphics.translate(sW,0)
		love.graphics.scale(-1, 1)
			
		love.graphics.draw(gfx.bgf,0,0,0,sW/1600,sH/900)
		love.graphics.draw(gfx.bgf,sW,sH,math.pi,sW/1600,sH/900)
		love.graphics.pop()

		love.graphics.rectangle("fill",0,0,sW,sH)
		love.graphics.setColor(255,255,255,128*game.pause.t[2])
		love.graphics.draw(game.pause.text.p,-game.pause.text.p:getHeight()+(game.pause.t[2]*sW/8),sH/8)
			
		love.graphics.setColor(255,255,255,(game.pause.s == 1 and 255 or 128)*game.pause.t[2])
		love.graphics.draw(game.pause.text.r,sW+game.pause.text.r:getHeight()-(game.pause.t[2]*(sW/4+game.pause.text.r:getHeight())),sH/1.5)
		love.graphics.setColor(255,255,255,(game.pause.s == 2 and 255 or 128)*game.pause.t[2])
		love.graphics.draw(game.pause.text.q,sW+game.pause.text.q:getHeight()-(game.pause.t[2]*(sW/4+game.pause.text.q:getHeight())),sH/1.4)
	end
	if game.pause.q then 
		love.graphics.setColor(0,0,0,255*game.pause.t[3])
		love.graphics.rectangle("fill",0,0,sW,sH)
	end
end

function outBounce(t)
	if t < 1 / 2.75 then
		return 1 * (7.5625 * t * t)
	elseif t < 2 / 2.75 then
		t = t - (1.5 / 2.75)
		return 1 * (7.5625 * t * t + 0.75)
	elseif t < 2.5 / 2.75 then
		t = t - (2.25 / 2.75)
		return 1 * (7.5625 * t * t + 0.9375)
	else
		t = t - (2.625 / 2.75)
		return 1 * (7.5625 * t * t + 0.984375)
	end
end
