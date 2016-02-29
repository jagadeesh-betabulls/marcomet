<%@ page import="com.marcomet.users.security.*" %>
<html>
<head> 
  <title>Job Details Page</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<%
boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")));
boolean hideAction=false;
String jobId=request.getParameter("jobId");
if (session.getAttribute("roles") != null) {
	if (((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isVendor()  && session.getAttribute("demo")==null) {
		%><%
	} else  {
		%><script>function popw1(url, xSize, ySize){alert('Not available')}</script><%
	}
}%>
</head> 
<body>
<p class="Title">Job Detail Page </p><%
   String actingRole = request.getParameter("actingRole");
   if (actingRole == null) actingRole = "None";
   if ((actingRole.equals("None") && editor) || ((RoleResolver)session.getAttribute("roles")).isSiteHost() && ((RoleResolver)session.getAttribute("roles")).isVendor() ) { %>
<jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>
<table cellpadding=0 cellspacing=5 border=0>
<tr><td valign='top'><jsp:include page="/includes/StatusSummary.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include>
</td><td valign='top' colspan="2"><jsp:include page="/includes/JobName.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include> </td></tr>
<tr><td valign='top'><jsp:include page="/includes/BuyerInternalReferenceData.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include> 
</td><td valign='top'><jsp:include page="/includes/JobLinkData.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>
</td></tr><tr><td valign='top'><jsp:include page="/includes/JobNotes.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
</td><td valign='top'><jsp:include page="/includes/JobVendorNotes.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> </td></tr>
</table>
<jsp:include page="/includes/SubVendorInternalReferenceData.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include> 
<jsp:include page="/includes/CustomerPO.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include> 
<jsp:include page="/includes/VendorRep.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
<jsp:include page="/includes/ClientInfoInclude.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /><jsp:param name="editor" value="<%=editor%>" /></jsp:include>
<jsp:include page="/includes/JobSpecifications.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>
<jsp:include page="/includes/JobChanges.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>
<hr><jsp:include page="/includes/PromoData.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
<jsp:include page="/includes/VendorPriceDetails.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>

<jsp:include page="/includes/TaxInformation.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include><%
if(editor){%><jsp:include page="/popups/POAdjustmentList.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /><jsp:param  name="print" value="false" /></jsp:include><%}else{%><jsp:include page="/includes/ShippingSummary.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include><%}%><jsp:include page="/includes/JobBillingSummary.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include><%
//<!-- If Buyer role on site AND Buyer role on job -->
 } else if ( ((RoleResolver)session.getAttribute("roles")).isVendor() && !actingRole.equals("buyer") ) { 
//<!-- If Vendor role on site and NOT Buyer role on job -->
%><jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
<table width=100% cellpadding=0 cellspacing=5 border=0>
<tr><td valign='top'><jsp:include page="/includes/StatusSummary.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>
</td><td valign='top'><jsp:include page="/includes/JobName.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include> 
</td></tr><tr><td valign='top'><jsp:include page="/includes/JobNotes.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
</td><td valign='top'><jsp:include page="/includes/JobVendorNotes.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
</td></tr></table>
<jsp:include page="/includes/SubVendorInternalReferenceData.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include> 
<jsp:include page="/includes/CustomerPO.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include> 
<jsp:include page="/includes/VendorRep.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
<jsp:include page="/includes/ClientInfoInclude.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /><jsp:param name="editor" value="<%=editor%>" /></jsp:include>
<jsp:include page="/includes/JobSpecifications.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>
<jsp:include page="/includes/JobChanges.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>
<jsp:include page="/includes/VendorPriceDetails.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>
<jsp:include page="/includes/TaxInformation.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include><%
if(editor){%><jsp:include page="/popups/POAdjustmentList.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /><jsp:param  name="print" value="false" /></jsp:include><%}else{%><jsp:include page="/includes/ShippingSummary.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include><%}
%><jsp:include page="/includes/JobBillingSummary.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include><% 


//<!-- if Sitehost role on site and NOT Buyer on job -->
} else if ( ((RoleResolver)session.getAttribute("roles")).isSiteHost() && !actingRole.equals("buyer") ) { %>
<jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
<table cellpadding=0 cellspacing=5 border=0>
<tr><td valign='top'><jsp:include page="/includes/StatusSummary.jsp" flush="true"/>
</td><td valign='top' colspan="2"><jsp:include page="/includes/JobName.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include> 
</td></tr><tr><td valign='top'><jsp:include page="/includes/BuyerInternalReferenceData.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include> 
</td><td valign='top'><jsp:include page="/includes/JobLinkData.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
</td></tr></table><jsp:include page="/includes/JobNotes.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
<jsp:include page="/includes/CustomerPO.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include> 
<jsp:include page="/includes/ClientInfoInclude.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /><jsp:param name="editor" value="<%=editor%>" /></jsp:include>
<jsp:include page="/includes/JobSpecifications.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>
<jsp:include page="/includes/JobChanges.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>
<hr><jsp:include page="/includes/PromoData.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
<jsp:include page="/includes/CustomerPriceDetails.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>
<jsp:include page="/includes/TaxInformation.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include><%
if(editor){%><jsp:include page="/popups/POAdjustmentList.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /><jsp:param  name="print" value="false" /></jsp:include><%}else{%><jsp:include page="/includes/ShippingSummary.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include><%}
%><jsp:include page="/includes/JobBillingSummary.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include><%
//<!-- If Buyer role on site AND Buyer role on job -->
 } else if ( ((RoleResolver)session.getAttribute("roles")).isBuyer() || actingRole.equals("buyer") ) { %>
<jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
<table width=100% cellpadding=0 cellspacing=5 border=0>
<tr><td valign='top'><jsp:include page="/includes/StatusSummary.jsp" flush="true"/>
</td><td valign='top'><jsp:include page="/includes/JobName.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include> 
</td></tr></table><jsp:include page="/includes/BuyerInternalReferenceData.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /></jsp:include> 
<% if ( ((RoleResolver)session.getAttribute("roles")).isVendor() && actingRole.equals("buyer") ) { %>

<jsp:include page="/includes/JobLinkData.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
<% } %>
<jsp:include page="/includes/JobNotes.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include> 
<jsp:include page="/includes/ClientInfoInclude.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /><jsp:param name="editor" value="<%=editor%>" /></jsp:include>
<jsp:include page="/includes/JobSpecifications.jsp" flush="true"/>
<jsp:include page="/includes/JobChanges.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>

<jsp:include page="/includes/CustomerPriceDetails.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>

<jsp:include page="/includes/TaxInformation.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include><%
if(editor){%><jsp:include page="/popups/POAdjustmentList.jsp" flush="true"><jsp:param  name="jobId" value="<%=jobId%>" /><jsp:param  name="print" value="false" /></jsp:include><%}else{%><jsp:include page="/includes/ShippingSummary.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include><%}
%><jsp:include page="/includes/JobBillingSummary.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /></jsp:include>
<% } %>
</body>
</html>