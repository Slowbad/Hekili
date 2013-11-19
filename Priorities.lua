--	Priorities.lua
--	Hekili @ Ner'zhul, 10/23/13

function Hekili.Flagged( ability )
	if not Hekili.ActiveModule or not Hekili.ActiveModule.flags or not Hekili.ActiveModule.flags[ability] then
		return false
	elseif	(Hekili.ActiveModule.flags[ability].talent and not Hekili.DB.char['Show Talents']) or
			(Hekili.ActiveModule.flags[ability].racial and not Hekili.DB.char['Show Racials']) or
			(Hekili.ActiveModule.flags[ability].interrupt and not Hekili.DB.char['Show Interrupts']) or
			(Hekili.ActiveModule.flags[ability].precombat and not Hekili.DB.char['Show Precombat']) or
			(Hekili.ActiveModule.flags[ability].profession and not Hekili.DB.char['Show Professions']) or
			(Hekili.ActiveModule.flags[ability].bloodlust and not Hekili.DB.char['Show Bloodlust']) or
			(Hekili.ActiveModule.flags[ability].consumable and not Hekili.DB.char['Show Consumables']) or
			(Hekili.ActiveModule.flags[ability].cooldown and
				(	(type(Hekili.ActiveModule.flags[ability].cooldown) == 'function' and Hekili.ActiveModule.flags[ability].cooldown() > Hekili.DB.char['Cooldown Threshold']) or
					(type(Hekili.ActiveModule.flags[ability].cooldown) == 'number' and Hekili.ActiveModule.flags[ability].cooldown > Hekili.DB.char['Cooldown Threshold'])
				)
			) then
		return true
	else
		return false
	end
end