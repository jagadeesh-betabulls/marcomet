<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>

<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<html>
<head>
  <title>Update Contact Person</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body>
<form method="post" action="/servlet/com.marcomet.tools.QuickColumnUpdaterServlet">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr>
    <td class="tableheader"><%= request.getParameter("question") %></td>
  </tr>
  <tr>
      <td class="lineitems" align="center"> 
        <% String repIdStr=request.getParameter("repId"); String sqlContactDD = "SELECT c.id 'value', CONCAT(c.lastname,', ',c.firstname) 'text' FROM contacts c WHERE c.companyid = " + request.getParameter("companyId") + " ORDER BY c.lastname, c.firstname"; %>
        <formtaglib:SQLDropDownTag dropDownName="newValue" sql="<%= sqlContactDD %>" selected="<%=repIdStr%>" extraCode="" /> 
      </td>
  </tr>
  <tr>
  	<td align="center">
  	<input type="button" value="Update" onClick="submit()">
	&nbsp;&nbsp;&nbsp;&nbsp;
	<input type="button" value="Cancel" onClick="self.close()">
	</td>
  </tr>
</table>
<input type="hidden" name="tableName" value="<%=request.getParameter("tableName")%>">
<input type="hidden" name="columnName" value="<%=request.getParameter("columnName")%>">
<input type="hidden" name="valueType" value="<%=request.getParameter("valueType")%>">
<input type="hidden" name="primaryKeyValue" value="<%=request.getParameter("primaryKeyValue")%>">
<input type="hidden" name="tableName" value="<%=request.getParameter("tableName")%>">
<input type="hidden" name="$$Return" value="<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>">
</form>
</body>
</html>
