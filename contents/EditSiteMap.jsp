<%@ page errorPage="/errors/ExceptionPage.jsp" %><%@ page import="com.marcomet.users.security.RoleResolver, com.marcomet.environment.SiteHostSettings" %><% session.setAttribute("currentSession","true"); %>
   <link rel="stylesheet" href="/styles/SiteMap.css" type="text/css">  
<%
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
String pageName=request.getParameter("pageName");

%><html><head><title>Site Map</title>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <link rel="stylesheet" href="/styles/marcomet.css" type="text/css">  
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body leftmargin="20" topmargin="10">
<div class='title'>Site Map for <%=shs.getDomainName()%></div>
<jsp:include page="/includes/topNav.jsp" flush="true" >
	<jsp:param name="pageName" value="<%=pageName%>" />
	<jsp:param name="isTopNav" value="false" />	
</jsp:include>
</body>
</html>
