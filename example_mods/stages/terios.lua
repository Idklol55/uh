hasSkid = false
camModified = false
function onCreatePost()
	makeLuaSprite('Background','stages/terios',0,0)
	makeLuaSprite('cannon','stages/cannon',330.45,844.4)

	addLuaSprite('Background',false)
	addLuaSprite('cannon',true)
	
	setProperty('gf.x', getProperty('gf.x') + 1500)
end

function onUpdate(elapsed)
	if getProperty('gf.animation.curAnim.name') == 'skid' and hasSkid == false then
		hasSkid = true
		doTweenX('skidIntoScene', getProperty('gf'), getProperty('gf.x') - 1600, 0.6, 'sineOut')
	end
	
	if camModified ~= true then
		if not mustHitSection then
			setProperty('defaultCamZoom',0.55)
		else
			setProperty('defaultCamZoom',0.65)
		end
	end
end

function onEvent(n,v1,v2)

	if n == 'CamHUD Fade' then
	
		doTweenAlpha('camGameFade','camGame',0, 0.8,'linear')
	end
	
	if n == "Set Cam Zoom" then
        
        if v2 == 'true' then
			camModified = true
		else
			camModified = false
		end
	end


end