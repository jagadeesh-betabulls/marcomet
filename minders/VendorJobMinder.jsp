<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<% UserProfile up = (UserProfile)session.getAttribute("userProfile");
   SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); 
 %><html>
<head>
  <title>Vendor Job Minder</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=shs.getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body background="<%=shs.getSiteHostRoot()%>/images/back3.jpg">
<p class="Title">Job Console</p>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
  <tr>
    <td class="label" align="right">
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
String sql;
	int i = 0;
	String actionFilter = "";
   	String companyFilter = "";
	String archiveFilter = "";
    String collectedFilter = "";
	String siteHostFilter = "";

    if (request.getParameter("companyFilter") != null) {
       companyFilter = request.getParameter("companyFilter");
       session.setAttribute("companyFilter", request.getParameter("companyFilter"));
    } else if (session.getAttribute("companyFilter") != null) {
       companyFilter = (String)session.getAttribute("companyFilter");
    } else {
       companyFilter = " AND 1 = 1 ";
       session.setAttribute("companyFilter", " AND 1 = 1 ");
    }

    if (request.getParameter("archiveFilter") != null) {
       archiveFilter = request.getParameter("archiveFilter");
       session.setAttribute("archiveFilter", request.getParameter("archiveFilter"));
    } else if (session.getAttribute("archiveFilter") != null) {
       archiveFilter = (String)session.getAttribute("archiveFilter");
    } else {
       archiveFilter = " AND j.status_id != 120 AND j.status_id != 9 ";
       session.setAttribute("archiveFilter", " AND j.status_id != 120 AND j.status_id != 9 ");
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

/*    if (request.getParameter("actionFilter") != null) {
       actionFilter = request.getParameter("actionFilter");
       session.setAttribute("actionFilter", request.getParameter("actionFilter"));
    } else if (session.getAttribute("actionFilter") != null) {
       actionFilter = (String)session.getAttribute("actionFilter");
    } else {
       actionFilter = " AND 1 = 1 ";
       session.setAttribute("actionFilter", " AND 1 = 1 ");
    } */
	 %>
<form method="post" action="">
      Buyer:
      &nbsp;

        <select name="companyFilter">

          <option selected value=" AND 1 = 1 ">All</option>

          <%
          sql = "SELECT c.id, c.company_name 'companyname', cont.lastname 'lastname', cont.firstname 'firstname' FROM jobs j, companies c, projects p, orders o, contacts cont WHERE j.project_id = p.id AND p.order_id = o.id AND o.buyer_company_id = c.id AND vendor_company_id = " + up.getCompanyId() + " AND cont.id=o.buyer_contact_id GROUP BY c.id ORDER BY companyname";
          ResultSet rs0 = st.executeQuery(sql);
          while (rs0.next()) {
		      if (companyFilter.equals(" AND o.buyer_company_id = " + rs0.getString("id")+ " ")) { 
		      	%><option selected value=" AND o.buyer_company_id = <%=rs0.getString("id")%> "><%=rs0.getString("companyname")%> - <%=rs0.getString("firstname")%> <%=rs0.getString("lastname")%></option><%
		      	} else { 
		      	%><option value=" AND o.buyer_company_id = <%=rs0.getString("id")%> "><%=rs0.getString("companyname")%>  - <%=rs0.getString("firstname")%> <%=rs0.getString("lastname")%></option><%
		      	} 
		   } 
		   %></select>
        &nbsp;	  
        Job Status:&nbsp;
        <select name="archiveFilter">
          <% if (archiveFilter.equals(" AND j.status_id != 120 AND j.status_id != 9 ")) { %>
          <option selected value=" AND j.status_id != 120 AND j.status_id != 9 ">Active</option>
          <option value=" AND j.status_id = 120 ">Closed</option>
          <option value=" AND j.status_id = 9 ">Cancelled</option>
          <option value=" AND 1 = 1 ">All</option>
          <% } else if (archiveFilter.equals(" AND j.status_id = 120 ")) { %>
          <option value=" AND j.status_id != 120 AND j.status_id != 9 ">Active</option>
          <option selected value=" AND j.status_id = 120 ">Closed</option>
          <option value=" AND j.status_id = 9 ">Cancelled</option>
          <option value=" AND 1 = 1 ">All</option>
          <% } else if (archiveFilter.equals(" AND j.status_id = 9 ")) { %>
          <option value=" AND j.status_id != 120 AND j.status_id != 9 ">Active</option>
          <option value=" AND j.status_id = 120 ">Closed</option>
          <option selected value=" AND j.status_id = 9 ">Cancelled</option>
          <option value=" AND 1 = 1 ">All</option>
          <% } else { %>
          <option value=" AND j.status_id != 120 AND j.status_id != 9 ">Active</option>
          <option value=" AND j.status_id = 120 ">Closed</option>
          <option value=" AND j.status_id = 9 ">Cancelled</option>
          <option selected value=" AND 1 = 1 ">All</option>
          <% } %>
        </select>
        &nbsp; Action&nbsp;Status:&nbsp; 
        <select name="collectedFilter"><%
        if (collectedFilter.equals(" AND (j.status_id = 16 OR j.status_id = 2) ")) { 
        	%><option value=" AND 1 = 1 ">All</option>
          <option selected value=" AND (j.status_id = 16 OR j.status_id = 2) ">Quote or Confirm</option> 
          <option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Await Quote/Chg Appvl</option>		  
          <option value=" AND (j.billable - j.billed > 0) ">Unbilled</option><%
        } else if (collectedFilter.equals(" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ")) { 
        	%><option value=" AND 1 = 1 ">All</option>
          <option value=" AND (j.status_id = 16 OR j.status_id = 2) ">Quote or Confirm</option>
          <option selected value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Await Quote/Chg Appvl</option>		  
          <option value=" AND (j.billable - j.billed > 0) ">Unbilled</option><%
        } else if (collectedFilter.equals(" AND (j.billable - j.billed > 0) ")) { 
        %><option value=" AND 1 = 1 ">All</option>
          <option value=" AND (j.status_id = 16 OR j.status_id = 2) ">Quote or Confirm</option>	  
          <option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Await Quote/Chg Appvl</option>		  
          <option selected value=" AND (j.billable - j.billed > 0) ">Unbilled</option><%
        } else if (collectedFilter.equals(" AND (j.billed - j.collected > 0) ")) { 
        	%><option value=" AND 1 = 1 ">All</option>
          <option value=" AND (j.status_id = 16 OR j.status_id = 2) ">Quote or Confirm</option>	  
          <option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Await Quote/Chg Appvl</option>		  
          <option value=" AND (j.billable - j.billed > 0) ">Unbilled</option><%
        } else if (collectedFilter.equals(" AND (j.billed - j.collected = 0 AND j.billable != 0) ")) { 
        %><option value=" AND 1 = 1 ">All</option>
          <option value=" AND (j.status_id = 16 OR j.status_id = 2) ">Quote or Confirm</option>	  
          <option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Await Quote/Chg Appvl</option>		  
          <option value=" AND (j.billable - j.billed > 0) ">Unbilled</option><%
        } else if (collectedFilter.equals(" AND (j.billable = j.collected AND j.billable != 0) ")) { %>
          <option value=" AND 1 = 1 ">All</option>
          <option value=" AND (j.status_id = 16 OR j.status_id = 2) ">Quote or Confirm</option>	  
          <option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Await Quote/Chg Appvl</option>		  
          <option value=" AND (j.billable - j.billed > 0) ">Unbilled</option><%
        } else { 
        	%><option selected value=" AND 1 = 1 ">All</option>
          <option value=" AND (j.status_id = 16 OR j.status_id = 2) ">Quote or Confirm</option>	  
          <option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Await Quote/Chg Appvl</option>		  
          <option value=" AND (j.billable - j.billed > 0) ">Unbilled</option><%
        } 
        %></select>&nbsp;
	    <input type="submit" name="Submit" value="Filter">
     </form>		
    </td>
  </tr>
</table><%
boolean alt = true; 

StringBuffer minderQuery = new StringBuffer();
    minderQuery.append("SELECT o.id 'order_id', DATE_FORMAT(o.date_created,'%m/%d/%y') 'creation_date', j.id 'job_id', j.job_name 'job_name', ljt.value 'job_type', lst.value 'service_type', j.status_id 'status_id', j.billable 'invoice', j.billed, j.collected 'collected', j.escrow_amount 'escrow', jfs.shownstatus 'shown_status', CONCAT(c.firstname,' ',c.lastname) 'customer', j.balance_to_vendor 'vendorbalance', j.balance_to_site_host 'sitehostbalance', consolereseller, consolecustomer, actionform, whosaction, c2.company_name 'sitehost', p.id 'projectnumber', c.id 'customerid', o.site_host_contact_id 'sitehostcontactid', j.vendor_company_id 'vendor_company_id', j.internal_reference_data 'internalref', j.vendor_contact_id 'vendorcontactid', c1.company_name 'vendor', j.buyer_internal_reference_data, j.job_link, o.buyer_contact_id, o.buyer_company_id, c3.company_name 'buyercompany', j.quantity 'quantity' "); 
    minderQuery.append("FROM orders o, projects p, jobs j, contacts c, jobflowstates jfs, lu_job_types ljt, lu_service_types lst, vendors v, companies c1, companies c2, companies c3, site_hosts sh ");
    minderQuery.append("WHERE o.id = p.order_id AND p.id = j.project_id AND o.buyer_contact_id = c.id AND j.status_id = jfs.statusnumber AND j.service_type_id = lst.id AND j.job_type_id = ljt.id AND o.site_host_id = sh.id AND v.company_id = c1.id AND sh.company_id = c2.id AND c.companyid=c3.id AND j.vendor_id = v.id AND ((site_host_id = " + shs.getSiteHostId() + " OR j.vendor_company_id = " + up.getCompanyId() + ") OR o.buyer_company_id = " + up.getCompanyId() + ") ");
    minderQuery.append(companyFilter);
    minderQuery.append(archiveFilter);
	minderQuery.append(collectedFilter);
    minderQuery.append(" ORDER BY o.date_created, j.project_id, j.id ASC");
    ResultSet minderRS = st.executeQuery(minderQuery.toString());
    request.setAttribute("minderRS", minderRS);
%><table cellspacing="0" cellpadding="3" width="100%" border="1" bordercolor="#000000">
  <tr bordercolor="#000000"> 
    <td class="minderheaderleft"   height="0" width="0">Buyer</td>
<!--    <td class="minderheadercenter" height="0" width="0">Order</td> -->
    <td class="minderheaderleft"   height="0" width="0">Date</td>
<!--    <td class="minderheaderleft"   height="0" width="0">Proj.</td> -->
    <td class="minderheadercenter" height="0" width="0">Job</td>
<!--    <td class="minderheadercenter" height="0" width="0">Job Link</td> -->
<!--    <td class="minderheadercenter" height="0" width="0">Buyer Ref.</td> -->
    <td class="minderheaderleft"   height="0" width="0">Vendor Ref.</td>
    <td class="minderheaderleft"   height="0" width="0">Job Name</td>
<!--    <td class="minderheaderleft"   height="0" width="0">Job Type</td> -->
<!--    <td class="minderheaderleft"   height="0" width="0">Service</td> -->
    <td class="minderheaderright"  height="0" width="0" nowrap>Job Total</td>
    <td class="minderheaderright"  height="0" width="0">Billed</td>
    <td class="minderheadercenter" height="0" width="0">Status</td>
    <td class="minderheadercenter" height="0" width="0">Actions Items</td>
    <td class="minderheadercenter" height="0" width="0">Other Actions</td>
  </tr>
  <iterate:dbiterate name="minderRS" id="k">
  <% alt = (alt)?false:true; 
  %><tr>
    <%-- buyer --%>
    <td class="lineitemleft<%=(alt)?"alt\"":"\""%>><a href="javascript:pop('/popups/PersonProfilePage.jsp?personId=<$ customerid $>','650','450')" class="minderLink"><$ buyercompany $><br><$ customer $></a></td>
    <%-- order # --%>
<!--    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><$ order_id $></td> -->
    <%-- order date --%>
    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><%=minderRS.getString("creation_date")%></td>
    <%-- project number --%>
<!--    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><$ projectnumber $></td> -->
    <%-- job number --%>
    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><$ job_id $></td>
    <%-- job link --%>
<!--    <td class="lineitemcenter/*<%=(alt)?"alt\"":"\""%>*/><$ job_link $></td> -->
    <%-- buyer reference --%>
<!--    <td class="lineitemleft<%=(alt)?"alt\"":"\""%>><$ buyer_internal_reference_data $>&nbsp;</td> -->
    <%-- internal reference --%> 
    <td class="lineitemleft<%=(alt)?"alt\"":"\""%>><$ internalref $>&nbsp;</td>
    <%-- job name --%>
    <td class="lineitemleft<%=(alt)?"alt\"":"\""%>><$ job_name $><br>
	<%=(minderRS.getString("quantity")!=null&&minderRS.getString("quantity")!="")?"Qty: " +(minderRS.getString("quantity")):("")%>
	</td>
    <%-- job type --%>
<!--    <td class="lineitemleft<%=(alt)?"alt\"":"\""%>><$ job_type $></td> -->
    <%-- service type --%>
<!--    <td class="lineitemleft<%=(alt)?"alt\"":"\""%>><$ service_type $></td> -->
    <%-- invoice amount --%>
    <td class="lineitemright<%=(alt)?"alt\"":"\""%>><%=formatter.getCurrency(minderRS.getDouble("invoice"))%></td>
    <%-- billed amount --%>
    <td class="lineitemright<%=(alt)?"alt\"":"\""%>><%=formatter.getCurrency(minderRS.getDouble("billed"))%></td>
    <%-- job status --%>
    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><$ shown_status $></td>
	<% if (minderRS.getInt("buyer_contact_id") == Integer.parseInt((String)up.getContactId())) { %>
    <%-- Next Action --%>
    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><a class="minderACTION" href="<$ actionform $>?jobId=<$ job_id $>" class="lineitemright<%=(alt)?"alt\"":"\""%><b><$ consolecustomer $></b></a>
    <% String invoiceQuery = "SELECT ai.id 'id' FROM ar_invoice_details aid,ar_invoices ai LEFT JOIN ar_collection_details acd ON ai.id=acd.ar_invoiceid WHERE ai.id = aid.ar_invoiceid AND acd.ar_invoiceid IS NULL AND status_id != 2 AND ai.ar_invoice_type != 3 AND aid.jobid = " + minderRS.getString("job_id");
       ResultSet invoiceRS = st2.executeQuery(invoiceQuery);
       while (invoiceRS.next()) { %>
          <a class="minderLink" href="/minders/workflowforms/ReviewInvoice.jsp?invoiceId=<%=invoiceRS.getString("id")%>&jobId=<$ job_id $>"><br>Pay Invoice</a>
       <% } %>&nbsp;
	</td><%-- other actions --%>
    <td class="lineitemleft<%=(alt)?"alt\"":"\""%> nowrap>&nbsp;&nbsp;<a class="minderLink" href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<$ job_id $>&actingRole=buyer','700','300')">Details</a>
    | <a class="minderLink" href="/files/JobFileViewer.jsp?jobId=<$ job_id $>">Files</a>
    | <a class="minderLink" href="/files/useremailform.jsp?jobId=<$ job_id $>&target=vendor">Email Vendor</a>
    </td><%
    } else { 
    %><%-- Next Action --%>
    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><a class="minderACTION" href="<$ actionform $>?jobId=<$ job_id $>" class="lineitemright<%=(alt)?"alt\"":"\""%><b><$ consolereseller $></b></a> <%
       String compQuery = "SELECT a.group_id FROM form_messages a LEFT OUTER JOIN form_messages b on a.job_id = b.job_id AND a.group_id = b.group_id AND ((a.form_id = 1 OR a.form_id = 2) AND b.form_id = 8) WHERE (a.form_id = 1 OR a.form_id = 2) AND b.group_id IS NULL AND a.job_id = " + minderRS.getString("job_id");
       ResultSet compRS = st2.executeQuery(compQuery);
       while (compRS.next()) { %>
          <a class="minderLink" href="/minders/workflowforms/AdHocApproveCompProof.jsp?groupId=<%=compRS.getInt("group_id")%>&jobId=<$ job_id $>"><br>Appvl Pend</a><%
	   }
       String invoiceQuery = "SELECT ai.id 'id' FROM ar_invoice_details aid,ar_invoices ai LEFT JOIN ar_collection_details acd ON ai.id=acd.ar_invoiceid WHERE ai.id = aid.ar_invoiceid AND acd.ar_invoiceid IS NULL AND  aid.jobid = " + minderRS.getString("job_id");
       ResultSet invoiceRS = st2.executeQuery(invoiceQuery);
       while (invoiceRS.next()) { %>
          <a class="minderLink" href="/minders/workflowforms/ReviewInvoice.jsp?invoiceId=<%=invoiceRS.getString("id")%>&jobId=<$ job_id $>"><br>Bill Pend</a>
       <% } %>&nbsp;
	</td>
    <%-- other actions --%>
    <td class="lineitemleft<%=(alt)?"alt\"":"\""%> nowrap>
	&nbsp;&nbsp;<a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<$ job_id $>','700','300')" class="minderLink">Details</a> 
	| <a href="/files/JobFileViewer.jsp?jobId=<$ job_id $>" class="minderLink">Files</a> 
	| <a class="minderLink" href="/files/useremailform.jsp?jobId=<$ job_id $>&target=client">Email Buyer</a> 
    </td><%
    } 
    %>  </tr>
  </iterate:dbiterate>
</table>
</body>
</html><%st.close();st2.close();conn.close();%>