function onCreate()
	addCharacterToList('blue', 'boyfriend');
	addCharacterToList('bluehit', 'boyfriend');
	makeLuaSprite('bg', 'killbg', -620, -227)
	addLuaSprite('bg', false);
	setObjectOrder('dadGroup', 1)
	setObjectOrder('boyfriendGroup', 2)

end
singList = {"singLEFT", "singDOWN", "singUP", "singRIGHT"}

function opponentNoteHit(id, direction, noteType, isSustainNote)
    local direction = direction + 1; -- Lua counts from 1, not 0
	triggerEvent('Change Character', 0, 'bluehit');
	triggerEvent('Play Animation', singList[direction], 1);
end

function onUpdate(elapsed)
	local currentanim = getProperty('boyfriend.animation.curAnim.name');

	if currentanim == 'idle' then
	triggerEvent('Change Character', 0, 'blue');
end
end



function goodNoteHit(id, direction, noteType, isSustainNote)
	triggerEvent('Change Character', 0, 'blue');
end
function noteMiss(id, direction, noteType, isSustainNote)
	triggerEvent('Change Character', 0, 'blue');
end
