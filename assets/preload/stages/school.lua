function onCreate()
end

function onUpdate()
	if mustHitSection == false then 
		triggerEvent('Camera Follow Pos',580, 580)    
	else
		triggerEvent('Camera Follow Pos',880, 580)    
	end
end

