function onEvent(n,v1,v2)


	if n == 'SetPos' then
		newPos = tonumber(v2)
		setProperty(v1, newPos);
	end



end