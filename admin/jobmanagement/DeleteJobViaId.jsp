<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<% validator.setReqTextFields(new String[]{"jobId"}); %>
<html>
<head>
<title>Delete Job?</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<script language="JavaScript">
function verifyDeletion(){
	if(confirm("Are you sure you want to delete: " + document.forms[0].jobId.value+"?")){
		submitForm();
	}
}
</script>
<jsp:getProperty name="validator" property="javaScripts" />
<script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" text="#000000">
<form method="post" action="/servlet/com.marcomet.admin.data.SimpleDeleteJobServlet">
<table>
	<tr>
		<td colspan="2">
		<b><font color="red"><%=(request.getAttribute("errorMessage")==null)?"":(String)request.getAttribute("errorMessage")%></font>
		<%=(request.getAttribute("returnMessage")==null)?"":(String)request.getAttribute("returnMessage")%></b></td>
	</tr>
	<tr>
		<td>Job Id:</td><td><input type="text" name="jobId" value="">
	</tr>
	<tr>
		<td>&nbsp;</td><td><input type="button" value="Delete Job" onClick="verifyDeletion()"></td>
	</tr>
</table>
<input type="hidden" name="errorPage" value="/admin/jobmanagement/DeleteJobViaId.jsp">
<input type="hidden" name="$$Return" value="[/admin/jobmanagement/DeleteJobViaId.jsp]">
</form>
</body>
</html>
