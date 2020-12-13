function love.load()
	--graphics stuff
	love.graphics.setBackgroundColor(0,0,0)
	font = love.graphics.newFont("zeldadxt.ttf", 22, mono)
	love.graphics.setFont( font )
	love.graphics.setDefaultFilter("nearest", "nearest", 1) 
	love.window.setMode(512,512)

	--song data
	song  = { 1,  2,  3,  4,  5,  6,  7,  8,  1,  3,  5,  3,  1 }
	songO = { 0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1 }
	songL = {.5, .5, .5, .5, .5, .5, .5, .5,  1, .5,  1, .5,  1 }
	songX = { 0, .5,  1,  1,  1, .5,  0,  0,  0,  1,  1,  1,  0 }
	songY = { 0,  0,  0, .5,  1,  1,  1, .5,  0,  0,  1,  0,  0 }
	
	--note/song engine stuff
	chro_to_dia = {0, 1, 3, 5, 6, 8, 10, 11, 12}
	note = love.sound.newSoundData(16000,44100,16,1)
	timer = 1
	isPlaying = false
	songPos = 1
	beginningOffset = 120
	nextUpdate = beginningOffset
	graphX = 16
	graphY = 256-24
	accuracy = 0
	bpm = 60
	correct = true
	step = 0
	
	--neural net stuff
	local luann = require("luann")
	math.randomseed(love.timer.getTime())
	learningRate = 1 -- set between 1, 100
	threshold = 1 -- steepness of the sigmoid curve
	myNetwork = luann:new({2,4, 4}, learningRate, threshold)
	speed = 1
	index = 0
	
end

function love.keypressed(key, unicode)
	if key == "p" then
		if isPlaying then
			isPlaying = false
		else
			isPlaying = true
		end
	end
end

function getNote(x, y)
	tempArr = {x, y}
	myNetwork:activate(tempArr)
	a = myNetwork[3].cells[1].signal
	b = myNetwork[3].cells[2].signal
	c = myNetwork[3].cells[3].signal
	d = myNetwork[3].cells[4].signal
	n = -1
	
	if a >= .5 and b < .5 and c < .5 and d <.5 then
		n = 1
	elseif a >= .5 and b >= .5 and c < .5 and d <.5 then
		n = 2
	elseif a < .5 and b >= .5 and c < .5 and d <.5 then
		n = 3
	elseif a < .5 and b >= .5 and c >= .5 and d <.5 then
		n = 4
	elseif a < .5 and b < .5 and c >= .5 and d <.5 then
		n = 5
	elseif a < .5 and b < .5 and c >= .5 and d >=.5 then
		n = 6
	elseif a < .5 and b < .5 and c < .5 and d >=.5 then
		n = 7
	elseif a >= .5 and b < .5 and c < .5 and d >=.5 then
		n = 8
	elseif a < .5 and b < .5 and c < .5 and d <.5 then
		n = 0
	else
		n = 9 --hiccup later
	end
	
	return n
	
end

