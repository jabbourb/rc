-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

beautiful.init("/home/bassam/.config/awesome/themes/myzenburn/theme.lua")


-- === Parameters =============================================================================={{{1

terminal = "sakura"
editor = "gvim"
browser = "uzbl-browser"
modkey = "Mod4"


-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
	awful.layout.suit.max,
	awful.layout.suit.tile,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.floating,
}


-- === Tags ===================================================================================={{{1
tags = {}
for s = 1, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = awful.tag({ 1, 2, 3, 4 }, s, layouts[1])
end

-- Adjust the layout on the last tag of screen 1 for UzblWget rule
awful.layout.set (awful.layout.suit.fair.horizontal, tags[1][4])


-- === Menu ===================================================================================={{{1

mymainmenu = awful.menu({ items = {
	{ "edit config", editor .. " " .. awful.util.getdir("config") .. "/rc.lua" },
	{ "restart", awesome.restart },
	{ "quit", awesome.quit },
	{ "-----------", "" },
	{ "open terminal", terminal }
}})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon), menu = mymainmenu })



-- === Hooks ==================================================================================={{{1

-- --- Mail ------------------------------------------------------------------------------------{{{2
mailTimer = timer({ timeout = 60 })
mailTimer:add_signal("timeout", function() awful.util.spawn("/usr/local/bin/newmail.sh") end)
mailTimer:start()


-- --- Battery (BAT0) --------------------------------------------------------------------------{{{2
batteryWidget = widget({ type = "textbox" })

function  batteryInfo (adapter)
	local notified = false

	return function ()
		local display

		local fcur = io.open("/sys/class/power_supply/"..adapter.."/energy_now")
		local fcap = io.open("/sys/class/power_supply/"..adapter.."/energy_full")
		local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")

		if (fcur) then
			local cur = fcur:read()
			fcur:close()
			local cap = fcap:read()
			fcap:close()
			local sta = fsta:read()
			fsta:close()

			local battery = math.min (100, math.floor(cur * 100 / cap))
			display = battery.."%"

			if (sta:match("Discharging")) then
				if (battery < 10) then
					if (battery < 5) then
						os.execute("sudo pm-suspend")
					elseif (not notified) then
						naughty.notify({ text = "<span size=\"x-large\" color=\"red\">Battery low!</span>",
						icon = "/usr/share/icons/oxygen/48x48/status/battery-low.png",
						timeout = 0 })
						notified = true
					end
					color = "red"
				else
					color = "yellow"
				end
			else 
				notified = false
				color = "green"
			end

			display = "<span color=\""..color.."\">"..display.."</span>"

		else
			display = "=AC="
		end

		batteryWidget.text = display
	end
end

batteryTimer = timer({ timeout = 10 })
batteryTimer:add_signal("timeout", batteryInfo("BAT0"))
batteryTimer:start()
batteryTimer:emit_signal("timeout")


-- === Wibox ==================================================================================={{{1

separator = widget ({ type = "textbox" })
separator.text = " | "

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
awful.button({ }, 1, awful.tag.viewonly),
awful.button({ modkey }, 1, awful.client.movetotag),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, awful.client.toggletag),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
awful.button({ }, 1, function (c)
	if not c:isvisible() then
		awful.tag.viewonly(c:tags()[1])
	end
	client.focus = c
	c:raise()
end),
awful.button({ }, 3, function ()
	if instance then
		instance:hide()
		instance = nil
	else
		instance = awful.menu.clients({ width=250 })
	end
end),
awful.button({ }, 4, function ()
	awful.client.focus.byidx(1)
	if client.focus then client.focus:raise() end
end),
awful.button({ }, 5, function ()
	awful.client.focus.byidx(-1)
	if client.focus then client.focus:raise() end
end))

for s = 1, screen.count() do
	-- Create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
	awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
	awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end)))
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist(function(c)
		return awful.widget.tasklist.label.currenttags(c, s)
	end, mytasklist.buttons)

	-- Create the wibox
	mywibox[s] = awful.wibox({ position = "top", screen = s })

	mywibox[s].widgets = {
		{
			mylauncher,
			mytaglist[s],
			mypromptbox[s],
			layout = awful.widget.layout.horizontal.leftright
		},
		mylayoutbox[s],
		batteryWidget,
		separator,
		mytextclock,
		s == 1 and mysystray or nil,
		mytasklist[s],
		layout = awful.widget.layout.horizontal.rightleft
	}
end

-- === Bindings ================================================================================{{{1

-- --- Mouse -----------------------------------------------------------------------------------{{{2
root.buttons( awful.util.table.join(
awful.button({ }, 3, function () mymainmenu:toggle() end),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))


-- --- Keyboard --------------------------------------------------------------------------------{{{2
globalkeys = awful.util.table.join(

-- Navigation
awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),

awful.key({ modkey,           }, "j",
function ()
	awful.client.focus.byidx( 1)
	if client.focus then client.focus:raise() end
end),
awful.key({ modkey,           }, "k",
function ()
	awful.client.focus.byidx(-1)
	if client.focus then client.focus:raise() end
end),
awful.key({ modkey,           }, "Tab",
function ()
	awful.client.focus.history.previous()
	if client.focus then
		client.focus:raise()
	end
end),

-- Layout manipulation
awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
-- Toggle the Wibox
awful.key({ modkey }, "f",
function()
	for s=1,screen.count() do
		mywibox[s].visible = not mywibox[mouse.screen].visible
	end
end),

-- Prompt
awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
awful.key({ modkey }, "x",
function ()
	awful.prompt.run({ prompt = "Run Lua code: " },
	mypromptbox[mouse.screen].widget,
	awful.util.eval, nil,
	awful.util.getdir("cache") .. "/history_eval")
end),

-- Standard program
awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
awful.key({ modkey, "Control" }, "r", awesome.restart),
awful.key({ modkey, "Shift"   }, "q", awesome.quit),

-- User defined
awful.key({ modkey }, "i", function() awful.util.spawn(browser) end),
awful.key({ modkey }, "e", function() awful.util.spawn(editor) end),
awful.key({ modkey }, "m", function() awful.util.spawn(terminal .. " --class Mutt -e \"mutt -y\"") end),
awful.key({ modkey, "Shift" }, "n", function() awful.util.spawn("wine /home/bassam/.wine/drive_c/Program\\ Files/CalorieKing/ckdiary_us.exe") end),
-- We need to bind xtrlock to the "Key Released" event, hence the nil argument
-- awful.key({ modkey, "Control" }, "l", nil, function() awful.util.spawn("xtrlock") end),
awful.key({ modkey, "Control" }, "l", function() awful.util.spawn("slimlock") end),

-- Volume
awful.key({}, "XF86AudioMute", function () awful.util.spawn("amixer -q sset Master toggle") end),
awful.key({}, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -q sset Master 5%+") end),
awful.key({}, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -q sset Master 5%-") end)
)

clientkeys = awful.util.table.join(
awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
-- awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end)
-- awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
	keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
	globalkeys = awful.util.table.join(globalkeys,
	awful.key({ modkey }, "#" .. i + 9,
	function ()
		local screen = mouse.screen
		if tags[screen][i] then
			awful.tag.viewonly(tags[screen][i])
		end
	end),
	awful.key({ modkey, "Shift" }, "#" .. i + 9,
	function ()
		if client.focus and tags[client.focus.screen][i] then
			awful.client.movetotag(tags[client.focus.screen][i])
		end
	end))
end

clientbuttons = awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize))


root.keys(globalkeys)


-- === Applications ============================================================================{{{1

-- --- Rules -----------------------------------------------------------------------------------{{{2
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = true,
			keys = clientkeys,
			buttons = clientbuttons } },


	-- Disable empty space around some apps
	{
		rule = { class = "Emacs" },
		properties = { size_hints_honor = false } },
	{
		rule = { class = "Gvim" },
		properties = { size_hints_honor = false } },
--		callback = function(c)
--				os.execute("sleep 0.01")
--			end },
	{
		rule = { class = "Sakura" },
		properties = { size_hints_honor = false } },

	-- Fix the layout problem when firing Mutt under Sakura in "max" mode
	{
		rule = { class = "Mutt" },
		properties = { size_hints_honor = false },
		callback = function(c)
				os.execute("sleep 0.1")
			end },

	{
		rule = { class = "gimp" },
		properties = { floating = true } },

	-- Open download windows on last tag
	{
		rule = { class = "UzblWget" },
		properties = { tag = tags[1][4] } },
}


-- --- Signals ---------------------------------------------------------------------------------{{{2
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
	-- Add a titlebar
	-- awful.titlebar.add(c, { modkey = modkey })

	-- Enable sloppy focus
	c:add_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
			and awful.client.focus.filter(c) then
			client.focus = c
		end
	end)

	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- awful.client.setslave(c)

		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- vim: fdm=marker: fml=2
