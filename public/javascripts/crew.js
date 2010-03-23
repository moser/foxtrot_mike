function Observable(obj) {
  this.obj = obj;
  this.observers = [];
}
Observable.prototype = {
  add: function(obj) {
    this.observers.push(obj);
  },
  notify: function() {
    this.observers.each(function(o) {
      if($.isFunction(o.update))
        o.update(this.obj);
    });
  }
}

function Crew(id, seat1, seat2) {
  this.id = id;
  this.type = "crew";
  this.observable = new Observable(this);
}
Crew.prototype = {
  
};

function Person(id, firstname, lastname) {
  this.id = id;
  this.type = "person";
}
Person.prototype = {

};

function RestClient(resource) {
  this.resource = resource;
}
RestClient.prototype = {
  url: function(id) {
    if(id)
      return "/" + this.resource + "/" + id;
    else
      return "/" + this.resource;
  },
  get: function(id, callback) {
    $.getJSON(this.url(id), callback);
  }
};
