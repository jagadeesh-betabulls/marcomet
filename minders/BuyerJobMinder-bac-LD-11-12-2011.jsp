<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.jdbc.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<% UserProfile up = (UserProfile)session.getAttribute("userProfile");
   SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); %>
<html>
<head>
  <title>Buyer Job Minder</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=shs.getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body background="<%=shs.getSiteHostRoot()%>/images/back3.jpg">
<p class="Title">Jobs Console</p>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
  <tr> 
    <td> 
      <p>&nbsp;</p>
    </td>
  </tr>
  <tr> 
    <td class="label" align="right"><%
    String archiveFilter = "";
    String buyerFilter = "";
    String buyerSupv = "";
%>
<!-- archiveFilter -->
<%
    if (request.getParameter("archiveFilter") != null) {
       archiveFilter = request.getParameter("archiveFilter");
       session.setAttribute("archiveFilter", request.getParameter("archiveFilter"));
    } else if (session.getAttribute("archiveFilter") != null) {
       archiveFilter = (String)session.getAttribute("archiveFilter");
    } else {
       archiveFilter = " AND j.status_id != 120 AND j.status_id != 9 ";
       session.setAttribute("archiveFilter", " AND j.status_id != 120 AND j.status_id != 9 ");
    } %>
<!-- buyerFilter -->
<%
    if (request.getParameter("buyerFilter") != null) {
       buyerFilter = request.getParameter("buyerFilter");
       session.setAttribute("buyerFilter", request.getParameter("buyerFilter"));
    } else if (session.getAttribute("buyerFilter") != null) {
       buyerFilter = (String)session.getAttribute("buyerFilter");
    } else {
       buyerFilter = " AND o.buyer_contact_id = " + up.getContactId() + "";
       session.setAttribute("buyerFilter", " AND o.buyer_company_id = " + up.getCompanyId() + "");
    } %>
      <form method="post" action="">
<%
    String sql;
%>
        <!-- Buyer Rep Filter -->
        <!-- Check role for view all or only self.  Role = 9 means Buyer Supv, show all Buyers when buyer_view = 1 -->
        <%
	sql = "SELECT cont.id, cr.contact_role_id, c.company_name 'companyname', cont.lastname 'lastname', cont.firstname  'firstname' FROM companies c, contacts cont LEFT JOIN contact_roles cr ON cr.contact_id = cont.id WHERE cont.id = " + up.getContactId() + " AND cont.companyid = c.id AND ((c.buyer_view=0) OR (c.buyer_view = 1 AND cr.site_host_id = " + shs.getSiteHostId() + " AND cr.contact_role_id = 9))";
		Connection conn = DBConnect.getConnection();
		Statement st = conn.createStatement();
		Statement st2 = conn.createStatement();
		ResultSet rs7 = st.executeQuery(sql);
		while (rs7.next()) {
			buyerSupv = "1";
			}
