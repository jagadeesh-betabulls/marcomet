<%@ page import="java.text.*,java.io.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<%
StringTool str=new StringTool();

SimpleDateFormat df = new SimpleDateFormat("MM/dd/yyyy");
boolean excel=((request.getParameter("excel")!=null && request.getParameter("excel").equals("true"))?true:false);	
if (excel){
response.reset();
response.setHeader("Content-type","application/xls");
response.setHeader("Content-disposition","inline; filename=accrualreport.xls");
}
String headerClass=((excel)?"minderheaderleft":"text-row1");
String noLines="yes";
String reportType=((request.getParameter("reportType")==null)?"":request.getParameter("reportType"));
String reportTitle=((request.getParameter("reportTitle")==null)?"":request.getParameter("reportTitle"));
String siteId=((request.getParameter("siteId")==null)?"":request.getParameter("siteId"));
String vendorId=((request.getParameter("vendorId")==null)?"":request.getParameter("vendorId"));
String rootProdCode=((request.getParameter("rootProdCode")==null)?"":request.getParameter("rootProdCode"));
String rootGroup=((request.getParameter("rootGroup")==null)?"":request.getParameter("rootGroup"));
String buildType=((request.getParameter("buildType")==null)?"":request.getParameter("buildType"));
String preaccrual=((request.getParameter("preaccrual")==null)?"":request.getParameter("preaccrual"));
String openbalances=((request.getParameter("openbalances")==null)?"":request.getParameter("openbalances"));
String totalsonly=((request.getParameter("totalsonly")==null)?"":request.getParameter("totalsonly"));
String excelStr=((request.getParameter("excel")==null)?"":request.getParameter("excel"));
String subtotal=((request.getParameter("subtotal")==null)?"":request.getParameter("subtotal"));
String vendorCompanyText=((request.getParameter("vendorCompanyText")==null)?"":request.getParameter("vendorCompanyText"));
String siteText=((request.getParameter("siteText")==null)?"":request.getParameter("siteText"));
String dateFrom=((request.getParameter("dateFrom")==null)?"":request.getParameter("dateFrom"));
String dateTo=((request.getParameter("dateTo")==null)?"":request.getParameter("dateTo"));
String fromDate=((request.getParameter("dateFrom")==null)?"":request.getParameter("dateFrom"));
String toDate=((request.getParameter("dateTo")==null)?"":request.getParameter("dateTo"));
int rCount=0;
%><html>
	<head>
		<title><%=reportTitle%></title>
