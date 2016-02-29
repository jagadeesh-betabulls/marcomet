<%@ page import="java.text.*,java.sql.*,java.util.*,com.marcomet.environment.*,com.marcomet.jdbc.*,com.marcomet.tools.*" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();

StringTool str=new StringTool();
DecimalFormat nf = new DecimalFormat("#,###.00");
DecimalFormat decFormatter = new DecimalFormat("#,###.##");
boolean submitted=((!(request.getParameter("cId")==null || request.getParameter("cId").equals("0")) && request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true"))?true:false);
String keyStr="";
String act = ((request.getParameter("act")==null)?"":request.getParameter("act"));
String mode = request.getParameter("mode");
boolean noVendor=((request.getParameter("cId")!=null && request.getParameter("cId").equals("0") && submitted)?true:false);
String message =((!submitted && request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true"))?((request.getParameter("cId")!=null && request.getParameter("cId").equals("0"))?"Error: Vendor Must be chosen.<br>":"Error:"):"");
String siteHostId=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId();
int x=0;
int y=0;
int iDiv=0;
double detailLines=0;
if(act.equals("exit") || siteHostId==null) {
	response.sendRedirect("/reports/vendors/index.jsp");
	return;
}
String vendorId=((request.getParameter("cId")==null) || request.getParameter("cId").equals("")?"0":request.getParameter("cId"));
String reportType=((request.getParameter("reportType")==null) || request.getParameter("reportType").equals("")?"AllOpen":request.getParameter("reportType"));
String apID=((request.getParameter("apId")==null) || request.getParameter("apId").equals("")?"0":request.getParameter("apId"));
String vendorContactId=((request.getParameter("contactId")==null) || request.getParameter("contactId").equals("")?vendorId:request.getParameter("contactId"));
String vendorCompanyId=((request.getParameter("companyId")==null) || request.getParameter("companyId").equals("")?vendorId:request.getParameter("companyId"));
String jobDate=((request.getParameter("txtJobDateTo")==null)?"":request.getParameter("txtJobDateTo"));
boolean apiNotComplete=true;
String compName = ((request.getParameter("cName")==null) || request.getParameter("cName").equals("")?"":request.getParameter("cName"));
String poNo = ((request.getParameter("poNo")==null) || request.getParameter("poNo").equals("")?"0":request.getParameter("poNo"));
String jobId = ((request.getParameter("jobId")==null) || request.getParameter("jobId").equals("")?"0":request.getParameter("jobId"));
String invDate=((request.getParameter("txtInvDate")==null )?"":request.getParameter("txtInvDate"));
String invAmount=((request.getParameter("poAmt")==null) || request.getParameter("poAmt").equals("")?"0":request.getParameter("poAmt"));
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
<style>
div#filters{margin: 0px 20px 0px 20px;display: none;}
.greenbutton {
	border-style: solid;	border-width: 1px 1px 1px 1px;
	color: white;	border-color: Black Black Black Black;	text-decoration: none;	background-color: #448c34;
	font: bold 8pt Arial,Verdana,Geneva;	text-align: center;	width: 100px;	border: thin outset;	padding-left: 10px;	padding-right: 10px;	white-space: nowrap;
}

A.greenbutton:active {
	border-style: solid;	border-width: 1px 1px 1px 1px;	color: Red;	border-color: Black Black Black Black;
	text-decoration: none;	background-color: #448c34;	text-align: center;	width: 100px;	border: thin outset; font: bold 8pt Arial,Verdana,Geneva;
}

A.greenbutton:visited {
	border-style: solid;	border-width: 1px 1px 1px 1px;	color: white;	border-color: Black Black Black Black;
	text-decoration: none;	background-color: #448c34;	text-align: center;	width: 100px;	border: thin outset; font: bold 8pt Arial,Verdana,Geneva;
}

A.greenbutton:hover {
	color: Red;	text-decoration: none;	background-color: #6f8c62;	font: bold 8pt Arial,Verdana,Geneva;	text-align: center;
	width: 100px;	border-style: outset;	border-width: thin;
}

A.greenbutton:link {	text-decoration: none;	color: white;}

.redbutton {
	border-style: solid; border-width: 1px 1px 1px 1px;	color: black;	border-color: Black Black Black Black;	text-decoration: none;	background-color: red;	font: bold 10pt Arial,Verdana,Geneva;	text-align: center;	width: 100px;	border: thin outset;	padding-left: 10px;	padding-right: 10px;	white-space: nowrap;
}

A.redbutton:active {
	border-style: solid;	border-width: 1px 1px 1px 1px;
	color: Red;	border-color: Black Black Black Black;	text-decoration: none;	background-color: red;
	text-align: center;	width: 100px;	border: thin outset;	font: bold 8pt Arial,Verdana,Geneva;
}

A.redbutton:hover {
	color: Red;	text-decoration: none;	background-color: #6f8c62;	font: bold 10pt Arial,Verdana,Geneva;
	text-align: center;	width: 100px;	border-style: outset;	border-width: thin;
}

A.redbutton:link {	text-decoration: none;	color: black;}

.highlightActiveField {
    border: 1px solid black;
    border-left: 4px solid #BF1717;
    background-color: #DFDFDF;  
}

.highlightInactiveField {
    border: 1px solid black;    
    background-color: #fff;
}

</style>
<script>
function none(){
}
function popVendorFields(el){
	var arr=el.value.split('|');
	document.forms[0].cName.value=el.options[el.selectedIndex].text
	document.forms[0].cId.value=arr[0];
	document.forms[0].companyId.value=arr[1];
	document.forms[0].contactId.value=arr[2];
}
var applied=0;
var firstApplied=0;
var appliedShip = new Array();
var appliedPO = new Array();

var apid=0;

function newLine(jobno,accStr){
	applied=((firstApplied=='')?0:firstApplied);
	for (x in appliedShip){
		applied=Number(applied)+Number(appliedShip[x]);
	}
	for (x in appliedPO){
		applied=Number(applied)+Number(appliedPO[x]);
	}
	if ((document.forms[1].elements['ap_shipping_amount'+jobno].value=='' || document.forms[1].elements['ap_shipping_amount'+jobno].value=='0') && (document.forms[1].elements['ap_purchase_amount'+jobno].value=='' || document.forms[1].elements['ap_purchase_amount'+jobno].value=='0')){
		document.getElementById('accept'+jobno).innerHTML='';
	} else {
		document.getElementById('accept'+jobno).innerHTML=((accStr=='0')?'':'<a href="javascript:onClick=acceptLine('+jobno+')" class=greenbutton>APPLY</a>');
	}
	document.getElementById('applied').innerHTML=applied.toFixed(2);
	
}

function acceptLine(jobId){
	document.forms[1].elements['createLines'].value='true';
	document.forms[1].submit();
}

function closePO(el,jobno){
		if (el.checked){
			document.forms[1].elements['ap_shipping_amount'+jobno].value=document.forms[1].elements['F:H:Ship^Balance'+jobno].value;
			document.forms[1].elements['ap_purchase_amount'+jobno].value=document.forms[1].elements['F:H:PO^Balance'+jobno].value;	
			appliedShip[jobno]=Number(document.forms[1].elements['H:Accrued^Shipping'+jobno].value.replace(/,/g,""));
			appliedPO[jobno]=Number(document.forms[1].elements['H:F:Accrued^PO^Cost'+jobno].value.replace(/,/g,""));
			newLine(jobno,1);

		}else{
			document.forms[1].elements['ap_shipping_amount'+jobno].value='';
			document.forms[1].elements['ap_purchase_amount'+jobno].value='';
			appliedShip[jobno]=0;
			appliedPO[jobno]=0;
			newLine(jobno,0);
		}
}


function addTot(){
	
}

function deleteAPLine(id){
	var ans=confirm('Are you sure you want to delete the AP Invoice Line #'+id+'?');
	if (ans){
		document.forms[1].elements['deleteLine'].value=id;
		document.forms[1].submit();
	}
}
function applyAPLine(id,vid,vcid,vcmpid){
	var ans=confirm('Are you sure you want to change the AP Invoice to #'+id+'?');
	if (ans){
		document.forms[1].apId.value=id;	
		document.forms[1].submit();	
	}
}
function jobLookup(typePop){
	if (document.forms[0].luJobNumber.value==''){
		alert('Please enter a job number before requesting the '+typePop+' details.');
		document.forms[0].luJobNumber.focus();
	}else{
		if (typePop=='Job'){
			pop('/popups/JobDetailsPage.jsp?jobId='+document.forms[0].luJobNumber.value,'800','600');
		}else{
			pop('/popups/PurchaseOrder.jsp?jobId='+document.forms[0].luJobNumber.value,'800','600');		
		}
	}
}
</script>
</head><body>
<span id='loading'><div align='center'> L O A D I N G . . . <br><br><img src='/images/loading.gif'><br></div></span><div id='filtertoggle' ></div><div id='filters'>
<form name="entryForm" method="POST" action="APAddEntryFromQuick.jsp?submitted=true">
<table border=0 width=60%><tr><td><input type="hidden" name="cName" value="<%=compName%>"><input type="hidden" name="contactId" value="<%=vendorContactId%>"><input type="hidden" name="companyId" value="<%=vendorCompanyId%>"><input type="hidden" name="cId" value="<%=vendorId%>"><input type="hidden" name="compName" value="<%=compName%>"><input type="hidden" name="act" value="<%=act%>">
	<table  cellspacing="1" cellpadding="0" bgcolor="#333333" >
	<tr><td valign="top" ><table border="0" cellspacing="0" cellpadding="0" ><tr><td bgcolor="f3f1f1"><table border="0" cellpadding="0" cellspacing="1">
          				<tr> <td colspan="2" class="table-heading">APPLY SUBVENDOR INVOICE TO JOBS</td>
          				<td rowspan=11 valign=top width=65% class=lineitem>Notes:<br>Choose a vendor, enter the invoice number from the Vendor's form or leave it blank to create a new AP Invoice Record. If the vendor's invoice number hasn't been entered into the system yet a new AP Invoice record will be created for it. To pull up information on an unrelated job use the 'job Info Lookup' feature below.<hr><blockquote><p class=text-row1><i>Job Info Lookup</i><br>Job Number:&nbsp;<input type="text" name="luJobNumber"><br><a href="javascript:jobLookup('Job')">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&raquo;&nbsp;Popup job details</a><br><a href="javascript:jobLookup('PO')">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&raquo;&nbsp;Popup job PO</a><br><br></p></blockquote></td>               		<tr><td class="text-row2" colspan=2><b>SubVendor Invoice Information:</b></td></tr>
                		<tr><td class="text-row1" ><span class='errorText'>**</span>Vendor Company (Required)</td><%
                  String sql="Select concat(v.id,'|',v.company_id,'|',c.id) as value,v.notes as text from vendors v,companies co,contacts c where  co.id=c.companyid and v.subvendor=1 and if(v.default_rep =0,v.company_id=c.companyid, v.default_rep=c.id) order by v.notes";
                  			%><td class="text-row2" >
<formtaglib:SQLDropDownTag dropDownName="cIdChoices" sql="<%=sql%>"  selected="<%=vendorId+"|"+vendorCompanyId+"|"+vendorContactId%>" extraCode="class=\"text-list\" onChange=\"popVendorFields(this)\"" extraFirstOption="<option value=\"0\" selected>Select SubVendor Company</option>" />
</td></tr>
                		<tr><td class="text-row1" >Vendor Invoice Number</td><td class="text-row2" ><input type="text" name="poNo" size="30" class="textbox" maxlength="30" value="<%=poNo%>"></tr>
                		<tr><td class="text-row1" >Vendor Invoice Amount</td><td class="text-row2" >
                  $<input type="text" name="poAmt" size="24" align=right class="textbox" maxlength="8" value="<%=invAmount%>"></tr>
                		<tr><td class="text-row1" >Invoice Date</td><td class="text-row2" >             		

<input type="hidden" name="txtInvDate" id="f_invdate_d"><span class="lineitemsselected" id="show_inv"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c"
				     style="cursor: pointer; border: 1px solid red;"
				     title="Date selector"
				     onmouseover="this.style.background='red';"
				     onmouseout="this.style.background=''" />
<script type="text/javascript">Calendar.setup({<%String fDateFrom=((request.getParameter("txtInvDate")==null)?"":request.getParameter("txtInvDate"));%>
	inputField: "f_invdate_d", ifFormat: "%Y-%m-%d",displayArea: "show_inv",daFormat: "%m-%d-%Y", button:"f_trigger_c", align: "BR", singleClick: true}); 
 	var d=new Date();
 	var dMonth=(d.getMonth()+1)+''; dMonth=((dMonth.length==2)?dMonth:'0'+dMonth);
	var dDay=(d.getDate())+''; dDay=((dDay.length==2)?dDay:'0'+dDay); 	
 	document.forms[0].txtInvDate.value=<%=((fDateFrom.equals(""))?"d.getFullYear()+'-'+dMonth+'-'+dDay":"'"+fDateFrom+"'")%>; 
 	document.getElementById('show_inv').innerHTML=<%=((fDateFrom.equals(""))?"(dMonth)+'-'+dDay+'-'+d.getFullYear()":"'"+fDateFrom.substring(5,7)+"-"+fDateFrom.substring(8,10)+"-"+fDateFrom.substring(0,4)+"'")%>;
</script>              		
                		</tr>
               			<tr><td class="text-row2" colspan=2><hr><b>Apply To Jobs:</b></td></tr>
                		<tr><td class="text-row1" >Show:</td><td class="text-row2" ><input type='radio' name="reportType" value="AllOpen" <%=((reportType.equals("AllOpen"))?"checked":"")%>>All Open <input type='radio' name="reportType" value="PartOpen" <%=((reportType.equals("PartOpen"))?"checked":"")%>> Partial Open<br><input type='radio' name="reportType" value="FullOpen" <%=((reportType.equals("FullOpen"))?"checked":"")%>> Fully Open <input type='radio' name="reportType" value="All" <%=((reportType.equals("All"))?"checked":"")%>> All (Open and Closed)<br></td></tr><tr><td class="text-row1">Show Jobs Posted from</td><td class="text-row2" > 
               
                		
<%String fDateTo=((request.getParameter("txtJobDateTo")==null)?"":request.getParameter("txtJobDateTo"));%>
<input type="hidden" name="txtJobDateFrom" id="f_datefrom_d"><span class="lineitemsselected" id="show_d2"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c2"
				     style="cursor: pointer; border: 1px solid red;"
				     title="Date selector"
				     onmouseover="this.style.background='red';"
				     onmouseout="this.style.background=''" />
<script type="text/javascript">
Calendar.setup({<%fDateFrom=((request.getParameter("txtJobDateFrom")==null)?"":request.getParameter("txtJobDateFrom"));%>
	inputField: "f_datefrom_d", ifFormat : "%Y-%m-%d", displayArea : "show_d2", daFormat : "%m-%d-%Y", button : "f_trigger_c2", align: "BR", singleClick : true });
	var d=new Date();
	var dMonth=(d.getMonth())+''; dMonth=((dMonth.length==2)?dMonth:'0'+dMonth);
	var dDay=(d.getDate())+''; dDay=((dDay.length==2)?dDay:'0'+dDay);
	document.forms[0].txtJobDateFrom.value=<%=((fDateFrom.equals(""))?"'2001-'+dMonth+'-'+ dDay ":"'"+fDateFrom+"'")%>; document.getElementById('show_d2').innerHTML=<%=((fDateFrom.equals(""))?"(dMonth)+'-'+dDay+'-2001'":"'"+fDateFrom.substring(5,7)+"-"+fDateFrom.substring(8,10)+"-"+fDateFrom.substring(0,4)+"'")%>;
</script>
<br>TO:


<input type="hidden" name="txtJobDateTo" id="f_dateto_d"><span class="lineitemsselected" id="show_d3"></span> &nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c3"
				     style="cursor: pointer; border: 1px solid red;"
				     title="Date selector"
				     onmouseover="this.style.background='red';"
				     onmouseout="this.style.background=''" />
<script type="text/javascript">
Calendar.setup({<%fDateFrom=((request.getParameter("txtJobDateTo")==null)?"":request.getParameter("txtJobDateTo"));%>
	inputField: "f_dateto_d", ifFormat : "%Y-%m-%d", displayArea : "show_d3", daFormat : "%m-%d-%Y", button : "f_trigger_c3", align: "BR", singleClick : true });
	var d=new Date();
	var dMonth=(d.getMonth()+1)+''; dMonth=((dMonth.length==2)?dMonth:'0'+dMonth);
	var dDay=(d.getDate())+''; dDay=((dDay.length==2)?dDay:'0'+dDay);
	document.forms[0].txtJobDateTo.value=<%=((fDateTo.equals(""))?"d.getFullYear()+'-'+dMonth+'-'+ dDay ":"'"+fDateTo+"'")%>; document.getElementById('show_d3').innerHTML=<%=((fDateFrom.equals(""))?"(dMonth)+'-'+dDay+'-'+d.getFullYear()":"'"+fDateFrom.substring(5,7)+"-"+fDateFrom.substring(8,10)+"-"+fDateFrom.substring(0,4)+"'")%>;
</script>
</tr>
                		<tr><td class="text-row1" ><b>- OR-</b> Show Job Id</td><td class="text-row2" ><input type="text" name="jobId" size="24" class="textbox" maxlength="6" value="<%=((request.getParameter("jobId")==null)?"":request.getParameter("jobId"))%>"></tr>
                		<tr><td colspan="3" class="table-subheading" > <div align="center"><input type="submit" value=" CREATE / FIND INVOICE " name="submit2" class="Field-Button" onClick="document.forms[0].submit();">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="submit" value="  EXIT   " name="submit2" class="Field-Button" onclick="doExit()"></div></td>
                		</tr>
                	</table>
            	</td></tr><%
				if(!message.equals("")) {
					//show message
					message += ((request.getParameter("message")==null)?"":request.getParameter("message"));
					
			%><tr ><td colspan="2" class="text-row2" align='center'><span class='errorText'> <%=message%></span></td></tr><%}%>
			</table></td></tr></table>
</td><td class=subtitle></td><td></td></tr><%
%></table></td></tr></table></td></tr></table>
</form><hr></div>
<!-- END FILTERS -->
<%

//If the search pulls up one PO use it as the AP header, if it pulls up multiple PO's present the list and have user select one to use.

if(!(vendorId.equals("0") && poNo.equals("0") && jobId.equals("0")) ){

String vendorFilter = ((vendorId==null || vendorId.equals(""))?"":" and j.dropship_vendor='"+vendorId+"' ");
String poaVendorFilter = ((vendorId==null || vendorId.equals(""))?"":" and poa.vendor_id='"+vendorId+"' ");
String pohVendorFilter = ((vendorId==null || vendorId.equals(""))?"":" and poa.vendor_id='"+vendorId+"' ");
String apidVendorFilter = ((vendorId==null || vendorId.equals(""))?"":" and apid.vendorid='"+vendorId+"' ");
String shVendorFilter = ((vendorId==null || vendorId.equals(""))?"":" and sh.shipping_vendor_id='"+vendorId+"' ");
String shaVendorFilter = ((vendorId==null || vendorId.equals(""))?"":" and sh.shipping_account_vendor_id='"+vendorId+"' ");
String openBalanceFilter ="";  
// and Accrued_Job_Cost_Balance <> 0;
String asOfDate=request.getParameter("txtInvDate");
String asOfPostDate=request.getParameter("txtJobDateTo");
String postDateFrom=((request.getParameter("txtJobDateFrom")==null)?"":request.getParameter("txtJobDateFrom"));
String postDateTo=((request.getParameter("txtJobDateTo")==null)?"":request.getParameter("txtJobDateTo"));
String postDateFromTime=((request.getParameter("txtJobDateFrom")==null)?"":request.getParameter("txtJobDateFrom")+" 00:00:00");
String postDateToTime=((request.getParameter("txtJobDateTo")==null)?"":request.getParameter("txtJobDateTo")+" 23:59:59");
String asOfDateTime=request.getParameter("txtInvDate")+" 23:59:59";

boolean showPreAccrual=false;

//If the user supplied a vendor PO number check to see if the PO Number exists for the given vendor, if not create it.

String apVendorIdFilter=((vendorId.equals("0"))?"":" and in2 ='"+vendorId+"' ");
String apPONumberFilter=((poNo.equals("0"))?"":" and txt5 ='"+poNo+"'");
String apIdFilter=((apID.equals("0"))?"":" and txt4 ='"+apID+"'");
String apAmountFilter="";
//((invAmount.equals("0"))?"":" and ap_invoice_amount='"+invAmount+"'");
//String apInvDateFilter=( (invDate.equals("")) ? "":" and ap_invoice_date='"+invDate+"' ":"");
apVendorIdFilter=((vendorId.equals("0"))?"":" and ap.vendorid="+vendorId+" ");
String poNoFilter=((poNo.equals("0"))?"":" and ap.vendor_invoice_no='"+poNo+"' ");
String jobIdFilter=((jobId.equals("0"))?"":" and jobs.id="+jobId+" ");
	
	
String apFirstSQL=((apID.equals("0"))?"Select distinct ap.id 'apid' from ap_invoices ap where ap.vendor_invoice_no='"+poNo+"' and ap.vendorid='"+vendorId+"'":"Select distinct ap.id 'apid' from ap_invoices ap where ap.id='"+apID+"'");


//"Select distinct ap.vendorid 'vendor_id',ap.id 'ap_id',ap.vendor_invoice_no 'vendor_invoice_no' ,apid.job_id 'Job Id', round(sum(po_amount) + sum(po_adjustment_amount)-sum(ap_purchase_amount),2) 'AP balance', round(sum(shipcost) + sum(shipadjustment) - sum(ap_shipping_amount),2) 'ship balance' from ap_invoices ap left join ap_invoice_details apid on ap.id=apid.ap_invoiceid  where ap.vendor_invoice_no='"+poNo+"' and ap.vendorid='"+vendorId+"'";

//"Select distinct vendorid 'vendor_id',apinvoice_id 'ap_id',vendor_invoice_no 'vendor_invoice_no' ,job_id 'Job Id', round(sum(po_amount) + sum(po_adjustment_amount)-sum(ap_purchase_amount),2) 'AP balance',round(sum(shipcost) + sum(shipadjustment) - sum(ap_shipping_amount),2) 'ship balance' from tmpxaAPTransactions t group by job_id order by job_id";

//if line items need to be entered into the invoice from the form cycle through and enter them
String shipApply="0";
String poApply="0";
String apNotes="";
String idStr="";
int numLines=((request.getParameter("numLines")==null || request.getParameter("numLines").equals(""))?0:Integer.parseInt(request.getParameter("numLines")));
%><script>document.write("<div class=lineitems>");<%
if(request.getParameter("createLines")!=null && request.getParameter("createLines").equals("true") && numLines>0){
	for (int k=0 ;k <= (numLines-1); k++){
		idStr=((request.getParameter("key"+k)==null)?"":request.getParameter("key"+k));
		if (!(idStr.equals("")) ){
			shipApply=((request.getParameter("ap_shipping_amount"+idStr)==null || request.getParameter("ap_shipping_amount"+idStr).equals(""))?"0":request.getParameter("ap_shipping_amount"+idStr));
			poApply=((request.getParameter("ap_purchase_amount"+idStr)==null || request.getParameter("ap_purchase_amount"+idStr).equals(""))?"0":request.getParameter("ap_purchase_amount"+idStr));			
			apNotes=((request.getParameter("purchase_description"+idStr)==null)?"":request.getParameter("purchase_description"+idStr));
			if(!(shipApply.equals("0") && poApply.equals("0")) ) {
				%>document.write("<br>Created new line for AP=<%=apID%> | Job=<%=idStr%> | Ship=<%=shipApply%> | PO=<%=poApply%> | Notes=<%=apNotes%>");<%
				String addAPDSQL="insert into ap_invoice_details ( ap_invoiceid, po_id, jobid, gross, net, purchase_description, ap_purchase_amount, ap_shipping_amount, ap_sales_tax_amount, ap_sales_tax_state, amount, lu_ap_recipient_type_id, accrual_post_date, vendorid, vendor_invoice_no, apinvoice_date) values ( '"+apID+"', '0', '"+idStr+"', '0', '0', '"+apNotes+"', '"+poApply+"', '"+shipApply+"', '0', '31', '"+Double.toString(Double.parseDouble(shipApply)+Double.parseDouble(poApply))+"', '4', '"+invDate+"', '"+vendorId+"', '"+poNo+"', '"+invDate+"')";
				st.executeUpdate(addAPDSQL);
			}
		}
	}
}

if(request.getParameter("deleteLine")!=null && !(request.getParameter("deleteLine").equals(""))){
		String deleteAPDSQL="delete from ap_invoice_details where id="+request.getParameter("deleteLine");
		st.executeUpdate(deleteAPDSQL);
		%>document.write("<div class=lineitems>Deleted AP Invoice line #<%=request.getParameter("deleteLine")%> for AP=<%=apID%></div>");<%
}

%>document.write("</div>");</script><%

ResultSet rsAPFirstID = st.executeQuery(apFirstSQL);
%><!-- apFirstSQL: <%=apFirstSQL%> --><%
int c=0;
apID="";
while (rsAPFirstID.next()){
	apID=rsAPFirstID.getString("apid");	
	c++;
} 

if (c>1){
//If more than one APInvoice record exists with this vendor invoice number then present them and ask for a Choice
//Don't present the rest of the page

%>Multiple Invoices Exist, please choose one to use:<%
	submitted=false;
}else if (c==0){
	String insSQL="insert into ap_invoices ( rec_no, vendorid, vendor_invoice_no, ap_invoice_date, ap_invoice_amount, pay_to_contact_id, pay_to_company_id) values ('0', '"+vendorId+"', '"+poNo+"', '"+invDate+"', '"+invAmount+"', '"+vendorContactId+"', '"+vendorCompanyId+"')";

	st.executeUpdate(insSQL);
		ResultSet rsId=st.executeQuery("select max(id) 'maxid' from ap_invoices");
		if(rsId.next()){
			apID=rsId.getString("maxid");	
		}

}

String apSQLId="Select ap.id 'K:AP<br>Invoice Id',ap.vendorid 'Vendor ID',v.notes 'Vendor',ap.vendor_invoice_no 'E1:Vendor Invoice Number',concat('<input type=hidden name=\"txtInvDate\" value=\"',ap.ap_invoice_date,'\">',DATE_FORMAT(ap.ap_invoice_date,'%m/%d/%Y')) 'E2:Invoice Date', concat('<input type=hidden name=\"txtInvAmt\" value=\"',ap.ap_invoice_amount,'\">',ap.ap_invoice_amount) 'E3:Invoice Amount',ap.pay_to_contact_id 'Pay to Contact Id',ap.pay_to_company_id 'Pay to Company Id', concat('<span class=lineitemsright id=\"appliedPO\">',if(apid.id is null,0,sum(apid.ap_purchase_amount)),'</span>')  'Purchase Amount Total', concat('<span class=lineitemsright id=\"appliedShip\">',if(apid.id is null,0,sum(apid.ap_shipping_amount)),'</span>') 'Shipping Amount Total', if(apid.id is null,0,sum(apid.ap_sales_tax_amount)) 'Sales Tax Amount',concat('<span class=lineitemsright id=\"applied\">',if(apid.id is null,0,sum(apid.amount)),'</span>') 'Total Applied',count(apid.id) 'Detail Lines' from ap_invoices ap left join ap_invoice_details apid on ap.id=apid.ap_invoiceid left join vendors v on v.id=ap.vendorid where  ap.id='"+apID+"' group by ap.id ";	
%><!-- apSQLId: <%=apSQLId%> --><%
if (submitted && !(apID.equals(""))){
try{
	ResultSet rsAPFirst = st.executeQuery(apSQLId);
	ResultSetMetaData rsmdAPFirst = rsAPFirst.getMetaData();
	int numberOfColumnsAPFirst = rsmdAPFirst.getColumnCount();
	String tempStringAPFirst = null;
	Vector headersAPFirst  = new Vector(15) ;
		%><form method="POST" action="APAddEntryFromQuick.jsp?submitted=true"><script>apid='<%=apID%>';</script>
	<input type="hidden" name="poAmt" value="<%=invAmount%>"><input type="hidden" name="companyId" value="<%=vendorCompanyId%>"><input type="hidden" name="contactId" value="<%=vendorContactId%>"><input type="hidden" name="act" value=""><input type="hidden" name="apId" value="<%=apID%>"><input type="hidden" name="cId" value="<%=vendorId%>"><input type="hidden" name="poNo" value="<%=poNo%>"><input type="hidden" name="jobId" value="<%=jobId%>"><input type="hidden" name="cName" value="<%=compName%>"><input type="hidden" name="txtJobDate" value="<%=postDateTo%>"><input type="hidden" name="txtJobDateTo" value="<%=postDateTo%>"><input type="hidden" name="txtJobDateFrom" value="<%=postDateFrom%>"><input type="hidden" name="reportType" value="<%=reportType%>"><input type="hidden" name="createLines" value="false"><input type="hidden" name="deleteLine" value="">
	<!-- AP INVOICE HEADER -->
	<div class=subtitle>Apply Lines to this AP Invoice:</div>
	<table id='invoice' cellpadding=2><tr><%
	for (int k=1 ;k <= numberOfColumnsAPFirst; k++){
		tempStringAPFirst = new String ((String) rsmdAPFirst.getColumnLabel(k));
		headersAPFirst.add(tempStringAPFirst);
		tempStringAPFirst = str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempStringAPFirst,"E3:", ""),"E2:", ""),"E1:", ""),"H:", ""),"F:", ""),"S:", ""),"_", " "),"R:", ""),"T:", ""),"Po:", ""),"Pr:", ""),"K:", ""),"L:", ""),"~", "&nbsp;"),"C:", "");
		x++;
		%><td  class="table-heading"><%=tempStringAPFirst%></td><%
	} //FOR loop		%></tr>	<%
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
			%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%><%
			}else if(columnName.indexOf("E1:")>-1){
				%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><a href='javascript:pop("/popups/QuickChangeFormDiv.jsp?cols=30&rows=1&question=Change%20AP%20Vendor%20Invoice%20Number&primaryKeyValue=<%=keyStr%>&columnName=vendor_invoice_no&tableName=ap_invoices&valueType=string&parentDiv=<%="changeDiv"+(iDiv)%>",300,200)'>&raquo;</a>&nbsp;<span id='<%="changeDiv"+(iDiv++)%>' ><%=columnValue%></span><%
			}else if(columnName.indexOf("E2:")>-1){
				%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><a href='javascript:pop("/popups/QuickChangeDateFormDiv.jsp?refreshOpener=false&cols=30&rows=1&question=Change%20AP%20Vendor%20Invoice%20Date&primaryKeyValue=<%=keyStr%>&columnName=ap_invoice_date&tableName=ap_invoices&valueType=string&parentDiv=<%="changeDiv"+(iDiv)%>",300,200)'>&raquo;</a>&nbsp;<span id='<%="changeDiv"+(iDiv++)%>' ><%=columnValue%></span><%		
			}else if(columnName.indexOf("E3:")>-1){
				%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><a href='javascript:pop("/popups/QuickChangeFormDiv.jsp?cols=30&rows=1&question=Change%20AP%20Vendor%20Invoice%20Amount&primaryKeyValue=<%=keyStr%>&columnName=ap_invoice_amount&tableName=ap_invoices&valueType=string&parentDiv=<%="changeDiv"+(iDiv)%>",300,200)'>&raquo;</a>&nbsp;<span id='<%="changeDiv"+(iDiv++)%>' ><%=columnValue%></span><%	
			}else{%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%><%
			}%><%=(((columnName.indexOf("H:")>-1))?"<input type=hidden name='"+columnName+keyStr+"' value='"+columnValue+"'>":"")%></td><%
		} //for
	x++;
		%></tr><%
	} //while
	%></table>
	