function getNoteTime(n)
	out = beginningOffset
	for i = 1, n-1 do
		if (i < #song+1) then
			out = out + (songL[i] * bpm)
		end
	end
	return out
end

function setNoteColor(n,o)
	if not (n == -1) then
	
		if song[n] == 1 then
			love.graphics.setColor(1,0,0,o)
		elseif song[n] == 2 then
			love.graphics.setColor(1,.5,0,o)
		elseif song[n] == 3 then
			love.graphics.setColor(1,1,0,o)
		elseif song[n] == 4 then
			love.graphics.setColor(0,1,0,o)
		elseif song[n] == 5 then
			love.graphics.setColor(0,1,1,o)
		elseif song[n] == 6 then
			love.graphics.setColor(0,.5,1,o)
		elseif song[n] == 7 then
			love.graphics.setColor(.5,0,1,o)
		elseif song[n] == 8 then
			love.graphics.setColor(1,0,1,o)
		elseif song[n] == 0 then
			love.graphics.setColor(1,1,1,o)
		end
		
	else
		a = myNetwork[3].cells[1].signal
		b = myNetwork[3].cells[2].signal
		c = myNetwork[3].cells[3].signal
		d = myNetwork[3].cells[4].signal
		n = -1
		
		if a >= .5 and b < .5 and c < .5 and d <.5 then
			love.graphics.setColor(1,0,0,o)
		elseif a >= .5 and b >= .5 and c < .5 and d <.5 then
			love.graphics.setColor(1,.5,0,o)
		elseif a < .5 and b >= .5 and c < .5 and d <.5 then
			love.graphics.setColor(1,1,0,o)
		elseif a < .5 and b >= .5 and c >= .5 and d <.5 then
			love.graphics.setColor(0,1,0,o)
		elseif a < .5 and b < .5 and c >= .5 and d <.5 then
			love.graphics.setColor(0,1,1,o)
		elseif a < .5 and b < .5 and c >= .5 and d >=.5 then
			love.graphics.setColor(0,.5,1,o)
		elseif a < .5 and b < .5 and c < .5 and d >=.5 then
			love.graphics.setColor(.5,0,1,o)
		elseif a >= .5 and b < .5 and c < .5 and d >=.5 then
			love.graphics.setColor(1,0,1,o)
		elseif a < .5 and b < .5 and c < .5 and d <.5 then
			love.graphics.setColor(0,0,0,o) --rest
		else
			love.graphics.setColor(.5,.5,.5,o) --hiccup later
		end
		
	end
	
end

function love.draw()
	for i = 1, 33 do
		for j = 1, 33 do
			myNetwork:activate({(i-1)/32,(j-1)/32})
			setNoteColor(-1,1)
			love.graphics.rectangle("fill",graphX+((i-1)*8), graphY+((j-1)*8),8,8)
		end
	end
	
	love.graphics.setColor(1,1,1,1)
	love.graphics.print("acc: " .. math.ceil(accuracy*100) .. "/100",graphX+256+16,graphY+256-8)
	love.graphics.print("step: " .. step ,graphX+256+16,graphY+256-8-16)
	
	if isPlaying then
		if timer > nextUpdate and songPos < #song+1 then
		
			nextUpdate = nextUpdate + ((songL[songPos])*bpm) --updates value to next time to update note
			
			noteToPlay = getNote(songX[songPos],songY[songPos]) --feed forward the input x y, get note value from it
			
			if noteToPlay == 9 then --hiccup
			
				hiccup = love.audio.newSource("hiccup.wav", "static")
				love.audio.play(hiccup)
				
			elseif noteToPlay ~= 0 then --normal note
				noteLength = songL[songPos]*40000*(bpm/60)
				note = love.sound.newSoundData(noteLength,44100,16,1)
				
				for i=0,noteLength - 1 do
					vibratoval = 1 + (math.sin( i/ 1500 ) / 500)
					volCo = ((noteLength-i)/noteLength)
					
                    note:setSample(i,volCo * math.sin(i/25*vibratoval*math.pow(math.pow(2,1/12),chro_to_dia[noteToPlay+1]+(songO[songPos]*12))))

				end
				source1 = love.audio.newSource(note, "static")
				love.audio.play(source1)
			end
			
			if noteToPlay == song[songPos] and song[songPos] < #song then
				accuracy = accuracy + (1/(#song))
				correct = true
			elseif noteToPlay ~= song[songPos] then
				correct = false
			end
			
			
			songPos = songPos + 1
			
		elseif timer > nextUpdate and songPos > #song then --end song, reset values
			timer = 1
			songPos = 1
			nextUpdate = beginningOffset
			isPlaying = false
			accuracy = 0
		end
		
		if songPos > 1 then --draw the outlines
			tempX = graphX + ((songX[songPos-1])*256)
			tempY =  graphY + ((songY[songPos-1])*256)
			if math.floor(timer/4) % 2 == 0 then
				if correct then
					love.graphics.setColor(1,1,1,1)
				else
					love.graphics.setColor(0,0,0,1)
				end
			else
				setNoteColor(songPos-1,1)
			end
			love.graphics.rectangle("fill",tempX,tempY,8,8)
		end
		
		--draw falling notes
		
		for i = songPos, #song do
			if i < #song+1 then
				tempPos = getNoteTime(i)
				tempX = graphX + ((songX[i])*256)
				tempY =  graphY + ((songY[i])*256)
				tempPos = tempPos - timer
				tempPos = tempPos * 2
				opacity = (100 - (tempPos/2)) / 100
				if opacity < 0 then
					opacity = 0
				end
				love.graphics.setColor(0,0,0,1)
				love.graphics.rectangle("line",tempX+2,tempY+2 - tempPos,4,4)
				love.graphics.rectangle("line",tempX-2,tempY-2 - tempPos,12,12)
				
				love.graphics.setColor(0,0,0,opacity)
				love.graphics.rectangle("fill",tempX,tempY,8,8)
				
				setNoteColor(i,1)
				love.graphics.rectangle("line",tempX,tempY - tempPos,8,8)
			end
		end
		
		timer = timer + 1

	end

	if love.keyboard.isDown("space") then
		for i = 1, speed do
			if     index == 0 then myNetwork:bp({0,0}, {1,0,0,0})
			elseif index == 1 then myNetwork:bp({.5,0},{1,1,0,0})
			elseif index == 2 then myNetwork:bp({1,0}, {0,1,0,0})
			elseif index == 3 then myNetwork:bp({1,.5},{0,1,1,0})
			elseif index == 4 then myNetwork:bp({1,1}, {0,0,1,0})
			elseif index == 5 then myNetwork:bp({.5,1},{0,0,1,1})
			elseif index == 6 then myNetwork:bp({0,1},{0,0,0,1})
			elseif index == 7 then myNetwork:bp({0,.5},{1,0,0,1})
			elseif index == 8 then myNetwork:bp({.5,.5},{0,0,0,0})
			end
			index = index + 1
			if index > 8 then index = 0 end
		end
	end

end