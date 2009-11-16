// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


var BShow = Behavior.create({
  initialize: function(){
    this.target = this.element.down(".function"); 
    if (this.target) this.target.hide();

  },

  onmouseover : function() { if (this.target) this.target.show();},
  onmouseout : function() { if (this.target) this.target.hide();}

});


var BCalendarCell = Behavior.create({
  initialize: function(){
    this.element.down(".play").hide();
    this.more = this.element.down("ul.advanced");
    this.simple = this.element.down("ul.simple");
    this.advancedLink = this.element.down("a.more");
    if (this.advancedLink){
      this.advancedLink.observe("click", this.switchPartiesList.bindAsEventListener(this, "advanced"));
      this.lessLink = this.element.down("a.less")
      if (this.lessLink)
        this.lessLink.observe("click", this.switchPartiesList.bindAsEventListener(this, "simple"));
    }
  },
  
  onmouseover : function(){
      this.element.down(".play").show();
  },

  onmouseout : function(){
    if(!this.active)
      this.element.down(".play").hide();
  },
  
  onclick: function(){
    Calendar.cells.without(this).each(function(cell){
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
    this.switchPartiesList(null, "simple");
  },
  

  switchPartiesList: function(link, mode){
      if (mode == "simple") {
        if (this.simple)
          this.simple.show();
        if (this.more)
          this.more.hide();
      }
      if (mode == "advanced"){
        if (this.simple)
          this.simple.hide();
        if (this.more)
          this.more.show();
      }
      return false;
      
  },
});



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
    li = ev.findElement("a.tag")
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
      this.tagField.setValue(this.searchedTags.join(", "));
    }
    this.formChange(null);
  },

  highlightSelectedTags: function(){
    this.searchedTags.each(function(tag){
      this.results.select("a." + tag).invoke("addClassName", "selected")
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

/*
  Use to create an in place editor with an autocomplete
*/
var AjaxInPlaceAutocomplete = Class.create(Ajax.InPlaceEditor,{
  createForm: function($super){
      $super();
      this._controls.autocomplete = new Element("div", {"class": "auto_complete"});
      this._form.insert(this._controls.autocomplete);
      new Ajax.Request('/tags/lookup.json', {method: "get", onSuccess: this.loadTags.bind(this)});
      
  },
  
  loadTags: function(response){
      new Autocompleter.Local(this._controls.editor, this._controls.autocomplete, response.responseJSON, 
      {fullSearch: true, frequency: 0, minChars: 1 , tokens : [',', ' ']});
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
    this.loadTip();
    this.loadTagInPlaceEdit();
  },
  
  loadSmartForm: function(){
      $$(".smartForm").each(function(form) {
        new SmartForm(form);
      });
  },
  
  loadTip: function(){
    $$('li.tip img').each(function(img) {
       new Tip(img, img.alt, {'style': 'ludomanager', width: 'auto', 'stem': 'topMiddle',
                              hook: {tip: "topMiddle", target: "bottomMiddle"} });
     });
  },
  
  loadTagInPlaceEdit: function(methsArgs){
      $$(".tag-in-place-edit").each(function(element){
        game_id = element.id.gsub(/in_place_edit_game_/, "")
        url = "/games/#{game_id}/tags".interpolate({'game_id': game_id})
        tag_list_url = "/games/#{game_id}/tags.text".interpolate({'game_id': game_id})
        edit = element.next("a.in_place_edit_trigger")
        new AjaxInPlaceAutocomplete(element, url, {externalControlOnly: true, externalControl: edit,
                              loadTextURL: tag_list_url,
                              size: 70, rows:1});
      });
  }
  
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
  ls = new LudoSearch("ludo-search");
  if ($('search-results'))
    TableStrip.strip($('search-results').down('table'))
  $$('.autohide').each(function(elt){
    BShow.attach(elt)
  });
  Application.start();
  
  Sidebar.load();
  Calendar.load();
})