<!-- END AP HEADER -->

<!-- AP INVOICE DETAIL LINES -->
<%apSQLId="Select apid.id 'K:AP Invoice<br>Detail Id',concat('<input type=hidden name=\"apdId\"',ap.id,' value=\"',apid.id,'\">',apid.jobid) 'Job #',concat('<input type=hidden name=\"apPurchaseAmount\"',apid.id,' value=\"',apid.ap_purchase_amount,'\">',apid.ap_purchase_amount) 'AP Purchase Amount',concat('<input type=hidden name=\"apShippingAmount\"',apid.id,' value=\"',apid.ap_shipping_amount,'\">',apid.ap_shipping_amount) 'AP Shipping Amount',concat('<input type=hidden name=\"apSalesTaxAmount\"',apid.id,' value=\"',apid.ap_sales_tax_amount,'\">',apid.ap_sales_tax_amount) 'AP Sales Tax',concat('<input type=hidden name=\"apAmount\"',apid.id,' value=\"',apid.amount,'\">',apid.amount) 'AP Total',DATE_FORMAT(apid.accrual_post_date,'%m/%d/%y') 'Post Date',apid.purchase_description 'Purchase Description'  from ap_invoices ap , ap_invoice_details apid where ap.id=apid.ap_invoiceid and ap.id='"+apID+"'";	
%><!-- apSQLIdLines: <%=apSQLId%> --><%
	 rsAPFirst = st.executeQuery(apSQLId);
	 rsmdAPFirst = rsAPFirst.getMetaData();
	 numberOfColumnsAPFirst = rsmdAPFirst.getColumnCount();
	 tempStringAPFirst = null;
	 headersAPFirst  = new Vector(15) ;
		%>	<table id='invoice' cellpadding=2><tr><td class="table-heading">Delete<br>line</td><%
	for (int k=1 ;k <= numberOfColumnsAPFirst; k++){
		tempStringAPFirst = new String ((String) rsmdAPFirst.getColumnLabel(k));
		headersAPFirst.add(tempStringAPFirst);
		tempStringAPFirst = str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempStringAPFirst,"E3:", ""),"E2:", ""),"E1:", ""),"H:", ""),"F:", ""),"S:", ""),"_", " "),"R:", ""),"T:", ""),"Po:", ""),"Pr:", ""),"K:", ""),"L:", ""),"~", "&nbsp;"),"C:", "");
		x++;
		%><td  class="table-heading"><%=tempStringAPFirst%></td><%
	} //FOR loop		%></tr>	<%
		x=0;
	while (rsAPFirst.next()){
		%><tr><%
		for (int i=0;i < numberOfColumnsAPFirst; i++){
			String columnName = (String) headersAPFirst.get(i);
			String columnValue=((columnName.indexOf("F:")>-1)?nf.format(rsAPFirst.getDouble(columnName)):((rsAPFirst.getString(columnName)==null)?"":rsAPFirst.getString(columnName) ));
			if(columnName.indexOf("K:")>-1){
				keyStr=columnValue;
			%><td><a href="javascript:deleteAPLine('<%=columnValue%>')" class='redButton' alt='DELETE AP LINE'>-</a>&nbsp;&nbsp;<input type='hidden' name='keyAP<%=x%>' value='<%=columnValue%>'></td><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%><%
			}else if(columnName.indexOf("E1:")>-1){
				%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=30&rows=1&question=Change%20AP%20Vendor%20Invoice%20Number&primaryKeyValue=<%=keyStr%>&columnName=vendor_invoice_no&tableName=ap_invoices&valueType=string",300,200)'>&raquo;</a>&nbsp;<%=columnValue%><%
			}else if(columnName.indexOf("E2:")>-1){
				%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><a href='javascript:pop("/popups/QuickChangeDateForm.jsp?refreshOpener=false&cols=30&rows=1&question=Change%20AP%20Vendor%20Invoice%20Date&primaryKeyValue=<%=keyStr%>&columnName=ap_invoice_date&tableName=ap_invoices&valueType=string",300,200)'>&raquo;</a>&nbsp;<%=columnValue%><%		
			}else if(columnName.indexOf("E3:")>-1){
				%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=30&rows=1&question=Change%20AP%20Vendor%20Invoice%20Amount&primaryKeyValue=<%=keyStr%>&columnName=ap_invoice_amount&tableName=ap_invoices&valueType=string",300,200)'>&raquo;</a>&nbsp;<%=columnValue%><%	
			}else{%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%><%
			}%><%=(((columnName.indexOf("H:")>-1))?"<input type=hidden name='"+columnName+keyStr+"' value='"+columnValue+"'>":"")%></td><%
		} //for
	x++;
		%></tr><%
	} //while
	if (x==0){
	%><Tr><td class=lineitems colspan='<%=numberOfColumnsAPFirst+1%>'>No Detail Lines for this AP Invoice</td></tr><%
	}
	%></table><br><hr><br>
