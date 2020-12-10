--project borrows heavily from https://github.com/wixico/luann, thank you!!
io.stdout:setvbuf("no")

function love.load()
	love.graphics.setBackgroundColor(0,0,0)
	
	note = love.sound.newSoundData(16000,44100,16,1)
	song = {0,-5,-8,-12,-8,-5,0,4,7,12}
	timer = 0
	
	
	local luann = require("luann")
	math.randomseed(love.timer.getTime())
	learningRate = 1 -- set between 1, 100
	threshold = 1 -- steepness of the sigmoid curve
	
	myNetwork = luann:new({2,4, 4}, learningRate, threshold)

	
		--[[myNetwork:bp({0,0,0,0},{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
		myNetwork:bp({1,0,0,0},{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
		myNetwork:bp({0,1,0,0},{0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0})
		myNetwork:bp({0,0,1,0},{0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0})
		myNetwork:bp({0,0,0,1},{0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0})
		myNetwork:bp({1,1,0,0},{0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0})
		myNetwork:bp({1,0,1,0},{0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0})
		myNetwork:bp({1,0,0,1},{0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0})
		myNetwork:bp({0,1,1,0},{0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0})
		myNetwork:bp({0,1,0,1},{0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0})
		myNetwork:bp({0,0,1,1},{0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0})
		myNetwork:bp({1,1,1,0},{0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0})
		myNetwork:bp({0,1,1,1},{0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0})
		myNetwork:bp({1,1,0,1},{0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0})
		myNetwork:bp({1,0,1,1},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0})
		myNetwork:bp({1,1,1,1},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1})]]--
		
	
end

function love.draw()
	--[[if timer < (((#song+1)*60)-1) then
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
	end]]--
	
	graphX = 64
	graphY = 64
	speed = 1
	for i = 1,speed do
		myNetwork:bp({0,0}, {1,0,0,0})
		myNetwork:bp({.5,0},{1,1,0,0})
		myNetwork:bp({1,0}, {0,1,0,0})
		myNetwork:bp({1,.5},{0,1,1,0})
		myNetwork:bp({1,1}, {0,0,1,0})
		myNetwork:bp({.5,1},{0,0,1,1})
		myNetwork:bp({0,1},{0,0,0,1})
		myNetwork:bp({0,.5},{1,0,0,1})
		myNetwork:bp({.5,.5},{0,0,0,0})
		
	end
	for i = 1, 4 do
		love.graphics.setColor(1,1,1,1)
		love.graphics.print(tostring(myNetwork[2].cells[i]),graphX,graphY + 256 + 32 + (i*32))
	end
	
	for i = 1, 4 do
		love.graphics.setColor(1,1,1,1)
		love.graphics.print(tostring(myNetwork[3].cells[i]),graphX+128,graphY + 256 + 32 + (i*32))
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