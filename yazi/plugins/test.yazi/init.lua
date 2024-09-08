local selected_or_hovered = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, u in pairs(tab.selected) do
		paths[#paths + 1] = tostring(u)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths
end)

return {
  entry = function()
    ya.manager_emit("escape", { visual = true })
    local urls = selected_or_hovered()
    local paths = table.concat(urls, " ")

    local value, event = ya.input {
      title = "Zsh shell:",
      position = { "top-center", y = 3, w = 40 },
    }
    if event == 1 then
      -- if value:match("%s$@$") then
      --   value = value:gsub("%s$@$", " " .. paths)
      -- end
      old_command = "zsh -ic " .. ya.quote(value .. "; exit", true)
      new1_command = "zsh -ic " .. ya.quote(value .. "; exit", true) .. ' "$0" "$@"'
      new2_command = string.format('zsh -ic %s "$0" "$@"', ya.quote(value .. '; exit', true))
      ya.notify({
        title = "exec",
        content = string.format("old : %s\nnew1: %s\nnew2: %s", old_command, new1_command, new2_command),
        timeout = 6.5,
      })

      ya.manager_emit("shell", {
        -- old_command,
        -- new1_command,
        new2_command,
        block = true,
        confirm = true,
      })
    end
  end,
}