<!-- END AP DETAIL LINES -->
<%
try{
	st.executeUpdate("DROP TABLE tmpxaAPTransactions");
} catch (Exception e){

}

st.executeUpdate("CREATE  TABLE tmpxaAPTransactions (vendor INT UNSIGNED NOT NULL DEFAULT 0,job_id INT UNSIGNED NOT NULL DEFAULT 0,product_id INT UNSIGNED NOT NULL DEFAULT 0,product_code varchar(50) default '',root_prod_code varchar(50) default '',job_name text, post_date date default NULL,po_amount double default '0',po_adjustment_amount double default '0',shipcost double default '0',shipadjustment double default '0',ap_purchase_amount double default '0',ap_shipping_amount double default '0',apinvoice_id INT UNSIGNED NOT NULL DEFAULT 0,vendor_invoice_no varchar(100) default '',apinvoice_date date default NULL,purchase_description text) ");

//st.executeUpdate("CREATE TEMPORARY TABLE tmpxAPTransactions (vendor INT UNSIGNED NOT NULL DEFAULT 0,job_id INT UNSIGNED NOT NULL DEFAULT 0,product_id INT UNSIGNED NOT NULL DEFAULT 0,product_code varchar(50) default '',root_prod_code varchar(50) default '',job_name text, post_date date default NULL,po_amount double default '0',po_adjustment_amount double default '0',shipcost double default '0',shipadjustment double default '0',ap_purchase_amount double default '0',ap_shipping_amount double default '0',apinvoice_id INT UNSIGNED NOT NULL DEFAULT 0,vendor_invoice_no varchar(100) default '',apinvoice_date date default NULL,purchase_description text) ");

