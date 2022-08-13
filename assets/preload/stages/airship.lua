
local u = false;
local r = 0;
local shot = false;
local agent = 1
local health = 0;
local xx = 700;
local yy = -2000;
local xx2 = 1634.05;
local yy2 = -54.3;
local ofs = 50;
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
    if curStep == 1 then
        setProperty('defaultCamZoom',0.3)
		followchars = true
        xx = 1634.05
        yy = -54.3
        xx2 = 1634.05
        yy2 = -54.3
    end
    if curBeat == 64 then
        setProperty('defaultCamZoom', 0.4)
        followchars = true
        xx = 800
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 96 then
        setProperty('defaultCamZoom', 0.6)
        followchars = true
        xx = 700
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 128 then
        setProperty('defaultCamZoom', 0.4)
        xx = 800
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 155 then
        setProperty('defaultCamZoom', 0.8)
        followchars = true
        xx = 450
        yy = 150
        xx2 = 450
        yy2 = 150
    end
    if curBeat == 160 then
        setProperty('defaultCamZoom', 0.4)
        followchars = true
        xx = 800
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 192 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 700
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 256 then
        setProperty('defaultCamZoom', 0.4)
        followchars = true
        xx = 800
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 288 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 700
        yy = 150
        xx2 = 1200
        yy2 = 150
    end
    if curBeat == 320 then
        setProperty('defaultCamZoom', 0.3)
        followchars = true
        xx = 1634.05
        yy = -54.3
        xx2 = 1634.05
        yy2 = -54.3
    end
    if curBeat == 384 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 700
        yy = 150
        xx2 = 1200
        yy2 = 150
    end

    
end

