require "class"
require "mouse"
require "game"
require "menu"
require "world"
require "tetra"

gfx = {}
font = {}

function love.load()
	love.filesystem.remove("NOTE.txt") -- LITTLE EASTER EGG

	sW, sH, sF = love.window.getMode()
	hZ = sF["refreshrate"]
	wScale = sH*(1/768)
	
	waitStartT = {1,0}
	
	love.math.setRandomSeed(love.timer.getTime(),love.timer.getTime())
	math.randomseed(love.timer.getTime())
	love.keyboard.setKeyRepeat(true)	
	
	font.ariblk = love.graphics.newFont("font/ariblk.ttf", 24*wScale)
	font.ariblk:setFilter("nearest", "nearest", 0)

	font.ariblkM = love.graphics.newFont("font/ariblk.ttf", 24*wScale)
	font.ariblkM:setFilter("nearest", "nearest", 0)

	font.ariblk1 = love.graphics.newFont("font/ariblk.ttf", 32*wScale)
	font.ariblk1:setFilter("nearest", "nearest", 0)

	font.ariblk2 = love.graphics.newFont("font/ariblk.ttf", 48*wScale)
	font.ariblk2:setFilter("nearest", "nearest", 0)

	font.ariblk3 = love.graphics.newFont("font/ariblk.ttf", 64*wScale)
	font.ariblk3:setFilter("nearest", "nearest", 0)

	font.ariblk4 = love.graphics.newFont("font/ariblk.ttf", 128*wScale)
	font.ariblk4:setFilter("nearest", "nearest",0)
	
	font.normal	= love.graphics.newFont("font/clacon.ttf", 48)
	font.normal:setFilter("nearest", "nearest", 0)
	
	gfx.tetra = love.graphics.newImage("gfx/piece.png")
	gfx.tetra:setWrap("repeat", "repeat")
	gfx.shadow = love.graphics.newImage("gfx/shadow.png")
	
	gfx.menuP = love.graphics.newImage("gfx/menup.png")
	gfx.star = love.graphics.newImage("gfx/star.png")
	gfx.menuGN = love.graphics.newImage("gfx/menuGN.png")
	gfx.zrec = love.graphics.newImage("gfx/zrec.png")
	gfx.zrecG = love.graphics.newImage("gfx/zrec-games.png")
	
	gfx.combo = love.graphics.newImage("gfx/combo.png")
	gfx.comboI = love.graphics.newImage("gfx/comboI.png")

	gfx.bgf = love.graphics.newImage("gfx/bgf.png")
	
	menu.load()
end

function love.update(dt)
	if game.state == "start" then
		waitStartT[2] = waitStartT[2]+waitStartT[1]*dt
		return
	end
	
	if game.state == "menu" then
		menu.update(dt)

	elseif game.state == "play" or game.state == "pause" then
		game.pause.update(dt)
		if game.state == "play" then
			game.play.update(dt)
			for _, v in ipairs(game.worlds) do
				v:update(dt)
			end			
		end
	end

	if game.state == "menu" and game.oldstate ~= "menu" then
		menu.load()
		if game.oldstate == "pause" then menu.time[2] = 1 menu.time[3] = true end
		game.worlds = {}
	end

	if game.oldstate ~= game.state then game.oldstate = game.state end
	
	if game.exit.start then
		game.exit.fade = game.exit.fade+dt
	end
end

