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

%>
<html>
<head>
  <title>Statement of Account</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<!----------------------Report Header------------------------------->
<p class="Title">Statement of Account</p>
<table  border=0 cellpadding=0 cellspacing=0 width=100%>
  <tr>
    <td width="5%" class="label" style="text-align:right">Name:</td>
    <td width="70%" class='bodyBlack'><%= cB.getFirstName() %> <%= cB.getLastName() %></td>
    <td width="25%" align="right"><a  href="/reports/buyers" class="greybutton">EXIT</a></td>
  </tr>
  <tr>
    <td class="label" style="text-align:right">Company:</td>
    <td class="bodyBlack"><%= cB.getCompanyName() %></td>
    <td>&nbsp;</td>
  </tr>
</table>
<table border="0" cellpadding="1" cellspacing="0" width="100%">
<!--------------------End Header------------------------------------------>
<%
String sqlSiteHosts="";
String companyId=session.getAttribute("companyId").toString();
String contactId=session.getAttribute("contactId").toString();
String contactIdFilter=( (!(contactId.equals("")))?" ":"");
ResultSet rsBuyers;
String alt="alt";
double rTotalPrice = 0;
double rTotalShipping = 0;
double rTotalSalesTax = 0;
double rTotalDeposit = 0;
double rTotalTotal = 0;
double rTotalPayments = 0;
double ageUnder30=0;
double age30_60=0;
double age60_90=0;
double age90_120=0;
double ageOver120=0;


String noinvoice="no";
String headerRow="<tr><td colspan=12 class=minderheadercenter>INVOICES</td><td>&nbsp;</td><td class='minderheadercenter' colspan=5>AGING</td></tr><tr><td class='minderheadercenter' >Invoice&nbsp;Date</td><td class='minderheadercenter' >Invoice&nbsp;#</td><td class='minderheadercenter' >Job #</td><td class='minderheadercenter' >Job Name</td><td class='minderheadercenter' >Amount</td><td class='minderheadercenter' >Shipping</td><td class='minderheadercenter' >Sales Tax</td><td class='minderheadercenter' >Deposit</td><td class='minderheadercenter' >Total</td><td class='minderheadercenter' width='10px' >&nbsp;</td><td class='minderheadercenter' >Payments</td><td class='minderheadercenter' >Balance</td><td>&nbsp;</td><td class='minderheadercenter' >&nbsp;0&nbsp;&minus;&nbsp;30&nbsp;</td><td class='minderheadercenter' >&nbsp;31&nbsp;&minus;&nbsp;60&nbsp;</td><td class='minderheadercenter' >&nbsp;61&nbsp;&minus;&nbsp;90&nbsp;</td><td class='minderheadercenter' >&nbsp;91&nbsp;&minus;&nbsp;120&nbsp;</td><td class='minderheadercenter' >&nbsp;&gt; 120&nbsp;</td></tr>";

String sqlARInvoices = "SELECT (to_days(now())-to_days(ai.creation_date)) as aging,if(sum(acd.payment_amount) is null,0,sum(acd.payment_amount)) as paid, st.buyer_exempt,ai.*,arid.*,luas.value, j.job_name FROM contacts c, ar_invoice_details arid, jobs j, sales_tax st, lu_abreviated_states luas,ar_invoices ai LEFT JOIN ar_collection_details acd on ai.id = acd.ar_invoiceid WHERE  ai.id = arid.ar_invoiceid AND c.id="+contactId+" and arid.jobid = j.id AND st.entity = luas.id  AND (ai.bill_to_contactid = c.id or (((j.site_number=c.default_site_number and c.default_site_number<>'0' and trim(leading '0' from c.default_site_number)<>'' and c.default_site_number is not null) or (((c.default_site_number='0' or trim(leading '0' from c.default_site_number)='' or c.default_site_number is null) or (j.site_number='0' or trim(leading '0' from j.site_number)='' or j.site_number is null)) and j.jbuyer_contact_id=c.id)))) AND st.job_id=j.id GROUP BY ai.id ORDER BY ai.creation_date ";

//"SELECT (to_days(now())-to_days(ai.creation_date)) as aging,sum(acd.payment_amount) as paid, st.buyer_exempt,ai.*,arid.*,luas.value, j.job_name FROM ar_invoice_details arid, jobs j, sales_tax st, lu_abreviated_states luas,ar_invoices ai LEFT JOIN ar_collection_details acd on ai.id = acd.ar_invoiceid WHERE  ai.id = arid.ar_invoiceid AND arid.jobid = j.id AND st.entity = luas.id  AND ai.bill_to_contactid = " + contactId + "  AND st.job_id=j.id GROUP BY ai.id ORDER BY ai.creation_date ";

