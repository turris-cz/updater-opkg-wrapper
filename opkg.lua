--[[
This file is part of updater-ng-opkg. Don't edit it.
]]

-- Repositories configured in opkg configuration.
-- We read only customfeeds.conf as that should be only file where user should add additional repositories to
local custom_feed = io.open(root_dir .. "etc/opkg/customfeeds.conf")
if custom_feed then
	-- Prepare list of custom keys added to opkg
	local pubkeys = {}
	for f in pairs(ls(root_dir .. "etc/opkg/keys")) do
		table.insert(pubkeys, "file://" .. root_dir .. "etc/opkg/keys/" .. f)
	end
	-- Read opkg feeds and register them to updater
	for line in custom_feed:lines() do
		local name, feed_uri, arguments = line:match('^src/gz[%s]+([^%s]+)[%s]+([^%s]+)[%s]*(.*)$')
		if name and feed_uri then
			if arguments ~= "updater-ignore" then
				DBG("Adding custom opkg feed " .. name .. " (" .. feed_uri .. ")")
				Repository(name, feed_uri, {pubkey = pubkeys, optional = true})
			else
				DBG("Skipping custom opkg feed " .. name .. " (" .. feed_uri .. ")")
			end
		else
			TRACE("Line from customfeeds.conf ignored:\n" .. line)
		end
	end
	custom_feed:close()
else
	ERROR("No " .. root_dir .. "etc/opkg/customfeeds.conf file. No opkg feeds are included.")
end
