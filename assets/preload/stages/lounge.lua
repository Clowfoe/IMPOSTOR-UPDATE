local xx = 700
local yy = 700
local xx2 = 1000

function onCreate()

end

function onUpdate()
	setProperty('gf.alpha', 0);
	if mustHitSection == false then
		triggerEvent('Camera Follow Pos',xx,yy)
	else
		triggerEvent('Camera Follow Pos',xx2,yy)
	end

	if curBeat >= 120 then
		xx = 840
		xx2 = 1500
	end
end