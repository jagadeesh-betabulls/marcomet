//********* Pop up functions **************
var popUp;
function pop(url, xSize, ySize){
  if(popUp && !popUp.closed){
    popUp.location.replace(url);
  }else{
    Left = (screen.width - xSize ) /2;
    Top = (screen.height - ySize) /2;
    var opts = "width=" + xSize + ",height="+ ySize +",left="+ Left +",top="+ Top +",location=0,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=1,toolbar=0";
    popUp = open(url,"popup",opts);
  }
  popUp.focus();
}
//******** Primary Pop up functions-use if need to pop up a window with other popups on it **************
var popUpw;
function popw(url, xSize, ySize){
  if(popUpw && !popUpw.closed){
    popUpw.location.replace(url);
  }else{
    Left = (screen.width - xSize ) /2;
    Top = (screen.height - ySize) /2;
    var opts = "width=" + xSize + ",height="+ ySize +",left="+ Left +",top="+ Top +",location=0,menubar=0,resizable=1,scrollbars=1,status=0,titlebar=1,toolbar=0";
    popUpw = open(url,"popupw",opts);
  }
  popUpw.focus();
}
//******Nothing Formula******************

function nothing(){ 
      var i = 0;
}
//*************Popup Help*********************
function popUpHelp(objectName){
	pop("/popups/popuphelp.jsp?name="+objectName,"300","300");
}	

function refreshPage(url){
  document.forms[0].action= url;
  document.forms[0].submit();
}
//**********string trims****************
function ltrim(argvalue) {

  while (1) {
    if (argvalue.substring(0, 1) != " ")
      break;
    argvalue = argvalue.substring(1, argvalue.length);
  }

  return argvalue;
}
function rtrim(argvalue) {

  while (1) {
    if (argvalue.substring(argvalue.length - 1, argvalue.length) != " ")
      break;
    argvalue = argvalue.substring(0, argvalue.length - 1);
  }

  return argvalue;
}
function trim(argvalue) {
  var tmpstr = ltrim(argvalue);

  return rtrim(tmpstr);

}
//*************form was changed************
function formChanged(){
	document.forms[0].formchanged.value="1";
}
function formChangedArea(area){
	eval("document.forms[0].formChanged"+ area + ".value='1'");
}
//************* Tab Functions *****************

function expandIt(whichEl) {
  //  whichIm = event.srcElement;
    if (whichEl.style.display == "none") {
        whichEl.style.display = "";
     //   whichIm.src = "triUp.gif";        
    }
    else {
        whichEl.style.display = "none";
    //    whichIm.src = "triDown.gif";
    }
}
function expandItImSwap(whichEl) {
   whichIm = event.srcElement;
    if (whichEl.style.display == "none") {
        whichEl.style.display = "";
       whichIm.src = "/imgs/buttons/minus.gif";        
    }
    else {
        whichEl.style.display = "none";
       whichIm.src = "/imgs/buttons/plus.gif";       
    }
}
function RndNumber(){  //used mostly for tacking on the end of urls to defeat caching.
	var d = new Date();
	return (d.getSeconds() * d.getMinutes() * d.getDay());
}
//*********************** Job action moving forward js function *************
function moveJob(ai, ji){
	if(ai == '3'||ai=='6'||ai == '12'||ai == '35'||ai == '39'){
		window.location.replace('/minders/workflowforms/ProposeChangeOrder.jsp?jobId='+ji);
	}else{
		document.forms[0].nextStepJobId.value= ji;
		document.forms[0].nextStepActionId.value= ai;	
		submitForm();
	}	
}
function moveWorkFlow(ai){
	if(ai == '3'||ai=='6'||ai == '12'||ai == '35'||ai == '39'||ai == '41'){
		window.location.replace('/minders/workflowforms/ProposeChangeOrder.jsp?jobId='+document.forms[0].jobId.value);
	}else{
		document.forms[0].nextStepActionId.value= ai;	
		submitForm();
	}
}
//*************** Currency Seciont Start********************************
function formatCurrency(num) {
	num = num.toString().replace(/\$|\,/g,'');
	if(isNaN(num)){
		num = "0";
	}	
	sign = (num == (num = Math.abs(num)));
	num = Math.floor(num*100+0.50000000001);
	cents = num%100;
	num = Math.floor(num/100).toString();
	if(cents<10){
		cents = "0" + cents;
	}	
	for (var i = 0; i < Math.floor((num.length-(1+i))/3); i++){
		num = num.substring(0,num.length-(4*i+3))+','+ num.substring(num.length-(4*i+3));
	}	
	return (((sign)?'':'-') + '$' + num + '.' + cents);
}
function roundCurrency(amount){
	//var formattedAmount = (Math.round(amount * 100) /100);
	//return Math.floor(formattedAmount*Math.pow(10,2))/Math.pow(10,2);
	return (Math.round(amount * 100) /100);
}

