<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*, java.sql.*, com.marcomet.jdbc.*" %>

<%@ include file="/includes/SessionChecker.jsp" %>

<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />

<html>
<head>

  <title>Invoice <%= request.getParameter("invoiceId")%></title>

  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">

<script language="JavaScript" src="/javascripts/mainlib.js"></script>

<script>

function ccPay(){

document.forms[0].action="/minders/workflowforms/CollectionsForm.jsp";

document.forms[0].submit();

}

</script>

</head>

<body class="label" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">

<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit"><%

	String sql1 = "select * from ar_invoices where id = " +request.getParameter("invoiceId");

	String sql2 = "select * from ar_invoice_details where ar_invoiceid = " + request.getParameter("invoiceId");

	Connection conn = DBConnect.getConnection();
	Statement st1 = conn.createStatement();
	Statement st2 = conn.createStatement();

	ResultSet rsInvoice = st1.executeQuery(sql1);
	ResultSet rsInvoiceDetail = st2.executeQuery(sql2);

	rsInvoice.next();
	rsInvoiceDetail.next();	

%>

<div align="center"> 

<table border=0 ><tr>

        <td> <a href="javascript:pop('/minders/workflowforms/PrintInvoice.jsp?invoiceId=<%=request.getParameter("invoiceId")%>','640','480')" class="greybutton">View 

          Printable Invoice</a> </td>

        <td><a href="javascript:ccPay()" class="greybutton"> Continue and Pay with Credit Card</a></td>

		<td><a href="javascript:document.forms[0].submit()" class="greybutton">Continue -- I've printed my bill and will send payment</a>

</td></tr>

</table>

</div><br><br>

<jsp:include page="/minders/workflowforms/PrintInvoice.jsp" flush="true"><jsp:param  name="invoiceId" value="<%=request.getParameter("invoiceId")%>" /></jsp:include>

<input type="hidden" name="jobId" value="<%= rsInvoiceDetail.getString("jobid") %>" >

<input type="hidden" name="id" value="<%= rsInvoice.getString("id") %>" >

<input type="hidden" name="invoiceId" value="<%= rsInvoice.getString("id") %>" >

<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">

<input type="hidden" name="redirect" value="[/minders/JobMinderSwitcher.jsp]">

<input type="hidden" name="nextStepActionId" value="90">

<input type="hidden" name="statusId" value="2">

<input type="hidden" name="invoiceNumber" value="<%=request.getParameter("invoice_number")%>">

<input type="hidden" name="contactId" value="<%=session.getAttribute("contactId").toString()%>">

</form>
</body>
</html>

<%
try { st1.close(); } catch (Exception e) {}
try { st2.close(); } catch (Exception e) {}
try { conn.close(); } catch (Exception e) {}
%>

