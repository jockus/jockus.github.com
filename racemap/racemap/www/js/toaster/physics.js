var Body, ContactListener, b2Body, b2BodyDef, b2CircleShape, b2DebugDraw, b2Dot, b2Fixture, b2FixtureDef, b2MassData, b2PolygonShape, b2RevoluteJointDef, b2Vec2, b2World,
  __hasProp = {}.hasOwnProperty;

b2Vec2 = Box2D.Common.Math.b2Vec2;

b2Dot = Box2D.Common.Math.b2Math.Dot;

b2BodyDef = Box2D.Dynamics.b2BodyDef;

b2Body = Box2D.Dynamics.b2Body;

b2FixtureDef = Box2D.Dynamics.b2FixtureDef;

b2Fixture = Box2D.Dynamics.b2Fixture;

b2World = Box2D.Dynamics.b2World;

b2MassData = Box2D.Collision.Shapes.b2MassData;

b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape;

b2CircleShape = Box2D.Collision.Shapes.b2CircleShape;

b2DebugDraw = Box2D.Dynamics.b2DebugDraw;

b2RevoluteJointDef = Box2D.Dynamics.Joints.b2RevoluteJointDef;

ContactListener = (function() {

  function ContactListener() {}

  ContactListener.prototype.PreSolve = function(contact, oldManifold) {};

  ContactListener.prototype.PostSolve = function(contact, contactImpulse) {};

  ContactListener.prototype.BeginContact = function(contact) {
    var goA, goB;
    goA = contact.GetFixtureA().GetBody().GetUserData();
    goB = contact.GetFixtureB().GetBody().GetUserData();
    this.sendMessage(goA, goB, "beginContact");
    return this.sendMessage(goB, goA, "beginContact");
  };

  ContactListener.prototype.EndContact = function(contact) {
    var goA, goB;
    goA = contact.GetFixtureA().GetBody().GetUserData();
    goB = contact.GetFixtureB().GetBody().GetUserData();
    this.sendMessage(goA, goB, "endContact");
    return this.sendMessage(goB, goA, "endContact");
  };

  ContactListener.prototype.sendMessage = function(goA, goB, func) {
    var key, value, _results;
    _results = [];
    for (key in goA) {
      if (!__hasProp.call(goA, key)) continue;
      value = goA[key];
      if (value[func] != null) {
        _results.push(value[func](goB));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  return ContactListener;

})();

Body = (function() {

  function Body(go, bodyDef, fixDef, targetPosition, targetRotation) {
    this.go = go;
    this.targetPosition = targetPosition;
    this.targetRotation = targetRotation;
    this.body = resources.world.CreateBody(bodyDef);
    this.body.CreateFixture(fixDef);
    this.body.SetUserData(this.go);
  }

  Body.prototype.update = function() {
    if (this.targetPosition != null) {
      this.targetPosition.x = this.body.GetPosition().x * physicsScale;
      this.targetPosition.y = this.body.GetPosition().y * physicsScale;
    }
    if (this.go.sprite != null) {
      return this.go.sprite.sprite.rotation = this.body.GetAngle();
    }
  };

  Body.prototype.toJSON = function() {
    return {
      position: this.body.GetPosition(),
      angle: this.body.GetAngle()
    };
  };

  Body.prototype.parse = function(data) {
    this.body.SetPosition(data.position);
    return this.body.SetAngle(data.angle);
  };

  return Body;

})();
