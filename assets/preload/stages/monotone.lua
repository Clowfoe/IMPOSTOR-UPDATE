
local u = false;
local r = 0;
local shot = false;
local agent = 1
local health = 0;
local xx = 950;
local yy = 700;
local xx2 = 950;
local yy2 = 700;
local ofs = 20;
local followchars = true;
local del = 0;
local del2 = 0;


function onCreate()
    setProperty('camHUD.alpha', 0);
end


function onUpdate()
    setProperty('gf.alpha', 0);
    
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
    if curBeat == 6 then
        doTweenZoom('defeated', 'camGame', 0.4, 20, 'linear')
    end
    if curBeat == 32 then
        setProperty('defaultCamZoom',0.4)
		followchars = true
        xx = 950
        yy = 700
        xx2 = 950
        yy2 = 700
    end
    if curBeat == 81 then
        setProperty('defaultCamZoom',0.45)
		followchars = true
        xx = 850
        yy = 750
        xx2 = 1050
        yy2 = 750
    end
    if curBeat == 88 then
        setProperty('defaultCamZoom',0.8)
		followchars = true
        xx = 700
        yy = 800
        xx2 = 700
        yy2 = 800
    end
    if curBeat == 95 then
        setProperty('defaultCamZoom',0.5)
		followchars = true
        xx = 850
        yy = 750
        xx2 = 1050
        yy2 = 750
    end
    if curBeat == 112 then
        setProperty('defaultCamZoom',0.5)
		followchars = true
        xx = 950
        yy = 700
        xx2 = 950
        yy2 = 700
    end
    if curBeat == 128 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 850
        yy = 750
        xx2 = 1050
        yy2 = 750
    end
    if curBeat == 192 then
        setProperty('defaultCamZoom',0.5)
		followchars = true
        xx = 950
        yy = 700
        xx2 = 950
        yy2 = 700
    end
    if curBeat == 208 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 850
        yy = 750
        xx2 = 1050
        yy2 = 750
    end
    if curBeat == 224 then
        setProperty('defaultCamZoom',0.5)
		followchars = true
        xx = 950
        yy = 700
        xx2 = 950
        yy2 = 700
    end
    if curBeat == 254 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 1300
        yy = 800
        xx2 = 1300
        yy2 = 800
    end
    if curBeat == 262 then
        setProperty('defaultCamZoom',0.7)
		followchars = true
        xx = 1400
        yy = 800
        xx2 = 1400
        yy2 = 800
    end
    if curBeat == 270 then
        setProperty('defaultCamZoom',0.8)
		followchars = true
        xx = 1450
        yy = 800
        xx2 = 1450
        yy2 = 800
    end
    if curBeat == 278 then
        setProperty('defaultCamZoom',0.9)
		followchars = true
        xx = 1500
        yy = 800
        xx2 = 1500
        yy2 = 800
    end
    if curBeat == 294 then
        setProperty('defaultCamZoom',0.4)
		followchars = true
        xx = 850
        yy = 700
        xx2 = 850
        yy2 = 700
    end
    if curBeat == 312 then
        setProperty('defaultCamZoom',0.45)
		followchars = true
        xx = 850
        yy = 750
        xx2 = 1050
        yy2 = 750
    end
    if curBeat == 328 then
        setProperty('defaultCamZoom',0.55)
		followchars = true
        xx = 650
        yy = 750
        xx2 = 650
        yy2 = 750
    end
    if curBeat == 334 then
        setProperty('defaultCamZoom',0.45)
		followchars = true
        xx = 650
        yy = 750
        xx2 = 650
        yy2 = 750
    end
    if curBeat == 344 then
        setProperty('defaultCamZoom',0.7)
		followchars = true
        xx = 1400
        yy = 800
        xx2 = 1300
        yy2 = 800
    end
    if curBeat == 360 then
        setProperty('defaultCamZoom',0.5)
		followchars = true
        xx = 950
        yy = 700
        xx2 = 950
        yy2 = 700
    end
    if curBeat == 456 then
        setProperty('defaultCamZoom',0.6)
		followchars = true
        xx = 850
        yy = 750
        xx2 = 1050
        yy2 = 750
    end
    
    
    
end

