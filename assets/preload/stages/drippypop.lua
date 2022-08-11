
local u = false;
local r = 0;
local shot = false;
local agent = 1
local health = 0;
local xx = 1200;
local yy = 600;
local xx2 = 1350;
local yy2 = 600;
local ofs = 30;
local followchars = true;
local del = 0;
local del2 = 0;
function onCreate()

end




function onUpdate()
	if del > 0 then
		del = del - 1
	end
	if del2 > 0 then
		del2 = del2 - 1
	end
    if followchars == true then
        if mustHitSection == false then
           
            if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx-ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx+ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
                triggerEvent('Camera Follow Pos',xx-ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
                triggerEvent('Camera Follow Pos',xx+ofs,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
                triggerEvent('Camera Follow Pos',xx,yy-ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
                triggerEvent('Camera Follow Pos',xx,yy+ofs)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
            if getProperty('dad.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx,yy)
            end
        else

            if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
                triggerEvent('Camera Follow Pos',xx2-ofs,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
                triggerEvent('Camera Follow Pos',xx2+ofs,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
                triggerEvent('Camera Follow Pos',xx2,yy2-ofs)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
                triggerEvent('Camera Follow Pos',xx2,yy2+ofs)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'idle-alt' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
            end
            if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
                triggerEvent('Camera Follow Pos',xx2,yy2)
            end
        end
    else
        triggerEvent('Camera Follow Pos','','')
    end
    if curBeat == 286 then
        setProperty('defaultCamZoom',1.1)
		followchars = true
        xx = 1300
        yy = 350
        xx2 = 1300
        yy2 = 350
    end
    if curBeat == 304 then
        setProperty('defaultCamZoom',0.9)
		followchars = true
        xx = 1200
        yy = 600
        xx2 = 1350
        yy2 = 600
    end
    if curBeat == 318 then
        setProperty('defaultCamZoom',1.1)
		followchars = true
        xx = 1300
        yy = 350
        xx2 = 1300
        yy2 = 350
    end
    if curBeat == 336 then
        setProperty('defaultCamZoom',0.9)
		followchars = true
        xx = 1200
        yy = 600
        xx2 = 1350
        yy2 = 600
    end
    if curBeat == 384 then
        setProperty('defaultCamZoom',1.1)
		followchars = true
        xx = 1300
        yy = 350
        xx2 = 1300
        yy2 = 350
    end
    if curBeat == 401 then
        setProperty('defaultCamZoom',0.9)
		followchars = true
        xx = 1200
        yy = 600
        xx2 = 1350
        yy2 = 600
    end
end

