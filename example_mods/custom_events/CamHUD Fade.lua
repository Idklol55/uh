function onEvent(n,v1,v2)

	alpha = tonumber(v1)
	duration = tonumber(v2)
	if n == 'CamHUD Fade' then
	
		doTweenAlpha('camHUDFade','camHUD',alpha, duration,'linear')
	end



end