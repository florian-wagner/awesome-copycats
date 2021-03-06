--[[

     Holo Awesome WM config 2.0
     github.com/copycat-killer
     modified by fwagner

--]]
--


-- {{{ Required libraries
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local drop      = require("scratchdrop")
local lain      = require("lain")
local pomodoro      = require("pomodoro")
pomodoro.init()
-- }}}


-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

run_once("unclutter")
run_once("compton")
run_once("xrandr --output VGA-1 --off --output DVI-I-1 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-1 --mode 1920x1080 --pos 0x0 --rotate normal")

-- }}}

-- {{{ Variable definitions
-- localization
--os.setlocale(os.getenv("LANG"))

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/holo/theme.lua")

-- common
HOST  = awful.util.pread("hostname | tr -d '\n'")
modkey     = "Mod4"
altkey     = "Mod1"
terminal   = "terminator"
--terminal   = "urxvt"
editor     = "vim"
editor_cmd = terminal .. " -e " .. editor

-- user defined
browser    = "chromium"
browser2   = browser
mail       = "icedove"
gui_editor = "atom"
graphics   = "gimp"
musiplr    = terminal .. " -e ncmpcpp "
todo = "chromium --app-id=ojcflmmmcfpacggndoaaflkmcoblhnbh"

local layouts = {
    lain.layout.uselesstile.left,
    lain.layout.uselesstile.right,
    lain.layout.uselesstile.top,
    lain.layout.uselessfair,
    lain.layout.uselessfair.horizontal,
    lain.layout.termfair,
    awful.layout.suit.floating
 }

--- Monitor setup
if screen.count() == 1 then
    tags = {
        names = { " 1: MAIL ", " 2: WEB ", " 3: FILES ", " 4: TERM ", " 5: TEXT ", " 6: TODO ", " 7: MISC ", " 8: VBOX "},
        layout = { layouts[1], layouts[1], layouts[1], layouts[6], layouts[1], layouts[1], layouts[1], layouts[1] },
    }
    -- {{{ Tags
    for s = 1, screen.count() do
        tags[s] = awful.tag(tags.names, s, tags.layout)
    end

elseif screen.count() == 2 then
    tags = {
        { names = { " 1: MAIL ", " 2: WEB ", " 3: FILES ", " 4: TERM ", " 5: TEXT ", " 6: TODO ", " 7: MISC "}, layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1]} },
        { names = { " 1: CODING ", " 2 ", " 3 ", " 4 ", " 5 "}, layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] } },
    }
    -- {{{ Tags
    for s = 1, screen.count() do
        tags[s] = awful.tag(tags[s].names, s, tags[s].layout)
    end
end


-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Menu
mymainmenu = awful.menu.new({ items = require("menugen").build_menu(),
                              theme = { height = 16, width = 130 }})
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- {{{ Wibox
markup = lain.util.markup
blue   = "#80CCE6"
space3 = markup.font("Dingbats 3", " ")
space2 = markup.font("Dingbats 2", " ")

-- Menu icon
awesome_icon = wibox.widget.imagebox()
awesome_icon:set_image(beautiful.awesome_icon)
awesome_icon:buttons(awful.util.table.join( awful.button({ }, 1, function() mymainmenu:toggle() end)))

-- Clock
mytextclock = awful.widget.textclock(markup("#FFFFFF", space3 .. "%H:%M" .. space2))
clock_icon = wibox.widget.imagebox()
clock_icon:set_image(beautiful.clock)
clockwidget = wibox.widget.background()
clockwidget:set_widget(mytextclock)
clockwidget:set_bgimage(beautiful.widget_bg)

-- Calendar
mytextcalendar = awful.widget.textclock(markup("#FFFFFF", space3 .. "%d %b<span font='Dingbats 5'> </span>"))
calendar_icon = wibox.widget.imagebox()
calendar_icon:set_image(beautiful.calendar)
calendarwidget = wibox.widget.background()
calendarwidget:set_widget(mytextcalendar)
calendarwidget:set_bgimage(beautiful.widget_bg)
lain.widgets.calendar:attach(calendarwidget, { fg = "#FFFFFF", position = "bottom_right" })

--[[ Mail IMAP check
-- commented because it needs to be set before use
mailwidget = lain.widgets.imap({
    timeout  = 180,
    server   = "server",
    mail     = "mail",
    password = "keyring get mail",
    settings = function()
        mail_notification_preset.fg = white
        mail  = ""
        count = ""

        if mailcount > 0 then
            mail = "Arch "
            count = mailcount .. " "
        end

        widget:set_markup(markup(blue, mail) .. markup(white, count))
    end
})
]]

-- MPD
mpd_icon = wibox.widget.imagebox()
mpd_icon:set_image(beautiful.mpd)
prev_icon = wibox.widget.imagebox()
prev_icon:set_image(beautiful.prev)
next_icon = wibox.widget.imagebox()
next_icon:set_image(beautiful.nex)
stop_icon = wibox.widget.imagebox()
stop_icon:set_image(beautiful.stop)
pause_icon = wibox.widget.imagebox()
pause_icon:set_image(beautiful.pause)
play_pause_icon = wibox.widget.imagebox()
play_pause_icon:set_image(beautiful.play)

mpdwidget = lain.widgets.mpd({
    settings = function ()
        if mpd_now.state == "play" then
            mpd_now.artist = mpd_now.artist:upper():gsub("&.-;", string.lower)
            mpd_now.title = mpd_now.title:upper():gsub("&.-;", string.lower)
            widget:set_markup(markup.font("Dingbats 4", " ")
                              .. markup.font("Dingbats 8",
                              mpd_now.artist
                              .. " - " ..
                              mpd_now.title
                              .. markup.font("Dingbats 10", " ")))
            play_pause_icon:set_image(beautiful.pause)
        elseif mpd_now.state == "pause" then
            widget:set_markup(markup.font("Dingbats 4", " ") ..
                              markup.font("Dingbats 8", "MPD PAUSED") ..
                              markup.font("Dingbats 10", " "))
            play_pause_icon:set_image(beautiful.play)
        else
            widget:set_markup("")
            play_pause_icon:set_image(beautiful.play)
        end
    end
})

musicwidget = wibox.widget.background()
musicwidget:set_widget(mpdwidget)
musicwidget:set_bgimage(beautiful.widget_bg)
musicwidget:buttons(awful.util.table.join(awful.button({ }, 1,
function () awful.util.spawn_with_shell(musicplr) end)))
mpd_icon:buttons(awful.util.table.join(awful.button({ }, 1,
function () awful.util.spawn_with_shell(musicplr) end)))
prev_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    awful.util.spawn_with_shell("mpc prev || ncmpcpp prev || ncmpc prev || pms prev")
    mpdwidget.update()
end)))
next_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    awful.util.spawn_with_shell("mpc next || ncmpcpp next || ncmpc next || pms next")
    mpdwidget.update()
end)))
stop_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    play_pause_icon:set_image(beautiful.play)
    awful.util.spawn_with_shell("mpc stop || ncmpcpp stop || ncmpc stop || pms stop")
    mpdwidget.update()
end)))
play_pause_icon:buttons(awful.util.table.join(awful.button({}, 1,
function ()
    awful.util.spawn_with_shell("mpc toggle || ncmpcpp toggle || ncmpc toggle || pms toggle")
    mpdwidget.update()
end)))

