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
		jumptimeleft = 0,
		speed = 10,
		jumptime = 1.5,
		jumpheight = 100,
		update = function(self, dt)
			if self.jumptimeleft > 0 then
				self.jumptimeleft = self.jumptimeleft - dt
				y = y + (self.jumpheight*dt) --cai proporcional ao tempo de pulo
			end
		end,
		draw = function()
			love.graphics.setColor(0,255,0)
			love.graphics.rectangle("fill", x, y, 10, 30)
			love.graphics.setColor(255,255,255)
		end,
		walk = function(self, dir)
			x = x + (dir*self.speed)
			if x > width then
				x = 0
			end
		end,
		jump = function(self)
			--Checa se está pulando para evitar múltiplos pulos
			if self.jumptimeleft > 0 then
				return
			end
			
			y = y - self.jumpheight
			self.jumptimeleft = self.jumptime --seta tempo restante para o pulo acabar
		end
	}
end

function love.load()
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
		player:walk(1)
	end
	if key == "left" then
		player:walk(-1)
	end
	if key == "space" then
		player:jump()
	end
end

function love.update(dt)
  if init then
	player:update(dt)
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