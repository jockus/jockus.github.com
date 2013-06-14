## Physics
b2Vec2 = Box2D.Common.Math.b2Vec2
b2Dot = Box2D.Common.Math.b2Math.Dot
b2BodyDef = Box2D.Dynamics.b2BodyDef
b2Body = Box2D.Dynamics.b2Body
b2FixtureDef = Box2D.Dynamics.b2FixtureDef
b2Fixture = Box2D.Dynamics.b2Fixture
b2World = Box2D.Dynamics.b2World
b2MassData = Box2D.Collision.Shapes.b2MassData
b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape = Box2D.Collision.Shapes.b2CircleShape
b2DebugDraw = Box2D.Dynamics.b2DebugDraw
b2RevoluteJointDef = Box2D.Dynamics.Joints.b2RevoluteJointDef

class ContactListener
    constructor: () ->
    PreSolve: (contact, oldManifold) ->
    PostSolve: (contact, contactImpulse ) ->
    BeginContact: (contact) ->
        goA = contact.GetFixtureA().GetBody().GetUserData()
        goB = contact.GetFixtureB().GetBody().GetUserData()
        @sendMessage( goA, goB, "beginContact" )
        @sendMessage( goB, goA, "beginContact" )

    EndContact: (contact) ->
        goA = contact.GetFixtureA().GetBody().GetUserData()
        goB = contact.GetFixtureB().GetBody().GetUserData()
        @sendMessage( goA, goB, "endContact" )
        @sendMessage( goB, goA, "endContact" )

    sendMessage: ( goA, goB, func ) ->
        for own key, value of goA
            if value[func]?
                value[func]( goB )


class Body
    constructor: (@go, bodyDef, fixDef, @targetPosition, @targetRotation) ->
        @body = resources.world.CreateBody(bodyDef)
        @body.CreateFixture(fixDef)
        @body.SetUserData(@go)

    update: () ->
        if @targetPosition?
            @targetPosition.x = @body.GetPosition().x * physicsScale
            @targetPosition.y = @body.GetPosition().y * physicsScale

        # Hack, directly exposing the rotation from the sprite doesn't work
        if @go.sprite?
            @go.sprite.sprite.rotation = @body.GetAngle()

    toJSON: () ->
        { position: @body.GetPosition(), angle: @body.GetAngle() }

    parse: ( data ) ->
        @body.SetPosition( data.position )
        @body.SetAngle( data.angle )
