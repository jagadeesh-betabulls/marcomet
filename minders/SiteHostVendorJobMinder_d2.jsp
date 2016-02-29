<%@ page errorPage="/errors/ExceptionPage.jsp" %><%@ page import="java.sql.*,java.util.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.jdbc.*;
" %><%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %><%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" /><% UserProfile up = (UserProfile)session.getAttribute("userProfile");
   SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
String sql;
String vendorRepFilter = "";
String boFilter="";
String vendorRepSupv = "";
String onlySubVendor = "";
String jobTypeFilter = "";
String rootProdFilter = "";
String designFilter = "";
String companyFilter = "";
String siteHostFilter = "";
String vendorFilter = "";
String subvendorFilter = "";
String warehouseFilter = "";
String archiveFilter = "";
String collectedFilter = "";
String jobnumberFilter = "";
String mndrJobNumber="";
String actionFilter = "";
String linkedjobsFilter = "";
String sortFilter = "";
String sitenumberFilter="";
String sitenumberEntry="";
String fmd2Query="";
String fmd2Add1=",jobs j ";
String fmd2Add2="";
String jobNotes="";
String jobRole="buyer";
String jobLink="&nbsp;";

boolean alt = true;
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();

try{
if (request.getParameter("companyFilter") != null) {
   companyFilter = request.getParameter("companyFilter");
   session.setAttribute("companyFilter", request.getParameter("companyFilter"));
} else if (session.getAttribute("companyFilter") != null) {
   companyFilter = (String)session.getAttribute("companyFilter");
} else {
   companyFilter = " AND 1 = 1 ";
   session.setAttribute("companyFilter", " AND 1 = 1 ");
}
if (request.getParameter("vendorFilter") != null) {
   vendorFilter = request.getParameter("vendorFilter");
   session.setAttribute("vendorFilter", request.getParameter("vendorFilter"));
} else if (session.getAttribute("vendorFilter") != null) {
   vendorFilter = (String)session.getAttribute("vendorFilter");
} else {
   vendorFilter = " AND 1 = 1 ";
   session.setAttribute("vendorFilter", " AND 1 = 1 ");
}
if (request.getParameter("subvendorFilter") != null) {
   subvendorFilter = request.getParameter("subvendorFilter");
   session.setAttribute("subvendorFilter", request.getParameter("subvendorFilter"));
} else if (session.getAttribute("subvendorFilter") != null) {
   subvendorFilter = (String)session.getAttribute("subvendorFilter");
} else {
   subvendorFilter = "  1 = 1 ";
   session.setAttribute("subvendorFilter", " 1 = 1 ");
}

if (request.getParameter("warehouseFilter") != null) {
   warehouseFilter = request.getParameter("warehouseFilter");
   session.setAttribute("warehouseFilter", request.getParameter("warehouseFilter"));
} else if (session.getAttribute("warehouseFilter") != null) {
   warehouseFilter = (String)session.getAttribute("warehouseFilter");
} else {
   warehouseFilter = "  1 = 1 ";
   session.setAttribute("warehouseFilter", " 1 = 1 ");
}

if (request.getParameter("boFilter") != null) {
   boFilter = request.getParameter("boFilter");
   session.setAttribute("boFilter", request.getParameter("boFilter"));
} else if (session.getAttribute("boFilter") != null) {
   boFilter = (String)session.getAttribute("boFilter");
} else {
   boFilter = " ";
   session.setAttribute("boFilter", " ");
}


if (request.getParameter("sitenumberEntry") != null) {
   sitenumberEntry = request.getParameter("sitenumberEntry");
   session.setAttribute("sitenumberEntry", request.getParameter("sitenumberEntry"));
} else if (session.getAttribute("sitenumberEntry") != null) {
   sitenumberEntry = (String)session.getAttribute("sitenumberEntry");
} else {
   sitenumberEntry = "";
   session.setAttribute("sitenumberEntry", "");
}

if (sitenumberEntry.equals("")) {
	   sitenumberFilter = " AND 1 = 1 ";
	}else{
   		sitenumberFilter = " AND c.default_site_number = '"+sitenumberEntry+"' ";
}

if (request.getParameter("vendorRepFilter") != null) {
   vendorRepFilter = request.getParameter("vendorRepFilter");
   session.setAttribute("vendorRepFilter", request.getParameter("vendorRepFilter"));
} else if (session.getAttribute("vendorRepFilter") != null) {
   vendorRepFilter = (String)session.getAttribute("vendorRepFilter");
} else {
   vendorRepFilter = " AND 1 = 0 ";
   session.setAttribute("vendorRepFilter", " AND 1 = 0 ");
}
if (request.getParameter("jobTypeFilter") != null) {
   jobTypeFilter = request.getParameter("jobTypeFilter");
   session.setAttribute("jobTypeFilter", request.getParameter("jobTypeFilter"));
} else if (session.getAttribute("jobTypeFilter") != null) {
   jobTypeFilter = (String)session.getAttribute("jobTypeFilter");
} else {
   jobTypeFilter = " AND 1 = 1 ";
   session.setAttribute("jobTypeFilter", " AND 1 = 1 ");
}
if (request.getParameter("rootProdFilter") != null) {
   rootProdFilter = request.getParameter("rootProdFilter");
   session.setAttribute("rootProdFilter", request.getParameter("rootProdFilter"));
} else if (session.getAttribute("rootProdFilter") != null) {
   rootProdFilter = (String)session.getAttribute("rootProdFilter");
} else {
   rootProdFilter = " AND 1 = 1 ";
   session.setAttribute("rootProdFilter", " AND 1 = 1 ");
}
if (request.getParameter("archiveFilter") != null) {
   archiveFilter = request.getParameter("archiveFilter");
   session.setAttribute("archiveFilter", request.getParameter("archiveFilter"));
} else if (session.getAttribute("archiveFilter") != null) {
   archiveFilter = (String)session.getAttribute("archiveFilter");
} else {
   archiveFilter = " AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ";
   session.setAttribute("archiveFilter", " AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ");
}
if (request.getParameter("collectedFilter") != null) {
   collectedFilter = request.getParameter("collectedFilter");
   session.setAttribute("collectedFilter", request.getParameter("collectedFilter"));
} else if (session.getAttribute("collectedFilter") != null) {
   collectedFilter = (String)session.getAttribute("collectedFilter");
} else {
   collectedFilter = " AND 1 = 1 ";
   session.setAttribute("collectedFilter", " AND 1 = 1 ");
}
if (request.getParameter("siteHostFilter") != null) {
   siteHostFilter = request.getParameter("siteHostFilter");
   session.setAttribute("siteHostFilter", request.getParameter("siteHostFilter"));
} else if (session.getAttribute("siteHostFilter") != null) {
   siteHostFilter = (String)session.getAttribute("siteHostFilter");
} else {
   siteHostFilter = " AND 1 = 1 ";
   session.setAttribute("siteHostFilter", " AND 1 = 1 ");
}

mndrJobNumber=((request.getParameter("mndrJobNumber")== null)?((session.getAttribute("mndrJobNumber") == null)?"":session.getAttribute("mndrJobNumber").toString()):request.getParameter("mndrJobNumber"));
session.setAttribute("mndrJobNumber", mndrJobNumber);

linkedjobsFilter=((request.getParameter("linkedjobsFilter")== null)?((session.getAttribute("linkedjobsFilter") == null)?"":session.getAttribute("linkedjobsFilter").toString()):request.getParameter("linkedjobsFilter"));
session.setAttribute("linkedjobsFilter", linkedjobsFilter);

jobnumberFilter = ((mndrJobNumber.equals(""))?"":" AND (j.id = "+ mndrJobNumber + 
((linkedjobsFilter.equals("YES"))?" OR j.job_link = " + mndrJobNumber+") ":")"));

if (request.getParameter("sortFilter") != null) {
   sortFilter = request.getParameter("sortFilter");
   session.setAttribute("sortFilter", request.getParameter("sortFilter"));
} else if (session.getAttribute("sortFilter") != null) {
   sortFilter = (String)session.getAttribute("sortFilter");
} else {
   sortFilter = " ORDER BY o.date_created, j.project_id, j.id DESC";
   session.setAttribute("sortFilter", " ORDER BY o.date_created, j.project_id, j.id DESC");
}
if (request.getParameter("designFilter") != null) {
   designFilter = request.getParameter("designFilter");
   session.setAttribute("designFilter", request.getParameter("designFilter"));
} else if (session.getAttribute("designFilter") != null) {
   designFilter = (String)session.getAttribute("designFilter");
} else {
   designFilter = " AND 1 = 1 ";
   session.setAttribute("designFilter", " AND 1 = 1 ");
}

if (request.getParameter("actionFilter") != null) {
   actionFilter = request.getParameter("actionFilter");
   session.setAttribute("actionFilter", request.getParameter("actionFilter"));
} else if (session.getAttribute("actionFilter") != null) {
   actionFilter = (String)session.getAttribute("actionFilter");
} else {
   actionFilter = " AND 1 = 1 ";
   session.setAttribute("actionFilter", " AND 1 = 1 ");
}
	 %><html>
<head>
  <title>Site Host Vendor Job Minder</title>
  <meta http-equiv="Content-Type" content="text/html;
 charset=iso-8859-1">
  <link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
  <link rel="stylesheet" href="<%=shs.getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib2.js"></script>
<style>
	div#filters{
margin: 0px 20px 0px 20px;
display: none;
}</style>
</head>
<body background="<%=shs.getSiteHostRoot()%>/images/back3.jpg" topmargin="0">
<span id='loading'><div align='center'> L O A D I N G . . .<br><br><img src='/images/loading.gif'><br></div></span><div id='filtertoggle' ></div><div id='filters'><%@ include file='/includes/shvminderfilters_d.jsp' %></div>
<script>
	function toggleLayer(whichLayer){
		var style2 = document.getElementById(whichLayer).style;
		style2.display = style2.display=="block"? "none":"block";
	}
	function togglefilters(){
		var style2 = document.getElementById('filters').style;
		if (style2.display=="block"){
			document.getElementById('filtertoggle').innerHTML='<div class=menuLink><a href="javascript:togglefilters()">+ Show Filters</a></div>';
		}else{
			document.getElementById('filtertoggle').innerHTML='<div class=menuLink><a href=\"javascript:togglefilters()\">&raquo; Hide Filters</a></div>';
		}
		toggleLayer('filters');
	}
	togglefilters();
