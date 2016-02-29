<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.environment.*,com.marcomet.admin.company.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%-- jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" /--%>
<%	
	UserProfile up = (UserProfile)session.getAttribute("userProfile");
	CompanyInformationObject cio = new CompanyInformationObject(up.getCompanyId());
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
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" text="#000000">

<table>
	<tr>
		<td class="label">Company Name:</td><td ><%= cio.getCompanyName()%></td>
	</tr>
	<tr>
		<td class="label">Company URL:</td><td ><%= cio.getCompanyURL()%></td>
	</tr>
	<tr>
		<td colspan="2" class="contentstitle"><u>Billing Address:</u></td>
	</tr>	
	<tr>
		<td class="label">Address:</td><td ><%= cio.getBillToAddress1()%></td>
	</tr>
	<tr>
		<td class="label"></td><td ><%= cio.getBillToAddress2()%></td>
	</tr>

	<tr>
		<td class="label">City, State &amp; Zip:</td><td ><%= cio.getBillToCity()+", " + cio.getBillToState() + " " + cio.getBillToZipcode() %></td>
	</tr>
	<tr>
		<td class="label">Country:</td>
		<td class="readonlytext"><taglib:LUTableValueTag table="lu_countries" selected="<%= cio.getBillToCountryId()%>"/></td>
	</tr>
	<tr>
		<td colspan="2"  class="contentstitle"><u>Pay To Address:</u></td>
	</tr>
	<tr>
		<td class="label">Address:</td><td ><%= cio.getPayToAddress1()%></td>
	</tr>
	<tr>
		<td class="label"></td><td ><%= cio.getPayToAddress2()%></td>
	</tr>

	<tr>
		<td class="label">City, State &amp; Zip:</td><td ><%= cio.getPayToCity()+", " + cio.getPayToState() + " " + cio.getPayToZipcode() %></td>
	</tr>
	<tr>
		<td class="label">Country:</td>
		<td class="readonlytext"><taglib:LUTableValueTag table="lu_countries" selected="<%= cio.getPayToCountryId()%>"/></td>
	</tr>	
	<tr><td class="label" colspan="4">&nbsp;</td>
	<tr>
		<td class="label">Primary (Default) Contact:</td><td><%= cio.getPrimaryContact() %></td>
	</tr>	
	<tr>
		<td class="label">Bill To Contact:</td><td><%= cio.getBillToContact() %></td>
	</tr>
	<tr>
		<td class="label">Pay To Conact:</td><td><%= cio.getPayToContact() %></td>
	</tr>
	<tr>
		<td class="label">Work Flow Contact:</td><td><%= cio.getPrimaryContact() %></td>
	</tr>	
</table>

<input type="button" value="Edit Information" onClick="location.href = '/app-admin/companyinfo/CompanyInformationForm.jsp'" >
<input type="button" value="Cancel" onClick="location.href='/app-admin/index.jsp'">
<p>
</body>
</html>

