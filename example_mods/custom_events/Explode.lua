function onEvent(n,v1,v2)


	if n == 'Explode' then
		makeAnimatedLuaSprite('explosion', 'explosion', getProperty(v1..'.x') - 300, getProperty(v1..'.y') - 300)
		addAnimationByPrefix('explosion', 'expl', 'explosion idle', 20, false)
		objectPlayAnimation('explosion', 'expl', true)
		setGraphicSize('explosion', getProperty(v1..'.width') * 3)
		addLuaSprite('explosion',true)
		runTimer('explosionEnd', 0.7);
		setProperty(v1..'.visible', false);
	end



end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'explosionEnd' then
		removeLuaSprite('explosion', true)
	end
end