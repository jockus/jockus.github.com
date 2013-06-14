var Gos, animStep, animate, contactListener, context, createHouse, createVehicle, createWheel, filter, frequencyChange, go, gravity, init, initialised, key, loadAudioFile, loadedAudio, logSave, objStore, object, objects, onWindowResize, pause, physicsScale, playAudioFile, prefab, previousTime, removeSave, resources, save, source, stats, value, _i, _j, _len, _len1,
  __hasProp = {}.hasOwnProperty;

initialised = false;

resources = {};

stats = new Stats();

stats.setMode(0);

stats.domElement.style.position = 'absolute';

stats.domElement.style.left = '0px';

stats.domElement.style.top = '0px';

document.body.appendChild(stats.domElement);

physicsScale = 10;

gravity = new b2Vec2(0, 0);

resources.world = new b2World(gravity, true);

contactListener = new ContactListener;

resources.world.SetContactListener(contactListener);

loadedAudio = false;

if (typeof AudioContext !== "undefined" && AudioContext !== null) {
  context = new AudioContext();
} else if (typeof webkitAudioContext !== "undefined" && webkitAudioContext !== null) {
  context = new webkitAudioContext();
} else {
  context = 0;
}

filter = context.createBiquadFilter();

source = context.createBufferSource();

playAudioFile = function(buffer) {
  source.buffer = buffer;
  source.loop = true;
  filter.type = 0;
  filter.frequency.value = 2440;
  source.connect(filter);
  filter.connect(context.destination);
  return source.start(0);
};

