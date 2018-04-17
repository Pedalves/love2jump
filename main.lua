-- Renan da Fonte Simas dos Santos - 1412122
-- Pedro Ferreira - 1320981

local init = false
local move_player1 = {left = "a", jump = "w", right = "d"}
local move_player2 = {left = "left", jump = "up", right = "right"}

-----------------------------------------------------------------------

function newPlataform(init_y)
  local y = init_y
  local speed = math.random(1,3)
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
          speed = math.random(1,3)
        end
        wait(1/1000, self)
       
      end
    end),
    
    draw = function(self)
      love.graphics.draw(img, x , y - 2*self.height, 0, 1/15, 1/10)
    end,
    
    sleep = 0,
    
    isActive = function(self)
      if(os.clock() >= self.sleep) then
        return true
      end
      return false
    end,
	getPosition = function()
		return x, y
	end
  }
end

-----------------------------------------------------------------------

function newplayer(movetable, color, xInit, yInit)
	local x, y = xInit + 20, yInit - 30
	local width, height = love.graphics.getDimensions()
	local speed = 200
	local jumpinitialspeed = 380
  
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
      if color == "green" then
        love.graphics.setColor(0,255,0)
      else
        love.graphics.setColor(255,0,0)
      end
			love.graphics.rectangle("fill", x, y, self.sizex, self.sizey)
			love.graphics.setColor(255,255,255)
		end,
    
    keypressed = function(self, key)
      if key == movetable.jump then
        self:jump()
      end
    end,
    
		--Define movimentação
		walk = function(self, dt)
			dir = 0 --guarda direção do movimento
			
			--Checa tecla pressionada
			if love.keyboard.isDown(movetable.right) then
				dir = 1
			elseif love.keyboard.isDown(movetable.left) then
				dir = -1
			end
			--Executa movimento
			x = x + (dir*speed*dt)
		end,
    
    
		--Define o pulo
		jump = function(self)
      if self.jumpspeedy <= 0 and self.jumpspeedy > -52 then
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
				x = 0
			elseif curX < 0 then
				x = width - self.sizex
			end
			if curY >= height - self.sizey then
				gameover = color
			end
		end
	}
end

-----------------------------------------------------------------------

function love.load()
  love.window.setTitle("Love2Jump")
  
	gameover = nil
	gravity = 500
  gameovertextfont = love.graphics.newFont("resources/PressStart2P-Regular.ttf")
  
  background = love.graphics.newImage("resources/background.jpg")
	
	math.randomseed(os.time())
	lisPlataforms = {}
  
	for i = 1, 10 do
		lisPlataforms[i] = newPlataform(i * 100)
	end
  
  initialX, initialY = lisPlataforms[2].getPosition()
  
  player1 = newplayer(move_player1, "green", initialX, initialY)
  player2 = newplayer(move_player2, "red", initialX + 20, initialY)
end

-----------------------------------------------------------------------

function love.keypressed(key)
	init = true
  player1:keypressed(key)
  player2:keypressed(key)
  
  if gameover ~= nil then
    if key == 'space' then
        love.load()
    end
  end
  
  if key == "p" then
    love.graphics.captureScreenshot("teste.png")
  end
end

-----------------------------------------------------------------------

function love.update(dt)
  if (init and gameover == nil) then
	player1:update(dt)
  player2:update(dt)
    for i = 1,#lisPlataforms do
      if(lisPlataforms[i]:isActive()) then
        lisPlataforms[i]:update()      
      end
    end
  end
end

-----------------------------------------------------------------------

function love.draw()
	local sx = love.graphics.getWidth() / background:getWidth()
	local sy = love.graphics.getHeight() / background:getHeight()
	if gameover == nil then
		love.graphics.draw(background, 0, 0, 0, sx, sy)

		player1:draw()
    player2:draw()
		for i = 1,#lisPlataforms do
			lisPlataforms[i]:draw()
		end
	else
    love.graphics.setFont(gameovertextfont)
    love.graphics.draw(background, 0, 0, 0, sx, sy)
    love.graphics.setColor(255,255,255)
    --love.graphics.setColor(0,0,0)
		love.graphics.print("GAME OVER", love.graphics.getWidth()/6, love.graphics.getHeight()/4, 0, 5, 5)
		love.graphics.print("Player " .. gameover .. " lost", love.graphics.getWidth()/7, love.graphics.getHeight()/2.5, 0, 3, 3)
    love.graphics.print("Press SPACE to start a new game", love.graphics.getWidth()/4, love.graphics.getHeight()/1.2, 0, 1, 1)
    love.graphics.setColor(255,255,255)
    
    if gameover ~= "red" then
      love.graphics.setColor(255,0,0)
    else 
      love.graphics.setColor(0,255,0)
    end
	end
end

-----------------------------------------------------------------------

function wait(segundos, meublip)
    cur = os.clock()
    meublip.sleep = cur+segundos
    coroutine.yield()
end