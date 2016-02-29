<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<html>
<head>
<title>Company Contacts List</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>

<body><%
UserProfile up = (UserProfile)session.getAttribute("userProfile");
String companyName=sl.getValue("companies","id",up.getCompanyId(), "company_name");
%>
<div class="title">Company Contact List for <%=companyName%></div>
<p><a class="menuLink" href="/app-admin/users/AddCompanyMemberForm.jsp">&nbsp;Add New Contact&nbsp;</a>&nbsp;&nbsp;
<a class="menuLink" href="/app-admin/index.jsp">&nbsp;Cancel&nbsp;</a></p>
<table width="20%" border=0 >
<tr>
	<td class="lineitems">
		<div class="subtitle" align='center'>Current Contacts</div>
	</td>
</tr><%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
	String sqlMembers = "SELECT CONCAT(if(c.active_flag=0,'[USER INACTIVE] ',''),c.lastname,', ', c.firstname) 'fullname' FROM contacts c WHERE c.companyid = " + up.getCompanyId() + " ORDER BY c.lastname";
	ResultSet rsMembers = st.executeQuery(sqlMembers);
	while(rsMembers.next()){
%>	<tr>
		<td class="lineitems">
			<%= rsMembers.getString("fullname") %>
		</td>
	</tr><%
	}
%></table>
</body>
</html><%conn.close();%>
