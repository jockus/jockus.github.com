class @Vehicle
    constructor: (@go) ->
        @wheels = []
        @driveWheels = []
        @brakingWheels = []
        @steeringJoints = []
        @handbrakeWheels = []
        Mousetrap.bind( "left", () =>
                @left = true
            , 'keydown' )
        Mousetrap.bind( "left", () =>
                @left = false
            , 'keyup' )
        Mousetrap.bind( "right", () =>
                @right = true
            , 'keydown' )
        Mousetrap.bind( "right", () =>
                @right = false
            , 'keyup' )
        Mousetrap.bind( "up", () =>
                @up = true
            , 'keydown' )
        Mousetrap.bind( "up", () =>
                @up = false
            , 'keyup' )
        Mousetrap.bind( "down", () =>
                @down = true
            , 'keydown' )
        Mousetrap.bind( "down", () =>
                @down = false
            , 'keyup' )
        Mousetrap.bind( "space", () =>
                @space = true
            , 'keydown' )
        Mousetrap.bind( "space", () =>
                @space = false
            , 'keyup' )

    initialise: () ->

    addWheel: (wheel, position) ->
        jointDef = new b2RevoluteJointDef()
        jointDef.bodyA = @go.body.body
        jointDef.enableLimit = true
        jointDef.lowerAngle = 0
        jointDef.upperAngle = 0
        jointDef.localAnchorB.SetZero()
        @wheels.push( wheel )
        jointDef.bodyB = wheel.body.body
        jointDef.localAnchorA.Set( position.x, position.y )
        return world.CreateJoint( jointDef )

    beginContact: ( go ) ->

    endContact: ( go ) ->

    update: () ->
        desiredSpeed = 0
        setSpeed = false
        braking = false
        if @up
            desiredSpeed = 200
            setSpeed = true
        else if @down
            braking = true
            desiredSpeed = 0
            setSpeed = true

        for wheel in @driveWheels
            wheel.wheel.desiredSpeed = desiredSpeed
            wheel.wheel.setSpeed = setSpeed
            wheel.wheel.braking = braking


        setHandbrake = false
        if @space
            setHandbrake = true
        for wheel in @handbrakeWheels
            wheel.wheel.handbrake = setHandbrake


        newAngle = 0
        if @right
            newAngle = -0.6
        else if @left
            newAngle = 0.6

        for joint in @steeringJoints
            joint.SetLimits( newAngle, newAngle )

        window.camera.position.x = @go.body.body.GetPosition().x * window.physicsScale
        window.camera.position.y = @go.body.body.GetPosition().y * window.physicsScale

    toJSON: () ->
        {}



class @Wheel
    constructor: (@go) ->
        @maxLateralImpulse = 3
        @desiredSpeed = 0
        @setSpeed = false
        @handbrake

    initialise: () ->
        @body = @go.body.body


    updateDrive: ( skidding ) ->
        maxDriveForce = 200

        currentForwardNormal = @body.GetWorldVector( new b2Vec2(0,1) );
        currentSpeed = b2Dot( @getForwardVelocity(), currentForwardNormal );

        # apply necessary force
        force = 0;
        if !@setSpeed
            return
        if ( @desiredSpeed > currentSpeed )
            force = maxDriveForce;
        else if ( @braking and currentSpeed > 0 )
            force = -50;
        else if ( force > -0.1 and force < 0.1 )
            return
        forceVec = currentForwardNormal
        forceVec.Multiply( force )
        if skidding
            forceVec.Multiply( 0.2 )
        @body.ApplyForce( forceVec, @body.GetWorldCenter() );


    getLateralVelocity: () ->
        currentRightNormal = @body.GetWorldVector( new b2Vec2(1,0) )
        currentRightNormal.Multiply( b2Dot( currentRightNormal, @body.GetLinearVelocity() ) )
        return currentRightNormal

    getForwardVelocity: () ->
       currentForwardNormal = @body.GetWorldVector( new b2Vec2(0,1) )
       currentForwardNormal.Multiply( b2Dot( currentForwardNormal, @body.GetLinearVelocity() ) )
       return currentForwardNormal

    update: () ->
       # resist lateral movement
       latVel = @getLateralVelocity()
       latVel.Multiply( @body.GetMass() )
       latVel.NegativeSelf()
       impulse = latVel
       skidding = impulse.Length() > @maxLateralImpulse or @handbrake
       if skidding
            impulse.Multiply( @maxLateralImpulse / impulse.Length() )

       if @handbrake
            impulse.Multiply( 0.5 )

       @body.ApplyImpulse( impulse, @body.GetWorldCenter() )

       @updateDrive( skidding )


       # resist rotation about center of mass
       @body.ApplyTorque( 0.1 * @body.GetInertia() * -@body.GetAngularVelocity() )

       # apply rolling drag
       currentForwardNormal = @getForwardVelocity()
       currentForwardSpeed = currentForwardNormal.Length()
       dragForceMagnitude = -0.01
       dragForce = currentForwardNormal
       dragForce.Multiply( dragForceMagnitude )
       @body.ApplyForce( dragForce, @body.GetWorldCenter() )