//PO Header Records
String jobSQL="INSERT INTO tmpxaAPTransactions Select poa.vendor_id,j.id,j.product_id,j.product_code,j.root_prod_code,j.job_name,j.post_date,sum(poa.adjustment_amount),0,0,0,0,0,'','','0000-00-00',''  from jobs j,po_transactions poa where j.id=poa.job_id and (poa.adjustment_code is not null and poa.adjustment_code=0) "+((showPreAccrual)?"":"and (poa.pre_accrual is  null or poa.pre_accrual<>1)")+"  and poa.accrued_date>='"+postDateFromTime+"' and poa.accrued_date <='"+postDateToTime+"' "+poaVendorFilter+" group by j.id,poa.vendor_id";

//PO Adjustment Records
jobSQL=jobSQL+" union Select poa.vendor_id,j.id,j.product_id,j.product_code,j.root_prod_code,j.job_name,j.post_date,0,sum(poa.adjustment_amount),0,0,0,0,'','','0000-00-00',''  from jobs j,po_transactions poa where j.id=poa.job_id and (poa.adjustment_code is null or poa.adjustment_code<>0) "+((showPreAccrual)?"":"and (poa.pre_accrual is  null or poa.pre_accrual<>1)")+" and poa.accrued_date>='"+postDateFromTime+"' and poa.accrued_date <='"+postDateToTime+"' "+poaVendorFilter+" group by j.id,poa.vendor_id";

