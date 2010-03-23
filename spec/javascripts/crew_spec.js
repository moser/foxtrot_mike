require("spec_helper.js");
require("../../public/javascripts/crew.js");

Screw.Unit(function(){
  describe("Crew", function(){
    it("sets the ID", function(){
      var crew = new Crew("theID");
      expect(crew.id).to(equal, "theID");
    });
  });
});
