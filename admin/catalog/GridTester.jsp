<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
  <title>Grid Tester</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<body>
  <taglib:PricingGridTag catJobId="<%=request.getParameter(\"catJobId\")%>" vendorId="<%=request.getParameter(\"vendorId\")%>" siteHostId="<%=(String)session.getAttribute(\"siteHostId\")%>" catalogPage="<%=request.getParameter(\"pageNumber\")%>"/>
</body>
</html>
