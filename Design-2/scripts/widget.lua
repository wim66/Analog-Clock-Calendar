-- widget.lua
-- analog-clock-calendar
-- by @wim66
-- v1 May 17, 2025

-- === Required Cairo Modules ===
require("cairo")
-- Attempt to safely require the 'cairo_xlib' module
local status, cairo_xlib = pcall(require, "cairo_xlib")

if not status then
	-- If not found, fall back to a dummy table
	-- Redirects unknown keys to the global namespace (_G)
	-- Allows use of global Cairo functions like cairo_xlib_surface_create
	cairo_xlib = setmetatable({}, {
		__index = function(_, key)
			return _G[key]
		end,
	})
end

package.path = "./scripts/?.lua"

-- Load calendar.lua (as module)
local ok, err = pcall(require, "calendar")
if not ok then
	print("Error loading calendar.lua: " .. err)
end

-- Load clock.lua (as module)
local ok, err = pcall(require, "clock")
if not ok then
	print("Error loading clock.lua: " .. err)
end

function conky_main_box()
	if conky_window == nil then
		return
	end

	local layout = require("layout")
	local boxes_settings = layout.boxes_settings

	local cs =
		cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	local cr = cairo_create(cs)

	if tonumber(conky_parse("$updates")) < 5 then
		return
	end
	for i in pairs(boxes_settings) do
		draw_box(cr, boxes_settings[i])
	end
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end

