<%@ page import="java.text.*,java.sql.*,java.util.*,org.apache.commons.beanutils.*,com.marcomet.environment.*,com.marcomet.jdbc.*,com.marcomet.tools.*" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %><%
StringTool str=new StringTool();
DecimalFormat nf = new DecimalFormat("#,###.00");
String keyStr="";
String act = request.getParameter("act");
String siteHostId=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId();
int x=0;
int y=0;
double detailLines=0;
if(act.equals("exit") || siteHostId==null) {
	response.sendRedirect("/app-admin/index.jsp");
	return;
}

//If the search pulls up one PO use it as the AP header, id it pulls up multiple PO's present the list and have user select one to use.

String vendorId=((request.getParameter("cId")==null) || request.getParameter("cId").equals("")?"0":request.getParameter("cId"));
String apID=((request.getParameter("apId")==null) || request.getParameter("apId").equals("")?"0":request.getParameter("apId"));

String vendorContactId=((request.getParameter("contactId")==null) || request.getParameter("contactId").equals("")?vendorId:request.getParameter("contactId"));
String vendorCompanyId=((request.getParameter("companyId")==null) || request.getParameter("companyId").equals("")?vendorId:request.getParameter("companyId"));
String jobDate=((request.getParameter("txtJobDate")==null)?"":request.getParameter("txtJobDate"));

boolean apiNotComplete=true;

String compName = ((request.getParameter("cName")==null) || request.getParameter("cName").equals("")?"":request.getParameter("cName"));
String poNo = ((request.getParameter("poNo")==null) || request.getParameter("poNo").equals("")?"0":request.getParameter("poNo"));
String jobId = ((request.getParameter("jobId")==null) || request.getParameter("jobId").equals("")?"0":request.getParameter("jobId"));
String invDate=((request.getParameter("txtInvDate")==null )?"":request.getParameter("txtInvDate"));
String invAmount=((request.getParameter("poAmt")==null) || request.getParameter("poAmt").equals("")?"0":request.getParameter("poAmt"));

if(vendorId.equals("0") && poNo.equals("0") && jobId.equals("0")){
  response.sendRedirect("APEntryForm.jsp?mode=repeat&message=No parameters entered.");
  return;
}
%><html> 
<head>
<meta http-equiv="Content-Language" content="en-us">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>ADD AP ENTRY</title>
<link rel="stylesheet" type="text/css" href="css/master.css" title="Style" >
<link rel="stylesheet" type="text/css" href="/sitehosts/lms/styles/vendor_styles.css" title="Style" >
<link rel="stylesheet" type="text/css" href="css/rfnet.css">
<script type="text/javascript" src="javascripts/dataentry.js"></script>
<script type="text/javascript" src="javascripts/sorttable.js"></script>
<link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
<script type="text/javascript" src="/javascripts/jscalendar/calendar.js"></script>
<script type="text/javascript" src="/javascripts/mainlib.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/calendar-setup.js"></script>
<script>
var applied=0;
	function closePO(el,jobno){
		if (el.checked){
			document.forms[0].elements['ap_shipping_amount'+jobno].value=document.forms[0].elements['H:Accrued^Shipping'+jobno].value;
			applied=Number(applied)+Number(document.forms[0].elements['H:Accrued^Shipping'+jobno].value.replace(/,/g,""));
			document.forms[0].elements['ap_purchase_amount'+jobno].value=document.forms[0].elements['H:F:Accrued^PO^Cost'+jobno].value;	
			applied=Number(applied)+Number(document.forms[0].elements['H:F:Accrued^PO^Cost'+jobno].value.replace(/,/g,""));
			document.getElementById('applied').innerHTML=applied.toFixed(2);
			document.getElementById('appliedTotal').innerHTML=applied.toFixed(2);
	<%//		pop('/popups/QuickChangeForm.jsp?refreshOpener=false&columnName=po_closed&newValue=1&valueType=string&primaryKeyValue='+jobno+'&tableName=jobs&cols=1&rows=1&autosubmit=true',1,1);%>
		}else{
			document.forms[0].elements['ap_shipping_amount'+jobno].value='';
			applied=Number(applied)-Number(document.forms[0].elements['H:Accrued^Shipping'+jobno].value.replace(/,/g,""));
			document.forms[0].elements['ap_purchase_amount'+jobno].value='';
			applied=Number(applied)-Number(document.forms[0].elements['H:F:Accrued^PO^Cost'+jobno].value.replace(/,/g,""));
			if (Number(applied)<0){applied=0}
			document.getElementById('applied').innerHTML=applied.toFixed(2);
			document.getElementById('appliedTotal').innerHTML=applied.toFixed(2);<%
			//		pop('/popups/QuickChangeForm.jsp?refreshOpener=false&columnName=po_closed&newValue=0&valueType=string&primaryKeyValue='+jobno+'&tableName=jobs&cols=1&rows=1&autosubmit=true',1,1);
		%>}
	}	
	function addTot(){
	
	}

	function deleteAPLine(id){
		var ans=confirm('Are you sure you want to delete the AP Invoice Line #'+id+'?');
		if (ans){
<%//			pop('/popups/APLineDelete.jsp?apidId='+id,'1','1'); %>
		}
	}
	function applyAPLine(id,vid,vcid,vcmpid){
		var ans=confirm('Are you sure you want to change the AP Invoice to #'+id+'?');
		if (ans){
			document.forms[0].apId.value=id;	
			document.forms[0].submit();	
		}
	}
