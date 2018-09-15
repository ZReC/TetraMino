menu = {}

function menu.load()
	love.graphics.setBackgroundColor(5/64,5/64,107/256)

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

		menu.p[i]:setColors(1,1,1,0, 1,1,1,(1/2), 1,1,1,0)
		menu.p[i]:setRelativeRotation(true)

		menu.p[i]:setEmissionArea("uniform", sW,sH)
	end

	menu.button = {
		{
			enable	= true,
			name	= "1 PLAYER",
			x		= sW/2,
			y		= sH/10*5
		},
		{
			enable	= true,
			name	= "2 PLAYERS",
			x		= sW/2,
			y		= sH/10*5.5
		},
		{
			enable	= false,
			name	= "MULTIPLAYER",
			x		= sW/2,
			y		= sH/10*6
		},
		{
			enable	= false,
			name	= "OPTIONS",
			x		= sW/2,
			y		= sH/10*7
		},
		{
			enable	= true,
			name	= "EXIT",
			x		= sW/2,
			y		= sH/10*8
		}
	}menu.selected = 1

	menu.text = {}
	
	for i = 1, #menu.button do
		menu.text[i] = {}
		menu.text[i].t = love.graphics.newText(font.ariblkM, "")
		bText(menu.text[i].t, menu.button[i].name)
	end
	
	menu.arrow = {[1] = {}, [2] = {}}
	menu.arrow[1].t = love.graphics.newText(font.ariblkM, "►")
	menu.arrow[2].t = love.graphics.newText(font.ariblkM, "◄")

	bText(menu.arrow[1].t, "►")
	bText(menu.arrow[2].t, "◄")
	
	menu.tP = love.graphics.newParticleSystem(gfx.menuP, 64)
	menu.tP:setParticleLifetime(2,1,3)
	menu.tP:setEmissionRate(8)
	menu.tP:setSizes(wScale,1.2*wScale,wScale)
	menu.tP:setColors(1,1,1,0, 1,1,1,(3/4), 1,1,1,0)
	menu.tP:setEmissionArea("uniform", menu.text[menu.selected].t:getWidth()/2, menu.text[menu.selected].t:getHeight()/2)
	menu.tP:setPosition(menu.button[menu.selected].x, menu.button[menu.selected].y+menu.text[menu.selected].t:getHeight()/2)
	
	menu.time = {2,1, true}
	
	menu.startGame = false
end

function menu.keypressed(key,_,isrepeat)
	-- BUG FIX
	if menu.time[3] then return end

	if key == "up" then
		repeat
			menu.selected = menu.selected == 1 and #menu.button or menu.selected -1
		
		until menu.button[menu.selected].enable
	elseif key == "down" then
		repeat
			menu.selected = menu.selected == #menu.button and 1 or menu.selected +1
			
		until menu.button[menu.selected].enable
		
	elseif key == "return" then
		if menu.selected == 1 then
			menu.startGame = 1
		elseif menu.selected == 2 then
			menu.startGame = 2
		elseif menu.selected == 5 then
			game.exit.start = true
			game.exit.greeting = math.random(#game.greetings)
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

	love.graphics.setColor(1,1,1)

	for i = 1, 7 do
		love.graphics.draw(menu.p[i], 0, 0)
	end

	for i=1, #menu.button do
		local alphabutton = (3/4)
		
		if i == menu.selected then
			alphabutton = 1
			menu.tP:setEmissionArea("uniform", menu.text[menu.selected].t:getWidth()/2, menu.text[menu.selected].t:getHeight()/2)
			menu.tP:setPosition(menu.button[menu.selected].x, menu.button[menu.selected].y+menu.text[menu.selected].t:getHeight()/2)
			love.graphics.draw(menu.tP, 0,0)
			love.graphics.setColor(1,1,1,(3/4))
		else
			love.graphics.setColor(1,1,1,(1/4))
		end

		love.graphics.setColor(menu.button[i].enable and {1, 1, 1, alphabutton} or {(1/2), (1/2), (1/2), (3/8)})
		love.graphics.draw(menu.text[i].t, menu.button[i].x-menu.text[i].t:getWidth()/2, menu.button[i].y)	
	end

	
	love.graphics.setColor(1,1,1)
	
	local arrowAx, arrowAy =
								menu.button[menu.selected].x-(menu.text[menu.selected].t:getWidth()/2+menu.arrow[1].t:getWidth()*2),
								menu.button[menu.selected].y-(menu.arrow[1].t:getHeight()/2-menu.text[menu.selected].t:getHeight()/2)
	
	local arrowBx, arrowBy =
								menu.button[menu.selected].x+(menu.text[menu.selected].t:getWidth()/2+menu.arrow[1].t:getWidth()),
								menu.button[menu.selected].y-(menu.arrow[2].t:getHeight()/2-menu.text[menu.selected].t:getHeight()/2)

	local tmpSIN = math.sin((math.pi*love.timer.getTime())%math.pi)
	
	love.graphics.draw(menu.arrow[1].t,	arrowAx+tmpSIN*menu.arrow[1].t:getWidth(), arrowAy)
	love.graphics.draw(menu.arrow[2].t, arrowBx-tmpSIN*menu.arrow[2].t:getWidth(), arrowBy)

	love.graphics.draw(gfx.menuGN,sW/2,sH/4,0,wScale,wScale,gfx.menuGN:getWidth()/2,gfx.menuGN:getHeight()/2)
	
	love.graphics.setColor(1,1,1,(1/2))
	love.graphics.print(game.name.." "..game.version.." - ".."Contact me: m.me/DrZReC or t.me/DrZReC", 0, sH-sH/64)
	
	if menu.startGame ~= false then
		love.graphics.setColor(1,1,1,menu.time[2])
		love.graphics.rectangle("fill",0,0,sW,sH)
	end
	
	if menu.time[3] then
		love.graphics.setColor(0,0,0,menu.time[2])
		love.graphics.rectangle("fill",0,0,sW,sH)
	end	
end

