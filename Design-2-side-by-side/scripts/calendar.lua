-- calendar.lua
-- Draws a monthly calendar with color settings for all elements
-- Version: 1.2 - May 6, 2025
-- Author: Wim66

require 'cairo'
-- Attempt to safely require the 'cairo_xlib' module
local status, cairo_xlib = pcall(require, 'cairo_xlib')

if not status then
    -- If not found, fall back to a dummy table
    -- Redirects unknown keys to the global namespace (_G)
    -- Allows use of global Cairo functions like cairo_xlib_surface_create
    cairo_xlib = setmetatable({}, {
        __index = function(_, key) return _G[key] end
    })
end

-- Helper function: hex to rgba
local function hex_to_rgba(hex)
    hex = hex:gsub("#","")
    local r = tonumber("0x"..hex:sub(1,2)) / 255
    local g = tonumber("0x"..hex:sub(3,4)) / 255
    local b = tonumber("0x"..hex:sub(5,6)) / 255
    return r, g, b, 1
end

-- Main function
function conky_draw_calendar()
    if not conky_window then return end

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
    local start_y = 40
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
    draw_calendar(cr, start_x, start_y, font_name, font_size, day_spacing, show_weeknums, week_starts, language,
        colour_month, colour_weekdays, colour_weekday_today, colour_days, colour_today, colour_outside, colour_weeknums)

    cairo_destroy(cr)
    cairo_surface_destroy(surface)
end

-- Draw the calendar
function draw_calendar(cr, x, y, font, size, spacing, weeknums, week_starts, language,
    colour_month, colour_weekdays, colour_weekday_today, colour_days, colour_today, colour_outside, colour_weeknums)

    -- Draw month name
    draw_month_name(cr, x, y, font, size, colour_month, language)

    -- Draw weekdays
    y = y + spacing
    draw_weekdays(cr, x, y, font, size, spacing, colour_weekdays, colour_weekday_today, week_starts, language)

    -- Draw days
    y = y + spacing
    draw_days(cr, x, y, font, size, spacing, weeknums, week_starts, colour_days, colour_today, colour_outside)

    -- Draw week numbers
    if weeknums then
        draw_week_numbers(cr, x, y, font, size, spacing, colour_weeknums, week_starts, language)
    end
end

-- Draws the month name
function draw_month_name(cr, x, y, font, size, colour, language)
    local translations = {
        english = { months = {"January","February","March","April","May","June","July","August","September","October","November","December"} },
        dutch   = { months = {"Januari","Februari","Maart","April","Mei","Juni","Juli","Augustus","September","Oktober","November","December"} },
        german  = { months = {"Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"} },
        spanish = { months = {"enero","febrero","marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre"} },
        french  = { months = {"janvier","février","mars","avril","mai","juin","juillet","août","septembre","octobre","novembre","décembre"} }
    }

    local month_names = translations[language] and translations[language].months or translations.english.months
    local now = os.date("*t")
    local month_text = month_names[now.month] .. " " .. now.year

    cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    cairo_set_font_size(cr, size + 4)
    cairo_set_source_rgba(cr, hex_to_rgba(colour))
    local extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, month_text, extents)
    cairo_move_to(cr, x - extents.width / 2 + 60, y)
    cairo_show_text(cr, month_text)
end

-- Draws the abbreviations of the weekdays
function draw_weekdays(cr, x, y, font, size, spacing, colour, colour_today, week_starts, language)
    local translations = {
        english = { monday = {"Mo","Tu","We","Th","Fr","Sa","Su"}, sunday = {"Su","Mo","Tu","We","Th","Fr","Sa"} },
        dutch   = { monday = {"ma","di","wo","do","vr","za","zo"}, sunday = {"zo","ma","di","wo","do","vr","za"} },
        german  = { monday = {"Mo","Di","Mi","Do","Fr","Sa","So"}, sunday = {"So","Mo","Di","Mi","Do","Fr","Sa"} },
        spanish = { monday = {"lu","ma","mi","ju","vi","sá","do"}, sunday = {"do","lu","ma","mi","ju","vi","sá"} },
        french  = { monday = {"lu","ma","me","je","ve","sa","di"}, sunday = {"di","lu","ma","me","je","ve","sa"} }
    }

    local names = translations[language] and translations[language][week_starts] or translations.english[week_starts]
    local today_weekday = tonumber(os.date("%w")) -- 0 = Sunday

    if week_starts == "monday" then
        today_weekday = today_weekday == 0 and 6 or today_weekday - 1
    end

    cairo_set_font_size(cr, size)
    cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)

    for i = 0, 6 do
        local label = names[i+1]
        if i == today_weekday then
            cairo_set_source_rgba(cr, hex_to_rgba(colour_today))
        else
            cairo_set_source_rgba(cr, hex_to_rgba(colour))
        end
        cairo_move_to(cr, x + i*spacing, y)
        cairo_show_text(cr, label)
    end
end



