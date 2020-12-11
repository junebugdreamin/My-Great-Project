--project borrows heavily from https://github.com/wixico/luann, thank you!!
io.stdout:setvbuf("no")

function love.load()
	love.graphics.setBackgroundColor(0,0,0)
	
	note = love.sound.newSoundData(16000,44100,16,1)
	song  = {1,  2,  3,  4,  5,  6,  7,  8,  0}
	songL = {1, .5, .5, .5, .5, .5, .5,  1,  1}
	songX = {0, .5,  1,  1,  1, .5,  0,  0, .5}
	songY = {0,  0,  0, .5,  1,  1,  1, .5, .5}
	chro_to_dia = {0, 1, 3, 5, 6, 8, 10, 12, 13, 25}
	
	timer = 1
	isPlaying = false
	songPos = 1
	nextUpdate = 60
	
	local luann = require("luann")
	math.randomseed(love.timer.getTime())
	learningRate = 1 -- set between 1, 100
	threshold = 1 -- steepness of the sigmoid curve
	
	myNetwork = luann:new({2,4, 4}, learningRate, threshold)
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
function love.draw()

	if isPlaying then
		if timer > nextUpdate and songPos < #song+1 then
			nextUpdate = nextUpdate + ((songL[songPos])*60)
			noteToPlay = getNote(songX[songPos],songY[songPos])
			if noteToPlay == 25 then
				note = love.sound.newSoundData(1000,44100,16,1)
				for i=0,songL[songPos]*999 do
					note:setSample(i, math.sin(i * (math.sin(i/10)/25*math.pow(math.pow(2,1/12),chro_to_dia[noteToPlay+1]))))
				end
				source1 = love.audio.newSource(note, "static")
				love.audio.play(source1)
			elseif noteToPlay ~= 0 then
				note = love.sound.newSoundData(songL[songPos]*10000,44100,16,1)
				for i=0,songL[songPos]*9999 do
					note:setSample(i, math.sin(i/25*math.pow(math.pow(2,1/12),chro_to_dia[noteToPlay+1])))
				end
				source1 = love.audio.newSource(note, "static")
				love.audio.play(source1)
			end
			songPos = songPos + 1
		elseif timer > nextUpdate and songPos > #song then
			timer = 1
			songPos = 1
			nextUpdate = 60
			isPlaying = false
		end
		
		if songPos > 1 then
			tempX = graphX + 14 + ((songX[songPos-1])*256)
			tempY =  graphY + 14 + ((songY[songPos-1])*256)
			love.graphics.setColor(1,1,1,1)
			love.graphics.rectangle("fill",tempX,tempY,12,12)
		end
			
		if songPos < #song+2 then
			timer = timer + 1
		end--[[else
			timer = 1
			songPos = 1
			nextUpdate = 60
			isPlaying = false
		end]]--

	end
	
	
	graphX = 64
	graphY = 64 
	speed = 2
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
		
	
	
	for i = 1, 17 do
		for j = 1, 17 do
			myNetwork:activate({i/16,j/16})
			if (1==1) then
				if myNetwork[3].cells[1].signal >= .5 then
					love.graphics.setColor(1,0,0,1)
					love.graphics.rectangle("fill",graphX+(i*16), graphY+(j*16),4,4)
				end
				if myNetwork[3].cells[2].signal >= .5 then
					love.graphics.setColor(0,1,0,1)
					love.graphics.rectangle("fill",graphX+(i*16)+4, graphY+(j*16),4,4)
				end
				if myNetwork[3].cells[3].signal >= .5 then
					love.graphics.setColor(0,0,1,1)
					love.graphics.rectangle("fill",graphX+(i*16), graphY+(j*16)+4,4,4)
				end
				if myNetwork[3].cells[4].signal >= .5 then
					love.graphics.setColor(1,1,0,1)
					love.graphics.rectangle("fill",graphX+(i*16)+4, graphY+(j*16)+4,4,4)
				end	
			else
				love.graphics.setColor(1,0,0,myNetwork[3].cells[1].signal)
				love.graphics.rectangle("fill",graphX+(i*16), graphY+(j*16),4,4)
				love.graphics.setColor(0,1,0,myNetwork[3].cells[2].signal)
				love.graphics.rectangle("fill",graphX+(i*16)+4, graphY+(j*16),4,4)
				love.graphics.setColor(0,0,1,myNetwork[3].cells[3].signal)
				love.graphics.rectangle("fill",graphX+(i*16), graphY+(j*16)+4,4,4)
				love.graphics.setColor(1,1,0,myNetwork[3].cells[4].signal)
				love.graphics.rectangle("fill",graphX+(i*16)+4, graphY+(j*16)+4,4,4)
			end
		end
	end
end