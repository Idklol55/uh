ringsArray = {}
dmgCooldown = 0
function noteMiss(id, direction, noteType, isSustainNote)
	if getPropertyFromGroup('notes', id, 'gfNote') == true and dmgCooldown <= 0 then
		dmgCooldown = 2
		playSound('ring_loss')
		local ringCount = math.random(3, 8)
		for i=0, ringCount do
			setProperty('health', getProperty('health') - i/100)
			ringIndex = tostring(i)
			ringName = 'ring'..ringIndex
			local yOfs = math.random(-3, 3)
			local xOfs = math.random(-10, 10)
			makeAnimatedLuaSprite(ringName, 'ring', getMidpointX('gf') - 70, getMidpointY('gf') - 100 + (50 * yOfs))
			addAnimationByPrefix(ringName, 'spin', 'ringspin', 24, true)
			objectPlayAnimation(ringName, 'spin', true)
			addLuaSprite(ringName, true)
			doTweenX('moveHorizontally'..ringIndex, ringName, (getProperty(ringName..'.x') + (xOfs * 70)), 0.7, 'sineOut')
			doTweenY('moveUp'..ringIndex,ringName, (getProperty(ringName..'.y') - 80), 0.2, 'sineOut')
			
			ringsArray[i] = getProperty(ringName)
		end
	end
end

function onTweenCompleted(tag)
	for i,ring in pairs(ringsArray) do
		if ring ~= nil then
			if tag == 'moveUp'..i then
				doTweenY('moveDown'..i, ring, (getProperty(ring..'.y') + 800), 0.5, 'sineIn')
			end
			
			if tag == 'moveDown'..i then
				removeLuaSprite(ring)
			end
		end
	end
end

function onUpdatePost(el)
	--thanks funk mix :D
    for i,ring in pairs(ringsArray) do
		setProperty(ring..'.alpha', (getPropertyFromClass('flixel.FlxG', 'game.ticks') % 2))
	end
	
	if dmgCooldown > 0 then
		setProperty('gf.alpha', (getPropertyFromClass('flixel.FlxG', 'game.ticks') % 2))
		dmgCooldown = dmgCooldown - el
		if dmgCooldown <= 0 then
			dmgCooldown = 0
			setProperty('gf.alpha', 1)
		end
	end
end