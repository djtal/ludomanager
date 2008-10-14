var ListKit = Class.create({
  initialize: function(list){
    if(!$(list)) return;
    this.list = $(list);
    this.childs = this.list.select("li");
    this.strip();
  },
  
  strip: function(){
    this.childs.each(function(li, i){
      li.addClassName(i % 2 === 0 ? "roweven" : "rowodd");
    })
  },
});

document.observe("dom:loaded", function() {
  $$("ul.strip").each(function(ul){ new ListKit(ul);})
});