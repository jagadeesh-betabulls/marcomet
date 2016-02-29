<%@ page import="java.sql.*, java.util.*, com.marcomet.jdbc.SimpleConnection" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
  <title>Grid Bridge Table Builder</title>
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<body>
<form method="post" action="/servlet/com.marcomet.admin.catalog.RebuildGridBridgeServlet">
  <table align="center" border="0">
    <tr>
      <td class="contentstitle">Grid Bridge Table Rebuilder
        <hr size=1>
      </td>
    </tr><%
	if (request.getParameter("insertedCount") != null) { %>
    <tr>
      <td align="center"><b><font color="#FF0000"><%=request.getParameter("insertedCount")%> Rows Inserted</font></b></td>
    </tr><%
	} %>
	<tr>
      <td align="center"><input type="submit" value="Submit"></td>
    </tr>
  </table>
</form>
</body>
</html>