//Shipping Records - Shipping Account Vendor for cost
jobSQL=jobSQL+" union Select sh.shipping_account_vendor_id,j.id,j.product_id,j.product_code,j.root_prod_code,j.job_name,j.post_date,0,0,sum(sh.cost),0,0,0,'','','0000-00-00',''  from jobs j,shipping_data sh where sh.job_id=j.id and (sh.ignore_on_ap is null or sh.ignore_on_ap<>1) "+shaVendorFilter+" and (sh.adjustment_flag is null or sh.adjustment_flag<>1)  and sh.accrued_date <='"+postDateToTime+"' AND sh.accrued_date >='"+postDateFromTime+"' "+((showPreAccrual)?"":"and (pre_accrual is null or pre_accrual<>'1') ")+" group by j.id,sh.shipping_account_vendor_id";

//Shipping Records - Shipping Vendor for handling
jobSQL=jobSQL+" union Select sh.shipping_vendor_id,j.id,j.product_id,j.product_code,j.root_prod_code,j.job_name,j.post_date,0,0,sum(sh.subvendor_handling),0,0,0,'','','0000-00-00',''  from jobs j,shipping_data sh where sh.job_id=j.id and (sh.ignore_on_ap is null or sh.ignore_on_ap<>1) "+shVendorFilter+" and (sh.adjustment_flag is null or sh.adjustment_flag<>1)  and sh.accrued_date <='"+postDateToTime+"' AND sh.accrued_date >='"+postDateFromTime+"' "+((showPreAccrual)?"":"and (pre_accrual is null or pre_accrual<>'1') ")+" group by j.id,sh.shipping_vendor_id";

