<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
<title>Password Reset Confirmation</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>

<body bgcolor="#FFFFFF" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg" leftmargin="30"  class='body' topmargin="0">
<form>
<br>
  <p class='maintitle'>Password Reset</p>
  <hr size=1 color=red>
  <p class="body">The password for this user has been reset. Please notify the 
    user of the new password.</p>
  <input type=button value="Continue" onClick="parent.window.location.replace('/index.jsp')">
</form>
</body>
</html>