</script>
</head><body >
<a href='APEntryForm.jsp' class=greybutton>&raquo;Filters</a>
<form method="POST" action="APAddEntry.jsp">
<input type="hidden" name="act" value=""><input type="hidden" name="apId" value="<%=apID%>"><input type="hidden" name="cId" value="<%=vendorId%>"><input type="hidden" name="poNo" value="<%=poNo%>"><input type="hidden" name="jobId" value="<%=jobId%>"><input type="hidden" name="cName" value="<%=compName%>"><input type="hidden" name="txtJobDate" value="<%=jobDate%>">
  <table width="100%" border="0" cellspacing="1" cellpadding="0" bgcolor="#333333">
    <tr><td><table  border="0" cellpadding="0" cellspacing="0" bgcolor="#F3F1F1">
    			<tr><td  valign="top" > 
    			<table cellpadding="6" cellspacing="1">
                <tr> 
                  <td  colspan="4" class="table-heading">ADD VENDOR PAYMENT / ADJUST PO</td>
                </tr>
                <tr> 
                  <td  class="text-row1"> Vendor Company</td>
                  <td  colspan="3" class="text-row2" ><%=compName%></td>
                </tr>
                <tr> 
                  <td  class="table-heading">Invoice Total</td>
                  <td  class="lineitemsright" >$<span id='invoiceTotal'></span></td>
                  <td  class="table-heading">Total Applied</td>
                  <td  class="lineitemsright" >$<span id='appliedTotal'></span></td>
                </tr>
    </table><%
//Check for open API's

//apID="";
//Does a PO with this number exist? If not, add one
SimpleConnection sc = new SimpleConnection();
Connection conn = sc.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();

String apVendorIdFilter=((vendorId.equals("0"))?"":" and vendorid ='"+vendorId+"' ");
String apPONumberFilter=((poNo.equals("0"))?"":" and vendor_invoice_no='"+poNo+"'");
String apIdFilter=((apID.equals("0"))?"":" and id='"+apID+"'");
String apAmountFilter=((invAmount.equals("0"))?"":" and ap_invoice_amount='"+invAmount+"'");
//String apInvDateFilter=( (invDate.equals("")) ? "":" and ap_invoice_date='"+invDate+"' ":"");

ResultSet rsAPFirstID = st.executeQuery("Select * from ap_invoices_copy where 1=1  "+apVendorIdFilter+apPONumberFilter+apAmountFilter+apIdFilter);

//Select c.company_name,ap.*,if(api.id is null,0,sum(api.amount)) 'applied' from ap_invoices_copy ap left join ap_invoice_details_copy api on api.ap_invoiceid=ap.id left join companies c on c.id=ap.pay_to_company_id where ap.vendor_invoice_no='"+poNo+"'"+apVendorIdFilter+" group by ap.id");
int c=0;
while (rsAPFirstID.next()){
	apID=rsAPFirstID.getString("id");	
	vendorId=rsAPFirstID.getString("vendorid");
//	jobDate=rsAPFirstID.getString("ap_invoice_date");
//	apiNotComplete=!(rsAPFirstID.getString("ap_invoice_amount").equals(rsAPFirstID.getString("applied")));
	c++;
}
	if (c>1){
		apID="";
	}
