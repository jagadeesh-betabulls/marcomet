<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.util.*,com.marcomet.environment.SiteHostSettings;" %>
<% SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<html>
<head>
  <title>Add User</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=shs.getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
  	<script type="text/javascript">
  			var zip="";
  			var processing=false;
			</script>
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body background="<%=shs.getSiteHostRoot()%>/images/back3.jpg" leftmargin="30" topmargin="10" text="#000000" onLoad="MM_preloadImages('/images/buttons/continueover.gif');window.history.forward(1);">
<form method="post" action="/servlet/com.marcomet.admin.company.AddCompanyMember">
  <p class="Title">Add User to Company: - <span class="label">Please enter all information accurately.<font color="#FF0000"> <b>*</b></font> = Required Field</span></p>
<%if (request.getParameter("email")!=null ) { %> 
  <p class="subTitle"><font color="#FF0000"><b>**There is a user already with the chosen user name and/or email address. If you don't remember your username or password you can click here to have it reset and sent to your email address: <a href='/admin/user_password_reset.jsp'>RETRIEVE USER NAME AND RESET PASSWORD</a> **</b></font></p>
  <% } %>
  <jsp:include page="/includes/UserRegistration.jsp" flush="true" />
  <hr size=1 color=red>
  <div align="center" id="processing"></div>
  <div id="formSection">
  <table width=100%>
    <tr> 
      <td width="428">&nbsp;</td>
      <td width="74"><a href="javascript:parent.window.location.replace('/index.jsp')"class="greybutton">Cancel</a></td>
      <td width="10">&nbsp;</td>
      <td width="10">&nbsp; </td>
      <td width="10">&nbsp;</td>
      <td width="62"><a href="javascript:checkAndSubmitForm();" class="greybutton" onclick="document.getElementById('processing').innerHTML = '<img src=\'/images/loader.gif\'/> Processing. . .';">Submit</a></td>
      <td width="448">&nbsp; </td>
    </tr>
  </table>
  </div>
  <div id="waitSection" align="center" style="display:none;"><img src='/images/loader.gif'/> Processing. . .</div>
<input type="hidden" name="errorPage" value="/app-admin/users/AddCompanyMemberForm.jsp">
<input type="hidden" name="siteHostId" value="<%=shs.getSiteHostId()%>">
<input type="hidden" name="lastIP" value="<%=request.getRemoteAddr()+((request.getHeader("x-forwarded-for")==null || request.getHeader("x-forwarded-for").equals("") )?"":":"+request.getHeader("x-forwarded-for"))%>">
<input type="hidden" name="defaultWebsite" value="<%=shs.getSiteHostId()%>">
<input type="hidden" name="defaultRoleId" value="1">
<input type="hidden" name="$$Return" value="[/users/AccountInformationPage.jsp]">
<script type="text/javascript">

function getXMLHTTPRequest(){
	// Firefox, Other
	try{
		req = new XMLHttpRequest();
	}
	catch(err1){
		// Microsoft Only Checks
	    try{
	    	req = new ActiveXObject("Msxml2.XMLHTTP");
	    }
	    catch (err2){
	        try{
	        	req = new ActiveXObject("Microsoft.XMLHTTP");
	        }
	        catch (err3){
	            req = false;
	        }}}
	return req;
}

function queryAJAX(http, aUrl, callBack){
    myRand = parseInt(Math.random()*99999999999);
    myRandB = parseInt(Math.random());
    // add random number to URL to avoid cache problems
    var modurl = aUrl+"&rand="+myRand+"_"+myRandB;
    http.open("GET", modurl, true);
    http.onreadystatechange = callBack;
	// Send the Request
    http.send(null);
}


document.getElementById("aName").onblur = function(){
	checkSiteNumber(document.getElementById("aName"));
}
document.getElementById("aUserName").onblur = function(){checkUniqueUser(document.getElementById("aUserName"),"username");}
document.getElementById("aEmail").onblur = function(){preCheckEmail();}

var zip="";

var http;
var mode="";

function preCheckEmail(){
	if(emailCheck(document.forms[0].email.value)){
			checkUniqueUser(document.getElementById("aEmail"),"email");
	}
}

function checkSiteNumber(field) {
	if (field.value.length > 0) {http = getXMLHTTPRequest();queryAJAX(http, "/servlet/com.marcomet.users.admin.ValidateSiteNumber?value="+(field.value.toLowerCase()), checkSiteNumberCB);}
}
function checkUniqueUser(field,modeStr) {
	mode=modeStr
	if (field.value.length > 0) {http = getXMLHTTPRequest();queryAJAX(http, "/servlet/com.marcomet.users.admin.ValidateUserName?mode="+mode+"&value="+(field.value.toLowerCase()), checkUniqueUserCB);}
}


function checkSiteNumberCB(){
    if (http.readyState == 4) {
        if(http.status == 200) {
			var response = http.responseXML;
			var txt = http.responseText;
			var valid = response.getElementsByTagName("valid")[0].childNodes[0].nodeValue;
			var siteName = ((valid=="true")?response.getElementsByTagName("siteName")[0].childNodes[0].nodeValue:"");
			zip = ((valid=="true")?response.getElementsByTagName("zip")[0].childNodes[0].nodeValue:"");
			var brand = ((valid=="true")?response.getElementsByTagName("brand")[0].childNodes[0].nodeValue:"");
			var msg = ((valid=="true")?response.getElementsByTagName("msg")[0].childNodes[0].nodeValue:"");
            if (valid == "false") {
            	document.getElementById('chkUsrRst').innerHTML = '<img title="Error Icon" src="/images/chkBad.png"/> <span style="font-size:0.9em;color:gray">&nbsp;This is not a valid site number: '+msg+'</span>';
            } else if (valid == "true"){
          		document.getElementById('chkUsrRst').innerHTML = '<img title="Site Number is OK" src="/images/chkGood.png"/>&nbsp;'+brand+': '+siteName+'&nbsp;**';
          	} else {
				document.getElementById('chkUsrRst').innerHTML = msg;
			}
        }
    }else{
    	document.getElementById('chkUsrRst').innerHTML = '<img src="/images/loader.gif"/>';
    }
  }

function checkUniqueUserCB(){
	if ((mode=='email' && emailCheck(document.forms[0].email.value)) || mode=='username'){
	    if (http.readyState == 4) {
	        if(http.status == 200) {
				var response = http.responseXML;
				var valid = response.getElementsByTagName("valid")[0].childNodes[0].nodeValue;
				var msg = response.getElementsByTagName("msg")[0].childNodes[0].nodeValue.replace("{","<").replace("}",">");
				while (msg.indexOf("{") >= 0){
					msg = msg.replace("{", "<").replace("}",">");
				}
	            if (valid == "false") {
	            	document.getElementById(mode+'D').innerHTML = "<img title='Error Icon' src='/images/chkBad.png'/> <span style='font-size:0.9em;color:gray'>&nbsp;"+msg+"</span>";
	            } else if (valid == "true"){
	          		document.getElementById(mode+'D').innerHTML = '<img title="Site Number is OK" src="/images/chkGood.png"/>';
	          	} else {
					document.getElementById(mode+'D').innerHTML = "**";
				}
	        }
	    }else{
	    	document.getElementById(mode+'D').innerHTML = '<img src="/images/loader.gif"/>';
	    }
	 }
  }

  </script>
</form>
</body>
</html>