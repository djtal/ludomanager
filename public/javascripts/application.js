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

var BMore = Behavior.create({
    onclick : function() { 
        this.element.up("td").down("#" + this.element.id + "_more").toggle();
        return false;
    },
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
	this.authors = this.form.select("#authors").reduce();
	new Ajax.Request('/tags/lookup', {onSuccess: this.loadTags.bind(this)});
    new Ajax.Request("/authors", {method: "get", onSuccess: this.loadAuthor.bind(this)});
    this.bindUI();
  },
  
  loadTags: function(response){
    this.tags = response.responseJSON;
    new Autocompleter.Local('tag', 'tags_lookup_auto_complete', this.tags, 
                            {fullSearch: true, frequency: 0, minChars: 1 , tokens : [',', ' ']});
  },
  
  loadAuthor: function(response){
    this.authorsName = response.responseJSON;
    this.authors.select("input[type=text]").each(function(input){
         new Autocompleter.Local(input, 'authors_lookup_auto_complete', this.authorsName, 
                            {fullSearch: true, frequency: 0, minChars: 1});  
    }.bind(this));  
  },
  
  bindUI: function(){
    this.form.select("legend").each(function(elt){
      if ($(elt))
        $(elt).observe("click", this.hideContent.bindAsEventListener(this));
    }.bind(this));
	this.form.select("#authors .del").each(function(a){
		a.observe("click", this.removeAuthor.bindAsEventListener(this));
	}.bind(this));
	this.form.select("#authors .add").each(function(a){
		a.observe("click", this.addAuthor.bindAsEventListener(this));
	}.bind(this));
  },
  
  
  hideContent: function(ev){
    ev.element().next("div").toggle();
  },
  
  addAuthor: function(ev){
	elt = new Element("div", {"class": "author"})
	elt.insert(new Element("input", {"type": "text", "size": 30}))
	add = new Element("span", {"class": "link add"})
	add.observe("click", this.addAuthor.bindAsEventListener(this))
	elt.insert(add.insert("add"))
	elt.insert(" | ")
	del = new Element("span", {"class": "link del"});
	del.observe("click", this.removeAuthor.bindAsEventListener(this))
	elt.insert(del.insert("del"))
	this.authors.insert(elt);
  },
  
  removeAuthor: function(ev){
  	ev.element().up().hide();
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
  	if ($("mine"))
	{
		$("mine").observe("click", function(ev){
			elt = ev.element();
			if (elt.hasClassName("active"))
			{
				elt.removeClassName("active");
				$$("table").each(function(t){
          			PartyFilter.showAll(t);
        		});	
			} else {
				elt.addClassName("active");
				$$("table").each(function(t){
          			PartyFilter.showMine(t);
        		});
			}
		})
		
	}
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

Sidebar = {
	load: function(){
		$$("#innernews .widget").each(function(widget){
			new Widget(widget);
		});
	}
}

var Widget = Class.create();
Widget.addMethods({
	initialize: function(elt){
		if (!$(elt))
			return;
		this.widget = $(elt);
		this.title = this.widget.select("h3").reduce();
		this.content = this.widget.select("div.w-content").reduce();
		this.widgitize();
	},
	
	widgitize: function(){
		if (this.title)
			this.title.observe("click", this.toggleContent.bindAsEventListener(this));
	},
	
	toggleContent: function(ev){
		this.content.toggle();
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
	$("search_player").setAttribute('autocomplete','off');
	new Ajax.Request('/tags/lookup', {onSuccess: this.loadTags.bind(this)});
	this.loadObservers();
	this.makeTagsClickable();
  },
  
  
  loadTags: function(reponse){
    this.tags = reponse.responseJSON;
    this.tagFieldAutocomplete = new Autocompleter.Local(this.tagField, 'tags_lookup_auto_complete', this.tags, 
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
	this.searchedTags = [];
	this.highlightSelectedTags();
    this.formChange(null);
  },
  
  search: function(input, elt){
  	this.searchedTags.push(elt.innerHTML.stripTags());
    this.formChange(null);
  },
  
  formChange: function(ev){
    new Ajax.Request(this.form.action, {asynchronous:true, evalScripts:true, parameters:Form.serialize(this.form)});
    return false;
  },
  
  makeTagsClickable: function(){
  	this.results.select("ul.tags li").each(function(elt){
		  elt.observe("click", this.tagClicked.bindAsEventListener(this));
	  }.bind(this));
	  this.highlightSelectedTags();
  },
  
  tagClicked: function(ev){
	li = ev.element();
	if (!this.searchedTags.include(li.innerHTML)) {
		this.searchedTags.push(li.innerHTML);
		if (this.tagField.getValue().empty())
			val = li.innerHTML
		else
			val = this.tagField.getValue() + ", " + li.innerHTML
		this.tagField.setValue(val);
		li.addClassName("selected");
	} else {
		this.searchedTags = this.searchedTags.without(li.innerHTML);
		this.tagField.setValue(this.tagField.getValue().gsub(",*\\s*" + li.innerHTML, ""));
		li.removeClassName("selected");
	}
	this.formChange(null);
  },
 
  highlightSelectedTags: function(){
  	this.searchedTags.each(function(tag){
		this.results.select("li." + tag).invoke("addClassName", "selected")
	}.bind(this));
  }
 
});

document.observe("dom:loaded", function() {
  //new PrettySearchField("wrap", "search_q");
  PartyFilter.loadObservers();
  new PlayForm("play-form");
  new GameForm("game-form");
  ls = new LudoSearch("ludo-search");
  new GameList();
  Sidebar.load();
  $$(".more").each(function(elt){
      BMore.attach(elt);
  });
})