apVendorIdFilter=((vendorId.equals("0"))?"":" and ap.vendorid="+vendorId+" ");
String poNoFilter=((poNo.equals("0"))?"":" and ap.vendor_invoice_no='"+poNo+"' ");
String jobIdFilter=((jobId.equals("0"))?"":" and jobs.id="+jobId+" ");
if (c==0){
	st.executeUpdate("insert into ap_invoices_copy ( rec_no, vendorid, vendor_invoice_no, ap_invoice_date, ap_invoice_amount, pay_to_contact_id, pay_to_company_id) values ('0', '"+vendorId+"', '"+poNo+"', '"+invDate+"', '"+invAmount+"', '"+vendorContactId+"', '"+vendorCompanyId+"')");
	ResultSet rsId=st.executeQuery("select max(id) 'maxid' from ap_invoices_copy");
	if(rsId.next()){
		apID=rsId.getString("maxid");	
	}
}

if (!(apID.equals(""))){
	String apSQLId="Select ap.id 'K:AP<br>Invoice Id',ap.vendorid 'Vendor ID',ap.vendor_invoice_no 'E1:Vendor Invoice Number',concat('<input type=hidden name=\"txtInvDate\" value=\"',ap.ap_invoice_date,'\">',DATE_FORMAT(ap.ap_invoice_date,'%c/%e/%Y')) 'E2:Invoice Date', concat('<input type=hidden name=\"txtInvAmt\" value=\"',format(ap.ap_invoice_amount,2),'\">',format(ap.ap_invoice_amount,2)) 'E3:Invoice Amount',ap.pay_to_contact_id 'Pay to Contact Id',ap.pay_to_company_id 'Pay to Company Id',if(apid.id is null,0,format(sum(apid.ap_purchase_amount),2)) 'Purchase Amount Total', if(apid.id is null,0,format(sum(apid.ap_shipping_amount),2)) 'Shipping Amount Total', if(apid.id is null,0,format(sum(apid.ap_sales_tax_amount),2)) 'Sales Tax Amount',concat('<span class=lineitemsright id=\"applied\">',if(apid.id is null,0,format(sum(apid.amount),2)),'</span>') 'Total Applied',count(apid.id) 'Detail Lines' from ap_invoices_copy ap left join ap_invoice_details_copy apid on ap.id=apid.ap_invoiceid where  ap.id='"+apID+"' group by ap.id ";

ResultSet rsAPFirst = st.executeQuery(apSQLId);
ResultSetMetaData rsmdAPFirst = rsAPFirst.getMetaData();
int numberOfColumnsAPFirst = rsmdAPFirst.getColumnCount();
String tempStringAPFirst = null;
Vector headersAPFirst  = new Vector(15) ;
	%>
<div class=subtitle>Apply Lines to this AP Invoice:</div>
<table id='invoice' cellpadding=2><tr><td class="table-heading">&nbsp;</td><%
	for (int k=1 ;k <= numberOfColumnsAPFirst; k++){
		tempStringAPFirst = new String ((String) rsmdAPFirst.getColumnLabel(k));
		headersAPFirst.add(tempStringAPFirst);
		tempStringAPFirst=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempStringAPFirst,"E1:", ""),"E2:", ""),"E3:", ""),"K:", ""),"C:", ""),"L:", ""),"^","<br>"),"-", "&nbsp;");
		x++;
		%><td  class="table-heading"><%=tempStringAPFirst%></td><%
	}%></tr><%
	x=0;
