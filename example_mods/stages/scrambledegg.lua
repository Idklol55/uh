
function onCreate()
	
	--Makes the gloop sprite and marks down its animations
	makeLuaSprite('lights','stages/SEgg/lights', -200, 0)
	setScrollFactor('lights', 0.6, 0.6);
	
	makeLuaSprite('back','stages/SEgg/back', 0, 0)
	setScrollFactor('back', 0.8, 0.8);
	
	makeLuaSprite('floor','stages/SEgg/floor', 0, 1164)

	addLuaSprite('lights',false)
	addLuaSprite('back',false)
	addLuaSprite('floor',false)

end

function onUpdate(elapsed)

    if not mustHitSection then
		setProperty('defaultCamZoom',0.6)
	else
		setProperty('defaultCamZoom',0.7)
	end
end