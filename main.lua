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
	local x, y = 30, 500
	local width, height = love.graphics.getDimensions()
	local speed = 200
	local jumpinitialspeed = 300
	return {
		jumpspeedy = 0, --define velocidade corrente do pulo
		jumpdir = 0, --define direção horizontal do pulo
		startjumpheight = 0, --guarda a altura de onde pulou
		sizex = 10, --largura do player
		sizey = 30, --altura do player
		update = function(self, dt)
			-- pulo
			if (self.jumpspeedy ~= 0) then
				self.jumpspeedy = self.jumpspeedy - gravity*dt
				
				y = y - self.jumpspeedy*dt
					
				--Checa se já está no solo
				if y > self.startjumpheight then
					self.jumpspeedy = 0
					y = self.startjumpheight
				end
			end
			
			self:walk(dt) --movimento
			self:checkPos()
		end,
		draw = function(self)
			love.graphics.setColor(0,255,0)
			love.graphics.rectangle("fill", x, y, self.sizex, self.sizey)
			love.graphics.setColor(255,255,255)
		end,
		walk = function(self, dt)
			dir = 0 --guarda direção do movimento
			
			--Checa tecla pressionada
			if love.keyboard.isDown("right", "d") then
				dir = 1
			elseif love.keyboard.isDown("left", "a") then
				dir = -1
			end
			
			--Executa movimento
			x = x + (dir*speed*dt)
		end,
		jump = function(self)
			--Checa se está pulando para evitar múltiplos pulos
			if player.jumpspeedy == 0 then
				self.jumpspeedy = jumpinitialspeed --inicia pulo				
				self.startjumpheight = y --Atualiza altura quando pulou
			end
		end,
		isPlayerOnFloor = function()
		end,
		getPosition = function()
			return x, y
		end,
		checkPos = function(self)
			curX, curY = self.getPosition()
			if curX > width - self.sizex then
				x = width - self.sizex
			elseif curX < 0 then
				x = 0
			end
			if curY >= height - self.sizey then
				y = height - self.sizey
			elseif curY < 0 then
				y = 0
			end
		end
	}
end


function love.load()
	debugMode = true --printa variaveis

	gravity = 500
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
	if key == "space" or key == "up" or key == "w" then
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

	player:draw()
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