//Shipping Adjustment Records - Shipping Account Vendor for cost
jobSQL=jobSQL+" union Select shipping_account_vendor_id,j.id,j.product_id,j.product_code,j.root_prod_code,j.job_name,j.post_date,0,0,0,sum(sh.cost),0,0,'','','0000-00-00',''  from jobs j,shipping_data sh where sh.job_id=j.id and (sh.ignore_on_ap is null or sh.ignore_on_ap<>1) "+shaVendorFilter+" and (sh.adjustment_flag is not null and sh.adjustment_flag=1) and sh.accrued_date <='"+postDateToTime+"' AND sh.accrued_date >='"+postDateFromTime+"' "+((showPreAccrual)?"":"and (pre_accrual is null or pre_accrual<>'1') ")+" group by j.id,sh.shipping_account_vendor_id";

//Shipping Adjustment Records - Shipping Vendor for handling
jobSQL=jobSQL+" union Select shipping_vendor_id,j.id,j.product_id,j.product_code,j.root_prod_code,j.job_name,j.post_date,0,0,0,sum(sh.subvendor_handling ),0,0,'','','0000-00-00',''  from jobs j,shipping_data sh where sh.job_id=j.id and (sh.ignore_on_ap is null or sh.ignore_on_ap<>1) "+shVendorFilter+" and (sh.adjustment_flag is not null and sh.adjustment_flag=1) and sh.accrued_date <='"+postDateToTime+"' AND sh.accrued_date >='"+postDateFromTime+"' "+((showPreAccrual)?"":"and (pre_accrual is null or pre_accrual<>'1') ")+" group by j.id,sh.shipping_vendor_id";

//AP Records
jobSQL=jobSQL+" union Select apid.vendorid,j.id,j.product_id,j.product_code,j.root_prod_code,j.job_name,j.post_date,0,0,0,0,  sum(apid.ap_purchase_amount), sum(apid.ap_shipping_amount),apid.ap_invoiceid,apid.vendor_invoice_no,apid.apinvoice_date,apid.purchase_description  from jobs j,ap_invoice_details apid where j.id=apid.jobid "+((showPreAccrual)?"":" and (apid.pre_accrual is null or apid.pre_accrual<>'1') ") + " and apid.accrual_post_date >='"+postDateFromTime+"' "+apidVendorFilter+" group by j.id,apid.vendorid";

