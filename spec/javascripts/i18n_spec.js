require("spec_helper.js");
require("../../public/javascripts/i18n.js");

Screw.Unit(function(){
  describe("I18n", function(){
    it("translates strings", function(){
      expect(I18n.t("stop")).to(equal, "Stop");
    });
  });
});
