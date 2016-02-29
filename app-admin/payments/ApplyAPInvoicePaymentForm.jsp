<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.text.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.workflow.*,com.marcomet.users.security.*,com.marcomet.environment.UserProfile" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="taglib" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />

<%	
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
String jobId="";
String x="1";
	String defaultInvoiceNumber="[Enter Unique Invoice Number]";
	String errorMessage="";
	UserProfile up = (UserProfile)session.getAttribute("userProfile");
	String invoiceId=((request.getParameter("invoiceId")==null || request.getParameter("invoiceId").equals(""))?"":request.getParameter("invoiceId"));
	String step=((request.getParameter("step")==null || request.getParameter("step").equals(""))?((invoiceId.equals("") || invoiceId.equals(defaultInvoiceNumber))?"one":"two"):request.getParameter("step"));
	String vendorId=((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":request.getParameter("vendorId"));
	String vendorCompanyId=((request.getParameter("vendorCompanyId")==null || request.getParameter("vendorCompanyId").equals(""))?"":request.getParameter("vendorCompanyId"));
	String invoiceNumber=((request.getParameter("invoiceNumber")==null || request.getParameter("invoiceNumber").equals(""))?defaultInvoiceNumber:request.getParameter("invoiceNumber"));;
	String vendorName="";
	String invoiceDate=((request.getParameter("invoiceDate")==null || request.getParameter("invoiceDate").equals(""))?"":request.getParameter("invoiceDate"));
	String invoiceDateStr="";
	if (!invoiceDate.equals("")){
				SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
			java.util.Date myDate = null;
			try {
				myDate = sdf.parse(invoiceDate);
			} catch (ParseException pe) {
				System.out.println("Error parsing date");
			}
			sdf = new SimpleDateFormat ("yyyy-MM-dd", Locale.US);
     	 	invoiceDateStr = sdf.format(myDate);
	}
	String invoiceAmount=((request.getParameter("invoiceAmount")==null || request.getParameter("invoiceAmount").equals(""))?"":request.getParameter("invoiceAmount"));
	String sqlInsert="";
	String sqlSelect="";
	String poId="";
	String invoiceAmountNum="0";
	ArrayList poList = new ArrayList();
	if (step.equals("two")){
		if (invoiceId.equals("")){
			sqlSelect="Select max(id)+1 'id' from ap_invoices";
			ResultSet invRS = st.executeQuery(sqlSelect);
			if (invRS.next()) { 
				invoiceId=invRS.getString("id");
			}
   			
			sqlInsert="Insert into ap_invoices(id,vendorid,vendor_invoice_no,ap_invoice_date,ap_invoice_amount) values("+invoiceId+","+vendorId+",'"+invoiceNumber+"','"+invoiceDateStr+"',"+invoiceAmount+")";
			ResultSet insRS = st.executeQuery(sqlInsert);
		}
	}
	if(step.equals("two")||step.equals("three")){
			String sqlInvoice=( (!(invoiceId.equals("")))?"Select  vendorid,vendor_invoice_no, c.company_name,ap_invoice_date, ap_invoice_amount from ap_invoices i, vendors v,companies c where i.vendorid=v.id and v.company_id=c.id and i.id="+invoiceId:"Select  vendorid,vendor_invoice_no, c.company_name 'vendorName',ap_invoice_date, ap_invoice_amount from ap_invoices i, vendors v,companies c where i.vendorid=v.id and v.company_id=c.id and i.vendor_invoice_no="+invoiceNumber + " and i.vendorid="+vendorId);
			ResultSet rsInvoices = st.executeQuery(sqlInvoice);		
			if(rsInvoices.next()){
				vendorId=rsInvoices.getString("vendorid");
				invoiceNumber=rsInvoices.getString("vendor_invoice_no");
				vendorName=rsInvoices.getString("c.company_name");
				invoiceDate=formatter.formatMysqlDate(rsInvoices.getString("ap_invoice_date"));
				invoiceAmount=formatter.getCurrency(rsInvoices.getString("ap_invoice_amount"));
				invoiceAmountNum=rsInvoices.getString("ap_invoice_amount");
			}else{
				errorMessage="No Invoices were found for this Invoice Id.";
			}
	}
	if (step.equals("three")){
			sqlSelect="Delete from ap_invoice_details where ap_invoiceid="+invoiceId;
			ResultSet rsPO = st.executeQuery(sqlSelect);
			sqlSelect="Select p.id 'id' from purchase_orders p where p.closed=0 and p.vendor_id="+vendorId;
			rsPO = st.executeQuery(sqlSelect);
			while(rsPO.next()){
				poId=rsPO.getString("id");
				if (!request.getParameter("total_"+poId).equals("") && !request.getParameter("total_"+poId).equals("0")){
					sqlInsert="Insert into ap_invoice_details(purchase_code,lu_ap_recipient_type,ap_invoiceid, po_id,jobid,ap_purchase_amount, ap_shipping_amount, ap_sales_tax_amount,ap_sales_tax_state,amount) values("+request.getParameter("pOPurchaseCode_"+poId)+"','4','"+invoiceId+"','"+poId+"','"+request.getParameter("jobId_"+poId)+"','"+request.getParameter("apply_"+poId)+"','"+request.getParameter("applyship_"+poId)+"','"+request.getParameter("applytax_"+poId)+"','"+request.getParameter("applytaxState_"+poId)+"','"+request.getParameter("total_"+poId)+"')";
					ResultSet insRS = st.executeQuery(sqlInsert);
				}
			}

	}
%><html>
<head>
<title>Apply AP Payments to Purchase Orders</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="/styles/marcomet.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style2 {font-size: 16pt}
.lineitems {
		color:black;
		font-size:10pt;
		font-weight:bold;
		font-family:Arial, Verdana, Geneva;
		border : thin ridge;
		padding : 0px 0px 0px 3px;
}
.style3 {font-size: 10pt}
-->
</style>
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script language="JavaScript">
var invoiceAmountNum="<%=invoiceAmountNum%>";
function submitFirstForm(){
 	var m1=m2=m3=m4=m5='';
	if (document.forms[0].vendorId.value==""){
 		m1="You need to choose a Vendor before continuing; "
	}
 	if(document.forms[0].invoiceNumber.value==""){
 		m2="You need to enter a unique invoice number; "
	}
	if(document.forms[0].invoiceAmount.value=="" || document.forms[0].invoiceAmount.value=="0"){
 		m3="You need to enter a total amount for the invoice; "
	}
	if(document.forms[0].invoiceDate.value==""){
 		m3="You need to enter an invoice date; "
	}
 	m5=m1+m2+m3+m4;
	if (!(m5=="")){
		alert("There were errors submitting this form: " + m5);
 	}else{
		document.forms[0].step.value="two";
		document.forms[0].submit();
	}

}

function submitSecondForm(){
		document.forms[0].step.value="three";
		document.forms[0].submit();
}

function submitForm(){
	var m1=m2=m3=m4=m5='';
	if (document.forms[0].totalapply_total.value>invoiceAmount){
 		m1="The total to be applied is greater than the invoice amount. Please change the amount(s) to be applied before resubmitting; "
	}
 	if(document.forms[0].totalapply_total.value=="" || document.forms[0].totalapply_total.value=="0"){
 		m2="You have not chosen an amount to apply. Please add in the appropriate amount(s) before resubmitting; "
	}
 	m5=m1+m2+m3;
	if (!(m5=="")){
		alert("There were errors submitting this form: " + m5);
 	}else{
		document.forms[0].submit();
	}
}
<%if (step.equals("one") && !(vendorId.equals("")) ){
%>var invNumbers = new Array();
<%String sqlInvoices="Select vendor_invoice_no 'invoices' from ap_invoices where vendorid="+vendorId;
ResultSet rsInvNumbers = st.executeQuery(sqlInvoices);
if(rsInvNumbers.next()){
	%>invNumbers["<%=rsInvNumbers.getString("invoices")%>"]="<%=rsInvNumbers.getString("invoices")%>";<%
}else{%>
	invNumbers[""]="";<%
}
while(rsInvNumbers.next()){
	%>invNumbers["<%=rsInvNumbers.getString("invoices")%>"]="<%=rsInvNumbers.getString("invoices")%>";<%
}

}%>

var overInvoiceMessage="The total amount to be applied is greater than the Invoice total. Please change the amount(s) applied before submitting.";
</script>
<body bgcolor="#FFFFFF" text="#000000">
<p class="pagetitle">Marcomet Invoice Payment Applications<br>Purchase Order/Non-PO</p><%
	errorMessage=(request.getAttribute("errorMessage")==null || request.getAttribute("errorMessage")=="")?errorMessage:"ERROR: "+errorMessage+request.getAttribute("errorMessage") + session.getAttribute("lastErrorMessage");	
	errorMessage=((session.getAttribute("lastErrorMessage")==null)?errorMessage:errorMessage+session.getAttribute("lastErrorMessage"));
	session.setAttribute("lastErrorMessage","");%><%=errorMessage%><%
	if (step.equals("one")){
	%><form method="post" action="/admin/accounting/ApplyAPInvoicePaymentForm.jsp">
	<input type="hidden" name="vendorId" id="vendorId" value="<%=vendorId%>"><input type="hidden" name="vendorCompanyId" id="vendorCompanyId" value="<%=vendorCompanyId%>">
  <table cellspacing="0" cellpadding="4" border="0">
    <tr class="lineitems">
      <td colspan="2">*Vendor</td>
      <td width="623"><%String sqlDD = "SELECT distinct concat(companies.id,'|',vendors.id) 'value', if(vendors.notes is Null or vendors.notes=companies.company_name,companies.company_name,Concat(companies.company_name,': ',vendors.notes)) 'text' FROM vendors, companies, jobs WHERE vendors.id = jobs.vendor_id AND vendors.company_id = companies.id  and vendors.activevendor=1 Order by text";
		String vendStr=vendorCompanyId+"|"+vendorId;
	%><taglib:SQLDropDownTag dropDownName="vendorCompanyIdTemp\" id=\"vendorCompanyIdTemp" sql="<%=sqlDD%>" selected="<%=vendStr%>" extraCode="onChange=\"splitOptionFields(\'vendorCompanyIdTemp\',\'vendorCompanyId\',\'vendorId\',\'refresh\')\"" /></td>
    </tr>
    <tr class="lineitems">
      <td colspan="2">*Invoice Number:</td>
      <td><input name="invoiceNumber" type="text" size=30 value="<%=invoiceNumber%>" onFocus="clearOnEntry(this,'<%=defaultInvoiceNumber%>' )" onBlur="refillOnExit(this,'<%=defaultInvoiceNumber%>' )" onChange="checkNotExists(this,invNumbers,'This invoice has already been entered in the system for this vendor.')"></td>
    </tr>
    <tr class="lineitems">
      <td colspan="2"><p>*Invoice Date</p>
      </td>
      <td><input name="invoiceDate" type="text" size=30 value="<%=invoiceDate%>" >
      (Use format: MM/DD/YYYY, e.g. 01/01/2006) </td>
    </tr>
    <tr class="lineitems">
      <td colspan="2">*Invoice Amount</td>
      <td><input name="invoiceAmount" type="text" size=30 value="<%=invoiceAmount%>" ></td>
    </tr>
  </table>
  <blockquote>
    <blockquote>
      <blockquote><input type="button" value="Next->" onClick="submitFirstForm()"></blockquote>
    </blockquote>
  </blockquote>
<input type="hidden" name="step" value="<%=step%>"></form>	
	<%
}else{
%><form method="post" action="/admin/accounting/ApplyAPInvoicePaymentForm.jsp"><input type="hidden" name="jobId" value="<%=jobId%>"><input type="hidden" name="invoiceId" value="<%=invoiceId%>"><input type="hidden" name="vendorId" value="<%=vendorId%>"><input type="hidden" name="invoiceAmount" value="<%=invoiceAmount%>">
  <table cellspacing="0" cellpadding="5" border="1" >
    <tr>
      <td class="tableheaderright">Vendor&nbsp;ID </td>
      <td  class="tablecellleft"><%=vendorId%></td>
      <td  class="tableheaderright">Vendor&nbsp;Name </td>
      <td colspan="4" class="tablecellleft"><%=vendorName%></td>
    </tr>

    <tr class="lineitem">
      <td  class="tableheaderright">Invoice&nbsp; Number </td>
      <td class="tablecellleft"><%=invoiceNumber%></td>
      <td  class="tableheader">Invoice&nbsp;Date</td>
      <td class="tablecellleft"><%=invoiceDate%></td>
      <td class="tableheaderright">Invoice Amount</td>
      <td class="tablecellleft"><%=invoiceAmount%></td>
    </tr>
 
</table>
  <br>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr class="planheader1">
      <td>PO #</td>
      <td>Job #</td>
      <td>Function</td>
      <td>Job Price</td>
      <td>PO Amount</td>
      <td>PO Balance</td>
      <td>Applied</td>
      <td>Job Shipping</td>
      <td>Applied</td>
      <td>Tax</td>
      <td>Total</td>
    </tr>
    <tr class="lineitems">
      <td colspan="11"><br>Open (unclosed) PO's for this vendor:</td>
    </tr><%
	String sqlPO="Select p.id 'id',p.sales_tax_state taxState, p.po_number,p.job_id,p.purchase_code,p.job_id,j.price,j.shipping_price,p.total_amount,(p.total_amount-( if( (sum(i.ap_purchase_amount) is null),0,sum(i.ap_purchase_amount) ))) as  'balance' from jobs j,purchase_orders p left join ap_invoice_details i on i.po_id=p.id where p.job_id=j.id and p.closed=0 and p.vendor_id="+vendorId+" group by p.id";
	ResultSet rsPO = st.executeQuery(sqlPO);
	boolean foundpo=false;
	while(rsPO.next()){
		foundpo=true;
		%><tr class="lineitems">
      <td><a href='/minders/workflowforms/ProcessPOForm.jsp?id=<%=rsPO.getString("p.id")%>' target='_blank'><%=rsPO.getString("p.po_number")%></a></td>
      <td><%=rsPO.getString("p.job_id")%><input type="hidden" name="jobId_<%=rsPO.getString("id")%>" id="jobId_<%=rsPO.getString("id")%>" value="<%=request.getParameter("p.job_id")%>"><input type="hidden" name="jobId_<%=rsPO.getString("id")%>" id="jobId_<%=rsPO.getString("")%>" value="<%=request.getParameter("p.purchase_code")%>"></td>
      <td><%=rsPO.getString("p.purchase_code")%></td>
      <td><div align="right"><%=formatter.getCurrency(rsPO.getString("j.price"))%></div></td>
      <td><div align="right"><%=formatter.getCurrency(rsPO.getString("p.total_amount"))%></div></td>
      <td><div align="right"><%=formatter.getCurrency(rsPO.getString("balance"))%></div></td>
      <td>
        <div align="right">
          <input type='number' style="text-align:right; " name='apply_<%=rsPO.getString("id")%>' id='apply_<%=rsPO.getString("id")%>' size='10' onBlur='fillAndAddCappedTotal(overInvoiceMessage,invoiceAmountNum,"total_",6,"total_total","apply_total","applytax_total","applyship_total")' onChange="sumFields(this,'total_<%=rsPO.getString("id")%>','apply_<%=rsPO.getString("id")%>','applytax_<%=rsPO.getString("id")%>','applyship_<%=rsPO.getString("id")%>')" value="0">
        </div></td>
      <td><div align="right"><%=rsPO.getString("j.shipping_price")%></div></td>
      <td>
        <div align="right">
          <input type='text' name='applyship_<%=rsPO.getString("id")%>' style="text-align:right; " id='applyship_<%=rsPO.getString("id")%>' size='10' value="0" onBlur='fillAndAddCappedTotal(overInvoiceMessage,invoiceAmountNum,"applyship_",10,"total_total","apply_total","applytax_total","applyship_total")'  onChange="sumFields(this,'total_<%=rsPO.getString("id")%>','apply_<%=rsPO.getString("id")%>','applytax_<%=rsPO.getString("id")%>','applyship_<%=rsPO.getString("id")%>')">
        </div></td>
      <td>
        <div align="right">
          <input type='hidden'  align="right" name='applytaxState_<%=rsPO.getString("id")%>' id='applytaxState_<%=rsPO.getString("id")%>' value='<%=rsPO.getString("taxState")%>'><input type='text' name='applytax_<%=rsPO.getString("id")%>'  style="text-align:right; " id='applytax_<%=rsPO.getString("id")%>' size='10' value="0" onBlur='fillAndAddCappedTotal(overInvoiceMessage,invoiceAmountNum,"applytax_",9,"total_total","apply_total","applytax_total","applyship_total")'  onChange="sumFields(this,'total_<%=rsPO.getString("id")%>','apply_<%=rsPO.getString("id")%>','applytax_<%=rsPO.getString("id")%>','applyship_<%=rsPO.getString("id")%>')">
        </div></td>
      <td><div id="total_<%=rsPO.getString("id")%>Span" align="right">&nbsp;</div><input type="hidden" name="total_<%=rsPO.getString("id")%>" id="total_<%=rsPO.getString("id")%>"></td>
    </tr><%
	}
	if (!foundpo){
		%><tr class="lineitems"><td colspan="11"><br>No open Purchase Orders were found for this vendor.</td></tr><%
	}
    %><tr class="lineitems">
      <td colspan="11"><br>
      Non-PO applications: </td>
    </tr>
    <tr class="lineitems">
      <td height="12"></td>
      <td>disp 2</td>
      <td></td>
      <td><div align="right">disp 3</div></td>
      <td><div align="right"></div></td>
      <td><div align="right"></div></td>
      <td><div align="right"><input type='number' style="text-align:right; " name='apply_npo<=x%>' id='apply_npo<=x%>' size='10' onBlur='fillAndAddCappedTotal(overInvoiceMessage,invoiceAmountNum,"total_",6,"total_total","apply_total","applytax_total","applyship_total")' onChange="sumFields(this,'total_npo<%=x%>','apply_npo<%=x%>','applytax_npo<%=x%>','applyship_npo<%=x%>')" value="0"></div></td>
      <td><div align="right">disp 5</div></td>
      <td><div align="right"><input type='number' style="text-align:right; " name='applyship_npo<=x%>' id='applyship_npo<=x%>' size='10'onBlur='fillAndAddCappedTotal(overInvoiceMessage,invoiceAmountNum,"applyship_",13,"total_total","apply_total","applytax_total","applyship_total")' onChange="sumFields(this,'total_npo<%=x%>','apply_npo<%=x%>','applytax_npo<%=x%>','applyship_npo<%=x%>')" value="0"></div></td>
      <td><div align="right"><input type='hidden'  align="right" name='applytaxState_npo<%=x%>' id='applytaxState_npo<%=x%>' value='<%=rsPO.getString("taxState")%>'><input type='number' style="text-align:right; " name='applytax_npo<%=x%>' id='applytax_npo<%=x%>' size='10' onBlur='fillAndAddCappedTotal(overInvoiceMessage,invoiceAmountNum,"applytax_",12,"total_total","apply_total","applytax_total","applyship_total")' onChange="sumFields(this,'total_npo<%=x%>','apply_npo<%=x%>','applytax_npo<%=x%>','applyship_npo<%=x%>')" value="0"></div></td>
      <td><div id="total_npo<%=x%>Span" align="right">&nbsp;</div><input type="hidden" name="total_npo<%=x%>" id="total_npo<%=x%>"></td>
    </tr>
    <tr class="lineitems">
      <td colspan="6"><div align="right">TOTAL&nbsp;&nbsp;&nbsp;</div></td>
      <td><div id="apply_totalSpan" align="right">0</div><input type="hidden" name="apply_total" id="apply_total"></td>
      <td bgcolor="#CCCCCC"></td>
      <td><div id="applyship_totalSpan" align="right">0</div><input type="hidden" name="applyship_total" id="applyship_total"></td>
      <td><div id="applytax_totalSpan" align="right"0></div><input type="hidden" name="applytax_total" id="applytax_total"></td>
      <td><div id="total_totalSpan" align="right">0</div><input type="hidden" name="total_total" id="total_total"></td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </table>
  <p align=center><input type="button" value="Next->" onClick="submitSecondForm()"></p><input type="hidden" name="step" value="<%=step%>">
</form>
<%}

	st.close();
	conn.close();

%></body>
</html>
