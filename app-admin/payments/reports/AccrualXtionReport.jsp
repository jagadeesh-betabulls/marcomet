<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.text.*,java.io.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />

<%
StringTool str=new StringTool();
String reportTitle="Job Accrual Transaction Report (Original PO)";
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
    <tr> <td class="tableheader">Vendor:</td><td class='lineitems'><%=((request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""))?"All":sl.getValue("vendors","id",request.getParameter("vendorId"), "concat(notes,'[',id,']')"))%></td> </tr>
    <tr> <td class="tableheader">Root Product:</td><td class=lineitems><%=((request.getParameter("rootProdCode")==null || request.getParameter("rootProdCode").equals(""))?"All":request.getParameter("rootProdCode"))%></td></tr>
    <tr> <td class="tableheader">Root Group:</td><td class=lineitems><%=((request.getParameter("rootGroup")==null || request.getParameter("rootGroup").equals(""))?"All":request.getParameter("rootGroup"))%></td></tr>
    <tr> <td class="tableheader">Build Type:</td><td class=lineitems><%=((request.getParameter("buildType")==null || request.getParameter("buildType").equals(""))?"All":request.getParameter("buildType"))%></td></tr>
    <tr> <td class="tableheader">Additional Parameters</td><td class=lineitems><%=((request.getParameter("preaccrual")!=null && request.getParameter("preaccrual").equals("true"))?"Includes Pre-accrual Data":"Excludes Pre-accrual Data")%></td></tr>
    <tr><td class="tableheader">Accrued Date From:</td><td class=lineitems><%=((request.getParameter("dateFrom")==null)?"":formatter.formatMysqlDate(request.getParameter("dateFrom")))%></td></tr>
    <tr> <td class="tableheader">Accrued Date To:</td><td class=lineitems><%=((request.getParameter("dateTo")==null)?"":formatter.formatMysqlDate(request.getParameter("dateTo")))%></td></tr>
	<tr><td colspan=13>&nbsp;</td></tr></table><%
	}
%><table <%=((excel)?"class=grid":"id='invoices' class='sortable' width='100%' cellpadding=2")%> ><tr><%

boolean vendorNotChosen=(request.getParameter("vendorId")==null || request.getParameter("vendorId").equals(""));
boolean totalsOnly=(request.getParameter("totalsonly")!=null && request.getParameter("totalsonly").equals("true"));
String vendorFilter = ((vendorNotChosen)?"":" and j.dropship_vendor='"+request.getParameter("vendorId")+"' ");
String pohVendorFilter = ((vendorNotChosen)?"":" and poh.vendor_id='"+request.getParameter("vendorId")+"' ");
String poaVendorFilter = ((vendorNotChosen)?"":" and poa.vendor_id='"+request.getParameter("vendorId")+"' ");
String apidVendorFilter = ((vendorNotChosen)?"":" and apid.vendorid='"+request.getParameter("vendorId")+"' ");
String shVendorFilter = ((vendorNotChosen)?"":" and (sh.shipping_vendor_id='"+request.getParameter("vendorId")+"' or sh.shipping_account_vendor_id='"+request.getParameter("vendorId")+"' or sh.subvendor_id='"+request.getParameter("vendorId")+"') ");

