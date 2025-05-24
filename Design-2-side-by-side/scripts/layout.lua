-- layout.lua
-- analog-clock-calendar
-- by @wim66
-- v 1 May 23, 2025

local M = {}

local colours = require "colour_schemes"

-- == Colours to choose from (Box & border) == --
-- my_box_colour = colours.box_gray
-- my_border_colour = colours.border_gray
-- blue
-- red
-- orange
-- green
-- purple

-- === Box & Border Colour ===
local my_box_colour = colours.box_gray
local my_border_colour = colours.border_gray

-- === Layout ===

local M = {}
M.boxes_settings = {
    {
        x=2, y=2, w=400, h=200,
      	colour= my_box_colour, linear_gradient= {0,0,0,200},
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
        x=2, y=2, w=400, h=200,
        colour = my_border_colour, linear_gradient={0,0,0,200},
        --the missing corners are repeated
        corners={ {"circle",20}, {"circle",20}, {"circle",20}, {"circle",20}},
        border = 4
        },
}

return M