function love.draw()
	if game.state == "start" then
		if waitStartT[2] > 3 then
			game.state = "menu"
		end
		love.graphics.draw(gfx.zrec,sW/2,sH/2,0,wScale,wScale,gfx.zrec:getWidth()/2, gfx.zrec:getHeight()/2)
		
		love.graphics.setColor(255,255,255,waitStartT[2] > 1 and 255 or 0)
		local bounce = outBounce(waitStartT[2] < 2 and waitStartT[2]-1 or 1)
		love.graphics.draw(gfx.zrecG,((gfx.zrec:getWidth()/2)*wScale)+(sW/2),((gfx.zrec:getHeight()/2)*wScale)+(sH/2),0,wScale*bounce,wScale*bounce, gfx.zrecG:getWidth()/1.3, gfx.zrecG:getHeight()/1.3)
			
		love.graphics.setColor(0,0,0,255*(waitStartT[2] < 1 and 1-waitStartT[2] or waitStartT[2] > 2 and waitStartT[2]-2 or 0))
		love.graphics.rectangle("fill", 0,0,sW,sH)
		love.graphics.setColor(255,255,255)
		return
	end

	if game.state == "menu" then
		menu.draw()

	elseif game.state == "play" or game.state == "pause" then
		if game.pause.e then
			if not game.pause.eA then
				game.pause.blur.c1[1]:renderTo(
					function()
						love.graphics.clear(love.graphics.getBackgroundColor())
						for _, v in ipairs(game.worlds) do
							v:draw()
						end
					end
				)
				game.pause.eA = true
			else
				if game.pause.blur.t1[2]<game.pause.blur.t1[1] then
					game.pause.blur.t1[2] = game.pause.blur.t1[2]+1
					game.pause.blur.c1[2]:renderTo(
						function()
							love.graphics.setShader(game.pause.blur.v)
							love.graphics.draw(game.pause.blur.c1[1])
							love.graphics.setShader()
						end)
					game.pause.blur.c1[1]:renderTo(
						function()
							love.graphics.setShader(game.pause.blur.h)
							love.graphics.draw(game.pause.blur.c1[2])
							love.graphics.setShader()
						end)
				end
			end
		else
			for _, v in ipairs(game.worlds) do
				v:draw()
			end
		end

		game.pause.draw()
		game.play.draw()
	end
	
	-- El metodo es algo extraño, me gusta lo extraño
	if game.exit.start then
		love.graphics.setFont(font.normal)
	
		love.graphics.setColor(0,0,0,255*math.min(game.exit.fade, 1))
		love.graphics.rectangle("fill",0,0,sW,sH)
		
		if game.exit.fade > 1 then
			love.graphics.setColor(255,255,255)
			
			local txt = "- O.ZSystem VER "..game.version.." | COPYRIGHT "..os.date("%Y").." -\n\n\t"
			
			if game.exit.fade > 1.3 then
				txt = txt.."zrec@dev:~$ "..string.sub("exit", 0, math.min(math.floor((game.exit.fade-1.3)*3), 4))
				
				if game.exit.fade > 3 then
					txt = txt.."\n\tAre you Sure? [ Y/N ] "
					
					if game.exit.fade>3.5 then
						txt = txt.."Y"
						
						if game.exit.fade > 4 then
							
							txt = txt.."\n\n\tTHANKS TO PLAY!\n\n\tzrec@dev:~$ "
							if game.exit.fade > 4.5 then
								
								txt = txt..string.gsub(string.sub(game.greetings[game.exit.greeting], 0, math.min(math.floor((game.exit.fade-4.5)*8), #game.greetings[game.exit.greeting])), ";", "")
								if game.exit.fade > 6+(#game.greetings[game.exit.greeting]/8) then
								
									if game.exit.greeting == 7 then -- LITTLE EASTER EGG
										love.filesystem.write("NOTE.txt", "U'r amazing")
									end
									
									love.event.quit(0)
								end
							end
						end
					end
				end
			end
			
			if game.exit.fade%.30 > .15 then
				txt = txt.."█"
			end
			
			love.graphics.print(txt, sW*.015, sH*.015, 0, sH*.001)
		end
	end
	
	love.graphics.setColor(0,0,0,0)
end

function love.keypressed(key,_,isrepeat)
	if (key == "return" or key == "escape") and game.pause.drawENDa then
		game.pause.q = true
	end

	if key == "escape" then
		if game.state == "menu" then
			menu.selected = 5
		end
		if game.exit.start then
			love.event.quit(0)
		end
	end
	
	if game.exit.start or game.pause.q or (menu.startGame ~= false and game.state == "menu") then return end
	
	if (game.state == "menu" or game.state == "pause") and isrepeat then return end

	if game.state == "play" or game.state == "pause" then

		if game.state == "play" and key == "escape" then
			game.state = "pause"
			return
		end

		if key == "return" then
			if game.pause.s == 1 then
				game.state = "play"
			elseif game.pause.s == 2 then
				game.pause.q = true
				return
			end

		elseif key == "up" then
			game.pause.s = game.pause.s == 2 and 1 or game.pause.s+1

		elseif key == "down" then
			game.pause.s = game.pause.s == 1 and 2 or game.pause.s-1

		elseif key == "escape" then
			game.state = "play"
			
			-- Reiniciar el menu de pausa
			game.pause.s = 1
		end

		if game.state ~= "pause" then
			for _, v in ipairs(game.worlds) do
				v:keypressed(key,_,isrepeat)
			end
		end

	elseif game.state == "menu" and game.oldstate ~= "pause" then		
		menu.keypressed(key,_,isrepeat)

	end
end

function love.keyreleased(key)
	if game.state == "play" or game.state == "pause" then
		if game.state == "pause" then return end

		for _, v in ipairs(game.worlds) do
			v:keyreleased(key)
		end
	end
end

function love.quit()
	if not game.exit.start then
		if game.state == "menu" then
			if menu.selected == 5 then
				game.exit.start = true
			end
			
		elseif game.state == "play" or game.state == "pause" then
			if game.pause.s == 2 then
				love.keypressed("return")
				return true
			end
			
			game.pause.s = 2
		end
		
		love.keypressed("escape")
		return true
	end
	-- Iniciado game.exit.start puede salir del juego cuando quiera.
end

function bText(t, v, w, a)
	if not t then return end
	w = w or sW
	a = a or "left"
	
	t:set()
	
	if type(v) == "table" then
		local str = ""
		
		for _, value in pairs(v) do
			if type(value) == "string" then
				str = str..value
			end
		end
		t:addf({{0, 0, 0}, str}, w, a, 0, 0)
		t:addf({{0, 0, 0}, str}, w, a, 0, 2)
		t:addf({{0, 0, 0}, str}, w, a, 2, 0)
		t:addf({{0, 0, 0}, str}, w, a, 2, 2)
		
		t:addf(v, w, a, 1, 1)
	else
		t:addf({{0, 0, 0}, v}, w, a, 0, 0)
		t:addf({{0, 0, 0}, v}, w, a, 0, 2)
		t:addf({{0, 0, 0}, v}, w, a, 2, 0)
		t:addf({{0, 0, 0}, v}, w, a, 2, 2)
		t:addf({{255, 255, 255}, v}, w, a, 1, 1)
	end
end

function rgbToHsv(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v
  v = max

  local d = max - min
  if max == 0 then s = 0 else s = d / max end

  if max == min then
    h = 0 -- achromatic
  else
    if max == r then
    h = (g - b) / d
    if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, v
end

function hsvToRgb(h, s, v)
  local r, g, b

  local i = math.floor(h * 6);
  local f = h * 6 - i;
  local p = v * (1 - s);
  local q = v * (1 - f * s);
  local t = v * (1 - (1 - f) * s);

  i = i % 6

  if i == 0 then r, g, b = v, t, p
  elseif i == 1 then r, g, b = q, v, p
  elseif i == 2 then r, g, b = p, v, t
  elseif i == 3 then r, g, b = p, q, v
  elseif i == 4 then r, g, b = t, p, v
  elseif i == 5 then r, g, b = v, p, q
  end

  return r * 255, g * 255, b * 255
end