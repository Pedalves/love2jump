-- Renan da Fonte Simas dos Santos - 1412122
-- Pedro Ferreira - 1320981

local init = false

function newPlataform(init_y)
  local y = init_y
  local speed = math.random(1,10)
  local x = math.random(1,love.graphics.getWidth() - 100)

  return {
    update = coroutine.wrap (function (self)
      while 1 do
        local _, height = love.graphics.getDimensions( )
        y = y+speed/10
        if y > height then
          y = 0
          x = math.random(1,love.graphics.getWidth() - 100)
          speed = math.random(1,10)
        end
        wait(1/1000, self)
       
      end
    end),
    
    draw = function ()
      love.graphics.rectangle("fill", x, y, 100, 10)
    end,
    
    sleep = 0,
    
    isActive = function(self)
      if(os.clock() >= self.sleep) then
        return true
      end
      return false
    end
  }
end

function newplayer()
	local x, y = 30, 200
	local width, height = love.graphics.getDimensions()
	return {
		update = function(dt)
		end,
		draw = function()
			love.graphics.setColor(0,255,0)
			love.graphics.rectangle("fill", x, y, 10, 30)
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

function love.load()
	speed = 10
	player = newplayer()
	
	math.randomseed(os.time())
	lisPlataforms = {}
  
	for i = 1, 5 do
		lisPlataforms[i] = newPlataform(i * 100)
	end
end

function love.keypressed(key)
	init = true
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
  if init then
    for i = 1,#lisPlataforms do
      if(lisPlataforms[i]:isActive()) then
        lisPlataforms[i]:update()      
      end
    end
  end
end

function love.draw()
	player.draw()
	for i = 1,#lisPlataforms do
		lisPlataforms[i].draw()
	end
end

function wait(segundos, meublip)
    cur = os.clock()
    meublip.sleep = cur+segundos
    coroutine.yield()
end