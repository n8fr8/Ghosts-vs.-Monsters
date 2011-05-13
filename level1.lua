-- 
-- Abstract: Ghosts Vs Monsters sample project 
-- Designed and created by Jonathan and Biffy Beebe of Beebe Games exclusively for Ansca, Inc.
-- http://beebegamesonline.appspot.com/

-- (This is easiest to play on iPad or other large devices, but should work on all iOS and Android devices)
-- 
-- Version: 1.0
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.




module(..., package.seeall)

--***********************************************************************************************--
--***********************************************************************************************--

-- LEVEL MODULE

-- To create a new level, change "MODULE-SPECIFIC VARIABLES" (below) and also the
-- createLevel() function. Everything else should be identical between level modules.

--***********************************************************************************************--
--***********************************************************************************************--


-- Main function - MUST return a display.newGroup()
function new()
	local hudGroup = display.newGroup()
	
	local gameGroup = display.newGroup()
	gameGroup.x = -480
	
	local trailGroup = display.newGroup()
	local dotTimer
	
	local levelGroup = display.newGroup()
	
	-- MODULE-SPECIFIC VARIABLES
	local backgroundFilename1 = "altbackground1.png"
	local backgroundFilename2 = "altbackground2.png"
	
	-- EXTERNAL MODULES / LIBRARIES
	
	local movieclip = require( "movieclip" )
	local physics = require "physics"
	local ui = require("ui")
	--local facebook = require "facebook"
	
	local mCeil = math.ceil
	local mAtan2 = math.atan2
	local mPi = math.pi
	local mSqrt = math.sqrt
	
	-- OBJECTS
	
	local backgroundImage1
	local backgroundImage2
	local clouds1
	local clouds2
	local clouds3
	local clouds4
	local groundLight1
	local groundObject1
	local groundObject2
	local shotOrb
	local shotArrow
	local blastGlow
	local ghostObject
	local poofObject
	local greenPoof; local poofTween
	
	local life1; local life2; local life3; local life4
	local scoreText; local bestScoreText
	local continueText; local continueTimer
	local pauseMenuBtn; local pauseBtn; local pauseShade
	
	-- VARIABLES
	
	local gameIsActive = false
	local waitingForNewRound
	local restartTimer
	local ghostTween
	local screenPosition = "left"	--> "left" or "right"
	local canSwipe = true
	local swipeTween
	local gameLives = 4
	local gameScore = 0
	local bestScore
	local monsterCount
	
	-- LEVEL SETTINGS
	
	local restartModule
	local nextModule
	local woodDensity = 2.0
	local vPlankShape = { -6,-48, 6,-48, 6,48, -6,48 }
	local hPlankShape = { -48,-6, 48,-6, 48,6, -48,6 }
	local stoneDensity = 5.0
	local vSlabShape = { -12,-26, 12,-26, 12,26, -12,26 }
	local tombDensity = 5.5
	local tombShape = { -18,-21, 18,-21, 18,21, -18,21 }
	local monsterDensity = 1.0
	local monsterShape = { -12,-13, 12,-13, 12,13, -12,13 }
	
	-- AUDIO
	
	local tapSound = audio.loadSound( "tapsound.wav" )
	local blastOffSound = audio.loadSound( "blastoff.wav" )
	local ghostPoofSound = audio.loadSound( "ghostpoof.wav" )
	local monsterPoofSound = audio.loadSound( "monsterpoof.wav" )
	local impactSound = audio.loadSound( "impact.wav" )
	local weeSound = audio.loadSound( "wee.wav" )
	local newRoundSound = audio.loadSound( "newround.wav" )
	local youWinSound = audio.loadSound( "youwin.wav" )
	local youLoseSound = audio.loadSound( "youlose.wav" )
	
	--***************************************************

	-- saveValue() --> used for saving high score, etc.
	
	--***************************************************
	local saveValue = function( strFilename, strValue )
		-- will save specified value to specified file
		local theFile = strFilename
		local theValue = strValue
		
		local path = system.pathForFile( theFile, system.DocumentsDirectory )
		
		-- io.open opens a file at path. returns nil if no file found
		local file = io.open( path, "w+" )
		if file then
		   -- write game score to the text file
		   file:write( theValue )
		   io.close( file )
		end
	end
	
	--***************************************************

	-- loadValue() --> load saved value from file (returns loaded value as string)
	
	--***************************************************
	local loadValue = function( strFilename )
		-- will load specified file, or create new file if it doesn't exist
		
		local theFile = strFilename
		
		local path = system.pathForFile( theFile, system.DocumentsDirectory )
		
		-- io.open opens a file at path. returns nil if no file found
		local file = io.open( path, "r" )
		if file then
		   -- read all contents of file into a string
		   local contents = file:read( "*a" )
		   io.close( file )
		   return contents
		else
		   -- create file b/c it doesn't exist yet
		   file = io.open( path, "w" )
		   file:write( "0" )
		   io.close( file )
		   return "0"
		end
	end
	
	local startNewRound = function()
		if ghostObject then
			
			local activateRound = function()
				
				canSwipe = true
				waitingForNewRound = false
						
				if restartTimer then
					timer.cancel( restartTimer )
				end
				
				groundLight1:toFront()
				groundObject1:toFront()
				groundObject2:toFront()
				ghostObject.x = 150; --ghostObject.y = 195
				ghostObject.y = 300;
				ghostObject:stopAtFrame( 1 )
				ghostObject.rotation = 0
				ghostObject.isVisible = true
				ghostObject.isBodyActive = true
				
				audio.play( newRoundSound )
				
				local ghostLoaded = function()
					
					gameIsActive = true
					ghostObject.inAir = false
					ghostObject.isHit = false
					ghostObject:toFront()
					
					ghostObject.bodyType = "static"
					
					-- Show the pause button
					pauseBtn.isVisible = true
					pauseBtn.isActive = true
					
					-- START up and down animation
					if ghostTween then
						transition.cancel( ghostTween )
					end
					
					local function ghostAnimation()
						local animUp = function()
							if ghostObject.inAir or shotOrb.isVisible then
								transition.cancel( ghostTween )
							else
								ghostTween = transition.to( ghostObject, { time=375, y=190, onComplete=ghostAnimation })
							end
						end
						
						if ghostObject.inAir or shotOrb.isVisible then
							transition.cancel( ghostTween )
						else
							ghostTween = transition.to( ghostObject, { time=375, y=200, onComplete=animUp })
						end
					end
					
					ghostTween = transition.to( ghostObject, { time=375, y=190, onComplete=ghostAnimation })
					
					-- END up and down animation
				end
				
				transition.to( ghostObject, { time=1000, y=195, onComplete=ghostLoaded } )
			end
			
			-- reset camera
			if gameGroup.x < 0 then
				transition.to( gameGroup, { time=1000, x=0, transition=easing.inOutExpo, onComplete=activateRound } )
			else
				gameGroup.x = 0
				activateRound()
			end
		end
	end
	
	local comma_value = function(amount)
		local formatted = amount
			while true do  
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if (k==0) then
		  		break
			end
	  	end
		
		return formatted
	end
	
	local setScore = function( scoreNum )
		local newScore = scoreNum
		
		gameScore = newScore
		
		if gameScore < 0 then gameScore = 0; end
		
		scoreText.text = comma_value(gameScore)
		scoreText.xScale = 0.5; scoreText.yScale = 0.5	--> for clear retina display text
		scoreText.x = (480 - (scoreText.contentWidth * 0.5)) - 15
		scoreText.y = 20
	end
	
	local callGameOver = function( isWin )
		
		local isWin = isWin
		
		if isWin == "yes" then
			audio.play( youWinSound )
		else
			audio.play( youLoseSound )
		end
		
		gameIsActive = false	--> temporarily disable gameplay touches, enterFrame listener, etc.
		physics.pause()
		
		-- Make sure pause button is hidden/inactive
		pauseBtn.isVisible = false
		pauseBtn.isActive = false
		
		if continueTimer then timer.cancel( continueTimer ); end
		continueText.isVisible = false
		
		-- Create all game over objects and insert them into the HUD group
		
		-- SHADE
		local shadeRect = display.newRect( 0, 0, 480, 320 )
		shadeRect:setFillColor( 0, 0, 0, 255 )
		shadeRect.alpha = 0
		
		
		-- GAME OVER WINDOW
		local gameOverDisplay
		
		if isWin == "yes" then
			gameOverDisplay = display.newImageRect( "youwin.png", 390, 154 )
			
			-- Give score bonus depending on how many ghosts left
			local ghostBonus = gameLives * 20000
			local newScore = gameScore + ghostBonus
			setScore( newScore )
			
		else
			gameOverDisplay = display.newImageRect( "youlose.png", 390, 154 )
		end
		
		gameOverDisplay.x = 240; gameOverDisplay.y = 165
		gameOverDisplay.alpha = 0
		
		-- MENU BUTTON
		local onMenuTouch = function( event )
			if event.phase == "release" then
				audio.play( tapSound )
				director:changeScene( "loadmainmenu" )
			end
		end
		
		local menuBtn = ui.newButton{
			defaultSrc = "menubtn.png",
			defaultX = 60,
			defaultY = 60,
			overSrc = "menubtn-over.png",
			overX = 60,
			overY = 60,
			onEvent = onMenuTouch,
			id = "MenuButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		if isWin == "yes" then
			menuBtn.x = 227
		else
			menuBtn.x = 266
		end
		
		menuBtn.y = 186
		menuBtn.alpha = 0
		
		-- RESTART BUTTON
		local onRestartTouch = function( event )
			if event.phase == "release" then
				audio.play( tapSound )
				local theModule = "load" .. restartModule
				director:changeScene( theModule )
			end
		end
		
		local restartBtn = ui.newButton{
			defaultSrc = "restartbtn.png",
			defaultX = 60,
			defaultY = 60,
			overSrc = "restartbtn-over.png",
			overX = 60,
			overY = 60,
			onEvent = onRestartTouch,
			id = "RestartButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		restartBtn.x = menuBtn.x + 72; restartBtn.y = 186
		restartBtn.alpha = 0
		
		-- NEXT BUTTON
		local onNextTouch = function( event )
			if event.phase == "release" then
				audio.play( tapSound )
				local theModule = "load" .. nextModule
				director:changeScene( theModule )
			end
		end
		
		local nextBtn = ui.newButton{
			defaultSrc = "nextlevelbtn.png",
			defaultX = 60,
			defaultY = 60,
			overSrc = "nextlevelbtn-over.png",
			overX = 60,
			overY = 60,
			onEvent = onNextTouch,
			id = "NextButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		nextBtn.x = restartBtn.x + 72; nextBtn.y = 186
		nextBtn.alpha = 0
		if isWin ~= "yes" then nextBtn.isVisible = false; end
		
		-- OPENFEINT BUTTON
		local onOFTouch = function( event )
			if event.phase == "release" then
				audio.play( tapSound )
				-- Launch OpenFeint Leaderboards Panel:
				--openfeint.launchDashboard("leaderboards")
				
			end
		end
		
		local ofBtn = ui.newButton{
			defaultSrc = "openfeintbtn.png",
			defaultX = 168,
			defaultY = 40,
			overSrc = "openfeintbtn-over.png",
			overX = 168,
			overY = 40,
			onEvent = onOFTouch,
			id = "OpenfeintButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		ofBtn.x = 168; ofBtn.y = 110
		ofBtn.alpha = 0
		
		local fbBtn
		
		-- FACEBOOK BUTTON
		local onFBTouch = function( event )
			if event.phase == "release" and fbBtn.isActive then
				audio.play( tapSound )
				
				-- Code to Post Status to Facebook (don't forget the 'require "facebook"' line at top of module)
				-- The Code below is fully functional as long as you replace the fbAppID var with valid app ID.
				
				--[[
				local fbAppID = "1234567890"	--> (string) Your FB App ID from facebook developer's panel
				
				local facebookListener = function( event )
					if ( "session" == event.type ) then
						-- upon successful login, update their status
						if ( "login" == event.phase ) then
							
							local scoreToPost = comma_value(gameScore)
							
							local statusUpdate = "just scored a " .. gameScore .. " on Ghosts v.s Monsters!"
							
							facebook.request( "me/feed", "POST", {
								message=statusUpdate,
								name="Download Ghosts vs. Monsters to Compete with Me!",
								caption="Ghosts vs. Monsters - Sample app created with the Corona SDK by Ansca Mobile.",
								link="http://itunes.apple.com/us/app/your-app-name/id382456881?mt=8",
								picture="http://www.yoursite.com/link-to-90x90-image.png" } )
						end
					end
				end
				
				facebook.login( fbAppID, facebookListener, { "publish_stream" } )
				]]--
			end
		end
		
		fbBtn = ui.newButton{
			defaultSrc = "facebookbtn.png",
			defaultX = 302,
			defaultY = 40,
			overSrc = "facebookbtn-over.png",
			overX = 302,
			overY = 40,
			onEvent = onFBTouch,
			id = "FacebookButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		fbBtn.x = 240; fbBtn.y = 220
		fbBtn.alpha = 0
		
		if isWin == "yes" then
			fbBtn.isVisible = true
			fbBtn.isActive = true
		else
			fbBtn.isVisible = false
			fbBtn.isActive = false
		end
		
		-- INSERT ALL ITEMS INTO GROUP
		hudGroup:insert( shadeRect )
		hudGroup:insert( ofBtn )
		hudGroup:insert( fbBtn )
		hudGroup:insert( gameOverDisplay )
		hudGroup:insert( menuBtn )
		hudGroup:insert( restartBtn )
		if isWin == "yes" then hudGroup:insert( nextBtn ); end
		
		-- FADE IN ALL GAME OVER ELEMENTS
		transition.to( shadeRect, { time=200, alpha=0.65 } )
		transition.to( gameOverDisplay, { time=500, alpha=1 } )
		transition.to( menuBtn, { time=500, alpha=1 } )
		transition.to( restartBtn, { time=500, alpha=1 } )
		if isWin == "yes" then transition.to( nextBtn, { time=500, alpha=1 } ); end
		transition.to( ofBtn, { time=500, alpha=1, y=68, transition=easing.inOutExpo } )
		if isWin == "yes" then transition.to( fbBtn, { time=500, alpha=1, y=255, transition=easing.inOutExpo } ); end
		
		-- MAKE SURE SCORE TEXT IS VISIBLE (if player won the round)
		if isWin == "yes" then
			scoreText.isVisible = false
			local oldScoreText = scoreText.text
			scoreText.text = "Score: " .. oldScoreText
			scoreText.xScale = 0.5; scoreText.yScale = 0.5	--> for clear retina display text
			scoreText.x = (480 - (scoreText.contentWidth * 0.5)) - 30
			scoreText.y = 30
			scoreText:toFront()
			timer.performWithDelay( 1000, function() scoreText.isVisible = true; end, 1 )
		else
			scoreText:removeSelf()
			scoreText = nil
		end
		
		-- Update Best Score
		if gameScore > bestScore then
			bestScore = gameScore
			local bestScoreFilename = restartModule .. ".data"
			saveValue( bestScoreFilename, tostring(bestScore) )
		end
		
		-- MAKE SURE BEST SCORE TEXT IS VISIBLE
		bestScoreText = display.newText( "0", 10, 300, "Helvetica-Bold", 32 )
		bestScoreText:setTextColor( 228, 228, 228, 255 )	--> white
		bestScoreText.text = "Best Score For This Level: " .. comma_value( bestScore )
		bestScoreText.xScale = 0.5; bestScoreText.yScale = 0.5	--> for clear retina display text
		bestScoreText.x = (bestScoreText.contentWidth * 0.5) + 15
		bestScoreText.y = 304
		
		hudGroup:insert( bestScoreText )
	end
	
	local callNewRound = function( shouldPoof, instantPoof )
		local shouldPoof = shouldPoof
		local instantPoof = instantPoof
		local isGameOver = false
		
		if blastGlow.isVisible then
			blastGlow.isVisible = false
		end
		
		if gameLives >= 1 then
			gameLives = gameLives - 1
			
			if gameLives == 3 then
				life4.alpha = 0.3
				if monsterCount < 1 then isGameOver = true; end
			elseif gameLives == 2 then
				life4.alpha = 0.3
				life3.alpha = 0.3
				if monsterCount < 1 then isGameOver = true; end
			elseif gameLives == 1 then
				life4.alpha = 0.3
				life3.alpha = 0.3
				life2.alpha = 0.3
				if monsterCount < 1 then isGameOver = true; end
			elseif gameLives == 0 then
				life4.alpha = 0.3
				life3.alpha = 0.3
				life2.alpha = 0.3
				life1.alpha = 0.3
				isGameOver = true
			end
		elseif gameLives < 0 then
			gameLives = 0
			life4.alpha = 0.3
			life3.alpha = 0.3
			life2.alpha = 0.3
			life1.alpha = 0.3
			isGameOver = true
		else
			life4.alpha = 0.3
			life3.alpha = 0.3
			life2.alpha = 0.3
			life1.alpha = 0.3
			isGameOver = true
		end
			
		
		if shouldPoof then
				
			local poofTheGhost = function()
				local theDelay = 300
				
				-- Make ghost disappear and show "poof" animation
				ghostObject:setLinearVelocity( 0, 0 )
				ghostObject.bodyType = "static"
				ghostObject.isVisible = false
				ghostObject.isBodyActive = false
				ghostObject.rotation = 0
				
				-- Poof code below --
				audio.play( ghostPoofSound )
				poofObject.x = ghostObject.x; poofObject.y = ghostObject.y
				poofObject.alpha = 0
				poofObject.isVisible = true
				
				local fadePoof = function()
					transition.to( poofObject, { time=2000, alpha=0 } )	
				end
				transition.to( poofObject, { time=100, alpha=1.0, onComplete=fadePoof } )
				
				-- Move camera to far right to see effect
				if gameGroup.x > -480 then
					local camTween = transition.to( gameGroup, { time=500, x=-480 } )
				end
				
				local continueBlink = function()
					 local startBlinking = function()
					 	if continueText.isVisible then
					 		continueText.isVisible = false
					 	else
					 		continueText.isVisible = true
					 	end
					 end
					 
					 continueTimer = timer.performWithDelay( 350, startBlinking, 0 )
				end
				
				restartTimer = timer.performWithDelay( theDelay, function()
					waitingForNewRound = true;
					continueBlink();
				end, 1 )
				
				--[[
				if not isGameOver then
					restartTimer = timer.performWithDelay( theDelay, function() waitingForNewRound = true; end, 1 )
				else
					if monsterCount > 0 then
						restartTimer = timer.performWithDelay( theDelay, function() callGameOver( "no" ); end, 1 )
					else
						restartTimer = timer.performWithDelay( 3000, function() callGameOver( "yes" ); end, 1 )
					end
				end
				]]--
			end
			
			if instantPoof == "yes" then
				local poofTimer = timer.performWithDelay( 500, poofTheGhost, 1 )
			else
				local poofTimer = timer.performWithDelay( 1700, poofTheGhost, 1 )
			end
		else
			
			ghostObject:setLinearVelocity( 0, 0 )
			ghostObject.bodyType = "static"
			ghostObject.isVisible = false
			ghostObject.isBodyActive = false
			ghostObject.rotation = 0
			
			--restartTimer = timer.performWithDelay( 300, startNewRound, 1 )
			
			if not isGameOver then
				restartTimer = timer.performWithDelay( 300, startNewRound, 1 )
			else
				if monsterCount > 0 then
					restartTimer = timer.performWithDelay( 300, function() callGameOver( "no" ); end, 1 )
				else
					restartTimer = timer.performWithDelay( 300, function() callGameOver( "yes" ); end, 1 )
				end
			end
		end
	end
	
	local drawBackground = function()
		-- Background gets drawn in this order: backdrop, clouds, trees, red glow
		
		-- BACKDROP
		backgroundImage1 = display.newImageRect( backgroundFilename1, 480, 320 )
		backgroundImage1:setReferencePoint( display.CenterLeftReferencePoint )
		backgroundImage1.x = 0; backgroundImage1.y = 160
		
		backgroundImage2 = display.newImageRect( backgroundFilename2, 480, 320 )
		backgroundImage2:setReferencePoint( display.CenterLeftReferencePoint )
		backgroundImage2.x = 480; backgroundImage2.y = 160
		
		gameGroup:insert( backgroundImage1 )
		gameGroup:insert( backgroundImage2 )
		
		-- CLOUDS
		clouds1 = display.newImageRect( "clouds-left.png", 480, 320 )
		clouds1.x = 240; clouds1.y = 160
		
		clouds2 = display.newImageRect( "clouds-right.png", 480, 320 )
		clouds2.x = 720; clouds2.y = 160
		
		clouds3 = display.newImageRect( "clouds-left.png", 480, 320 )
		clouds3.x = 1200; clouds3.y = 160
		
		clouds4 = display.newImageRect( "clouds-right.png", 480, 320 )
		clouds4.x = 1680; clouds4.y = 160
		
		gameGroup:insert( clouds1 )
		gameGroup:insert( clouds2 )
		gameGroup:insert( clouds3 )
		gameGroup:insert( clouds4 )
		
		-- TREES
		local treesLeft = display.newImageRect( "trees-left.png", 480, 320 )
		treesLeft.x = 240; treesLeft.y = 160
		
		local treesRight = display.newImageRect( "trees-right.png", 480, 320 )
		treesRight.x = 720; treesRight.y = 160
		
		gameGroup:insert( treesLeft )
		gameGroup:insert( treesRight )
		
		-- RED GLOW
		--[[
		local redGlow = display.newImageRect( "redglow.png", 480, 320 )
		redGlow.x = 725; redGlow.y = 160
		redGlow.alpha = 0.5
		
		gameGroup:insert( redGlow )
		]]--
	end
	
	local drawHUD = function()
		-- TWO BLACK RECTANGLES AT TOP AND BOTTOM (for those viewing from iPad)
		local topRect = display.newRect( 0, -160, 480, 160 )
		topRect:setFillColor( 0, 0, 0, 255 )
		
		local bottomRect = display.newRect( 0, 320, 480, 160 )
		bottomRect:setFillColor( 0, 0, 0, 255 )
		
		hudGroup:insert( topRect )
		hudGroup: insert( bottomRect )
		
		-- LIVES DISPLAY
		life1 = display.newImageRect( "lifeicon.png", 22, 22 )
		life1.x = 20; life1.y = 18
		
		life2 = display.newImageRect( "lifeicon.png", 22, 22 )
		life2.x = life1.x + 25; life2.y = 18
		
		life3 = display.newImageRect( "lifeicon.png", 22, 22 )
		life3.x = life2.x + 25; life3.y = 18
		
		life4 = display.newImageRect( "lifeicon.png", 22, 22 )
		life4.x = life3.x + 25; life4.y = 18
		
		hudGroup:insert( life1 )
		hudGroup:insert( life2 )
		hudGroup:insert( life3 )
		hudGroup:insert( life4 )
		
		-- SCORE DISPLAY
		scoreText = display.newText( "0", 470, 22, "Helvetica-Bold", 52 )
		scoreText:setTextColor( 255, 255, 255, 255 )	--> white
		scoreText.text = gameScore
		scoreText.xScale = 0.5; scoreText.yScale = 0.5	--> for clear retina display text
		scoreText.x = (480 - (scoreText.contentWidth * 0.5)) - 15
		scoreText.y = 20
		
		hudGroup:insert( scoreText )
		
		-- TAP TO CONTINUE DISPLAY
		continueText = display.newText( "TAP TO CONTINUE", 240, 18, "Helvetica", 36 )
		continueText:setTextColor( 249, 203, 64, 255 )
		continueText.xScale = 0.5; continueText.yScale = 0.5
		continueText.x = 240; continueText.y = 18
		continueText.isVisible = false
		
		hudGroup:insert( continueText )
		
		-- PAUSE BUTTON
		local onPauseTouch = function( event )
			if event.phase == "release" and pauseBtn.isActive then
				audio.play( tapSound )
				
				-- Pause the game
				
				if gameIsActive then
				
					gameIsActive = false
					physics.pause()
					
					-- SHADE
					if not shadeRect then
						shadeRect = display.newRect( 0, 0, 480, 320 )
						shadeRect:setFillColor( 0, 0, 0, 255 )
						hudGroup:insert( shadeRect )
					end
					shadeRect.alpha = 0.5
					
					-- SHOW MENU BUTTON
					if pauseMenuBtn then
						pauseMenuBtn.isVisible = true
						pauseMenuBtn.isActive = true
						pauseMenuBtn:toFront()
					end
					
					pauseBtn:toFront()
					
					-- STOP GHOST ANIMATION
					if ghostTween then
						transition.cancel( ghostTween )
					end
				else
					
					if shadeRect then
						shadeRect:removeSelf()
						shadeRect = nil
					end
					
					if pauseMenuBtn then
						pauseMenuBtn.isVisible = false
						pauseMenuBtn.isActive = false
					end
					
					gameIsActive = true
					physics.start()
					
					-- START Ghost animation back up
					if ghostTween then
						transition.cancel( ghostTween )
					end
					
					local function ghostAnimation()
						local animUp = function()
							if ghostObject.inAir or shotOrb.isVisible then
								transition.cancel( ghostTween )
							else
								ghostTween = transition.to( ghostObject, { time=375, y=190, onComplete=ghostAnimation })
							end
						end
						
						if ghostObject.inAir or shotOrb.isVisible then
							transition.cancel( ghostTween )
						else
							ghostTween = transition.to( ghostObject, { time=375, y=200, onComplete=animUp })
						end
					end
					
					ghostTween = transition.to( ghostObject, { time=375, y=190, onComplete=ghostAnimation })
				end
			end
		end
		
		pauseBtn = ui.newButton{
			defaultSrc = "pausebtn.png",
			defaultX = 44,
			defaultY = 44,
			overSrc = "pausebtn-over.png",
			overX = 44,
			overY = 44,
			onEvent = onPauseTouch,
			id = "PauseButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		pauseBtn.x = 442; pauseBtn.y = 288
		pauseBtn.isVisible = false
		pauseBtn.isActive = false
		
		hudGroup:insert( pauseBtn )
		
		-- MENU BUTTON (on Pause Display)
		local onMenuPauseTouch = function( event )
			if event.phase == "release" and pauseMenuBtn.isActive then
				
				audio.play( tapSound )
				
				local onComplete = function ( event )
					if "clicked" == event.action then
						local i = event.index
						if i == 2 then
							-- Player click 'Cancel'; do nothing, just exit the dialog
						elseif i == 1 then
							-- Player clicked Yes, go to main menu
							director:changeScene( "loadmainmenu" )
						end
					end
				end
				
				-- Show alert with two buttons
				local alert = native.showAlert( "Are You Sure?", "Your current game will end.", 
														{ "Yes", "Cancel" }, onComplete )
			end
		end
		
		pauseMenuBtn = ui.newButton{
			defaultSrc = "pausemenubtn.png",
			defaultX = 44,
			defaultY = 44,
			overSrc = "pausemenubtn-over.png",
			overX = 44,
			overY = 44,
			onEvent = onMenuPauseTouch,
			id = "PauseMenuButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		pauseMenuBtn.x = 38; pauseMenuBtn.y = 288
		pauseMenuBtn.isVisible = false
		pauseMenuBtn.isActive = false
		
		hudGroup:insert( pauseMenuBtn )
	end
	
	local createGround = function()
		groundLight1 = display.newImageRect( "groundlight.png", 228, 156 )
		groundLight1.x = 150; groundLight1.y = 190
		
		groundObject1 = display.newImageRect( "ground1.png", 480, 76 )
		groundObject1:setReferencePoint( display.BottomLeftReferencePoint )
		groundObject1.x = 0; groundObject1.y = 320
		
		groundObject2 = display.newImageRect( "ground2.png", 480, 76 )
		groundObject2:setReferencePoint( display.BottomLeftReferencePoint )
		groundObject2.x = 480; groundObject2.y = 320
		
		groundObject1.myName = "ground"
		groundObject2.myName = "ground"
		
		local groundShape = { -240,-18, 240,-18, 240,18, -240,18 }
		physics.addBody( groundObject1, "static", { density=1.0, bounce=0, friction=0.5, shape=groundShape } )
		physics.addBody( groundObject2, "static", { density=1.0, bounce=0, friction=0.5, shape=groundShape } )
		
		gameGroup:insert( groundLight1 )
		gameGroup:insert( groundObject1 )
		gameGroup:insert( groundObject2 )
	end
	
	local createShotOrb = function()
		shotOrb = display.newImageRect( "orb.png", 96, 96 )
		shotOrb.xScale = 1.0; shotOrb.yScale = 1.0
		shotOrb.isVisible = false
		
		gameGroup:insert( shotOrb )
	end
	
	local createGhost = function()
		
		local onGhostCollision = function( self, event )
			if event.phase == "began" then
				
				audio.play( impactSound )
				
				if ghostObject.isHit == false then
				
					if blastGlow.isVisible then
						blastGlow.isVisible = false
					end
					
					
					if dotTimer then timer.cancel( dotTimer ); end
					ghostObject.isHit = true
					
					if event.other.myName == "wood" or event.other.myName == "stone" or event.other.myName == "tomb" or event.other.myName == "monster" then
						callNewRound( true, "yes" )
					else
						callNewRound( true, "no" )
					end
					
					local newScore = gameScore + 500
					setScore( newScore )
				
				elseif ghostObject.isHit then
					return true
				end
			end
		end
		
		-- first, create the transparent arrow that shows up 
		shotArrow = display.newImageRect( "arrow.png", 240, 240 )
		shotArrow.x = 150; shotArrow.y = 195
		shotArrow.isVisible = false
		
		gameGroup:insert( shotArrow )
		
		ghostObject = movieclip.newAnim({ "ghost1-waiting.png", "ghost1.png" }, 26, 26 )
		ghostObject.x = 150; ghostObject.y = 195
		ghostObject.isVisible = false
		
		ghostObject.isReady = false	--> Not "flingable" until touched.
		ghostObject.inAir = false
		ghostObject.isHit = false
		ghostObject.isBullet = true
		ghostObject.trailNum = 0
		
		ghostObject.radius = 12
		physics.addBody( ghostObject, "static", { density=1.0, bounce=0.4, friction=0.15, radius=ghostObject.radius } )
		ghostObject.rotation = 0
		ghostObject:stopAtFrame( 1 )
		
		-- START up and down animation
		
		--ghostTween = transition.to( ghostObject, { time=200, y=192, onComplete=ghostAnimation })
		
		-- END up and down animation
		
		-- Set up collisions
		ghostObject.collision = onGhostCollision
		ghostObject:addEventListener( "collision", ghostObject )
		
		-- Create the Blast Glow
		blastGlow = display.newImageRect( "blastglow.png", 54, 54 )
		blastGlow.x = ghostObject.x; blastGlow.y = ghostObject.y
		blastGlow.isVisible = false
		
		-- Create Poof Objects
		poofObject = display.newImageRect( "poof.png", 80, 70 )
		poofObject.alpha = 1.0
		poofObject.isVisible = false
		
		greenPoof = display.newImageRect( "greenpoof.png", 80, 70 )
		greenPoof.alpha = 1.0
		greenPoof.isVisible = false
		
		-- Insert objects into main group
		gameGroup:insert( trailGroup )
		gameGroup:insert( blastGlow )
		gameGroup:insert( ghostObject )
		gameGroup:insert( poofObject )
		gameGroup:insert( greenPoof )
	end
	
	local onMonsterPostCollision = function( self, event )
		if event.force > 1.5 and self.isHit == false then
			audio.play( monsterPoofSound )
			
			self.isHit = true
			print( "Monster destroyed! Force: " .. event.force )
			self.isVisible = false
			self.isBodyActive = false
			
			-- Poof code below --
			if poofTween then transition.cancel( poofTween ); end
			
			greenPoof.x = self.x; greenPoof.y = self.y
			greenPoof.alpha = 0
			greenPoof.isVisible = true
			
			local fadePoof = function()
				transition.to( greenPoof, { time=500, alpha=0 } )	
			end
			poofTween = transition.to( greenPoof, { time=50, alpha=1.0, onComplete=fadePoof } )
			
			monsterCount = monsterCount - 1
			if monsterCount < 0 then monsterCount = 0; end
			
			self.parent:remove( self )
			self = nil
			
			local newScore = gameScore + mCeil(5000 * event.force)
			setScore( newScore )
		end
	end
	
	local onScreenTouch = function( event )
		if gameIsActive then
			if event.phase == "began" and ghostObject.inAir == false and event.xStart > 115 and event.xStart < 180 and event.yStart > 160 and event.yStart < 230 and screenPosition == "left" then
				
				transition.cancel( ghostTween )
				ghostObject.y = 195
				ghostObject.isReady = true
				shotOrb.isVisible = true
				shotOrb.alpha = 0.75
				shotOrb.x = ghostObject.x; shotOrb.y = ghostObject.y
				shotOrb.xScale = 0.1; shotOrb.yScale = 0.1
				
				shotArrow.isVisible = true
			
			elseif event.phase == "began" and waitingForNewRound then
				
				waitingForNewRound = false
				if continueTimer then timer.cancel( continueTimer ); end
				continueText.isVisible = false
				
				if gameLives < 1 then
					-- GAME OVER
					if monsterCount < 1 then
						callGameOver( "yes" )
					else
						callGameOver( "no" )
					end
				elseif monsterCount < 1 and gameLives >= 1 then
					
					callGameOver( "yes" )
				else
					startNewRound()
				end
			
			elseif event.phase == "began" and waitingForNewRound == false then
				
				if continueTimer then timer.cancel( continueTimer ); end
				continueText.isVisible = false
				
				if gameLives < 1 then
					-- GAME OVER
					if monsterCount < 1 then
						callGameOver( "yes" )
					else
						callGameOver( "no" )
					end
				elseif monsterCount < 1 and gameLives >= 1 then
					
					callGameOver( "yes" )
				end
				
			elseif event.phase == "ended" and ghostObject.isReady == false and ghostObject.inAir == false and canSwipe == true then
				
				local leftRight
				
				if event.xStart > event.x then
					leftRight = "left"
				elseif event.xStart < event.x then
					leftRight = "right"
				end
				
				-- Swipe to view other end of the screen
				if leftRight == "left" and screenPosition == "left" and event.xStart > 180 then
					-- Swiped game screen to the left
					print( "Swiped left!" )
					canSwipe = false
					
					local switchPosition = function()
						screenPosition = "right"
						local swipeTimer = timer.performWithDelay( 200, function() canSwipe = true; end, 1 )
					end
					
					if swipeTween then
						transition.cancel( swipeTween )
					end
					
					if (event.xStart - event.x) >= 100 then
						swipeTween = transition.to( gameGroup, { time=700, x=-480, onComplete=switchPosition } )
					else
						swipeTween = transition.to( gameGroup, { time=100, x=0, onComplete=function() canSwipe = true; end } )
					end
					
				elseif leftRight == "right" and screenPosition == "right" then
					-- Swiped screen to the right
					print( "Swiped right!" )
					canSwipe = false
					
					local switchPosition = function()
						screenPosition = "left"
						local swipeTimer = timer.performWithDelay( 200, function() canSwipe = true; end, 1 )
					end
					
					if swipeTween then
						transition.cancel( swipeTween )
					end
					
					if (event.x - event.xStart) >= 100 then
						swipeTween = transition.to( gameGroup, { time=700, x=0, onComplete=switchPosition } )
					else
						swipeTween = transition.to( gameGroup, { time=100, x=-480, onComplete=function() canSwipe = true; end } )
					end
					
				end
				
			elseif event.phase == "ended" and ghostObject.isReady then
				-- Finger lifted from screen; fling the Roly Poly!
				
				local flingNow = function()
					-- handle the shot orb and disable screen swiping
					transition.cancel( ghostTween )
					shotOrb.isVisible = false
					shotArrow.isVisible = false
					canSwipe = false
					
					local x = event.x
					local y = event.y
					local xForce = (-1 * (x - ghostObject.x)) * 2.15	--> 2.75
					local yForce = (-1 * (y - ghostObject.y)) * 2.15	--> 2.75
					
					audio.play( weeSound )
					
					ghostObject:stopAtFrame( 2 )
					ghostObject.bodyType = "dynamic"
					ghostObject:applyForce( xForce, yForce, ghostObject.x, ghostObject.y )
					ghostObject.isReady = false
					ghostObject.inAir = true
					
					-- START TRAILING DOTS BLOCK
					local i
					
					-- First, delete previous trail
					for i = trailGroup.numChildren,1,-1 do
						local child = trailGroup[i]
						child.parent:remove( child )
						child = nil
					end
					
					local startDotCreation = function()
						local createDot = function()
							local trailDot
							
							if ghostObject.trailNum == 0 then
								trailDot = display.newCircle( gameGroup, ghostObject.x, ghostObject.y, 2.5 )
							else
								trailDot = display.newCircle( gameGroup, ghostObject.x, ghostObject.y, 1.5 )
							end
							trailDot:setFillColor( 255, 255, 255, 255 )
							trailDot.alpha = 1.0
							
							trailGroup:insert( trailDot )
							--gameGroup:insert( trailGroup )
							
							
							if ghostObject.trailNum == 0 then
								ghostObject.trailNum = 1
							else
								ghostObject.trailNum = 0
							end
						end
						
						dotTimer = timer.performWithDelay( 50, createDot, 50 )
					end
					
					local startDotTimer = timer.performWithDelay( 50, startDotCreation, 1 )
					-- END TRAILING DOTS BLOCK
					
					-- Show the blast glow
					blastGlow.x = ghostObject.x
					blastGlow.y = ghostObject.y
					blastGlow.isVisible = true
				end
				
				transition.to( shotOrb, { time=175, xScale=0.1, yScale=0.1, onComplete=flingNow } )
				
				audio.play( blastOffSound )
				
				-- Make sure pause button is hidden/inactive
				pauseBtn.isVisible = false
				pauseBtn.isActive = false
			end
			
			if shotOrb.isVisible == true then
				
				local xOffset = ghostObject.x
				local yOffset = ghostObject.y
				
				-- Formula math.sqrt( ((event.y - yOffset) ^ 2) + ((event.x - xOffset) ^ 2) )
				local distanceBetween = mCeil(mSqrt( ((event.y - yOffset) ^ 2) + ((event.x - xOffset) ^ 2) ))
				
				shotOrb.xScale = -distanceBetween * 0.02
				shotOrb.yScale = -distanceBetween * 0.02
				
				-- Formula: 90 + (math.atan2(y2 - y1, x2 - x1) * 180 / PI)
				local angleBetween = mCeil(mAtan2( (event.y - yOffset), (event.x - xOffset) ) * 180 / mPi) + 90
				
				ghostObject.rotation = angleBetween + 180
				shotArrow.rotation = ghostObject.rotation
			end
			
			if canSwipe == true then
				
				if screenPosition == "left" then
					-- Swipe left to go right
					if event.xStart > 180 then
						gameGroup.x = event.x - event.xStart
						
						if gameGroup.x > 0 then
							gameGroup.x = 0
							canSwipe = true
						end
					end
						
				elseif screenPosition == "right" then
					-- Swipe right to go to the left
					gameGroup.x = (event.x - event.xStart) - 480
					
					if gameGroup.x < -480 then
						gameGroup.x = -480
						canSwipe = true
					end
				end
			end
		end
	end
	
	-- Main enterFrame Listener
	local gameLoop = function()
		if gameIsActive then
			-- CAMERA CONTROL
			if ghostObject.x > 240 and ghostObject.x < 720 and not waitingForNewRound then
				gameGroup.x = -ghostObject.x + 240
			end
				
			
			-- MAKE SURE GHOST's Rotation Doesn't Go Past Limits
			if ghostObject.inAir then
				if ghostObject.rotation < -45 then
					ghostObject.rotation = -45
				elseif ghostObject.rotation > 30 then
					ghostObject.rotation = 30
				end
			end
			
			-- Make sure Blast Glow's Rotation is Equal to the Ghost's
			if blastGlow.isVisible then
				blastGlow.rotation = ghostObject.rotation
				blastGlow.x = ghostObject.x - 10
				blastGlow.y = ghostObject.y + 3
			end
			
			
			-- MOVE CLOUDS SLOWLY
			local cloudMoveSpeed = 0.5
			
			clouds1.x = clouds1.x - cloudMoveSpeed
			clouds2.x = clouds2.x - cloudMoveSpeed
			clouds3.x = clouds3.x - cloudMoveSpeed
			clouds4.x = clouds4.x - cloudMoveSpeed
			
			if clouds1.x <= -240 then
				clouds1.x = 1680
			end
			
			if clouds2.x <= -240 then
				clouds2.x = 1680
			end
			
			if clouds3.x <= -240 then
				clouds3.x = 1680
			end
			
			if clouds4.x <= -240 then
				clouds4.x = 1680
			end
			-- END CLOUD MOVEMENT
			
			-- CHECK IF GHOST GOES PAST SCREEN
			if ghostObject.isHit == false and ghostObject.x >= 960 then
				ghostObject.isHit = true
				if dotTimer then timer.cancel( dotTimer ); end
				callNewRound( false, "no" )
			end
			
			if ghostObject.isHit == false and ghostObject.x < 0 then
				if dotTimer then timer.cancel( dotTimer ); end
				ghostObject.isHit = true
				if dotTimer then timer.cancel( dotTimer ); end
				callNewRound( false, "no" )
			end
		end
	end
	
	local reorderLayers = function()
		
		gameGroup:insert( levelGroup )
		groundObject1:toFront()
		groundObject2:toFront()
		ghostObject:toFront()
		poofObject:toFront()
		greenPoof:toFront()
		hudGroup:toFront()
		
	end
	
	-- *********************************************************************************************
	
	-- createLevel() function (should be the only function that's different in each level module
	
	-- *********************************************************************************************
	
	local createLevel = function()
		
		restartModule = "level1"
		nextModule = "level2"
		monsterCount = 2
	
		-- FIRST VERTICAL SLAB
		local vSlab1 = display.newImageRect( "vertical-stone.png", 28, 58 )
		vSlab1.x = 600; vSlab1.y = 215
		vSlab1.myName = "stone"
		
		physics.addBody( vSlab1, "dynamic", { density=stoneDensity, bounce=0, friction=0.5, shape=vSlabShape } )
		levelGroup:insert( vSlab1 )
		
		-- SECOND VERTICAL SLAB
		local vSlab2 = display.newImageRect( "vertical-stone.png", 28, 58 )
		vSlab2.x = 646; vSlab2.y = 215
		vSlab2.myName = "stone"
		
		physics.addBody( vSlab2, "dynamic", { density=stoneDensity, bounce=0, friction=0.5, shape=vSlabShape } )
		levelGroup:insert( vSlab2 )
		
		-- FIRST VERTICAL PLANK
		local vPlank1 = display.newImageRect( "vertical-wood.png", 14, 98 )
		vPlank1.x = 623; vPlank1.y = 215
		vPlank1.myName = "wood"
		
		physics.addBody( vPlank1, "dynamic", { density=woodDensity, bounce=0, friction=0.5, shape=vPlankShape } ) 
		levelGroup:insert( vPlank1 )
		
		-- SECOND VERTICAL PLANK
		local vPlank2 = display.newImageRect( "vertical-wood.png", 14, 98 )
		vPlank2.x = 723; vPlank2.y = 215
		vPlank2.myName = "wood"
		
		physics.addBody( vPlank2, "dynamic", { density=woodDensity, bounce=0, friction=0.5, shape=vPlankShape } ) 
		levelGroup:insert( vPlank2 )
		
		-- THIRD VERTICAL PLANK
		local vPlank3 = display.newImageRect( "vertical-wood.png", 14, 98 )
		vPlank3.x = 821; vPlank3.y = 215
		vPlank3.myName = "wood"
		
		physics.addBody( vPlank3, "dynamic", { density=woodDensity, bounce=0, friction=0.5, shape=vPlankShape } ) 
		levelGroup:insert( vPlank3 )
		
		-- SECOND VERTICAL SLAB STACK
		local vSlab3 = display.newImageRect( "vertical-stone.png", 28, 58 )
		vSlab3.x = 800; vSlab3.y = 215
		vSlab3.myName = "stone"
		
		physics.addBody( vSlab3, "dynamic", { density=stoneDensity, bounce=0, friction=0.5, shape=vSlabShape } )
		levelGroup:insert( vSlab3 )
		
		local vSlab4 = display.newImageRect( "vertical-stone.png", 28, 58 )
		vSlab4.x = 843; vSlab4.y = 215
		vSlab4.myName = "stone"
		
		physics.addBody( vSlab4, "dynamic", { density=stoneDensity, bounce=0, friction=0.5, shape=vSlabShape } )
		levelGroup:insert( vSlab4 )
		
		-- HORIZONTAL PLANK 1
		local hPlank1 = display.newImageRect( "horizontal-wood.png", 98, 14 )
		hPlank1.x = 674; hPlank1.y = 162
		hPlank1.myName = "wood"
		
		physics.addBody( hPlank1, "dynamic", { density=woodDensity, bounce=0, friction=0.5, shape=hPlankShape } ) 
		levelGroup:insert( hPlank1 )
		
		-- HORIZONTAL PLANK 2
		local hPlank2 = display.newImageRect( "horizontal-wood.png", 98, 14 )
		hPlank2.x = 772; hPlank2.y = 162
		hPlank2.myName = "wood"
		
		physics.addBody( hPlank2, "dynamic", { density=woodDensity, bounce=0, friction=0.5, shape=hPlankShape } ) 
		levelGroup:insert( hPlank2 )
		
		local hPlank4 = display.newImageRect( "horizontal-wood.png", 98, 14 )
		hPlank4.x = 723; hPlank4.y = 143
		hPlank4.myName = "wood"
		
		physics.addBody( hPlank4, "dynamic", { density=woodDensity, bounce=0, friction=0.5, shape=hPlankShape } ) 
		levelGroup:insert( hPlank4 )
		
		-- TOP TOMBSTONES
		local tombStone1 = display.newImageRect( "tombstone.png", 38, 46 )
		tombStone1.x = 650; tombStone1.y = 128
		tombStone1.myName = "tomb"
		
		physics.addBody( tombStone1, "dynamic", { density=woodDensity, bounce=0, friction=0.5, shape=tombShape } ) 
		levelGroup:insert( tombStone1 )
		
		local tombStone2 = display.newImageRect( "tombstone.png", 38, 46 )
		tombStone2.x = 796; tombStone2.y = 128
		tombStone2.myName = "tomb"
		
		physics.addBody( tombStone2, "dynamic", { density=woodDensity, bounce=0, friction=0.5, shape=tombShape } ) 
		levelGroup:insert( tombStone2 )
		
		-- MONSTERS
		local monster1 = display.newImageRect( "monster.png", 26, 30 )
		monster1.x = 745; monster1.y = 125
		monster1.myName = "monster"
		monster1.isHit = false
		
		physics.addBody( monster1, "dynamic", { density=monsterDensity, bounce=0, friction=0.5, shape=monsterShape } ) 
		levelGroup:insert( monster1 )
		
		monster1.postCollision = onMonsterPostCollision
		monster1:addEventListener( "postCollision", monster1 )
		
		local monster2 = display.newImageRect( "monster.png", 26, 30 )
		monster2.x = 700; monster2.y = 125
		monster2.myName = "monster"
		monster2.isHit = false
		
		monster2.postCollision = onMonsterPostCollision
		monster2:addEventListener( "postCollision", monster2 )
		
		physics.addBody( monster2, "dynamic", { density=monsterDensity, bounce=0, friction=0.5, shape=monsterShape } ) 
		levelGroup:insert( monster2 )
		
		-- SET PROPER DRAW ORDER:
		reorderLayers()
	end
	
	-- *********************************************************************************************
	
	-- END createLevel() function
	
	-- *********************************************************************************************
	
	local onSystem = function( event )
		if event.type == "applicationSuspend" then
			if gameIsActive and pauseBtn.isVisible then
				gameIsActive = false
				physics.pause()
				
				-- SHADE
				if not shadeRect then
					shadeRect = display.newRect( 0, 0, 480, 320 )
					shadeRect:setFillColor( 0, 0, 0, 255 )
					hudGroup:insert( shadeRect )
				end
				shadeRect.alpha = 0.5
				
				-- SHOW MENU BUTTON
				if pauseMenuBtn then
					pauseMenuBtn.isVisible = true
					pauseMenuBtn.isActive = true
					pauseMenuBtn:toFront()
				end
				
				pauseBtn:toFront()
				
				-- STOP GHOST ANIMATION
				if ghostTween then
					transition.cancel( ghostTween )
				end
			end
			
		elseif event.type == "applicationExit" then
			if system.getInfo( "environment" ) == "device" then
				-- prevents iOS 4+ multi-tasking crashes
				os.exit()
			end
		end
	end
	
	local gameInit = function()
		
		-- PHYSICS
		physics.start( true )
		physics.setDrawMode( "normal" )	-- set to "debug" or "hybrid" to see collision boundaries
		physics.setGravity( 0, 11 )	--> 0, 9.8 = Earth-like gravity
		
		-- DRAW GAME OBJECTS
		drawBackground()
		createGround()
		createShotOrb()
		createGhost()
		
		-- CREATE LEVEL
		createLevel()
		
		-- DRAW HEADS-UP DISPLAY (score, lives, etc)
		drawHUD()
		
		-- LOAD BEST SCORE FOR THIS LEVEL
		local bestScoreFilename = restartModule .. ".data"
		local loadedBestScore = loadValue( bestScoreFilename )	--> restartModule should be "level1" or "level2", etc.
		
		bestScore = tonumber(loadedBestScore)
		
		-- START EVENT LISTENERS
		Runtime:addEventListener( "touch", onScreenTouch )
		Runtime:addEventListener( "enterFrame", gameLoop )
		Runtime:addEventListener( "system", onSystem )
		
		local startTimer = timer.performWithDelay( 2000, function() startNewRound(); end, 1 )
	end
	
	unloadMe = function()
		-- STOP PHYSICS ENGINE
		physics.stop()
		
		-- REMOVE EVENT LISTENERS
		Runtime:removeEventListener( "touch", onScreenTouch )
		Runtime:removeEventListener( "enterFrame", gameLoop )
		Runtime:removeEventListener( "system", onSystem )
		
		-- REMOVE everything in other groups
		for i = hudGroup.numChildren,1,-1 do
			local child = hudGroup[i]
			child.parent:remove( child )
			child = nil
		end
		
		-- Stop any transitions
		if ghostTween then transition.cancel( ghostTween ); end
		if poofTween then transition.cancel( poofTween ); end
		if swipeTween then transition.cancel( swipeTween ); end
		
		-- Stop any timers
		if restartTimer then timer.cancel( restartTimer ); end
		if continueTimer then timer.cancel( continueTimer ); end
	end
	
	gameInit()
	
	-- MUST return a display.newGroup()
	return gameGroup
end
