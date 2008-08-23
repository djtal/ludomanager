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


document.observe("dom:loaded", function() {
    asf = new AuthorshipForm("authorship_form");
    pfs = $$("form.member").inject($A(), function(acc,form){ acc.push(new PlayerForm(form)); return acc})[0];
    new GameForm("game_form");
});