%>
<!-- jobSQL: <%=jobSQL%> -->
<%
	//Populate the temp table
	st2.executeUpdate(jobSQL);
	String tempString = "";	
	x=0;

	String adjSQL="Select vendor 'Vendor #',job_id 'K:Job #',product_code 'Product Code',product_id 'Pr:Product ID',job_name 'Job Name',sum(po_amount) 'T:R:Accrued Job Cost',sum(po_adjustment_amount) 'T:R:Po:Adjustments to Accrued Job Costs',sum(po_amount)+sum(po_adjustment_amount) 'T:R:Po:Total Accrued Job Costs',sum(ap_purchase_amount) 'T:R:Po:A/P Applied to Job Costs', round(sum(po_amount) + sum(po_adjustment_amount)-sum(ap_purchase_amount),2) 'T:R:Accrued_Job_Cost_Balance' , sum(shipcost) 'T:R:Po:Accrued Ship Cost', sum(dbl3) 'T:R:Po:Adjustments to Accrued Ship Costs', sum(shipcost) +sum(shipadjustment) 'T:R:Po:Total Accrued Ship Costs',sum(ap_shipping_amount)  'T:R:Po:A/P Applied to Ship Costs', round(sum(shipcost) + sum(shipadjustment) - sum(ap_shipping_amount),2) 'T:R:Accrued Ship Cost Balance'  ";

	adjSQL+="from tmpxaAPTransactions t left join product_roots pr on  t.root_prod_code=pr.root_prod_code  left join products p on t.product_id=p.id ";

	adjSQL+="where (round(sum(po_amount) + sum(po_adjustment_amount)-sum(ap_purchase_amount),2)+round(sum(shipcost) + sum(shipadjustment) - sum(ap_shipping_amount),2))>0 group by job_id order by job_id";

	%>
	<!-- adjQL: <%=jobSQL%> -->
	<%

	 apVendorIdFilter=((vendorId.equals("0"))?"":" and in2 ='"+vendorId+"' ");
	 apPONumberFilter=((poNo.equals("0"))?"":" and txt5 ='"+poNo+"'");
	 apIdFilter=((apID.equals("0"))?"":" and txt4 ='"+apID+"'");
	 apAmountFilter="";
	//((invAmount.equals("0"))?"":" and ap_invoice_amount='"+invAmount+"'");
	//String apInvDateFilter=( (invDate.equals("")) ? "":" and ap_invoice_date='"+invDate+"' ":"");
	 apFirstSQL="Select distinct vendor 'vendor_id',apinvoice_id 'ap_id',vendor_invoice_no 'vendor_invoice_no' ,job_id 'Job Id', round(sum(po_amount) + sum(po_adjustment_amount)-sum(ap_purchase_amount),2) 'AP balance', round(sum(shipcost) + sum(shipadjustment) - sum(ap_shipping_amount),2) 'ship balance' from tmpxaAPTransactions t group by job_id order by job_id";
	 rsAPFirstID = st.executeQuery(apFirstSQL);
	%>
	<!-- apFirstSQL: <%=apFirstSQL%> -->
	<%
	c=0;
	while (rsAPFirstID.next()){
		apID=rsAPFirstID.getString("ap_id");	
		vendorId=rsAPFirstID.getString("vendor_id");
	//	jobDate=rsAPFirstID.getString("ap_invoice_date");
	//	apiNotComplete=!(rsAPFirstID.getString("ap_invoice_amount").equals(rsAPFirstID.getString("applied")));
		c++;
	}
	if (c>1){
		apID="";
	}
	apVendorIdFilter=((vendorId.equals("0"))?"":" and ap.vendorid="+vendorId+" ");
	 poNoFilter=((poNo.equals("0"))?"":" and ap.vendor_invoice_no='"+poNo+"' ");
	 jobIdFilter=((jobId.equals("0"))?"":" and jobs.id="+jobId+" ");

	%>
	<!-- COMPLETED JOBS FOR THIS VENDOR WITH OPEN AP BALANCES -->
	<%

	String vendorIdFilter=((vendorId.equals("0"))?"":" and dropship_vendor="+vendorId+" ");
	String jobDateFilter=( (jobId.equals("0")) ? "jobs.order_date<'"+jobDate+"' AND ":"");
	
	//JOBS FOR THIS VENDOR
	//Present jobs where the amount owed to this vendor is not equal to the amount paid to this vendor. Use the temp table where all amounts owed to the vendor have been gathered as well as where all amounts paid to the vendor are gathered
	
	%><div class='subtitle'>Jobs for this vendor with open balances: (Where posting date >= '<%=postDateFrom%>' and <= '<%=postDateTo%>')</div>
	<table id='invoice' class='sortable' width='100%' cellpadding=2><tr><%
	//poNoFilter=((detailLines==0 || apiNotComplete )?"":poNoFilter);
	String POSQL="SELECT job_id 'K:Job^Number','' as 'B:C:Apply&nbsp;All', jobs.offline_po_number 'Offline^PO^Number', sum(po_amount)+sum(po_adjustment_amount) 'H:F:Accrued^PO^Cost',round(sum(t.ap_purchase_amount),2) 'H:AP Applied', round(((sum(po_amount)+sum(po_adjustment_amount)) - sum(t.ap_purchase_amount)),2) 'F:H:PO^Balance', concat('<input type=text name=\"ap_purchase_amount',jobs.id,'\" size=10 class=lineitemsright onChange=\"appliedPO[',jobs.id,']=this.value;newLine(',jobs.id,',','1)\">') 'Apply AP To PO Purchase', round(sum(shipcost)+sum(shipadjustment),2) 'H:Accrued^Shipping',round(sum(t.ap_shipping_amount),2) 'H:Shipping^Applied',round((sum(shipcost)+sum(shipadjustment)-sum(t.ap_shipping_amount)),2) 'F:H:Ship^Balance', concat('<input type=text name=\"ap_shipping_amount',jobs.id,'\" size=10 class=lineitemsright onChange=\"appliedShip[',jobs.id,']=this.value;newLine(',jobs.id,',','1)\">') 'Apply To^Shipping', concat('<input type=text name=\"purchase_description',jobs.id,'\" size=30 class=lineitems><br>',t.purchase_description) 'H:AP-Purchase^Description', if(jobs.quantity is null,'N/A',format(jobs.quantity,0)) 'Quantity', DATE_FORMAT(jobs.order_date, '%m/%d/%Y') 'Order^Date', DATE_FORMAT(jobs.post_date, '%m/%d/%Y')  'Post^Date', jobs.product_code 'Product^Code', jobs.status_id 'Status^ID', jobs.price 'Price', jobs.shipping_price 'Shipping^Price', jobs.dropship_vendor 'Dropship^Vendor','"+apID+"' as 'API-ID', round(((sum(shipcost)+sum(shipadjustment)+sum(t.po_amount)+sum(t.po_adjustment_amount)) - sum(t.ap_purchase_amount)-sum(t.ap_shipping_amount)),2) 'H:PO &amp; Ship Balance' from tmpxaAPTransactions t left join jobs on jobs.id=t.job_id where "+jobDateFilter+" jobs.id=jobs.id "+jobIdFilter+" group by job_id order by jobs.id";
	%>
	<!-- POSQL: <%=POSQL%> -->
	<%
	ResultSet rs = st.executeQuery(POSQL);
	ResultSetMetaData rsmd = rs.getMetaData();
	int numberOfColumns = rsmd.getColumnCount();
	tempString = null;
	Vector headers  = new Vector(15);
	%><td>&nbsp;</td><%
	for (int i=1 ;i <= numberOfColumns; i++){
		tempString = new String ((String) rsmd.getColumnLabel(i));
		headers.add(tempString);
	tempString=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring( str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempString,"H:", ""),"F:", ""),"B:", ""),"K:", ""),"C:", ""),"L:", ""),"^"," <br /> "),"-", "&nbsp;");
		x++;
		%><td  class="text-row1" ><%=tempString%></td><%
	}%></tr><%
	x=0;
	numLines=0;
	while (rs.next()){
	//if balance is zero and reportType<>All don't show
		if (reportType.equals("All") || !(rs.getDouble("H:PO &amp; Ship Balance")==0)){
		%><%
				if (reportType.equals("All") || reportType.equals("AllOpen") ||  (reportType.equals("FullOpen") && rs.getString("H:AP Applied").equals("0.00") && rs.getString("H:Shipping^Applied").equals("0.00")) ||  (reportType.equals("PartOpen") && (!(rs.getString("H:AP Applied").equals("0.00")) || !(rs.getString("H:Shipping^Applied").equals("0.00"))))  ){
		
			%><tr><%
			for (int i=0;i < numberOfColumns; i++){
				String columnName = (String) headers.get(i);
				String columnValue=((columnName.indexOf("F:")>-1)?nf.format(rs.getDouble(columnName)):((rs.getString(columnName)==null)?"":rs.getString(columnName) ));
				%><td class='text-row<%=(((x % 2) == 0)?1:2)%>' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%
				
				if(columnName.indexOf("K:")>-1){
				keyStr=columnValue;
			  %><a href="javascript:pop('/popups/PurchaseOrder.jsp?jobId=<%=keyStr%>','600','400')" class=greybutton> PO </a>
			  <a href="javascript:pop('/minders/workflowforms/InterimShipment2.jsp?jobId=<%=keyStr%>&actionId=80&closeOnExit=true',600,400)" class=greybutton> +&nbsp;Ship </a><br>
				<a href="javascript:pop('/popups/POAdjustment.jsp?jobId=<%=keyStr%>',450,300)" class=greybutton> +&nbsp;PO Adj </a><input type='hidden' name='key<%=x%>' value='<%=columnValue%>'></td><td class=lineitems><a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%=keyStr%>','800','600')"><%=columnValue%></a></td><%
				}else{%><%=((columnName.indexOf("B:")>-1)?"<span id='accept"+keyStr+"'></span><input type='checkbox' id='"+keyStr+"' value='1' onClick=\"javascript:closePO(this,'"+keyStr+"','"+keyStr+"')\" >":columnValue)%>
		<%}%><%=(((columnName.indexOf("H:")>-1))?"<input type=hidden name='"+columnName+keyStr+"' value='"+columnValue+"'>":"")%></td><%
			}
		x++;
		numLines++;
			%></tr><%
		}
		}
	}%></table><%
	if (x==0){
	//  response.sendRedirect("APEntryFormFromQuick.jsp?mode=repeat&message=No records found for this request.");
	//  return;
	%>None Found<%
	}
	%></td>
		</tr>
	  </table>
	<!-- END OPEN JOBS -->  
	
	
	<!-- OPEN AP INVOICES FOR THIS VENDOR --> 
	 <%
	String apiSQL="Select round((if(t.ap_invoice_amount is null,0,t.ap_invoice_amount)-if(max(ap.id) is null,0,sum(ap.amount))),2) 'F:Balance',t.id 'K:AP<br>Invoice Id',t.vendorid 'Vendor ID',t.vendor_invoice_no 'E1:Vendor Invoice Number',DATE_FORMAT(t.ap_invoice_date,'%m/%d/%Y') 'E2:Invoice Date', round(if(t.ap_invoice_amount is null,0,t.ap_invoice_amount),2) 'E3:Invoice Amount', round(if(max(ap.id) is null,0,sum(ap.amount)),2) 'Purchase_Amount_Total', round(if(max(ap.id) is null,0,sum(ap.ap_shipping_amount)),2) 'Shipping_Amount_Total', round(if(max(ap.id) is null, 0,sum(ap.ap_purchase_amount + ap.ap_shipping_amount)),2) 'Total_Applied',count(ap.id) 'Detail Lines' from ap_invoices t left join ap_invoice_details ap on ap.ap_invoiceid=t.id where  t.vendorid='"+vendorId+"'  and (ap.pre_accrual is null or ap.pre_accrual<>1)   group by t.id";
		%>
	<!-- APISQL: <%=apiSQL%> -->
	<%
	ResultSet rsAP = st.executeQuery(apiSQL);
	ResultSetMetaData rsmdAP = rsAP.getMetaData();
	int numberOfColumnsAP = rsmdAP.getColumnCount();
	String tempStringAP = null;
	Vector headersAP  = new Vector(15) ;
	
	%><div class=subtitle>Open AP Invoices for this Vendor</div>
	<table id='invoice' cellpadding=2><tr><td class="table-heading">&nbsp;</td><%
	
	for (int k=1 ;k <= numberOfColumnsAP; k++){
		tempStringAP = new String ((String) rsmdAP.getColumnLabel(k));
		headersAP.add(tempStringAP);
		tempStringAP=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempStringAP,"E3:", ""),"E2:", ""),"E1:", ""),"H:", ""),"F:", ""),"S:", ""),"_", " "),"R:", ""),"T:", ""),"Po:", ""),"Pr:", ""),"K:", ""),"L:", ""),"~", "&nbsp;"),"C:", "");
		x++;
		%><td  class="table-heading"><%=tempStringAP%></td><%
	}%></tr><%
	x=0;
	//detailLines=0;
	while (rsAP.next()){
		if (!(rsAP.getString("F:Balance").equals("0.00")) && !(rsAP.getString("F:Balance").equals("-0.00"))){
	//detailLines=rsAP.getDouble("Detail Lines");
		%><tr><%
		for (int i=0;i < numberOfColumnsAP; i++){		
			String columnName = (String) headersAP.get(i);
			String columnValue=((columnName.indexOf("F:")>-1)?nf.format(rsAP.getDouble(columnName)):((rsAP.getString(columnName)==null)?"":rsAP.getString(columnName) ));
			if(columnName.indexOf("K:")>-1){
				keyStr=columnValue;
		%><td><a href="javascript:applyAPLine('<%=columnValue%>','<%=vendorId%>','<%=vendorContactId%>','<%=vendorCompanyId%>')" class='greyButton' alt='USE THIS'>USE THIS&raquo;</a>&nbsp;&nbsp;</td><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%><%
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
	}
	%></table>
	<!-- END OTHER OPEN AP INVOICES -->  
	
	<input type='hidden' name='numLines' value='<%=numLines%>'>
	</form>
	<script>
		document.getElementById('appliedTotal').innerHTML=((applied=='' || applied==null)?'0':applied);
</script><%
	}catch (SQLException e){
			%><%="Error: "+e %><%
			st.executeUpdate("DROP TABLE tmpxaAPTransactions");
	}finally{
			try{st.executeUpdate("DROP TABLE tmpxaAPTransactions");}catch(Exception e){}
			submitted=false;
	}
} //if more than one ap invoice was found
} //if submitted with parameters

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
			document.getElementById('filtertoggle').innerHTML='<div align=right><div class=menuLink><a href="javascript:togglefilters()">+ Show Filters</a></div></div>';
		}else{
			document.getElementById('filtertoggle').innerHTML= <%=((!submitted)?"''":"'<div class=menuLink><a href=\"javascript:togglefilters()\">&raquo; Hide Filters</a></div>'")%>;
		}
		toggleLayer('filters');
	}
	<%= ((!submitted)?"togglefilters();":"document.getElementById('filtertoggle').innerHTML='<div align=right><div class=menuLink><a href=\"javascript:togglefilters()\">+ Show Filters</a></div></div>'") %>
	firstApplied=document.getElementById('applied').innerHTML;
</script>
</body></html>

<%
st.close();
st2.close();
conn.close();
%>