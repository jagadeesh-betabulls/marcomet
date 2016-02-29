<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
String customerPO=request.getParameter("customerPO");
String removeCode=((request.getParameter("removeCode")==null)?"":request.getParameter("removeCode"));
String titleText="Apply Customer Reference/PO Number";
String customerPOStatus="";
String jobId=((request.getParameter("jobId")!=null)?request.getParameter("jobId"):"");
String submitted=((request.getParameter("submitted")!=null)?request.getParameter("submitted"):"");
if(!removeCode.equals("")){
		session.removeAttribute("customerPO");
		titleText="";
}else if(customerPO !=null && customerPO.equals("")){
	titleText="Error - No Customer Reference/PO Number supplied";
}else if (request.getParameter("submitted")!=null){
		session.setAttribute("customerPO",customerPO);
		titleText="";
}

if (titleText.equals("")){
	%><html><head><script>parent.window.opener.location="/catalog/checkout/Checkout.jsp?coStep=step2";setTimeout('close()',500);</script></head><body></body></html><%
}else{
%><html>
<head>
  <title><%= titleText %></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script>
	function removecustomerPO(){
		document.forms[0].customerPO.value='';
		document.forms[0].removeCode.value='true';
		document.forms[0].submit();
	}
</script>
<body>
<form method="post" action="/popups/customerPO.jsp">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr><td class="tableheader"><%=titleText%></td></tr>
  <tr><td class="lineitems" align="center">
      <input type="text" name="customerPO" size='30' value="<%=((customerPO==null)?((session.getAttribute("customerPO")!=null)?session.getAttribute("customerPO").toString():""):customerPO) %>"></td></tr>
<tr><td align="center">
<input type="submit" value="Update" >&nbsp;&nbsp;<%
if(session.getAttribute("customerPO")!=null && !session.getAttribute("customerPO").toString().equals("")){
	%><input type="button" value="Remove Reference Number" onClick="removecustomerPO();" >&nbsp;&nbsp;<%
}
%><input type="button" value="Cancel" onClick="self.close()" ></td></tr>
</table>
<input type="hidden" name="submitted" value="true">
<input type="hidden" name="removeCode" value="">
<input type="hidden" name="jobId" value="<%=jobId%>">
<input type="hidden" name="$$Return" value="<script><%=((request.getParameter("refreshOpener")!=null)?"":"parent.window.opener.location.reload();")%>setTimeout('close()',500);</script>">
<%=((request.getParameter("autosubmit")!=null && request.getParameter("autosubmit").equals("true"))?"<script>document.forms[0].submit()</script>":"")%>
</form></body>
</html><%
}
%>