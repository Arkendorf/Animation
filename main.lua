local shader = require "shader"

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  canvas = love.graphics.newCanvas(64, 64)

  pool_img = love.graphics.newImage("pool.png")
  pool_quad = spritesheet(pool_img, 64, 64)
  pool_frame = 1

  back_img = love.graphics.newImage("neddy_blur.png")
  dive_img = love.graphics.newImage("diving.png")

  splash_img = love.graphics.newImage("splash.png")
  splash_quad = spritesheet(splash_img, 48, 48)
  splash_frame = 1

  neddy_pos = 0
  dive_pos = -38

  splash = false

  wait = 1
  step = 1
end

function love.update(dt)
  if wait <= 0 then
    if step == 1 then
      neddy_pos = neddy_pos + dt * 12
      if neddy_pos > 8 then
        step = 2
        wait = 1
      end
    elseif step == 2 then
      neddy_pos = neddy_pos - dt * 60 * 10
      if neddy_pos <-128 then
        step = 3
        wait = 1
      end
    elseif step == 3 then
      dive_pos = dive_pos + dt * 60 * 2
      if dive_pos > 32 then
        step = 4
        wait = 1
      elseif dive_pos > 0 and splash == false then
        splash = true
      end
    end
  else
    wait = wait - dt
  end

  if splash == true then
    splash_frame = splash_frame + dt * 12
    if splash_frame > 12 then
      splash = false
      splash_frame = 1
    end
  end

  pool_frame = pool_frame + dt * 4
  if pool_frame >= 5 then
    pool_frame = 1
  end
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.clear()

  love.graphics.draw(pool_img, pool_quad[math.floor(pool_frame)])
  love.graphics.draw(back_img, 0, neddy_pos)

  shader.cutoff:send("cutoff", 32)
  love.graphics.setShader(shader.cutoff)
  love.graphics.draw(dive_img, 20, dive_pos)
  love.graphics.setShader()

  if splash then
    love.graphics.draw(splash_img, splash_quad[math.floor(splash_frame)], 8, -4)
  end

  love.graphics.setCanvas()
  love.graphics.draw(canvas, 0, 0, 0, 5, 5)
end

spritesheet = function(img, tw, th)
  local quads = {}
  for y = 0, math.ceil(img:getHeight()/th)-1 do
    for x = 0, math.ceil(img:getWidth()/tw)-1 do
      quads[#quads+1] = love.graphics.newQuad(x*tw, y * th, tw, th, img:getDimensions())
    end
  end
  return quads
end
