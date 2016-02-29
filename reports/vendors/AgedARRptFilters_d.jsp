<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<%		Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
	String loginId = (session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId"); 
	loginId = ((request.getParameter("userId")==null)?loginId:request.getParameter("userId"));
	cB.setContactId(loginId);
	String vendorCompanyId=Integer.toString(cB.getCompanyId());
	String asOfDate=( (request.getParameter("asOfDate") != null)? request.getParameter("asOfDate"):"");
//aged ar
%><html>
<head>
  <title>Statement of Account</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<style>
	div#filters{
margin: 0px 20px 0px 20px;
display: none;
}</style>
<script>
	function popSiteNumber(){
		var elVal=' AND 1 = 1 ';
		var EntryVal=document.forms[0].sitenumberEntry.value;
		if ( EntryVal != ''){
			elVal=" AND c.default_site_number = '"+EntryVal+"'";
			}
			document.forms[0].siteNumberFilter.value=elVal;
		}
	</script>
	<script language="JavaScript" src="/javascripts/mainlib.js"></script>
	<link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
	<script type="text/javascript" src="/javascripts/jscalendar/calendar.js"></script>
	<script type="text/javascript" src="/javascripts/jscalendar/lang/calendar-en.js"></script>
	<script type="text/javascript" src="/javascripts/jscalendar/calendar-setup.js"></script>
	</head>
	<body>
	<p class="Title">Accounts Receivable Aging Report</p>
	<span id='loading'><div align='center'> L O A D I N G . . . <br><br><img src='/images/loading.gif'><br></div></span><div id='filtertoggle' ></div>
	<div id='filters'>
	<form method="post" action="/reports/vendors/AgedARRptFilters_d.jsp">
	<table border=0 align='center'>
	<td class='lineitems' style="width:450px;"><br />&nbsp;&nbsp;Invoices/Payments As Of:&nbsp;<input type='hidden' name='submitted' value='true'><input type="hidden" name="asOfDate" id="f_asOfDate_d" ><span class="lineitemsselected" id="show_d"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c"
					     style="cursor: pointer; border: 1px solid red;"
					     title="Date selector"
					     onmouseover="this.style.background='red';"
					     onmouseout="this.style.background=''" />
						<script type="text/javascript">
						    Calendar.setup({
						        inputField     :    "f_asOfDate_d",
						        ifFormat       :    "%Y-%m-%d",
						        displayArea    :    "show_d",
						        daFormat       :    "%m-%d-%Y",
						        button         :    "f_trigger_c",
						        align          :    "BR",
						        singleClick    :    true
						    });
							var d=new Date();
							document.forms[0].asOfDate.value=<%=((asOfDate.equals(""))?"d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate()":"'"+asOfDate+"'")%>;
	document.getElementById('show_d').innerHTML=<%=((asOfDate.equals(""))?"(d.getMonth()+1)+'-'+d.getDate()+'-'+d.getFullYear()":"'"+asOfDate+"'")%>;
						</script></td></tr><% 


String siteHostFilter=( (request.getParameter("siteHostFilter") != null)? request.getParameter("siteHostFilter"):" AND 1 = 1 ");
String brandFilter=( (request.getParameter("brandFilter") != null)? request.getParameter("brandFilter"):" AND 1 = 1 ");
//-- Sitenumber Filter --
String noinvoice="yes";
String companyId=session.getAttribute("companyId").toString();
String sitenumberEntry=((request.getParameter("sitenumberEntry") != null)?request.getParameter("sitenumberEntry"):"");
String siteNumberFilter=( (sitenumberEntry.equals("")) ? "":" AND c.default_site_number = '"+sitenumberEntry+"'");

String contactId=((request.getParameter("contactId") != null)?request.getParameter("contactId"):"");
String contactIdFilter=( (!(contactId.equals("")))?" AND ai.bill_to_contactid = '"+contactId+"' ":"");


