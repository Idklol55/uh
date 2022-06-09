--Idea by MoonScarf
--Created by Kevin Kuntz
--Modified by Cold_Vee & Kevin Kuntz
function onCreatePost()
    for i = 0, getProperty('unspawnNotes.length') - 1 do
        sus = getPropertyFromGroup('unspawnNotes', i, 'isSustainNote')
        mustPress = getPropertyFromGroup('unspawnNotes', i, 'mustPress')
        noteType = getPropertyFromGroup('unspawnNotes', i, 'noteType')
        noteData = getPropertyFromGroup('unspawnNotes', i, 'noteData')
        if noteType == 'Shifter' then
            if not sus then
                oFX = getPropertyFromGroup('unspawnNotes', i, 'offsetX') - 40
				setPropertyFromGroup('unspawnNotes', i, 'offsetY', -30)
			else
				susFX = getPropertyFromGroup('unspawnNotes', i, 'offsetX') - 40
				setPropertyFromGroup('unspawnNotes', i, 'offsetY', -10)
				susFY = getPropertyFromGroup('unspawnNotes', i, 'offsetY')
			end
            if mustPress then
                setPropertyFromGroup('unspawnNotes', i, 'offsetX', getPropertyFromGroup('unspawnNotes', i, 'offsetX') - 640)
            else
                setPropertyFromGroup('unspawnNotes', i, 'offsetX', getPropertyFromGroup('unspawnNotes', i, 'offsetX') + 640)
            end
        end
    end
	precacheImage('ShifterNotes')
	precacheImage('greenNotes')
end

function onUpdatePost(el)
    songPos = getSongPosition()
    local currentBeat = (getSongPosition() / 1000)*(bpm/60)
    for a = 0, getProperty('notes.length') - 1 do
        strumTime = getPropertyFromGroup('notes', a, 'strumTime')
        sus = getPropertyFromGroup('notes', a, 'isSustainNote')
        noteType = getPropertyFromGroup('notes', a, 'noteType')
		mustPress = getPropertyFromGroup('notes', a, 'mustPress')
        if noteType == 'Shifter' then
			local isHoldEnd = getPropertyFromGroup('notes', a, 'animation.curAnim.name') == 'greenholdend' 
				or getPropertyFromGroup('notes', a, 'animation.curAnim.name') == 'redholdend' 
				or getPropertyFromGroup('notes', a, 'animation.curAnim.name') == 'blueholdend'
				or getPropertyFromGroup('notes', a, 'animation.curAnim.name') == 'purpleholdend'
			if (getPropertyFromGroup('notes', a, 'prevNote.wasGoodHit') or getPropertyFromGroup('notes', a, 'offsetX') >= -50) and sus then
				setPropertyFromGroup('notes', a, 'texture', 'ShifterNotes');
				if not isHoldEnd then
					setPropertyFromGroup('notes', a, 'offsetY', -30);
				else
					setPropertyFromGroup('notes', a, 'offsetY', 40);
				end
			end
			if isHoldEnd then
				setPropertyFromGroup('notes', a, 'offsetY', 40);
			end
			
			if getPropertyFromGroup('notes', a, 'animation.curAnim.curFrame') == 4 and getPropertyFromGroup('notes', a, 'texture') == 'ShifterNotes' and getPropertyFromGroup('notes', a, 'animation.curAnim.paused') ~= true then
				setPropertyFromGroup('notes', a, 'animation.curAnim.paused', true)
			end
            if (strumTime - songPos) < 1200 / scrollSpeed then
				if getPropertyFromGroup('notes', a, 'texture') ~= 'ShifterNotes' then
					setPropertyFromGroup('notes', a, 'texture', 'ShifterNotes');
				end
				if not sus then
					if getPropertyFromGroup('notes', a, 'offsetX') ~= oFX then
						setPropertyFromGroup('notes', a, 'offsetX', lerp(getPropertyFromGroup('notes', a, 'offsetX'), oFX, boundTo(el * 20, 0, 1)))
					elseif getPropertyFromGroup('notes', a, 'offsetX') <= oFX then
						setPropertyFromGroup('notes', a, 'offsetX', oFX)
					end
				else
					if getPropertyFromGroup('notes', a, 'offsetX') ~= susFX then
						setPropertyFromGroup('notes', a, 'offsetX', lerp(getPropertyFromGroup('notes', a, 'offsetX'), susFX, boundTo(el * 20, 0, 1)))
					elseif getPropertyFromGroup('notes', a, 'offsetX') <= susFX then
						setPropertyFromGroup('notes', a, 'offsetX', susFX)
					end
				end
            end
        end
    end
end

function lerp(a, b, ratio)
  return math.floor(a + ratio * (b - a))
end

function boundTo(value, min, max)
    return math.max(min, math.min(max, value))
end