var AuthorshipForm = Class.create({
  initialize: function(form){
    if (!$(form)) return;
    this.form = $(form);
    this.last_index = "0"
    new Ajax.Request("/authors.json", {method: "get", onSuccess: this.loadAuthor.bind(this)});
  },
  
  bindUI: function(){
    this.authorships = $H()
      this.form.select(".authorship").each(function(el){
        this.setupAuthorship(el);
      }.bind(this));
  },
  
  setupAuthorship: function(authorship){
      input = $("authorships_display_name_#{index}".interpolate({index: authorship.id})) 
      if (input){
        autocomplete = "authorship_#{index}_auto_complete".interpolate({ index: authorship.id});
        new Autocompleter.Local(input, autocomplete, this.authorsName, 
                                {fullSearch: true, frequency: 0, minChars: 1});
        authorship.down(".add").observe("click", this.getForm.bindAsEventListener(this)).addClassName("link")
        authorship.down(".remove").observe("click", this.removeAuthorship.bindAsEventListener(this, authorship)).addClassName("link")
        this.authorships.set(authorship.id, authorship);
        this.last_index = authorship.id
      }
  },
  
  getForm: function(ev){
      new Ajax.Request("/authorships/new_partial_form", {method: "get", parameters: {index: this.last_index}});
  },
  
  removeAuthorship: function(ev, authorship){
      authorship.fade().remove();
      this.authorships.unset(authorship.id)
  },
  
  loadAuthor: function(response){
    this.authorsName = response.responseJSON; 
    this.bindUI();
  },
});


var PlayerForm = Class.create({
  instance: [],
  
  initialize: function(form){
    if(!$(form)) return;
    this.form = $(form);
    new Ajax.Request('/members.json', {method: "get", onSuccess: this.loadMember.bind(this)});
  },
 
  loadMember: function(response){
    this.members = response.responseJSON.inject($H(), function(acc, member){
        acc.set(member.name + " - " + member.nickname, member.id);
        return acc;
    });
    this.bindUI();
  },
  
  bindUI: function(){
    this.form.getInputs("text", "member_name").each(function(input, index){
      this.setupPlayer(input, index + 1);
    }.bind(this));
  },
  
  setupPlayer: function(player, index){
      autocomplete = "member_name_#{index}_auto_complete".interpolate({ index: index});
      new Autocompleter.Local(player, autocomplete, this.members.keys(), 
      {fullSearch: true, frequency: 0, minChars: 1, afterUpdateElement: this.updateMemberId.bind(this, index)}); 
      btn = player.next(".add");
      if (btn)
        btn.observe("click", this.newMember.bindAsEventListener(this)).addClassName("link")
      btn = player.next(".remove");
      if (btn)
        btn.observe("click", this.removeMember.bindAsEventListener(this, index)).addClassName("link")
      this.last_index = index;
  },
  
  newMember: function(ev){
    new Ajax.Request("/players/new_partial_form", {method: "get", parameters: {index: this.last_index,
                                                                                   party_id: $F("players_party_id")}});
  },
  
  removeMember: function(ev, index){
      $(index.toPaddedString(1)).fade().remove();
  },
  
  updateMemberId: function(index, field){
    $("player_" + index + "_member_id").value = this.members.get($F(field));
  }
  
});

var GameForm = Class.create();
GameForm.addMethods({
  initialize: function(form){
    if (!$(form)) return;
    this.form = $(form);
    new Ajax.Request('/tags/lookup.json', {method: "get", onSuccess: this.loadTags.bind(this)});
    new Ajax.Request("/authors.json", {method: "get", onSuccess: this.loadAuthor.bind(this)});
    this.bindUI();
  },

  loadTags: function(response){
    this.tags = response.responseJSON;
    new Autocompleter.Local('tag_tag_list', 'tags_lookup_auto_complete', this.tags, 
    {fullSearch: true, frequency: 0, minChars: 1 , tokens : [',', ' ']});
  },

  loadAuthor: function(response){
    this.authorsName = response.responseJSON;
    this.form.select("#authors input[type=text]").each(function(input){
      new Autocompleter.Local(input, 'authors_lookup_auto_complete', this.authorsName, 
      {fullSearch: true, frequency: 0, minChars: 1});  
    }.bind(this));  
  },
  
  bindUI: function(){
      $("game_photo_delete").observe("click", this.toggleFileSelector.bindAsEventListener(this))
  },
  
  toggleFileSelector: function(ev){
      $("box_file_selector").toggleClassName("hide");  
  },
});

var ReplaceGameForm = Class.create({
  initialize: function(form){
    if (!$(form)) return;
    this.form = $(form);
    new Ajax.Request('/games.json', {method: "get", onSuccess: this.loadGames.bind(this)});
  },
  
  loadGames: function(response){
      this.games = response.responseJSON.inject($H(), function(acc, game){
          acc.set(game.name , game.id);
          return acc;
      });
      this.nameInput = $("replace_destination")
      autocomplete = $("replace_destination_auto_complete")
      new Autocompleter.Local(this.nameInput, autocomplete, this.games.keys(), 
      {fullSearch: true, frequency: 0, minChars: 1, afterUpdateElement: this.updateGameId.bind(this)});
  },
  
  updateGameId: function(){
      $("replace_destination_id").value = this.games.get($F(this.nameInput));
  },
})

var PartyForm = Class.create();
PartyForm.addMethods({
  initialize: function(form){
    if(!$(form) && !$("party_game"))
      return;
    this.form = $(form);
    this.form_container = this.form.up("div");
    this.data_fields = $H();
    new Ajax.Request("/games.json", {method: "get", onSuccess: this.loadGames.bind(this)}); 
    this.form.down("span.reset").observe("click", this.close.bindAsEventListener(this));
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
  },


  close: function(){
    if (this.form_container)
      this.form_container.squish();
  }
});


document.observe("dom:loaded", function() {
    pf = $A();
    asf = new AuthorshipForm("authorship_form");
    pfs = $$("form.member").inject($A(), function(acc,form){ acc.push(new PlayerForm(form)); return acc})[0];
    rpgf = new ReplaceGameForm("replace_game");
    gf = new GameForm("game_form");
    new GameForm("game_form");
});