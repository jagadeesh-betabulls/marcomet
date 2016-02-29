<%@ page import="java.sql.*, java.util.*, com.marcomet.jdbc.SimpleConnection" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
  <title>Grid Bridge Table Builder</title>
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<body>
<form method="post" action="/servlet/com.marcomet.admin.catalog.GridBridgeServlet">
  <table align="center" border="0">
    <tr>
      <td class="contentstitle" colspan="2">Grid Bridge Table Administration
        <hr size=1>
      </td>
    </tr><%
	if (request.getParameter("insertedCount") != null) { %>
    <tr>
      <td align="center" colspan="2"><b><font color="#FF0000"><%=request.getParameter("insertedCount")%> Rows Inserted</font></b></td>
    </tr><%
	} %>
    <tr>
      <td>Catalog Job Id:</td>
      <td><input type="text" name="catJobId" value="<%=(request.getParameter("catalogPage") == null) ? "" : request.getParameter("catJobId")%>"></td>
    </tr>
    <tr>
      <td>Vendor Id:</td>
      <td><input type="text" name="vendorId" value="<%=(request.getParameter("vendorId") == null) ? "" : request.getParameter("vendorId")%>"></td>
    </tr>
    <tr>
      <td>Catalog Page:</td>
      <td><input type="text" name="catalogPage" value="<%=(request.getParameter("catalogPage") == null) ? "" : request.getParameter("catalogPage")%>"></td>
    </tr>
	<tr>
      <td align="center" colspan="2"><input type="submit" value="Submit"></td>
    </tr>
  </table>
</form>
</body>
</html>