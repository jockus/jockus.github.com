## http://smus.com/game-asset-loader/
## http://thinkpixellab.com/pxloader/

initialised = false

stats = new Stats()
stats.setMode(0)
stats.domElement.style.position = 'absolute'
stats.domElement.style.left = '0px'
stats.domElement.style.top = '0px'
document.body.appendChild( stats.domElement )



## Physics
    
b2Vec2 = Box2D.Common.Math.b2Vec2
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2Body = Box2D.Dynamics.b2Body
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2Fixture = Box2D.Dynamics.b2Fixture
b2World = Box2D.Dynamics.b2World
b2MassData = Box2D.Collision.Shapes.b2MassData
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
b2DebugDraw = Box2D.Dynamics.b2DebugDraw

world = new b2World( new b2Vec2(0, -100), true )

physicsScaleX = 10
physicsScaleY = 10

## Audio
filter = 0
source = 0
loadedAudio = false
if AudioContext?
    context = new AudioContext();
else if webkitAudioContext?
    context = new webkitAudioContext();
else
    context = 0


playAudioFile = (buffer) ->
    source = context.createBufferSource()
    source.buffer = buffer
    
    filter = context.createBiquadFilter();
    filter.type = 0
    filter.frequency.value = 440

    source.connect(filter);
    filter.connect(context.destination);
    # source.start(0)


loadAudioFile = (url) ->
    request = new XMLHttpRequest()

    request.open('get', 'jinroh02.mp3', true)
    request.responseType = 'arraybuffer'
    request.onload = -> 
        context.decodeAudioData(request.response, (incomingBuffer) ->
            playAudioFile(incomingBuffer) )
    request.send()

# if webkitAudioContext?
#     loadAudioFile()

frequencyChange = (value) ->
   minValue = 40
   maxValue = context.sampleRate / 2
   numberOfOctaves = Math.log( maxValue / minValue ) / Math.LN2
   multiplier = Math.pow( 2, numberOfOctaves * ( value - 1.0 ) )
   filter.frequency.value = maxValue * multiplier
window.frequencyChange = frequencyChange

window.startMusic = ->
    loadAudioFile()


## Graphics

class Body
    constructor: (@go, bodyDef, fixDef, @targetPosition) ->
        @body = world.CreateBody(bodyDef)
        @body.CreateFixture(fixDef)
        @body.SetUserData(@go)

    update: () ->
        if @targetPosition?
            @targetPosition.x = @body.GetPosition().x * physicsScaleX
            @targetPosition.y = @body.GetPosition().y * physicsScaleY

    toJSON: () ->
        { position: @body.GetPosition() }
    
    parse: ( data ) ->
        @body.SetPosition( data.position )
        
Actions = { IDLE: 0, JUMP : 1 }
class PlayerControls
    currentAction: Actions.IDLE
    jumpCallback: () => 
        if @onGround
            @currentAction = Actions.JUMP

    constructor: (@go) ->
        Mousetrap.bind( "space", @jumpCallback, 'keydown' )

    beginContact: ( go ) ->
        if go.prefab? && go.prefab == "House"
            @onGround = true

    endContact: ( go ) ->
        if go.prefab? && go.prefab == "House"
            @onGround = false

    update: () ->
        if @currentAction == Actions.JUMP
            @go.body.body.SetLinearVelocity( new b2Vec2( 0, 40 ) )
            @go.body.body.SetAwake( true )
            @go.body.body.SetActive( true )
            @currentAction = Actions.IDLE

    toJSON: () ->
        {}


Gos = []

renderer = 0
scene = 0
camera = 0

controls = 0


moving = false
moveStart = new b2Vec2()
cameraStart = new b2Vec2()

onMouseDown = ( event ) ->
    moveStart.Set( event.clientX, event.clientY )
    cameraStart.Set( camera.position.x, camera.position.y )
    moving = true
onMouseUp = ( event ) ->
    moving = false
onMouseWheel = ( event ) ->
onTouchStart = ( event ) ->
onTouchMove = ( event ) ->
onMouseMove = ( event ) ->
    if moving
        camera.position.x = cameraStart.x + ( moveStart.x - event.clientX ) * 10
        camera.position.y = cameraStart.y + ( event.clientY - moveStart.y ) * 10

window.addEventListener( 'contextmenu', ( event ) -> 
        event.preventDefault()
    , false )

window.addEventListener( 'mousedown', onMouseDown, false )
window.addEventListener( 'mouseup', onMouseUp, false )
window.addEventListener( 'mousewheel', onMouseWheel, false )
window.addEventListener( 'DOMMouseScroll', onMouseWheel, false )
window.addEventListener( 'touchstart', onTouchStart, false )
window.addEventListener( 'touchmove', onTouchMove, false )
window.addEventListener( 'mousemove', onMouseMove, false )




class Go
    constructor: (@prefab) ->

class ContactListener
    constructor: () ->
    PreSolve: (contact, oldManifold) ->
    PostSolve: (contact, contactImpulse ) ->
    BeginContact: (contact) ->
        goA = contact.GetFixtureA().GetBody().GetUserData()
        goB = contact.GetFixtureB().GetBody().GetUserData()
        @notifyBeginContact( goA, goB )
        @notifyBeginContact( goB, goA )

    EndContact: (contact) ->
        goA = contact.GetFixtureA().GetBody().GetUserData()
        goB = contact.GetFixtureB().GetBody().GetUserData()
        @notifyEndContact( goA, goB )
        @notifyEndContact( goB, goA )
    
    notifyBeginContact: ( goA, goB ) ->
        for own key, value of goA
            if value.beginContact? 
                value.beginContact( goB )

    notifyEndContact: ( goA, goB ) ->
        for own key, value of goA
            if value.endContact? 
                value.endContact( goB )

