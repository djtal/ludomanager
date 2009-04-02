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

/*
 *  Fires "mouse:enter" and "mouse:leave" events as a substitute for the
 *  "mouseenter" and "mouseleave" events. Simulates, in effect, the behavior
 *  of the CSS ":hover" pseudoclass.
 */

(function() {
  function respondToMouseOver(event) {
    var target = event.element();
    if (event.relatedTarget && !event.relatedTarget.descendantOf(target))
      target.fire("mouse:enter");
  }
  
  function respondToMouseOut(event) {
    var target = event.element();
    if (event.relatedTarget && !event.relatedTarget.descendantOf(target))
      target.fire("mouse:leave");
  }
    
  
  if (Prototype.Browser.IE) {
    document.observe("mouseenter", function(event) {
      event.element().fire("mouse:enter");
    });
    document.observe("mouseleave", function(event) {
      event.element().fire("mouse:leave");
    });
  } else {
    document.observe("mouseover", respondToMouseOver);
    document.observe("mouseout",  respondToMouseOut);
  }  
})();


// Add them to the element mixin
Element.addMethods(DOM);


var BShow = Behavior.create({
  initialize: function(){
    this.target = this.element.down(".function"); 
    if (this.target) this.target.hide();

  },

  onmouseover : function() { if (this.target) this.target.show();},
  onmouseout : function() { if (this.target) this.target.hide();}

});

var BMore = Behavior.create({
  initialize: function(){
    this.target = this.element.up("td").down(".extended");
  },
  
  onclick : function() { 
    if (this.target)
      this.target.toggle();
    return false;
  },
});


var BCalendarCell = Behavior.create({
  initialize: function(){
    this.element.down(".play").hide();
  },
  onmouseover : function(){
      this.element.down(".play").show();
  },

  onmouseout : function(){
    if(!this.active)
      this.element.down(".play").hide();
  },
  
  onclick: function(){
    Calendar.cells.each(function(cell){
      cell.desactivate();
    })
    this.active = true;
    this.element.addClassName("active");
    this.onmouseover();
  },
  
  desactivate: function(){
    this.active = false;
    this.element.removeClassName("active");
    this.onmouseout();
  }
});



var PartyForm = Class.create();
PartyForm.addMethods({
  initialize: function(form){
    if(!$(form) && !$("party_game"))
      return;
    this.form = $(form);
    this.data_fields = $H();
    Widget.prototype.closeWidget = Widget.prototype.closeWidget.wrap(function(proceed){
      Calendar.clearAll();
      proceed();
    });
    this.widget = new Widget(this.form.up(".widget"));
    new Ajax.Request("/games.json", {method: "get", onSuccess: this.loadGames.bind(this)}); 
    $("reset").observe("click", this.close.bindAsEventListener(this));
  },
  
  updateDataField: function(){
    this.form.select(".party_game_name").each(function(field){
      this.newFieldAutocomplete(field);
    }.bind(this));
  },

  loadGames: function(response){
    this.games = response.responseJSON.inject($H(), function(acc, game){
      acc.set(game.name, game.id);
      return acc;
    });
    this.updateDataField();
  },
    
  newFieldAutocomplete: function(field){
    txts = this.data_fields.keys(); 
    if (!txts.include(field.id)){
      ac = new Autocompleter.Local(field, field.next("div.auto_complete"), this.games.keys(), 
                            {fullSearch: true, frequency: 0, minChars: 1,
                              afterUpdateElement: this.updateForm.bind(this)});
      if (ac){
        this.data_fields.set(field.id, field.next("input.party_game_id"));
        $(field).up("li").down(".remove_game").observe("click", this.removeGame.bindAsEventListener(this));
        $(field).focus();
      }
    }
  },

  updateForm: function(elt){
      game_id_input = this.data_fields.get(elt.id)
      if (game_id_input)
        game_id_input.value = this.games.get($F(elt));
  },
  
  removeGame: function(ev){
    li = ev.element();
    li.up("li").remove();
    this.detect_game_fields();
  },

  clearForm: function(){
      this.games_name.invoke("clear")
      this.games_id.invoke("clear")
  },
  
  resetForm: function(){
    if(this.parties_li.size() > 0)
    {
      this.parties_li.without(this.parties_li.first()).invoke("remove");
      this.detect_game_fields();
    }
    this.clearForm();
  },
  
  close: function(){
    this.form.up(".widget").remove();
  }
});

var AccountGameForm = Class.create()
AccountGameForm.addMethods({
  initialize: function(form){
    if (!$(form)) return;
    this.form = $(form)
    this.transdatePicker = new Control.DatePicker("account_game_transdate", {locale: 'fr'});
    new Ajax.Request("/account_games/missing.json", {method: "get", onSuccess: this.loadMissingGames.bind(this)});
  },
  
  loadMissingGames: function(response){
     this.missing = response.responseJSON.inject($H(), function(acc, game){
        acc.set(game.name, game.id);
        return acc;
      });
    new Autocompleter.Local("account_game_game_name", 'account_game_game_name_lookup', this.missing.keys(), 
    {fullSearch: true, frequency: 0, minChars: 1, afterUpdateElement: this.updategameId.bind(this)}); 
  },
  
  updategameId: function(elt){
    $("account_game_game_id").value = this.missing.get($F(elt));
  }
})



Sidebar = {
  load: function(){
    $$("#innernews .widget").each(function(widget){
      new Widget(widget)
    });
  }
}