<%if (excel){%><style>
	<style>
	.Title {font-family: Helvetica, Arial, sans-serif;font-size: 12pt;color: black;font-weight: bold;border-bottom: thin solid;font-variant: normal;}
	.grid {	border: thin solid;cellspacing:0;cellpadding:3;}
	.minderheaderleft {	font-family: Arial;font-size: 10pt;font-weight: bolder;color: White;background-color: #A5A5A5;
		text-decoration: none;text-align: left;margin-top: 0px;margin-right: 0;margin-bottom: 0px;margin-left: 0px;letter-spacing: 0px;}
	.minderheadercenter {font-family: Arial;font-size: 10pt;font-weight: bolder;color: White;background-color: #A5A5A5;text-decoration: none;text-align: center;margin-top: 0px;margin-right: 0;margin-bottom: 0px;margin-left: 0px;letter-spacing: 0px;}
	.minderheaderright {font-family: Arial;font-size: 10pt;font-weight: bolder;color: White;background-color: #A5A5A5;text-decoration: none;text-align: right;margin-top: 0px;margin-right: 0;margin-bottom: 0px;margin-left: 0px;letter-spacing: 0px;}
	.lineitem {color: black;font-size: 10pt;font-weight: normal;font-family: Arial, Verdana, Geneva;text-align: left;			border: thin solid;}
	.lineitemcenter {color: black;font-size: 10pt;font-weight: normal;font-family: Arial, Verdana, Geneva;text-align: center;			border: thin solid;}
	.lineitemright {color: black;font-size: 10pt;font-weight: normal;font-family: Arial, Verdana, Geneva;text-align: right;}
	.lineitemleftalt {color: black;font-size: 10pt;font-weight: normal;font-family: Arial, Verdana, Geneva;background: #CCCCCC;text-align: left;			border: thin solid;}
	A.lineitemleftalt:hover {color: Red;}
	A.lineitemleftalt:link {color: black;}
	A.lineitemleftalt:active {color: black;border: thin solid;}
	.lineitemcenteralt {color: black;font-size: 10pt;font-weight: normal;font-family: Arial, Verdana, Geneva;background: #CCCCCC;text-align: center;border: thin solid;}
	.lineitemrightalt {color: black;font-size: 10pt;font-weight: normal;font-family: Arial, Verdana, Geneva;text-align: right;border: thin solid;}
	</style><%
}else{
%><link rel="stylesheet" type="text/css" href="/styles/master.css" title="Style" >
<link rel="stylesheet" type="text/css" href="/sitehosts/lms/styles/vendor_styles.css" title="Style" >
<script type="text/javascript" src="/javascripts/sorttable.js"></script>
<script type="text/javascript" src="/javascripts/mainlib.js"></script>
<link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
<script type="text/javascript" src="/javascripts/jscalendar/calendar.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/calendar-setup.js"></script>
<style>div#filters{margin: 0px 20px 0px 20px;display: none;}</style>
<%}%></head>
<body><%
boolean showPreAccrual=((request.getParameter("preaccrual")==null || request.getParameter("preaccrual").equals(""))?false:true);
if(!excel){%><jsp:include page="/app-admin/payments/APReportFilters.jsp" flush="true" >
	<jsp:param name="reportType" value="<%=reportType%>" />
	<jsp:param name="reportTitle" value="<%=reportTitle%>" />	
	<jsp:param name="siteId" value="<%=siteId%>" />
	<jsp:param name="vendorId" value="<%=vendorId%>" />
	<jsp:param name="rootProdCode" value="<%=rootProdCode%>" />
	<jsp:param name="rootGroup" value="<%=rootGroup%>" />
	<jsp:param name="buildType" value="<%=buildType%>" />
	<jsp:param name="preaccrual" value="<%=preaccrual%>" />
	<jsp:param name="openbalances" value="<%=openbalances%>" />
	<jsp:param name="totalsonly" value="<%=totalsonly%>" />
	<jsp:param name="excel" value="<%=excelStr%>" />
	<jsp:param name="subtotal" value="<%=subtotal%>" />
	<jsp:param name="dateFrom" value="<%=dateFrom%>" />
	<jsp:param name="dateTo" value="<%=dateTo%>" />
	<jsp:param name="vendorCompanyText" value="<%=vendorCompanyText%>" />
	<jsp:param name="siteText" value="<%=siteText%>" />
</jsp:include>
<table border=0><tr><td colspan=13>&nbsp;</td></tr>
	<tr><td class="tableheader">Site:</td><td class=lineitems><%=((request.getParameter("siteText")==null)?"":request.getParameter("siteText"))%></td></tr>
    <tr><td class="tableheader">Vendor:</td><td class='lineitems'><%=((request.getParameter("vendorCompanyText")==null || request.getParameter("vendorCompanyText").equals(""))?"All":request.getParameter("vendorCompanyText"))%></td></tr>
    <tr><td class="tableheader">Root Product:</td><td class=lineitems><%=((request.getParameter("rootProdCode")==null || request.getParameter("rootProdCode").equals(""))?"All":request.getParameter("rootProdCode"))%></td></tr>
    <tr> <td class="tableheader">Root Group:</td><td class=lineitems><%=((request.getParameter("rootGroup")==null || request.getParameter("rootGroup").equals(""))?"All":request.getParameter("rootGroup"))%></td></tr>
	<tr><td class="tableheader">Build Type:</td><td class=lineitems><%=((request.getParameter("buildType")==null || request.getParameter("buildType").equals(""))?"All":request.getParameter("buildType"))%></td></tr>
    <tr> <td class="tableheader">Additional Parameters</td><td class=lineitems><%=((request.getParameter("preaccrual")!=null && request.getParameter("preaccrual").equals("true"))?"Includes Pre-accrual Data":"Excludes Pre-accrual Data")%></td></tr>
    <tr><td class="tableheader">As Of Date:</td><td class=lineitems><%=((request.getParameter("dateFrom")==null)?"":formatter.formatMysqlDate(request.getParameter("dateFrom")))%></td></tr>
	<tr><td colspan=13>&nbsp;</td></tr></table><%
	}
%><table <%=((excel)?"class=grid":"id='invoices' class='sortable' width='100%' cellpadding=2")%> ><tr><%
boolean vendorNotChosen=(request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""));
boolean totalsOnly=(request.getParameter("totalsonly")!=null && request.getParameter("totalsonly").equals("true"));

//boolean showPreAccrual=((request.getParameter("preaccrual")!=null && request.getParameter("preaccrual").equals("true"))?true:false);
String vendorFilter = ((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":" and j.dropship_vendor='"+request.getParameter("vendorId")+"' ");
String pohVendorFilter = ((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":" and poh.vendor_id='"+request.getParameter("vendorId")+"' ");
String poaVendorFilter = ((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":" and poa.vendor_id='"+request.getParameter("vendorId")+"' ");
String apidVendorFilter = ((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":" and apid.vendorid='"+request.getParameter("vendorId")+"' ");
String shVendorFilter = ((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":" and (sh.shipping_vendor_id='"+request.getParameter("vendorId")+"' or sh.shipping_account_vendor_id='"+request.getParameter("vendorId")+"' or sh.subvendor_id='"+request.getParameter("vendorId")+"') ");

String shaVendorFilter = ((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":" and (sha.shipping_vendor_id='"+request.getParameter("vendorId")+"' or sha.shipping_account_vendor_id='"+request.getParameter("vendorId")+"' or sha.subvendor_id='"+request.getParameter("vendorId")+"') ");

String siteHostFilter = ((request.getParameter("siteHostId")==null || request.getParameter("siteHostId").equals(""))?"":" and j.jsite_host_id='"+request.getParameter("siteId")+"' ");

String rootProdFilter=((request.getParameter("rootProdCode")==null || request.getParameter("rootProdCode").equals(""))?"":" AND j.root_prod_code='"+request.getParameter("rootProdCode")+"'");
String rootGroupFilter=((request.getParameter("rootGroup")==null || request.getParameter("rootGroup").equals(""))?"":" AND pr.root_group='"+request.getParameter("rootGroup")+"'");
String buildTypeFilter=((request.getParameter("buildType")==null || request.getParameter("buildType").equals("") || request.getParameter("buildType").equals("ALL"))?"":" AND p.build_type='"+request.getParameter("buildType")+"'");
String asOfDate=request.getParameter("dateFrom");
String asOfDateTime=request.getParameter("dateFrom")+" 00:00:00";
String sortBy= ((request.getParameter("sortBy")==null || request.getParameter("sortBy").equals(""))?" order by ":" order by "+request.getParameter("sortBy"));

//SimpleConnection sc = new SimpleConnection();

Connection conn = DBConnect.getConnection();

Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
int sessionId=0;
ResultSet rsSession = st.executeQuery("Select max(sessionid) 'sid' from temp_table");
if(rsSession.next()){sessionId=rsSession.getInt("sid")+1;}
String openBalanceFilter="";
String jobSQL="Select  "+sessionId+" as 'sessionid',j.dropship_vendor 'in2',j.id 'in1',0 as 'dbl1',0 as 'dbl2',0 as 'dbl3',0 as 'dbl4',0 as 'dbl5',j.product_code 'txt1',j.product_id 'in3',j.job_name 'txt2' from jobs j where j.post_date is not null and j.post_date <='"+asOfDate+"' "+((showPreAccrual)?"":"and j.exclude_from_gl_accrual<>'1' ")+openBalanceFilter+vendorFilter+siteHostFilter+rootProdFilter+rootGroupFilter+buildTypeFilter;

jobSQL=jobSQL+" union Select "+sessionId+" as 'sessionid',j.dropship_vendor 'in2',j.id 'in1',sum(poa.adjustment_amount) 'dbl1',0 as 'dbl2',0 as 'dbl3',0 as 'dbl4',0 as 'dbl5',j.product_code 'txt1',j.product_id 'in3',j.job_name 'txt2'  from jobs j,po_transactions poa where j.id=poa.job_id and (poa.adjustment_code is null or poa.adjustment_code<>1) and poa.accrued_date <='"+asOfDate+"' "+poaVendorFilter+" group by j.id";

jobSQL=jobSQL+" union Select "+sessionId+" as 'sessionid',j.dropship_vendor 'in2',j.id 'in1',0 as 'dbl1',sum(sh.cost +sh.subvendor_handling ) 'dbl2',0 as 'dbl3',0 as 'dbl4',0 as 'dbl5',j.product_code 'txt1',j.product_id 'in3',j.job_name 'txt2'  from jobs j,shipping_data sh where sh.job_id=j.id and (sh.ignore_on_ap is null or sh.ignore_on_ap<>1) "+shVendorFilter+" and (sh.adjustment_flag is null or sh.adjustment_flag<>1)  and sh.accrued_date <='"+asOfDate+"' "+((showPreAccrual)?"":"and (pre_accrual is null or pre_accrual<>'1') ")+" group by j.id";

jobSQL=jobSQL+" union Select "+sessionId+" as 'sessionid',j.dropship_vendor 'in2',j.id 'in1',0 as 'dbl1',0 as 'dbl2',sum(sh.cost +sh.subvendor_handling ) 'dbl3',0 as 'dbl4',0 as 'dbl5',j.product_code 'txt1',j.product_id 'in3',j.job_name 'txt2'  from jobs j,shipping_data sh where sh.job_id=j.id and (sh.ignore_on_ap is null or sh.ignore_on_ap<>1) "+shVendorFilter+" and (sh.adjustment_flag is not null and sh.adjustment_flag=1) and sh.accrued_date <='"+asOfDate+"' "+((showPreAccrual)?"":"and (pre_accrual is null or pre_accrual<>'1') ")+" group by j.id";

jobSQL=jobSQL+" union Select "+sessionId+" as 'sessionid',j.dropship_vendor 'in2',j.id 'in1',0 as 'dbl1',0 as 'dbl2',0 as 'dbl3',sum(apid.ap_purchase_amount) 'dbl4',sum(apid.ap_shipping_amount) 'dbl5',j.product_code 'txt1',j.product_id 'in3',j.job_name 'txt2'  from jobs j,ap_invoice_details apid where j.id=apid.jobid "+((showPreAccrual)?"":" and (apid.pre_accrual is null or apid.pre_accrual<>'1') ") + " and apid.apinvoice_date <='"+asOfDate+"'  "+apidVendorFilter+" group by j.id";

ResultSet rsAdj = st2.executeQuery(jobSQL);
ResultSetMetaData rsmdAdj = rsAdj.getMetaData();
int numberOfAdjColumns = rsmdAdj.getColumnCount();
String tempString = null;
String vals="";
String cols="";
ArrayList headersJobs  = new ArrayList(15);
for (int i=1 ;i <= numberOfAdjColumns; i++){
	tempString = new String ((String) rsmdAdj.getColumnLabel(i));
	headersJobs.add(tempString);
	cols+=((cols.equals(""))?tempString:","+tempString);
	vals+=((vals.equals(""))?"?":",?");
}

PreparedStatement tmpJobs = conn.prepareStatement("insert into temp_table ("+cols+")  values ("+vals+")");
tmpJobs.clearParameters();

while (rsAdj.next()){
	int x=1;
	for (int i=0;i < numberOfAdjColumns; i++){
		tmpJobs.setString(x++, rsAdj.getString((String)headersJobs.get(i)));
	}
	tmpJobs.executeUpdate();
}
NumberFormat decFormatter = NumberFormat.getCurrencyInstance(Locale.US);
//DecimalFormat decFormatter = new DecimalFormat("#,###.##");
int x=0;


String stt=((request.getParameter("subtotal")==null || request.getParameter("subtotal").equals("None"))?"":request.getParameter("subtotal"));
String adjSQL="";
boolean subtotals=false;

if(stt.equals("v")){
	adjSQL="Select j.dropship_vendor 'S:Vendor #',DATE_FORMAT(post_date,'%m/%d/%y') 'Job Posting Date',j.id 'K:Job #',j.product_code 'Product Code',j.product_id 'Pr:Product ID',j.job_name 'Job Name',format(j.price,2) 'Posted Job Price', format(if(poh.adjustment_amount is null,0,poh.adjustment_amount),2) 'Accrued Job Cost',format(j.accrued_inventory_cost,2) 'Estimated Inventory Cost',format(j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount),2) 'Posted Margin before Labor',format(((j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount))/j.price),2) 'Posted Margin before Labor %',format(j.est_labor_cost,2) 'Estimated Labor Cost',j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount)-j.est_labor_cost 'Posted Gross Margin',format((j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount)-j.est_labor_cost)/j.price,2) 'Posted Gross Margin %',j.shipping_price 'Po:Posted Ship Price', format(if(sh.id is null,0,sum(sh.cost +sh.subvendor_handling )),2) 'Po:Accrued Ship Cost',j.shipping_price - if(sh.id is null,0,sum(sh.cost +sh.subvendor_handling )) 'Posted Ship Margin', format(j.shipping_price - if(sh.id is null,0,sum(sh.cost +sh.subvendor_handling ))+(j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount)-j.est_labor_cost),2) 'Posted Aggregate Job Margin',format((j.shipping_price - if(sh.id is null,0,sum(sh.cost +sh.subvendor_handling ))+(j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount)-j.est_labor_cost) )/(j.price+j.shipping_price),2) 'Posted Aggregate Job Margin %',month(post_date) 'Job Posting Month',year(post_date) 'Job Posting Year' from product_roots pr,products p,jobs j left join po_transactions poh on j.id=poh.job_id and poh.adjustment_code=1 and poh.accrued_date <='"+asOfDateTime+"' "+pohVendorFilter+" left join po_transactions poa on j.id=poa.job_id and poa.adjustment_code<>1 and poa.accrued_date <='"+asOfDate+"' "+poaVendorFilter+" left join ap_invoice_details apid on j.id=apid.jobid "+((showPreAccrual)?"":" and apid.pre_accrual<>'1' ") + " and apid.apinvoice_date <='"+asOfDate+"'  "+apidVendorFilter+" left join shipping_data sh on sh.job_id=j.id and (sh.ignore_on_ap is null or sh.ignore_on_ap<>1) "+shVendorFilter+" and sh.adjustment_flag<>1 left join shipping_data sha on sha.job_id=j.id "+((showPreAccrual)?"":"and (sha.ignore_on_ap is null or sha.ignore_on_ap<>1)")+" "+shaVendorFilter+"  and sha.adjustment_flag=1  where j.product_id=p.id and j.root_prod_code=pr.root_prod_code and j.post_date is not null and j.post_date <='"+asOfDate+"' "+((showPreAccrual)?"":"and j.exclude_from_gl_accrual<>'1' ")+vendorFilter+siteHostFilter+rootProdFilter+rootGroupFilter+buildTypeFilter+"  group by j.id order by j.dropship_vendor ,j.id";
	subtotals=true;
	
}else if(stt.equals("m")){
	adjSQL="Select concat(month(post_date),year(post_date)) 'S:Job Posting Month-Year' , j.dropship_vendor 'Vendor #',DATE_FORMAT(post_date,'%m/%d/%y') 'Job Posting Date',j.id 'K:Job #',j.product_code 'Product Code',j.product_id 'Pr:Product ID',j.job_name 'Job Name',format(j.price,2) 'Posted Job Price', format(if(poh.adjustment_amount is null,0,poh.adjustment_amount),2) 'Accrued Job Cost',format(j.accrued_inventory_cost,2) 'Estimated Inventory Cost',format(j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount),2) 'Posted Margin before Labor',format(((j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount))/j.price),2) 'Posted Margin before Labor %',format(j.est_labor_cost,2) 'Estimated Labor Cost',j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount)-j.est_labor_cost 'Posted Gross Margin',format((j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount)-j.est_labor_cost)/j.price,2) 'Posted Gross Margin %',j.shipping_price 'Po:Posted Ship Price', format(if(sh.id is null,0,sum(sh.cost +sh.subvendor_handling )),2) 'Po:Accrued Ship Cost',j.shipping_price - if(sh.id is null,0,sum(sh.cost +sh.subvendor_handling )) 'Posted Ship Margin', format(j.shipping_price - if(sh.id is null,0,sum(sh.cost +sh.subvendor_handling ))+(j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount)-j.est_labor_cost),2) 'Posted Aggregate Job Margin',format((j.shipping_price - if(sh.id is null,0,sum(sh.cost +sh.subvendor_handling ))+(j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount)-j.est_labor_cost) )/(j.price+j.shipping_price),2) 'Posted Aggregate Job Margin %' from product_roots pr,products p,jobs j left join po_transactions poh on j.id=poh.job_id and poh.adjustment_code=1 and poh.accrued_date <='"+asOfDateTime+"' "+pohVendorFilter+" left join po_transactions poa on j.id=poa.job_id and poa.adjustment_code<>1 and poa.accrued_date <='"+asOfDate+"' "+poaVendorFilter+" left join ap_invoice_details apid on j.id=apid.jobid "+((showPreAccrual)?"":" and apid.pre_accrual<>'1' ") + " and apid.apinvoice_date <='"+asOfDate+"'  "+apidVendorFilter+" left join shipping_data sh on sh.job_id=j.id and (sh.ignore_on_ap is null or sh.ignore_on_ap<>1) "+shVendorFilter+" and sh.adjustment_flag<>1 left join shipping_data sha on sha.job_id=j.id "+((showPreAccrual)?"":"and (sha.ignore_on_ap is null or sha.ignore_on_ap<>1)")+" "+shaVendorFilter+"  and sha.adjustment_flag=1  where j.product_id=p.id and j.root_prod_code=pr.root_prod_code and j.post_date is not null and j.post_date <='"+asOfDate+"' "+((showPreAccrual)?"":"and j.exclude_from_gl_accrual<>'1' ")+vendorFilter+siteHostFilter+rootProdFilter+rootGroupFilter+buildTypeFilter+"  group by j.id order by j.post_date, j.id";
	subtotals=true;
		
}else{
	adjSQL="Select j.dropship_vendor 'Vendor #',DATE_FORMAT(post_date,'%m/%d/%y') 'Job Posting Date',j.id 'K:Job #',j.product_code 'Product Code',j.product_id 'Pr:Product ID',j.job_name 'Job Name',format(j.price,2) 'Posted Job Price', format(if(poh.adjustment_amount is null,0,poh.adjustment_amount),2) 'Accrued Job Cost',format(j.accrued_inventory_cost,2) 'Estimated Inventory Cost',format(j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount),2) 'Posted Margin before Labor',format(((j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount))/j.price),2) 'Posted Margin before Labor %',format(j.est_labor_cost,2) 'Estimated Labor Cost',j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount)-j.est_labor_cost 'Posted Gross Margin',format((j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount)-j.est_labor_cost)/j.price,2) 'Posted Gross Margin %',j.shipping_price 'Po:Posted Ship Price', format(if(sh.id is null,0,sum(sh.cost +sh.subvendor_handling )),2) 'Po:Accrued Ship Cost',j.shipping_price - if(sh.id is null,0,sum(sh.cost +sh.subvendor_handling )) 'Posted Ship Margin', format(j.shipping_price - if(sh.id is null,0,sum(sh.cost +sh.subvendor_handling ))+(j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount)-j.est_labor_cost),2) 'Posted Aggregate Job Margin',format((j.shipping_price - if(sh.id is null,0,sum(sh.cost +sh.subvendor_handling ))+(j.price-if(poh.adjustment_amount is null,0,poh.adjustment_amount)-j.est_labor_cost) )/(j.price+j.shipping_price),2) 'Posted Aggregate Job Margin %',month(post_date) 'Job Posting Month',year(post_date) 'Job Posting Year' from product_roots pr,products p,jobs j left join po_transactions poh on j.id=poh.job_id and poh.adjustment_code=1 and poh.accrued_date <='"+asOfDateTime+"' "+pohVendorFilter+" left join po_transactions poa on j.id=poa.job_id and poa.adjustment_code<>1 and poa.accrued_date <='"+asOfDate+"' "+poaVendorFilter+" left join ap_invoice_details apid on j.id=apid.jobid "+((showPreAccrual)?"":" and apid.pre_accrual<>'1' ") + " and apid.apinvoice_date <='"+asOfDate+"'  "+apidVendorFilter+" left join shipping_data sh on sh.job_id=j.id and (sh.ignore_on_ap is null or sh.ignore_on_ap<>1) "+shVendorFilter+" and sh.adjustment_flag<>1 left join shipping_data sha on sha.job_id=j.id "+((showPreAccrual)?"":"and (sha.ignore_on_ap is null or sha.ignore_on_ap<>1)")+" "+shaVendorFilter+"  and sha.adjustment_flag=1  where j.product_id=p.id and j.root_prod_code=pr.root_prod_code and j.post_date is not null and j.post_date <='"+asOfDate+"' "+((showPreAccrual)?"":"and j.exclude_from_gl_accrual<>'1' ")+vendorFilter+siteHostFilter+rootProdFilter+rootGroupFilter+buildTypeFilter+"  group by j.id order by j.id";
}

%><table id='invoice' class='sortable' width='100%' cellpadding=2><%
 rsAdj = st2.executeQuery(adjSQL);
 rsmdAdj = rsAdj.getMetaData();
 numberOfAdjColumns = rsmdAdj.getColumnCount();
 tempString = null;
ArrayList headersAdj  = new ArrayList(15);
ArrayList vTotals  = new ArrayList(15);
ArrayList stTotals  = new ArrayList(15);
int hiddenCols=0;
String headerStr="<tr>";
for (int i=1 ;i <= numberOfAdjColumns; i++){
	tempString = new String ((String) rsmdAdj.getColumnLabel(i));
	String tempString2 = new String ((String) rsmdAdj.getColumnLabel(i));
	headersAdj.add(tempString);
	vTotals.add("0");
	stTotals.add("0");	
	tempString=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempString,"H:", ""),"S:", ""),"R:", ""),"T:", ""),"Po:", ""),"Pr:", ""),"K:", ""),"L:", ""),"~", "&nbsp;"),"C:", "");
	x++;
	if(tempString2.indexOf("H:")==(-1)){headerStr+="<td  class='text-row1' ><p>"+tempString+"</p></td>";}else{hiddenCols++;}
}
headerStr+="</tr>";
String subTotStr="";
boolean openBalances=true;
int c=0;
int totHeadCol=1;
int stRowCount=0;
boolean showRow=true;
String addParams="";
//If Subtotals are chosen output the subtotal row and header row 
%><%=headerStr%><%
while (rsAdj.next()){
	String keyStr="";
	for (int i=0;i < numberOfAdjColumns; i++){
	   String columnName = (String) headersAdj.get(i);
	   showRow=true;//not filtering this report for open balances
	   if (showRow){
	   	rCount++;
	    if(columnName.indexOf("H:")==-1){
		 if(((stt.equals("v") && vendorNotChosen) || (stt.equals("m"))) && subtotals && columnName.indexOf("S:")>-1 && (!subTotStr.equals(((rsAdj.getString(columnName)==null)?"0":rsAdj.getString(columnName))) )){
			if(stRowCount>0){
				%><tr><%
				for (int j=0;j < numberOfAdjColumns; j++){
					String columnNameST = (String) headersAdj.get(j);
					String totalStrSt=((columnNameST.indexOf("T:")>-1)?decFormatter.format(Double.parseDouble((String)stTotals.get(j))):"&nbsp;");
					if (j==0){
						%><td class='minderheaderright' align='right' colspan=<%=totHeadCol-hiddenCols%>><%=((totalsOnly)?"<a href=\"javascript:pop('/app-admin/payments/reports/AccrualAdjustmentsXtionReport.jsp?"+addParams+"&siteText="+request.getParameter("siteText")+"&preaccrual="+((request.getParameter("preaccrual")==null)?"":request.getParameter("preaccrual"))+"','900','800')\" class='minderLink'>&raquo;</a>":"")%>TOTALS FOR <%=((stt.equals(""))?"":((stt.equals("m"))?"ACCRUAL MONTH-YEAR ":"VENDOR ")) + subTotStr%></td><%
					}else if (j>(totHeadCol-1)){
						%><td class='<%=((columnNameST.indexOf("T:")>-1)?"lineitemsright":"minderheaderright")%>' align='right'><b><%=totalStrSt%></b></td><%		
					}
				}
				for (int m=0; m < numberOfAdjColumns; m++) {
					stTotals.set(m,"0");
				}
				%></tr><%
			
			} //if(stRowCount)
			subTotStr=((rsAdj.getString(columnName)==null)?"0":rsAdj.getString(columnName));
			addParams=((stt.equals("v"))?"vendorId="+subTotStr+"&dateTo="+toDate+"&dateFrom="+fromDate+"&vendorCompanyText="+subTotStr:"vendorId="+request.getParameter("vendorId")+"&dateTo="+(subTotStr.substring(subTotStr.indexOf("-")+1,subTotStr.length())+"-"+subTotStr.substring(0,subTotStr.indexOf("-"))+"-"+"31")+"&dateFrom="+(subTotStr.substring(subTotStr.indexOf("-")+1,subTotStr.length())+"-"+subTotStr.substring(0,subTotStr.indexOf("-"))+"-"+"01")+"&vendorCompanyText="+request.getParameter("vendorCompanyText"));
			stRowCount++;
			if (i==0){%><%=headerStr%><%}
		}else if (i==0 && !totalsOnly){%><tr><%}
		String linkStr="";
		if (columnName.indexOf("T:")>-1){
			totHeadCol=((totHeadCol==1)?i:totHeadCol);
			double tempD=rsAdj.getDouble(columnName)+Double.parseDouble((String)vTotals.get(i));
			double tempDST=rsAdj.getDouble(columnName)+Double.parseDouble((String)stTotals.get(i));				
			vTotals.set(i, Double.toString(tempD));
			stTotals.set(i, Double.toString(tempDST));
		}
		keyStr=((columnName.indexOf("K:")>-1)?rsAdj.getString(columnName):keyStr);
		if(!excel){
			linkStr=((columnName.indexOf("K:")>-1)?"<a href=\"javascript:pop('/popups/JobDetailsPage.jsp?jobId="+rsAdj.getString(columnName)+"','700','600')\" class='minderACTION'>":   ((columnName.indexOf("Pr:")>-1)?"<a href=\"javascript:pop('/popups/ProductInfo.jsp?productId="+rsAdj.getString(columnName)+"','900','800')\" class='minderACTION'>":   ((columnName.indexOf("Po:")>-1)?"<a href=\"javascript:pop('/popups/PurchaseOrder.jsp?actingRole=vendor&jobId="+keyStr+"','900','800')\" class='minderACTION'>":"")));
		}
		if(!totalsOnly){
			%><td class='text-row<%=(((x % 2) == 0)?1:2)%>' align='<%=((columnName.indexOf("R:")>-1)?"right":((columnName.indexOf("C:")>-1)?"center":"left"))%>'><%=linkStr+((rsAdj.getString(columnName)==null)?"":((columnName.indexOf("T:")>-1)?decFormatter.format(Double.parseDouble(rsAdj.getString(columnName))):rsAdj.getString(columnName)) ) +((linkStr.equals(""))?"":"</a>")%></td><%
		}		
	  }//hidden column
	 } //showrow
	} //for... columns
	x++;
	if(!totalsOnly){%></tr><%}
} //while

if( ((stt.equals("v") && vendorNotChosen) || (stt.equals("m")))  && subtotals){
	%><tr><%
	for (int j=0;j < numberOfAdjColumns; j++){
		String columnNameST = (String) headersAdj.get(j);
		String totalStrSt=((columnNameST.indexOf("T:")>-1)?decFormatter.format(Double.parseDouble((String)stTotals.get(j))):"&nbsp;");
		if (j==0){
			%><td class='minderheaderright' align='right' colspan=<%=totHeadCol-hiddenCols%>><%=((totalsOnly)?"<a href=\"javascript:pop('/app-admin/payments/reports/AccrualAdjustmentsXtionReport.jsp?"+addParams+"&siteText="+request.getParameter("siteText")+"&preaccrual="+((request.getParameter("preaccrual")==null)?"":request.getParameter("preaccrual"))+"','900','800')\" class='minderLink'>&raquo;</a>":"")%>TOTALS FOR <%=((stt.equals(""))?"":((stt.equals("m"))?"ACCRUAL MONTH-YEAR ":"VENDOR ")) + subTotStr%> </td><%
		}else if (j>(totHeadCol-1)){
			%><td class='<%=((columnNameST.indexOf("T:")>-1)?"lineitemsright":"minderheaderright")%>' align='right'><b><%=totalStrSt%></b></td><%		
		}
	}%></tr><%
}

	%><tr><%
	for (int i=0;i < numberOfAdjColumns; i++){
		String columnName = (String) headersAdj.get(i);
		String totalStr=((columnName.indexOf("T:")>-1)?decFormatter.format(Double.parseDouble((String)vTotals.get(i))):"&nbsp;");
		if (i==0){
			%><td class='minderheaderright' align='right' colspan=<%=totHeadCol-hiddenCols%>>TOTALS:</td><%
		}else if (i>(totHeadCol-1)){
			%><td class='<%=((columnName.indexOf("T:")>-1)?"lineitemsright":"minderheaderright")%>' align='right'><b><%=totalStr%></b></td><%		
		}
	}
	%></tr><%=headerStr%><%
	st.close();
	st2.close();
	conn.close();
%></tr></table><%if(!excel){%><script>
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
			document.getElementById('filtertoggle').innerHTML=<%=((rCount==0)?"''":"'<div class=menuLink><a href=\"javascript:togglefilters()\">&raquo; Hide Filters</a></div>'")%>;
		}
		toggleLayer('filters');
	}
	<%=((rCount==0)?"togglefilters();":"document.getElementById('filtertoggle').innerHTML='<div align=right><div class=menuLink><a href=\"javascript:togglefilters()\">+ Show Filters</a></div></div>'")%>
	</script><%}%></body></html>