<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
<title>Order Confirmation</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<body leftmargin="10" topmargin="10" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/continueover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">

<table height="100%" width="100%">
  <tr> 
    <td valign="top"> 
      <table width="100%">
        <tr> 
          <td class="Title" valign="top"></td>
        </tr>
      </table>
    </td>
  </tr>
  <tr> 
    <td align="center" class="catalogLABEL"> 
      <p class="catalogTITLE"><font size="4">Thank you for registering.</font></p>
      <p>You will receive an email confirming your registration and user name.</p><p>Please click continue to access the website. You will either be automatically logged in or you may log in with your newly created user name and password.<br><br>We look forward to serving you.</p>
      </td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2" align="center"> <a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp')" class="greybutton">Continue</a>
    </td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
  </tr>
</table>
</body>
</html>
