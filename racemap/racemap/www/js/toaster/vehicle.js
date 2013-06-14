var Vehicle, Wheel,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Vehicle = (function(_super) {

  __extends(Vehicle, _super);

  function Vehicle(go) {
    var _this = this;
    this.go = go;
    this.wheels = [];
    this.driveWheels = [];
    this.brakingWheels = [];
    this.steeringJoints = [];
    this.handbrakeWheels = [];
    Mousetrap.bind("left", function() {
      return _this.left = true;
    }, 'keydown');
    Mousetrap.bind("left", function() {
      return _this.left = false;
    }, 'keyup');
    Mousetrap.bind("right", function() {
      return _this.right = true;
    }, 'keydown');
    Mousetrap.bind("right", function() {
      return _this.right = false;
    }, 'keyup');
    Mousetrap.bind("up", function() {
      return _this.up = true;
    }, 'keydown');
    Mousetrap.bind("up", function() {
      return _this.up = false;
    }, 'keyup');
    Mousetrap.bind("down", function() {
      return _this.down = true;
    }, 'keydown');
    Mousetrap.bind("down", function() {
      return _this.down = false;
    }, 'keyup');
    Mousetrap.bind("space", function() {
      return _this.space = true;
    }, 'keydown');
    Mousetrap.bind("space", function() {
      return _this.space = false;
    }, 'keyup');
  }

  Vehicle.prototype.initialise = function() {};

  Vehicle.prototype.addWheel = function(wheel, position) {
    var jointDef;
    jointDef = new b2RevoluteJointDef();
    jointDef.bodyA = this.go.body.body;
    jointDef.enableLimit = true;
    jointDef.lowerAngle = 0;
    jointDef.upperAngle = 0;
    jointDef.localAnchorB.SetZero();
    this.wheels.push(wheel);
    jointDef.bodyB = wheel.body.body;
    jointDef.localAnchorA.Set(position.x, position.y);
    return resources.world.CreateJoint(jointDef);
  };

  Vehicle.prototype.beginContact = function(go) {};

  Vehicle.prototype.endContact = function(go) {};

  Vehicle.prototype.update = function() {
    var braking, desiredSpeed, joint, newAngle, setHandbrake, setSpeed, wheel, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
    desiredSpeed = 0;
    setSpeed = false;
    braking = false;
    if (this.up) {
      desiredSpeed = 200;
      setSpeed = true;
    } else if (this.down) {
      braking = true;
      desiredSpeed = 0;
      setSpeed = true;
    }
    _ref = this.driveWheels;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      wheel = _ref[_i];
      wheel.wheel.desiredSpeed = desiredSpeed;
      wheel.wheel.setSpeed = setSpeed;
      wheel.wheel.braking = braking;
    }
    setHandbrake = false;
    if (this.space) {
      setHandbrake = true;
    }
    _ref1 = this.handbrakeWheels;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      wheel = _ref1[_j];
      wheel.wheel.handbrake = setHandbrake;
    }
    newAngle = 0;
    if (this.right) {
      newAngle = -0.6;
    } else if (this.left) {
      newAngle = 0.6;
    }
    _ref2 = this.steeringJoints;
    for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
      joint = _ref2[_k];
      joint.SetLimits(newAngle, newAngle);
    }
    resources.camera.position.x = this.go.body.body.GetPosition().x * window.physicsScale;
    resources.camera.position.y = this.go.body.body.GetPosition().y * window.physicsScale;
    return this.updateAudio();
  };

  Vehicle.prototype.updateAudio = function() {
    var pitch;
    pitch = this.driveWheels[0].wheel.getForwardVelocity().Length() / 100;
    frequencyChange(440 + (this.driveWheels[0].wheel.getForwardVelocity().Length() / 100) * 1000);
    return source.playbackRate.value = pitch;
  };

  Vehicle.prototype.toJSON = function() {
    return {};
  };

  return Vehicle;

})(Go);

Wheel = (function() {

  function Wheel(go) {
    this.go = go;
    this.maxLateralImpulse = 3;
    this.desiredSpeed = 0;
    this.setSpeed = false;
    this.handbrake;
  }

  Wheel.prototype.initialise = function() {
    return this.body = this.go.body.body;
  };

  Wheel.prototype.updateDrive = function(skidding) {
    var currentForwardNormal, currentSpeed, force, forceVec, maxDriveForce;
    maxDriveForce = 200;
    currentForwardNormal = this.body.GetWorldVector(new b2Vec2(0, 1));
    currentSpeed = b2Dot(this.getForwardVelocity(), currentForwardNormal);
    force = 0;
    if (!this.setSpeed) {
      return;
    }
    if (this.desiredSpeed > currentSpeed) {
      force = maxDriveForce;
    } else if (this.braking && currentSpeed > 0) {
      force = -50;
    } else if (force > -0.1 && force < 0.1) {
      return;
    }
    forceVec = currentForwardNormal;
    forceVec.Multiply(force);
    if (skidding) {
      forceVec.Multiply(0.2);
    }
    return this.body.ApplyForce(forceVec, this.body.GetWorldCenter());
  };

  Wheel.prototype.getLateralVelocity = function() {
    var currentRightNormal;
    currentRightNormal = this.body.GetWorldVector(new b2Vec2(1, 0));
    currentRightNormal.Multiply(b2Dot(currentRightNormal, this.body.GetLinearVelocity()));
    return currentRightNormal;
  };

  Wheel.prototype.getForwardVelocity = function() {
    var currentForwardNormal;
    currentForwardNormal = this.body.GetWorldVector(new b2Vec2(0, 1));
    currentForwardNormal.Multiply(b2Dot(currentForwardNormal, this.body.GetLinearVelocity()));
    return currentForwardNormal;
  };

  Wheel.prototype.update = function() {
    var currentForwardNormal, currentForwardSpeed, dragForce, dragForceMagnitude, impulse, latVel, skidding;
    latVel = this.getLateralVelocity();
    latVel.Multiply(this.body.GetMass());
    latVel.NegativeSelf();
    impulse = latVel;
    skidding = impulse.Length() > this.maxLateralImpulse || this.handbrake;
    if (skidding) {
      impulse.Multiply(this.maxLateralImpulse / impulse.Length());
    }
    if (this.handbrake) {
      impulse.Multiply(0.5);
    }
    this.body.ApplyImpulse(impulse, this.body.GetWorldCenter());
    this.updateDrive(skidding);
    this.body.ApplyTorque(0.1 * this.body.GetInertia() * -this.body.GetAngularVelocity());
    currentForwardNormal = this.getForwardVelocity();
    currentForwardSpeed = currentForwardNormal.Length();
    dragForceMagnitude = -0.01;
    dragForce = currentForwardNormal;
    dragForce.Multiply(dragForceMagnitude);
    return this.body.ApplyForce(dragForce, this.body.GetWorldCenter());
  };

  Wheel.prototype.toJSON = function() {
    return {};
  };

  return Wheel;

})();
