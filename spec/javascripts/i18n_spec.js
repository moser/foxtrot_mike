describe("I18n", function(){
  it("translates strings", function(){
    expect(I18n.t("stop")).toEqual("Stop");
  });
});
