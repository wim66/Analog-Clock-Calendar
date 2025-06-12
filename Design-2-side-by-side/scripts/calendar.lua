-- calendar.lua
-- Draws a monthly calendar with color settings for all elements
-- Version: 1.2 - June 12, 2025
-- Author: Wim66

require("cairo")
local status, cairo_xlib = pcall(require, "cairo_xlib")
if not status then
  cairo_xlib = setmetatable({}, {
    __index = function(_, key)
      return _G[key]
    end,
  })
end

local function hex_to_rgba(hex)
  hex = hex:gsub("#", "")
  local r = tonumber("0x" .. hex:sub(1, 2)) / 255
  local g = tonumber("0x" .. hex:sub(3, 4)) / 255
  local b = tonumber("0x" .. hex:sub(5, 6)) / 255
  return r, g, b, 1
end

function conky_draw_calendar()
  if not conky_window then
    return
  end
  local w = conky_window.width
  local h = conky_window.height
  local surface = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, w, h)
  local cr = cairo_create(surface)

                                                -- === SETTINGS === ---
-- ===================================================================================================================================
    -- Settings (adjust to your preference)
    local font_name = "Ubuntu Mono"
    local font_size = 16
    local day_spacing = 22
    local start_x = 235
    local start_y = 35
    local show_weeknums = true
    local week_starts = "monday" -- monday or sunday
    local language = "english" -- english, dutch, german, spanish, french

    -- Color settings
    local colour_month = "#44AAFF"
    local colour_weekdays = "#ffbf00"
    local colour_weekday_today = "#00FF00"
    local colour_days = "#FFFFFF"
    local colour_today = "#00FF00"
    local colour_outside = "#808080"
    local colour_weeknums = "#44AAFF"
-- ====================================================================================================================================

  draw_calendar(
    cr,
    start_x,
    start_y,
    font_name,
    font_size,
    day_spacing,
    show_weeknums,
    week_starts,
    language,
    colour_month,
    colour_weekdays,
    colour_days,
    colour_today,
    colour_outside,
    colour_weeknums
  )

  cairo_destroy(cr)
  cairo_surface_destroy(surface)
end

function draw_calendar(
  cr,
  x,
  y,
  font,
  size,
  spacing,
  weeknums,
  week_starts,
  language,
  colour_month,
  colour_weekdays,
  colour_days,
  colour_today,
  colour_outside,
  colour_weeknums
)
  draw_month_name(cr, x, y, font, size, colour_month, language)
  y = y + spacing
  draw_weekdays(cr, x, y, font, size, spacing, colour_weekdays, week_starts, language)
  y = y + spacing
  local week_count = draw_days(cr, x, y, font, size, spacing, weeknums, week_starts, colour_days, colour_today, colour_outside)
  if weeknums then
    draw_week_numbers(cr, x, y, font, size, spacing, colour_weeknums, week_starts, language, week_count)
  end
end

function draw_month_name(cr, x, y, font, size, colour, language)
  local translations = {
    english = {
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    },
    dutch = {
      "Januari",
      "Februari",
      "Maart",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Augustus",
      "September",
      "Oktober",
      "November",
      "December",
    },
    german = {
      "Januar",
      "Februar",
      "März",
      "April",
      "Mai",
      "Juni",
      "Juli",
      "August",
      "September",
      "Oktober",
      "November",
      "Dezember",
    },
    spanish = {
      "enero",
      "febrero",
      "marzo",
      "abril",
      "mayo",
      "junio",
      "julio",
      "agosto",
      "septiembre",
      "octubre",
      "noviembre",
      "diciembre",
    },
    french = {
      "janvier",
      "février",
      "mars",
      "avril",
      "mai",
      "juin",
      "juillet",
      "août",
      "septembre",
      "octobre",
      "novembre",
      "décembre",
    },
  }
  local months = translations[language] or translations.english
  local now = os.date("*t")
  local text = months[now.month] .. " " .. now.year

  cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
  cairo_set_font_size(cr, size + 4)
  cairo_set_source_rgba(cr, hex_to_rgba(colour))

  local extents = cairo_text_extents_t:create()
  cairo_text_extents(cr, text, extents)
  cairo_move_to(cr, x - extents.width / 2 + 60, y)
  cairo_show_text(cr, text)
