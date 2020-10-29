pico-8 cartridge // http://www.pico-8.com
version 19
__lua__

local width = 128
local height = 128
local pi = 3.14159265

local plasma1 = {}
local plasma2 = {}
local palette = {}
local half_pal = 0

function round(n)
  return flr(n + 0.5)
end

function hypot(a, b)
  return sqrt(a*a + b*b)
end

function precalculate(plasma1, w, h)
  for y=0,h do
    for x=0,w do
      plasma1[y*w+x] = sin(hypot(0.5*w - x/2, 0.5*h - y/2) / (2*pi))
      -- plasma2[y*w+x] = sin((x/2) / (2*pi))
    end
  end
end

function _init()
  -- color palette
  palette[0] = 0
  palette[1] = 1
  palette[2] = 2
  palette[3] = 13
  palette[4] = 12
  palette[5] = 14
  palette[6] = 15
  half_pal = 0.5 * (#palette - 1)

  -- plasma lookup tables
  precalculate(plasma1, width*2, height*2)
end

function draw()
  cls()

  local t = time()
  local x1 = 0.5*width + 0.5*width * cos(t/(2*pi))
  local x2 = 0.5*width + 0.5*width * sin(-t/(2*pi))
  local y1 = 0.5*height + 0.5*height * sin(t/(2*pi))
  local y2 = 0.5*height + 0.5*height * cos(-t/(2*pi))
  local i1 = round( y1 * width + x1 )
  local i2 = round( y2 * width + x2 )

  for y=0,height do
    for x=0,width do
      local sin_sum = plamsa1[i1]
      local c = palette[ round(half_pal + half_pal * sin_sum) ]
      pset(x, y, c)

      i1 += 1
      -- if i1 >= #plasma1 then i1 = 0 end
      -- i2 += 1
      -- if i2 >= #plasma2 then i2 = 0 end
    end
  end

  color(8)
  print(stat(7), 100, 10)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
