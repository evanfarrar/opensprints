var timerID;
function update() {
  new Ajax.Request('/irosprints/update', {});
}
function startRace() {
  new Ajax.Request('/irosprints/go', {});
  timerID = window.setInterval(update,300);
}
function stopRace() {
  window.clearInterval(timerID);
  new Ajax.Request('/irosprints/stop', {});
}
