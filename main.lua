local shader = require "shader"

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  canvas = love.graphics.newCanvas(64, 64)

  pool_img = love.graphics.newImage("pool.png")
  pool_quad = spritesheet(pool_img, 64, 64)

  back_img = love.graphics.newImage("neddy_blur.png")
  back_quad = spritesheet(back_img, 64, 160)
  dive_img = love.graphics.newImage("diving.png")
  dive_quad = spritesheet(dive_img, 24, 42)
  leave_img = love.graphics.newImage("leaving.png")
  leave_quad = spritesheet(leave_img, 16, 16)

  splash_img = love.graphics.newImage("splash.png")
  splash_quad = spritesheet(splash_img, 32, 32)

  ripple_img = love.graphics.newImage("ripple.png")
  ripple_quad = spritesheet(ripple_img, 24, 24)

  wipe_angle = math.pi*3.5

  wait = 1
  step = 1

  total_dt = 0

  palette = 1

  mode = 1 -- what animation to perform

  font_a = 0

  window = {x = 100, y = 0, scale = 5}

  font = love.graphics.newFont(24)
  love.graphics.setFont(font)

  quote = "Here, for the first time in his life, he did not dive but went down the steps into the icy water and swam a hobbled sidestroke that he might have learned as a youth"

  reset()
end

reset = function()
  pool_frame = 1
  splash_frame = 1
  ripple_frame = 1

  neddy_pos = 0
  dive_pos = -42
  leave_pos = 20

  pos_goal = 8

  splash = false
end

function love.update(dt)
  if wait <= 0 then -- pause when told to

    if mode == 1 then -- dive in and emerge animation

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
      elseif step == 4 then -- emerge from water
        leave_pos = leave_pos - dt * 12
        if leave_pos < 4 then
          wait = 1
          step = 5
        end
      elseif step == 5 then -- start transition
        if wipe_angle > math.pi*3.5 then
          wipe_angle = -math.pi/2 -- initiate wipe
        elseif wipe_angle >= math.pi*1.5 and step >= 5 then -- switch time
          step = 1
          wait = 2.5
          palette = palette + 1
          reset()
          if palette > 4 then
            mode = 2
            wait = 4
          end
        end
      end
    elseif mode == 2 then -- walk in and stay animation
      if step == 1 then
         neddy_pos = neddy_pos + dt * 12
         if neddy_pos >= pos_goal then
           step = 2
           pos_goal = pos_goal - 3
         end
       elseif step == 2 then
         neddy_pos = neddy_pos - dt * 8
         if neddy_pos <= pos_goal then
           step = 1
           pos_goal = pos_goal + 9
         end
       end
       if neddy_pos >= 44 then
         mode = 3
       end
    elseif mode == 3 then -- text fades in
      font_a = font_a + dt * 60 * 8
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
    if splash_frame > 13 then
      splash = false
      splash_frame = 1
    end
  end

  pool_frame = pool_frame + dt * 4 -- animate background
  if pool_frame >= 5 then
    pool_frame = 1
  end

  wipe_angle = wipe_angle + dt * 4

  total_dt = total_dt + dt
end

function love.draw()
  love.graphics.setCanvas(canvas)
  love.graphics.clear()

  love.graphics.draw(pool_img, pool_quad[math.floor(pool_frame)+(palette-1)*4]) -- draw background

  love.graphics.draw(back_img, back_quad[palette], 0, neddy_pos) -- draw close up of neddy

  shader.cutoff:send("cutoff", 20) -- draw emerging neddy
  love.graphics.setShader(shader.cutoff)
  love.graphics.draw(leave_img, leave_quad[palette], 24, leave_pos)

  shader.cutoff:send("cutoff", 32) -- draw diving neddy
  love.graphics.setShader(shader.cutoff)
  love.graphics.draw(dive_img, dive_quad[palette], 20, dive_pos)
  love.graphics.setShader()

  if step >= 4 and leave_pos < 12 then -- draw ripple
    love.graphics.draw(ripple_img, ripple_quad[math.floor(ripple_frame)+(palette-1)*6], 20, 4)
  end

  if splash then -- draw splash
    love.graphics.draw(splash_img, splash_quad[math.floor(splash_frame)+(palette-1)*12], 16, 8)
  end

  love.graphics.setColor(0, 0, 0) -- draw transition
  wipe(wipe_angle)
  love.graphics.setColor(255, 255, 255)

  love.graphics.setCanvas()
  love.graphics.draw(canvas, window.x, window.y, 0, window.scale, window.scale)

  love.graphics.setColor(255, 255, 255, font_a)
  love.graphics.printf(quote, window.x+8*window.scale, window.y+10*window.scale, 48*window.scale, "center")
  love.graphics.setColor(255, 255, 255)

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

wipe = function(angle)
  if angle <= math.pi*1.5 then
    love.graphics.arc("fill", 32, 32, 64, -math.pi/2, angle, 10)
  elseif angle <= math.pi*3.5 then
    love.graphics.arc("fill", 32, 32, 64, angle-math.pi*2, math.pi*1.5, 10)
  end
end
