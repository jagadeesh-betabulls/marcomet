<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.workflow.*,com.marcomet.users.security.*" %>
<%@ include file="/includes/SessionChecker.jsp" %>

<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
	String[] totfs = {"file0","file1","file2","material0","material1","material2"};
	validator.setThisOrThatFields(totfs);
%>

<html>
  <head>
    <title>Submit Work</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />  
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script>
function adjustStatus() {
	if (document.forms[0].approvalType[0].checked) {
		document.forms[0].stage.value = "interim";
		document.forms[0].submit();
	} else if (document.forms[0].approvalType[1].checked) {
		document.forms[0].stage.value = "final";
		document.forms[0].submit();
	} else {
		alert('Please indicate the stage of materials to be approved.');
	}
}
</script>
<!-- carl's new stuff -->
<body class="body" onLoad="MM_preloadImages('/images/buttons/continueover.gif','/images/buttons/cancelbtover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit" enctype="multipart/form-data">
<!-- end of carl's new stuff -->
  <p class="Title">Submit Work for Approval</p>
  <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
  <p> <b>Instructions: </b>Please attach any work you would like to see approved 
    by the Customer. You may also provide a message with specific instructions. 
    The Customer will be asked to indicate their approval of the work referenced 
    on this form. If multiple choices are available they will only be able to 
    select the one for which they desire work to be continued.</p>
<!--
  <p><b>Interim Work Approvals</b>: Choose this if you are seeking your client's 
    approval at a preliminary stage of the work process (i.e. to approve of your 
    general direction of work). You may re-submit later for final approval before 
    your work is to be completed and delivered.</p>
  <p><b>Final Work Approvals:</b> Choose this if you are seeking your client's 
    approval at a final stage of your work process, where the work approved will 
    then be completed and delivered.</p>
  <table>
  <tr> 
    <td class="label">Please indicate the stage of materials to be approved:</td>
    <td class="label"><input type="radio" name="approvalType" value="1"> Interim Work Approval </td>
    <td class="label"><input type="radio" name="approvalType" value="2"> Final Work Approval </td>
  </tr>
</table>
-->
<input type="hidden" name="approvalType" value="1">
<p>
  <span class="label">Sender's Message:</span><br>
  <textarea cols="80" rows=3 name="message"></textarea><br>
</p>

<table>
  <tr>
    <td class="contentstitle">File Upload</td>
  </tr>
  <tr>
    <td><jsp:include page="/includes/UploadFilesInclude.jsp" flush="true"><jsp:param name="showComments" value="true" /></jsp:include></td>
  </tr>
  <tr>
    <td class="contentstitle">Physical Shipment Info</td>
  </tr>
  <tr>
    <td><jsp:include page="/includes/MaterialFilesInclude.jsp" flush="true"><jsp:param name="showComments" value="true" /></jsp:include></td>
  </tr>
  <tr>
    <td><jsp:include page="/includes/ShippingDataInclude.jsp" flush="true"/></td>
  </tr>
</table>
<br>
<!-- carl's new stuff -->
<br>
  <table border="0" width="20%" align="center">
    <tr>
      <td width="24%"> 
        <div align="center"><a href="/minders/JobMinderSwitcher.jsp" class="greybutton">Cancel</a></div>
      </td>
      <td width="1%">&nbsp;</td>
      <td width="24%"> 
        <div align="center"><a href="javascript:document.forms[0].submit()" class="greybutton">Submit</a> 
        </div>
      </td>
  </tr>
</table>
<!-- end of carl's new stuff -->
<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
<input type="hidden" name="nextStepActionId" value="<%=request.getParameter("actionId")%>">
<input type="hidden" name="redirect" value="<%=(((RoleResolver)session.getAttribute("roles")).isVendor())?"/minders/JobMinderSwitcher.jsp":"/minders/JobMinderSwitcher.jsp"%>">
<input type="hidden" name="status" value="Submitted">
<input type="hidden" name="stage" value="">
<input type='hidden' name="shippingStatus" value="interim">
<input type="hidden" name="category" value="For Appvl">
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
</form>
</body>
</html>