end

function draw_weekdays(cr, x, y, font, size, spacing, colour, week_starts, language)
  local days = {
    english = {
      monday = { "Mo", "Tu", "We", "Th", "Fr", "Sa", "Su" },
      sunday = { "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" },
    },
    dutch = {
      monday = { "ma", "di", "wo", "do", "vr", "za", "zo" },
      sunday = { "zo", "ma", "di", "wo", "do", "vr", "za" },
    },
    -- voeg eventueel meer talen toe
  }

  local weekdays = (days[language] or days.english)[week_starts]
  cairo_set_font_size(cr, size)
  cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
  cairo_set_source_rgba(cr, hex_to_rgba(colour))

  for i = 1, 7 do
    cairo_move_to(cr, x + (i - 1) * spacing, y)
    cairo_show_text(cr, weekdays[i])
  end
end

function draw_days(cr, x, y, font, size, spacing, weeknums, week_starts, colour_days, colour_today, colour_outside)
  local now = os.date("*t")
  local year, month, today = now.year, now.month, now.day
  local first_day = os.time({ year = year, month = month, day = 1 })
  local weekday = tonumber(os.date("%w", first_day)) -- zondag=0

  if week_starts == "monday" then
    if weekday == 0 then
      weekday = 6
    else
      weekday = weekday - 1
    end
  end

  local days_in_month = os.date("*t", os.time({ year = year, month = month + 1, day = 0 })).day
  local prev_month_days = os.date("*t", os.time({ year = year, month = month, day = 0 })).day

  local col, row = 0, 0
  cairo_set_font_size(cr, size)
  cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)

  -- dagen van vorige maand
  for i = weekday, 1, -1 do
    cairo_set_source_rgba(cr, hex_to_rgba(colour_outside))
    cairo_move_to(cr, x + col * spacing, y + row * spacing)
    cairo_show_text(cr, tostring(prev_month_days - i + 1))
    col = col + 1
  end

  -- huidige maand
  for d = 1, days_in_month do
    if col == 7 then
      col = 0
      row = row + 1
    end
    local colour = (d == today) and colour_today or colour_days
    cairo_set_source_rgba(cr, hex_to_rgba(colour))
    cairo_move_to(cr, x + col * spacing, y + row * spacing)
    cairo_show_text(cr, tostring(d))
    col = col + 1
  end

  -- volgende maand
  local d = 1
  while col < 7 do
    cairo_set_source_rgba(cr, hex_to_rgba(colour_outside))
    cairo_move_to(cr, x + col * spacing, y + row * spacing)
    cairo_show_text(cr, tostring(d))
    d = d + 1
    col = col + 1
  end

  return row + 1 -- aantal weken
end

function draw_week_numbers(cr, x, y, font, size, spacing, colour, week_starts, language, week_count)
  local now = os.date("*t")
  local year, month = now.year, now.month
  cairo_set_font_size(cr, size)
  cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
  cairo_set_source_rgba(cr, hex_to_rgba(colour))

  local labels = { english = "wk", dutch = "wk", german = "KW", french = "sm", spanish = "sm" }
  local label = labels[language] or "wk"

  cairo_move_to(cr, x - spacing, y - spacing)
  cairo_show_text(cr, label)

  for row = 0, week_count - 1 do
    local day = 1 + row * 7
    local t = os.time({ year = year, month = month, day = day })
    local wn = week_starts == "monday" and os.date("%V", t) or os.date("%U", t)
    cairo_move_to(cr, x - spacing, y + row * spacing)
    cairo_show_text(cr, wn)
  end
end
