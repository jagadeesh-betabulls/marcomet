<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<%
	String sql;
	ResultSet rs1;
	String loginId = (session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId"); 
	loginId = ((request.getParameter("userId")==null)?loginId:request.getParameter("userId"));
%><html>
<head>
<title>User Account Information</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg" leftmargin="10">
<jsp:include page="/popups/PersonProfilePage.jsp" flush="true"><jsp:param name="personId" value="<%=loginId%>" /><jsp:param name="popup" value="false" /></jsp:include> 
<%if (session.getAttribute("demo")==null &&  (request.getParameter("editFlag")==null || request.getParameter("editFlag").equals("true"))){%>
<hr size=1>
<table alin="center" align="center">
  <tr> 
    <td><a href="/users/AccountInformationForm.jsp" class="greybutton">Edit Information</a></td>
    <td width="1%">
      <div align="center"></div>
    </td>
    <td><a href="/users/ChangePasswordForm.jsp" class="greybutton">Change Password</a></td>
    <td width="1%">
      <div align="center"></div>
    </td>
    <td><a href="javascript:pop('/popups/QuickChangeUserNameForm.jsp?cols=20&rows=1&question=Change%20User%20Name&primaryKeyValue=<%=loginId%>&columnName=user_name&tableName=logins&valueType=string',500,100)" class="greybutton">Change User Name</a></td>
      </tr>
</table><%}else{%><%}%></body>
</html>
