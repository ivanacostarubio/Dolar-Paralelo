$(document).ready(function(){
    // Bla bla


    // Bla bla

		if(Titanium.Network.online == true){

			$.ajax({
	        url: "http://dolarparalelo.heroku.com/.json",
	        dataType: "json",
	        type: "get",
	        success: function(data){
	            console.log('data');
	            console.log(data);
					  	var venta = data.dolar.venta;
							$('body').html("<h1 class='venta'>"+ venta + "</h1>");	
	        },
	        error: function(error){
	            console.log('error');
	            console.log(error);
	        }
	    });



		}else{	
			$('body').html("<img src='ouch_perdimosconexion.jpg'>");
		}


});

		
		
	
	
	

