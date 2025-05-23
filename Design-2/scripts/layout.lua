-- layout.lua
-- analog-clock-calendar
-- by @wim66
-- v 1 May 23, 2025

local M = {}

-- === Colour-parsers ===
local function parse_color_gradient(str, default)
    local gradient = {}
    for position, color, alpha in str:gmatch("([%d%.]+),0x(%x+),([%d%.]+)") do
        table.insert(gradient, {tonumber(position), tonumber(color, 16), tonumber(alpha)})
    end
    return #gradient == 3 and gradient or default
end
local colours = require "colour_schemes"

-- == Colours to choose from (Border only) == --
-- my_border_colour = colours.wim66_green          💚
-- my_border_colour = colours.crimson_flame        🔴
-- my_border_colour = colours.ocean_deep           🔵
-- my_border_colour = colours.emerald_glow         🟢
-- my_border_colour = colours.mystic_twilight      🌌
-- my_border_colour = colours.solar_ember          🟠
-- my_border_colour = colours.rainbow              🌈

-- == Colours to choose from (Box & border) == --
-- my_box_colour = colours.box_gray
-- my_border_colour = colours.border_gray

-- my_box_colour = colours.box_blue
-- my_border_colour = colours.border_blue

-- === Box & Border Colour ===
local my_box_colour = colours.box_blue
local my_border_colour = colours.border_blue

-- === Layout ===

local M = {}
M.boxes_settings = {
    {
        x=2, y=2, w=200, h=375,
      	colour= my_box_colour, linear_gradient= {0,0,0,375},
        corners={ {"circle",20}, {"circle",20}, {"circle",20}, {"circle",20}},
        },

      	{
        x=12, y=12, w=180, h=180, 
      	colour= my_box_colour, linear_gradient= {180,180,10,10},
      	corners={ {"circle",90} },
        },
        
      	{
        x=22, y=22, w=160, h=160,
      	colour= my_box_colour, linear_gradient= {20,20,160,160},
      	corners={ {"circle",80} },
        },
        -- border
        {
        x=2, y=2, w=200, h=375,
        colour = my_border_colour, linear_gradient={0,0,0,375},
        --the missing corners are repeated
        corners={ {"circle",20}, {"circle",20}, {"circle",20}, {"circle",20}},
        border = 4
        },
}

return M