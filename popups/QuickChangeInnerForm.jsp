<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
String tableName=((request.getParameter("tableName")==null || request.getParameter("tableName").equals(""))?"jobs":request.getParameter("tableName"));%><html>
<head>
  <title><%= request.getParameter("question") %></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body>
<form method="post" action="/servlet/com.marcomet.tools.QuickColumnUpdaterServlet">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr><td class="tableheader"><%= request.getParameter("question") %></td></tr>
  <tr><td class="lineitems" align="center">
      <textarea name="newValue" cols="<%=request.getParameter("cols")%>" rows="<%=request.getParameter("rows")%>"><%
      java.sql.ResultSet rs = st.executeQuery("SELECT " + request.getParameter("columnName") + " FROM "+request.getParameter("tableName")+" j WHERE j.id = " + request.getParameter("primaryKeyValue"));
      if (rs.next()) { %><%=rs.getString(1)%><%
      } %></textarea></td></tr>
<tr><td align="center"><input type="button" value="Update" onClick="<%=((request.getParameter("inner")!=null && !(request.getParameter("inner").equals("")))?"parent.window.opener.document.getElementById('"+request.getParameter("inner")+"').innerHTML=document.forms[0].newValue.value;":"")%>document.forms[0].submit();">&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="Cancel" onClick="self.close()"></td></tr>
</table>
<input type="hidden" name="tableName" value="<%=tableName%>">
<input type="hidden" name="columnName" value="<%=request.getParameter("columnName")%>">
<input type="hidden" name="valueType" value="<%=request.getParameter("valueType")%>">
<input type="hidden" name="primaryKeyValue" value="<%=request.getParameter("primaryKeyValue")%>">
<input type="hidden" name="tableName" value="<%=request.getParameter("tableName")%>">
<input type="hidden" name="$$Return" value="<script>setTimeout('close()',500);</script>">
</form>
</body>
</html><%st.close();conn.close();%>
