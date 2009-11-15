/*
  This is just an extrat of TableKit strip feature
  I make this eaucouse table kit is too heavy formy use
*/

TableStrip = {
  strip: function(elt){
      table = $(elt)
      if (!table) return;
      
      rows = (table.tHead && table.tHead.rows.length > 0) ? $A(table.tBodies[0].rows) : $A(table.rows)
      rows.each(function(r,i) {
  			TableStrip.addStripeClass(table,r,i);
  		});
  },
  
  addStripeClass : function(t,r,i) {
		t = t || r.up('table');
		var op = $w("roweven rowodd")
		//var op = TableKit.option('rowEvenClass rowOddClass', t.id);
		var css = ((i+1)%2 === 0 ? op[0] : op[1]);
		// using prototype's assClassName/RemoveClassName was not efficient for large tables, hence:
		var cn = r.className.split(/\s+/);
	  var newCn = [];
	  for(var x = 0, l = cn.length; x < l; x += 1) {
		  if(cn[x] !== op[0] && cn[x] !== op[1]) { newCn.push(cn[x]); }
	  }
	  newCn.push(css);
	  r.className = newCn.join(" ");
	}
};