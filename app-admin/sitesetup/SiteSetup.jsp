<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.environment.*,com.marcomet.admin.site.*;" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>

<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%	
	SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
	SiteSetupObject sso = new SiteSetupObject(shs.getSiteHostId());
	UserProfile up = (UserProfile)session.getAttribute("userProfile");	
%>
<html>
<head>
<title>Update Information</title>
<META HTTP-EQUIV="pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Pragma-directive" CONTENT="no-cache">
<META HTTP-EQUIV="cache-directive" CONTENT="no-cache">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" text="#000000">

<form method="post" action="/servlet/com.marcomet.admin.site.UpdateSiteSetupServlet">
<table>
<%
	if(request.getAttribute("errorMessage")!= null){
%>
	<tr><td colspan="4"><%= (String)request.getAttribute("errorMessage") %></td></tr>
<%
	}
%>
	<tr>
		<td class="label">Outer Frame:</td><td><input type="text" name="outerFrameSetHeight" value="<%= sso.getOuterFrameSetHeight()%>"></td>
	</tr>
	<tr>
		<td class="label">Inner Frame:</td><td><input type="text" name="innerFrameSetHeight" value="<%= sso.getInnerFrameSetHeight()%>"></td>
	</tr>
</table>

<input type="button" value="Update Settings" onClick="submitForm()" >
<input type="button" value="Cancel" onClick="location.href='/app-admin/index.jsp'">

<p>
<input type="hidden" name="companyId" value="<%= up.getCompanyId()%>" >
<input type="hidden" name="errorPage" value="/app-admin/sitesetup/SiteSetup.jsp">
<input type="hidden" name="$$Return" value="[/app-admin/sitesetup/SiteSetup.jsp]">
</form>
</body>
</html>