detailLines=0;
while (rsAPFirst.next()){
detailLines=rsAPFirst.getDouble("Detail Lines");
	%><tr><%
	for (int i=0;i < numberOfColumnsAPFirst; i++){
		String columnName = (String) headersAPFirst.get(i);
		String columnValue=((columnName.indexOf("F:")>-1)?nf.format(rsAPFirst.getDouble(columnName)):((rsAPFirst.getString(columnName)==null)?"":rsAPFirst.getString(columnName) ));
		if(columnName.indexOf("K:")>-1){
			keyStr=columnValue;
		%><td><a href="javascript:deleteAPLine('<%=columnValue%>')" class='greyButton' alt='DELETE AP LINE'>-</a>&nbsp;&nbsp;<input type='hidden' id=key<%=x%> value='<%=columnValue%>'></td><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%><%
		}else if(columnName.indexOf("E1:")>-1){
			%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=30&rows=1&question=Change%20AP%20Vendor%20Invoice%20Number&primaryKeyValue=<%=keyStr%>&columnName=vendor_invoice_no&tableName=ap_invoices_copy&valueType=string",300,200)'>&raquo;</a>&nbsp;<%=columnValue%><%
		}else if(columnName.indexOf("E2:")>-1){
			%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><a href='javascript:pop("/popups/QuickChangeDateForm.jsp?refreshOpener=false&cols=30&rows=1&question=Change%20AP%20Vendor%20Invoice%20Date&primaryKeyValue=<%=keyStr%>&columnName=ap_invoice_date&tableName=ap_invoices_copy&valueType=string",300,200)'>&raquo;</a>&nbsp;<%=columnValue%><%		
		}else if(columnName.indexOf("E3:")>-1){
			%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=30&rows=1&question=Change%20AP%20Vendor%20Invoice%20Amount&primaryKeyValue=<%=keyStr%>&columnName=ap_invoice_amount&tableName=ap_invoices_copy&valueType=string",300,200)'>&raquo;</a>&nbsp;<%=columnValue%><%	
		}else{%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%><%
		}%><%=(((columnName.indexOf("H:")>-1))?"<input type=hidden name='"+columnName+keyStr+"' value='"+columnValue+"'>":"")%></td><%
	}
x++;
	%></tr><%
}
%></table><%


}

//OTHER OPEN AP INVOICES

String vendorIdFilter=((vendorId.equals("0"))?"":" and dropship_vendor="+vendorId+" ");
String jobDateFilter=( (jobId.equals("0")) ? "jobs.order_date<'"+jobDate+"' AND ":"");
String apiSQL="Select ap.id 'K:AP<br>Invoice Id',ap.vendorid 'Vendor ID',ap.vendor_invoice_no 'E1:Vendor Invoice Number',concat('<input type=hidden name=\"txtInvDate\" value=\"',ap.ap_invoice_date,'\">',DATE_FORMAT(ap.ap_invoice_date,'%c/%e/%Y')) 'E2:Invoice Date', concat('<input type=hidden name=\"txtInvAmt\" value=\"',format(ap.ap_invoice_amount,2),'\">',format(ap.ap_invoice_amount,2)) 'E3:Invoice Amount',ap.pay_to_contact_id 'Pay to Contact Id',ap.pay_to_company_id 'Pay to Company Id',if(apid.id is null,0,format(sum(apid.ap_purchase_amount),2)) 'Purchase Amount Total', if(apid.id is null,0,format(sum(apid.ap_shipping_amount),2)) 'Shipping Amount Total', if(apid.id is null,0,format(sum(apid.ap_sales_tax_amount),2)) 'Sales Tax Amount',concat('<span class=lineitemsright id=\"applied\">',if(apid.id is null,0,format(sum(apid.amount),2)),'</span>') 'Total Applied',count(apid.id) 'Detail Lines' from ap_invoices_copy ap left join ap_invoice_details_copy apid on ap.id=apid.ap_invoiceid where 1=1 "+poNoFilter+jobIdFilter+apVendorIdFilter+" group by ap.id";
%><!--<%=apiSQL%>--><%
ResultSet rsAP = st.executeQuery(apiSQL);
ResultSetMetaData rsmdAP = rsAP.getMetaData();
int numberOfColumnsAP = rsmdAP.getColumnCount();
String tempStringAP = null;
Vector headersAP  = new Vector(15) ;
%>
<div class=subtitle>Other Open AP Invoices</div>
<table id='invoice' cellpadding=2><tr><td class="table-heading">&nbsp;</td><%
for (int k=1 ;k <= numberOfColumnsAP; k++){
	tempStringAP = new String ((String) rsmdAP.getColumnLabel(k));
	headersAP.add(tempStringAP);
	tempStringAP=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempStringAP,"E1:", ""),"E2:", ""),"E3:", ""),"K:", ""),"C:", ""),"L:", ""),"^","<br>"),"-", "&nbsp;");
	x++;
	%><td  class="table-heading"><%=tempStringAP%></td><%
}%></tr><%

