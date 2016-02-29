<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
<title>Order Confirmation</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>

<body bgcolor="#FFFFFF" text="#000000" class='body' topmargin="0">
<form>
<br>
  <p class='maintitle'>Custom Order Submitted</p>
  <hr size=1 color=red>
  <p class="body">Thank you for your Custom Order.</p>
  <p class="body">A <b>SmallBizPromoter</b> Representative will contact you for 
    any additional information.</p>
  <input type=button value="Continue" onClick="parent.window.location.replace('/index.jsp')">
</form>
</body>
</html>
