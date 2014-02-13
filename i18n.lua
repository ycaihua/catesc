i18 = {
	["ru"] = {
		["gameover"] = "ИГРА ОКОНЧЕНА";
		["space"] = "НАЖМИТЕ ПРОБЕЛ";
		["help1"] = "КЛАВИШИ: ВЛЕВО, ВПРАВО, ВВЕРХ или ПРОБЕЛ";
		["help2"] = "НАЖМИТЕ ESC ДЛЯ ВЫХОДА В МЕНЮ";
		["Score"] = "Пройдено:";
		["Hiscore"] = "Рекорд:";
		["continue"] = "ПРОДОЛЖИТЬ?";
		["cont"] = "Продолжить?";
		["1"] = "Кошки не умеют плавать";
		["2"] = "Осторожно!";
		["3"] = "Трамплин";
		["4"] = "Лестница";
		["5"] = "Лазер";
		["6"] = "Не спеши";
		["7"] = "Не стой!";
		["8"] = "Иди!";
		["9"] = "Прыгай!";
		["10"] = "Канат";
		["11"] = "Не бойся";
		["12"] = "Лифт";
		["13"] = "Змея";
		["14"] = "Дождь";
		["15"] = "Лазеры";
		["16"] = "Пресс";
		["17"] = "Догадайся";
		["18"] = "Просто?";
		["19"] = "Невозможно?";
		["20"] = "Марс";
		["21"] = "Быстрее, выше, сильнее!",
		["22"] = "Аккуратней!";	
		["23"] = "Зима";
		["24"] = "Устал?";
		["26"] = "Мины";
		["27"] = "Сила кота";
		["28"] = "Тьма";
		["29"] = "Змея II";
		["30"] = "Странное место";
		["31"] = "Шлюз";
		["30"] = "Свобода";
		}
}

_ = function(s)
	local l = LANG
	local a = s:gsub("^([^:]+):.*$", "%1")
	s = s:gsub("^[^:]+:", "")
	if not l or not i18[l] then
		return s
	end
	local ss = i18[l][a] 
	if ss then return ss end
	return s
end
