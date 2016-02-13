menu = {}

function menu.load()
	love.graphics.setBackgroundColor(20,20,107)

	menu.p = {}

	menu.p.image = love.graphics.newImage("gfx/pParticles.png")
	menu.p.image:setFilter("nearest", "nearest")
	
	q = {
		love.graphics.newQuad(0, 0, 12, 8, menu.p.image:getDimensions()),
		love.graphics.newQuad(12, 0, 12, 8, menu.p.image:getDimensions()),
		love.graphics.newQuad(24, 0, 12, 8, menu.p.image:getDimensions()),
		love.graphics.newQuad(36, 0, 12, 8, menu.p.image:getDimensions()),
		love.graphics.newQuad(48, 0, 12, 8, menu.p.image:getDimensions()),
		love.graphics.newQuad(60, 0, 8, 8, menu.p.image:getDimensions()),
		love.graphics.newQuad(68, 0, 16, 4, menu.p.image:getDimensions())
	}
	
	for i = 1, 7 do
		menu.p[i] = love.graphics.newParticleSystem(menu.p.image, 100)
		menu.p[i]:setQuads(q[i])
		
		menu.p[i]:setParticleLifetime(3)
		menu.p[i]:setSizes(4*wScale)
		menu.p[i]:setEmissionRate(7)
		menu.p[i]:setLinearAcceleration(10, 10, -10, -10)

		menu.p[i]:setColors(255,255,255,0, 255,255,255,128, 255,255,255,0)
		menu.p[i]:setRelativeRotation(true)

		menu.p[i]:setAreaSpread("uniform", sW,sH)
	end

	menu.buttons = {
		{
			["name"] = "1 PLAYER",
			["x"] = sW/2,
			["y"] = sH/10*5.5
		},
		{
			["name"] = "2 PLAYERS",
			["x"] = sW/2,
			["y"] =  sH/10*6
		},
		{
			["name"] = "MULTIPLAYER",
			["x"] = sW/2,
			["y"] = sH/10*6.5
		},
		{
			["name"] = "OPTIONS",
			["x"] = sW/2,
			["y"] = sH/10*7.5
		}
	}menu.button = 1

	menu.text = {}
	
	for i = 1, #menu.buttons do
		menu.text[i] = {}
		menu.text[i].t = love.graphics.newText(font.ariblkM, "")
		bText(menu.text[i].t, menu.buttons[i].name)
	end
	
	menu.arrows = {[1] = {}, [2] = {}}
	menu.arrows[1].t = love.graphics.newText(font.ariblkM, "►")
	menu.arrows[2].t = love.graphics.newText(font.ariblkM, "◄")

	bText(menu.arrows[1].t, "►")
	bText(menu.arrows[2].t, "◄")
	
	menu.tP = love.graphics.newParticleSystem(gfx.menuP, 64)
	menu.tP:setParticleLifetime(2,1,3)
	menu.tP:setEmissionRate(8)
	menu.tP:setSizes(wScale,1.2*wScale,wScale)
	menu.tP:setColors(255,255,255,0, 255,255,255,192, 255,255,255,0)
	menu.tP:setAreaSpread("uniform", menu.text[menu.button].t:getWidth()/2, menu.text[menu.button].t:getHeight()/2)
	menu.tP:setPosition(menu.buttons[menu.button].x, menu.buttons[menu.button].y+menu.text[menu.button].t:getHeight()/2)
	
	menu.time = {2,1, true}
	
	menu.startGame = false
end

function menu.keypressed(key,_,isrepeat)
	if key == "up" then
		menu.button = menu.button == 1 and #menu.buttons/2 or menu.button -1
	elseif key == "down" then
		menu.button = menu.button == #menu.buttons/2 and 1 or menu.button +1
	elseif key == "return" then
		if menu.button == 1 then
			menu.startGame = 1
		elseif menu.button == 2 then
			menu.startGame = 2
		end
	end
end


function menu.update(dt)
	if menu.time[3] then
		if menu.time[2] < 0 then
			menu.time[3] = false
		end
		menu.time[2] = menu.time[2]-dt*menu.time[1]
	end

	if menu.startGame ~= false then
		menu.time[2] = menu.time[2]+dt*menu.time[1]
		if menu.time[2] > 1 then
			menu.time[2] = 0
			game.start(menu.startGame)
			menu.startGame = false
		end
		return
	end

	for i = 1, 7 do
		menu.p[i]:update(dt)
	end
	
	menu.tP:update(dt)
end

function menu.draw()
	love.graphics.setColor(0,0,0)
	love.graphics.draw(gfx.bgf,0,0,0,sW/1600,sH/900)
	love.graphics.draw(gfx.bgf,sW,sH,math.pi,sW/1600,sH/900)

	love.graphics.setColor(255,255,255)

	for i = 1, 7 do
		love.graphics.draw(menu.p[i], 0, 0)
	end

	for i=1, #menu.buttons do
		if i == menu.button then
			menu.tP:setAreaSpread("uniform", menu.text[menu.button].t:getWidth()/2, menu.text[menu.button].t:getHeight()/2)
			menu.tP:setPosition(menu.buttons[menu.button].x, menu.buttons[menu.button].y+menu.text[menu.button].t:getHeight()/2)
			love.graphics.draw(menu.tP, 0,0)
			love.graphics.setColor(255,255,255,192)
		else
			love.graphics.setColor(255,255,255,64)
		end

		love.graphics.setColor(i>2 and 64 or 255,i>2 and 64 or 255,i>2 and 64 or 255,i>2 and 32 or 255)
		love.graphics.draw(menu.text[i].t, menu.buttons[i].x-menu.text[i].t:getWidth()/2, menu.buttons[i].y)	
	end
	
	love.graphics.setColor(255,255,255)
	love.graphics.draw(menu.arrows[1].t,
		menu.buttons[menu.button].x-(menu.text[menu.button].t:getWidth()/2+menu.arrows[1].t:getWidth()),
		menu.buttons[menu.button].y-(menu.arrows[1].t:getHeight()/2-menu.text[menu.button].t:getHeight()/2)
	)

	love.graphics.draw(menu.arrows[2].t,
		menu.buttons[menu.button].x+menu.text[menu.button].t:getWidth()/2,
		menu.buttons[menu.button].y-(menu.arrows[2].t:getHeight()/2-menu.text[menu.button].t:getHeight()/2)
	)

	love.graphics.draw(gfx.zrec,sW/2,sH/6,0,wScale*.5,wScale*.5,gfx.zrec:getWidth()/2, gfx.zrec:getHeight()/2)
	love.graphics.draw(gfx.zrecG,((gfx.zrec:getWidth()/2)*(wScale*.5))+(sW/2),((gfx.zrec:getHeight()/2)*(wScale*.5))+(sH/6),0,wScale*.5,wScale*.5, gfx.zrecG:getWidth()/1.3, gfx.zrecG:getHeight()/1.3)

	love.graphics.draw(gfx.menuGN,sW/2,sH/3,0,wScale,wScale,gfx.menuGN:getWidth()/2,gfx.menuGN:getHeight()/2)
	
	love.graphics.setColor(255,255,255,128)
	love.graphics.print("Ver. "..game.version, 0, sH-sH/64)
	
	if menu.startGame ~= false then
		love.graphics.setColor(255,255,255,255*menu.time[2])
		love.graphics.rectangle("fill",0,0,sW,sH)
	end
	
	if menu.time[3] then
		love.graphics.setColor(0,0,0,255*menu.time[2])
		love.graphics.rectangle("fill",0,0,sW,sH)
	end	
end

