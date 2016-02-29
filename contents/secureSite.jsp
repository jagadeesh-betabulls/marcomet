<%@ page import="javax.servlet.*,javax.servlet.http.*,java.util.*,java.sql.*,com.marcomet.jdbc.*, com.marcomet.environment.*" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%
if(request.getParameter("contents")!=null){
	session.removeAttribute("contents");
}
%><html>

<head>
<style type="text/css">

.winBox{
position:absolute;
width:420px;
height:240px;
z-index:15;
top:50%;
left:50%;
margin:-150px 0 0 -150px;

-webkit-box-shadow:3px 3px 6px black, 0 0 0 gray;

	background-image: url(/images/window.png);
}


</style>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>Secure Site Redirect</title>
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script language="javascript" src="/javascripts/mainlib.js"></script>
<script>

MM_preloadImages('/images/lockIcon.png','/images/loading.gif');

function moveToCO(){
	window.location.href="/catalog/checkout/Checkout.jsp";
}

</script>
</head>

<body bgcolor="#FFFFFF" class="body">

<div class='winBox'>
	<div style="padding-top:20px;padding-left:20px;padding-right:20px;">
	<div class="offeringTITLE" align="left">SECURE CHECKOUT<hr></div>
<img src="/images/lockIcon.png" align="left"><br>You are currently being redirected to a secure site for checkout.<br><br>Please wait while we build your shopping cart&hellip;<br><br><br>
</div>
	<div align="center"><img src="/images/loading.gif"></div>
</div>
<script>
setTimeout(function() { moveToCO(); }, 2000);
</script>
</body>

</html>
