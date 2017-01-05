$(document).ready(function(){
var dict = [];
$.ajax({
    url: 'data/players.json',
    method: 'GET',
    dataType: 'json',
    success: function(data) {
          $.each(data, function() {
                  dict.push(this.toString());
                      });
              return dict;
                }
});

$('#players').autocomplete({
    source: dict
});

$('#players').keydown(function() {
    console.log(dict);
});

});

function formResults (form) {
  name = form.players.value;
  processPlayer(name);
}; 

function processPlayer(name){
  document.write(name);
  var names = { "first_name":name }
  $.ajax({
    type: 'POST',
    url: '/ajaxcall',
    dataType: 'json',
    data: JSON.stringify({ name: name }),
    contentType: 'application/json; charset=utf-8',
    success: function() {
      alert("Done!")
    }
  });
};
