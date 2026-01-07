--! #textdomain wesnoth-low

local labels = {}
local wml_label = wesnoth.wml_actions.label

local wml_actions = wesnoth.wml_actions
local T = wml.tag
local vars = wml.variables

function wesnoth.wml_actions.shift_labels(cfg)
	for k, v in ipairs(labels) do
		wml_label { x = v.x, y = v.y }
	end
	for k, v in ipairs(labels) do
		v.x = v.x + cfg.x
		v.y = v.y + cfg.y
		wml_label(v)
	end
end

--
-- Overrides of core tags
--

function wesnoth.wml_actions.label(cfg)
	table.insert(labels, cfg.__parsed)
	wml_label(cfg)
end

function wesnoth.wml_actions.replace_map_section(cfg)
	if not cfg.x and not cfg.y then
		return wesnoth.wml_actions.replace_map(cfg)
	end
	local x1,x2 = string.match(cfg.x, "(%d+)-(%d+)")
	local y1,y2 = string.match(cfg.y, "(%d+)-(%d+)")
	local map = cfg.map_data
	x1 = tonumber(x1)
	y1 = tonumber(y1)
	x2 = x2 + 2
	y2 = y2 + 2
	local t = {}
	local y = 1
	for row in string.gmatch(map, "[^\n]+") do
		if y >= y1 and y <= y2 then
			local r = {}
			local x = 1
			for tile in string.gmatch(row, "[^,]+") do
				if x >= x1 and x <= x2 then r[x - x1 + 1] = tile end
				x = x + 1
			end
			t[y - y1 + 1] = table.concat(r, ',')
		end
		y = y + 1
	end
	local new_map = table.concat(t, '\n')
	wesnoth.wml_actions.replace_map { map_data = new_map, expand = true, shrink = true }
end

function alpha_print(text, size, alpha, duration)

    local c = mathx.round(255 * alpha)

    wesnoth.wml_actions.print({
        text = text,
        size = size,
        red = c, green = c, blue = c,
        duration=duration
    })

    wesnoth.interface.delay(20)
end

-- Arguments:
--   text:          Text displayed
--   duration:      Duration of the text after fade-in and before fade-out animations, in milliseconds
function wesnoth.wml_actions.credits_text(cfg)

    local title = cfg.title
    local text = cfg.body
    local duration = cfg.duration
    --local fade_duration = cfg.fade_duration

    if text == nil then
        text = ""
    end

    if title ~= nil then
        text = "<span size='larger' weight='bold'>" .. title .. "</span>\n\n" .. text;
    end

    if duration == nil then
        duration = 5000
    end

    for alpha = 0.0, 1.0, 0.1 do
        alpha_print(text, 24, alpha, 1000)
    end

    alpha_print(text, 24, 1.0, duration)
    wesnoth.interface.delay(duration)

    for alpha = 1.0, 0.0, -0.1 do
        alpha_print(text, 24, alpha, 1000)
    end

    wesnoth.interface.delay(1000)
end