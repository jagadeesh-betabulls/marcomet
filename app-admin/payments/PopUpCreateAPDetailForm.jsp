<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.admin.accounting.*;" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
	String[] rqdFlds = {"amount"};
	validator.setReqTextFields(rqdFlds);
	String[] numFlds = {"amount"};
	validator.setNumberFields(numFlds);
%><html>
<head>
<title>Create AP Invoice Detail</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" text="#000000">
<form method="post" action="/servlet/com.marcomet.admin.accounting.CreateAPPaymentDetailForm">
<table align="center">
	<tr>
		<td>AP Invoice ID:</td><td><%
		Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
		Statement st = conn.createStatement();
	ResultSet rsOpenAps = st.executeQuery("SELECT distinct ai.id 'id' FROM ap_invoice_details aid,ap_invoices ai LEFT JOIN ap_payment_details apd ON ai.id=apd.ap_invoice_id WHERE ai.id = aid.ap_invoiceid AND apd.ap_invoice_id is null OR (ai.ap_invoice_amount != apd.amount AND ai.id = apd.ap_invoice_id)");
	if(rsOpenAps.next()){
		%><select name="apInvoiceId"><%
				do{		
			%><option><%= rsOpenAps.getString("id") %></option><%
				}while(rsOpenAps.next());	
				%></select><%
	}else{
%>No Open AP's found<!--: <input type="text" name="apInvoiceId" value=""> --><%	
	}		%></td>
	</tr>
	<tr>
		<td>Amount:</td><td><input type="text" name="amount"></td>
	</tr>
	<tr>
		<td>Accounting System Reference:</td><td><input type="text" name="acctgSysRef" value=""></td>
	</tr>
</table>
<center><input type="button" value="Submit" onClick="submitForm()"></center>
<p>
<input type="hidden" name="$$Return" value="<script>parent.window.opener.refresh();setTimeout('200',close());</script>">
</form>
</body>
</html><%conn.close();%>