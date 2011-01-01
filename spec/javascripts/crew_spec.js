describe("Crew", function(){
  it("sets the ID", function(){
    var crew = new Crew("theID");
    expect(crew.id).toEqual("theID");
  });
});