</script>
<%
//long query for the minder
//if the action filter is set to show jobs with files that need to be submitted need to run query twice and exclude the jobs that have files submitted.
	StringBuffer filterSQL = new StringBuffer();
	StringBuffer minderQuery = new StringBuffer();
	StringBuffer minderFilterQuery = new StringBuffer();
	if (jobnumberFilter.equals("") && !(actionFilter.equals(""))){
		 fmd2Query=((actionFilter.indexOf("fmd2")>0)?" and fmd.status='Final' ":"");
		 fmd2Add1=((actionFilter.indexOf("fmd2")>0)?",file_meta_data fmd2,jobs j ":",jobs j ");
		 fmd2Add2=((actionFilter.indexOf("fmd2")>0)?" fmd2.job_id=j.id AND ":"");		
	}
	String baseSQL = "SELECT j.product_id, o.id 'order_id', DATE_FORMAT(o.date_created,'%m/%d/%y') 'creation_date', j.id 'job_id', j.job_name 'job_name', ljt.value 'job_type', lst.value 'service_type', j.status_id 'status_id', j.billable 'invoice', j.billed, j.collected 'collected', j.escrow_amount 'escrow', jfs.shownstatus 'shown_status', CONCAT(c.firstname,' ',c.lastname) 'customer', j.balance_to_vendor 'vendorbalance', j.balance_to_site_host 'sitehostbalance', consolereseller, consolecustomer, actionform, whosaction, sh.abbreviation 'sitehost',c2.company_name 'sitehostname', p.id 'projectnumber', c.default_site_number sitenumber, c.default_pm_site_number pmsitenumber, c.id 'customerid', o.site_host_contact_id 'sitehostcontactid', j.vendor_company_id 'vendor_company_id', if(j.vendor_notes is null,'',j.vendor_notes) 'internalref', j.subvendor_reference_data 'subvendorref', j.vendor_contact_id 'vendorcontactid', c1.company_name 'vendor', j.buyer_internal_reference_data, j.job_link, o.buyer_contact_id, o.buyer_company_id, c3.company_name 'buyercompany', j.root_prod_code, if(j.quantity  is null,'',j.quantity) 'quantity',if(j.dropship_vendor is null,'0',j.dropship_vendor) 'dropship_vendor',if(prod.inv_on_order_amount>prod.inventory_amount and prod.inventory_product_flag=1,1,0) 'bo_status',prod.inv_on_order_amount 'on_order',prod.inventory_amount 'inv_amount',prod.backorder_notes 'bo_notes',prod.default_warehouse_id 'wh_number' FROM orders o, projects p, contacts c, jobflowstates jfs, lu_job_types ljt, lu_service_types lst, vendors v, companies c1, companies c2, companies c3, site_hosts sh, job_specs js"+fmd2Add1+" ";
	
	minderQuery.append(baseSQL);	
	minderFilterQuery.append(baseSQL);	