%>
<!-- end check for Buyer Supv role -->
<!-- if Buyer Supv, view all Buyers or select -->
<%		if (buyerSupv.equals("1")) { %>
        Buyer:&nbsp; 
        <select name="buyerFilter">
          <option selected value=" AND 1 = 0 ">- select -</option>
          <% if (buyerFilter.equals(" AND o.buyer_company_id = " + up.getCompanyId() + "")) { %>  <!-- if already set to All, show All selected -->
	          <option selected value=" AND o.buyer_company_id = <%=up.getCompanyId()%>">All</option>
			<% } else { %>
          <option value=" AND o.buyer_company_id = <%=up.getCompanyId()%>">All</option>
			<% } %>
          <%
          sql = "SELECT c.id , c.company_name 'companyname', cont.lastname 'lastname', cont.id, cont.firstname 'firstname' FROM jobs j, companies c, projects p, orders o, contacts cont WHERE j.project_id = p.id AND p.order_id = o.id  AND o.buyer_company_id = c.id AND c.id = " + up.getCompanyId() + " AND o.site_host_id = " + shs.getSiteHostId() + " AND cont.companyid=c.id GROUP BY cont.id ORDER BY companyname, cont.lastname, cont.firstname";
          ResultSet rs2 = st.executeQuery(sql);
          while (rs2.next()) {
		      if (buyerFilter.equals(" AND o.buyer_contact_id = " + rs2.getString("cont.id")+ "")) { %>  <!-- if buyer already set, show that selected -->
          <option selected value=" AND o.buyer_contact_id = <%=rs2.getString("cont.id")%>"><%=rs2.getString("companyname")%> 
          - <%=rs2.getString("firstname")%> <%=rs2.getString("lastname")%> - <%=rs2.getString("cont.id")%></option>
          <% } else { %>
          <option value=" AND o.buyer_contact_id = <%=rs2.getString("cont.id")%>"><%=rs2.getString("companyname")%> 
          - <%=rs2.getString("firstname")%> <%=rs2.getString("lastname")%> - <%=rs2.getString("cont.id")%></option>
			<% } } %>
        </select>
		<% } %>  <!-- End Buyer Rep Filter --> <!-- end else, end while -->
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
        &nbsp;
        <input type="submit" name="Submit" value="Filter">
      </form>
    </td>
  </tr>
</table>
<% boolean alt = true;
   int minderFilter = shs.getBuyerMinderFilter();
   StringBuffer minderQuery = new StringBuffer();
   minderQuery.append("SELECT o.id AS 'order_id', DATE_FORMAT(o.date_created,'%m/%d/%y') AS 'creation_date', j.id AS 'job_id', j.job_name AS 'job_name', ljt.value AS 'job_type', lst.value AS 'service_type', j.status_id AS 'status_id', j.collected 'collected', j.price AS 'total_job_price', j.shipping_price AS 'shipping', j.sales_tax AS 'sales_tax', j.billable AS 'invoice', j.billed, j.escrow_amount AS 'escrow', jfs.shownstatus AS 'shown_status', consolecustomer, actionform, whosaction, c1.company_name 'vendor', c2.company_name 'sitehost', j.buyer_internal_reference_data AS 'buyer_ref', p.id 'projectnumber', o.buyer_contact_id 'customerid', CONCAT(c.firstname,' ',c.lastname) 'customer',  c3.company_name 'buyercompany', o.site_host_contact_id 'sitehostcontactid', j.vendor_contact_id 'vendorcontactid', cv.firstname 'vfirstname', cv.lastname 'vlastname', j.quantity 'quantity' ");
   minderQuery.append("FROM orders o, projects p, jobflowstates jfs, lu_job_types ljt, lu_service_types lst, companies c1, companies c2, companies c3, vendors v, site_hosts sh, contacts c, contacts cv,jobs j ");
   minderQuery.append("WHERE o.id = p.order_id AND p.id = j.project_id AND j.status_id = jfs.statusnumber AND j.service_type_id = lst.id and j.job_type_id = ljt.id AND v.id = j.vendor_id AND v.company_id = c1.id AND sh.id = o.site_host_id AND sh.company_id = c2.id AND o.buyer_company_id = c3.id AND o.buyer_contact_id = c.id AND j.vendor_contact_id = cv.id");
   switch(minderFilter) {
      case 1: minderQuery.append(" AND (1 = 1 OR sh.id = " + shs.getSiteHostId() + ")  "); 
              break;
      case 2: minderQuery.append(" AND sh.id = " + shs.getSiteHostId() + " ");
              break;
      case 3: minderQuery.append("  AND (( v.company_id = ");
              minderQuery.append(shs.getSiteHostCompanyId());
              minderQuery.append(") OR sh.id = " + shs.getSiteHostId() + ") ");
              break;
   }
   minderQuery.append(archiveFilter);
   minderQuery.append(buyerFilter);
   minderQuery.append(" ORDER BY o.date_created, j.project_id, j.id ASC ");%><!-- <%=minderQuery%> --><%
   ResultSet minderRS = st2.executeQuery(minderQuery.toString());
   request.setAttribute("minderRS", minderRS); %>
