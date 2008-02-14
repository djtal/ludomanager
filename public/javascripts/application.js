// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
// Simple utility methods for working with the DOM
DOM = {
  nextElement : function(element) {
    element = $(element);
    while (element = element.nextSibling) 
      if (element.nodeType == 1) return element;
    return null;
  },
  previousElement : function(element) {
    element = $(element);
    while (element = element.previousSibling) 
      if (element.nodeType == 1) return element;
    return null;
  },
  remove : function(element) {
    element = $(element);
    return element.parentNode.removeChild(element);
  },
  insertAfter : function(element, node, otherNode) {
    element = $(element);
    return element.insertBefore(node, otherNode.nextSibling);
  },
  addBefore : function(element, node) {
    element = $(element);
    return element.parentNode.insertBefore(node, element);
  },
  addAfter : function(element, node) {
    element = $(element);
    return $(element.parentNode).insertAfter(node, element);
  },
  replaceElement : function(element, node) {
    $(element).parentNode.replaceChild(node, element);
    return node;
  }
};

// Add them to the element mixin
Element.addMethods(DOM);

var SearchForm = {
  reset: function() {
    Form.reset('search')
    $('search-results').innerHTML = "";
  },
  
  search: function(){
    new Ajax.Request('/games/search', {asynchronous:true, evalScripts:true, parameters:Form.serialize($("search-form"))});
    return false;
  }
  
}

var PlayForm = Class.create();
PlayForm.addMethods({
  initialize: function(elt){
    this.form = $(elt)
    if (!this.form)
      return
    new Form.Observer(this.form, 1, this.onFieldChange.bindAsEventListener(this));
  },
  
  onFieldChange: function(){
    new Ajax.Request('/games/play', {asynchronous:true, evalScripts:true, parameters:Form.serialize(this.form)});
    return false;
  }
})
var BShow = Behavior.create({
    onmouseover : function() { this.element.select('.function').reduce().show();},
    onmouseout : function() { this.element.select('.function').reduce().hide();}
});

var GameList = Class.create();
GameList.addMethods({
  initialize: function(){
    if (!$("games"))
      return;
    $$(".game").each(function(elt){
      elt.select('.function').reduce().hide();
      BShow.attach(elt);
    });
  },
});

var GameForm = Class.create();
GameForm.addMethods({
  initialize: function(form){
    if (!$(form))
      return;
    this.form = $(form);
    this.bindUI();
  },
  
  bindUI: function(){
    this.form.select("legend").each(function(elt){
      if ($(elt))
        $(elt).observe("click", this.hideContent.bindAsEventListener(this));
    }.bind(this));
  },
  
  hideContent: function(ev){
    ev.element().next("div").toggle();
  }
});

PartyFilter = {
  showMine: function(table) {
    table.select("tbody tr").each(function(e){
      if (!e.hasClassName("own"))
        e.hide();     
    });
    TableKit.Rows.stripe(table);
  },
  
  showAll : function(table){
    $(table).select("tbody tr").invoke("show");
  },
  
  loadObservers: function(){
    if(!$("parties-filter"))
      return;
    $("parties-filter").observe("change", function(e){
      if(e.element().getValue() == "ludo")
        $$("table").each(function(t){
          PartyFilter.showMine(t);
        });
      else
        $$("table").each(function(t){
          PartyFilter.showAll(t);
        });
      
    });
    $("parties-filter").getInputs("submit").first().hide();
  },
}

var LudoSearch = Class.create();
LudoSearch.addMethods({
  initialize: function(form){
    if (!$(form))
    return;
  this.form = $(form);
  $("search_player").setAttribute('autocomplete','off');
  new Ajax.Request('/tags/lookup', {onSuccess: this.loadTags.bind(this)});
  this.loadObservers();
  },
  
  
  loadTags: function(reponse){
    this.tags = reponse.responseJSON;
    new Autocompleter.Local('search_tags', 'tags_lookup_auto_complete', this.tags, 
                            {fullSearch: true, frequency: 0, minChars: 1 , tokens : [',', ' '],
                            afterUpdateElement: this.search.bind(this) } );
  },
  
  loadObservers: function(){
    new Field.Observer("search_player", 0.3, this.formChange.bindAsEventListener(this));
    new Field.Observer("search_tags_mode_or", 0.3, this.formChange.bindAsEventListener(this));
    new Field.Observer("search_tags_mode_and", 0.3, this.formChange.bindAsEventListener(this));
    if ($("reset"))
      $("reset").observe("click", this.reset.bindAsEventListener(this));  
  },
  
  reset: function(){
    this.form.reset();
    this.formChange(null);
  },
  
  search: function(input, elt){
    this.formChange(null);
  },
  
  formChange: function(ev){
    new Ajax.Request(this.form.action, {asynchronous:true, evalScripts:true, parameters:Form.serialize(this.form)});
    return false;
  }
});

document.observe("dom:loaded", function() {
  //new PrettySearchField("wrap", "search_q");
  PartyFilter.loadObservers();
  new PlayForm("play-form");
  new GameForm("game-form");
  new LudoSearch("ludo-search");
  new GameList();
})