<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<%@ page import="com.marcomet.users.security.*,java.sql.*,java.util.*" %>
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
boolean print = ((request.getParameter("print")==null || !(request.getParameter("print").equals("true")))?false:true);
String actingRole = request.getParameter("actingRole");
String subvendor="";
String jobId=request.getParameter("jobId");
String valStr=request.getParameter("jobId");
boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) && !(print));
boolean sitehost= ((((RoleResolver)session.getAttribute("roles")).isSiteHost()) );
%><html>
<head> 
  <title>Subcontract Purchase Order Page</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head> 
<body>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<div class="Title"><%if (!(print)){%><a href="javascript:popw('/popups/PurchaseOrder.jsp?jobId=<%=request.getParameter("jobId")%>&print=true',800,600)" class=greybutton>PRINT PO</a><%}%>Subcontract Purchase Order from  Vendor to Subvendor</div>
This purchase order represents a subcontract on this job to you as our subvendor / dropshipper. Please review all specifications, notes, etc. about this job below prior to fulfillment and direct any questions about this job to us as the purchaser. Please do not contact our client directly yourself. If product is required to be shipped to our client, please see our client's ship-to address below. If you wish to enter your own corresponding internal order reference/number on this job, you may enter it in the Vendor Reference field editable on this page. Upon completion/delivery of job, please enter job shipping information, if applicable, and mark job complete, then bill us as purchasor directly offline through your own billing system with reference to this PO# for the amount indicated below.<br /><br /><%
   if (actingRole == null) actingRole = "None";
   if ( ((RoleResolver)session.getAttribute("roles")).isVendor() && !actingRole.equals("buyer") ) { 
//If Vendor role on site and NOT Buyer role on job
%><jsp:include page="/includes/POHeader.jsp" flush="true"><jsp:param name="jobId" value="<%=valStr%>" /><jsp:param  name="print" value="<%=print%>" /></jsp:include> 
<table border=0 cellspacing=10 cellspadding=0>
	<tr>
	<td><jsp:include page="/includes/JobName.jsp" flush="true"><jsp:param  name="jobId" value="<%=valStr%>" /><jsp:param  name="print" value="<%=print%>" /></jsp:include></td><td><%
	 }		
	java.sql.ResultSet rs1 = st.executeQuery("SELECT sum(adjustment_amount) 'po_cost',dropship_vendor from jobs j left join po_transactions p on j.id=p.job_id WHERE j.id = " + request.getParameter("jobId")+" group by j.id");
	String poAmount="";
	      if (rs1.next()) { 
				poAmount = formatter.getCurrency(rs1.getDouble("po_cost"));
				subvendor = rs1.getString("dropship_vendor");
	%><table border="0" cellpadding="5" cellspacing="0" >
<tr><td class="tableheader">PO Amount</td></tr><tr>
<td class="lineitems" align="center"><%=poAmount%>  + Out-of-pocket freight cost</td></tr></table><%
	      }else{
		  %><table border="0" cellpadding="5" cellspacing="0" >
<tr><td class="tableheader">PO Amount</td></tr><tr><td class="lineitems" align="center">PO Amount $______________________ + Out-of-pocket freight cost</td></tr></table><% 
		   } %></td></tr><%if (sitehost){%><tr><td><jsp:include page="/popups/POAdjustmentList.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /><jsp:param  name="print" value="<%=print%>" /></jsp:include></td></tr><%}%><tr><td><jsp:include page="/includes/SubVendorInternalReferenceData.jsp" flush="true"><jsp:param  name="jobId" value="<%=valStr%>" /><jsp:param  name="print" value="<%=print%>" /></jsp:include></td><td><jsp:include page="/includes/VendorRep.jsp" flush="true"><jsp:param name="jobId" value="<%=valStr%>" /><jsp:param  name="print" value="<%=print%>" /></jsp:include></td>
	</tr></table><jsp:include page="/includes/JobVendorNotes.jsp" flush="true"><jsp:param name="jobId" value="<%=valStr%>" /><jsp:param  name="print" value="<%=print%>" /></jsp:include>
<jsp:include page="/includes/ClientInfoIncludePO.jsp" flush="true"/>
<jsp:include page="/includes/JobSpecifications.jsp" flush="true"/>
<%if (false){%><hr><jsp:include page="/includes/JobChangesPO.jsp" flush="true"><jsp:param name="jobId" value="<%=valStr%>" /><jsp:param  name="print" value="<%=print%>" /></jsp:include><%}%>
</body>
</html><%st.close();conn.close();%>