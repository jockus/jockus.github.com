#<< vehicle
#<< sprite
#<< go
#<< physics


## http://smus.com/game-asset-loader/
## http://thinkpixellab.com/pxloader/

initialised = false
resources = {}

# Stats
stats = new Stats()
stats.setMode(0)
stats.domElement.style.position = 'absolute'
stats.domElement.style.left = '0px'
stats.domElement.style.top = '0px'
document.body.appendChild( stats.domElement )


# physics
physicsScale = 10
gravity = new b2Vec2(0, 0)
resources.world = new b2World( gravity, true )
contactListener = new ContactListener
resources.world.SetContactListener( contactListener )


## Audio
loadedAudio = false
if AudioContext?
    context = new AudioContext();
else if webkitAudioContext?
    context = new webkitAudioContext();
else
    context = 0

filter = context.createBiquadFilter()
source = context.createBufferSource()

playAudioFile = (buffer) ->
    source.buffer = buffer
    source.loop = true

    filter.type = 0
    filter.frequency.value = 2440

    source.connect(filter);
    filter.connect(context.destination);
    source.start(0)


loadAudioFile = (url) ->
    request = new XMLHttpRequest()

    request.open('get', 'buzz.wav', true)
    request.responseType = 'arraybuffer'
    request.onload = ->
        context.decodeAudioData(request.response, (incomingBuffer) ->
            playAudioFile(incomingBuffer) )
    request.send()


frequencyChange = (value) ->
   minValue = 40
   maxValue = context.sampleRate / 2
   numberOfOctaves = Math.log( maxValue / minValue ) / Math.LN2
   multiplier = Math.pow( 2, numberOfOctaves * ( value - 1.0 ) )
   filter.frequency.value = maxValue * multiplier
window.frequencyChange = frequencyChange

# Kick it off
loadAudioFile()

## Graphics

Gos = []

## Potential mouse moving code
# moving = false
# moveStart = new b2Vec2()
# cameraStart = new b2Vec2()
#
# onMouseDown = ( event ) ->
#     moveStart.Set( event.clientX, event.clientY )
#     cameraStart.Set( camera.position.x, camera.position.y )
#     moving = true
# onMouseUp = ( event ) ->
#     moving = false
# onMouseWheel = ( event ) ->
# onTouchStart = ( event ) ->
# onTouchMove = ( event ) ->
# onMouseMove = ( event ) ->
#     if moving
#         camera.position.x = cameraStart.x + ( moveStart.x - event.clientX ) * 10
#         camera.position.y = cameraStart.y + ( event.clientY - moveStart.y ) * 10
#
# window.addEventListener( 'contextmenu', ( event ) ->
#         event.preventDefault()
#     , false )
#
# window.addEventListener( 'mousedown', onMouseDown, false )
# window.addEventListener( 'mouseup', onMouseUp, false )
# window.addEventListener( 'mousewheel', onMouseWheel, false )
# window.addEventListener( 'DOMMouseScroll', onMouseWheel, false )
# window.addEventListener( 'touchstart', onTouchStart, false )
# window.addEventListener( 'touchmove', onTouchMove, false )
# window.addEventListener( 'mousemove', onMouseMove, false )


createWheel = () ->
    wheelGo = new Go( "Wheel" )

    wheelGo.sprite = new Sprite( @go, "wheel.png", 1, 1, 1, 0.2, 0.6 )

    fixDef = new b2FixtureDef
    fixDef.density = 1.0
    fixDef.shape = new b2PolygonShape
    fixDef.shape.SetAsBox( 0.2 * 0.5, 0.6 * 0.5 )

    bodyDef = new b2BodyDef()
    bodyDef.type = b2Body.b2_dynamicBody
    wheelGo.body = new Body( wheelGo, bodyDef, fixDef, wheelGo.sprite.sprite.position, wheelGo.sprite.sprite.rotation )

    wheelGo.wheel = new Wheel( wheelGo )
    Gos.push( wheelGo )
    return wheelGo