contactListener = new ContactListener

world.SetContactListener( contactListener )

class Sprite
    constructor: (@go, filename, @numFrames, startFrame, endFrame) ->
        spriteMap = THREE.ImageUtils.loadTexture( filename, null, @onLoad )
        @spriteMat = new THREE.SpriteMaterial( { map: spriteMap, color: 0xffffff, useScreenCoordinates: false, scaleByViewport: true } )
        @sprite = new THREE.Sprite( @spriteMat );

        @spriteMat.uvScale.set(1 / @numFrames, 1)
        @spriteTween = new TWEEN.Tween( { frame: startFrame, numFrames: @numFrames, spriteMat: @spriteMat} ).to( { frame: endFrame }, 1000 ).repeat(Infinity).onUpdate( -> 
            frameX = ( 1 / @numFrames ) * Math.floor( @frame )
            @spriteMat.uvOffset.set( frameX, 0 ) )
 
        @spriteTween.start()

        scene.add( @sprite )

    onLoad: (texture) =>
        @sprite.scale.set( Math.floor( texture.image.width / @numFrames ), texture.image.height, 1 ) 

    parse: ( data ) ->
        @spriteMat.uvOffset.set( data.uvOffset.x, data.uvOffset.y )

    toJSON: () ->
        { uvOffset: @spriteMat.uvOffset }

createMan = (posX, posY) ->
    go = new Go( "Man" )
    sprite = new Sprite( go, "run.jpg", 10, 1, 7 )
    go.sprite = sprite

    width = 2
    height = 3.2 
    # graphicWidth = width * physicsScaleY
    # graphicHeight = height * physicsScaleY 
    # material = new THREE.MeshBasicMaterial( { color: 0x777722, wireframe: false } )
    # groundGeom = new THREE.CubeGeometry( graphicWidth, graphicHeight, 1 )
    # mesh = new THREE.Mesh( groundGeom, material ) 
    # scene.add( mesh )

    fixDef = new b2FixtureDef
    fixDef.density = 1.0
    fixDef.friction = 0
    fixDef.shape = new b2PolygonShape
    fixDef.shape.SetAsBox( width * 0.5, height * 0.5 )

    bodyDef = new b2BodyDef()
    bodyDef.type = b2Body.b2_dynamicBody
    bodyDef.position.x = posX
    bodyDef.position.y = posY
    go.body = new Body( go, bodyDef, fixDef, sprite.sprite.position ) 

    go.controls = new PlayerControls( go )
    Gos.push( go )
    return go
    
createHouse = (posX, posY) ->
    go = new Go( "House")

    width = 20
    height = 10 
    graphicWidth = width * physicsScaleY
    graphicHeight = height * physicsScaleY
    material = new THREE.MeshBasicMaterial( { color: 0x777722, wireframe: false } )
    groundGeom = new THREE.CubeGeometry( graphicWidth, graphicHeight, 1 )
    mesh = new THREE.Mesh( groundGeom, material ) 
    scene.add( mesh )

    fixDef = new b2FixtureDef
    fixDef.density = 1.0
    fixDef.friction = 0
    fixDef.shape = new b2PolygonShape
    fixDef.shape.SetAsBox( width * 0.5, height * 0.5 )
    bodyDef = new b2BodyDef()
    bodyDef.type = b2Body.b2_staticBody
    bodyDef.position.x = posX
    bodyDef.position.y = posY

    go.body = new Body( go, bodyDef, fixDef, mesh.position  ) 
    Gos.push( go )
    return go

init = () ->
    camera = new THREE.OrthographicCamera(-400, 400, 400, -400, 1, 100 )
    camera.position.z = 40 

    scene = new THREE.Scene()

    renderer = new THREE.WebGLRenderer( {antialias: false} )
    renderer.setSize( window.innerWidth, window.innerHeight )

    document.body.appendChild( renderer.domElement )
    initialised = true



pause = false
window.togglePause = () ->
    pause = !pause
    save()
Mousetrap.bind( "p", window.togglePause, 'keydown' )

onWindowResize = () ->
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize( window.innerWidth, window.innerHeight );
window.addEventListener( 'resize', onWindowResize, false );


save = () ->
    objects = {}
    for go in Gos
        object = { prefab: go.prefab }
        for own key, value of go
            if value.toJSON? 
                object += value.toJSON()
        objects += object
    localStorage.setItem( "objects", JSON.stringify( Gos ) )                
    localStorage.setItem( "pause", pause )
    console.log( JSON.stringify( Gos ) )

logSave = () ->
    console.log( localStorage.getItem( "objects" ) )
Mousetrap.bind( "l", logSave, 'keydown' )

removeSave = () ->
    localStorage.removeItem( "objects" )
    localStorage.removeItem( "pause" )

previousTime = 0
animStep = (t) ->
    animate( ( t - previousTime ) / 1000 )
    previousTime = t 
    requestAnimationFrame( animStep )

serialiseTimer = 0
animate = (time) ->
    stats.begin()

    if !pause
        world.Step(time, 10, 10);
        world.ClearForces();
        TWEEN.update()
        removeSave()

    for go in Gos
        for own key, value of go
            if value.update? 
                value.update()

    renderer.render( scene, camera )

    stats.end()


init()

pause = localStorage.getItem( "pause" )
objStore = localStorage.getItem( "objects" )
if pause && objStore?
    console.log( "Loading save..." )
    objects = JSON.parse( objStore )
    for object in objects 
        prefab = object.prefab
        go = undefined
        if prefab == "Man"
            go = createMan(0, 0)
        else
            go = createHouse(0, -10)
        for own key, value of object
           if go[key] and go[key].parse?
                go[key].parse( value )
else
    createMan(0, 10)
    createHouse(0, -10)

animStep(0)