x=0;
//detailLines=0;
while (rsAP.next()){
//detailLines=rsAP.getDouble("Detail Lines");
	%><tr><%
	for (int i=0;i < numberOfColumnsAP; i++){
		String columnName = (String) headersAP.get(i);
		String columnValue=((columnName.indexOf("F:")>-1)?nf.format(rsAP.getDouble(columnName)):((rsAP.getString(columnName)==null)?"":rsAP.getString(columnName) ));
		if(columnName.indexOf("K:")>-1){
			keyStr=columnValue;
	%><td><a href="javascript:applyAPLine('<%=columnValue%>','<%=vendorId%>','<%=vendorContactId%>','<%=vendorCompanyId%>')" class='greyButton' alt='USE THIS'>USE THIS--></a>&nbsp;&nbsp;</td><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%><%
		}else if(columnName.indexOf("E1:")>-1){
			%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%><%
		}else if(columnName.indexOf("E2:")>-1){
			%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%><%		
		}else if(columnName.indexOf("E3:")>-1){
			%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%><%	
		}else{%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%><%
		}%></td><%
	}
x++;
	%></tr><%
}
%></table>
<script>document.getElementById('invoiceTotal').innerHTML=document.forms[0].txtInvAmt.value;document.getElementById('appliedTotal').innerHTML=document.getElementById('applied').innerHTML</script>
<%

//JOBS FOR THIS VENDOR

%><br><br>
<div class='subtitle'>Jobs for this vendor not yet associated with AP Invoices: (Where order date < '<%=jobDate%>')</div>
<table id='invoice' class='sortable' width='100%' cellpadding=2><tr><%
//poNoFilter=((detailLines==0 || apiNotComplete )?"":poNoFilter);

String POSQL="SELECT jobs.id 'K:Job^Number',jobs.PO_closed 'B:C:Apply^All', jobs.offline_po_number 'Offline^PO^Number', if(apid.ap_purchase_amount is null,concat('<input type=text name=\"ap_purchase_amount',jobs.id,'\" size=10 class=lineitemsright>'),apid.ap_purchase_amount) 'AP-Purchase^Applied',  jobs.accrued_po_cost 'H:F:Accrued^PO^Cost', format(jobs.accrued_shipping,2) 'H:Accrued^Shipping', if(apid.ap_shipping_amount is null,concat('<input type=text name=\"ap_shipping_amount',jobs.id,'\" size=10 class=lineitemsright>'),format(apid.ap_shipping_amount,2)) 'AP^Shipping^Applied', if(apid.ap_purchase_amount is null,concat('<input type=text name=\"apid.purchase_description',jobs.id,'\" size=30 class=lineitems>'),apid.purchase_description) 'AP-Validation^Notes', if(jobs.quantity is null,'N/A',format(jobs.quantity,0)) 'Quantity', DATE_FORMAT(jobs.order_date, '%m/%d/%Y') 'Order^Date', DATE_FORMAT(jobs.post_date, '%m/%d/%Y')  'Post^Date', jobs.product_code 'Product^Code', jobs.status_id 'Status^ID', format(jobs.price,2) 'Price', format(jobs.shipping_price,2) 'Shipping^Price', jobs.dropship_vendor 'Dropship^Vendor',if(ap.id is null,'NA',ap.id) 'API-ID' from jobs left join ap_invoice_details_copy apid on apid.jobid=jobs.id left join ap_invoices_copy ap on apid.ap_invoiceid=ap.id where "+jobDateFilter+" jobs.PO_closed=jobs.PO_closed "+vendorIdFilter+poNoFilter+jobIdFilter+" order by 'API-ID',jobs.id";

