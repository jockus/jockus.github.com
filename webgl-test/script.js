// Generated by CoffeeScript 1.6.1
(function() {
  var Actions, Body, ContactListener, Go, Gos, PlayerControls, Sprite, animStep, animate, b2Body, b2BodyDef, b2CircleShape, b2DebugDraw, b2Fixture, b2FixtureDef, b2MassData, b2PolygonShape, b2Vec2, b2World, bodyDef, camera, contactListener, context, controls, createMan, createNewMan, filter, fixDef, frequencyChange, gui, init, initialised, loadAudioFile, loadedAudio, num_meshes, onWindowResize, pause, physicsScaleX, physicsScaleY, playAudioFile, previousTime, renderer, scene, source, world,
    _this = this,
    __hasProp = {}.hasOwnProperty;

  initialised = false;

  b2Vec2 = Box2D.Common.Math.b2Vec2;

  b2BodyDef = Box2D.Dynamics.b2BodyDef;

  b2Body = Box2D.Dynamics.b2Body;

  b2FixtureDef = Box2D.Dynamics.b2FixtureDef;

  b2Fixture = Box2D.Dynamics.b2Fixture;

  b2World = Box2D.Dynamics.b2World;

  b2MassData = Box2D.Collision.Shapes.b2MassData;

  b2PolygonShape = Box2D.Collision.Shapes.b2PolygonShape;

  b2CircleShape = Box2D.Collision.Shapes.b2CircleShape;

  b2DebugDraw = Box2D.Dynamics.b2DebugDraw;

  world = new b2World(new b2Vec2(0, -10), true);

  window.world = world;

  fixDef = new b2FixtureDef;

  fixDef.density = 1.0;

  fixDef.friction = 0.5;

  fixDef.restitution = 0.3;

  bodyDef = new b2BodyDef;

  bodyDef.type = b2Body.b2_staticBody;

  bodyDef.position.x = 0;

  bodyDef.position.y = -20;

  fixDef.shape = new b2PolygonShape;

  fixDef.shape.SetAsBox(20, 0.5);

  world.CreateBody(bodyDef).CreateFixture(fixDef);

  physicsScaleX = 100;

  physicsScaleY = 100;

  filter = 0;

  source = 0;

  loadedAudio = false;

  console.log(typeof AudioContext !== "undefined" && AudioContext !== null);

  if (typeof AudioContext !== "undefined" && AudioContext !== null) {
    context = new AudioContext();
  } else if (typeof webkitAudioContext !== "undefined" && webkitAudioContext !== null) {
    context = new webkitAudioContext();
  } else {
    context = 0;
  }

  console.log(context);

  playAudioFile = function(buffer) {
    source = context.createBufferSource();
    source.buffer = buffer;
    filter = context.createBiquadFilter();
    filter.type = 0;
    filter.frequency.value = 440;
    source.connect(filter);
    return filter.connect(context.destination);
  };

  loadAudioFile = function(url) {
    var request;
    request = new XMLHttpRequest();
    request.open('get', 'jinroh02.mp3', true);
    request.responseType = 'arraybuffer';
    request.onload = function() {
      return context.decodeAudioData(request.response, function(incomingBuffer) {
        return playAudioFile(incomingBuffer);
      });
    };
    return request.send();
  };

  frequencyChange = function(value) {
    var maxValue, minValue, multiplier, numberOfOctaves;
    minValue = 40;
    maxValue = context.sampleRate / 2;
    numberOfOctaves = Math.log(maxValue / minValue) / Math.LN2;
    multiplier = Math.pow(2, numberOfOctaves * (value - 1.0));
    return filter.frequency.value = maxValue * multiplier;
  };

  window.frequencyChange = frequencyChange;

  window.startMusic = function() {
    return loadAudioFile();
  };

  gui = new dat.GUI();

  Body = (function() {

    function Body(go, body) {
      this.go = go;
      this.body = body;
    }

    Body.prototype.setTargetPosition = function(targetPosition) {
      return this.targetPosition = targetPosition;
    };

    Body.prototype.update = function() {
      if (this.targetPosition != null) {
        this.targetPosition.x = this.body.GetPosition().x * physicsScaleX;
        return this.targetPosition.y = this.body.GetPosition().y * physicsScaleY;
      }
    };

    Body.prototype.serialise = function() {};

    return Body;

  })();

  Actions = {
    IDLE: 0,
    JUMP: 1
  };

  PlayerControls = (function() {

    PlayerControls.prototype.currentAction = Actions.IDLE;

    PlayerControls.prototype.callback = function() {
      return this.currentAction = Actions.JUMP;
    };

    function PlayerControls(go) {
      var _this = this;
      this.go = go;
      this.callback = function() {
        return PlayerControls.prototype.callback.apply(_this, arguments);
      };
      Mousetrap.bind("up", this.callback, 'keydown');
    }

    PlayerControls.prototype.update = function() {
      if (this.currentAction === Actions.JUMP) {
        this.go.body.body.SetLinearVelocity(new b2Vec2(0, 10));
        this.go.body.body.SetAwake(true);
        return this.currentAction = Actions.IDLE;
      }
    };

    return PlayerControls;

  })();

  num_meshes = 10;

  Gos = [];

  renderer = 0;

  scene = 0;

  camera = 0;

  controls = 0;

  createNewMan = false;

  Go = (function() {

    function Go() {}

    return Go;

  })();

  ContactListener = (function() {

    function ContactListener() {}

    ContactListener.prototype.PreSolve = function(contact, oldManifold) {};

    ContactListener.prototype.PostSolve = function(contact, contactImpulse) {};

    ContactListener.prototype.BeginContact = function(contact) {
      return createNewMan = true;
    };

    ContactListener.prototype.EndContact = function(contact) {};

    return ContactListener;

  })();

  contactListener = new ContactListener;

  world.SetContactListener(contactListener);

  Sprite = (function() {

    function Sprite(go, filename) {
      var endFrame, numFrames, spriteMap, spriteMat, spriteTween, startFrame,
        _this = this;
      this.go = go;
      this.onLoad = function(texture) {
        return Sprite.prototype.onLoad.apply(_this, arguments);
      };
      spriteMap = THREE.ImageUtils.loadTexture("run.jpg", null, this.onLoad);
      spriteMat = new THREE.SpriteMaterial({
        map: spriteMap,
        color: 0xffffff,
        useScreenCoordinates: false
      });
      this.sprite = new THREE.Sprite(spriteMat);
      this.sprite.scale.multiplyScalar(100);
      console.log(spriteMap.image.width);
      numFrames = 10;
      startFrame = 1;
      endFrame = 7;
      console.log(spriteMat.uvScale);
      spriteMat.uvScale.set(1 / numFrames, 1);
      spriteTween = new TWEEN.Tween({
        frame: startFrame
      }).to({
        frame: endFrame
      }, 1000).repeat(Infinity).onUpdate(function() {
        var frameX;
        frameX = (1 / 10) * Math.floor(this.frame);
        return spriteMat.uvOffset.set(frameX, 0);
      });
      spriteTween.start();
    }

    Sprite.prototype.onLoad = function(texture) {
      console.log("texture");
      this.sprite.scale.set(texture.image.width / 10, texture.image.height, 1);
      return this.sprite.scale.multiplyScalar(2);
    };

    return Sprite;

  })();

  createMan = function(posX, posY) {
    var body, spriteComp, spriteGo;
    bodyDef.type = b2Body.b2_dynamicBody;
    fixDef.shape = new b2PolygonShape;
    fixDef.shape.SetAsBox(1, 10);
    bodyDef.position.x = posX;
    bodyDef.position.y = posY;
    body = window.world.CreateBody(bodyDef);
    body.CreateFixture(fixDef);
    spriteGo = new Go();
    spriteComp = new Sprite(spriteGo, "run.jpg");
    scene.add(spriteComp.sprite);
    spriteGo.sprite = spriteComp;
    spriteGo.body = new Body(spriteGo, body);
    spriteGo.body.setTargetPosition(spriteComp.sprite.position);
    spriteGo.controls = new PlayerControls(spriteGo);
    return Gos.push(spriteGo);
  };

  init = function() {
    var controlsStore, geometry, go, groundGeom, i, material, mesh, tween, tween2, _i, _j, _len, _results;
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000);
    camera.position.z = 4000;
    controls = new THREE.OrbitControls(camera);
    controlsStore = localStorage.getItem("controls");
    if (controlsStore != null) {
      camera.position.copy(JSON.parse(controlsStore));
    }
    scene = new THREE.Scene();
    scene.add(new THREE.AxisHelper(100));
    window.physicsScaleY = physicsScaleY;
    gui.add(this, 'physicsScaleY', -10, 10);
    geometry = new THREE.CubeGeometry(200, 200, 200);
    material = new THREE.MeshBasicMaterial({
      color: 0x777722,
      wireframe: false
    });
    material.uvScale = [1, 1];
    for (i = _i = 0; 0 <= num_meshes ? _i < num_meshes : _i > num_meshes; i = 0 <= num_meshes ? ++_i : --_i) {
      mesh = new THREE.Mesh(geometry, material);
      mesh.position.x = (i - num_meshes / 2.0) * 300;
      mesh.position.y = 0;
      mesh.position.z = 0;
      scene.add(mesh);
    }
    groundGeom = new THREE.CubeGeometry(20 * physicsScaleX, 0.5 * physicsScaleY, 0.5 * 20 * physicsScaleX);
    mesh = new THREE.Mesh(groundGeom, material);
    mesh.position.x = 0;
    mesh.position.y = -10 * physicsScaleY;
    mesh.position.z = 0;
    scene.add(mesh);
    tween = new TWEEN.Tween({
      scale: 1
    }).to({
      scale: 0.01
    }, 5000).delay(0).repeat(Infinity).onUpdate(function() {
      return mesh.scale.set(this.scale, this.scale, this.scale);
    });
    tween2 = new TWEEN.Tween({
      scale: 0.01
    }).to({
      scale: 1
    }, 500).delay(0).onUpdate(function() {
      return mesh.scale.set(this.scale, this.scale, this.scale);
    });
    tween2.chain(tween);
    tween.start();
    renderer = new THREE.WebGLRenderer({
      antialias: true
    });
    renderer.setSize(window.innerWidth, window.innerHeight);
    tween = new TWEEN.Tween({
      meshes: 1
    }).to({
      meshes: 9
    }, 1000).repeat(Infinity).onUpdate(function() {
      return num_meshes = Math.floor(this.meshes);
    });
    tween.start();
    document.body.appendChild(renderer.domElement);
    initialised = true;
    createMan(0, 0);
    _results = [];
    for (_j = 0, _len = Gos.length; _j < _len; _j++) {
      go = Gos[_j];
      _results.push(console.log(go));
    }
    return _results;
  };

  pause = false;

  window.togglePause = function() {
    return pause = !pause;
  };

  onWindowResize = function() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    return renderer.setSize(window.innerWidth, window.innerHeight);
  };

  window.addEventListener('resize', onWindowResize, false);

  previousTime = 0;

  animStep = function(t) {
    animate((t - previousTime) / 1000);
    previousTime = t;
    return requestAnimationFrame(animStep);
  };

  animate = function(time) {
    var go, key, posX, value, _i, _len;
    if (!pause) {
      world.Step(time, 10, 10);
      world.ClearForces();
      TWEEN.update();
      localStorage.setItem("controls", JSON.stringify(controls.object.position));
    }
    if (createNewMan) {
      posX = Math.floor((Math.random() * 40) - 20);
      createNewMan = false;
    }
    for (_i = 0, _len = Gos.length; _i < _len; _i++) {
      go = Gos[_i];
      for (key in go) {
        if (!__hasProp.call(go, key)) continue;
        value = go[key];
        if (value.update != null) {
          value.update();
        }
      }
    }
    controls.update();
    return renderer.render(scene, camera);
  };

  if (!initialised) {
    init();
  }

  animStep(0);

}).call(this);
