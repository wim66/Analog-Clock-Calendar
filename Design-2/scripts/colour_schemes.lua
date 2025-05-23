-- colour_schemes.lua
-- analog-clock-calendar
-- by @wim66
-- v 1 May 23, 2025
-- Gradient colour schemes for Conky boxes

return {

  border_gray = {
    {0,0xAAAAAA,1},
    {1,0x333333,1},
  },
  box_gray = {
    {0,0x858585,1},
    {1,0x000000,1},
  },

  border_blue = {
    {0,0x4242e6,1},
    {1,0x252580,1}
  },
  box_blue = {
    {0,0x36366b,1}, 
    {1,0x0b0b26,1}
  },

-------------------------------- Border only -------------------------------

  wim66_green = {
    {0.00, 0x003e00, 1},
    {0.50, 0x03f404, 1},
    {1.00, 0x003e00, 1},
  },

    -- 🔴 “Crimson Flame”
  crimson_flame = {
    {0.00, 0x8B0000, 1},  -- Dark red (crimson)
    {0.25, 0xE53935, 1},  -- Intense red
    {0.50, 0xFFCDD2, 1},  -- Light pink highlight
    {0.75, 0xE53935, 1},
    {1.00, 0x8B0000, 1},
  },
    -- 🔵 “Ocean Deep”
  ocean_deep = {
    {0.00, 0x0D47A1, 1},  -- Navy blue
    {0.25, 0x42A5F5, 1},  -- Bright blue
    {0.50, 0xBBDEFB, 1},  -- Light blue highlight
    {0.75, 0x42A5F5, 1},
    {1.00, 0x0D47A1, 1},
  },
    -- 🟢 “Emerald Glow”
  emerald_glow = {
    {0.00, 0x004D40, 1},  -- Dark emerald
    {0.25, 0x26A69A, 1},  -- Fresh green
    {0.50, 0xB2DFDB, 1},  -- Mint highlight
    {0.75, 0x26A69A, 1},
    {1.00, 0x004D40, 1},
  },
    -- 🌌 “Mystic Twilight”
  mystic_twilight = {
    {0.00, 0x4A148C, 1},  -- Deep purple
    {0.25, 0xAB47BC, 1},  -- Lavender
    {0.50, 0xE1BEE7, 1},  -- Light lavender highlight
    {0.75, 0xAB47BC, 1},
    {1.00, 0x4A148C, 1},
  },
  -- 🟠 “Solar Ember”
  solar_ember = {
    {0.00, 0xD94F00, 1},  -- Deep orange
    {0.25, 0xFFA726, 1},  -- Warm orange
    {0.50, 0xFFF3B0, 1},  -- Golden yellow highlight
    {0.75, 0xFFA726, 1},
    {1.00, 0xD94F00, 1},
  },
  -- 🌈 "Rainbow"
  rainbow = {
    {0.00, 0xFF0000, 1},  -- red
    {0.15, 0xff981d, 1},  -- orange
    {0.40, 0xFFFF00, 1},  -- yellow
    {0.60, 0x00FF00, 1},  -- green
    {0.75, 0x0000FF, 1},  -- blue
    {1.00, 0x922DF2, 1},  -- violet
  },
}
