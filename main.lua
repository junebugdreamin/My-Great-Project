function love.load()
	love.graphics.setBackgroundColor(0,0,0)
	
	note = love.sound.newSoundData(16000,44100,16,1)

	
	for i=0,9999 do
		note:setSample(i, math.sin(i/25*math.pow(math.pow(2,1/12),2)))
	end
	
	song = {1, 3, 5, 6, 8, 10, 12, 13, 100}
	timer = 0
end

function love.draw()
	if timer < (((#song+1)*60)-1) then
		timer = timer + 1
	end
	if (timer % 60 == 0) then
		noteToPlay = song[math.floor(timer/60)]
		if noteToPlay ~= 0 then
			for i=0,9999 do
				note:setSample(i, math.sin(i/25*math.pow(math.pow(2,1/12),noteToPlay)))
			end
			source1 = love.audio.newSource(note, "static")
			love.audio.play(source1)
		end
	end
	
end