-- Battery
batwidget = lain.widgets.bat({
    settings = function()
        bat_header = " Bat "
        bat_p      = bat_now.perc .. " "

        if bat_now.status == "Not present" then
            bat_header = ""
            bat_p      = ""
        end

        widget:set_markup(markup(blue, bat_header) .. bat_p)
    end
})

-- ALSA volume bar
myvolumebar = lain.widgets.alsabar({
    width  = 80,
    height = 10,
    colors = {
        background = "#383838",
        unmute     = "#80CCE6",
        mute       = "#FF9F9F"
    },
    notifications = {
        font      = "Dingbats",
        font_size = "12",
        bar_size  = 32
    }
})
alsamargin = wibox.layout.margin(myvolumebar.bar, 5, 8, 80)
wibox.layout.margin.set_top(alsamargin, 12)
wibox.layout.margin.set_bottom(alsamargin, 12)
volumewidget = wibox.widget.background()
volumewidget:set_widget(alsamargin)
volumewidget:set_bgimage(beautiful.widget_bg)

-- CPU
cpu_widget = lain.widgets.cpu({
    settings = function()
        widget:set_markup(space3 .. "CPU " .. cpu_now.usage
                          .. "%" .. markup.font("Dingbats 5", " "))
    end
})
cpuwidget = wibox.widget.background()
cpuwidget:set_widget(cpu_widget)
cpuwidget:set_bgimage(beautiful.widget_bg)
cpu_icon = wibox.widget.imagebox()
cpu_icon:set_image(beautiful.cpu)

