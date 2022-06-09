isRed = false
function onCreate()
	makeLuaSprite('vignette', 'vignette', 0, 0)
	setObjectCamera('vignette', 'hud')
	addLuaSprite('vignette', false)
	setProperty('vignette.alpha', 0)
end

function onEvent(n,v1,v2)

	if n == 'Siren' and getPropertyFromClass('ClientPrefs', 'flashing') then
		isRed = not isRed
		local color = ''
		if isRed then
			color = 'FF0000'
		else
			color = '0000FF'
		end
		
		doTweenColor('colorChange', 'vignette', color, 0.00001, 'linear') --idk of a better way to do this
		setProperty('vignette.alpha', 0.5)
		doTweenAlpha('fadeOut', 'vignette', 0, 0.4, 'cubeOut')
	end

	

end