<html>
<head>
<title>Vendor Reports Menu</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" text="#000000">
<table>
	<tr>
		<td class="minderheadercenter">Reports</td>
	</tr>
	<tr>
		<td>
			<ol>
				<li><a href="/reports/buyers/invoiceHistoryFilters.jsp">Invoice History</a></li>
				<li><a href="/reports/buyers/orderHistoryFilters.jsp">Order History</a></li>
				<li><a href="/reports/buyers/statementAccount.jsp">Statement of Account</a></li>
			</ol>
		</td>
	</tr>
  <tr><td align="center" height="15px"></td></tr>
  <tr>
    <td><input type="button" value="Exit" onClick="history.go(-1)"></td>
  </tr>
</table>
</body>
</html>
