## http://smus.com/game-asset-loader/
## http://thinkpixellab.com/pxloader/

initialised = false
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

world = new b2World( new b2Vec2(0, -10), true )
window.world = world

fixDef = new b2FixtureDef
fixDef.density = 1.0
fixDef.friction = 0.5
fixDef.restitution = 0.3

bodyDef = new b2BodyDef

# create ground
bodyDef.type = b2Body.b2_staticBody
bodyDef.position.x = 0
bodyDef.position.y = -20
fixDef.shape = new b2PolygonShape
fixDef.shape.SetAsBox(20, 0.5)
world.CreateBody(bodyDef).CreateFixture(fixDef)

# create some objects

physicsScaleX = 100
physicsScaleY = 100

## Audio
filter = 0
source = 0
loadedAudio = false
console.log( AudioContext? )
if AudioContext?
    context = new AudioContext();
else if webkitAudioContext?
    context = new webkitAudioContext();
else
    context = 0
console.log( context )


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

##UI
gui = new dat.GUI();

## Graphics

class Body
    constructor: (@go, @body) ->

    setTargetPosition: (targetPosition) ->
        @targetPosition = targetPosition

    update: () ->
        if @targetPosition?
            @targetPosition.x = @body.GetPosition().x * physicsScaleX
            @targetPosition.y = @body.GetPosition().y * physicsScaleY

    toJSON: () ->
        { position: @body.GetPosition() }
        
Actions = { IDLE: 0, JUMP : 1 }
class PlayerControls
    currentAction: Actions.IDLE
    callback: () => @currentAction = Actions.JUMP

    constructor: (@go) ->
        Mousetrap.bind( "up", @callback, 'keydown' )

    update: () ->
        if @currentAction == Actions.JUMP
            @go.body.body.SetLinearVelocity( new b2Vec2( 0, 10) )
            @go.body.body.SetAwake( true )
            @currentAction = Actions.IDLE

    toJSON: () ->
        {}


num_meshes = 10
Gos = []

renderer = 0
scene = 0
camera = 0

controls = 0

createNewMan = false
class Go
    constructor: (@prefab) ->

class ContactListener
    constructor: () ->
    PreSolve: (contact, oldManifold) ->
    PostSolve: (contact, contactImpulse ) ->
    BeginContact: (contact) ->
        createNewMan = true
    EndContact: (contact) ->
        

contactListener = new ContactListener

world.SetContactListener( contactListener )

class Sprite
    constructor: (@go, filename) ->
        spriteMap = THREE.ImageUtils.loadTexture( "run.jpg", null, @onLoad )
        spriteMat = new THREE.SpriteMaterial( { map: spriteMap, color: 0xffffff, useScreenCoordinates: false } )
        @sprite = new THREE.Sprite( spriteMat );
        @sprite.scale.multiplyScalar( 100 )
        console.log( spriteMap.image.width )

        numFrames = 10
        startFrame = 1
        endFrame = 7
        console.log( spriteMat.uvScale )
        spriteMat.uvScale.set(1 / numFrames, 1)

        @spriteTween = new TWEEN.Tween( { frame: startFrame } ).to( { frame: endFrame }, 1000 ).repeat(Infinity).onUpdate( -> 
            frameX = ( 1 / 10 ) * Math.floor( @frame )
            spriteMat.uvOffset.set( frameX, 0 ) )
            # spriteMat.uvOffset = [ 100, 0 ] )
        @spriteTween.start()

    onLoad: (texture) =>
        console.log( "texture"  )
        @sprite.scale.set( texture.image.width / 10, texture.image.height, 1 ) 
        @sprite.scale.multiplyScalar( 2 )

    toJSON: () ->
        {  }
 

createMan = (posX, posY) ->
    
    bodyDef.type = b2Body.b2_dynamicBody
    fixDef.shape = new b2PolygonShape
    fixDef.shape.SetAsBox( 1, 10)
    bodyDef.position.x = posX
    bodyDef.position.y = posY
    body = window.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)
    
    # How to deal with this callback? sprite component which owns sprite?
    ## sprite = new THREE.Sprite( { map: spriteMap, useScreenCoordinates: false, color: 0xffffff } )
    spriteGo = new Go( "Man" )
    spriteComp = new Sprite( spriteGo, "run.jpg" )
    scene.add( spriteComp.sprite  )
    spriteGo.sprite = spriteComp
    spriteGo.body = new Body( spriteGo, body ) 
    spriteGo.body.setTargetPosition( spriteComp.sprite.position )
    spriteGo.controls = new PlayerControls( spriteGo )
    Gos.push( spriteGo )
    


