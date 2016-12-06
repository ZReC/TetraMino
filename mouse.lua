--[[ TODO: Sin pulir.

local isTouch = true

function love.mousemoved(x, y, dx, dy)
	if game.pause.q or (menu.startGame ~= false and game.state == "menu") then return end
	
	if game.state == "menu" then
		for i = 1, #menu.buttons/2 do
			local tW, tH = menu.text[i].t:getWidth(), menu.text[i].t:getHeight()
			local tX, tY = menu.buttons[i].x-tW/2 , menu.buttons[i].y
			
			if x >= tX and x <= tX+tW and y >= tY and y <= tY+tH then
				menu.button = i
				isTouch = true
				break
			end
			isTouch = false
		end
	end
end

function love.mousepressed(x, y, button, istouch)
	if game.pause.q or (menu.startGame ~= false and game.state == "menu") then return end
	if game.pause.drawENDa then
		game.pause.q = true
	end

	if game.state == "menu" and isTouch then
		menu.startGame = menu.button
	end
end

]]--