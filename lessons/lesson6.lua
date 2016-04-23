-- decomposition lesson
-- still needs math and check functionality
----------------------------------------------------------

local composer = require( "composer" )
local numLine = require( "objects.numLine" )
local animal = require("objects.animal")
local animalball = require("objects.animalball")
local bucketObject = require( "objects.bucketObject")
local numLine = require( "objects.numLine" )
local bucket = require( "objects.bucket")
local numInput = require( "objects.numInput")
local widget = require "widget"
local physics = require "physics"
physics.start()
physics.setDrawMode( "hybrid" )
physics.setGravity( 0, 9.8 )
physics.setTimeStep( 1/15 )

local scene = composer.newScene()

local hasCollidedCircle

local max = 10
local count = max -- math.random( 1, max)
math.randomseed(os.time())
local numberOne = math.random( 0, max )
local numberTwo = math.random( 0, max )
local result = numberOne + numberTwo
local matchCount = count

local countBalls = {}
local matchBalls = {}
local numberLine
local displayText = {}
--local bucket
local bucket1
local bucket2
local bucketY = _H*.25
local bucketY3 = _H*.7
local bucketX1 = _W*.15
local bucketX2 = _W*.5
local bucketX3 = _W*.32
local num1
local num2
local num3
local plus
local input
local numberLine
local question
local ballCount

local sceneGroup

local decText
local latText

local selText = display

local function drag( event )
    local t = event.target

    -- Print info about the event. For actual production code, you should
    -- not call this function because it wastes CPU resources.
    --printTouch(event)

    local phase = event.phase
    if "began" == phase then
        -- Make target the top-most object
        local parent = t.parent
        parent:insert( t )
        display.getCurrentStage():setFocus( t )

        decText.text = t.num
        local text = convertDecToLat( t.num )
        latText.text = text
        -- Spurious events can be sent to the target, e.g. the user presses
        -- elsewhere on the screen and then moves the finger over the target.
        -- To prevent this, we add this flag. Only when it's true will "move"
        -- events be sent to the target.
        t.isFocus = true

        -- Store initial position
        t.x0 = event.x - t.x
        t.y0 = event.y - t.y
    elseif t.isFocus then
        if "moved" == phase then
            -- Make object move (we subtract t.x0,t.y0 so that moves are
            -- relative to initial grab point, rather than object "snapping").
            t.x = event.x - t.x0
            t.y = event.y - t.y0

        elseif "ended" == phase or "cancelled" == phase then

                print(t.cooldedWith)

                if(t.collidedWith ~= nil) then

                    hasCollidedCircle(t, t.collidedWith )

                end

            display.getCurrentStage():setFocus( nil )
            t.isFocus = false
        end
    end

    -- Important to return true. This tells the system that the event
    -- should not be propagated to listeners of any objects underneath.
    return true
end

local function onLocalCollision( self, event )
   local t = event.target
   local o = event.other

    if ( event.phase == "began" ) then

        if (event.other.matched == false) then
            event.other.num = self.num
            self.collidedWith = event.other

        end

    elseif ( event.phase == "ended" ) or ( event.phase == "cancelled" ) then

        if (event.other.matched == false) then
            event.other.num = self.num
            self.collidedWith = event.other
        end

    end
end


function hasCollidedCircle(obj1, obj2)

    if obj1 == nil then
        return false
    end

    if obj2 == nil then
        return false
    end

    local sqrt = math.sqrt
    local dx =  obj1.x - obj2.x;
    local dy =  obj1.y - obj2.y;
    local distance = sqrt(dx*dx + dy*dy);
    local objectSize = (obj2.contentWidth/2) + (obj1.contentWidth/2)

    if distance < objectSize then

                    local function listener( event )
                        display.remove(obj1)
                    end


                    local transitionTime = 100


                    transition.to(obj1,
                    {
                        time=transitionTime,
                        x = obj2.x,
                        y= obj2.y,
                        onComplete = listener
                    })

                   obj2.text.text = obj1.num--= display.newText( obj1.num, 0, 0, font, ballR*2 )
                    obj2.text:setFillColor(0,0,0)
                    obj2.text.alpha = 0
                    obj2.num = obj1.num
                    obj2:insert( obj2.text )
                    obj2.matched = true


                    local function listener( event )
                        transition.to(obj2.text,
                        {
                        time=500,
                        alpha =.75
                        })
                    end
                    timer.performWithDelay( transitionTime, listener )

                    matchCount = matchCount - 1

                    if matchCount <= 0 then
                        decText.text = ""
                        latText.text = ""
                      check()
                        matchCount = count
                    end
        print("true")
        return true
    end
    return false
