local xx = 500
local yy = 600
local xx2 = 1000

function onCreate()

end

function onUpdate()
    setProperty("gf.alpha", 0)
    if mustHitSection == false then
		triggerEvent('Camera Follow Pos',xx,yy)
	else
		triggerEvent('Camera Follow Pos',xx2,yy)
	end
end

