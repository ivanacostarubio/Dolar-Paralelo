$(document).ready(function(){
    // Bla bla

    $.ajax({
        url: "http://dolarparalelo.heroku.com/.json",
        dataType: "json",
        type: "get",
        success: function(data){
            console.log('data');
            console.log(data);
				  	var compra = data.dolar.compra;
						$('body').html("<h1 class='venta'>"+ compra + "</h1>");	
        },
        error: function(error){
            console.log('error');
            console.log(error);
        }
    });

    // Bla bla

});
