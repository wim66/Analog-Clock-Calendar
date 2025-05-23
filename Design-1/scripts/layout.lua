-- layout.lua
-- by @wim66
-- May 17, 2025

-- Defines the box-layout for background, layer2, and border

-- Ensure settings.lua is already loaded before this module
local M = {}

-- === Color parsers ===
local function parse_color_gradient(str, default)
    local gradient = {}
    for position, color, alpha in str:gmatch("([%d%.]+),0x(%x+),([%d%.]+)") do
        table.insert(gradient, {tonumber(position), tonumber(color, 16), tonumber(alpha)})
    end
    return #gradient == 3 and gradient or default
end

local function parse_solid_color(str, default)
    local hex, alpha = str:match("0x(%x+),([%d%.]+)")
    if hex and alpha then
        return { {1, tonumber(hex, 16), tonumber(alpha)} }
    end
    return default
end

-- === Defaults ===
local DEFAULT_BORDER_COLOR = { {0, 0x003E00, 1}, {0.5, 0x03F404, 1}, {1, 0x003E00, 1} }
local DEFAULT_BG_COLOR     = { {1, 0x000000, 0.5} }
local DEFAULT_LAYER2_COLOR = { {0, 0x55007f, 0.5}, {0.5, 0xff69ff, 0.5}, {1, 0x55007f, 0.5} }

-- === Reading from settings.lua ===
local border_color  = parse_color_gradient(border_COLOR or "", DEFAULT_BORDER_COLOR)
local bg_color      = parse_solid_color(bg_COLOR or "", DEFAULT_BG_COLOR)
local layer2_color  = parse_color_gradient(layer_2 or "", DEFAULT_LAYER2_COLOR)

-- === Layout ===
M.boxes_settings = {
    {
        type = "background",
        x = 0, y = 0, w = 206, h = 375,
        centre_x = true,
        corners = {20, 20, 20, 20},
        rotation = 0,
        draw_me = true,
        colour = bg_color
    },
    {
        type = "layer2",
        x = 0, y = 0, w = 206, h = 375,
        centre_x = true,
        corners = {20, 20, 20, 20},
        rotation = 0,
        draw_me = true,
        linear_gradient = {0, 0, 0, 375},
        colours = layer2_color, -- Dynamisch ingesteld vanuit settings.lua
    },
    {
        type = "border",
        x = 0, y = 0, w = 206, h = 375,
        centre_x = true,
        corners = {20, 20, 20, 20},
        rotation = 0,
        draw_me = true,
        border = 4,
        colour = border_color,
        linear_gradient = {0, 0, 0, 375},
    },
}

return M