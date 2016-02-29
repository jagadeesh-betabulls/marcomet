<%@ page import="java.text.*, java.sql.*, com.marcomet.jdbc.SimpleConnection" %>
<%@ include file="/includes/SessionChecker.jsp" %>

<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />

<html>
<head>
  <title>Print Invoice <%= request.getParameter("invoiceId")%></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<body >
<table border=0 cellspacing=0 cellpadding=0 width=92% align="center">
  <%
	double basePrice=0;
	double optionsPrice=0;	
	double changesPrice=0;	
	double invoicesPrice=0;
	double shippingPrice=0;
	double salestaxPrice=0;
	String sql1 = "select * from ar_invoices where id = " +request.getParameter("invoiceId");
	String sql2 = "select * from ar_invoice_details where ar_invoiceid = " + request.getParameter("invoiceId");
	SimpleConnection sc = new SimpleConnection();
	Connection conn = sc.getConnection();
	Statement st1 = conn.createStatement();
	Statement st2 = conn.createStatement();
	ResultSet rsInvoice = st1.executeQuery(sql1);
	ResultSet rsInvoiceDetail = st2.executeQuery(sql2);
	rsInvoice.next();
	rsInvoiceDetail.next();
	String invoiceShipping=rsInvoiceDetail.getString("ar_shipping_amount");
	String invoiceSalesTax=rsInvoiceDetail.getString("ar_sales_tax");
	String invoiceAmount=rsInvoiceDetail.getString("ar_invoice_amount");
	String vendorId=rsInvoice.getString("vendor_id");
	String invoicePurchaseAmount=rsInvoiceDetail.getString("ar_purchase_amount");			
	String sql3 = "Select v.id,c.id companyId,c.company_name name,l.address1 address1,l.address2 address2,l.city city,s.value state,l.zip zip from vendors v, companies c,company_locations l,lu_abreviated_states s where l.company_id=c.id and c.id=v.company_id and l.lu_location_type_id=3 and s.id=l.state and v.id="+vendorId;
	Statement st3=conn.createStatement();
	ResultSet rsVendorInfo = st3.executeQuery(sql3);
	rsVendorInfo.next();
	
	String sql4 = "Select concat(ct.firstname,\" \",ct.lastname) fullname, c.company_name companyname,l.address1 billtoaddress1,l.address2 billtoaddress2,l.city billtocity,s.value billtostate,l.zip billtozip ,shp.address1 shiptoaddress1,shp.address2 shiptoaddress2,shp.city shiptocity,sshp.value shiptostate,shp.zip shiptozip ";
	sql4+=" from companies c,locations l,locations shp,lu_abreviated_states s,lu_abreviated_states sshp,contacts ct ";
	sql4+=" where c.id=ct.companyid and ct.id="+rsInvoice.getString("bill_to_contactid")+" and l.contactid=ct.id  and l.locationtypeid=2 and s.id=l.state and shp.contactid=ct.id  and shp.locationtypeid=1 and s.id=shp.state and sshp.id=shp.state";
	Statement st4=conn.createStatement();
	ResultSet rsCustomerInfo = st4.executeQuery(sql4);
	rsCustomerInfo.next();
	
	String sql5 = "Select * from jobs where id="+rsInvoiceDetail.getString("jobid");
	Statement st5=conn.createStatement();
	ResultSet rsJobInfo = st5.executeQuery(sql5);
	rsJobInfo.next();
	shippingPrice=rsJobInfo.getDouble("shipping_price");
	salestaxPrice=rsJobInfo.getDouble("sales_tax");
	
	String sql = "select price from job_specs where (cat_spec_id=88888 or cat_spec_id=99999) and job_id="+rsInvoiceDetail.getString("jobid");
	Statement st=conn.createStatement();
	ResultSet rsBasePrice = st.executeQuery(sql);
	if (rsBasePrice.next()){
		basePrice=rsBasePrice.getDouble("price");
	}
	
	 sql = "select sum(price) price from job_specs where (cat_spec_id<>88888 and cat_spec_id<>99999) and job_id="+rsInvoiceDetail.getString("jobid");
	 st=conn.createStatement();
	ResultSet rsOptionPrice = st.executeQuery(sql);
	if (rsOptionPrice.next()){
		optionsPrice=rsOptionPrice.getDouble("price");
	}	

	 sql = "select sum(d.ar_invoice_amount) price,sum(d.ar_sales_tax) salestaxPrice, sum(d.ar_shipping_amount) shippingPrice from ar_invoice_details d, ar_invoices i where i.id<'"+rsInvoice.getString("id")+"' and i.id=d.ar_invoiceid and d.jobid="+rsInvoiceDetail.getString("jobid");
	 st=conn.createStatement();
	ResultSet rsInvoicePrice = st.executeQuery(sql);
	if (rsInvoicePrice.next()){
		invoicesPrice=rsInvoicePrice.getDouble("price");
	}	
	
	 sql = "select sum(price) price from jobchanges where jobid="+rsInvoiceDetail.getString("jobid");
	 st=conn.createStatement();
	ResultSet rsChangePrice = st.executeQuery(sql);
	if (rsChangePrice.next()){
		changesPrice=rsChangePrice.getDouble("price");
	}	
	
	 sql = "select * from ar_invoices i,ar_invoice_details d where i.id<"+rsInvoice.getString("id")+" and i.id=d.ar_invoiceid and d.jobid="+rsInvoiceDetail.getString("jobid");
	 st=conn.createStatement();
	ResultSet rsInvoices = st.executeQuery(sql);
	rsInvoices.next();
	
	sql = "select st.value AS entity_string, rate from sales_tax, lu_abreviated_states st where st.id = sales_tax.entity and job_id = " + rsInvoiceDetail.getString("jobid");
	st=conn.createStatement();
	ResultSet rsTaxInfo = st.executeQuery(sql);
	rsTaxInfo.next();
	
				
				
