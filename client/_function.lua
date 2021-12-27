function showbox(TextEntry, ExampleText, MaxStringLenght, isValueInt)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    local blockinput = true
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        if isValueInt then
            local isNumber = tonumber(result)
            if isNumber and tonumber(result) > 0 then
                return result
            else
                return nil
            end
        end
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

countTable = function(table)
    local i = 0
    for _,_ in pairs(table) do
        i = i + 1
    end
    return i
end

customGroupDigits = function(value)
	local left, num, right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

	return left..(num:reverse():gsub('(%d%d%d)','%1' .. " "):reverse())..right
end

CreateThread(function()
    local interval = 4000
    while true do
        refreshAPI()
        RefreshPlayerData()
        Wait(interval)
    end
end)