if (jobnumberFilter.equals("") && !(actionFilter.equals(""))){
	minderQuery.append(" LEFT JOIN file_meta_data fmd on j.id=fmd.job_id "+fmd2Query);
	minderFilterQuery.append(" LEFT JOIN file_meta_data fmd on j.id=fmd.job_id "+fmd2Query);
	
}
minderQuery.append(" LEFT JOIN vendors sv on j.dropship_vendor=sv.id LEFT JOIN products prod ON j.product_id = prod.id ");
minderFilterQuery.append(" LEFT JOIN vendors sv on j.dropship_vendor=sv.id LEFT JOIN products prod ON j.product_id = prod.id ");
String endSQL=" WHERE "+fmd2Add2+" o.id = p.order_id AND p.id = j.project_id AND o.buyer_contact_id = c.id AND j.status_id = jfs.statusnumber AND j.service_type_id = lst.id AND j.job_type_id = ljt.id AND o.site_host_id = sh.id AND v.company_id = c1.id AND sh.company_id = c2.id AND c.companyid=c3.id AND j.vendor_id = v.id AND js.job_id=j.id AND ((site_host_id = " + shs.getSiteHostId() + " OR j.vendor_company_id = " + up.getCompanyId() + ") OR o.buyer_company_id = " + up.getCompanyId() + ") ";
minderQuery.append(endSQL);
minderFilterQuery.append(endSQL);
if (!jobnumberFilter.equals("")){
	minderQuery.append(jobnumberFilter);
	minderQuery.append(" GROUP BY j.id");
}else{
	if (!actionFilter.equals(" AND ((fmd.category='For Appvl' and (fmd.status='Submitted' or fmd.Status='Accepted')))  ")){
		minderQuery.append(actionFilter);
	}else{
		minderFilterQuery.append(actionFilter);
	}
	filterSQL.append(((collectedFilter.equals(" AND 1 = 1 "))?"":collectedFilter));
	filterSQL.append(boFilter);
	filterSQL.append(((archiveFilter.equals(" AND 1 = 1 "))?"":archiveFilter));
	filterSQL.append(((vendorRepFilter.equals(" AND 1 = 1 "))?"":vendorRepFilter));
	filterSQL.append(((siteHostFilter.equals(" AND 1 = 1 "))?"":siteHostFilter));
	filterSQL.append(((sitenumberFilter.equals(" AND 1 = 1 "))?"":sitenumberFilter));
	filterSQL.append(((companyFilter.equals(" AND 1 = 1 "))?"":companyFilter));
	filterSQL.append(((rootProdFilter.equals(" AND 1 = 1 "))?"":rootProdFilter));
	filterSQL.append(((vendorFilter.equals(" AND 1 = 1 "))?"":vendorFilter));
	filterSQL.append(((designFilter.equals(" AND 1 = 1 "))?"":designFilter));
	filterSQL.append(((jobTypeFilter.equals(" AND 1 = 1 "))?"":jobTypeFilter));
	String shipperFilter=((subvendorFilter.equals(" 1 = 1 ") || subvendorFilter.equals(""))?"":subvendorFilter+((warehouseFilter.equals(" 1 = 1 ") || warehouseFilter.equals(""))?"":" AND "))+((warehouseFilter.equals(" 1 = 1 ") || warehouseFilter.equals(""))?"":warehouseFilter);
	filterSQL.append(((shipperFilter.equals(""))?"":" AND ( "+shipperFilter+") "));
	filterSQL.append(" GROUP BY j.id");
	filterSQL.append(sortFilter);
	minderQuery.append(filterSQL);
	minderFilterQuery.append(filterSQL);
	session.setAttribute("minderQuery",filterSQL);
}
Vector filterJobs = new Vector();
if (jobnumberFilter.equals("") && actionFilter.equals(" AND ((fmd.category='For Appvl' and (fmd.status='Submitted' or fmd.Status='Accepted')))  ")){
	ResultSet minderFRS = st.executeQuery(minderFilterQuery.toString());
	while (minderFRS.next()) {
		filterJobs.addElement(minderFRS.getString("job_id"));
	}
}

