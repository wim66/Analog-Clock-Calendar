-- layout.lua
-- by @wim66
-- May 17, 2025

-- === Layout ===

local M = {}
M.boxes_settings = {
    {
        x=2, y=2, w=200, h=375,
      	colour={{0,0x858585,1}, {1,0x000000,1}}, linear_gradient= {0,0,0,375},
        corners={ {"circle",20}, {"circle",20}, {"circle",20}, {"circle",20}},
        },

      	{
        x=12, y=12, w=180, h=180, 
      	colour={{0,0x858585,1}, {1,0x000000,1}}, linear_gradient= {180,180,10,10},
      	corners={ {"circle",90} },
        },
        
      	{
        x=22, y=22, w=160, h=160,
      	colour={{0,0x858585,1}, {1,0x000000,1}}, linear_gradient= {20,20,160,160},
      	corners={ {"circle",80} },
        },
        -- border
        {
        x=2, y=2, w=200, h=375,
        colour={{0,0xAAAAAA,1}, {1,0x333333,1}}, linear_gradient={0,0,0,},
        --the missing corners are repeated
        corners={ {"circle",20}, {"circle",20}, {"circle",20}, {"circle",20}},
        border = 4
        },
}

return M