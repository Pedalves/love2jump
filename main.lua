-- Renan da Fonte Simas dos Santos - 1412122
-- Pedro Ferreira - 1320981

local init = false

function newPlataform(init_y)
  local y = init_y
  local speed = math.random(1,10)
  local x = math.random(1,love.graphics.getWidth() - 100)
  
  local img = love.graphics.newImage("resources/plataform.png")
  print()
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
      love.graphics.setColor(0,0,0)
      love.graphics.rectangle("fill", x, y, 100, 10)
      love.graphics.setColor(255,255,255)
      
      --love.graphics.draw(img, x, y, 0, 1/10, 1/10)
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
	local speed = 10
	local jumpinitialspeed = 20
	local jumphorizontalspeed = 10
	return {
		jumpspeedy = 0, --define velocidade corrente do pulo
		jumpdir = 0, --define direção horizontal do pulo
		startjumpheight = 0, --guarda a altura de onde pulou
		update = function(self, dt)
			if (self.jumpspeedy > 0 or y <= self.startjumpheight) then
				self.jumpspeedy = self.jumpspeedy - gravity*dt
				
				y = y - self.jumpspeedy*dt
					
				--Checa se já está no solo
				if y >= self.startjumpheight then
					y = self.startjumpheight
					self.jumpspeedy = 0
				else				
					x = x + (jumphorizontalspeed*dt*self.jumpdir) -- movimentacao enquanto pula
				end
				
			else
				jumpdir = 0 --reseta jumpdir
			end
		end,
		draw = function()
			love.graphics.setColor(0,255,0)
			love.graphics.rectangle("fill", x, y, 10, 30)
			love.graphics.setColor(255,255,255)
		end,
		walk = function(self, dir)
			--Checa se está pulando para não andar enquanto pula
			if self.jumpspeedy > 0 then
				self.jumpdir = dir
				return
			end
			x = x + (dir*speed)
			if x > width then
				x = 0
			end
		end,
		jump = function(self)
			--Checa se está pulando para evitar múltiplos pulos
			if self.jumpspeedy > 0 then
				return
			end
			
			self.jumpspeedy = jumpinitialspeed --inicia pulo		
			self.startjumpheight = y --Atualiza altura quando pulou
		end,
		getPosition = function()
			return x, y
		end
	}
end

function love.load()
	debugMode = true --printa variaveis

	gravity = 10
	player = newplayer()
  
  background = love.graphics.newImage("resources/background.jpg")
	
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
  local sx = love.graphics.getWidth() / background:getWidth()
  local sy = love.graphics.getHeight() / background:getHeight()
  love.graphics.draw(background, 0, 0, 0, sx, sy)

	player.draw()
	for i = 1,#lisPlataforms do
		lisPlataforms[i].draw()
	end
	
	if debugMode then
		playerx, playery = player.getPosition()
		love.graphics.printf("jumpverticalspeed: " .. player.jumpspeedy, 0, 0, 500, "left")
		love.graphics.printf("position: (" .. playerx .. ", " .. playery .. ")", 0, 30, 500, "left")
	end
end

function wait(segundos, meublip)
    cur = os.clock()
    meublip.sleep = cur+segundos
    coroutine.yield()
end