init = () ->
    camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 1, 10000 )
    # camera.position.x = 2000
    # camera.position.y = 2000
    camera.position.z = 4000

    scene = new THREE.Scene()


    # planeW = 100
    # planeH = 100
    # plane = new THREE.Mesh( new THREE.PlaneGeometry( planeW* 100, planeH* 100, planeW, planeH ), new   THREE.MeshBasicMaterial( { color: 0xaaaaaa, wireframe: true } ) )
    # plane.rotation.x = Math.PI/2
    # scene.add(plane)

    scene.add( new  THREE.AxisHelper( 100 ) )


    window.physicsScaleY = physicsScaleY
    gui.add(this, 'physicsScaleY', -10, 10);


    geometry = new THREE.CubeGeometry( 200, 200, 200 )
    material = new THREE.MeshBasicMaterial( { color: 0x777722, wireframe: false } )
    material.uvScale = [1, 1]

    
    for i in [0...num_meshes]
        # Gos[i] = new Go
        mesh = new THREE.Mesh( geometry, material ) 
        mesh.position.x = ( i - num_meshes / 2.0 ) * 300
        mesh.position.y = 0
        mesh.position.z = 0
        scene.add( mesh )


    groundGeom = new THREE.CubeGeometry( 20 * physicsScaleX, 0.5 * physicsScaleY, 0.5 * 20 * physicsScaleX )
    mesh = new THREE.Mesh( groundGeom, material ) 
    mesh.position.x = 0
    mesh.position.y = -10 * physicsScaleY
    mesh.position.z = 0
    scene.add( mesh )

    tween = new TWEEN.Tween( { scale: 1 } ).to( { scale: 0.01 }, 5000 ).delay( 0 ).repeat(Infinity).onUpdate( -> 
            mesh.scale.set( @scale, @scale, @scale ) )
    tween2 = new TWEEN.Tween( { scale: 0.01 } ).to( { scale: 1 }, 500 ).delay( 0 ).onUpdate( -> 
            mesh.scale.set( @scale, @scale, @scale ) )
    # tween.chain(tween2)
    tween2.chain(tween)
    tween.start()
    # tween2.start()


    # if Detector.webgl
    renderer = new THREE.WebGLRenderer( {antialias: true } )
    # else
    # renderer = new THREE.CanvasRenderer()
    renderer.setSize( window.innerWidth, window.innerHeight )

    tween = new TWEEN.Tween( { meshes: 1 } ).to( { meshes: 9 }, 1000 ).repeat( Infinity ).onUpdate( ->
        num_meshes = Math.floor( @.meshes ) )
    tween.start()

    document.body.appendChild( renderer.domElement )
    initialised = true

    createMan(0, 0)

    for go in Gos
        console.log( go )

pause = false
window.togglePause = () ->
    pause = !pause

onWindowResize = () ->
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize( window.innerWidth, window.innerHeight );
window.addEventListener( 'resize', onWindowResize, false );

previousTime = 0
animStep = (t) ->
    animate( ( t - previousTime ) / 1000 )
    previousTime = t 
    requestAnimationFrame( animStep )

serialiseTimer = 0
animate = (time) ->
    ## Physics
    if !pause
        world.Step(time, 10, 10);
        world.ClearForces();
        TWEEN.update()
    
    for go in Gos
        for own key, value of go
            if value.update? 
                value.update()
    objects = {}
    serialiseTimer += time
    if serialiseTimer > 3.0
        serialiseTimer = 0
        for go in Gos
            object = { prefab: go.prefab }
            for own key, value of go
                if value.toJSON? 
                    object += value.toJSON()
            objects += object
        console.log( JSON.stringify( objects ) ) 
        JSON.stringify( Gos )                

    renderer.render( scene, camera )

if !initialised
    init()
animStep(0)