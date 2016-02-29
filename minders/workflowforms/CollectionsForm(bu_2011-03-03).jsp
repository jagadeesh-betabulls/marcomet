<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.environment.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="cB" class="com.marcomet.beans.SBPContactBean" scope="page" />
<jsp:setProperty name="cB" property="*"/>  
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
%>
<%-- How to return info to this page when errored out --%>
<% 
	if(request.getParameter("firstName")==null){
		String loginId = (session.getAttribute("contactId")==null)?"":(String)session.getAttribute("contactId"); 
		cB.setContactId(loginId);
	}
%>
<html>
<head>
  <title>Check out <%=Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getCCommerce())%></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body onLoad="MM_preloadImages('/images/buttons/continueover.gif','/images/buttons/cancelbtover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<span class="Title">Credit Card Payment Processing Form</span> 
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">
   <%	
	String sql1 = "select * from ar_invoices where id = " +request.getParameter("invoiceId");
	String sql2 = "select if(sum(arc.payment_amount) is null,0,sum(arc.payment_amount))  as 'amount_paid',arid.ar_invoice_amount as 'invoice_amount',arid.jobid as 'jobid',(arid.ar_invoice_amount - if(sum(arc.payment_amount) is null,0,sum(arc.payment_amount))) as 'ar_invoice_amount' from ar_invoice_details arid left join ar_collection_details arc  on arid.ar_invoiceid=arc.ar_invoiceid where arid.ar_invoiceid = "+ request.getParameter("invoiceId")+"  group by arid.ar_invoiceid";
	ResultSet rsInvoice = st.executeQuery(sql1);
	ResultSet rsInvoiceDetail = st2.executeQuery(sql2);
	rsInvoice.next();
	rsInvoiceDetail.next();	
	boolean balanceDue=rsInvoiceDetail.getDouble("ar_invoice_amount")>0;
%><br><div style="align:center;border-color: #b2b2b2;border-style: solid;border-width: 1px;width:350">
  <table border=0>
    <tr> 
      <td class="subtitle"  valign="top" colspan=4><u>Summary for Invoice #<%= rsInvoice.getString("id")%></u></td></tr>
    <tr> 
      <td >&nbsp;</td>
      <td class="label" valign="top" align="right">Invoice Amount: </td>
      <td class="catalogTITLE" valign="top"> 
        <div align="right"><%= formater.getCurrency(rsInvoiceDetail.getDouble("invoice_amount")) %> </div>
      </td>
      <td class="catalogTITLE">&nbsp;</td>
    </tr>
        <tr> 
      <td >&nbsp;</td>
      <td class="label" valign="top" align="right">Amount Paid: </td>
      <td class="catalogTITLE" valign="top"> 
        <div align="right"><%= formater.getCurrency(rsInvoiceDetail.getDouble("amount_paid")) %> </div>
      </td>
      <td class="catalogTITLE">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan=4><hr size=1></td></tr>
        <tr> 
      <td >&nbsp;</td>
      <td class="subtitle" valign="top" align="right"><%=((balanceDue)?"Balance to be Charged to CC: ":"No Balance Due at this time.")%></td>
      <td class="subtitle" valign="top"> 
        <div align="right"><%= formater.getCurrency(rsInvoiceDetail.getDouble("ar_invoice_amount")) %> </div>
      </td>
      <td class="catalogTITLE">&nbsp;</td>
    </tr>
  </table></div><% 
 if(balanceDue){
 %><jsp:include page="/includes/ProcessCredCard.jsp" flush="true"></jsp:include>

 <table width=100%>
    <tr> 
      <td width="46%" align="right"><a href="javascript:history.back(1)" class ="greybutton" >Cancel</a></td>
      <td width="4%">&nbsp;</td>
      <td width="46%"><a href="javascript:document.forms[0].submit()" class="greybutton">Continue</a></td>
    </tr>
  </table>
  
<input type="hidden" name="dollarAmount" value="<%= rsInvoiceDetail.getDouble("ar_invoice_amount")%>">	
<input type="hidden" name="id" value="<%= rsInvoice.getString("id") %>" >
<input type="hidden" name="jobId" value="<%= rsInvoiceDetail.getString("jobid") %>" >
<input type="hidden" name="invoiceId" value="<%= request.getParameter("invoiceId")%>">
<input type="hidden" name="errorPage" value="/contents/CollectionsForm.jsp">
<input type="hidden" name="nextStepActionId" value="91">
<input type="hidden" name="companyId" value="<%=cB.getCompanyIdString()%>">
<input type="hidden" name="statusId" value="2">
<input type="hidden" name="contactId" value="<%=session.getAttribute("contactId").toString()%>">
<input type="hidden" name="$$Return" value="[/minders/workflowforms/CollectionsForm.jsp?invoiceId=<%=request.getParameter("invoiceId")%>]">
<input type="hidden" name="redirect" value="[/contents/FrameBreaker.jsp]">
<input type="hidden" name="formChangedPhones" value="<%= (request.getParameter("formChangedPhones") == null )?"0":request.getParameter("formChangedPhones") %>">
<input type="hidden" name="formChangedLocations" value="<%= (request.getParameter("formChangedLocations") == null )?"0":request.getParameter("formChangedLocations") %>">
<input type="hidden" name="formChangedContact" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedContact") %>">
<input type="hidden" name="formChangedCompany" value="<%= (request.getParameter("formChangedCompany") == null )?"0":request.getParameter("formChangedCompany") %>">
<%	session.setAttribute("errorMessage","");%>
<%}else{%>
<a href="javascript:parent.window.location.replace('http://<%=((com.marcomet.environment.SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName()%>/');" class="greybutton">Continue</a>
<%}%>
</form>
</body>
</html><%conn.close(); %>
