<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.environment.*,com.marcomet.admin.company.*;" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>

<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
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
<jsp:getProperty name="validator" property="javaScripts" />
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" text="#000000">
<form method="post" action="/servlet/com.marcomet.admin.company.UpdateCompanyInformationServlet">
<table>
<%
	if(request.getAttribute("errorMessage")!= null){
%>
	<tr><td colspan="4"><%= (String)request.getAttribute("errorMessage") %></td></tr>
<%
	}
%>
	<tr>
		<td class="label">Company Name:</td><td><input type="text" name="companyName" value="<%= cio.getCompanyName()%>" onChange="formChangedArea('Company')"></td>
	</tr>
	<tr>
		<td class="label">Company URL:</td><td><input type="text" name="companyURL" value="<%= cio.getCompanyURL()%>" onChange="formChangedArea('Company')"></td>
	</tr>
	<tr>
		<td colspan="2"><u>Billing Address:</u></td>
	</tr>	
	<tr>
		<td class="label">Address:</td><td><input type="text" name="billToAddress1" value="<%= cio.getBillToAddress1()%>" onChange="formChangedArea('Locations')"></td>
	</tr>
	<tr>
		<td class="label"></td><td><input type="text" name="billToAddress2" value="<%= cio.getBillToAddress2()%>" onChange="formChangedArea('Locations')"></td>
	</tr>

	<tr>
		<td class="label">City, State &amp; Zip:</td><td>
		<input type="text" name="billToCity" value="<%= cio.getBillToCity()%>" onChange="formChangedArea('Locations')">
		<formtaglib:LUDropDownTag dropDownName="billToStateId" table="lu_abreviated_states" extra="onChange=\"formChangedArea('Locations')\"" selected="<%= cio.getBillToStateId() %>"/>
		<input type="text" name="billToZipcode" value="<%= cio.getBillToZipcode()%>" onChange="formChangedArea('Locations')">
		</td>
	</tr>
	<tr>
		<td class="label">Country:</td>
		<td colspan="3"><formtaglib:LUDropDownTag dropDownName="billToCountryId" table="lu_countries"  extra="onChange=\"formChangedArea('Locations')\"" selected="<%= cio.getBillToCountryId() %>" /></td>
	</tr>	
	<tr>
		<td colspan="2"><u>Pay To Address:</u></td>
	</tr>
	<tr>
		<td class="label">Address:</td><td><input type="text" name="payToAddress1" value="<%= cio.getPayToAddress1()%>" onChange="formChangedArea('Locations')"></td>
	</tr>
	<tr>
		<td class="label"></td><td><input type="text" name="payToAddress2" value="<%= cio.getPayToAddress2()%>" onChange="formChangedArea('Locations')"></td>
	</tr>

	<tr>
		<td class="label">City, State &amp; Zip:</td><td>
		<input type="text" name="payToCity" value="<%= cio.getPayToCity() %>" onChange="formChangedArea('Locations')">
		<formtaglib:LUDropDownTag dropDownName="payToStateId" table="lu_abreviated_states" extra="onChange=\"formChangedArea('Locations')\"" selected="<%= cio.getPayToStateId() %>"/>
		<input type="text" name="payToZipcode" value="<%= cio.getPayToZipcode() %>" onChange="formChangedArea('Locations')">
		</td>
	</tr>
	<tr>
		<td class="label">Country:</td>
		<td colspan="3"><formtaglib:LUDropDownTag dropDownName="payToCountryId" table="lu_countries"  extra="onChange=\"formChangedArea('Locations')\""  selected="<%= cio.getPayToCountryId() %>" /></td>
	</tr>	
	<tr><td class="label">&nbsp;</td>
	<tr>
		<td class="label">Primary (Default) Contact:</td><td>
		<% String sqlContactDD = "SELECT c.id 'value', CONCAT(c.lastname,', ',c.firstname) 'text' FROM contacts c WHERE c.companyid = " + up.getCompanyId() + " ORDER BY c.lastname, c.firstname"; %>
		<formtaglib:SQLDropDownTag dropDownName="primaryContactId" sql="<%= sqlContactDD %>" selected="<%= cio.getPrimaryContactId()%>" extraCode="onChange=\"formChangedArea('Contacts')\"" />
		</td>
	</tr>	
	<tr>
		<td class="label">Bill To Contact:</td><td>
		<formtaglib:SQLDropDownTag dropDownName="billToContactId" sql="<%= sqlContactDD %>" selected="<%= cio.getBillToContactId()%>" />
		</td>
	</tr>
	<tr>
		<td class="label">Pay To Conact:</td><td>
		<formtaglib:SQLDropDownTag dropDownName="payToContactId" sql="<%= sqlContactDD %>" selected="<%= cio.getPayToContactId()%>" />
		</td>
	</tr>
	<tr>
		<td class="label">Work Flow Contact:</td><td>
		<formtaglib:SQLDropDownTag dropDownName="workFlowContactId" sql="<%= sqlContactDD %>" selected="<%= cio.getWorkFlowContactId()%>" />
	</tr>	
</table>

<input type="button" value="Update Information" onClick="submitForm()" >
<input type="button" value="Cancel" onClick="location.href='/app-admin/companyinfo/CompanyInformationPage.jsp'">
<p>
<input type="hidden" name="formChangedLocations" value="0" >
<input type="hidden" name="formChangedCompany" value="0" >
<input type="hidden" name="formChangedContacts" value="0" >
<input type="hidden" name="companyId" value="<%= up.getCompanyId()%>" >
<input type="hidden" name="errorPage" value="/app-admin/companyinfo/CompanyInformationForm.jsp">
<input type="hidden" name="$$Return" value="[/app-admin/companyinfo/CompanyInformationPage.jsp]">
</form>
</body>
</html>
