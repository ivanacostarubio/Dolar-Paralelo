var compra = "0";
var venta = "0";


var loader = Titanium.Network.createHTTPClient();

loader.open("GET","dolarparalelo.heroku.com/.json");

loader.onload = function() 
{
	compra = eval('('+this.dolar.compra+')');
	venta = "waso";
	alert(loader.dolar.compra);
};
// Send the HTTP request
loader.send();


// this sets the background color of the master UIView (when there are no windows/tab groups on it)
Titanium.UI.setBackgroundColor('#000');

// create tab group
var tabGroup = Titanium.UI.createTabGroup();

//
// create base UI tab and root window
//
var win1 = Titanium.UI.createWindow({  
    title:'Dolar Paralelo Compra',
    backgroundColor:'#fff'
});
var tab1 = Titanium.UI.createTab({  
    icon:'KS_nav_views.png',
    title:'Compra',
    window:win1
});

var label1 = Titanium.UI.createLabel({
	color:'#999',
	text: compra,
	font:{fontSize:20,fontFamily:'Helvetica Neue'},
	textAlign:'center',
	width:'auto'
});

win1.add(label1);

//
// create controls tab and root window
//
var win2 = Titanium.UI.createWindow({  
    title: "Dolar Paralelo Venta",
    backgroundColor:'#fff'
});
var tab2 = Titanium.UI.createTab({  
    icon:'KS_nav_ui.png',
    title:'Venta',
    window:win2
});

var label2 = Titanium.UI.createLabel({
	color:'#999',
	text: venta,
	font:{fontSize:20,fontFamily:'Helvetica Neue'},
	textAlign:'center',
	width:'auto'
});

win2.add(label2);



//
//  add tabs
//
tabGroup.addTab(tab1);  
tabGroup.addTab(tab2);  


// open tab group
tabGroup.open();