%><tr><td class='lineitems' >Wyndham Site#:&nbsp;<input type=text name='sitenumberEntry' id='sitenumberEntry' class='otherminder' size=10 onChange='popSiteNumber()' value='<%=sitenumberEntry%>'><input type=hidden name='siteNumberFilter' id='siteNumberFilter' value='<%=siteNumberFilter%>'></td></tr><%/* 
-- end Sitenumber filter --

-- Customer number Filter --

*/%><tr><td class='lineitems' >Buyer Contact #:&nbsp;<input type=text name='contactId' id='contactId' class='otherminder' size=10 value='<%=contactId%>'><input type=hidden name='contactIdFilter' id='contactIdFilter' value='<%=contactIdFilter%>'></td></tr><% 
//-- end Customer number filter --
%><br><%

//-- site host filter --
%><tr><td class='lineitems' >Site&nbsp;Host:&nbsp;<select name="siteHostFilter" class='otherminder'><option selected value=" AND 1 = 1 ">All</option><%
String sql = "SELECT sh.id 'id', sh.site_host_name 'companyname' FROM jobs j, projects p, orders o, site_hosts sh WHERE j.project_id = p.id AND o.id = p.order_id AND o.site_host_id = sh.id  GROUP BY sh.id ORDER BY sh.site_host_name";
ResultSet rs1 = st.executeQuery(sql);

while (rs1.next()) {
	if (siteHostFilter.equals(" AND j.jsite_host_id = "+rs1.getString("id")+" ")) { 
		%><option selected value=" AND j.jsite_host_id = <%=rs1.getString("id")%> "><%=rs1.getString("companyname")%></option><%
	} else { 
		%><option value=" AND j.jsite_host_id = <%=rs1.getString("id")%> "><%=rs1.getString("companyname")%></option><%   
	} 
} %></select>&nbsp;<% 
//-- End Site host filter --

