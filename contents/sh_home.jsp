<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<% 
String showRelease=((request.getParameter("ShowRelease")==null)? "" :request.getParameter("ShowRelease"));
String showInactive=((request.getParameter("ShowInactive")==null)? "" :request.getParameter("ShowInactive"));
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
%><html>
<head>
<title><%=shs.getSiteName()%></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/menu_styles.css" type="text/css">
<link rel="stylesheet" href="/styles/vendor_styles.css" type="text/css">
</head>
<body bgcolor="#FFFFFF" topmargin="10" leftmargin="5">
<table cellpadding=0 cellspacing=0 border=0><tr><td valign="top">
	<jsp:include page="/contents/leftnavmenu.jsp" flush="false" >
		<jsp:param name="ShowInactive" value="<%=showInactive%>" />
	</jsp:include>	
</td>
<td valign="top"><img src="/images/spacer.gif" width='20'></td>
<td valign="top"><div class="offeringTITLE">Welcome to <%=shs.getSiteName()%>!</div>
<table cellpadding=0 cellspacing=0 border=0>
<tr>
<div style="margin-right:15px;margin-left:15px" >
<jsp:include page="/includes/featuredProducts.jsp" flush="true" >
	<jsp:param name="ShowRelease" value="<%=showRelease%>" />
	<jsp:param name="ShowInactive" value="<%=showInactive%>" />
</jsp:include>
</div>
</td>
<td valign="top"><img src="/images/spacer.gif" width='20'></td>
<td valign="top"><div align="center">
	<jsp:include page="/includes/OrderSummaryInc.jsp" flush="false" ></jsp:include>
	<jsp:include page="/contents/page.jsp" flush="false" >
		<jsp:param name="pageName" value="rightNav" />
	</jsp:include>	
</div>
</td>
</tr></table>
</body>
</html>