<table cellspacing="0" cellpadding="3" width="100%" border="1" bordercolor="#000000">
  <tr bordercolor="#000000"> 
    <td class="minderheaderleft"   height="0" width="0">Buyer</td>
    <td class="minderheaderleft"   height="0" width="0">Rep</td><%
    if (minderFilter != 2) { %>
    <td class="minderheaderleft"   height="0" width="0">Site Host</td><% 
	} %>
<!--    <td class="minderheadercenter" height="0" width="0">Order</td> -->
    <td class="minderheaderleft"   height="0" width="0">Order Date</td>
<!--    <td class="minderheaderleft"   height="0" width="0">Project</td> -->
    <td class="minderheadercenter" height="0" width="0">Job #</td>
    <td class="minderheaderleft"   height="0" width="0">Buyer Ref.</td>
    <td class="minderheaderleft"   height="0" width="0">Job Name</td>
<!-- Suppress Job Type and Service Type
    <td class="minderheaderleft"   height="0" width="0">Service</td>
-->
    <td class="minderheaderright"  height="0" width="0" nowrap>Total<br>Billed<br>Collected</td>
    <td class="minderheadercenter" height="0" width="0">Status</td>
    <td class="minderheadercenter" height="0" width="0">Action Items</td>
    <td class="minderheaderleft"   height="0" width="0">Other Actions</td>
  </tr>
  <iterate:dbiterate name="minderRS" id="k">
  <% alt = (alt)?false:true; %>
  <tr>
    <%-- customer --%>
    <td class="lineitemleft<%=(alt)?"alt\"":"\""%>><a href="javascript:pop('/popups/PersonProfilePage.jsp?personId=<$ customerid $>','650','450')" class="minderLink"><$ buyercompany $><br><$ customer $></a></td>
    <%-- vendor --%>
    <td class="lineitemleft<%=(alt)?"alt\"":"\""%>><a href="javascript:pop('/popups/PersonProfilePage.jsp?personId=<$ vendorcontactid $>','650','450')" class="minderLink"><$ vfirstname $> <$ vlastname $></a></td>
    <% if (minderFilter != 2) { %>
    <%-- site --%>
    <td class="lineitemleft<%=(alt)?"alt\"":"\""%>><a href="javascript:pop('/popups/PersonProfilePage.jsp?personId=<$ sitehostcontactid $>','650','450')" class="minderLink"><$ sitehost $></a></td>
    <% } %>
	
    <%-- order # --%>
<!--    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><$ order_id $></td> -->
    <%-- order date --%>
    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><%=minderRS.getString("creation_date")%></td>
    <%-- project number --%>
<!--    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><$ projectnumber $></td> -->
    <%-- job number --%>
    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><$ job_id $></td>
    <%-- buyer ref --%>
    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><$ buyer_ref $>&nbsp;</td>
    <%-- job type --%>
    <td class="lineitemleft<%=(alt)?"alt\"":"\""%>><$ job_name $><br>
	<%=(minderRS.getString("quantity")!=null&&minderRS.getString("quantity")!="")?"Qty: " +(minderRS.getString("quantity")):("")%>
	</td>
<!-- Suppress Job Type and Service Type
    <%-- service type --%>
    <td class="lineitemleft<%=(alt)?"alt\"":"\""%>><$ service_type $></td>