end

function reset()

	clearBalls()
  	initBalls()
    input.reset()
    input.x = _W*.8
    physics.start()
    numberLine.y = -bucketY
    num1.y = bucketY
    num2.y = bucketY
    num3.y = bucketY
    plus.y = bucketY
    question.text = "?"
    displayText.text = ""
end

function check()



    local delayTime = 5000

    transition.to( bucket1, { time=1000, rotation = 90 } )
    transition.to( bucket2, { time=1000, rotation = -90 } )
    transition.to( input, { time=1000, x = _W*1.25} )
    question.text = input.getNumber()


    transition.to( bucket1, { delay = delayTime, time=1000, y = -bucketY } )
    transition.to( bucket2, { delay = delayTime, time=1000, y = -bucketY } )
    transition.to( question, {delay = delayTime, time=1000, y = -bucketY } )
    transition.to( num1, { delay = delayTime, time=1000, y = -bucketY } )
    transition.to( num2, { delay = delayTime, time=1000, y = -bucketY } )
    transition.to( plus, { delay = delayTime, time=1000, y = -bucketY } )
    transition.to( numberLine, { delay = delayTime, time=1000, y = bucketY } )

    timer.performWithDelay( delayTime, function (event) physics.pause() end)


    for i=1, (numberOne+numberTwo) do
           
            transition.to( matchBalls[i], { time=1000, delay = delayTime+1000,  x =  numberLine.hash[i].x + numberLine.x, y = bucketY + 2*ballR, rotation = 0} )

    end

    for j=1,(numberOne+numberTwo) do

        timer.performWithDelay((delayTime + 2000+ j * 400), function (event) 
            displayText.text = convertDecToLat(j) 
            matchBalls[j].outline:setFillColor(hlColor.R, hlColor.G, hlColor.B)
            matchBalls[j].outline.alpha = .5
            end)
    end

	timer.performWithDelay( (delayTime + 3000+ (numberOne+numberTwo) * 400), function (event) reset() end)

end


function initBalls()

        local ballSize = ballR*1.75
    
            for i = 1, numberOne do
                
                matchBalls[i] = Animal:new("images/ball.png", ballSize, ballSize, ballSize*.75)
                matchBalls[i].x, matchBalls[i].y = bucketX1 + math.random(-50, 50), bucketY - 2 * ballR*i
                physics.addBody( matchBalls[i], { radius=ballSize*.5 , friction = .5} )
                matchBalls[i].text.text = i
                sceneGroup:insert( matchBalls[i] )

            end 

        --[[    for i = numberOne+1, result do

                matchBalls[i] = Animal:new("images/ball.png", ballSize, ballSize, ballSize*.75)
                matchBalls[i].x, matchBalls[i].y = bucketX2 + math.random(-50, 50), bucketY - 2 * ballR*i
                physics.addBody( matchBalls[i], { radius=ballSize*.5, friction = .5 } )
                 matchBalls[i].text.text = i - numberOne
                sceneGroup:insert( matchBalls[i] )

            end  ]]--

end

function clearBalls()
    bucket1.rotation = 0 
    bucket2.rotation = 0 
    bucket1.y = bucketY
    bucket2.y = bucketY

    local i=1
    for k,v in pairs(matchBalls) do
        display.remove(matchBalls[i])
        matchBalls[i] = nil
        i=i + 1
    end

    numberOne = math.random( 0, max )
    numberTwo = math.random( 0, max )
    result = numberOne + numberTwo
    num1.text = numberOne
    num2.text = numberTwo

