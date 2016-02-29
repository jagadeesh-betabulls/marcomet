<html>
<head>
  <title>Frame Breaker</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<%if (request.getAttribute("errorMessage")!=null){
	session.setAttribute("errorMessage",request.getAttribute("errorMessage").toString());%>
<body onLoad="parent.window.location.replace('https://<%=((com.marcomet.environment.SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName()%>/frames/InnerFrameset.jsp?contents=/minders/workflowforms/CollectionsForm.jsp?invoiceId=<%=request.getParameter("id")%>&error=<%=(String)request.getAttribute("errorMessage")%>')">
<%}else{%>
<body onLoad="parent.window.location.replace('http://<%=((com.marcomet.environment.SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName()%>/index.jsp?contents=/minders/JobMinderSwitcher.jsp')">
<%}%>
</body>
</html>