<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>

<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<html>
<head>
  <title><%= request.getParameter("question") %></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body>
<form method="post" action="/servlet/com.marcomet.tools.QuickColumnUpdaterServlet" >
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr>
    <td class="tableheader"><%= request.getParameter("question") %></td>
  </tr>
  <tr>
      <td class="lineitems" align="center"> 
        <% String repIdStr=request.getParameter("repId"); 
String sqlContactDD = "SELECT "+request.getParameter("valueField")+" 'value', "+request.getParameter("textField")+" 'text' FROM "+request.getParameter("luTableName")+ " c WHERE "+request.getParameter("compField") + " = " + request.getParameter("compValue") + " ORDER BY "+request.getParameter("orderBy"); %>
        <formtaglib:SQLDropDownTag dropDownName="newValue" sql="<%= sqlContactDD %>" selected="<%=request.getParameter("valueFieldVal")%>"  extraCode="" /> 
      </td>
  </tr>
  <tr>
  	<td align="center">
  	<input type="button" value="Update" onClick="submit()">
	&nbsp;&nbsp;&nbsp;&nbsp;<%if(request.getParameter("tableName").equals("products")){%><input type="button" value="Change Across Tiers" onClick='document.forms(0).action="QuickChangeAcrossBrandsForm.jsp?noPL=false&submitted=true";document.forms(0).submit();'>&nbsp;&nbsp;<%}%>&nbsp;&nbsp;
	<input type="button" value="Cancel" onClick="self.close()"><%
	if(request.getParameter("tableName").equals("products")){%><br><br><input type="button" value="Change Across Brands AND Tiers" onClick='document.forms(0).action="QuickChangeAcrossBrandsForm.jsp?noPL=true&noCID=true&submitted=true";document.forms(0).submit();'><%}
	%></td>
  </tr>
</table>
<input type="hidden" name="tableName" value="<%=request.getParameter("tableName")%>">
<input type="hidden" name="columnName" value="<%=request.getParameter("columnName")%>">
<input type="hidden" name="valueType" value="<%=request.getParameter("valueType")%>">
<input type="hidden" name="primaryKeyValue" value="<%=request.getParameter("primaryKeyValue")%>">
<input type="hidden" name="$$Return" value="<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>">
</form>
</body>
</html>
