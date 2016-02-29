<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%

String prodId=((request.getParameter("prodId")==null)?"":request.getParameter("prodId"));
%><html>
<head>
  <title>Update Product Inventory Status</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body>
<jsp:include page="/minders/workflowforms/CheckProducts.jsp" >
	<jsp:param name="productId" value="<%=prodId%>" />
</jsp:include>
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr>
  	<td align="center">
  	<input type="button" value="Update" onClick="submit()">
	&nbsp;&nbsp;&nbsp;&nbsp;
	<input type="button" value="Cancel" onClick="self.close()">
	</td>
  </tr>
</table>
<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>
</body>
</html>