String shaVendorFilter = ((vendorNotChosen)?"":" and (sha.shipping_vendor_id= '"+request.getParameter("vendorId")+"' or sha.shipping_account_vendor_id='"+request.getParameter("vendorId")+"' or sha.subvendor_id='"+request.getParameter("vendorId")+"') ");

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
NumberFormat decFormatter = NumberFormat.getCurrencyInstance(Locale.US);
//DecimalFormat decFormatter = new DecimalFormat("#,###.##");
//Populate accrued shipping
//Populate accrued job costs
//Populate APID applied
int x=0;
//Adjustment Notes	Adj Month	Adj Year
String stt=((request.getParameter("subtotal")==null || request.getParameter("subtotal").equals("None"))?"":request.getParameter("subtotal"));
String adjSQL="";
boolean subtotals=false;
if(stt.equals("v")){
	adjSQL="Select j.id 'K:H:',poa.vendor_id 'S:Vendor #',poa.id 'Po:PO #',j.product_code 'Product Code',j.product_id 'Pr:Product ID',format(j.quantity,0) 'R:Quantity',DATE_FORMAT(poa.adjustment_date,'%m/%d/%Y') 'Issue Date',DATE_FORMAT(poa.accrued_date,'%m/%d/%Y') 'Accrued Date',poa.job_id 'K:Job #',j.job_name 'Job Name',poa.adjustment_code 'Adj Code',poa.adjustment_amount 'T:R:Accrued Job Cost',month(accrued_date) 'Accrued Month',year(accrued_date) 'Accrued Year',poa.pre_accrual 'PreAccrual Flag' from po_transactions poa,jobs j left join product_roots pr on j.root_prod_code=pr.root_prod_code  left join products p on j.product_id=p.id where j.id=poa.job_id and (poa.adjustment_code is not null and poa.adjustment_code=0) and (poa.accrued_date <='"+toDateTime+"' and poa.accrued_date >='"+fromDateTime+"') "+poaVendorFilter+" "+((showPreAccrual)?"":"and (poa.pre_accrual is null or poa.pre_accrual<>'1') ")+" order by poa.vendor_id, poa.accrued_date";
	subtotals=true;
}else if(stt.equals("m")){
	adjSQL="Select j.id 'K:H:',concat(month(accrued_date),'-',year(accrued_date)) 'S:Accrued Month-Year',poa.vendor_id 'Vendor #',poa.id 'Po:PO #',j.product_code 'Product Code',j.product_id 'Pr:Product ID',format(j.quantity,0) 'R:Quantity',DATE_FORMAT(poa.adjustment_date,'%m/%d/%Y') 'Issue Date',DATE_FORMAT(poa.accrued_date,'%m/%d/%Y') 'Accrued Date',poa.job_id 'K:Job #',j.job_name 'Job Name',poa.adjustment_code 'Adj Code',poa.adjustment_amount 'T:R:Accrued Job Cost',poa.pre_accrual 'PreAccrual Flag' from po_transactions poa,jobs j left join product_roots pr on j.root_prod_code=pr.root_prod_code  left join products p on j.product_id=p.id where j.id=poa.job_id and (poa.adjustment_code is not null and poa.adjustment_code=0) and (poa.accrued_date <='"+toDateTime+"' and poa.accrued_date >='"+fromDateTime+"') "+poaVendorFilter+" "+((showPreAccrual)?"":"and (poa.pre_accrual is null or poa.pre_accrual<>'1') ")+" order by poa.accrued_date";
	subtotals=true;
}else{
	adjSQL="Select j.id 'K:H:',poa.vendor_id 'Vendor #',poa.id 'Po:PO #',j.product_code 'Product Code',j.product_id 'Pr:Product ID',format(j.quantity,0) 'R:Quantity',DATE_FORMAT(poa.adjustment_date,'%m/%d/%Y') 'Issue Date',DATE_FORMAT(poa.accrued_date,'%m/%d/%Y') 'Accrued Date',poa.job_id 'K:Job #',j.job_name 'Job Name',poa.adjustment_code 'Adj Code',poa.adjustment_amount 'T:R:Accrued Job Cost',month(accrued_date) 'Accrued Month',year(accrued_date) 'Accrued Year',poa.pre_accrual 'PreAccrual Flag' from po_transactions poa,jobs j left join product_roots pr on j.root_prod_code=pr.root_prod_code  left join products p on j.product_id=p.id where j.id=poa.job_id and (poa.adjustment_code is not null and poa.adjustment_code=0) and (poa.accrued_date <='"+toDateTime+"' and poa.accrued_date >='"+fromDateTime+"') "+poaVendorFilter+" "+((showPreAccrual)?"":"and (poa.pre_accrual is null or poa.pre_accrual<>'1') ")+" order by poa.accrued_date";

}

%><table id='invoice' class='sortable' width='100%' cellpadding=2><%
ResultSet rsAdj = st2.executeQuery(adjSQL);
ResultSetMetaData rsmdAdj = rsAdj.getMetaData();
int numberOfAdjColumns = rsmdAdj.getColumnCount();
String tempString = null;
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
	   	keyStr=((columnName.indexOf("K:")>-1)?rsAdj.getString(columnName):keyStr);
	    if(columnName.indexOf("H:")==-1){
		 if(((stt.equals("v") && vendorNotChosen) || (stt.equals("m"))) && subtotals && columnName.indexOf("S:")>-1 && (!subTotStr.equals(((rsAdj.getString(columnName)==null)?"0":rsAdj.getString(columnName))) )){
			if(stRowCount>0){
				%><tr><%
				for (int j=0;j < numberOfAdjColumns; j++){
					String columnNameST = (String) headersAdj.get(j);
					String totalStrSt=((columnNameST.indexOf("T:")>-1)?decFormatter.format(Double.parseDouble((String)stTotals.get(j))):"&nbsp;");
					if (j==0){
						%><td class='minderheaderright' align='right' colspan=<%=totHeadCol-hiddenCols%>><%=((totalsOnly)?"<a href=\"javascript:pop('/app-admin/payments/reports/AccrualXtionReport.jsp?"+addParams+"&siteText="+request.getParameter("siteText")+"&preaccrual="+((request.getParameter("preaccrual")==null)?"":request.getParameter("preaccrual"))+"','900','800')\" class='minderLink'>&raquo;</a>":"")%>TOTALS FOR <%=((stt.equals(""))?"":((stt.equals("m"))?"ACCRUAL MONTH-YEAR "+subTotStr:"VENDOR "+ sl.getValue("vendors","id",subTotStr, "concat(notes,'[',id,']')")))%></td><%
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
			%><td class='minderheaderright' align='right' colspan=<%=totHeadCol-hiddenCols%>><%=((totalsOnly)?"<a href=\"javascript:pop('/app-admin/payments/reports/AccrualXtionReport.jsp?"+addParams+"&siteText="+request.getParameter("siteText")+"&preaccrual="+((request.getParameter("preaccrual")==null)?"":request.getParameter("preaccrual"))+"','900','800')\" class='minderLink'>&raquo;</a>":"")%>TOTALS FOR <%=((stt.equals(""))?"":((stt.equals("m"))?"ACCRUAL MONTH-YEAR "+subTotStr:"VENDOR "+ sl.getValue("vendors","id",subTotStr, "concat(notes,'[',id,']')")))%> </td><%
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
%></table><%if (!excel){%><script>
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