loadAudioFile = function(url) {
  var request;
  request = new XMLHttpRequest();
  request.open('get', 'buzz.wav', true);
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

loadAudioFile();

Gos = [];

createWheel = function() {
  var bodyDef, fixDef, wheelGo;
  wheelGo = new Go("Wheel");
  wheelGo.sprite = new Sprite(this.go, "wheel.png", 1, 1, 1, 0.2, 0.6);
  fixDef = new b2FixtureDef;
  fixDef.density = 1.0;
  fixDef.shape = new b2PolygonShape;
  fixDef.shape.SetAsBox(0.2 * 0.5, 0.6 * 0.5);
  bodyDef = new b2BodyDef();
  bodyDef.type = b2Body.b2_dynamicBody;
  wheelGo.body = new Body(wheelGo, bodyDef, fixDef, wheelGo.sprite.sprite.position, wheelGo.sprite.sprite.rotation);
  wheelGo.wheel = new Wheel(wheelGo);
  Gos.push(wheelGo);
  return wheelGo;
};

createVehicle = function(posX, posY) {
  var bodyDef, fixDef, fl, flJoint, fr, frJoint, go, height, rl, rlJoint, rr, rrJoint, width;
  go = new Go("Vehicle");
  go.sprite = new Sprite(go, "car.png", 1, 1, 1, 3 + 3, 6 - 1);
  go.vehicle = new Vehicle(go);
  width = 3;
  height = 6;
  fixDef = new b2FixtureDef;
  fixDef.density = 0.5;
  fixDef.friction = 0;
  fixDef.isSensor = true;
  fixDef.shape = new b2PolygonShape;
  fixDef.shape.SetAsBox(width * 0.5, height * 0.5);
  bodyDef = new b2BodyDef();
  bodyDef.type = b2Body.b2_dynamicBody;
  bodyDef.position.x = posX;
  bodyDef.position.y = posY;
  go.body = new Body(go, bodyDef, fixDef, go.sprite.sprite.position, go.sprite.sprite.rotation);
  fl = createWheel();
  flJoint = go.vehicle.addWheel(fl, new b2Vec2(-width / 2, height / 2.1));
  fr = createWheel();
  frJoint = go.vehicle.addWheel(fr, new b2Vec2(width / 2, height / 2.1));
  rl = createWheel();
  rlJoint = go.vehicle.addWheel(rl, new b2Vec2(-width / 2, -height / 2.1));
  rr = createWheel();
  rrJoint = go.vehicle.addWheel(rr, new b2Vec2(width / 2, -height / 2.1));
  go.vehicle.driveWheels.push(rl);
  go.vehicle.driveWheels.push(rr);
  go.vehicle.brakingWheels.push(fl);
  go.vehicle.brakingWheels.push(fr);
  go.vehicle.brakingWheels.push(rl);
  go.vehicle.brakingWheels.push(rr);
  go.vehicle.handbrakeWheels.push(rl);
  go.vehicle.handbrakeWheels.push(rr);
  go.vehicle.steeringJoints.push(flJoint);
  go.vehicle.steeringJoints.push(frJoint);
  Gos.push(go);
  return go;
};

createHouse = function(posX, posY) {
  var bodyDef, fixDef, go, graphicHeight, graphicWidth, groundGeom, height, material, mesh, width;
  go = new Go("House");
  width = 20;
  height = 10;
  graphicWidth = width * physicsScale;
  graphicHeight = height * physicsScale;
  material = new THREE.MeshBasicMaterial({
    color: 0x777722,
    wireframe: false
  });
  groundGeom = new THREE.CubeGeometry(graphicWidth, graphicHeight, 1);
  mesh = new THREE.Mesh(groundGeom, material);
  resources.scene.add(mesh);
  fixDef = new b2FixtureDef;
  fixDef.density = 1.0;
  fixDef.friction = 0;
  fixDef.shape = new b2PolygonShape;
  fixDef.shape.SetAsBox(width * 0.5, height * 0.5);
  bodyDef = new b2BodyDef();
  bodyDef.type = b2Body.b2_staticBody;
  bodyDef.position.x = posX;
  bodyDef.position.y = posY;
  go.body = new Body(go, bodyDef, fixDef, mesh.position, mesh.rotation);
  Gos.push(go);
  return go;
};

init = function() {
  var camera, container, googleMaps, map, renderer, scene, threemap;
  container = document.createElement('div');
  camera = new THREE.OrthographicCamera(-400, 400, 400, -400, 1, 100);
  camera.position.z = 40;
  scene = new THREE.Scene();
  renderer = new THREE.WebGLRenderer({
    antialias: false
  });
  renderer.setSize(window.innerWidth * 0.8, window.innerHeight * 0.8);
  resources.renderer = renderer;
  resources.scene = scene;
  resources.camera = camera;
  document.body.appendChild(renderer.domElement);
  googleMaps = true;
  if (googleMaps) {
    map = new google.maps.Map(container, {
      zoom: 4,
      center: new google.maps.LatLng(10, 0),
      disableDefaultUI: true,
      keyboardShortcuts: false,
      mapTypeId: google.maps.MapTypeId.SATELLITE
    });
    threemap = new ThreejsLayer({
      map: map
    }, {
      layer: function() {
        var geometry, material, texture;
        geometry = new THREE.Geometry();
        texture = new THREE.Texture(generateSprite());
        texture.needsUpdate = true;
        return material = new THREE.ParticleBasicMaterial({
          size: 20,
          map: texture,
          opacity: 0.3,
          blending: THREE.AdditiveBlending,
          depthTest: false,
          transparent: true
        });
      }
    });
  }
  return initialised = true;
};

pause = false;

window.togglePause = function() {
  pause = !pause;
  return save();
};

Mousetrap.bind("p", window.togglePause, 'keydown');

onWindowResize = function() {
  resources.camera.aspect = window.innerWidth / window.innerHeight;
  resources.camera.updateProjectionMatrix();
  return resources.renderer.setSize(window.innerWidth, window.innerHeight);
};

window.addEventListener('resize', onWindowResize, false);

save = function() {
  var go, key, object, objects, value, _i, _len;
  objects = {};
  for (_i = 0, _len = Gos.length; _i < _len; _i++) {
    go = Gos[_i];
    object = {
      prefab: go.prefab
    };
    for (key in go) {
      if (!__hasProp.call(go, key)) continue;
      value = go[key];
      if (value.toJSON != null) {
        object += value.toJSON();
      }
    }
    objects += object;
  }
  localStorage.setItem("objects", JSON.stringify(Gos));
  localStorage.setItem("pause", pause);
  return console.log(JSON.stringify(Gos));
};

logSave = function() {
  return console.log(localStorage.getItem("objects"));
};

Mousetrap.bind("l", logSave, 'keydown');

removeSave = function() {
  localStorage.removeItem("objects");
  return localStorage.removeItem("pause");
};

previousTime = 0;

animStep = function(t) {
  animate((t - previousTime) / 1000);
  previousTime = t;
  return requestAnimationFrame(animStep);
};

animate = function(time) {
  var go, key, value, _i, _len;
  stats.begin();
  if (!pause) {
    resources.world.Step(time, 10, 10);
    resources.world.ClearForces();
    TWEEN.update();
    removeSave();
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
  resources.renderer.render(resources.scene, resources.camera);
  resources.world.DrawDebugData();
  return stats.end();
};

init();

pause = localStorage.getItem("pause");

objStore = localStorage.getItem("objects");

if (pause && (objStore != null)) {
  console.log("Loading save...");
  objects = JSON.parse(objStore);
  for (_i = 0, _len = objects.length; _i < _len; _i++) {
    object = objects[_i];
    prefab = object.prefab;
    go = void 0;
    if (prefab === "Vehicle") {
      go = createVehicle(0, 0);
    } else if (prefab === "Wheel") {
      go = createWheel(0, 0);
    } else {
      go = createHouse(0, -10);
    }
    for (key in object) {
      if (!__hasProp.call(object, key)) continue;
      value = object[key];
      if (go[key].parse != null) {
        go[key].parse(value);
      }
    }
  }
} else {
  createVehicle(0, 10);
  createHouse(0, -10);
  createHouse(25, -10);
  createHouse(-25, -10);
}

for (_j = 0, _len1 = Gos.length; _j < _len1; _j++) {
  go = Gos[_j];
  for (key in go) {
    if (!__hasProp.call(go, key)) continue;
    value = go[key];
    if (go[key].initialise != null) {
      go[key].initialise();
    }
  }
}

animStep(0);
