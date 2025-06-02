-- Do not use 'M' for hotkey because it is tied to Moom

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- Tomito - pomodoro timer
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "T", function()
	if hs.application.launchOrFocus("Tomito") then
		local tomito = hs.application.find("tomito")

		local menu_start = { "Timer", "Start" }
		local menu_pause = { "Timer", "Pause" }
		local menu_resume = { "Timer", "Resume" }

		local start = tomito:findMenuItem(menu_start)
		local pause = tomito:findMenuItem(menu_pause)
		local resume = tomito:findMenuItem(menu_resume)

		if start and start.enabled then
			tomito:selectMenuItem(menu_start)
			hs.alert.show("Started pomodoro")
		elseif pause and pause.enabled then
			tomito:selectMenuItem(menu_pause)
			hs.alert.show("Paused pomodoro")
		elseif resume and resume.enabled then
			tomito:selectMenuItem(menu_resume)
			hs.alert.show("Resumed pomodoro")
		end

		tomito:hide()
	end
end)

-- Eject the NVMe drive (with 2 partitions) that's plugged in to the
-- Thunderbolt dock
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "E", function()
	hs.alert.show("Ejecting volumes ...")
	for _, vol in pairs({ "/Volumes/NVMe 2TB", "/Volumes/Photos backup" }) do
		ejected, errmsg = hs.fs.volume.eject(vol)
		if ejected then
			hs.alert.show(vol .. " ejected")
		else
			hs.alert.show("Error ejecting " .. vol .. ": " .. errmsg)
		end
	end
end)

wifiWatcher = nil
homeSSID = "killbot31"
lastSSID = hs.wifi.currentNetwork()

tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale"
exitNode = "bunny"

function ssidChangedCallback()
	local ssid = hs.wifi.currentNetwork()
	print("WiFi changed:", ssid)
	if not ssid then
		return
	end
	if ssid == homeSSID and lastSSID ~= homeSSID then
		hs.notify.new({ title = "Welcome home", informativeText = "Joined killbot31" }):send()
		local success, type, code = os.execute(tailscale .. " set --exit-node=")
		if not success then
			print("Could not unset Tailscale exit node")
		end
	elseif ssid ~= homeSSID and lastSSID == homeSSID then
		local success, type, code = os.execute(tailscale .. " set --exit-node=" .. exitNode)
		if not success then
			print("Could not set Tailscale exit node")
		else
			hs.notify.new({ title = "Tailscale", informativeText = "Set exit node -> " .. exitNode }):send()
		end
	end
	lastSSID = ssid
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()

-- ClipboardTool
hs.loadSpoon("ClipboardTool")
spoon.ClipboardTool:start()

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "C", function()
	spoon.ClipboardTool:showClipboard()
end)
