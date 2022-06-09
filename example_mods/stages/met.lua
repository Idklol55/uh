function onCreate()
	
	--Makes the gloop sprite and marks down its animations
	makeLuaSprite('Background','stages/met/floor',0, 0)
	--setProperty('Background.antialiasing',false)
	
	makeAnimatedLuaSprite('grounder', 'stages/met/grounder', 56.9, 620.25)
	addAnimationByPrefix('grounder', 'dance', 'grounder', 26, false)
	objectPlayAnimation('grounder', 'dance', true)
	
	makeAnimatedLuaSprite('octopus', 'stages/met/octopus', 1910.15, 1141.35)
	addAnimationByPrefix('octopus', 'dance', 'octopus', 26, false)
	objectPlayAnimation('octopus', 'dance', true)
	
	makeAnimatedLuaSprite('monkey', 'stages/met/monkey', 1144.85, 146.3)
	addAnimationByPrefix('monkey', 'dance', 'monkey', 26, false)
	objectPlayAnimation('monkey', 'dance', true)

	addLuaSprite('monkey',false)
	addLuaSprite('Background',false)
	addLuaSprite('grounder',false)
	addLuaSprite('octopus',false)

	--close(true)	
end

function onBeatHit()
	-- triggered 4 times per section
	
	if curBeat % 2 == 0 then
		objectPlayAnimation('grounder', 'dance', true);
		objectPlayAnimation('octopus', 'dance', true);
		objectPlayAnimation('monkey', 'dance', true);
	end
	
end

function onUpdate(elapsed)

    if not mustHitSection then
		setProperty('defaultCamZoom',0.7)
	else
		setProperty('defaultCamZoom',0.8)
	end
end

function onCountdownTick(counter)
	if curBeat % 2 == 0 then
		objectPlayAnimation('grounder', 'dance', true);
		objectPlayAnimation('octopus', 'dance', true);
		objectPlayAnimation('monkey', 'dance', true);
	end
end