-- Net
netdown_icon = wibox.widget.imagebox()
netdown_icon:set_image(beautiful.net_down)
netup_icon = wibox.widget.imagebox()
netup_icon:set_image(beautiful.net_up)
netwidget = lain.widgets.net({
    settings = function()
        widget:set_markup(markup.font("Dingbats 1", " ") .. net_now.received .. " - "
                          .. net_now.sent .. space2)
    end
})
networkwidget = wibox.widget.background()
networkwidget:set_widget(netwidget)
networkwidget:set_bgimage(beautiful.widget_bg)

-- Weather
yawn = lain.widgets.yawn(638242)

-- Separators
first = wibox.widget.textbox('<span font="Dingbats 4"> </span>')
last = wibox.widget.imagebox()
last:set_image(beautiful.last)
spr = wibox.widget.imagebox()
spr:set_image(beautiful.spr)
spr_small = wibox.widget.imagebox()
spr_small:set_image(beautiful.spr_small)
spr_very_small = wibox.widget.imagebox()
spr_very_small:set_image(beautiful.spr_very_small)
spr_right = wibox.widget.imagebox()
spr_right:set_image(beautiful.spr_right)
spr_bottom_right = wibox.widget.imagebox()
spr_bottom_right:set_image(beautiful.spr_bottom_right)
spr_left = wibox.widget.imagebox()
spr_left:set_image(beautiful.spr_left)
bar = wibox.widget.imagebox()
bar:set_image(beautiful.bar)
bottom_bar = wibox.widget.imagebox()
bottom_bar:set_image(beautiful.bottom_bar)

