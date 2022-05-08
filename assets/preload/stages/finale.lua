function onCreate()
	-- -- background shit
	makeLuaSprite('bgg', 'bgg', -600, -400);
	setLuaSpriteScrollFactor('bgg', 0.8, 0.8);
	makeLuaSprite('dead', 'dead', 800, -270);
	setLuaSpriteScrollFactor('dead', 0.8, 0.8);
	makeLuaSprite('bg', 'bg', -790, -530);
	setLuaSpriteScrollFactor('bg', 0.9, 0.9);
	makeLuaSprite('splat', 'splat', 370, 1200);
	makeLuaSprite('fore', 'fore', -750, 160);
  setLuaSpriteScrollFactor('fore', 1.1, 1.1);
	makeLuaSprite('dark', 'dark', -720, -350);
	setLuaSpriteScrollFactor('dark', 1.05, 1.05);
	makeLuaSprite('lamp', 'lamp', 1190, -280);
	makeAnimatedLuaSprite('light', 'light', -230, -100);
	setLuaSpriteScrollFactor('light', 1.05, 1.05);
  addAnimationByPrefix('light','light','light',24,true);
	setBlendMode('light','add')
	setBlendMode('dark','multiply')

	addLuaSprite('bgg', false);
	addLuaSprite('dead', false);
	addLuaSprite('bg', false)
	addLuaSprite('splat', true)
	addLuaSprite('lamp', false);
	addLuaSprite('fore', true);
	addLuaSprite('dark', true);
	addLuaSprite('light', true)

	scaleLuaSprite('bgg', 1.1, 1.1)
	scaleLuaSprite('dead', 1.1, 1.1)
	scaleLuaSprite('bg', 1.1, 1.1)
	scaleLuaSprite('lamp', 1.1, 1.1)
	scaleLuaSprite('fore', 1.1, 1.1)
  scaleLuaSprite('splat', 1.1, 1.1)
	scaleLuaSprite('dark', 1.1, 1.1)
	scaleLuaSprite('light', 1.1, 1.1)
end

function onBeatHit()
if (curBeat % 4 == 0) then
	objectPlayAnimation('light','finale/light',true)
	 end
end
