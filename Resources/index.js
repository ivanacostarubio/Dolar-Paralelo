window.onload = function()
{

	Titanium.Gesture.addEventListener('shake',function(){
		var alerty = Titanium.UI.createAlertDialog();
		alerty.setTitle("Not stirred!");
		alerty.show();
	},false);
	
};

$(document).ready(function() {
	
	$.getJSON("dolarparalelo.heroku.com", function(json){
		$('h1').text(json.dolar.compra);
	});
	
});

