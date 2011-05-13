
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

-- mainmenu

--***********************************************************************************************--
--***********************************************************************************************--

-- Main function - MUST return a display.newGroup()
function new()
	local menuGroup = display.newGroup()
	
	local ui = require("ui")
	local ghostTween
	local ofTween
	local playTween
	local isLevelSelection = false
	
	-- AUDIO
	local tapSound = audio.loadSound( "tapsound.wav" )
	--local backgroundSound = audio.loadStream( "rainsound.mp3" )	--> This is how you'd load music
	
	local drawScreen = function()
		-- BACKGROUND IMAGE
		local backgroundImage = display.newImageRect( "mainmenu.png", 480, 320 )
		backgroundImage.x = 240; backgroundImage.y = 160
		
		menuGroup:insert( backgroundImage )
		
		-- GHOST
		local menuGhost = display.newImageRect( "menughost.png", 50, 62 )
		menuGhost.x = 240; menuGhost.y = 188
		
		menuGroup:insert( menuGhost )
		
		-- GHOST ANIMATION
		if ghostTween then
			transition.cancel( ghostTween )
		end
		
		local function ghostAnimation()
			local animUp = function()
				ghostTween = transition.to( menuGhost, { time=400, y=193, onComplete=ghostAnimation })
			end
			
			ghostTween = transition.to( menuGhost, { time=400, y=183, onComplete=animUp })
		end
		
		ghostAnimation()
		-- END GHOST ANIMATION
		
		local ofBtn
		
		-- OPENFEINT BUTTON
		local onOFTouch = function( event )
			if event.phase == "release" and not isLevelSelection and ofBtn.isActive then
				
				audio.play( tapSound )
				
				print( "OpenFeint Button Pressed." )
				-- Will display OpenFeint dashboard when uncommented (if OpenFeint was properly initialized in main.lua)
				--openfeint.launchDashboard()
				
			end
		end
		
		ofBtn = ui.newButton{
			defaultSrc = "menuofbtn.png",
			defaultX = 118,
			defaultY = 88,
			overSrc = "menuofbtn-over.png",
			overX = 118,
			overY = 88,
			onEvent = onOFTouch,
			id = "OpenfeintButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		ofBtn:setReferencePoint( display.BottomCenterReferencePoint )
		ofBtn.x = 281 ofBtn.y = 410
		
		menuGroup:insert( ofBtn )
		
		-- PLAY BUTTON
		local playBtn
		
		local onPlayTouch = function( event )
			if event.phase == "release" and not isLevelSelection and playBtn.isActive then
				
				audio.play( tapSound )
				
				-- Bring Up Level Selection Screen
				
				isLevelSelection = true
				ofBtn.isActive = false
				ofBtn.isActive = false
				
				local shadeRect = display.newRect( 0, 0, 480, 320 )
				shadeRect:setFillColor( 0, 0, 0, 255 )
				shadeRect.alpha = 0
				menuGroup:insert( shadeRect )
				transition.to( shadeRect, { time=100, alpha=0.85 } )
				
				local levelSelectionBg = display.newImageRect( "levelselection.png", 328, 194 )
				levelSelectionBg.x = 240; levelSelectionBg.y = 160
				levelSelectionBg.isVisible = false
				menuGroup:insert( levelSelectionBg )
				timer.performWithDelay( 200, function() levelSelectionBg.isVisible = true; end, 1 )
				
				local level1Btn
				
				local onLevel1Touch = function( event )
					if event.phase == "release" and level1Btn.isActive then
						audio.play( tapSound )
						--audio.stop( backgroundSound )
						--audio.dispose( backgroundSound ); backgroundSound = nil
						
						level1Btn.isActive = false
						director:changeScene( "loadlevel1" )
					end
				end
				
				level1Btn = ui.newButton{
					defaultSrc = "level1btn.png",
					defaultX = 114,
					defaultY = 114,
					overSrc = "level1btn-over.png",
					overX = 114,
					overY = 114,
					onEvent = onLevel1Touch,
					id = "Level1Button",
					text = "",
					font = "Helvetica",
					textColor = { 255, 255, 255, 255 },
					size = 16,
					emboss = false
				}
				
				level1Btn.x = 174 level1Btn.y = 175
				level1Btn.isVisible = false
				
				menuGroup:insert( level1Btn )
				timer.performWithDelay( 200, function() level1Btn.isVisible = true; end, 1 )
				
				local level2Btn
				
				local onLevel2Touch = function( event )
					if event.phase == "release" and level2Btn.isActive then
						audio.play( tapSound )
						--audio.stop( backgroundSound )
						--audio.dispose( backgroundSound ); backgroundSound = nil
						
						level2Btn.isActive = false
						director:changeScene( "loadlevel2" )
					end
				end
				
				level2Btn = ui.newButton{
					defaultSrc = "level2btn.png",
					defaultX = 114,
					defaultY = 114,
					overSrc = "level2btn-over.png",
					overX = 114,
					overY = 114,
					onEvent = onLevel2Touch,
					id = "Level2Button",
					text = "",
					font = "Helvetica",
					textColor = { 255, 255, 255, 255 },
					size = 16,
					emboss = false
				}
				
				level2Btn.x = level1Btn.x + 134; level2Btn.y = 175
				level2Btn.isVisible = false
				
				menuGroup:insert( level2Btn )
				timer.performWithDelay( 200, function() level2Btn.isVisible = true; end, 1 )
				
				local closeBtn
				
				local onCloseTouch = function( event )
					if event.phase == "release" then
						
						audio.play( tapSound )
						
						-- unload level selection screen
						levelSelectionBg:removeSelf(); levelSelectionBg = nil
						level1Btn:removeSelf(); level1Btn = nil
						level2Btn:removeSelf(); level2Btn = nil
						shadeRect:removeSelf(); shadeRect = nil
						closeBtn:removeSelf(); closeBtn = nil
						
						isLevelSelection = false
						playBtn.isActive = true
						ofBtn.isActive = true
					end
				end
				
				closeBtn = ui.newButton{
					defaultSrc = "closebtn.png",
					defaultX = 44,
					defaultY = 44,
					overSrc = "closebtn-over.png",
					overX = 44,
					overY = 44,
					onEvent = onCloseTouch,
					id = "CloseButton",
					text = "",
					font = "Helvetica",
					textColor = { 255, 255, 255, 255 },
					size = 16,
					emboss = false
				}
				
				closeBtn.x = 85; closeBtn.y = 245
				closeBtn.isVisible = false
				
				menuGroup:insert( closeBtn )
				timer.performWithDelay( 201, function() closeBtn.isVisible = true; end, 1 )
				
			end
		end
		
		playBtn = ui.newButton{
			defaultSrc = "playbtn.png",
			defaultX = 146,
			defaultY = 116,
			overSrc = "playbtn-over.png",
			overX = 146,
			overY = 116,
			onEvent = onPlayTouch,
			id = "PlayButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		playBtn:setReferencePoint( display.BottomCenterReferencePoint )
		playBtn.x = 365 playBtn.y = 440
		
		menuGroup:insert( playBtn )
		
		
		-- SLIDE PLAY AND OPENFEINT BUTTON FROM THE BOTTOM:
		local setPlayBtn = function()
			playTween = transition.to( playBtn, { time=100, x=378, y=325 } )
			
			local setOfBtn = function()
				ofTween = transition.to( ofBtn, { time=100, x=268, y=325 } )
			end
			
			ofTween = transition.to( ofBtn, { time=500, y=320, onComplete=setOfBtn, transition=easing.inOutExpo } )
		end
		
		playTween = transition.to( playBtn, { time=500, y=320, onComplete=setPlayBtn, transition=easing.inOutExpo } )
		
	end
	
	drawScreen()
	--audio.play( backgroundSound, { channel=1, loops=-1, fadein=5000 }  )
	
	unloadMe = function()
		if ghostTween then transition.cancel( ghostTween ); end
		if ofTween then transition.cancel( ofTween ); end
		if playTween then transition.cancel( playTween ); end
		
		--if tapSound then audio.dispose( tapSound ); end
	end
	
	-- MUST return a display.newGroup()
	return menuGroup
end