end
-- "scene:create()"
function scene:create( event )

    sceneGroup = self.view

    count = math.random(1,max)
    matchCount = count
    
    local background = display.newImageRect( "images/bg_blue_zig.png",
            display.contentWidth, display.contentHeight )
    background.anchorX = 0
    background.anchorY = 0
    background.x, background.y = 0, 0
    sceneGroup:insert( background )

    
        displayText = display.newText("", _W * .5, _H * .125, font, _W*.1)
                displayText:setFillColor( 0, 0, .5 )
 --   physics.setGravity(0,0)
    sceneGroup:insert(displayText)


    local menu = display.newImageRect( "images/menu.png",
            _H*.1,  _H*.1)
    menu.x, menu.y = _W*.9, _H*.1
    local function listener()
        composer.gotoScene( "menu" )
    end
    menu:addEventListener( "tap", listener )
    sceneGroup:insert( menu )

    input = numInput:new(2, _W*.80,centerY)


    bucket1 = bucket:new(ballR*8,ballR*7)
    bucket1.x, bucket1.y = bucketX1, bucketY 
    
    bucket2 = bucket:new(ballR*8,ballR*7) 
    bucket2.x, bucket2.y = bucketX2, bucketY 
    
    bucket3 = bucket:new(ballR*8,ballR*7)
    bucket3.x, bucket3.y = bucketX3, bucketY3 
    
    -- plus sign
    plus = display.newText( "+", _W*.32, _H*.25, font, _W*.15 )
    plus:setFillColor( 0,0,0 )
    
    -- equal sign
    local equal = display.newText( "=", _W*.15, _H*.7, font, _W*.15 )
    equal:setFillColor( 0,0,0 )

     -- left number
    --num1 = display.newText( numberOne, bucketX1, bucketY, font, _W*.15 )
    --num1:setFillColor( 0,0,0, .5 )

     -- total number
    num3 = display.newText( result, bucketX3, bucketY3, font, _W*.15 )
    num3:setFillColor( 0,0,0, .5 )
    
    -- question mark
    question = display.newText( "?", bucketX2, bucketY, font, _W*.15 )
    question:setFillColor( 0,0,0, .5 )
    
    sceneGroup:insert( bucket1 )
    sceneGroup:insert( bucket2 )
    sceneGroup:insert( bucket3 )

    decText  = display.newText( "", 0, 0, font, _W*.1 )
    decText.x, decText.y = _W*.833, _H*.6
    decText:setFillColor( 0, 0, 0 )
    sceneGroup:insert( decText )

    latText = display.newText( "", 0, 0, font, _W*.1 )
    latText.x, latText.y = _W*.833, _H*.75
    latText:setFillColor( 0, 0, 0 )
    sceneGroup:insert( latText )
    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
 	initBalls()
            
    numberLine =  numLine:new(0, 20, _W*.9, 0, 1, fontSize*.5 )
    numberLine.x , numberLine.y = _H*.1, -bucketY
    sceneGroup:insert(numberLine)

    local overCheck = display.newRect(_W*.8, centerY*1.47, _W*.09, _W*.09)
    overCheck.alpha = .5
    
    local inputCheck = display.newRect(_W*.8, centerY, _W*.15, _W*.22)
    inputCheck.alpha = .5


    function overCheck:tap( event )

        local user = input.getNumber()
        
        print ("overCheck: " .. user)
        check()
      
        if result == user then
            print ( "CORRECT")
        else
            print ( "NEGATIVE" )
        end
    end
    
    function inputCheck:tap( event )
        
        local userCount = input.getNumber()
        print ("userCount: " .. userCount)
    end

overCheck:addEventListener( "tap", overCheck )
inputCheck:addEventListener( "tap", inputCheck )
    
end


-- "scene:show()"
function scene:show( event )

    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then

        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
    end
end


-- "scene:hide()"
function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )
    physics.setTimeStep( -1 )


   -- display.remove(sceneGroup)
   -- composer.removeAll()

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene


