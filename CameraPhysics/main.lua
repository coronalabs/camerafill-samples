display.setDrawMode( "forceRender", true )

local physics = require( "physics" )
physics.start()

local sky = display.newImage( "bkg_clouds.png", 160, 195 )

local ground = display.newImage( "ground.png", 160, 445 )

physics.addBody( ground, "static", { friction=0.5, bounce=0.3 } )


function dragBody( event, params )
	local body = event.target
	local phase = event.phase
	local stage = display.getCurrentStage()

	if "began" == phase then
		stage:setFocus( body, event.id )
		body.isFocus = true

		-- Create a temporary touch joint and store it in the object for later reference
		if params and params.center then
			-- drag the body from its center point
			body.tempJoint = physics.newJoint( "touch", body, body.x, body.y )
		else
			-- drag the body from the point where it was touched
			body.tempJoint = physics.newJoint( "touch", body, event.x, event.y )
		end

		-- Apply optional joint parameters
		if params then
			local maxForce, frequency, dampingRatio

			if params.maxForce then
				-- Internal default is (1000 * mass), so set this fairly high if setting manually
				body.tempJoint.maxForce = params.maxForce
			end
			
			if params.frequency then
				-- This is the response speed of the elastic joint: higher numbers = less lag/bounce
				body.tempJoint.frequency = params.frequency
			end
			
			if params.dampingRatio then
				-- Possible values: 0 (no damping) to 1.0 (critical damping)
				body.tempJoint.dampingRatio = params.dampingRatio
			end
		end
	
	elseif body.isFocus then
		if "moved" == phase then
		
			-- Update the joint to track the touch
			body.tempJoint:setTarget( event.x, event.y )

		elseif "ended" == phase or "cancelled" == phase then
			stage:setFocus( body, nil )
			body.isFocus = false
			
			-- Remove the joint when the touch ends			
			body.tempJoint:removeSelf()
			
		end
	end

	-- Stop further propagation of touch event
	return true
end


function newCrate()	
	rand = 100 + math.random( -10, 20 )



--	local crate = display.newRect( 60 + math.random( 160 ), -50, 60, 60*480/320 )
	local crate = display.newCircle( 160 + math.random( 160 ), -50, rand )
	--local crate = display.newRect( 0, 0, 320, 480 )

	crate.fill = { type="camera" }

	local randNum = math.random( 0, 2 )

	if randNum == 0 then
		crate.fill.effect = "filter.pixelate"
	elseif randNum == 1 then
	 	crate.fill.effect = "filter.sepia"
	elseif randNum == 2 then
		crate.fill.effect = "filter.sobel"
	end

	--crate.alpha = .25

	physics.addBody( crate, { density=3.0, friction=0.5, bounce=0.3, radius=rand } )

	crate:addEventListener( "touch", dragBody )
end

local dropCrates = timer.performWithDelay( 500, newCrate, 50 )