function draw_box(cr, t)
	if t.draw_me == true then
		t.draw_me = nil
	end
	if t.draw_me ~= nil and conky_parse(tostring(t.draw_me)) ~= "1" then
		return
	end

	local table_corners = { "circle", "curve", "line" }

	local t_operators = {
		clear = CAIRO_OPERATOR_CLEAR,
		source = CAIRO_OPERATOR_SOURCE,
		over = CAIRO_OPERATOR_OVER,
		["in"] = CAIRO_OPERATOR_IN,
		out = CAIRO_OPERATOR_OUT,
		atop = CAIRO_OPERATOR_ATOP,
		dest = CAIRO_OPERATOR_DEST,
		dest_over = CAIRO_OPERATOR_DEST_OVER,
		dest_in = CAIRO_OPERATOR_DEST_IN,
		dest_out = CAIRO_OPERATOR_DEST_OUT,
		dest_atop = CAIRO_OPERATOR_DEST_ATOP,
		xor = CAIRO_OPERATOR_XOR,
		add = CAIRO_OPERATOR_ADD,
		saturate = CAIRO_OPERATOR_SATURATE,
	}

	function rgba_to_r_g_b_a(tc)
		--tc={position,colour,alpha}
		local colour = tc[2]
		local alpha = tc[3]
		return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
	end

	function table.copy(t)
		local t2 = {}
		for k, v in pairs(t) do
			t2[k] = { v[1], v[2] }
		end
		return t2
	end

	function draw_corner(num, t)
		local shape = t[1]
		local radius = t[2]
		local x, y = t[3], t[4]
		if shape == "line" then
			if num == 1 then
				cairo_line_to(cr, radius, 0)
			elseif num == 2 then
				cairo_line_to(cr, x, radius)
			elseif num == 3 then
				cairo_line_to(cr, x - radius, y)
			elseif num == 4 then
				cairo_line_to(cr, 0, y - radius)
			end
		end
		if shape == "circle" then
			local PI = math.pi
			if num == 1 then
				cairo_arc(cr, radius, radius, radius, -PI, -PI / 2)
			elseif num == 2 then
				cairo_arc(cr, x - radius, y + radius, radius, -PI / 2, 0)
			elseif num == 3 then
				cairo_arc(cr, x - radius, y - radius, radius, 0, PI / 2)
			elseif num == 4 then
				cairo_arc(cr, radius, y - radius, radius, PI / 2, -PI)
			end
		end
		if shape == "curve" then
			if num == 1 then
				cairo_curve_to(cr, 0, radius, 0, 0, radius, 0)
			elseif num == 2 then
				cairo_curve_to(cr, x - radius, 0, x, y, x, radius)
			elseif num == 3 then
				cairo_curve_to(cr, x, y - radius, x, y, x - radius, y)
			elseif num == 4 then
				cairo_curve_to(cr, radius, y, x, y, 0, y - radius)
			end
		end
	end

	--check values and set default values
	if t.x == nil then
		t.x = 0
	end
	if t.y == nil then
		t.y = 0
	end
	if t.w == nil then
		t.w = conky_window.width
	end
	if t.h == nil then
		t.h = conky_window.height
	end
	if t.radius == nil then
		t.radius = 0
	end
	if t.border == nil then
		t.border = 0
	end
	if t.colour == nil then
		t.colour = { { 1, 0xFFFFFF, 0.5 } }
	end
	if t.linear_gradient ~= nil then
		if #t.linear_gradient ~= 4 then
			t.linear_gradient = { t.x, t.y, t.width, t.height }
		end
	end
	if t.angle == nil then
		t.angle = 0
	end

	if t.skew_x == nil then
		t.skew_x = 0
	end
	if t.skew_y == nil then
		t.skew_y = 0
	end
	if t.scale_x == nil then
		t.scale_x = 1
	end
	if t.scale_y == nil then
		t.scale_y = 1
	end
	if t.rot_x == nil then
		t.rot_x = 0
	end
	if t.rot_y == nil then
		t.rot_y = 0
	end

	if t.operator == nil then
		t.operator = "over"
	end
	if t_operators[t.operator] == nil then
		print("wrong operator :", t.operator)
		t.operator = "over"
	end

	if t.radial_gradient ~= nil then
		if #t.radial_gradient ~= 6 then
			t.radial_gradient = { t.x, t.y, 0, t.x, t.y, t.width }
		end
	end

	for i = 1, #t.colour do
		if #t.colour[i] ~= 3 then
			print("error in color table")
			t.colour[i] = { 1, 0xFFFFFF, 1 }
		end
	end

	if t.corners == nil then
		t.corners = { { "line", 0 } }
	end
	local t_corners = {}
	local t_corners = table.copy(t.corners)
	--don't use t_corners=t.corners otherwise t.corners is altered

	--complete the t_corners table if needed
	for i = #t_corners + 1, 4 do
		t_corners[i] = t_corners[#t_corners]
		local flag = false
		for j, v in pairs(table_corners) do
			flag = flag or (t_corners[i][1] == v)
		end
		if not flag then
			print("error in corners table :", t_corners[i][1])
			t_corners[i][1] = "curve"
		end
	end

	--this way :
	--    t_corners[1][4]=x
	--    t_corners[2][3]=y
	--doesn't work
	t_corners[1] = { t_corners[1][1], t_corners[1][2], 0, 0 }
	t_corners[2] = { t_corners[2][1], t_corners[2][2], t.w, 0 }
	t_corners[3] = { t_corners[3][1], t_corners[3][2], t.w, t.h }
	t_corners[4] = { t_corners[4][1], t_corners[4][2], 0, t.h }

	t.no_gradient = (t.linear_gradient == nil) and (t.radial_gradient == nil)

	cairo_save(cr)
	cairo_translate(cr, t.x, t.y)
	if t.rot_x ~= 0 or t.rot_y ~= 0 or t.angle ~= 0 then
		cairo_translate(cr, t.rot_x, t.rot_y)
		cairo_rotate(cr, t.angle * math.pi / 180)
		cairo_translate(cr, -t.rot_x, -t.rot_y)
	end
	if t.scale_x ~= 1 or t.scale_y ~= 1 or t.skew_x ~= 0 or t.skew_y ~= 0 then
		local matrix0 = cairo_matrix_t:create()
		tolua.takeownership(matrix0)
		cairo_matrix_init(matrix0, t.scale_x, math.pi * t.skew_y / 180, math.pi * t.skew_x / 180, t.scale_y, 0, 0)
		cairo_transform(cr, matrix0)
	end

	local tc = t_corners
	cairo_move_to(cr, tc[1][2], 0)
	cairo_line_to(cr, t.w - tc[2][2], 0)
	draw_corner(2, tc[2])
	cairo_line_to(cr, t.w, t.h - tc[3][2])
	draw_corner(3, tc[3])
	cairo_line_to(cr, tc[4][2], t.h)
	draw_corner(4, tc[4])
	cairo_line_to(cr, 0, tc[1][2])
	draw_corner(1, tc[1])

	if t.no_gradient then
		cairo_set_source_rgba(cr, rgba_to_r_g_b_a(t.colour[1]))
	else
		if t.linear_gradient ~= nil then
			pat = cairo_pattern_create_linear(t.linear_gradient[1], t.linear_gradient[2], t.linear_gradient[3], t.linear_gradient[4])
		elseif t.radial_gradient ~= nil then
			pat = cairo_pattern_create_radial(
				t.radial_gradient[1],
				t.radial_gradient[2],
				t.radial_gradient[3],
				t.radial_gradient[4],
				t.radial_gradient[5],
				t.radial_gradient[6]
			)
		end
		for i = 1, #t.colour do
			cairo_pattern_add_color_stop_rgba(pat, t.colour[i][1], rgba_to_r_g_b_a(t.colour[i]))
		end
		cairo_set_source(cr, pat)
		cairo_pattern_destroy(pat)
	end

	cairo_set_operator(cr, t_operators[t.operator])

	if t.border > 0 then
		cairo_close_path(cr)
		if t.dash ~= nil then
			cairo_set_dash(cr, t.dash, 1, 0.0)
		end
		cairo_set_line_width(cr, t.border)
		cairo_stroke(cr)
	else
		cairo_fill(cr)
	end

	cairo_restore(cr)
end

function conky_main()
	conky_main_box()
	conky_analog_clock()
	conky_draw_calendar()
end
