<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
<title>Duplicate File Detected</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<body class="body">
<form>
<br>
  <p>
  Oops!  Some or all of the files you are attempting to upload already 
  exist on our system.  Due to the error, none of the files you selected
  have been uploaded.  Please rename the files and try your uploads again.
  </p>
  <input type=button value="Back" onClick="history.go(-1)">
</form>
</body>
</html>