ResultSet rs = st.executeQuery(POSQL);
ResultSetMetaData rsmd = rs.getMetaData();
int numberOfColumns = rsmd.getColumnCount();
String tempString = null;
Vector headers  = new Vector(15) ;
%><td>&nbsp;</td><%
for (int i=1 ;i <= numberOfColumns; i++){
	tempString = new String ((String) rsmd.getColumnLabel(i));
	headers.add(tempString);
	tempString=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempString,"H:", ""),"F:", ""),"B:", ""),"K:", ""),"C:", ""),"L:", ""),"^","<br>"),"-", "&nbsp;");
	x++;
	%><td  class="text-row1" ><%=tempString%></td><%
}%></tr><%
x=0;
while (rs.next()){
	%><tr><%
	for (int i=0;i < numberOfColumns; i++){
		String columnName = (String) headers.get(i);
		String columnValue=((columnName.indexOf("F:")>-1)?nf.format(rs.getDouble(columnName)):((rs.getString(columnName)==null)?"":rs.getString(columnName) ));
		%><td class='text-row<%=(((x % 2) == 0)?1:2)%>' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%
		
		if(columnName.indexOf("K:")>-1){
			keyStr=columnValue;
	  %><a href="javascript:pop('/minders/workflowforms/InterimShipment2.jsp?jobId=<%=keyStr%>&actionId=80&closeOnExit=true',600,400)" class=greybutton> +&nbsp;Ship </a><br>
		<a href="javascript:pop('/popups/POAdjustment.jsp?jobId=<%=keyStr%>',450,300)" class=greybutton> +&nbsp;PO Adj </a><input type='hidden' id=key<%=x%> value='<%=columnValue%>'></td><td class=lineitems><a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%=keyStr%>','800','600')"><%=columnValue%></a></td><%
		}else{%><%=((columnName.indexOf("B:")>-1)?"<input type='checkbox' id='"+keyStr+"' value='1' onClick=\"javascript:closePO(this,'"+keyStr+"')\" >":columnValue)%>
<%}%><%=(((columnName.indexOf("H:")>-1))?"<input type=hidden name='"+columnName+keyStr+"' value='"+columnValue+"'>":"")%></td><%
	}
x++;
	%></tr><%
	int a=0;
	double totCost=rs.getDouble("H:F:Accrued^PO^Cost");
String adjSQL="SELECT id,DATE_FORMAT(adjustment_date, '%M-%d-%Y') 'Adjustment date',format(purchase_cost_adj_amt,2) 'Cost Adjustment',adjustment_notes 'Adjustment Notes' from po_adjustments where job_id='"+rs.getString("K:Job^Number")+"' order by id";

ResultSet rsAdj = st2.executeQuery(adjSQL);
while (rsAdj.next()){
	%><tr>
		<td class='tableheader' colspan=5><div align='right'>Cost Adjustment: <%=rsAdj.getString("Adjustment Date")%></div></td>
		<td class='text-row<%=(((x % 2) == 0)?1:2)%>' align='right'><%=rsAdj.getString("Cost Adjustment")%></td>
		<td class='text-row<%=(((x % 2) == 0)?1:2)%>' style="text-align: right;">&nbsp;</td>
		<td class='text-row<%=(((x % 2) == 0)?1:2)%>' colspan=11><%=rsAdj.getString("Adjustment Notes")%></td>
	</tr><%
	a++;
	totCost+=rsAdj.getDouble("Cost Adjustment");
}
//a=0;

double totShip=rs.getDouble("H:Accrued^Shipping");

adjSQL="SELECT id,DATE_FORMAT(date, '%M-%d-%Y') 'Ship date',format(cost,2) 'Ship Adjustment',description 'Adjustment Notes' from shipping_data where status='adjustment' and job_id='"+rs.getString("K:Job^Number")+"' order by date";

rsAdj = st2.executeQuery(adjSQL);
while (rsAdj.next()){
	%><tr>
		<td class='tableheader' colspan=5><div align='right'>Shipping Cost Adjustment: <%=rsAdj.getString("Ship Date")%></div></td>
		<td class='text-row<%=(((x % 2) == 0)?1:2)%>' style="text-align: right;">&nbsp;</td>
		<td class='text-row<%=(((x % 2) == 0)?1:2)%>' style="text-align: right;"><%=rsAdj.getString("Ship Adjustment")%></td>
		<td class='text-row<%=(((x % 2) == 0)?1:2)%>' colspan=11><%=rsAdj.getString("Adjustment Notes")%></td>
	</tr><%
	a++;
	totShip+=rsAdj.getDouble("Ship Adjustment");
}%><%=((a>0)?"<tr><td class='tableheader' colspan=5><div align='right'>Total For PO "+rs.getString("K:Job^Number")+"</div></td><td class='text-row"+(((x % 2) == 0)?1:2)+"' align='right'><strong>"+totCost+"</strong></td><td class='text-row"+(((x % 2) == 0)?1:2)+"' align='right'><strong>"+totShip+"</strong></td><td class='text-row"+(((x % 2) == 0)?1:2)+"' colspan=11>&nbsp;</td></tr><script>document.forms[0].elements['H:Accrued^Shipping"+keyStr+"'].value="+totShip+";document.forms[0].elements['H:F:Accrued^PO^Cost"+keyStr+"'].value="+totCost+"</script>":"")%><%
}
%></table><%
if (x==0){
//  response.sendRedirect("APEntryForm.jsp?mode=repeat&message=No records found for this request.");
//  return;
%><%=POSQL%><%
}
%></td>
    </tr>
  </table>
</form>
</body>
<%sc.close();%>
</html>