//-- Brand filter --
%>Brand:&nbsp;<select name="brandFilter" class='otherminder'><option selected value=" AND 1 = 1 ">All</option><%
sql = "SELECT brand_code, brand_name FROM brands where active=1 order by brand_name";
rs1 = st.executeQuery(sql);
while (rs1.next()) {
	if (brandFilter.equals(" AND brand_code = " + rs1.getString("brand_code")+ " ")) { 
		%><option selected value=" AND sh.id = <%=rs1.getString("brand_code")%> "><%=rs1.getString("brand_name")%></option><%
	} else {
		%><option value=" AND brand_code = <%=rs1.getString("brand_code")%> "><%=rs1.getString("brand_name")%></option><%   
	}
} %></select><%
// -- End brand filter --
%></td></tr>
<tr><td><div align='center'><a href="#" class='menuLINK' onClick="history.go(-1)">Cancel</a>&nbsp;&nbsp;<a href="#" class='menuLINK' onClick="document.forms[0].submit()">Generate Report</a></div>
</td></tr></table>
</form>
</div><%
if (request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true")){
%><table  border=0 cellpadding=0 cellspacing=0 width=100%>
  <tr>
    <td width="5%" class="label" style="text-align:right">Name:</td>
    <td width="70%" class='bodyBlack'><%= cB.getFirstName() %> <%= cB.getLastName() %></td>
  </tr>
  <tr>
    <td class="label" style="text-align:right">Company:</td>
    <td class="bodyBlack"><%= cB.getCompanyName() %></td>
  </tr>
</table>
<table border="0" cellpadding="1" cellspacing="0" width="100%"><%

String sqlSiteHosts="";
ResultSet rsBuyers;
String alt="alt";
double amountPaid=0;
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

String headerRow="<tr><td colspan=12 class=minderheadercenter>INVOICES</td><td>&nbsp;</td><td class='minderheadercenter' colspan=5>AGING</td></tr><tr><td class='minderheadercenter'>Invoice&nbsp;Date</td><td class='minderheadercenter' >Invoice&nbsp;#</td><td class='minderheadercenter' >Job #</td><td class='minderheadercenter' >Job Name</td><td class='minderheadercenter' >Amount</td><td class='minderheadercenter' >Shipping</td><td class='minderheadercenter' >Sales Tax</td><td class='minderheadercenter' >Deposit</td><td class='minderheadercenter' >Total</td><td class='minderheadercenter' width='10px' >&nbsp;</td><td class='minderheadercenter' >Payments</td><td class='minderheadercenter' >Balance</td><td>&nbsp;</td><td class='minderheadercenter' >&nbsp;0&nbsp;&minus;&nbsp;30&nbsp;</td><td class='minderheadercenter' >&nbsp;31&nbsp;&minus;&nbsp;60&nbsp;</td><td class='minderheadercenter' >&nbsp;61&nbsp;&minus;&nbsp;90&nbsp;</td><td class='minderheadercenter' >&nbsp;91&nbsp;&minus;&nbsp;120&nbsp;</td><td class='minderheadercenter' >&nbsp;&gt; 120&nbsp;</td></tr>";

String sqlARInvoices;						

sqlARInvoices = "SELECT (to_days(now())-to_days(ai.creation_date)) as aging,ai.ar_invoice_amount,st.buyer_exempt,ai.*,arid.*,luas.value, j.job_name FROM vendors v, contacts c,companies c3, ar_invoices ai, ar_invoice_details arid, jobs j, sales_tax st, lu_abreviated_states luas WHERE v.company_id= '" + vendorCompanyId + "' AND ai.bill_to_contactid=c.id AND c3.id=c.companyid AND to_days(ai.creation_date) <= to_days('" + asOfDate + "') AND ai.id = arid.ar_invoiceid AND ai.vendor_id=v.id AND arid.jobid = j.id AND st.entity = luas.id  " + contactIdFilter + siteHostFilter + siteNumberFilter + "  AND st.job_id=j.id GROUP BY ai.id ORDER BY ai.creation_date";

//"SELECT (to_days(now())-to_days(ai.creation_date)) as aging,sum(acd.payment_amount) as paid, ai.ar_invoice_amount-sum(acd.payment_amount) as balance,st.buyer_exempt,ai.*,arid.*,luas.value, j.job_name FROM vendors v, contacts c,companies c3, ar_invoices ai, ar_invoice_details arid, jobs j, sales_tax st, lu_abreviated_states luas LEFT JOIN ar_collection_details acd on ai.id = acd.ar_invoiceid LEFT JOIN ar_collections ac on ac.id=acd.ar_collectionid and to_days(ac.deposit_date) <= to_days('"+asOfDate+"') WHERE  v.company_id= '"+vendorCompanyId+"' AND ai.bill_to_contactid=c.id AND c3.id=c.companyid AND to_days(ai.creation_date) <= to_days('"+asOfDate+"') AND ai.id = arid.ar_invoiceid AND ai.vendor_id=v.id AND arid.jobid = j.id AND st.entity = luas.id  " + contactIdFilter+siteHostFilter + siteNumberFilter + "  AND st.job_id=j.id GROUP BY ai.id ORDER BY ai.creation_date";
	%><!-- <%=sqlARInvoices%> --><%
ResultSet rsARInvoices = st.executeQuery(sqlARInvoices);
if(rsARInvoices.next()){
	noinvoice="no";
  %><%=headerRow%><%
  do{
	String sqlSum="Select sum(acd.payment_amount) as paid from ar_collections ac, ar_collection_details acd, ar_invoices ai WHERE ai.id = acd.ar_invoiceid AND ac.id=acd.ar_collectionid AND to_days(ac.deposit_date) <= to_days('"+asOfDate+"') AND ai.id='"+rsARInvoices.getString("id")+"'";
	ResultSet rsSum = st2.executeQuery(sqlSum);
	if (rsSum.next()){
		amountPaid=rsSum.getDouble("paid");
	}else{
		amountPaid=0;
	}
    if(rsARInvoices.getDouble("ar_invoice_amount")-amountPaid != 0){
	 ageUnder30+=((rsARInvoices.getInt("aging")<31) ? (rsARInvoices.getDouble("ar_invoice_amount")-amountPaid) :0);
	 age30_60+=((rsARInvoices.getInt("aging")>30 && rsARInvoices.getInt("aging")<61) ?  (rsARInvoices.getDouble("ar_invoice_amount")-amountPaid) :0);
	 age60_90+=((rsARInvoices.getInt("aging")>60 && rsARInvoices.getInt("aging")<91) ?  (rsARInvoices.getDouble("ar_invoice_amount")-amountPaid) :0);
	 age90_120+=((rsARInvoices.getInt("aging")>90 && rsARInvoices.getInt("aging")<121) ? (rsARInvoices.getDouble("ar_invoice_amount")-amountPaid) :0);
	 ageOver120+=((rsARInvoices.getInt("aging")>121) ? (rsARInvoices.getDouble("ar_invoice_amount")-amountPaid) : 0);
      rTotalPrice += rsARInvoices.getDouble("ar_purchase_amount");
      rTotalShipping += rsARInvoices.getDouble("ar_shipping_amount"); 
      rTotalSalesTax += rsARInvoices.getDouble("ar_sales_tax");
      rTotalDeposit += rsARInvoices.getDouble("deposited");
      rTotalTotal += rsARInvoices.getDouble("ar_invoice_amount");
      rTotalPayments += amountPaid;
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
      %><td class="lineitemright<%=alt%>" ><a href="javascript:pop('/minders/workflowforms/InvoicePayments.jsp?invoiceId=<%=rsARInvoices.getString("id")%>','640','480')"><%=formatter.getCurrency(amountPaid)%></a></td><%
      %><td class="lineitemright<%=alt%>" ><%=formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-amountPaid)%></td><%
      %><td class="lineitemright<%=alt%>">&nbsp;</td><%
	  %><td class="lineitemright<%=alt%>" ><%=((rsARInvoices.getInt("aging")<31) ? formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-amountPaid) :"&nbsp;" )%></td><%
      %><td class="lineitemright<%=alt%>" ><%=((rsARInvoices.getInt("aging")>30 && rsARInvoices.getInt("aging")<61) ? formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-amountPaid) :"&nbsp;" )%></td><%
      %><td class="lineitemright<%=alt%>" ><%=((rsARInvoices.getInt("aging")>60 && rsARInvoices.getInt("aging")<91) ? formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-amountPaid) :"&nbsp;" )%></td><%
      %><td class="lineitemright<%=alt%>" ><%=((rsARInvoices.getInt("aging")>90 && rsARInvoices.getInt("aging")<121) ? formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-amountPaid) :"&nbsp;" )%></td><%
      %><td class="lineitemright<%=alt%>" ><%=((rsARInvoices.getInt("aging")>120) ? formatter.getCurrency(rsARInvoices.getDouble("ar_invoice_amount")-amountPaid) :"&nbsp;" )%></td><%
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
</table><%
}
%>
<script>
	document.getElementById('loading').innerHTML='';
	function toggleLayer(whichLayer){
		var style2 = document.getElementById(whichLayer).style;
		style2.display = style2.display=="block"? "none":"block";
	}
	function togglefilters(){
		var style2 = document.getElementById('filters').style;
		if (style2.display=="block"){
			document.getElementById('filtertoggle').innerHTML='<div class=menuLink><a href="javascript:togglefilters()">+ Show Filters</a></div>';
		}else{
			document.getElementById('filtertoggle').innerHTML=<%=((noinvoice.equals("yes"))?"''":"'<div class=menuLink><a href=\"javascript:togglefilters()\">&raquo; Hide Filters</a></div>'")%>;
		}
		toggleLayer('filters');
	}
	<%=((noinvoice.equals("yes"))?"togglefilters();":"document.getElementById('filtertoggle').innerHTML='<div class=menuLink><a href=\"javascript:togglefilters()\">+ Show Filters</a></div>'")%>
	</script>

</body>
</html><%st2.close();st.close();conn.close();%>