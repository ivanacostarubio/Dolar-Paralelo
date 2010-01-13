window.onload = function()
{

	Titanium.Gesture.addEventListener('shake',function(){
		var alerty = Titanium.UI.createAlertDialog();
		alerty.setTitle("Not stirred!");
		alerty.show();
	},false);
	
};

$(document).ready(function() {
	$('h1').text("6.00");
});