%><!-- <%=minderQuery.toString()%> --><%
ResultSet minderRS = st.executeQuery(minderQuery.toString());
request.setAttribute("minderRS", minderRS);
//=minderQuery
int i = 0;
%><iterate:dbiterate name="minderRS" id="k"><%
//unless this job is part of the set ot be filtered out of the display...
if(filterJobs.indexOf(minderRS.getString("job_id"))==-1){
	if (i==0){
		//table header
		%><div id="cdets" class="tip" style="width:80">Click for contact details</div><div id="jdets" class="tip" style="width:80">Click for job details</div><div id="jname" class="tip" style="width:80">Click to Edit Job Name</div><div id="po" class="tip" style="width:90">Click to Display PO Details</div><div id="appv" class="tip" style="width:90">Click to Approve Comp File</div><table cellspacing="0" cellpadding="3" width="100%" border="1" bordercolor="#000000">
		  <tr bordercolor="#000000"> 
		<td class="minderheaderleft"   height="0" width="0">Client</td>
		<td class="minderheaderleft"   height="0" width="0">Site Host</td>
		<td class="minderheaderleft"   height="0" width="0">Vendor</td>
		<!--
		<td class="minderheadercenter" height="0" width="0">Order</td> -->
		<td class="minderheaderleft"   height="0" width="0">Order<br>Date</td>
		<!--
		<td class="minderheaderleft"   height="0" width="0">Proj.</td> -->
		<td class="minderheadercenter" height="0" width="0">Job</td>
		<td class="minderheaderleft"   height="0" width="0">Vendor Notes</td>
		<td class="minderheaderleft"   height="0" width="0">Job Name</td>
		<!--
		<td class="minderheaderleft"   height="0" width="0">Service</td> -->
		<td class="minderheaderright"  height="0" width="0" nowrap>Total<br>Billed<br>Collected</td>
		<td class="minderheaderright"  height="0" width="0">Subcon/<br>Sub&nbsp;Ref&nbsp;#</td>
		<td class="minderheadercenter" height="0" width="0">Status</td>
		<td class="minderheadercenter" height="0" width="0">Actions Items</td>
		<td class="minderheadercenter" height="0" width="0">Other Actions</td>
		  </tr><%
	}
	//set tooltips for this job
	%><div id="sh<%=i%>" class="tip" style="width:120"><$ sitehostname $>, Click for contact details</div><%
	if (minderRS.getString("internalref")!=null && !(minderRS.getString("internalref").equals(""))){
	%><div id="jn<%=i%>" class="tip"><em>Click to add a note</em><hr><%=minderRS.getString("internalref")%></div><%
	}
	if (minderRS.getInt("buyer_company_id") == Integer.parseInt((String)up.getCompanyId()) ) { 
			jobRole="&actingRole=buyer";
	}else{
		jobRole="";
	}
   alt = (alt)?false:true;
   %><tr><%
//set job notes display
if (minderRS.getString("internalref")==null || minderRS.getString("internalref").equals("")){
	jobNotes="<a href=\"javascript:popw('/popups/QuickChangeAppendForm.jsp?tableName=jobs&columnName=vendor_notes&valueType=String&question=Edit%20Vendor%20Notes&rows=5&cols=40&update=n&primaryKeyValue="+minderRS.getString("job_id")+"', '500', '500')\" class='minderlink'>&raquo; Add Note</a>";

}else{
	jobNotes="<a href=\"javascript:pop('/popups/QuickChangeAppendForm.jsp?tableName=jobs&columnName=vendor_notes&valueType=String&question=Edit%20Vendor%20Notes&rows=5&cols=40&update=n&primaryKeyValue="+minderRS.getString("job_id")+"', '500', '500')\" onmouseout=\"popUpTT(event,'jn"+i+"')\" onmouseover=\"popUpTT(event,'jn"+i+"')\" class='minderlink'>"+minderRS.getString("internalref").substring(0,((minderRS.getString("internalref").indexOf("</div>")==-1)?100:minderRS.getString("internalref").indexOf("</div>")))+"</a>";
}

// customer and buyer reference number
%><td class="lineitemleft<%=(alt)?"alt":""%>"><a href="javascript:pop('/popups/PersonProfilePage.jsp?personId=<$ customerid $>','650','450')" class="minderLink" onmouseout="popUpTT(event,'cdets')" onmouseover="popUpTT(event,'cdets')"><$ buyercompany $><%=((minderRS.getString("sitenumber")==null || minderRS.getString("sitenumber").equals("") || minderRS.getString("sitenumber").equals("0"))?"":", Site #:&nbsp;"+minderRS.getString("sitenumber"))%><%=((minderRS.getString("pmsitenumber")==null || minderRS.getString("pmsitenumber").equals("") || minderRS.getString("pmsitenumber").equals("0"))?"":", PM&nbsp;Site #:&nbsp;"+minderRS.getString("pmsitenumber"))%><br><$ customer $></a><%=((minderRS.getString("buyer_internal_reference_data") == null || minderRS.getString("buyer_internal_reference_data").equals(""))?"":"<br>Buyer&nbsp;Ref&nbsp;#"+minderRS.getString("buyer_internal_reference_data") )%></td><%

// site 
%><td class="lineitemleft<%=(alt)?"alt":""%>"><a href="javascript:pop('/popups/PersonProfilePage.jsp?personId=<$ sitehostcontactid $>','650','450')" class="minderLink" onmouseout="popUpTT(event,'sh<%=i%>')" onmouseover="popUpTT(event,'sh<%=i%>')"><$ sitehost $></a></td><%

//Vendor
%><td class="lineitemleft<%=(alt)?"alt":""%>"><a href="javascript:pop('/popups/PersonProfilePage.jsp?personId=<$ vendorcontactid $>','650','450')" class="minderLink" onmouseout="popUpTT(event,'cdets')" onmouseover="popUpTT(event,'cdets')"><$ vendor $><br><$ vendorcontactid $></a></td>
<td class="lineitemcenter<%=(alt)?"alt":""%>"><%=minderRS.getString("creation_date")%></td><%

//job number
//job link
jobLink=((minderRS.getString("job_link").equals("0"))?"&nbsp;":"<br>Linked&nbsp;to:<br><a class='minderLink'  href=\"javascript:pop('/popups/JobDetailsPage.jsp?jobId=<$ job_link $>"+jobRole+"','700','600')\" onmouseout=\"popUpTT(event,'jdets')\" onmouseover=\"popUpTT(event,'jdets')\">"+minderRS.getString("job_link"));
	%><td class="lineitemcenter<%=(alt)?"alt":""%>"><a class="minderLink"  href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<$ job_id $><%=jobRole%>','700','600')" onmouseout="popUpTT(event,'jdets')" onmouseover="popUpTT(event,'jdets')"><$ job_id $></a><%=jobLink%></td><%

//vendor notes
%><td class="lineitemleft<%=(alt)?"alt":""%>"><%=((minderRS.getString("bo_status").equals("1"))?"<span style='color:red;'>Backordered:On order="+minderRS.getString("on_order")+", Inv Amount="+minderRS.getString("inv_amount")+", BO Message:"+((minderRS.getString("bo_notes")==null || minderRS.getString("bo_notes").equals(""))?"Default":minderRS.getString("bo_notes"))+"</span><br>":"")%><%=jobNotes%>&nbsp;</td><%

//Job Name
%><td class="lineitemleft<%=(alt)?"alt":""%>"><a href="javascript:pop('/popups/QuickChangeForm.jsp?tableName=jobs&columnName=job_name&valueType=String&question=Edit%20Job%20Name%20value&rows=1&cols=30&primaryKeyValue=<$ job_id $>', '350', '150')" class="minderLink" onmouseout="popUpTT(event,'jname')" onmouseover="popUpTT(event,'jname')"><$ job_name $></a><br><%=(minderRS.getString("quantity")!=null&&minderRS.getString("quantity")!="")?"Qty: " +(minderRS.getString("quantity")):("")%></td><%

// job amounts
	%><td class="lineitemright<%=(alt)?"alt\"":"\""%>><%=formatter.getCurrency(minderRS.getDouble("invoice"))%><br><%=formatter.getCurrency(minderRS.getDouble("billed"))%><br><%=formatter.getCurrency(minderRS.getDouble("collected"))%></td>
<td class="lineitemcenter<%=(alt)?"alt\"":"\""%> nowrap>&nbsp;&nbsp;
<%=((minderRS.getString("dropship_vendor")==null || minderRS.getString("dropship_vendor").equals("") || minderRS.getString("dropship_vendor").equals("0"))?"<a href='javascript:popw(\"/popups/QuickChangeDropDown.jsp?question=Change%20SubVendor&primaryKeyValue="+minderRS.getString("job_id")+"&columnName=dropship_vendor&tableName=jobs&luTableName=vendors&valueType=int&valueField=id&textField=notes&compField=subvendor&compValue=1&orderBy=notes\",300,150)' class=minderLink>&raquo;Add PO</a>":"<a class='minderLink' href=\"javascript:pop('/popups/PurchaseOrder.jsp?jobId="+minderRS.getString("job_id")+"&actingRole=vendor','900','700')\" class='minderLink' onmouseout=\"popUpTT(event,'po')\" onmouseover=\"popUpTT(event,'po')\"><b>Print&nbsp;PO:<br></b>SubCon#"+minderRS.getString("dropship_vendor")+"</a>"+((minderRS.getString("subvendorref").equals(""))?"":"<br>Ref&nbsp;#&nbsp;"+minderRS.getString("subvendorref")))%><br>WH#:<%=minderRS.getString("wh_number")%></td><%

//job status
	%><td class="lineitemcenter<%=(alt)?"alt":""%>"><$ shown_status $></td><%
	
//Next Action --
	 if (jobRole.equals("&actingRole=buyer")) { 
	%><td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><% boolean makeBreak = false;
   if (minderRS.getInt("whosaction") == 1) { 
	%><a class="minderACTION" href="<$ actionform $>?jobId=<$ job_id $>" class="lineitemright<%=(alt)?"alt\"":"\""%><b><$ consolecustomer $></b></a><%
	 } else { 
	%><$ consolecustomer $><%
	   }
   if (minderRS.getString("consolecustomer") != null && !minderRS.getString("consolecustomer").equals("")) makeBreak = true;
	 
  String compQuery = "SELECT a.group_id FROM form_messages a LEFT OUTER JOIN form_messages b on a.job_id = b.job_id AND a.group_id = b.group_id AND ((a.form_id = 1 OR a.form_id = 2) AND b.form_id = 8) WHERE (a.form_id = 1 OR a.form_id = 2) AND b.group_id IS NULL AND a.job_id = " + minderRS.getString("job_id");%><!-- <%=minderQuery.toString()%> --><%
   ResultSet compRS = st2.executeQuery(compQuery);
   while (compRS.next()) { 
	%><a class="minderACTION" href="/minders/workflowforms/AdHocApproveCompProof.jsp?groupId=<%=compRS.getInt("group_id")%>&jobId=<$ job_id $>" onmouseout="popUpTT(event,'appv')" onmouseover="popUpTT(event,'appv')"><%=(makeBreak ? "<br>":"")%>Approve Work</a><%
makeBreak = true;
	   }
   if (minderRS.getDouble("billed") - minderRS.getDouble("collected") > 0) { 		
String invoiceQuery = "SELECT ari.id 'id', ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance FROM ar_invoice_details arid,ar_invoices ari LEFT JOIN ar_collection_details arcd on arcd.ar_invoiceid=ari.id WHERE ari.id = arid.ar_invoiceid AND arid.jobid = " + minderRS.getString("job_id") + " GROUP BY ari.invoice_number having (invoice_balance) >0 ORDER BY ari.creation_date";
   ResultSet invoiceRS = st2.executeQuery(invoiceQuery);
   while (invoiceRS.next()) { 
	%><a class="minderACTION" href="/minders/workflowforms/ReviewInvoice.jsp?invoiceId=<%=invoiceRS.getString("id")%>&jobId=<$ job_id $>"><%=(makeBreak ? "<br>":"")%>Pay Invoice</a><% makeBreak = true;
 } } 
%>&nbsp;</td><%

//Other actions
%><td class="lineitemcenter<%=((alt)?"alt":"")%>" nowrap>&nbsp;&nbsp;<a class="minderLink"  href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<$ job_id $><%=jobRole%>','700','600')">Details</a>
| <a class="minderLink" href="/files/JobFileViewer.jsp?jobId=<$ job_id $>">Files</a>
<a class="minderLink" href="/files/useremailform.jsp?jobId=<$ job_id $>&target=vendor"><br>&nbsp;&nbsp;Email Vendor</a>
</td><% } else { %><%

//Next Action
%><td class="lineitemcenter<%=(alt)?"alt":""%>"><a class="minderACTION" href="<$ actionform $>?jobId=<$ job_id $>" class="lineitemright<%=(alt)?"alt":""%>"<b><$ consolereseller $></b></a> <%
   boolean makeBreak = false;
	   if (minderRS.getString("consolereseller") != null && !minderRS.getString("consolereseller").equals("")) makeBreak = true;
   String compQuery = "SELECT a.group_id FROM form_messages a LEFT OUTER JOIN form_messages b on a.job_id = b.job_id AND a.group_id = b.group_id AND ((a.form_id = 1 OR a.form_id = 2) AND b.form_id = 8) WHERE (a.form_id = 1 OR a.form_id = 2) AND b.group_id IS NULL AND a.job_id = " + minderRS.getString("job_id");
   ResultSet compRS = st2.executeQuery(compQuery);
   while (compRS.next()) {
	 %><a class="minderLink" href="/minders/workflowforms/AdHocApproveCompProof.jsp?groupId=<%=compRS.getInt("group_id")%>&jobId=<$ job_id $>"  onmouseout="popUpTT(event,'appv')" onmouseover="popUpTT(event,'appv')"><%=(makeBreak ? "<br>":"")%>Appvl Pend</a><%
makeBreak = true;
	   }
		String fileQuery = "SELECT * FROM file_meta_data WHERE job_id = " + minderRS.getString("job_id") + " and category LIKE '%For Appvl%' and NOT (`status` LIKE '%Submitted%') ORDER BY creation_date";
   ResultSet fileRS = st2.executeQuery(fileQuery);
   while (fileRS.next()) { 
		if (fileRS.getString("status") == "Approved") { 
			%><font color="#00CC00"><% } %><%=(makeBreak ? "<br>":"")%>File&nbsp;<%=fileRS.getString("status")%><%
		  			makeBreak = true;
		if (fileRS.getString("status") == "Approved") { 
			%></font><% } } %><%
   if (minderRS.getDouble("billed") - minderRS.getDouble("collected") > 0) { 		
String invoiceQuery = "SELECT ari.id 'id', ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance FROM ar_invoice_details arid,ar_invoices ari LEFT JOIN ar_collection_details arcd on arcd.ar_invoiceid=ari.id WHERE ari.id = arid.ar_invoiceid AND arid.jobid = " + minderRS.getString("job_id") + " GROUP BY ari.invoice_number having (invoice_balance) >0 ORDER BY ari.creation_date";
   ResultSet invoiceRS = st2.executeQuery(invoiceQuery);
   while (invoiceRS.next()) { 
	%><a class="minderACTION" href="/minders/workflowforms/ReviewInvoice.jsp?invoiceId=<%=invoiceRS.getString("id")%>&jobId=<$ job_id $>"><%=(makeBreak ? "<br>":"")%>Bill Pend</a><%
	 makeBreak = true;
 } 
} 
%>&nbsp;</td><%

//Other actions
%><td class="lineitemleft<%=((alt)?"alt":"")%>" nowrap>&nbsp;&nbsp;<a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<$ job_id $><%=jobRole%>','700','600')" class="minderLink">Details</a> | <a href="/files/JobFileViewer.jsp?jobId=<$ job_id $>" class="minderLink">Files</a><a class="minderLink" href="/files/useremailform.jsp?jobId=<$ job_id $>&target=client"><br>&nbsp;&nbsp;Email Client</a><a class="minderLink" href="/files/useremailform.jsp?jobId=<$ job_id $>&target=vendor"><br>&nbsp;&nbsp;Email Rep</a><%if (minderRS.getString("j.product_id")!=null && !(minderRS.getString("j.product_id").equals(""))){%> | <a href="javascript:popw('/popups/ProductInfo.jsp?productId=<%=minderRS.getString("j.product_id")%>',640,500)">Prod Info</a><%}%></td><%
} %></tr><%
i++;
}
//end actionFilter Check for embedded jobs to extract
%></iterate:dbiterate>
</table>
<script>
	document.getElementById('loading').innerHTML='';
</script>
</body>
</html><%
	st.close();
	st2.close();
	conn.close();
}catch (Exception e){
%><!--An error has occurred: <%=e%> --><%
}finally{
	st=null;
	st2=null;
	conn=null;
}

%>