window.onload = function()
{
alert(Titanium.Network.online);
	Titanium.Gesture.addEventListener('shake',function(){
		var alerty = Titanium.UI.createAlertDialog();
		alerty.setTitle("Not stirred!");
		alerty.show();
	},false);
	
};



$(document).ready(function() {
		
	
	$('body').html("<img src='/spinner.gif' alt='spinner'/>");
		

	if(Titanium.Network.online == true){
		
		$.getJSON("http://dolarparalelo.heroku.com/.json", function(json){
	  var compra = json.dolar.compra;
		$('body').html("<h1 class='venta'>"+ compra + "</h1>");	
		});
		
	}else{	
		$('body').html("<img src='ouch_perdimosconexion.jpg'>");
	}


});
