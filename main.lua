local shader = require "shader"

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  canvas = love.graphics.newCanvas(64, 64)

  pool_img = love.graphics.newImage("pool.png")
  pool_quad = spritesheet(pool_img, 64, 64)
  pool_frame = 1

  back_img = love.graphics.newImage("neddy_blur.png")
  dive_img = love.graphics.newImage("diving.png")
  leave_img = love.graphics.newImage("leaving.png")

  splash_img = love.graphics.newImage("splash.png")
  splash_quad = spritesheet(splash_img, 32, 32)
  splash_frame = 1

  ripple_img = love.graphics.newImage("ripple.png")
  ripple_quad = spritesheet(ripple_img, 24, 24)
  ripple_frame = 1

  neddy_pos = 0
  dive_pos = -38
  leave_pos = 20

  splash = false

  wait = 1
  step = 1

  total_dt = 0
end

function love.update(dt)
  if wait <= 0 then
    if step == 1 then -- bend knees before jump
      neddy_pos = neddy_pos + dt * 12
      if neddy_pos > 8 then
        step = 2
        wait = 1
      end
    elseif step == 2 then -- jump from foreground
      neddy_pos = neddy_pos - dt * 60 * 10
      if neddy_pos <-160 then
        step = 3
        wait = 1
      end
    elseif step == 3 then -- land in water
      dive_pos = dive_pos + dt * 60 * 2
      if dive_pos > 32 then
        step = 4
        wait = 2
      elseif dive_pos > 0 and splash == false then
        splash = true
      end
    elseif step == 4 then
      leave_pos = leave_pos - dt * 12
      if leave_pos < 4 then
        step = 5
        wait = 1
      end
    end
  else
    wait = wait - dt
  end

  if step >= 4 and leave_pos < 12 then -- animate ripple
    ripple_frame = ripple_frame + dt * 8
    if ripple_frame > 7 then
      ripple_frame = 1
    end
  end

  if splash == true then -- animate splash
    splash_frame = splash_frame + dt * 12
    if splash_frame > 12 then
      splash = false
      splash_frame = 1
    end
  end

  pool_frame = pool_frame + dt * 4 -- animate background
  if pool_frame >= 5 then
    pool_frame = 1
  end

  total_dt = total_dt + dt
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.clear()

  love.graphics.draw(pool_img, pool_quad[math.floor(pool_frame)])
  love.graphics.draw(back_img, 0, neddy_pos)

  shader.cutoff:send("cutoff", 20)
  love.graphics.setShader(shader.cutoff)
  love.graphics.draw(leave_img, 24, leave_pos)

  shader.cutoff:send("cutoff", 32)
  love.graphics.setShader(shader.cutoff)
  love.graphics.draw(dive_img, 20, dive_pos)
  love.graphics.setShader()

  if step >= 4 and leave_pos < 12 then
    love.graphics.draw(ripple_img, ripple_quad[math.floor(ripple_frame)], 20, 4)
  end

  if splash then
    love.graphics.draw(splash_img, splash_quad[math.floor(splash_frame)], 16, 8)
  end

  love.graphics.setCanvas()
  love.graphics.draw(canvas, 100, 0, 0, 5, 5)

  love.graphics.print(math.floor(total_dt*100)/100)
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