-->
    <%-- job amounts --%>
    <td class="lineitemright<%=(alt)?"alt\"":"\""%>><%=formatter.getCurrency(minderRS.getDouble("invoice"))%><br><%=formatter.getCurrency(minderRS.getDouble("billed"))%><br><%=formatter.getCurrency(minderRS.getDouble("collected"))%></td>
    <%-- job status --%>
    <td class="lineitemcenter<%=(alt)?"alt\"":"\""%>><$ shown_status $></td>
    <%-- Next Action --%>
	<td class="lineitemcenter<%=(alt)?"alt\"":"\""%>>
	<% boolean makeBreak = false;
       if (minderRS.getInt("whosaction") == 1) { %>
       <a class="minderACTION" href="<$ actionform $>?jobId=<$ job_id $>" class="lineitemright<%=(alt)?"alt\"":"\""%><b><$ consolecustomer $></b></a>
	<% } else { %>
       <$ consolecustomer $><%
	   }
       if (minderRS.getString("consolecustomer") != null && !minderRS.getString("consolecustomer").equals("")) makeBreak = true;
       String compQuery = "SELECT a.group_id FROM form_messages a LEFT OUTER JOIN form_messages b on a.job_id = b.job_id AND a.group_id = b.group_id AND ((a.form_id = 1 OR a.form_id = 2) AND b.form_id = 8) WHERE (a.form_id = 1 OR a.form_id = 2) AND b.group_id IS NULL AND a.job_id = " + minderRS.getString("job_id");
       ResultSet compRS = st.executeQuery(compQuery);
       while (compRS.next()) { %>
          <a class="minderACTION" href="/minders/workflowforms/AdHocApproveCompProof.jsp?groupId=<%=compRS.getInt("group_id")%>&jobId=<$ job_id $>"><%=(makeBreak ? "<br>":"")%>Review Work</a><%
makeBreak = true;
	   }
       if (minderRS.getDouble("billed") - minderRS.getDouble("collected") > .01 || minderRS.getDouble("billed") - minderRS.getDouble("collected") < -.01) { 		
String invoiceQuery = "SELECT ari.id 'id', ari.invoice_number, ari.creation_date, ari.ar_invoice_amount, sum(arcd.payment_amount) as invoice_payments, ari.ar_invoice_amount - (if(sum(arcd.payment_amount) is null,0,sum(arcd.payment_amount))) as invoice_balance FROM ar_invoice_details arid,ar_invoices ari LEFT JOIN ar_collection_details arcd on arcd.ar_invoiceid=ari.id WHERE ari.id = arid.ar_invoiceid AND arid.jobid = " + minderRS.getString("job_id") + " GROUP BY ari.invoice_number having (invoice_balance) >.01 or (invoice_balance) <-.01 ORDER BY ari.creation_date";
       ResultSet invoiceRS = st.executeQuery(invoiceQuery);
       while (invoiceRS.next()) { %>
          <a class="minderACTION" href="/minders/workflowforms/ReviewInvoice.jsp?invoiceId=<%=invoiceRS.getString("id")%>&jobId=<$ job_id $>"><%=(makeBreak ? "<br>":"")%>Print Invoice #<%=invoiceRS.getString("ari.invoice_number")+"&nbsp;/&nbsp;"+formatter.getCurrency(invoiceRS.getString("invoice_balance"))+ ((invoiceRS.getDouble("invoice_balance")>0)?"&nbsp;Due ":"&nbsp;Credit ")%></a>
       <% makeBreak = true; } } %>&nbsp
    </td>
    <%-- other actions --%>
    <td class="lineitemleft<%=(alt)?"alt\"":"\""%> nowrap>&nbsp;&nbsp;<a class="minderLink" href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<$ job_id $>','700','300')">Details</a>
    | <a class="minderLink" href="/files/JobFileViewer.jsp?jobId=<$ job_id $>">Files</a>
    | <a class="minderLink" href="/files/useremailform.jsp?jobId=<$ job_id $>&target=vendor">Email Rep</a> 
    </td>
  </tr>
  </iterate:dbiterate>
</table>
</body>
</html><%
try{
	st.close();
	st2.close();
	conn.close();
}catch (Exception e){

}finally{
	st=null;
	st2=null;
	conn=null;
}
%>
