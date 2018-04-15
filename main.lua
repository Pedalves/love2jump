function love.load()
	speed = 1
	player = newplayer()
end

function love.keypressed(key)
	if key == "right" then
		player.walk(1)
	end
	if key == "left" then
		player.walk(-1)
	end
	if key == "space" then
		player.jump()
	end
end

function love.update(dt)
end

function love.draw()
	player.draw()
end

function newplayer()
	local x, y = 30, 200
	local width, height = love.graphics.getDimensions()
	return {
		update = function(dt)
		end,
		draw = function()
			love.graphics.setColor(0,255,0)
			love.graphics.rectangle("line", x, y, 10, 30)
			love.graphics.setColor(255,255,255)
		end,
		walk = function(dir)
			x = x + (dir*speed)
			if x > width then
				x = 0
			end
		end,
		jump = function()
		end
	}
end