-- Draws the week numbers
function draw_week_numbers(cr, x, y, font, size, spacing, colour, week_starts, language)
    cairo_set_font_size(cr, size)
    cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_source_rgba(cr, hex_to_rgba(colour))

    local now = os.date("*t")
    local first_day = os.time{year=now.year, month=now.month, day=1}
    local start_day = tonumber(os.date("%w", first_day))
    if week_starts == "monday" then
        start_day = start_day == 0 and 6 or start_day - 1
    end

    local week_row = 0
    local week_start = os.time{year=now.year, month=now.month, day=1 - start_day}
    for i = 0, 5 do
        local week_num = tonumber(os.date("%V", week_start + i*7*24*3600))
        cairo_move_to(cr, x, y + i * spacing)
        cairo_show_text(cr, tostring(week_num))
    end
end

-- Draws the days of the month
function draw_days(cr, x, y, font, size, spacing, weeknums, week_starts,
    colour_days, colour_today, colour_outside)
    -- Calculate days and positions
    local now = os.date("*t")
    local year, month, day = now.year, now.month, now.day
    local first_day = os.time{year=year, month=month, day=1}
    local start_weekday = tonumber(os.date("%w", first_day)) -- 0=Sunday

    if week_starts == "monday" then
        if start_weekday == 0 then start_weekday = 7 end
        start_weekday = start_weekday - 1
    end

    local days_in_month = os.date("*t", os.time{year=year, month=month+1, day=0}).day

    -- Draw previous month's days
    local prev_month = month - 1
    local prev_year = year
    if prev_month < 1 then
        prev_month = 12
        prev_year = year - 1
    end
    local days_in_prev = os.date("*t", os.time{year=prev_year, month=prev_month+1, day=0}).day

    local line = 0
    local col = 1
    for i = 1, start_weekday do
        local d = days_in_prev - start_weekday + i
        cairo_set_source_rgba(cr, hex_to_rgba(colour_outside))
        cairo_move_to(cr, x + (col-1)*spacing, y + line*spacing)
        cairo_show_text(cr, tostring(d))
        col = col + 1
    end

    -- Draw current month's days
    for d = 1, days_in_month do
        if col > 7 then
            col = 1
            line = line + 1
        end
        if d == day then
            cairo_set_source_rgba(cr, hex_to_rgba(colour_today))
        else
            cairo_set_source_rgba(cr, hex_to_rgba(colour_days))
        end
        cairo_move_to(cr, x + (col-1)*spacing, y + line*spacing)
        cairo_show_text(cr, tostring(d))
        col = col + 1
    end

    -- Draw next month's days
    local next_day = 1
    while col <= 7 do
        cairo_set_source_rgba(cr, hex_to_rgba(colour_outside))
        cairo_move_to(cr, x + (col-1)*spacing, y + line*spacing)
        cairo_show_text(cr, tostring(next_day))
        col = col + 1
        next_day = next_day + 1
    end
end

function draw_week_numbers(cr, x, y, font, size, spacing, colour, week_starts, language)
    local now = os.date("*t")
    local year, month = now.year, now.month
    local first_day = os.time{year=year, month=month, day=1}
    local start_weekday = tonumber(os.date("%w", first_day)) -- 0=Sunday

    if week_starts == "monday" then
        if start_weekday == 0 then start_weekday = 7 end
        start_weekday = start_weekday - 1
    end

    -- Week label translations
    local week_label_translations = {
        english = "wk",
        dutch = "wk",
        german = "Wo",
        spanish = "sm",
        french = "sm"
    }
    local week_label = week_label_translations[language] or "wk"

    -- Function to calculate week number for Sunday-based weeks
    local function get_sunday_week_number(year, month, day)
        local date = os.time{year=year, month=month, day=day}
        local year_start = os.time{year=year, month=1, day=1}
        local year_start_weekday = tonumber(os.date("%w", year_start)) -- 0=Sunday
        local days_since_year_start = math.floor((date - year_start) / (24 * 3600))
        local week_offset = (year_start_weekday == 0 and 0 or 7 - year_start_weekday)
        local week_number = math.floor((days_since_year_start + week_offset) / 7) + 1
        return week_number
    end

    cairo_set_source_rgba(cr, hex_to_rgba(colour))
    local week_x = x - spacing

    -- Draw week label
    cairo_set_font_size(cr, size)
    cairo_move_to(cr, week_x, y - spacing)
    cairo_show_text(cr, week_label)

    -- Adjust start day to align with the first week of the month
    local first_week_day = 1 - start_weekday -- Start at the first Sunday before or on day 1
    for l = 0, 4 do
        local d = first_week_day + l * 7
        -- Use a valid day in the week for week number calculation (e.g., day 1 or later)
        local calc_day = math.max(1, d)
        local time = os.time{year=year, month=month, day=calc_day}
        local wn
        if week_starts == "monday" then
            wn = os.date("%V", time) -- ISO 8601 (Monday-based)
        else
            wn = get_sunday_week_number(year, month, calc_day) -- Sunday-based
        end
        -- Debug output
        -- print(string.format("Debug: Week row %d, start day %d, calc day %d, week number %s", l, d, calc_day, wn))
        cairo_move_to(cr, week_x, y + l*spacing)
        cairo_show_text(cr, tostring(wn))
    end
end