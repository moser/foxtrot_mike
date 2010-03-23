require("spec_helper.js");
require("../../public/javascripts/application.js");
require("../../public/javascripts/i18n.js");

Screw.Unit(function(){
  describe("Parse", function(){
    it("should parse times", function(){
      expect(Parse.time("19.30")).to(equal, {h: 19, m: 30});
      expect(Parse.time("1:00")).to(equal, {h: 1, m: 0});
      expect(Parse.time("23:20")).to(equal, {h: 23, m: 20});
      expect(Parse.time("sdafsfads sd")).to(equal, false);
    }); 
    it("should parse dates", function(){
      expect(Parse.date("1.2.99")).to(equal, {m: 2, d: 1, y: 1999});
      expect(Parse.date("2.1.09")).to(equal, {m: 1, d: 2, y: 2009});
      expect(Parse.date("2/3/2001")).to(equal, {m: 2, d: 3, y: 2001});
      expect(Parse.date("2-3-2001")).to(equal, {m: 2, d: 3, y: 2001});
    });
    it("should remove leading zeros from numbers", function(){
      expect(Parse.dezero("09")).to(equal, "9");
      expect(Parse.dezero("0000")).to(equal, "0");
    });
    it("should parse ints", function(){
      expect(Parse.integer("324")).to(equal, 324);
      expect(Parse.integer("000324")).to(equal, 324);
    });
    it("should parse durations", function(){
      expect(Parse.duration("1:02")).to(equal, 62);
      expect(Parse.duration("0:05")).to(equal, 5);
    });
  });
  
  describe("Time", function(){
    it("should add minutes to a time", function(){
      var t = {h: 13, m: 10};
      expect(Time.add(t, 5)).to(equal, {h: 13, m: 15});
      expect(Time.add(t, 50)).to(equal, {h: 14, m: 0});
      expect(Time.add(t, 55)).to(equal, {h: 14, m: 5});
      t = {h: 23, m: 10};
      expect(Time.add(t, 50)).to(equal, {h: 0, m: 0});
      expect(Time.add(t, 172)).to(equal, {h: 2, m: 2});
    });
  });
  
  describe("Format", function(){
    it("duration", function(){
      expect(Format.duration(65)).to(equal, "1:05");
      expect(Format.duration(2)).to(equal, "0:02");
      expect(Format.duration(12)).to(equal, "0:12");
      expect(Format.duration(130)).to(equal, "2:10");
    });
    it("time", function(){
      expect(Format.time({h: 1, m: 5})).to(equal, "1:05");
      expect(Format.time({h: 22, m: 22})).to(equal, "22:22");
      expect(Format.time({h: 0, m: 5})).to(equal, "0:05");
      expect(Format.time({h: 11, m: 0})).to(equal, "11:00");
    });
  });
  
  describe("UI", function(){
    describe("Disabler", function(){
      it("should disable a div", function(){
        var e = $('#disable_me');
        var d = new UI.Disabler(e);
        d.disable();
        expect($(".disabler", e).length).to(equal, 1);
        d.enable();
        expect($(".disabler", e).length).to(equal, 0);
      });
    });
  });
});