%>
  <tr> 
    <td class="Normal"><img src="<%="/vendors/"+rsVendorInfo.getString("companyId")+"/vendorlogo/invoiceheader.gif"%>" ></td>
  </tr>	
</table>
<br>
<br>

<table width="90%" border="0" cellspacing="0" cellpadding="0" align="center">
  <tr> 
    <td> 
      <div align="left"> 
        <table width="50%" cellpadding=0 border=0 cellspacing="0">
          <tr> 
            <td class="billheader" align="left" height="20"> 
              <div align="left"><b>Bill To</b></div>
            </td>
            <td class="billheader" align="left" height="20"> 
              <div align="left"><b>Ship To</b></div>
            </td>
          </tr>
          <tr> 
            <td class="bill"><%=((rsCustomerInfo.getString("fullname")==null)?"":"<b>"+rsCustomerInfo.getString("fullname")+"<br></b>")%> 
              <%=((rsCustomerInfo.getString("companyname")==null)?"":rsCustomerInfo.getString("companyname")+"<br>")%> 
              <%=((rsCustomerInfo.getString("billtoaddress1")==null  || rsCustomerInfo.getString("billtoaddress1").equals(""))?"":rsCustomerInfo.getString("billtoaddress1")+"<br>")%> 
              <%=((rsCustomerInfo.getString("billtoaddress2")==null || rsCustomerInfo.getString("billtoaddress2").equals(""))?"":rsCustomerInfo.getString("billtoaddress2")+"<br>")%> 
              <%=((rsCustomerInfo.getString("billtocity")==null)?"":rsCustomerInfo.getString("billtocity")+",  ")%> 
              <%=((rsCustomerInfo.getString("billtostate")==null)?"":rsCustomerInfo.getString("billtostate")+"  ")%> 
              <%=((rsCustomerInfo.getString("billtozip")==null)?"":rsCustomerInfo.getString("billtozip"))%>	
            </td>
            <td class="bill"><%=((rsCustomerInfo.getString("shiptoaddress1")==null || rsCustomerInfo.getString("shiptoaddress1").equals(""))?"":rsCustomerInfo.getString("shiptoaddress1")+"<br>")%> 
              <%=((rsCustomerInfo.getString("shiptoaddress2")==null || rsCustomerInfo.getString("shiptoaddress2").equals(""))?"":rsCustomerInfo.getString("shiptoaddress2")+"<br>")%> 
              <%=((rsCustomerInfo.getString("shiptocity")==null)?"":rsCustomerInfo.getString("shiptocity")+",  ")%> 
              <%=((rsCustomerInfo.getString("shiptostate")==null)?"":rsCustomerInfo.getString("shiptostate")+"  ")%> 
              <%=((rsCustomerInfo.getString("shiptozip")==null)?"":rsCustomerInfo.getString("shiptozip"))%></td>
          </tr>
        </table>
      </div>
      <p align="left"></p>
      <div align="left"> 
        <table width="72%" cellpadding=0 border=0 cellspacing="0">
          <tr> 
            <td class="billheader" align="left" height="20" width="21%"> 
              <div align="left"><b>Invoice Number</b></div>
            </td>
            <td class="billheader" align="left" height="20" width="22%"> 
              <div align="left"><b>Invoice Date</b></div>
            </td>
            <td class="billheader" align="left" height="20" width="21%"> 
              <div align="left"><b>Job Number</b></div>
            </td>
            <td class="billheader" align="left" height="20" width="36%"> 
              <div align="left"><b>Terms</b></div>
            </td>
          </tr>
          <tr> 
            <td class="bill" height="20" width="21%"><%=rsInvoice.getString("invoice_number")%></td>
            <td class="bill" height="20" width="22%"><%=formater.formatMysqlDate(rsInvoice.getString("creation_date"))%></td>
            <td class="bill" height="20" width="21%"><%=rsInvoiceDetail.getString("jobid")%></td>
            <td class="bill" height="20" width="36%">Upon Receipt</td>
          </tr>
        </table>
      <p></p></div>
    </td>
  </tr>