createVehicle = (posX, posY) ->
    go = new Go( "Vehicle" )
    go.sprite = new Sprite( go, "car.png", 1, 1, 1, 3 + 3, 6 - 1 )

    go.vehicle = new Vehicle( go )

    width = 3
    height = 6

    fixDef = new b2FixtureDef
    fixDef.density = 0.5
    fixDef.friction = 0
    fixDef.isSensor = true
    fixDef.shape = new b2PolygonShape
    fixDef.shape.SetAsBox( width * 0.5, height * 0.5 )

    bodyDef = new b2BodyDef()
    bodyDef.type = b2Body.b2_dynamicBody
    bodyDef.position.x = posX
    bodyDef.position.y = posY
    go.body = new Body( go, bodyDef, fixDef, go.sprite.sprite.position, go.sprite.sprite.rotation )


    #massData = new b2MassData()
    #go.body.body.GetMassData( massData )
    #massData.center = go.body.body.GetWorldVector( new b2Vec2( 0, 1 ) )
    #go.body.body.SetMassData( massData )

    fl = createWheel()
    flJoint = go.vehicle.addWheel( fl, new b2Vec2( -width / 2, height / 2.1 ) )
    fr = createWheel()
    frJoint = go.vehicle.addWheel( fr,  new b2Vec2( width / 2, height / 2.1 ) )
    rl = createWheel()
    rlJoint = go.vehicle.addWheel( rl,  new b2Vec2( -width / 2, -height / 2.1 ) )
    rr = createWheel()
    rrJoint = go.vehicle.addWheel( rr,  new b2Vec2( width / 2, -height / 2.1 ) )

    #go.vehicle.driveWheels.push( fl )
    #go.vehicle.driveWheels.push( fr )
    go.vehicle.driveWheels.push( rl )
    go.vehicle.driveWheels.push( rr )

    go.vehicle.brakingWheels.push( fl )
    go.vehicle.brakingWheels.push( fr )
    go.vehicle.brakingWheels.push( rl )
    go.vehicle.brakingWheels.push( rr )

    go.vehicle.handbrakeWheels.push( rl )
    go.vehicle.handbrakeWheels.push( rr )

    go.vehicle.steeringJoints.push( flJoint )
    go.vehicle.steeringJoints.push( frJoint )

    Gos.push( go )
    return go


createHouse = (posX, posY) ->
    go = new Go( "House")

    width = 20
    height = 10
    graphicWidth = width * physicsScale
    graphicHeight = height * physicsScale

    material = new THREE.MeshBasicMaterial( { color: 0x777722, wireframe: false } )
    groundGeom = new THREE.CubeGeometry( graphicWidth, graphicHeight, 1 )
    mesh = new THREE.Mesh( groundGeom, material )
    resources.scene.add( mesh )

    fixDef = new b2FixtureDef
    fixDef.density = 1.0
    fixDef.friction = 0
    fixDef.shape = new b2PolygonShape
    fixDef.shape.SetAsBox( width * 0.5, height * 0.5 )
    bodyDef = new b2BodyDef()
    bodyDef.type = b2Body.b2_staticBody
    bodyDef.position.x = posX
    bodyDef.position.y = posY

    go.body = new Body( go, bodyDef, fixDef, mesh.position, mesh.rotation  )
    Gos.push( go )
    return go



init = () ->
    container = document.createElement('div');

    camera = new THREE.OrthographicCamera(-400, 400, 400, -400, 1, 100 )
    camera.position.z = 40

    scene = new THREE.Scene()

    renderer = new THREE.WebGLRenderer( {antialias: false} )
    renderer.setSize( window.innerWidth * 0.8, window.innerHeight * 0.8 )

    resources.renderer = renderer
    resources.scene = scene
    resources.camera = camera

    document.body.appendChild( renderer.domElement )


    googleMaps = true
    if googleMaps
        map = new google.maps.Map(container, {
            zoom: 4,
            center: new google.maps.LatLng(10, 0),
            disableDefaultUI: true,
            keyboardShortcuts: false,
            mapTypeId: google.maps.MapTypeId.SATELLITE,
        });

        threemap = new ThreejsLayer({ map: map }, layer: ->
                geometry = new THREE.Geometry()
                texture = new THREE.Texture(generateSprite())
                texture.needsUpdate = true;
                material = new THREE.ParticleBasicMaterial({
                    size: 20,
                    map: texture,
                    opacity: 0.3,
                    blending: THREE.AdditiveBlending,
                    depthTest: false,
                    transparent: true
                    })
            )

    initialised = true


pause = false
window.togglePause = () ->
    pause = !pause
    save()
Mousetrap.bind( "p", window.togglePause, 'keydown' )

onWindowResize = () ->
    resources.camera.aspect = window.innerWidth / window.innerHeight;
    resources.camera.updateProjectionMatrix();
    resources.renderer.setSize( window.innerWidth, window.innerHeight );
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

animate = (time) ->
    stats.begin()
    # threemap.move()
    if !pause
        resources.world.Step(time, 10, 10);
        resources.world.ClearForces();
        TWEEN.update()
        removeSave()

    for go in Gos
        for own key, value of go
            if value.update?
                value.update()

    resources.renderer.render( resources.scene, resources.camera )
    resources.world.DrawDebugData();

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
        if prefab == "Vehicle"
            go = createVehicle(0, 0)
        else if prefab == "Wheel"
            go = createWheel(0, 0)
        else
            go = createHouse(0, -10)
        for own key, value of object
           if go[key].parse?
                go[key].parse( value )
else
    createVehicle(0, 10)
    createHouse(0, -10)
    createHouse(25, -10)
    createHouse(-25, -10)

for go in Gos
    for own key, value of go
        if go[key].initialise?
            go[key].initialise()


animStep(0)
