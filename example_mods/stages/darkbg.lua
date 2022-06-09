startTween = false
floating = false
function onCreate()
	setPropertyFromClass('GameOverSubstate', 'characterName', 'thorndyke')
	--Makes the gloop sprite and marks down its animations
	makeLuaSprite('Background','stages/darkbg',-800,-800)

	addLuaSprite('Background',false)

	--close(true)	
end

	

function onUpdate(elapsed)

	if getProperty('dad.idleSuffix') == '-mad' and floating == false then
		floating = true
		startTween = true
	end
	
	if startTween then
		startTween = false
		doTweenY('floatDown', 'dad', getProperty('dad.y') + 150, 2, 'sineInOut')
	end

    if not mustHitSection then
		setProperty('defaultCamZoom',0.65)
	else
		setProperty('defaultCamZoom',0.8)
	end
end

function onTweenCompleted(tag)
	if tag == 'floatDown' then
		doTweenY('floatUp', 'dad', getProperty('dad.y') - 150, 2, 'sineInOut')
	end
	
	if tag == 'floatUp' then
		startTween = true
	end
end