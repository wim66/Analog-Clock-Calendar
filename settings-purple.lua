-- settings.lua
-- analog-clock-calendar
-- by @wim66
-- v1 May 17, 2025

-- Set the path to the scripts folder
package.path = "./scripts/?.lua"

function conky_vars()
  
    -- border_COLOR: Defines the gradient border for the Conky widget.
    -- Format: "start_angle,color1,opacity1,midpoint,color2,opacity2,steps,color3,opacity3"
    -- Example: "0,0x390056,1.00,0.5,0xff007f,1.00,1,0x390056,1.00" creates a purple-pink gradient.
    border_COLOR = "0,0x4a148c,1.00,0.5,0xe1bee7,1.00,1,0x4a148c,1.00"

    -- bg_COLOR: Background color and opacity for the widget.
    -- Format: "color,opacity"
    -- Example: "0x1d1e28,0.75" sets a dark purple background with 75% opacity.
    bg_COLOR = "0x1d1d2e,0.75"

    -- layer_2: Defines the gradient for the second layer of the Conky widget.
    -- Format: "start_angle,color1,opacity1,midpoint,color2,opacity2,steps,color3,opacity3"
    -- Example: "0,0x00007f,0.50,0.5,0x00aaff,0.50,1,0x00007f,0.50" creates a blue gradient with 50% opacity.
    layer_2 = "0,0x4a148c,0.63,0.5,0x4a148c,0.78,1,0x4a148c,0.63"
end