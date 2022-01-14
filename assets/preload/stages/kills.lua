function onCreate()
	makeLuaSprite('bg', 'killbg', -620, -227)
	makeAnimatedLuaSprite('bluehit', 'characters/bluehit', 530, 450);
	addAnimationByPrefix('bluehit', 'idle', 'hit idle', 24, false);
	addAnimationByPrefix('bluehit', 'singUP', 'hit up', 24, false);
	addAnimationByPrefix('bluehit', 'singLEFT', 'hit left', 24, false);
	addAnimationByPrefix('bluehit', 'singRIGHT', 'hit right', 24, false);
	addAnimationByPrefix('bluehit', 'singDOWN', 'hit down', 24, false);
	addLuaSprite('bg', false);
	addLuaSprite('bluehit', true)
	setObjectOrder('dadGroup', 1)
	setObjectOrder('bluehit', 2)
	setObjectOrder('boyfriendGroup', 3)
		scaleLuaSprite('bluehit', 0.80, 0.80)

end
singList = {"singLEFT", "singDOWN", "singUP", "singRIGHT"}

function opponentNoteHit(id, direction, noteType, isSustainNote)
    local direction = direction + 1; -- Lua counts from 1, not 0
	if curBeat < 335 then
	objectPlayAnimation('bluehit', singList[direction], true)
	setProperty('boyfriend.visible', false)
	elseif curBeat > 391 then
	objectPlayAnimation('bluehit', singList[direction], true)
	setProperty('boyfriend.visible', false)
    end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
setProperty('boyfriend.visible', true)
if curBeat < 335 then
objectPlayAnimation('bluehit', 'idle', false)
elseif curBeat > 391 then
objectPlayAnimation('bluehit', 'idle', false)
end
end
function noteMiss(id, direction, noteType, isSustainNote)
setProperty('boyfriend.visible', true)
if curBeat < 335 then
objectPlayAnimation('bluehit', 'idle', false)
elseif curBeat > 391 then
objectPlayAnimation('bluehit', 'idle', false)
end
end
