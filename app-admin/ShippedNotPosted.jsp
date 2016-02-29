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
%><html>
	<head>
		<title>Ship Accrual Transaction Report</title>
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
<script type="text/javascript" src="/javascripts/mainlib.js"></script><%
}
%></head>
<body><%
boolean showPreAccrual=((request.getParameter("preaccrual")==null || request.getParameter("preaccrual").equals(""))?false:true);
if(!excel){%><div align=right><a class=greybutton href='javascript:history.go(-1)'>&laquo&nbsp;FILTERS&nbsp;</a><a class=greybutton href='javascript:location.href=location.href+"?excel=true"'>&nbsp;EXPORT TO EXCEL&nbsp;&raquo&nbsp;</a></div>
<table border=0><tr><td colspan=13>&nbsp;</td></tr>
	<tr><td class='Title' colspan=13>Jobs Shipped but Not Posted  Report as of <%=df.format(new java.util.Date())%></td></tr>
	<tr><td colspan=13>&nbsp;</td></tr></table><%
	}
%><table <%=((excel)?"class=grid":"id='invoices' class='sortable' width='100%' cellpadding=2")%> ><tr><%
	
String vendorFilter = ((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":" and j.dropship_vendor='"+request.getParameter("vendorId")+"' ");
String pohVendorFilter = ((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":" and poh.vendor_id='"+request.getParameter("vendorId")+"' ");
String poaVendorFilter = ((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":" and poa.vendor_id='"+request.getParameter("vendorId")+"' ");
String apidVendorFilter = ((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":" and apid.vendorid='"+request.getParameter("vendorId")+"' ");
String shVendorFilter = ((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":" and (sh.shipping_vendor_id='"+request.getParameter("vendorId")+"' or sh.shipping_account_vendor_id='"+request.getParameter("vendorId")+"' or sh.subvendor_id='"+request.getParameter("vendorId")+"') ");

String shaVendorFilter = ((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"":" and (sha.shipping_vendor_id= '"+request.getParameter("vendorId")+"' or sha.shipping_account_vendor_id='"+request.getParameter("vendorId")+"' or sha.subvendor_id='"+request.getParameter("vendorId")+"') ");

String siteHostFilter = ((request.getParameter("siteHostId")==null || request.getParameter("siteHostId").equals(""))?"":" and j.jsite_host_id='"+request.getParameter("siteId")+"' ");

String openBalanceFilter ="";// ((request.getParameter("openbalances")==null || request.getParameter("openbalances").equals(""))?"":" and Accrued_Job_Cost_Balance <> 0");

String rootProdFilter=((request.getParameter("rootProdCode")==null || request.getParameter("rootProdCode").equals(""))?"":" AND j.root_prod_code='"+request.getParameter("rootProdCode")+"'");
String rootGroupFilter=((request.getParameter("rootGroup")==null || request.getParameter("rootGroup").equals(""))?"":" AND pr.root_group='"+request.getParameter("rootGroup")+"'");
String buildTypeFilter=((request.getParameter("buildType")==null || request.getParameter("buildType").equals("") || request.getParameter("buildType").equals("ALL"))?"":" AND if(p.id is not null,p.build_type='"+request.getParameter("buildType")+"')");
String asOfDate=request.getParameter("dateFrom");
String asOfDateTime=request.getParameter("dateFrom")+" 00:00:00";

String fromDate=request.getParameter("dateFrom");
String fromDateTime=request.getParameter("dateFrom")+" 00:00:00";
String toDate=request.getParameter("dateTo");
String toDateTime=request.getParameter("dateTo")+" 23:59:59";

String sortBy= ((request.getParameter("sortBy")==null || request.getParameter("sortBy").equals(""))?" order by ":" order by "+request.getParameter("sortBy"));

Connection conn = DBConnect.getConnection();

Statement st = conn.createStatement();
Statement st2 = conn.createStatement();

DecimalFormat decFormatter = new DecimalFormat("#,###.##");

int x=0;

String adjSQL="select j.id 'K:Job #', j.price 'T:Job Price',j.billed_purchase_amount 'T:Amount Billed',  j.job_name 'Job Name',j.status_id 'Status Id', DATE_FORMAT(s.date,'%m/%d/%y') 'Ship Date',DATE_FORMAT(s.accrued_date,'%m/%d/%y') 'Accrued Shipping Date',DATE_FORMAT(j.post_date,'%m/%d/%y') 'Job Post Date',s.price 'Ship Price',(s.cost+s.subvendor_handling) 'Ship Cost' ,j.accrued_shipping 'Job Accrued Shipping Amount' from  jobs j,shipping_data s where s.job_id=j.id and  (j.post_date is  null or j.post_date='0000-00-00' ) and  (s.accrued_date is null or s.accrued_date='0000-00-00 00:00:00') order by s.date";

%><table id='invoice' class='sortable' width='100%' cellpadding=2><tr><%

ResultSet rsAdj = st2.executeQuery(adjSQL);
ResultSetMetaData rsmdAdj = rsAdj.getMetaData();
int numberOfAdjColumns = rsmdAdj.getColumnCount();
String tempString = null;
ArrayList headersAdj  = new ArrayList(15);
ArrayList vTotals  = new ArrayList(15);
int hiddenCols=0;
for (int i=1 ;i <= numberOfAdjColumns; i++){
	tempString = new String ((String) rsmdAdj.getColumnLabel(i));
	String tempString2 = new String ((String) rsmdAdj.getColumnLabel(i));
	headersAdj.add(tempString);
	vTotals.add("0");
	tempString=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempString,"R:", ""),"T:", ""),"Po:", ""),"Pr:", ""),"K:", ""),"L:", ""),"~", "&nbsp;"),"C:", "");
	x++;
	if(tempString2.indexOf("H:")==(-1)){
		%><td  class="text-row1" ><p><%=tempString%></p></td><%
	}else{
		hiddenCols++;
	}
}%></tr><%
int c=0;
int totHeadCol=1;
while (rsAdj.next()){
	%><tr><%
		String keyStr="";
	for (int i=0;i < numberOfAdjColumns; i++){
		String columnName = (String) headersAdj.get(i);
		String linkStr="";
		if (columnName.indexOf("T:")>-1){
			totHeadCol=((totHeadCol==1)?i:totHeadCol);
			double tempD=rsAdj.getDouble(columnName)+Double.parseDouble((String)vTotals.get(i));
			vTotals.set(i, Double.toString(tempD));
		}
		keyStr=((columnName.indexOf("K:")>-1)?rsAdj.getString(columnName):keyStr);
		if(!excel){
			linkStr=((columnName.indexOf("K:")>-1)?"<a href=\"javascript:pop('/popups/JobDetailsPage.jsp?jobId="+rsAdj.getString(columnName)+"','700','600')\" class='minderACTION'>":   ((columnName.indexOf("Pr:")>-1)?"<a href=\"javascript:pop('/popups/ProductInfo.jsp?productId="+rsAdj.getString(columnName)+"','900','800')\" class='minderACTION'>":   ((columnName.indexOf("Po:")>-1)?"<a href=\"javascript:pop('/popups/PurchaseOrder.jsp?actingRole=vendor&jobId="+keyStr+"','900','800')\" class='minderACTION'>":"")));
		}
		if(columnName.indexOf("H:")>-1){
		}else{
				%><td class='text-row<%=(((x % 2) == 0)?1:2)%>' align='<%=((columnName.indexOf("R:")>-1)?"right":((columnName.indexOf("C:")>-1)?"center":"left"))%>'><%=linkStr+((rsAdj.getString(columnName)==null)?"":((columnName.indexOf("T:")>-1)?decFormatter.format(Double.parseDouble(rsAdj.getString(columnName))):rsAdj.getString(columnName)) ) +((linkStr.equals(""))?"":"</a>")%></td><%
		}
	}
	x++;

	%></tr><%
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
	%></tr><%
	conn.close();
	
%></table></body></html>