//********************* Currency Section End ******************************

//********************* Rerun to original frameset ************************

function cancelProject() {
	parent.window.location.replace('/index.jsp');
}
function continueShopping() {
	parent.window.location.replace('/index.jsp');
}

//********************* Rollover Functions ********************************

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v4.0
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && document.getElementById) x=document.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}

//********************* End Rollover Functions ****************************
//********************* Form validation Section *************************
function isNumber(x){
	var anum=/(^\d+$)|(^\d+\.\d+$)/
	return(anum.test(x));
}
function isZipcode(fldvalue) {
	var valid = "0123456789-";
	var hyphencount = 0;

	if (fldvalue.length!=5 && fldvalue.length!=10) {
		return false;
	}
	for (var i=0; i < fldvalue.length; i++) {
		temp = "" + fldvalue.substring(i, i+1);
		if (temp == "-"){
			hyphencount++;
		}
		if (valid.indexOf(temp) == "-1") {  //invalid charactors
			return false;
		}
		if ((hyphencount > 1) || ((fldvalue.length==10) && ""+fldvalue.charAt(5)!="-")) {
			return false;
		}
	}	
	return true;
}
//********************* Form Validation Secition End ***********************

//********************* Price Adjustment Functions  ************************
function updatePrices(marcometMarkup, change, markup, edit) {
        
        if (markup == 1) {
           var mu = document.forms[0].mu.value;
           var percentage = (mu / document.forms[0].cost.value) * 100;
        } else {
           var mu = document.forms[0].cost.value * (document.forms[0].percentage.value/100);
        }
        var fee = document.getElementById('fee').innerHTML= (Math.round(document.forms[0].cost.value*100)/100 + Math.round(mu*100)/100) * ((1 / (1 - marcometMarkup )) - 1);
        var price = Math.round(document.forms[0].cost.value * 100)/100 + Math.round(mu*100)/100 + Math.round(fee*100)/100;
        if (change == 1) {
          var adjustedPrice = price + Math.round(document.forms[0].jobPrice.value * 100) / 100;
        }

        if (edit == 0) {
           document.getElementById('mu').innerHTML = formatCurrency(Math.round(mu * 100) /100);
        }
        document.getElementById('fee').innerHTML= formatCurrency(Math.round(fee * 100) /100);
        document.getElementById('price').innerHTML= formatCurrency(Math.round(price * 100) / 100);
        if (change == 1) {
           document.getElementById('adjustedPrice').innerHTML= formatCurrency(Math.round(adjustedPrice * 100) / 100);
        }

        if (markup == 1) {
           document.forms[0].percentage.value = percentage;
        }
        document.forms[0].mu.value = roundCurrency(mu);
        document.forms[0].fee.value = roundCurrency(fee);
        document.forms[0].price.value= roundCurrency(price);
}

//********** populates datefields with mysql formated dates, year-month-day
function popShipDateField(fieldName){
	popHiddenDateField(fieldName);
}

function popHiddenDateField(fieldName){
	var month = document.forms[0].dateMonth[document.forms[0].dateMonth.selectedIndex].value;
	var day = document.forms[0].dateDay[document.forms[0].dateDay.selectedIndex].value;
	var year = document.forms[0].dateYear[document.forms[0].dateYear.selectedIndex].value;
	eval("document.forms[0]."+ fieldName + ".value = '" + year + "-" + month + "-" + day+"'");
}

//********** Update inner Title ***********************
function populateTitle(title){
	if(parent.window.parent.frames['title'].document.getElementById('title') != null){
		parent.window.parent.frames['title'].document.getElementById('title').innerHTML=title;
	}	
}
//********** End of inner title section *************

//********** Use with generic file upload, currently just for salestrack ***********************
function uploadFile(relatedId,productName,fileCategory,relatedTable,relatedField,filePath){
	var url='/files/fileupload.jsp?relatedId='+relatedId+'&productName='+productName+'&fileCategory='+fileCategory+'&relatedTable='+relatedTable+'&relatedField='+relatedField+'&filePath='+filePath;
	window.open(url);
}
//*************End of file upload*********************

//********* for toggleing the new order link on and off ******
	function toggleNewOrder( onoff ){
  		if (document.all && parent.window.parent.window.header.document.all( "newOrder" ) != null){
  			target = parent.window.parent.window.header.document.all( "newOrder" );
  			if (onoff == "on"){
  				target.style.display = "";
  			} else {
  				target.style.display = "none";
  			}
  		}
	}
//**************** toggle end *****************

//********** Check to see if the user is registered and logged in before proceeding to the link specified ***********************
function checkUserRegistration(redirect){
	window.location.replace("/admin/checkuser.jsp?reDirect=/"+redirect);
}
//*************End of file upload*********************