-- Renan da Fonte Simas dos Santos - 1412122
-- Pedro Ferreira - 1320981

local init = false

function newPlataform(init_y)
  local y = init_y
  local speed = math.random(1,4)
  local x = math.random(1,love.graphics.getWidth() - 100)
  
  local img = love.graphics.newImage("resources/plataform.png")
  return {
	width = 100,
	height = 10,
    update = coroutine.wrap (function (self)
      while 1 do
        local _, height = love.graphics.getDimensions( )
        y = y+speed/10
        if y > height then
          y = 0
          x = math.random(1,love.graphics.getWidth() - 100)
          speed = math.random(1,4)
        end
        wait(1/1000, self)
       
      end
    end),
    
    draw = function(self)
      love.graphics.setColor(0,0,0)
      love.graphics.rectangle("fill", x, y, self.width, self.height)
      love.graphics.setColor(255,255,255)
      
      -- love.graphics.draw(img, x, y, 0, 1/10, 1/10)
    end,
    
    sleep = 0,
    
    isActive = function(self)
      if(os.clock() >= self.sleep) then
        return true
      end
      return false
    end,
	getPosition = function()
		return x,y
	end
  }
end

function newplayer()
	local x, y = 50, 100
	local width, height = love.graphics.getDimensions()
	local speed = 200
	local jumpinitialspeed = 350
  
	return {
		jumpspeedy = 0, --define velocidade corrente do pulo
		jumpdir = 0, --define direção horizontal do pulo
		startjumpheight = 0, --guarda a altura de onde pulou
		sizex = 10, --largura do player
		sizey = 30, --altura do player
    
		--Controla o que ocorre com o player a cada Update
		update = function(self, dt)
      y = y - self.jumpspeedy*dt
      
			--Checa se já está no solo
      curPlat = self:isPlayerOnFloor() --guarda a plataforma onde o player está
      if curPlat ~= nil then
        plat_x, plat_y = curPlat.getPosition()
        self.jumpspeedy = 0
      else
         self.jumpspeedy = self.jumpspeedy - gravity*dt
      end
      
			self:walk(dt) --movimento
			self:checkPos()
		end,
    
		draw = function(self)
			love.graphics.setColor(0,255,0)
			love.graphics.rectangle("fill", x, y, self.sizex, self.sizey)
			love.graphics.setColor(255,255,255)
		end,
    
		--Define movimentação
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
    
    
		--Define o pulo
		jump = function(self)
      if self.jumpspeedy <= 0 and self.jumpspeedy > -50 then
			--Checa se está pulando para evitar múltiplos pulos
        self.jumpspeedy = jumpinitialspeed --inicia pulo				
        self.startjumpheight = y --Atualiza altura quando pulou
      end
		end,
    
		--Checa se jogador está em uma plataforma ou no chão (no caso, retorna nil)
		isPlayerOnFloor = function(self)
			--Para cada plataforma, checa se player está em cima
			for i = 1,#lisPlataforms do
				plat_x, plat_y = lisPlataforms[i].getPosition()
				--checa x
				if (x >= plat_x and x <= plat_x + lisPlataforms[i].width) then
					--checa y
					if (math.floor(y) == math.floor(plat_y - self.sizey)) then
            
						return lisPlataforms[i]
					end
				end
			end
			return nil
		end,
    
		--Retorna as coordenadas do player
		getPosition = function()
			return x, y
		end,
    
		--Checa se player está em uma posição válida e corrige caso necessário
		checkPos = function(self)
			curX, curY = self.getPosition()
			if curX > width - self.sizex then
				x = width - self.sizex
			elseif curX < 0 then
				x = 0
			end
			if curY >= height - self.sizey then
				gameover = true
			elseif curY < 0 then
				y = 0
			end
		end
	}
end


function love.load()
	debugMode = true --printa variaveis

	gameover = false
	gravity = 500
	player = newplayer()
  
  background = love.graphics.newImage("resources/background.jpg")
	
	math.randomseed(os.time())
	lisPlataforms = {}
  
	for i = 1, 10 do
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
  if (init and not gameover) then
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
	if not gameover then
		love.graphics.draw(background, 0, 0, 0, sx, sy)

		player:draw()
		for i = 1,#lisPlataforms do
			lisPlataforms[i]:draw()
		end
		
		if debugMode then
			playerx, playery = player.getPosition()
			love.graphics.printf("jumpverticalspeed: " .. player.jumpspeedy, 0, 0, 500, "left")
			love.graphics.printf("position: (" .. playerx .. ", " .. playery .. ")", 0, 30, 500, "left")
		end
	else
		love.graphics.print("GAME OVER", love.graphics.getWidth()/4, love.graphics.getHeight()/4, 0, 5, 5)
	end
end

function wait(segundos, meublip)
    cur = os.clock()
    meublip.sleep = cur+segundos
    coroutine.yield()
end