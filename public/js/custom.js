$(function() {
    
	$('.autocomplete').typeahead({

		source: function(query, process) {
	        return $.ajax({
	            url: '/autocomplete',
	            type: 'get',
	            data: {query: query},
	            dataType: 'json',
	            success: function(json) {
	                return typeof json.options == 'undefined' ? false : process(json.options);
	            }
	        });
	    }
	});

 });