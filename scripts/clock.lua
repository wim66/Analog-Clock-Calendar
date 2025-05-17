clock.lua
-- analog-clock-calendar
-- by @wim66
-- v1 May 17, 2025

-- analog_clock.lua voor Conky: Analoge klok van 180px hoog, gecentreerd, met uur-nummers zonder decimalen en instelbare hexadecimale kleuren
-- Opslaan als ~/.conky/analog_clock.lua of een andere locatie en aanroepen in .conkyrc

-- Functie om hexadecimale kleur naar RGBA te converteren
local function hex_to_rgba(hex, default_alpha)
    hex = hex:gsub("#", "") -- Verwijder # als aanwezig
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    local a = default_alpha or 1 -- Gebruik default_alpha als geen alpha is opgegeven
    if #hex == 8 then
        a = tonumber(hex:sub(7, 8), 16) / 255 -- Ondersteun 8-cijferige hex (RRGGBBAA)
    end
    return r, g, b, a
end

-- Kleurinstellingen (hexadecimale kleuren, bijvoorbeeld #FFFFFF voor wit)
local settings = {
    clock_border_color = {hex = "#4682B4", alpha = 1},   -- Klokrand (Steel Blue)
    clock_border_width = 4,                              -- Dikte van de klokrand (pixels)
    hour_number_color = {hex = "#FFA500", alpha = 1},    -- Uurnummers (Orange)
    hour_mark_color = {hex = "#87CEEB", alpha = 1},    -- Uurmarkeringen (Sky Blue)
    minute_mark_color = {hex = "#B0E0E6", alpha = 1},  -- Minuutindicatoren (Powder Blue)
    hour_hand_color = {hex = "#1E90FF", alpha = 1},      -- Uurwijzer (Dodger Blue)
    minute_hand_color = {hex = "#00CED1", alpha = 1},    -- Minuutwijzer (Dark Turquoise)
    second_hand_color = {hex = "#FF4500", alpha = 1},    -- Secondewijzer (Orange Red)
    center_dot_color = {hex = "#F5F5F5", alpha = 1},     -- Centrumcirkel (White Smoke)
    date_background_color = {hex = "#000000", alpha = 0.7}, -- Datum achtergrond (Zwart, semi-transparant)
    date_y_offset = 35,                                  -- Verticale offset van datum vanaf klokcentrum (in pixels)
    glass_center_color = {hex = "#FFFFFF", alpha = 0.15}, -- Glas-effect centrum (Wit, semi-transparant)
    glass_edge_color = {hex = "#FFFFFF", alpha = 0.1}       -- Glas-effect rand (Volledig transparant)
}

function conky_analog_clock()
    -- Controleer of Conky actief is
    if conky_window == nil then return end

    -- Maak Cairo-surface en context
    local w = conky_window.width
    local h = conky_window.height
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, w, h)
    local cr = cairo_create(cs)

    -- Klokinstellingen
    local clock_size = 180 -- Diameter van de klok (hoogte = 180px)
    local xc = w / 2 -- X-coördinaat centrum (midden van het canvas)
    local yc = h / 2 -- Y-coördinaat centrum (midden van het canvas)
    local yc = 105
    local radius = clock_size / 2

    -- Tijd ophalen
    local secs = os.date("%S")
    local mins = os.date("%M")
    local hours_24 = os.date("%H") -- 24-uurs formaat voor berekeningen

    -- Hoeken berekenen (in radialen)
    local seconds_angle = (secs / 60) * 2 * math.pi
    local minutes_angle = ((mins + secs / 60) / 60) * 2 * math.pi
    local hours_angle = ((hours_24 % 12 + mins / 60) / 12) * 2 * math.pi

    -- Achtergrondcirkel (klokrand)
    local r, g, b, a = hex_to_rgba(settings.clock_border_color.hex, settings.clock_border_color.alpha)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_set_line_width(cr, settings.clock_border_width)
    cairo_arc(cr, xc, yc, radius - settings.clock_border_width / 2, 0, 2 * math.pi)
    cairo_stroke(cr)

    -- Semi-transparante achtergrondcirkel
    r, g, b, a = hex_to_rgba("#000000", 0.2)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_arc(cr, xc, yc, radius - settings.clock_border_width / 2, 0, 2 * math.pi)
    cairo_fill(cr)

    -- Uurmarkeringen (met nummers) en minuutindicatoren
    for i = 1, 60 do
        local angle = (i / 60) * 2 * math.pi
        if i % 5 == 0 then
            -- Uurmarkering (elke 5 minuten, dus 12 uur)
            local hour = math.floor(i / 5) -- Geen decimalen
            local text_radius = radius - 20 -- Positie van de nummers
            local text_x = xc + text_radius * math.sin(angle)
            local text_y = yc - text_radius * math.cos(angle)

            -- Tekst voor uur (1 t/m 12) met schaduw
            r, g, b, a = hex_to_rgba("#000000", 0.5)
            cairo_set_source_rgba(cr, r, g, b, a)
            cairo_select_font_face(cr, "DejaVu Sans", 0, 0)
            cairo_set_font_size(cr, 12)
            cairo_move_to(cr, text_x - 4, text_y + 6)
            cairo_show_text(cr, tostring(hour))
            cairo_stroke(cr)
            r, g, b, a = hex_to_rgba(settings.hour_number_color.hex, settings.hour_number_color.alpha)
            cairo_set_source_rgba(cr, r, g, b, a)
            cairo_move_to(cr, text_x - 5, text_y + 5)
            cairo_show_text(cr, tostring(hour))
            cairo_stroke(cr)

            -- Uurmarkering streep
            local inner_radius = radius - 10
            local outer_radius = radius - 4
            r, g, b, a = hex_to_rgba(settings.hour_mark_color.hex, settings.hour_mark_color.alpha)
            cairo_set_source_rgba(cr, r, g, b, a)
            cairo_set_line_width(cr, 2)
            cairo_move_to(cr, xc + inner_radius * math.sin(angle), yc - inner_radius * math.cos(angle))
            cairo_line_to(cr, xc + outer_radius * math.sin(angle), yc - outer_radius * math.cos(angle))
            cairo_stroke(cr)
        else
            -- Minuutindicator (kleinere streep)
            local inner_radius = radius - 7
            local outer_radius = radius - 4
            r, g, b, a = hex_to_rgba(settings.minute_mark_color.hex, settings.minute_mark_color.alpha)
            cairo_set_source_rgba(cr, r, g, b, a)
            cairo_set_line_width(cr, 1)
            cairo_move_to(cr, xc + inner_radius * math.sin(angle), yc - inner_radius * math.cos(angle))
            cairo_line_to(cr, xc + outer_radius * math.sin(angle), yc - outer_radius * math.cos(angle))
            cairo_stroke(cr)
        end
    end

    -- Datumweergave binnen de klok, gecentreerd met achtergrond
    local date = os.date("%d-%m-%Y")
    cairo_select_font_face(cr, "DejaVu Sans", 0, 0)
    cairo_set_font_size(cr, 10)
    -- Bereken tekstafmetingen voor centrering en achtergrond
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, date, extents)
    local text_width = extents.width
    local text_height = extents.height
    local text_x = xc - text_width / 2 -- Gecentreerde X-positie
    local text_y = yc + settings.date_y_offset -- Instelbare Y-positie
    -- Teken zwarte achtergrondrechthoek
    local padding_x = 4 -- Horizontale padding
    local padding_y = 2 -- Verticale padding
    r, g, b, a = hex_to_rgba(settings.date_background_color.hex, settings.date_background_color.alpha)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_rectangle(cr, text_x - padding_x, text_y - text_height - padding_y, text_width + 2 * padding_x, text_height + 2 * padding_y)
    cairo_fill(cr)
    -- Teken datumtekst
    r, g, b, a = hex_to_rgba(settings.hour_number_color.hex, settings.hour_number_color.alpha)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_move_to(cr, text_x, text_y)
    cairo_show_text(cr, date)
    cairo_stroke(cr)

    -- Uurwijzer met gloed
    r, g, b, a = hex_to_rgba(settings.hour_hand_color.hex, 0.3)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_set_line_width(cr, 6)
    local hour_length = radius * 0.5
    cairo_move_to(cr, xc, yc)
    cairo_line_to(cr, xc + hour_length * math.sin(hours_angle), yc - hour_length * math.cos(hours_angle))
    cairo_stroke(cr)
    r, g, b, a = hex_to_rgba(settings.hour_hand_color.hex, settings.hour_hand_color.alpha)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_set_line_width(cr, 4)
    cairo_move_to(cr, xc, yc)
    cairo_line_to(cr, xc + hour_length * math.sin(hours_angle), yc - hour_length * math.cos(hours_angle))
    cairo_stroke(cr)

    -- Minuutwijzer met gloed
    r, g, b, a = hex_to_rgba(settings.minute_hand_color.hex, 0.3)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_set_line_width(cr, 5)
    local minute_length = radius * 0.7
    cairo_move_to(cr, xc, yc)
    cairo_line_to(cr, xc + minute_length * math.sin(minutes_angle), yc - minute_length * math.cos(minutes_angle))
    cairo_stroke(cr)
    r, g, b, a = hex_to_rgba(settings.minute_hand_color.hex, settings.minute_hand_color.alpha)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_set_line_width(cr, 3)
    cairo_move_to(cr, xc, yc)
    cairo_line_to(cr, xc + minute_length * math.sin(minutes_angle), yc - minute_length * math.cos(minutes_angle))
    cairo_stroke(cr)

    -- Secondewijzer met gloed en contragewicht
    r, g, b, a = hex_to_rgba(settings.second_hand_color.hex, 0.4)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_set_line_width(cr, 3)
    local second_length = radius * 0.9
    cairo_move_to(cr, xc, yc)
    cairo_line_to(cr, xc + second_length * math.sin(seconds_angle), yc - second_length * math.cos(seconds_angle))
    cairo_stroke(cr)
    r, g, b, a = hex_to_rgba(settings.second_hand_color.hex, settings.second_hand_color.alpha)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_set_line_width(cr, 1)
    cairo_move_to(cr, xc, yc)
    cairo_line_to(cr, xc + second_length * math.sin(seconds_angle), yc - second_length * math.cos(seconds_angle))
    local counter_length = radius * 0.2
    cairo_move_to(cr, xc, yc)
    cairo_line_to(cr, xc - counter_length * math.sin(seconds_angle), yc + counter_length * math.cos(seconds_angle))
    cairo_stroke(cr)

    -- Centrumcirkel (klein punt in het midden)
    r, g, b, a = hex_to_rgba(settings.center_dot_color.hex, settings.center_dot_color.alpha)
    cairo_set_source_rgba(cr, r, g, b, a)
    cairo_arc(cr, xc, yc, 3, 0, 2 * math.pi)
    cairo_fill(cr)

    -- Glas-effect met radiale gradiënt (geen highlight)
    local glass_gradient = cairo_pattern_create_radial(xc, yc, 0, xc, yc, radius)
    r, g, b, a = hex_to_rgba(settings.glass_center_color.hex, settings.glass_center_color.alpha)
    cairo_pattern_add_color_stop_rgba(glass_gradient, 0, r, g, b, a)
    r, g, b, a = hex_to_rgba(settings.glass_edge_color.hex, settings.glass_edge_color.alpha)
    cairo_pattern_add_color_stop_rgba(glass_gradient, 1, r, g, b, a)
    cairo_set_source(cr, glass_gradient)
    cairo_arc(cr, xc, yc, radius, 0, 2 * math.pi)
    cairo_fill(cr)
    cairo_pattern_destroy(glass_gradient)

    -- Opruimen
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    return ""
end