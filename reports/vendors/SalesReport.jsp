<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<%		Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
	String loginId = (session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId"); 
	loginId = ((request.getParameter("userId")==null)?loginId:request.getParameter("userId"));
	cB.setContactId(loginId);
%><html>
<head>
  <title>Invoice History Report</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<!----------------------Report Header------------------------------->
<p class="Title">Sales Invoice History Report</p>
<table  border=0 cellpadding=2 cellspacing=0 width=100%>
  <tr>
    <td class="label" width="1%">Name:</td>
    <td class=bodyBlack width="99%"><%= cB.getFirstName() %> <%= cB.getLastName() %></td>
    <td align="right"><a onClick="history.go(-1)" href="#" class="greybutton">Exit</a></td>
  </tr>
  <tr>
    <td class="label">Company:</td>
    <td class="bodyBlack"><%= cB.getCompanyName() %></td>
  </tr>
  <tr>
  <td class="label">Site No:</td>
   <td class="bodyBlack"><%=((request.getParameter("siteNumber").equals(""))?" ":request.getParameter("siteNumber")) %></td>
  </tr>
  <tr>
  <tr> 
    <td class="label">Date&nbsp;From:</td>
    <td class="bodyBlack"><%=((request.getParameter("dateFrom").equals("0000-00-00"))?"All":request.getParameter("dateFrom"))%></td>
  </tr>
  <tr> 
    <td class="label">Date&nbsp;To:<br /><br /><br /></td>
    <td class="bodyBlack" valign="top"><%=((request.getParameter("dateTo").equals("2029-12-31"))?"All":request.getParameter("dateTo"))%></td>
  </tr>
</table>
<table border="0" cellpadding="1" cellspacing="0" width="100%">

<!--------------------End Header------------------------------------------>
<%
String sqlSiteHosts="";
String companyId=request.getParameter("companyId");
ResultSet rsBuyers;
String alt="alt";
double rTotalPrice = 0;
double rTotalShipping = 0;
double rTotalSalesTax = 0;
double rTotalDeposit = 0;
double rTotalTotal = 0;
double rTotalPayments = 0;
String noinvoice="no";
String siteNumber=request.getParameter("siteNumber");
String headerRow="<tr><td class=\"minderheadercenter\" >Customer #</td><td class=\"minderheadercenter\" >Invoice Date</td><td class=\"minderheadercenter\" >Invoice #</td><td class=\"minderheadercenter\" >Job #</td><td class=\"minderheadercenter\" >Job Name</td><td class=\"minderheadercenter\" >Amount</td><td class=\"minderheadercenter\" >Shipping</td><td class=\"minderheadercenter\" >Sales Tax</td><td class=\"minderheadercenter\" >Deposit</td><td class=\"minderheadercenter\" >Total</td><td class=\"minderheadercenter\" width=\"10px\" >&nbsp;</td><td class=\"minderheadercenter\" >Payments</td><td class=\"minderheadercenter\" >Balance</td></tr>";
System.out.println("request.getParameter('dateFrom') is "+request.getParameter("dateFrom"));
System.out.println("request.getParameter('dateTo') is "+request.getParameter("dateTo"));

String sqlARInvoices;			

if(request.getParameter("siteNumber")==null ||request.getParameter("siteNumber").equals("")){
sqlARInvoices = "SELECT sum(acd.payment_amount) as paid, st.buyer_exempt,ai.*,arid.*,luas.value, j.job_name FROM ar_invoice_details arid, jobs j, sales_tax st, lu_abreviated_states luas,ar_invoices ai LEFT JOIN ar_collection_details acd on ai.id = acd.ar_invoiceid WHERE  ai.id = arid.ar_invoiceid AND arid.jobid = j.id AND st.entity = luas.id  AND (ai.vendor_id = 105 or ai.vendor_id = 2)   AND st.job_id=j.id AND ai.creation_date >= '" + request.getParameter("dateFrom") +"' and ai.creation_date <= '" + request.getParameter("dateTo") + "' GROUP BY ai.id ORDER BY ai.creation_date ";
}else {
	
sqlARInvoices = "SELECT sum(acd.payment_amount) as paid, st.buyer_exempt,ai.*,arid.*,luas.value, j.job_name FROM ar_invoice_details arid, jobs j, sales_tax st, lu_abreviated_states luas,ar_invoices ai LEFT JOIN ar_collection_details acd on ai.id = acd.ar_invoiceid WHERE  ai.id = arid.ar_invoiceid AND arid.jobid = j.id AND st.entity = luas.id  AND (ai.vendor_id = 105 or ai.vendor_id = 2)   AND st.job_id=j.id AND ai.creation_date >= '" + request.getParameter("dateFrom") +"' and ai.creation_date <= '" + request.getParameter("dateTo") + "' AND site_number='"+request.getParameter("siteNumber")+"' GROUP BY ai.id ORDER BY ai.creation_date ";	
}
System.out.println("sqlARInvoices is "+sqlARInvoices);
ResultSet rsARInvoices = st.executeQuery(sqlARInvoices);

if(rsARInvoices.next()){
  %><%=headerRow%><%
  do{
    rTotalPrice += rsARInvoices.getDouble("ar_purchase_amount");
    rTotalShipping += rsARInvoices.getDouble("ar_shipping_amount"); 
    rTotalSalesTax += rsARInvoices.getDouble("ar_sales_tax");
    rTotalDeposit += rsARInvoices.getDouble("deposited");
    rTotalTotal += rsARInvoices.getDouble("ar_invoice_amount");
    rTotalPayments += rsARInvoices.getDouble("paid");
    alt=((alt.equals(""))?"alt":"");
    %>
    <tr>
    <td class="lineitemcenter<%=alt%>" ><%=rsARInvoices.getString("bill_to_contactid")%></td>
    <td class="lineitemcenter<%=alt%>" ><%=rsARInvoices.getString("creation_date")%></td>
    <td class="lineitemcenter<%=alt%>" ><a href="javascript:pop('/minders/workflowforms/PrintInvoice.jsp?invoiceId=<%=rsARInvoices.getString("id")%>','640','480')"><%=rsARInvoices.getString("invoice_number")%></a></td>
    <td class="lineitemcenter<%=alt%>" ><a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%=rsARInvoices.getString("arid.jobid")%>','640','480')"><%=rsARInvoices.getString("arid.jobid")%></td>
    <td class="lineitemcenter<%=alt%>" ><%=rsARInvoices.getString("job_name")%></td>

    <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("ar_purchase_amount"))%></td>
    <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("ar_shipping_amount"))%></td>
    <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("ar_sales_tax"))%></td>
    <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("deposited"))%></td>
    <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount"))%></td>
    <td class="lineitemright<%=alt%>">&nbsp;</td>
    <td class="lineitemright<%=alt%>" ><a href="javascript:pop('/minders/workflowforms/InvoicePayments.jsp?invoiceId=<%=rsARInvoices.getString("id")%>','640','480')"><%=formatter.getCurrency(rsARInvoices.getDouble("paid"))%></a></td>
    <td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid"))%></td>
    </tr>
    <%
    noinvoice="no";
   		 
  }while(rsARInvoices.next());  //ends invoices loop for the buyer

  }else{							
  noinvoice="yes";
  %><tr><td colspan="12">No Invoices Found for this buyer.</td></tr><%
}%>
<tr>				
<td class="label" colspan=5>Report Totals:</td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalPrice)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalShipping)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalSalesTax)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalDeposit)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalTotal)%></td>
<td class="lineitemright"></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalPayments)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalTotal-rTotalPayments)%></td>
</tr>
</table>
</body>
</html><%st.close();conn.close();%>