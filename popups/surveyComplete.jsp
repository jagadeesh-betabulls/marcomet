<%String siteHostRoot=((request.getParameter("siteHostRoot")==null)?(String)session.getAttribute("siteHostRoot"):request.getParameter("siteHostRoot"));%><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<META HTTP-EQUIV="pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Pragma-directive" CONTENT="no-cache">
<META HTTP-EQUIV="cache-directive" CONTENT="no-cache">
<title>Survey</title>
<link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
<link rel="stylesheet" href="<%=siteHostRoot%>/styles/vendor_styles.css" type="text/css">
</head>
<body style="margin-top:100px;"><div align=center class="subtitle">Thank you for your valuable input.</div><br><br><br><br><br><div align=center class="subtitle"><input type="button" value="Continue" onclick="parent.closeSurvey();"></div></body>
</html>
