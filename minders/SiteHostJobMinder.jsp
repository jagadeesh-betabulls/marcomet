<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<% Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
UserProfile up = (UserProfile)session.getAttribute("userProfile");
	SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); 

	String jobnumberFilter = "";
	String mndrJobNumber="";
	String linkedjobsFilter="";
	mndrJobNumber=((request.getParameter("mndrJobNumber")== null)?((session.getAttribute("mndrJobNumber") == null)?"":session.getAttribute("mndrJobNumber").toString()):request.getParameter("mndrJobNumber"));
	session.setAttribute("mndrJobNumber", mndrJobNumber);

	linkedjobsFilter=((request.getParameter("linkedjobsFilter")== null)?((session.getAttribute("linkedjobsFilter") == null)?"":session.getAttribute("linkedjobsFilter").toString()):request.getParameter("linkedjobsFilter"));
	session.setAttribute("linkedjobsFilter", linkedjobsFilter);

	jobnumberFilter = ((mndrJobNumber.equals(""))?"":" AND (j.id = "+ mndrJobNumber + " OR j.job_link = " + mndrJobNumber+") ");
	%><html>
<head>
  <title>Site Host Job Minder</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
  	<link rel="stylesheet" href="<%=shs.getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
	<style>
		div#filters{
			margin: 0px 20px 0px 20px;
			display: none;
		}
	#minderFilters { border-style: solid; border-width: 1px; text-align: left; text-decoration: none; font: 10pt "Arial Narrow", Helvetica, sans-serif;  }
	#jobNumberFilter {padding: 5pt; border-bottom-style: solid; border-bottom-width: 1px; }
	#otherFilters {padding: 5pt; border-bottom-style: solid; border-bottom-width: 1px; }
	#sortAndGo{padding: 5pt;}
	select { line-height: 14pt; font: normal 9pt Arial, Helvetica, sans-serif; }
	.otherminder { font: normal 9pt Arial, Helvetica, sans-serif; background: #f6f6de; }
	select.sortBy { font: normal 9pt Arial, Helvetica, sans-serif; background: #fffff8; }
	.jobNumberInput { font: normal 9pt Arial, Helvetica, sans-serif; background: #e9f3f6 }
	input.submit { font-weight: bold; font: normal 9pt Arial, Helvetica, sans-serif; background: #c0cbb1; }
	</style>
	<script>
		function popSiteNumber(){
			var elVal=' AND 1 = 1 ';
			var EntryVal=document.forms[0].sitenumberEntry.value;
			if ( EntryVal != ''){
				elVal=" AND (c.default_site_number = '"+EntryVal+"' or c.default_pm_site_number = '"+EntryVal+"' or c3.company_name like '%"+EntryVal+"%')";
			}
			document.forms[0].sitenumberFilter.value=elVal;

		}
	</script>
</head>
<script language="JavaScript" src="/javascripts/mainlib2.js"></script>
<body background="<%=shs.getSiteHostRoot()%>/images/back3.jpg">
<span id='loading'><div align='center'> L O A D I N G . . .<br><br><img src='/images/loading.gif'><br></div></span><div id='filtertoggle' ></div><div id='filters'>
<!-- Job Number Filter -->
<form method="post" action="">
	<div id=minderFilters>
<div id=jobNumberFilter><strong>Filter Jobs By:</strong><br>Job Number (Leave blank for all):&nbsp;<input type=text name="mndrJobNumber" size=6 value="<%=mndrJobNumber%>"  class="jobNumberInput"><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; --OR-- (Clear the job number to use filters below)</div>
<div id=otherFilters><%
		
    String sql;
	int i = 0;
	
    String vendorRepFilter = "";
	String vendorRepSupv = "";
	String onlySubVendor = "";
    String jobTypeFilter = "";
    String rootProdFilter = "";	
    String companyFilter = "";
    String siteHostFilter = "";	
	String vendorFilter = "";
	String subvendorFilter = "";
    String archiveFilter = "";
    String collectedFilter = "";
    String actionFilter = "";
	String sortFilter = "";
	String sitenumberFilter="";
	String sitenumberEntry="";
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
	   		sitenumberFilter = " AND (c.default_site_number = '"+sitenumberEntry+"' or c.default_pm_site_number = '"+sitenumberEntry+"' or c3.company_name like '%"+sitenumberEntry+"%')";
	}
	
    if (request.getParameter("companyFilter") != null) {
       companyFilter = request.getParameter("companyFilter");
       session.setAttribute("companyFilter", request.getParameter("companyFilter"));
    } else if (session.getAttribute("companyFilter") != null) {
       companyFilter = (String)session.getAttribute("companyFilter");
    } else {
       companyFilter = " AND 1 = 0 ";
       session.setAttribute("companyFilter", " AND 1 = 0 ");
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
       subvendorFilter = " AND 1 = 1 ";
       session.setAttribute("subvendorFilter", " AND 1 = 1 ");
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
     if (request.getParameter("sortFilter") != null) {
       sortFilter = request.getParameter("sortFilter");
       session.setAttribute("sortFilter", request.getParameter("sortFilter"));
    } else if (session.getAttribute("sortFilter") != null) {
       sortFilter = (String)session.getAttribute("sortFilter");
    } else {
       sortFilter = " ORDER BY o.date_created, j.project_id, j.id DESC";
       session.setAttribute("sortFilter", " ORDER BY o.date_created, j.project_id, j.id DESC");
    }
	 %>Client/Buyer:&nbsp; 
        <select name="companyFilter">
          <option selected value=" AND 1 = 0 ">- select -</option><%
 if (companyFilter.equals(" AND 1 = 1 ")) { %><option selected value=" AND 1 = 1 ">All</option><% 
} else { 
	%><option value=" AND 1 = 1 ">All</option><%
} 
     sql = "SELECT c.id, c.company_name 'companyname', cont.lastname 'lastname', cont.firstname 'firstname', cont.id FROM jobs j, companies c, projects p, orders o, contacts cont WHERE j.project_id = p.id AND p.order_id = o.id AND o.buyer_company_id = c.id AND (o.site_host_id = " + shs.getSiteHostId() + " OR vendor_company_id = " + shs.getSiteHostCompanyId() + ") AND cont.companyid=c.id GROUP BY cont.id ORDER BY companyname, lastname, firstname";
          ResultSet rs0 = st.executeQuery(sql);
          while (rs0.next()) {
		      if (companyFilter.equals(" AND o.buyer_contact_id = " + rs0.getString("cont.id")+ " ")) { 
			%><option selected value=" AND o.buyer_company_id = <%=rs0.getString("id")%> "><%=rs0.getString("companyname")%> - <%=rs0.getString("firstname")%> <%=rs0.getString("lastname")%></option><%
			 } else { 
				%><option value=" AND o.buyer_contact_id = <%=rs0.getString("cont.id")%> "><%=rs0.getString("companyname")%> - <%=rs0.getString("firstname")%> <%=rs0.getString("lastname")%></option><%
			} 
		} 
		%></select>
Root Prod:&nbsp; 
        <select name="rootProdFilter"><option selected value=" AND 1 = 1 ">All</option><%
          sql = "SELECT root_prod_code 'rootprodfilter', description 'root_desc' FROM product_roots GROUP BY root_prod_code ORDER BY root_prod_code";
          ResultSet rsRP = st.executeQuery(sql);
          while (rsRP.next()) {
		      if (rootProdFilter.equals(" AND ( j.root_prod_code = '" + rsRP.getString("rootprodfilter") + "' )")){ 
         %><option selected value=" AND ( j.root_prod_code = '<%=rsRP.getString("rootprodfilter")%>' )"><%=rsRP.getString("rootprodfilter")%> - <%=rsRP.getString("root_desc")%></option><%
 			  } else { 
	%><option value=" AND ( j.root_prod_code = '<%=rsRP.getString("rootprodfilter")%>' )"><%=rsRP.getString("rootprodfilter")%> - <%=rsRP.getString("root_desc")%></option><%
	 		  }
		 } %></select><br><br>
&nbsp; Job&nbsp;Status:&nbsp; 
<select name="archiveFilter"><%
 if (archiveFilter.equals(" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ")) {
	 %><option selected value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND 1 = 1 ">All</option><%
	
	 } else if (archiveFilter.equals(" AND (j.status_id = 16 OR j.status_id = 2) ")) { 
		%><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option selected value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND 1 = 1 ">All</option><%
		 } else if (archiveFilter.equals(" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ")) { %><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option selected value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND 1 = 1 ">All</option><%
		 } else if (archiveFilter.equals(" AND j.status_id = 112 ")) { 
			%><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option selected value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option> <option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND 1 = 1 ">All</option><%
			 } else if (archiveFilter.equals(" AND j.status_id = 119 ")) { 
				%><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option selected value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND 1 = 1 ">All</option><%
				 } else if (archiveFilter.equals(" AND j.status_id = 120 ")) {
		%><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option selected value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND 1 = 1 ">All</option><%
		 } else if (archiveFilter.equals(" AND j.status_id = 9 ")) { 
			%><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option>
          <option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option>
          <option value=" AND j.status_id = 119 ">Completed</option>
          <option value=" AND j.status_id = 120 ">Closed</option>
          <option selected value=" AND j.status_id = 9 ">Cancelled</option>
          <option value=" AND j.status_id = 122 ">On Hold</option>
          <option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option>
          <option value=" AND 1 = 1 ">All</option><%
 } else if (archiveFilter.equals(" AND j.status_id = 122 ")) { 
	%><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option>
          <option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option>
          <option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option>
          <option value=" AND j.status_id = 112 ">In Progress</option>
          <option value=" AND j.status_id = 119 ">Completed</option>
          <option value=" AND j.status_id = 120 ">Closed</option>
          <option value=" AND j.status_id = 9 ">Cancelled</option>
          <option selected value=" AND j.status_id = 122 ">On Hold</option>
          <option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option>
          <option value=" AND 1 = 1 ">All</option><%
 } else if (archiveFilter.equals(" AND j.status_id != 120 AND j.status_id != 9 ")) { 
	%><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option>
          <option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option>
          <option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option>
          <option value=" AND j.status_id = 119 ">Completed</option>
          <option value=" AND j.status_id = 120 ">Closed</option>
          <option value=" AND j.status_id = 9 ">Cancelled</option>
          <option value=" AND j.status_id = 122 ">On Hold</option>		  
          <option selected value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option>
          <option value=" AND 1 = 1 ">All</option><%
 } else { 
	%><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option>
          <option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option>
          <option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option>
          <option value=" AND j.status_id = 112 ">In Progress</option>
          <option value=" AND j.status_id = 119 ">Completed</option>
          <option value=" AND j.status_id = 120 ">Closed</option>
          <option value=" AND j.status_id = 9 ">Cancelled</option>
<option value=" AND j.status_id = 122 ">On Hold</option>
<option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option>
          <option selected value=" AND 1 = 1 ">All</option><% } %></select>
&nbsp; Bill/Pmt&nbsp;Status:&nbsp; 
        <select name="collectedFilter"><%
 if (collectedFilter.equals(" AND (j.billable - j.billed > 0) ")) {
	 %><option value=" AND 1 = 1 ">All</option>
          <option selected value=" AND (j.billable - j.billed > 0) ">Unbilled</option>
          <option value=" AND (j.billable - j.billed <= 0 AND j.billable != 0) ">Billed in Full</option>
          <option value=" AND (j.billed - j.collected > 0) ">Balance Due</option>
          <option value=" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ">Paid to Date</option>
          <option value=" AND (j.billable - j.collected <= 0 AND j.billable != 0) ">Paid in Full</option><%
 } else if (collectedFilter.equals(" AND (j.billable - j.billed <= 0 AND j.billable != 0) ")) { 
	%><option value=" AND 1 = 1 ">All</option>
          <option value=" AND (j.billable - j.billed > 0) ">Unbilled</option>
          <option selected value=" AND (j.billable - j.billed <= 0 AND j.billable != 0) ">Billed in Full</option>
          <option value=" AND (j.billed - j.collected > 0) ">Balance Due</option>
          <option value=" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ">Paid to Date</option>
          <option value=" AND (j.billable - j.collected <= 0 AND j.billable != 0) ">Paid in Full</option><%
 } else if (collectedFilter.equals(" AND (j.billed - j.collected > 0) ")) { 
	%><option value=" AND 1 = 1 ">All</option>
          <option value=" AND (j.billable - j.billed > 0) ">Unbilled</option>
          <option value=" AND (j.billable - j.billed <= 0 AND j.billable != 0) ">Billed in Full</option>
          <option selected value=" AND (j.billed - j.collected > 0) ">Balance Due</option>
          <option value=" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ">Paid to Date</option>
          <option value=" AND (j.billable - j.collected <= 0 AND j.billable != 0) ">Paid in Full</option><%
 } else if (collectedFilter.equals(" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ")) { %><option value=" AND 1 = 1 ">All</option>
          <option value=" AND (j.billable - j.billed > 0) ">Unbilled</option>
          <option value=" AND (j.billable - j.billed <= 0 AND j.billable != 0) ">Billed in Full</option>
          <option value=" AND (j.billed - j.collected > 0) ">Balance Due</option>
          <option selected value=" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ">Paid to Date</option>
          <option value=" AND (j.billable - j.collected <= 0 AND j.billable != 0) ">Paid in Full</option><%
 } else if (collectedFilter.equals(" AND (j.billable - j.collected <= 0 AND j.billable != 0) ")) { %><option value=" AND 1 = 1 ">All</option>
          <option value=" AND (j.billable - j.billed > 0) ">Unbilled</option>
          <option value=" AND (j.billable - j.billed <= 0 AND j.billable != 0) ">Billed in Full</option>
          <option value=" AND (j.billed - j.collected > 0) ">Balance Due</option>
          <option value=" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ">Paid to Date</option>
          <option selected value=" AND (j.billable - j.collected <= 0 AND j.billable != 0) ">Paid in Full</option><%
 } else { %><option selected value=" AND 1 = 1 ">All</option>
          <option value=" AND (j.billable - j.billed > 0) ">Unbilled</option>
          <option value=" AND (j.billable - j.billed <= 0 AND j.billable != 0) ">Billed in Full</option>
          <option value=" AND (j.billed - j.collected > 0) ">Balance Due</option>
          <option value=" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ">Paid to Date</option>
          <option value=" AND (j.billable - j.collected <= 0 AND j.billable != 0) ">Paid in Full</option><% } %></select></select>
		<!-- Sitenumber Filter -->
		Property Site#:&nbsp;<input type=text name='sitenumberEntry' id='sitenumberEntry' class='otherminder' size=10 onChange='popSiteNumber()' value='<%=sitenumberEntry%>'><input type=hidden name='sitenumberFilter' id='sitenumberFilter' value='<%=sitenumberFilter%>'>
		<!-- end Sitenumber filter -->
		Sort&nbsp;by:&nbsp; <select name="sortFilter"><%
 if (sortFilter.equals(" ORDER BY o.date_created, j.project_id, j.id DESC")) { %><option selected value=" ORDER BY o.date_created, j.project_id, j.id DESC">Date Ordered</option>
          <option value=" ORDER BY j.product_code, o.date_created, j.project_id, j.id DESC">Prod, Date Ordered</option>
          <option value=" ORDER BY c3.company_name, o.date_created, j.project_id, j.id DESC">Client Co., Date Ordered</option><% } else if (sortFilter.equals(" ORDER BY j.product_code, o.date_created, j.project_id, j.id DESC")) { %><option value=" ORDER BY o.date_created, j.project_id, j.id DESC">Date Ordered</option>
          <option selected value=" ORDER BY j.product_code, o.date_created, j.project_id, j.id DESC">Prod, Date Ordered</option>
          <option value=" ORDER BY c3.company_name, o.date_created, j.project_id, j.id DESC">Client Co., Date Ordered</option><% } else { %><option value=" ORDER BY o.date_created, j.project_id, j.id DESC">Date Ordered</option>
          <option value=" ORDER BY j.product_code, o.date_created, j.project_id, j.id DESC">Prod, Date Ordered</option>
          <option selected value=" ORDER BY c3.company_name, o.date_created, j.project_id, j.id DESC">Client Co., Date Ordered</option><% } %></select>
&nbsp;&nbsp;&nbsp;<input type="submit" name="Submit" class='submit' value=" >> APPLY FILTERS "></form>
</div></div></div><%
 boolean alt = true;

StringBuffer minderQuery = new StringBuffer();
    minderQuery.append("SELECT o.id 'order_id', DATE_FORMAT(o.date_created,'%m/%d/%y') 'creation_date', j.id 'job_id', j.job_name 'job_name', ljt.value 'job_type', lst.value 'service_type', j.status_id 'status_id', j.billable 'invoice', j.billed, j.collected 'collected', j.escrow_amount 'escrow', jfs.shownstatus 'shown_status', CONCAT(c.firstname,' ',c.lastname) 'customer', j.balance_to_vendor 'vendorbalance', j.balance_to_site_host 'sitehostbalance', consolereseller, consolecustomer, actionform, whosaction, c2.company_name 'sitehost', p.id 'projectnumber', c.id 'customerid', o.site_host_contact_id 'sitehostcontactid', j.vendor_company_id 'vendor_company_id', j.internal_reference_data 'internalref', j.vendor_contact_id 'vendorcontactid', c1.company_name 'vendor', j.buyer_internal_reference_data, j.job_link, o.buyer_contact_id, o.buyer_company_id, c3.company_name 'buyercompany', j.root_prod_code, j.quantity 'quantity' "); 
    minderQuery.append("FROM orders o, projects p, contacts c, jobflowstates jfs, lu_job_types ljt, lu_service_types lst, vendors v, companies c1, companies c2, companies c3, site_hosts sh, job_specs js,jobs j ");
    minderQuery.append("LEFT JOIN jobs j2 ON j.id = j2.job_link ");
    minderQuery.append("WHERE o.id = p.order_id AND p.id = j.project_id AND o.buyer_contact_id = c.id AND j.status_id = jfs.statusnumber AND j.service_type_id = lst.id AND j.job_type_id = ljt.id AND o.site_host_id = sh.id AND v.company_id = c1.id AND sh.company_id = c2.id AND c.companyid=c3.id AND j.vendor_id = v.id AND js.job_id=j.id AND ((site_host_id = " + shs.getSiteHostId() + " OR j.vendor_company_id = " + up.getCompanyId() + ") OR o.buyer_company_id = " + up.getCompanyId() + ") ");
	if (!jobnumberFilter.equals("")){
		minderQuery.append(jobnumberFilter);
		minderQuery.append(" GROUP BY j.id");
		minderQuery.append(sortFilter);
	}else{
		minderQuery.append(archiveFilter);
		minderQuery.append(collectedFilter);
	    minderQuery.append(companyFilter);
	    minderQuery.append(rootProdFilter);	
		minderQuery.append(sitenumberFilter);	
		minderQuery.append(" GROUP BY j.id");
	    minderQuery.append(sortFilter);
	}

    ResultSet minderRS = st.executeQuery(minderQuery.toString());
    request.setAttribute("minderRS", minderRS);
String tableHeader="<table cellspacing='0' cellpadding='3' width='100%' border='1' bordercolor='#000000'><tr bordercolor='#000000'><td class='minderheaderleft' height='0' width='0'>Client</td><td class='minderheaderleft' height='0' width='0'>Rep</td><td class='minderheaderleft' height='0' width='0'>Date</td><td class='minderheadercenter' height='0' width='0'>Job</td><td class='minderheaderleft'   height='0' width='0'>Buyer Ref.</td><td class='minderheaderleft' height='0' width='0'>Vendor Ref.</td><td class='minderheaderleft' height='0' width='0'>Job Name</td><td class='minderheaderright'  height='0' width='0' nowrap>Total<br>Billed<br>Collected</td><td class='minderheadercenter' height='0' width='0'>Status</td><td class='minderheadercenter' height='0' width='0'>Actions Items</td><td class='minderheadercenter' height='0' width='0'>Other Actions</td></tr>";
int z=0;
  %><iterate:dbiterate name="minderRS" id="k"><%
 		alt = (alt)?false:true; 
		z++;
		//customer
		%><%=((z==1)?tableHeader:"")%><tr><td class="lineitemleft<%=(alt)?"alt":""%>"><a href="javascript:pop('/popups/PersonProfilePage.jsp?personId=<$ customerid $>','650','450')" class="minderLink"><$ buyercompany $><br><$ customer $></a></td><%
//-- vendor --
%><td class="lineitemleft<%=(alt)?"alt\"":"\""%>><a href="javascript:pop('/popups/PersonProfilePage.jsp?personId=<$ vendorcontactid $>','650','450')" class="minderLink"><$ vendor $><br><$ vendorcontactid $></a></td><td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><%=minderRS.getString("creation_date")%></td>
<td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><$ job_id $></td><td class="lineitemleft<%=(alt)?"alt\"":"\""%>><$ buyer_internal_reference_data $>&nbsp;</td>
<td class="lineitemleft<%=(alt)?"alt\"":"\""%>><$ internalref $>&nbsp;</td><td class="lineitemleft<%=(alt)?"alt\"":"\""%>><$ job_name $><br><%=(minderRS.getString("quantity")!=null&&minderRS.getString("quantity")!="")?"Qty: " +(minderRS.getString("quantity")):("")%></td><td class="lineitemright<%=(alt)?"alt\"":"\""%>><%=formatter.getCurrency(minderRS.getDouble("invoice"))%><br><%=formatter.getCurrency(minderRS.getDouble("billed"))%><br><%=formatter.getCurrency(minderRS.getDouble("collected"))%></td><td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><$ shown_status $></td><%
 if (minderRS.getInt("buyer_company_id") == Integer.parseInt((String)up.getCompanyId()) 
	/*&& minderRS.getInt("buyer_contact_id") != minderRS.getInt("sitehostcontactid")*/
	/*|| minderRS.getInt("vendorcontactid") != Integer.parseInt((String)up.getContactId())*/
	) { %><td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><%
	 boolean makeBreak = false;
     if (minderRS.getInt("whosaction") == 1) { 
	%><a class="minderACTION" href="<$ actionform $>?jobId=<$ job_id $>" class="lineitemright<%=(alt)?"alt\"":"\""%><b><$ consolecustomer $></b></a><%
	 } else { 
	%><$ consolecustomer $><%
	   }
       if (minderRS.getString("consolecustomer") != null && !minderRS.getString("consolecustomer").equals("")) makeBreak = true;	 
      String compQuery = "SELECT a.group_id FROM form_messages a LEFT OUTER JOIN form_messages b on a.job_id = b.job_id AND a.group_id = b.group_id AND ((a.form_id = 1 OR a.form_id = 2) AND b.form_id = 8) WHERE (a.form_id = 1 OR a.form_id = 2) AND b.group_id IS NULL AND a.job_id = " + minderRS.getString("job_id");
       ResultSet compRS = st2.executeQuery(compQuery);
       while (compRS.next()) { %>
          <a class="minderACTION" href="/minders/workflowforms/AdHocApproveCompProof.jsp?groupId=<%=compRS.getInt("group_id")%>&jobId=<$ job_id $>"><%=(makeBreak ? "<br>":"")%>Approve Work</a><%
makeBreak = true;
	   }
       if (minderRS.getDouble("billed") - minderRS.getDouble("collected") > .01 || minderRS.getDouble("billed") - minderRS.getDouble("collected") < -.01) { 		
String invoiceQuery = "SELECT ari.id 'id', ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance FROM ar_invoice_details arid,ar_invoices ari LEFT JOIN ar_collection_details arcd on arcd.ar_invoiceid=ari.id WHERE ari.id = arid.ar_invoiceid AND arid.jobid = " + minderRS.getString("job_id") + " GROUP BY ari.invoice_number having (invoice_balance) >.01 or (invoice_balance) <-.01 ORDER BY ari.creation_date";
       ResultSet invoiceRS = st2.executeQuery(invoiceQuery);
       while (invoiceRS.next()) { 
	%><a class="minderACTION" href="/minders/workflowforms/ReviewInvoice.jsp?invoiceId=<%=invoiceRS.getString("id")%>&jobId=<$ job_id $>"><%=(makeBreak ? "<br>":"")%>Pay Invoice #<%=invoiceRS.getString("ari.invoice_number")+"&nbsp;/&nbsp;"+formatter.getCurrency(invoiceRS.getString("invoice_balance"))+ ((invoiceRS.getDouble("invoice_balance")>0)?"&nbsp;Due ":"&nbsp;Credit ")%></a><%
	 makeBreak = true; } } 
	%>&nbsp;</td>
    <td class="lineitemleft<%=(alt)?"alt\"":"\""%> nowrap>&nbsp;&nbsp;<a class="minderLink" href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<$ job_id $>&actingRole=buyer','700','300')">Details</a>
    | <a class="minderLink" href="/files/JobFileViewer.jsp?jobId=<$ job_id $>">Files</a>
    <a class="minderLink" href="/files/useremailform.jsp?jobId=<$ job_id $>&target=vendor"><br>&nbsp;&nbsp;Email Vendor</a></td><%
 } else { 
	%><td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><a class="minderACTION" href="<$ actionform $>?jobId=<$ job_id $>" class="lineitemright<%=(alt)?"alt\"":"\""%><b><$ consolereseller $></b></a><%
       boolean makeBreak = false;
	   if (minderRS.getString("consolereseller") != null && !minderRS.getString("consolereseller").equals("")) makeBreak = true;
       String compQuery = "SELECT a.group_id FROM form_messages a LEFT OUTER JOIN form_messages b on a.job_id = b.job_id AND a.group_id = b.group_id AND ((a.form_id = 1 OR a.form_id = 2) AND b.form_id = 8) WHERE (a.form_id = 1 OR a.form_id = 2) AND b.group_id IS NULL AND a.job_id = " + minderRS.getString("job_id");
       ResultSet compRS = st2.executeQuery(compQuery);
       while (compRS.next()) { %>
          <a class="minderLink" href="/minders/workflowforms/AdHocApproveCompProof.jsp?groupId=<%=compRS.getInt("group_id")%>&jobId=<$ job_id $>"><%=(makeBreak ? "<br>":"")%>Appvl Pend</a><%
makeBreak = true;
	   }
		String fileQuery = "SELECT * FROM file_meta_data WHERE job_id = " + minderRS.getString("job_id") + " and category LIKE '%For Appvl%' and NOT (`status` LIKE '%Submitted%') ORDER BY creation_date";
       ResultSet fileRS = st2.executeQuery(fileQuery);
       while (fileRS.next()) { 
		if (fileRS.getString("status") == "Approved") { 
			%><font color="#00CC00"><%
			 } 
			%><%=(makeBreak ? "<br>":"")%>File&nbsp;<%=fileRS.getString("status")%><%
		  
			makeBreak = true;
		if (fileRS.getString("status") == "Approved") { 
			%></font><%
		 }
	 } 
    if (minderRS.getDouble("billed") - minderRS.getDouble("collected") > .01 || minderRS.getDouble("billed") - minderRS.getDouble("collected") < -.01) { 		
String invoiceQuery = "SELECT ari.id 'id', ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance FROM ar_invoice_details arid,ar_invoices ari LEFT JOIN ar_collection_details arcd on arcd.ar_invoiceid=ari.id WHERE ari.id = arid.ar_invoiceid AND arid.jobid = " + minderRS.getString("job_id") + " GROUP BY ari.invoice_number having (invoice_balance) >.01 or (invoice_balance) < -.01 ORDER BY ari.creation_date";
       ResultSet invoiceRS = st2.executeQuery(invoiceQuery);
       while (invoiceRS.next()) { %><a class="minderACTION" href="/minders/workflowforms/ReviewInvoice.jsp?invoiceId=<%=invoiceRS.getString("id")%>&jobId=<$ job_id $>"><%=(makeBreak ? "<br>":"")%>Invoice&nbsp;#<%=invoiceRS.getString("ari.invoice_number")+"&nbsp;/&nbsp;"+formatter.getCurrency(invoiceRS.getString("invoice_balance"))+ ((invoiceRS.getDouble("invoice_balance")>0)?"&nbsp;Due ":"&nbsp;Credit ")%></a><%
 makeBreak = true; } } 
%>&nbsp;</td><td class="lineitemleft<%=(alt)?"alt\"":"\""%> nowrap>
	&nbsp;&nbsp;<a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<$ job_id $>','700','300')" class="minderLink">Details</a> 
	| <a href="/files/JobFileViewer.jsp?jobId=<$ job_id $>" class="minderLink">Files</a> 
	<a class="minderLink" href="/files/useremailform.jsp?jobId=<$ job_id $>&target=client"><br>&nbsp;&nbsp;Email Client</a> 
    <a class="minderLink" href="/files/useremailform.jsp?jobId=<$ job_id $>&target=vendor"><br>&nbsp;&nbsp;Email Rep</a></td><%
 } 
	i++;
	%></tr>
  </iterate:dbiterate>
</table>
<script>
	document.getElementById('loading').innerHTML='';
	function toggleLayer(whichLayer){
		var style2 = document.getElementById(whichLayer).style;
		style2.display = style2.display=="block"? "none":"block";
	}
	function togglefilters(){
		var style2 = document.getElementById('filters').style;
		if (style2.display=="block"){
			document.getElementById('filtertoggle').innerHTML='<span class=menuLink><a href="javascript:togglefilters()">+ Show Filters</a></span>';
		}else{
			document.getElementById('filtertoggle').innerHTML=<%=((i==0)?"''":"'<span class=menuLink><a href=\"javascript:togglefilters()\">&raquo; Hide Filters</a></span>'")%>;
		}
		toggleLayer('filters');
	}
	<%=((i==0)?"togglefilters()":"document.getElementById('filtertoggle').innerHTML='<span class=menuLink><a href=\"javascript:togglefilters()\">+ Show Filters</a></span>'")%>
</script>
</body>
</html><%st.close();st2.close();conn.close();%>