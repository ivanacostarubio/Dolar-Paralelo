window.onload = function()
{

	
	Titanium.Gesture.addEventListener('shake',function(){
		var alerty = Titanium.UI.createAlertDialog();
		alerty.setTitle("Not stirred!");
		alerty.show();
	},false);
	
	
	if(Titanium.Network.online== true){
		$.getJSON("http://dolarparalelo.heroku.com/.json", function(json){		
			venta = json.dolar.venta;
			$('body').html("<h1 class='venta'>"+ venta + "</h1>");
			
		});	
	  
	}else{	
		$('body').html("<img src='ouch_perdimosconexion.jpg'>");
		
	};
  


};

		
		
	
	
	

