if (Meteor.isClient) {
  Template.hello.greeting = function () {
    return "Welcome to evilplanet.";
  };

  Template.hello.events({
    'click input' : function () {
      game = new Game
    }
  });
}

if (Meteor.isServer) {
  Meteor.startup(function () {
    // code to run on server at startup
  });
}
