pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

-- each char is 4 pixels wide and 6 high

local w = 128
local h = 128
local pi = 3.14159256
local t = 0

-- each elem in positions represents a 'pair' of positions
local positions = {}

-- palettes must be zero based for modulo ops
local palette1 = {}
palette1[0] = 1   -- dark blue
palette1[1] = 5   -- dark grey
palette1[2] = 13  -- indigo
palette1[3] = 12  -- blue

local palette2 = {}
palette2[0] = 9   -- orange
palette2[1] = 10  -- yellow
palette2[2] = 2   -- dark purple
palette2[3] = 8   -- red

local state = ''
local state_update = {}
local state_draw = {}

local text = 'beware the bitwitch. beware the bitwitch.'
local off_text = (#text + 1) * 4

function round(n)
  return flr(0.5 + n)
end

function init_text_positions()
  for i=1,21 do
    positions[i] = {}
    if i % 2 == 0 then
      positions[i][1] = {x=0, y=6*i-3}  
      positions[i][2] = {x=off_text, y=6*i-3}  
    else
      positions[i][1] = {x=-off_text, y=6*i-3}  
      positions[i][2] = {x=0, y=6*i-3}  
    end
  end
end

function u_scroll()
  for i,pos in pairs(positions) do
    -- evens
    if i % 2 == 0 then
      pos[1].x -= 1
      pos[2].x -= 1
      if pos[2].x <= 0 then
        local tmp = pos[1]
        pos[1] = pos[2]
        pos[2] = tmp
        pos[2].x = pos[1].x + off_text
      end
    -- odds
    else
      pos[1].x += 1
      pos[2].x += 1
      if pos[2].x >= w then
        local tmp = pos[1]
        pos[1] = pos[2]
        pos[2] = tmp
        pos[1].x = pos[2].x - off_text
      end
    end
  end
end

function u_scroll_end()
  for i,pos in pairs(positions) do
    if i % 2 == 0 then
      pos[1].x -= 1
      pos[2].x -= 1
    else
      pos[1].x += 1
      pos[2].x += 1
    end
  end
end

function d_scroll()
  local i_color = round(time()) % 4
  local c1 = palette1[i_color]
  local c2 = palette2[i_color]

  for i,pos in pairs(positions) do
    local c
    if i % 2 == 0 then c=c1 else c=c2 end
    print(text, round(pos[1].x), round(pos[1].y), c)  
    print(text, round(pos[2].x), round(pos[2].y), c)  
  end
end

function _init()
  init_text_positions()

  state = 'scroll'
  state_update['scroll'] = u_scroll
  state_update['scroll_end'] = u_scroll_end
  state_draw['scroll'] = d_scroll
  state_draw['scroll_end'] = d_scroll
end

function _update()
--  if time() <= 5 then
--    state = 'scroll'
--  elseif time() > 5 then
--    state = 'scroll_end'
--  end
  state="scroll"
  state_update[state]()
end

function _draw()
  cls()
  state_draw[state]()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
