var Component, Go;

Go = (function() {

  function Go(prefabName) {
    this.prefabName = prefabName;
  }

  return Go;

})();

Component = (function() {

  function Component(resources) {}

  Component.prototype.initialise = function(go) {
    this.go = go;
  };

  Component.prototype.update = function(timeStep) {};

  Component.prototype.toJSON = function() {};

  Component.prototype.parse = function(data) {};

  return Component;

})();