-- Create a wibox for each screen and add it
mywibox = {}
mybottomwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
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
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 32 })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(first)
    left_layout:add(mytaglist[s])
    left_layout:add(mylayoutbox[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
        right_layout:add(wibox.widget.systray())
        right_layout:add(batwidget)
        right_layout:add(netdown_icon)
        right_layout:add(networkwidget)
        right_layout:add(netup_icon)
        right_layout:add(bottom_bar)
        right_layout:add(cpu_icon)
        right_layout:add(cpuwidget)
        right_layout:add(bottom_bar)
    end
    if s == 2 then
        right_layout:add(pomodoro.widget)
        right_layout:add(pomodoro.icon_widget)
    end
    right_layout:add(calendar_icon)
    right_layout:add(calendarwidget)
    right_layout:add(bottom_bar)
    right_layout:add(clock_icon)
    right_layout:add(clockwidget)
    right_layout:add(last)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

    -- Create the bottom wibox
    mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, border_width = 0, height = 32 })

    -- Widgets that are aligned to the bottom left
    bottom_left_layout = wibox.layout.fixed.horizontal()
    bottom_left_layout:add(awesome_icon)

    -- Widgets that are aligned to the bottom right
    bottom_right_layout = wibox.layout.fixed.horizontal()
    bottom_right_layout:add(spr_bottom_right)

    -- Now bring it all together (with the tasklist in the middle)
    bottom_layout = wibox.layout.align.horizontal()
    bottom_layout:set_left(bottom_left_layout)
    bottom_layout:set_middle(mytasklist[s])
    bottom_layout:set_right(bottom_right_layout)
    mybottomwibox[s]:set_widget(bottom_layout)

    -- Set proper backgrounds, instead of beautiful.bg_normal
    mywibox[s]:set_bg("#222222")
    mybottomwibox[s]:set_bg("#242424")

    -- Create a borderbox above the bottomwibox
    lain.widgets.borderbox(mybottomwibox[s], s, { position = "top", color = "#222222" } )
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    -- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
    awful.key({ altkey }, "p", function() os.execute("screenshot") end),

    -- Tag browsing
    awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),

    -- Non-empty tag browsing
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Show Menu
    awful.key({ modkey }, "a",
        function ()
            mymainmenu:show({ keygrabber = true })
        end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
        mybottomwibox[mouse.screen].visible = not mybottomwibox[mouse.screen].visible
    end),

    -- On the fly useless gaps change
    awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end),
    awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "h", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "l", function () awful.screen.focus_relative(-1) end),
    --awful.key({ "Control", altkey }, "Left", function () awful.screen.focus_relative( 1) end),
    --awful.key({ "Control", altkey }, "Right", function () awful.screen.focus_relative(-1) end),
    awful.key({ "Control", altkey }, "Left", function () awful.screen.focus(1) end),
    awful.key({ "Control", altkey }, "Right", function () awful.screen.focus(2) end),
    awful.key({ "Control", altkey }, "h", function () awful.screen.focus(1) end),
    awful.key({ "Control", altkey }, "l", function () awful.screen.focus(2) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            -- awful.client.focus.history.previous()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end),
        --function ()
            --for c in awful.client.iterate(function (x) return true end) do
                --client.focus = c
                --client.focus:raise()
            --end
        --end

    awful.key({ modkey, "Shift"   }, "Tab",
        function ()
            -- awful.client.focus.history.previous()
            awful.client.focus.byidx(1)
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ altkey, "Shift"   }, "h",      function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ altkey, "Shift"   }, "l",      function () awful.tag.incmwfact(-0.05)     end),
    awful.key({ modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)       end),
    awful.key({ modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)       end),
    awful.key({ altkey }, "l",      awful.tag.viewnext),
    awful.key({ altkey }, "h",      awful.tag.viewprev),
    awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1)  end),
    awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1)  end),
    awful.key({ modkey, "Control" }, "n",      awful.client.restore),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    --awful.key({ modkey, "Shift" }, "r",      awesome.restart),
    --awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

    -- Dropdown terminal
    awful.key({ modkey,	          }, "z",      function () drop(terminal) end),

    -- Widgets popups
    awful.key({ altkey,           }, "c",      function () lain.widgets.calendar:show(7) end),
    awful.key({ altkey,           }, "w",      function () yawn.show(7) end),

    -- Standard program
    awful.key({ modkey, }, "F12", function () awful.util.spawn("xscreensaver-command -lock") end),

    -- ALSA volume control with multimedia keys
    awful.key({}, "XF86AudioRaiseVolume",
        function ()
            awful.util.spawn("amixer -q set " .. myvolumebar.channel .. " " .. myvolumebar.step .. "+")
            myvolumebar.notify()
        end),
    awful.key({}, "XF86AudioLowerVolume",
        function ()
            awful.util.spawn("amixer -q set " .. myvolumebar.channel .. " " .. myvolumebar.step .. "-")
            myvolumebar.notify()
        end),
    awful.key({}, "XF86AudioMute",
        function ()
            awful.util.spawn("amixer -q set " .. myvolumebar.channel .. " playback toggle")
            myvolumebar.notify()
        end),
    awful.key({ altkey, "Control" }, "m",
        function ()
            awful.util.spawn("amixer -q set " .. myvolumebar.channel .. " playback 100%")
            myvolumebar.notify()
        end),

    -- Brightness
    awful.key({ }, "XF86MonBrightnessDown", function ()
        awful.util.spawn("xbacklight -dec 15") end),
    awful.key({ }, "XF86MonBrightnessUp", function ()
        awful.util.spawn("xbacklight -inc 15") end),

    -- Shutdown dialog
    awful.key({ "Control", altkey }, "Delete", awesome.quit),

        --awful.util.spawn("sh /home/fwagner/Skripte/bash/shutdown_dialog.sh") end),

    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey }, "w", function () awful.util.spawn(browser) end),
    awful.key({ modkey }, "d", function () awful.util.spawn("thunar") end),
    awful.key({ modkey }, "t", function () awful.util.spawn(mail) end),
    awful.key({ modkey }, "e", function () awful.util.spawn(gui_editor) end),
    awful.key({ modkey }, "g", function () awful.util.spawn(graphics) end),

    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    --awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
