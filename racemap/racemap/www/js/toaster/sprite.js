var Sprite,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Sprite = (function() {

  function Sprite(go, filename, numFrames, startFrame, endFrame, absWidth, absHeight) {
    var spriteMap;
    this.go = go;
    this.numFrames = numFrames;
    this.absWidth = absWidth;
    this.absHeight = absHeight;
    this.onLoad = __bind(this.onLoad, this);

    spriteMap = THREE.ImageUtils.loadTexture(filename, null, this.onLoad);
    this.spriteMat = new THREE.SpriteMaterial({
      map: spriteMap,
      color: 0xffffff,
      useScreenCoordinates: false,
      scaleByViewport: true,
      depthTest: false,
      opacity: 0.75,
      transparent: true
    });
    this.sprite = new THREE.Sprite(this.spriteMat);
    resources.scene.add(this.sprite);
  }

  Sprite.prototype.update = function() {
    return this.sprite.updateMatrix();
  };

  Sprite.prototype.onLoad = function(texture) {
    if ((this.absWidth != null) && (this.absHeight != null)) {
      return this.sprite.scale.set(this.absWidth * physicsScale, this.absHeight * physicsScale, 1);
    } else {
      return this.sprite.scale.set(Math.floor(texture.image.width / this.numFrames), texture.image.height, 1);
    }
  };

  Sprite.prototype.parse = function(data) {
    return this.spriteMat.uvOffset.set(data.uvOffset.x, data.uvOffset.y);
  };

  Sprite.prototype.toJSON = function() {
    return {
      uvOffset: this.spriteMat.uvOffset
    };
  };

  return Sprite;

})();