ResultSet rsARInvoices = st.executeQuery(sqlARInvoices);
if(rsARInvoices.next()){
  %><%=headerRow%><%
  do{
    if(rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid") != 0){
	 ageUnder30+=((rsARInvoices.getInt("aging")<31) ? (rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid")) :0);
	 age30_60+=((rsARInvoices.getInt("aging")>30 && rsARInvoices.getInt("aging")<61) ?  (rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid")) :0);
	 age60_90+=((rsARInvoices.getInt("aging")>60 && rsARInvoices.getInt("aging")<91) ?  (rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid")) :0);
	 age90_120+=((rsARInvoices.getInt("aging")>90 && rsARInvoices.getInt("aging")<121) ? (rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid")) :0);
	 ageOver120+=((rsARInvoices.getInt("aging")>121) ? (rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid")) : 0);
      rTotalPrice += rsARInvoices.getDouble("ar_purchase_amount");
      rTotalShipping += rsARInvoices.getDouble("ar_shipping_amount"); 
      rTotalSalesTax += rsARInvoices.getDouble("ar_sales_tax");
      rTotalDeposit += rsARInvoices.getDouble("deposited");
      rTotalTotal += rsARInvoices.getDouble("ar_invoice_amount");
      rTotalPayments += rsARInvoices.getDouble("paid");
      alt=((alt.equals(""))?"alt":"");
      %><tr><td class="lineitemcenter<%=alt%>" ><%=rsARInvoices.getString("creation_date")%></td><%
      %><td class="lineitemcenter<%=alt%>" ><a href="javascript:pop('/minders/workflowforms/PrintInvoice.jsp?invoiceId=<%=rsARInvoices.getString("id")%>','640','480')"><%=rsARInvoices.getString("id")%></a></td><%
      %><td class="lineitemcenter<%=alt%>" ><%=rsARInvoices.getString("arid.jobid")%></td><%
      %><td class="lineitemcenter<%=alt%>" ><%=rsARInvoices.getString("job_name")%></td><%
      %><td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("ar_purchase_amount"))%></td><%
      %><td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("ar_shipping_amount"))%></td><%
      %><td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("ar_sales_tax"))%></td><%
      %><td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("deposited"))%></td><%
      %><td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount"))%></td><%
      %><td class="lineitemright<%=alt%>">&nbsp;</td><%
      %><td class="lineitemright<%=alt%>" ><a href="javascript:pop('/minders/workflowforms/InvoicePayments.jsp?invoiceId=<%=rsARInvoices.getString("id")%>','640','480')"><%=formatter.getCurrency(rsARInvoices.getDouble("paid"))%></a></td><%
      %><td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid"))%></td><%
      %><td class="lineitemright<%=alt%>">&nbsp;</td><%
	  %><td class="lineitemright<%=alt%>" ><%=((rsARInvoices.getInt("aging")<31) ? formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid")) :"&nbsp;" )%></td><%
      %><td class="lineitemright<%=alt%>" ><%=((rsARInvoices.getInt("aging")>30 && rsARInvoices.getInt("aging")<61) ? formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid")) :"&nbsp;" )%></td><%
      %><td class="lineitemright<%=alt%>" ><%=((rsARInvoices.getInt("aging")>60 && rsARInvoices.getInt("aging")<91) ? formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid")) :"&nbsp;" )%></td><%
      %><td class="lineitemright<%=alt%>" ><%=((rsARInvoices.getInt("aging")>90 && rsARInvoices.getInt("aging")<121) ? formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid")) :"&nbsp;" )%></td><%
      %><td class="lineitemright<%=alt%>" ><%=((rsARInvoices.getInt("aging")>120) ? formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-rsARInvoices.getDouble("paid")) :"&nbsp;" )%></td><%
      %></tr><%
      noinvoice="no";
    }
   		 
  }while(rsARInvoices.next());  //ends invoices loop for the buyer
  }else{							
  noinvoice="yes";
  %><tr><td colspan="12">No Invoices Found for this buyer.</td></tr><%
}%><tr>				
<td class="minderheaderright" colspan=4><span class='subtitle'>Report Totals:</span></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalPrice)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalShipping)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalSalesTax)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalDeposit)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalTotal)%></td>
<td class="lineitemright"></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalPayments)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(rTotalTotal-rTotalPayments)%></td>
<td>&nbsp;</td>
<td class="lineitemsright" ><%=formatter.getCurrency(ageUnder30)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(age30_60)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(age60_90)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(age90_120)%></td>
<td class="lineitemsright" ><%=formatter.getCurrency(ageOver120)%></td>
</tr>
</table>
</body>
</html><%st.close();conn.close();%>