local np_map = { 87, 88, 89, 83, 84, 85, 79, 80, 81 }
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
     -- Also map numpad keys!
     globalkeys = awful.util.table.join(globalkeys,
         awful.key({ modkey }, "#" .. np_map[i],
                   function ()
                         local screen = mouse.screen
                         local tag = awful.tag.gettags(screen)[i]
                         if tag then
                            awful.tag.viewonly(tag)
                         end
                   end),
         awful.key({ modkey, "Control" }, "#" .. np_map[i],
                   function ()
                       local screen = mouse.screen
                       local tag = awful.tag.gettags(screen)[i]
                       if tag then
                          awful.tag.viewtoggle(tag)
                       end
                   end),
         awful.key({ modkey, "Shift" }, "#" .. np_map[i],
                   function ()
                       local tag = awful.tag.gettags(client.focus.screen)[i]
                       if client.focus and tag then
                           awful.client.movetotag(tag)
                      end
                   end),
         awful.key({ modkey, "Control", "Shift" }, "#" .. np_map[i],
                   function ()
                       local tag = awful.tag.gettags(client.focus.screen)[i]
                       if client.focus and tag then
                           awful.client.toggletag(tag)
                       end
                   end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     maximized_vertical   = false,
                     maximized_horizontal = false,
                     buttons = clientbuttons,
	                   size_hints_honor = false } },
    { rule = { class = "URxvt" },
          properties = { opacity = 0.99 } },

    { rule = { class = "MPlayer" },
          properties = { floating = true } },

    { rule = { class = "Icedove" },
          properties = { tag = tags[1][1], maximized_horizontal = true, maximized_vertical = true } },

    { rule = { class = "Atom" },
          properties = { tag = tags[2][1], maximized_horizontal = true, maximized_vertical = true } },

    { rule = { class = "Chromium-browser" },
          properties = { tag = tags[1][2], maximized_horizontal = true, maximized_vertical = true } },

    { rule = { instance = "crx_ojcflmmmcfpacggndoaaflkmcoblhnbh" }, -- Wunderlist app
          properties = { tag = tags[1][6] } },

    { rule = { instance = "plugin-container" },
          properties = { tag = tags[1][1] } },

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized_horizontal = true,
                         maximized_vertical = true } },
}
-- }}}

-- Caused clients to flip screens!

-- {{{ Signals
-- Signal function to execute when a new client appears.
--client.connect_signal("manage", function (c, startup)
    ---- Enable sloppy focus
    --c:connect_signal("mouse::enter", function(c)
        --if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            --and awful.client.focus.filter(c) then
            --client.focus = c
        --end
    --end)

    --if not startup and not c.size_hints.user_position
       --and not c.size_hints.program_position then
        --awful.placement.no_overlap(c)
        --awful.placement.no_offscreen(c)
    --end
--end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_width = 0
            c.border_color = beautiful.border_normal
        else
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then -- Fine grained borders and floaters control
            for _, c in pairs(clients) do -- Floaters always have borders
                if awful.client.floating.get(c) or layout == "floating" then
                    c.border_width = beautiful.border_width

                -- No borders with only one visible client
                elseif #clients == 1 or layout == "max" then
                    clients[1].border_width = 0
                    awful.client.moveresize(0, 0, 2, 2, clients[1])
                else
                    c.border_width = beautiful.border_width
                end
            end
        end
      end)
end
-- }}}
--
awful.util.spawn_with_shell("xscreensaver -no-splash")

-- focus screen 1
awful.screen.focus(1)

-- Custom autostart
run_once("nm-applet")
-- run_once("conky -c .conkyrc." .. HOST)
run_once("pidgin")

run_once(todo)
run_once("redshift -l 50.73743:7.09821 -t 5800:4500")
run_once("skype")
run_once(mail)
run_once("synapse -s")
run_once("skypeforlinux")
run_once("sleep 10 && chromium && dropbox")
run_once("atom")
run_once("owncloud")
run_once("xset b off")
run_once("numlockx on")
run_once("synapse -s")
run_once("setxkbmap -option caps:escape")
