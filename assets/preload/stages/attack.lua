
local u = false;
local r = 0;
local shot = false;
local agent = 1
local health = 0;
local xx =  1000;
local yy =  1050;
local xx2 = 1400;
local yy2 = 1050;
local ofs = 20;
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
    if curBeat == 64 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 1225
        yy = 1000
        xx2 = 1225
        yy2 = 1000
    end
    if curBeat == 80 then
        setProperty('defaultCamZoom',0.7)
		followchars = true
        xx = 1225
        yy = 1000
        xx2 = 1225
        yy2 = 1000
    end
    if curBeat == 95 then
        setProperty('defaultCamZoom',0.9)
		followchars = true
        xx = 1000
        yy = 900
        xx2 = 1000
        yy2 = 900
    end
    if curBeat == 99 then
        setProperty('defaultCamZoom',0.75)
		followchars = true
        xx = 1000
        yy = 1050
        xx2 = 1400  
        yy2 = 1050
    end
    if curBeat == 196 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 1225
        yy = 1000
        xx2 = 1225
        yy2 = 1000
    end
    if curBeat == 229 then
        setProperty('defaultCamZoom',0.7)
		followchars = true
        xx = 1225
        yy = 1000
        xx2 = 1225
        yy2 = 1000
    end
    if curBeat == 276 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 1225
        yy = 1000
        xx2 = 1225
        yy2 = 1000
    end
    if curBeat == 292 then
        setProperty('defaultCamZoom',0.75)
		followchars = true
        xx = 1000
        yy = 1050
        xx2 = 1400  
        yy2 = 1050
    end
    if curBeat == 324 then
        setProperty('defaultCamZoom',0.7)
		followchars = true
        xx = 1225
        yy = 1000
        xx2 = 1225
        yy2 = 1000
    end
    if curBeat == 355 then
        setProperty('defaultCamZoom',0.9)
		followchars = true
        xx = 1000
        yy = 900
        xx2 = 1000
        yy2 = 900
    end
    if curBeat == 360 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 1225
        yy = 1000
        xx2 = 1225
        yy2 = 1000
    end
    
    
end

