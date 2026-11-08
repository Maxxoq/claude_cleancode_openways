// Plugins are loaded by name from config at runtime, e.g. loadPlugin('csv').
function loadPlugin(name) {
  return require('./plugins/' + name + '-export.js');
}
module.exports = { loadPlugin };
