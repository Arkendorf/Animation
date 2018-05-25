local shader = {}

shader.cutoff = love.graphics.newShader[[
    extern number cutoff;
    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
      vec4 pixel = Texel(texture, texture_coords);
      if(screen_coords.y < cutoff){
        return pixel * color;
      }
      return vec4(0.0, 0.0, 0.0, 0.0);
    }
  ]]

return shader