var Widget = Class.create();
Widget.addMethods({
  initialize: function(elt){
    if (!$(elt))
    return;
    this.widget = $(elt);
    this.title = this.widget.select("h3").first();
    this.close = this.widget.select(".close").first();
    this.content = this.widget.select("div.w-content").first();
    this.widgitize();
  },

  widgitize: function(){
    if (this.title)
      this.title.observe("click", this.toggleContent.bindAsEventListener(this));
    if(this.close)
      this.close.observe("click", this.closeWidget.bindAsEventListener(this));
  },

  toggleContent: function(ev){
    this.content.toggle();
  },
  
  closeWidget: function(){
    this.widget.remove();
  }
});

var LudoSearch = Class.create();
LudoSearch.addMethods({
  initialize: function(form){
    if (!$(form))
    return;
    this.form = $(form);
    this.tagField = $("search_tags");
    this.searchedTags = [];
    this.results = $("search-results")
    new Ajax.Request('/tags/lookup', {method: "get", onSuccess: this.loadTags.bind(this)});
    this.loadObservers();
  },


  loadTags: function(reponse){
    this.tags = reponse.responseJSON;
    this.tagFieldAutocomplete = new Autocompleter.Local(this.tagField, 'tags_lookup_auto_complete', this.tags, 
    {fullSearch: true, frequency: 0, minChars: 1 , tokens : [',', ' '],
    afterUpdateElement: this.search.bind(this) } );
  },

  loadObservers: function(){
    this.form.select(".trigger").each(function(field){
      new Form.Element.Observer(field, 0.3, this.formChange.bindAsEventListener(this));
      field.setAttribute('autocomplete','off');
    }.bind(this));
    
    this.results.observe("click", this.tagClicked.bind(this))
    if ($("reset"))
      $("reset").observe("click", this.reset.bindAsEventListener(this));  
  },

  reset: function(){
    this.form.reset();
    this.searchedTags = [];
    this.highlightSelectedTags();
    this.formChange(null);
  },

  //trigered by autocomplter update action
  search: function(input, elt){
    this.searchedTags.push(elt.innerHTML.stripTags());
    this.formChange(null);
  },

  formChange: function(ev){
    this.form.request();
    return false;
  },

  tagClicked: function(ev){
    li = ev.findElement("li.tag")
    if (!li) return;
    ev.stop();
    //tag not in query
    if (!this.searchedTags.include(li.innerHTML)) {
      this.searchedTags.push(li.innerHTML);
      if (this.tagField.getValue().empty())
        val = li.innerHTML
      else
        val = this.tagField.getValue() + ", " + li.innerHTML
      this.tagField.setValue(val);
    } else { //tag in query
      this.searchedTags = this.searchedTags.without(li.innerHTML);
      this.tagField.setValue(this.tagField.getValue().gsub(",*\\s*" + li.innerHTML, ""));
    }
    this.formChange(null);
  },

  highlightSelectedTags: function(){
    this.searchedTags.each(function(tag){
      this.results.select("li." + tag).invoke("addClassName", "selected")
    }.bind(this));
  }

});

var SmartListForm = Class.create({
  initialize: function(){
    if(!$("smart_list_form")) return;
    if(!$("ludo-search")) return;
    this.form = $("smart_list_form")
    this.query_form = $("ludo-search")
    this.loadObservers()
  }, 
  
  loadObservers: function(){
    this.form.observe("submit", this.submit.bind(this));
    this.form.select("span.close").each(function(elt) {
      elt.observe("click",this.hide.bind(this))
    }.bind(this));
  },
  
  hide: function(){
    this.form.hide()
  },
  
  submit: function(ev){
    ev.stop();
    query = this.query_form.serialize(true)
    this.form.request({parameters: query})
  }
})

/*
  Used to create live unobtrusive live form
*/
var SmartForm = Class.create({
  initialize: function(form){
    if(!$(form)) return;
    this.form = $(form);
    this.loadObservers();
  },
  
  loadObservers: function(){
    this.form.observe("change", this.submit.bindAsEventListener(this))
  },
  
  submit: function(ev){
      ev.stop();
      this.form.request({onLoaded:this.lock.bind(this),
                          onSuccess: this.unlock.bind(this)});
  },
  
  lock: function(){
      this.form.disable();
  },
  
  unlock: function(){
      this.form.enable();
  },
  
})



Calendar = {
  cells: $A(),
  load: function(){
    $$(".day").each(function(elt){
      Calendar.cells.push(new BCalendarCell(elt));
    });
  },
  
  clearAll: function(){
    Calendar.cells.invoke("desactivate")
  }
}
Application = {
  start: function(){
    this.loadSmartForm();
  },
  
  loadSmartForm: function(){
      $$(".smartForm").each(function(form) {
        new SmartForm(form);
      });
  },
  
}

var Tabs = Class.create({
  initialize: function(header){
    if(!$(header)) return;
    this.tabs = $(header).select("li.tabs");
    this.tabs = this.tabs.inject($H(), function(acc, tab){
      tab.identify();
      tab.observe("click", this.toggleTab.bind(this, tab));
      body = $(tab.down("a").href.match(/#(\w.+)/)[1]);
      acc.set(tab.id, body);
      if (!tab.hasClassName("active"))
        body.hide();
      return acc;
    }.bind(this));
  },
  
  toggleTab: function(tab){
    b = this.tabs.clone()
    b.unset(tab.id)
    b.values().invoke("hide")
    this.tabs.get(tab.id).show()
    tab.addClassName("active");
    this.tabs.keys().without(tab.id).collect(function(id){ return $(id);}).invoke("removeClassName", "active");
  },
})


document.observe("dom:loaded", function() {
  new Tabs("gameTabs")
  new AccountGameForm("account_game_form")
  ls = new LudoSearch("ludo-search");
  $$('.autohide').each(function(elt){
    BShow.attach(elt)
  });
  Application.start();
  
  Sidebar.load();
  Calendar.load();
  $$("a.more").each(function(elt){
    BMore.attach(elt);
  });
})
