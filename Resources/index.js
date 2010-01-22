window.onload = function()
{

	Titanium.Gesture.addEventListener('shake',function(){
		var alerty = Titanium.UI.createAlertDialog();
		alerty.setTitle("Not stirred!");
		alerty.show();
	},false);
	
};

$(document).ready(function() {
	
	
	$.getJSON("http://dolarparalelo.heroku.com", function(json){
		var dolar = json.dolar.compra;
		$('.cambio').text(dolar);

	});
	
	
});

