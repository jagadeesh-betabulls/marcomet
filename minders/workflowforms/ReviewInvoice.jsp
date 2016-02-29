<%@ page import="java.text.*, java.sql.*, com.marcomet.jdbc.*" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<html>
<head>
  <title>Invoice <%= request.getParameter("invoiceId")%></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script>
function ccPay(){
document.forms[0].action="/minders/workflowforms/CollectionsForm.jsp";
document.forms[0].submit();
}
</script>
</head>
<body class="label" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit"><%
	String sql1 = "select * from ar_invoices where id = " +request.getParameter("invoiceId");
	String sql2 = "select * from ar_invoice_details where ar_invoiceid = " + request.getParameter("invoiceId");
	
	String invoiceId = request.getParameter("invoiceId");
	String id="";
	String paymentOption="";
	String jobId="";
	
	Connection conn = DBConnect.getConnection();
	Statement st1 = conn.createStatement();
	Statement st2 = conn.createStatement();
	ResultSet rsInvoice = st1.executeQuery(sql1);
	ResultSet rsInvoiceDetail = st2.executeQuery(sql2);
	if(rsInvoice.next()){
	
		id=rsInvoice.getString("id");
		paymentOption=rsInvoice.getString("payment_option");
	}
	if(rsInvoiceDetail.next()){
		jobId=rsInvoiceDetail.getString("jobid");
		
	}	
%>
<jsp:include page="/minders/workflowforms/PrintInvoice.jsp" flush="true"><jsp:param  name="invoiceId" value="<%= invoiceId %>" /></jsp:include>

<input type="hidden" name="jobId" value="<%= jobId  %>" >
<input type="hidden" name="id" value="<%= id %>" >
<input type="hidden" name="invoiceId" value="<%= id %>" >
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
<input type="hidden" name="redirect" value="[/minders/JobMinderSwitcher.jsp]">
<input type="hidden" name="nextStepActionId" value="90">
<input type="hidden" name="statusId" value="2">
<input type="hidden" name="invoiceNumber" value="<%=invoiceId%>">
<input type="hidden" name="contactId" value="<%=session.getAttribute("contactId").toString()%>">
</form>
<div align="center"> <%=paymentOption%>
  <table border=0 align="center" >
    <tr> 
<!--      <td width="141"> <a href="javascript:pop('/minders/workflowforms/PrintInvoice.jsp?invoiceId=<%=request.getParameter("invoiceId")%>','640','480')" class="greybutton">View&nbsp;Printable&nbsp;Invoice</a> 
      </td> --><%if (paymentOption.equals("1")){
	%><td width="156"><a href="javascript:parent.window.location.replace('https://<%=((com.marcomet.environment.SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName()%>/frames/InnerFrameset.jsp?contents=/minders/workflowforms/CollectionsForm.jsp?invoiceId=<%=id%>');" class="greybutton"> 
        Continue&nbsp;and&nbsp;Pay&nbsp;Online</a></td>
      <td width="281"><a href="/minders/JobMinderSwitcher.jsp" target="main" class="menuLINK">Continue&nbsp;--&nbsp;I've&nbsp;printed&nbsp;my&nbsp;bill&nbsp;and&nbsp;will&nbsp;fax&nbsp;payment</a></td>
      <%}%>
      <%if (paymentOption.equals("2")){%>
      <td width="393"><!--<a href="javascript:document.forms[0].submit()" class="greybutton">--><a href="/minders/JobMinderSwitcher.jsp" target="main" class="menuLINK">Continue&nbsp;--&nbsp;I've&nbsp;printed&nbsp;my&nbsp;bill&nbsp;and&nbsp;will&nbsp;send&nbsp;a check</a> 
        <%}%>
      <%if (paymentOption.equals("3")){%>
      <td width="156"><a href="javascript:parent.window.location.replace('https://<%=((com.marcomet.environment.SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getDomainName()%>/frames/InnerFrameset.jsp?contents=/minders/workflowforms/CollectionsForm.jsp?invoiceId=<%=id%>');" class="greybutton"> 
        Continue&nbsp;and&nbsp;Pay&nbsp;Online</a></td>
      <td width="393"><!--<a href="javascript:document.forms[0].submit()" class="greybutton">--><a href="/minders/JobMinderSwitcher.jsp" target="main" class="menuLINK">Continue&nbsp;--&nbsp;I've&nbsp;printed&nbsp;my&nbsp;bill&nbsp;and&nbsp;will&nbsp;fax or mail&nbsp;payment.</a> 
        <%}%>
      </td>
    </tr>
  </table>
</div>
</body>
</html>
<%
	st1.close();
	st2.close();
	conn.close();
%>
