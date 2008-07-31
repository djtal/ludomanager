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

document.observe("dom:loaded", function() {
    asf = new AuthorshipForm("authorship_form");
});