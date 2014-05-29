$(document).ready(function() {	

	$(document).on('click', '#hit input', function() {
		$.ajax({
			type: 'POST',
			url: '/game/player/hit'
		}).done(function(msg) {
			$('#game').replaceWith(msg);
		});
		return false;
	});


});


$(document).ready(function() {	

	$(document).on('click', '#stay input', function() {
		$.ajax({
			type: 'POST',
			url: '/game/player/stay'
		}).done(function(msg) {
			$('#game').replaceWith(msg);
		});
		return false;
	});


});



$(document).ready(function() {	

	$(document).on('click', '#next input', function() {
		$.ajax({
			type: 'POST',
			url: '/game/dealer/hit'
		}).done(function(msg) {
			$('#game').replaceWith(msg);
		});
		return false;
	});


});


