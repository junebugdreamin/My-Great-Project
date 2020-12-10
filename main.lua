function love.load()
	love.graphics.setBackgroundColor(0,0,0)
	
	note1 = love.sound.newSoundData(16000,44100,16,1)
	note2 = love.sound.newSoundData(16000,44100,16,1)
	note3 = love.sound.newSoundData(16000,44100,16,1)
	note4 = love.sound.newSoundData(16000,44100,16,1)
	note5 = love.sound.newSoundData(16000,44100,16,1)
	
	for i=0,9999 do
		note1:setSample(i, math.sin(i/25)*1)
		note2:setSample(i, math.sin(i/25*(math.pow(2,1/12))))
		note3:setSample(i, math.sin(i/25*math.pow(math.pow(2,1/12),2)))
		note4:setSample(i, math.sin(i/25*math.pow(math.pow(2,1/12),3)))
		note5:setSample(i, math.sin(i/25*math.pow(math.pow(2,1/12),4)))
	end
	
	notes = {note1, note2, note3, note4, note5}
	song = {1, 3, 5, 4, 2, 1, 0, 5, 3, 1}
	timer = 0
end

function love.draw()
	if timer < (((#song+1)*60)-1) then
		timer = timer + 1
	end
	if (timer % 60 == 0) then
		noteToPlay = song[math.floor(timer/60)]
		if noteToPlay ~= 0 then
			noteToPlay = notes[noteToPlay]
			source1 = love.audio.newSource(noteToPlay, "static")
			love.audio.play(source1)
		end
	end
	
end