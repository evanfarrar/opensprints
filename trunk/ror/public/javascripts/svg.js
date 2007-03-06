function startRace() {
  new PeriodicalExecuter(function(pe) {
    new Ajax.Request('/irosprints/update', {});
  }, 0.3);
}
