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

function love.load()
  math.randomseed(os.time())
  lisPlataforms = {}
  
  for i = 1, 5 do
    lisPlataforms[i] = newPlataform(i * 100)
  end
end

function love.keypressed(key)
  init = true
end

function love.update (dt)
  if init then
    for i = 1,#lisPlataforms do
      if(lisPlataforms[i]:isActive()) then
        lisPlataforms[i]:update()      
      end
    end
  end
end

function love.draw ()
  for i = 1,#lisPlataforms do
    lisPlataforms[i].draw()
  end
end

function wait(segundos, meublip)
    cur = os.clock()
    meublip.sleep = cur+segundos
    coroutine.yield()

end