</table>
<table width="90%" cellpadding="0" cellspacing="0" border="0" align="center" >
  <tr> 
    <td class="billheader" width="46%" height="20" > 
      <div align="left"><b>Job Description</b></div>
    </td>
    <td class="billheader" colspan="2" height="20"> 
      <div align="center"><b>Job Cost Summary</b></div>
    </td>
  </tr>
  <tr> 
    <td class="bill" rowspan="7" align="left" valign="top" width="46%"><%=rsJobInfo.getString("job_name")%><br>
      <%String jobName=rsJobInfo.getString("job_name");%>
      <taglib:JobSpecsTag tableWidth="80%" jobId="<%= jobName%>"/> </td>
    <!--    <td class="bill" width="26%">Base Price</td>
    <td class="bill" width="28%"> 
      <div align="right"><%=formater.getCurrency(basePrice)%></div>
    </td>
  </tr>
  <tr> 
    <td class="bill" width="26%">Price Options</td>
    <td class="bill" width="28%"> 
      <div align="right"><%=formater.getCurrency(optionsPrice)%></div>
    </td>
  </tr>
  <tr> 
    <td class="bill" width="26%">&nbsp;&nbsp;&nbsp;&nbsp;<b>Job Subtotal</b></td>
    <td class="bill" width="28%"> 
      <div align="right"><%=formater.getCurrency(optionsPrice+basePrice)%></div>
    </td>
  </tr>
  <tr> 
    <td class="bill" width="26%">Quotes/Change Orders</td>
    <td class="bill" width="28%"> 
      <div align="right"><%=formater.getCurrency(changesPrice)%></div>
    </td>
  </tr>-->
  <tr> 
    <td class="bill" width="26%" height="20" bgcolor="#F0F0F0"> 
      <div align="right"><b><font color="#000000">Job Amount</font></b></div>
    </td>
    <td class="bill" width="28%" height="20" bgcolor="#F0F0F0"> 
      <div align="right"><b><%=formater.getCurrency(optionsPrice+changesPrice+basePrice)%></b></div>
    </td>
  </tr>
  <tr> 
    <td class="bill" width="26%" height="20" bgcolor="#F0F0F0"> 
      <div align="right">Shipping</div>
    </td>
    <td class="bill" width="28%" height="20" bgcolor="#F0F0F0"> 
      <div align="right"><%=formater.getCurrency(shippingPrice)%></div>
    </td>
  </tr>
  <tr> 
    <td class="bill" width="26%" height="20" bgcolor="#F0F0F0"> 
      <div align="right">Sales Tax</div>
    </td>
    <td class="bill" width="28%" height="20" bgcolor="#F0F0F0"> 
      <div align="right"><%=formater.getCurrency(salestaxPrice)%></div>
    </td>
  </tr>
  <tr> 
    <td class="bill" width="26%" height="20" bgcolor="#F0F0F0"> 
      <div align="right"><b>&nbsp;&nbsp;<font color="#000000">&nbsp;Job Total</font></b></div>
    </td>
    <td class="bill" width="28%" height="20" bgcolor="#F0F0F0"> 
      <div align="right"><b><%=formater.getCurrency(shippingPrice+salestaxPrice+optionsPrice+changesPrice+basePrice)%></b></div>
    </td>
  </tr>
  <tr> 
    <td class="bill" width="26%" height="20" bgcolor="#F0F0F0"> 
      <div align="right">Job Billed To Date</div>
    </td>
    <td class="bill" width="28%" height="20" bgcolor="#F0F0F0"> 
      <div align="right"><%=formater.getCurrency(invoicesPrice)%></div>
    </td>
  </tr>
  <tr> 
    <td class="bill" width="26%" height="20" bgcolor="#F0F0F0"> 
      <div align="right"><b>&nbsp;&nbsp;<font color="#FF0000">&nbsp;<font color="#000000">Job 
        Balance Unbilled</font></font></b></div>
    </td>
    <td class="bill" width="28%" height="20" bgcolor="#F0F0F0"> 
      <div align="right"><b><%=formater.getCurrency(shippingPrice+salestaxPrice+optionsPrice+changesPrice+basePrice-invoicesPrice)%></b></div>
    </td>
  </tr>
  <tr> 
    <td class="billheader" width="46%" height="20"> 
      <!-- Taken out by Lou until Corrected "nullnull" appears when there is no prior invoice (see line 259 for more)...<div align="left"><b>Previous Billings on This Job</b></div>-->
    </td>
    <td class="billheader" colspan="2" height="20"> 
      <div align="center"><b>Current Invoice Summary</b></div>
    </td>
  </tr>
  <tr> 
    <td class="bill" width="46%" align="left" valign="top"> 
      <%
	do {%>
      <!-- Taken out by Lou until Corrected "nullnull" appears when there is no prior invoice...
	  Invoice#<%=rsInvoices.getString("invoice_number")%>&nbsp;&nbsp;&nbsp;<%=rsInvoices.getString("creation_date")%>&nbsp;&nbsp;&nbsp;<%=formater.getCurrency(rsInvoices.getString("ar_invoice_amount"))%><br>
  <%}while (rsInvoices.next());%>-->
&nbsp;
    </td>
    <td colspan="2" align="left" valign="top" bgcolor="#FFFFC1"> 
      <table width="100%" align="left" cellspacing="0" Border="0" cellpadding="0" >
        <tr> 
          <td class="bill" width="48%" height="20"> 
            <div align="right"><b><font color="#000000">Current Due on Job</font></b></div>
          </td>
          <td class="bill" width="52%" height="20"> 
            <div align="right"><b><%=formater.getCurrency(invoicePurchaseAmount)%></b></div>
          </td>
        </tr>
        <tr> 
          <td class="bill" width="48%" height="20"> 
            <div align="right">Shipping</div>
          </td>
          <td class="bill" width="52%" height="20"> 
            <div align="right"><%=formater.getCurrency(invoiceShipping)%></div>
          </td>
        </tr>
        <tr> 
          <td class="bill" width="48%" height="20"> 
            <div align="right">Sales Tax: <%=rsTaxInfo.getString("entity_string")%>&nbsp;<%=str.replaceSubstring(formater.getCurrency(rsTaxInfo.getDouble("rate")),"$","")%>%</div>
          </td>
          <td class="bill" width="52%" height="20"> 
            <div align="right"><%=formater.getCurrency(invoiceSalesTax)%></div>
          </td>
        </tr>
        <tr> 
          <td class="bill" width="48%" height="30"> 
            <div align="right"><font color="#003366"><b>&nbsp;&nbsp;&nbsp;Invoice 
              Amount Due</b></font></div>
          </td>
          <td class="bill" width="52%" height="30"> 
            <div align="right"><font color="#003366"><b><%=formater.getCurrency(invoiceAmount)%></b></font></div>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<table border=0 cellspacing=0 width="90%" align="center">
  <%=((rsInvoice.getString("message")!=null && !rsInvoice.getString("message").equals("") && !rsInvoice.getString("message").equals("&nbsp;"))?"<tr><td class=\"label\" colspan=2>Invoice Message:</td></tr><tr><td width=\"30\">&nbsp;</td><td>"+rsInvoice.getString("message"):"")+"</td></tr><tr><td width=\"60\" class=\"label\">&nbsp;</td><td >&nbsp;</td></tr>"%> 
  <tr> </tr>
  <tr> 
    <td width="80" valign="top" class="bodyBlack" bordercolor="#000000"> 
      <div align="center" class="label">Remit to:</div>
    </td>
    <td width="800" valign="top" class="label" bordercolor="#000000" ><%=rsVendorInfo.getString("name")%><br>
      <%=((rsVendorInfo.getString("address1")==null || rsVendorInfo.getString("address1").equals(""))?"":rsVendorInfo.getString("address1")+"<br>")%>
      <%=((rsVendorInfo.getString("address2")==null || rsVendorInfo.getString("address2").equals(""))?"":rsVendorInfo.getString("address2")+"<br>")%> <%=rsVendorInfo.getString("city")%>, 
      <%=rsVendorInfo.getString("state")%> <%=rsVendorInfo.getString("zip")%> 
    </td>
  </tr>
</table>
  
<hr color="red" size="1" width="92%" align="center">
</body>
</html>
