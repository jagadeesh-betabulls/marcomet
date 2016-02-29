<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="com.marcomet.users.security.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<html>
<head>
  <title>Job File Viewer</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<script language="javascript"><!--
  function emailFiles() {
    var noFileChecked = true;
  	if (document.forms[0].fileList != null) {
		for(x = 0; x < document.forms[0].fileList.length;x++){
			if(document.forms[0].fileList[x].checked){
				document.forms[0].redirect.value="/files/useremailform.jsp";
				document.forms[0].submit();
				noFileChecked = false;
			}
		}
        if (document.forms[0].fileList.checked) {
            document.forms[0].redirect.value="/files/useremailform.jsp";
            document.forms[0].submit();
            noFileChecked = false;
        }
		if (noFileChecked) {
			alert("You have no files selected for Emailing!");
		}	
	} 
  }
  function downloadFiles() {
  	var noFileChecked = true;
  	if (document.forms[0].fileList != null) {
		for(x = 0; x < document.forms[0].fileList.length;x++){
			if(document.forms[0].fileList[x].checked){
				document.forms[0].submit();
				noFileChecked = false;
			}
		}
		if (document.forms[0].fileList.checked) {
                document.forms[0].submit();
                noFileChecked = false;
		}
		if (noFileChecked) {
			alert("You have no files selected for download!");
		}	
	} 
  }
//--></script>
<body background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.files.FileManagementServlet">
<p class="Title">Job File History<br></p>
<div align="right" class="body"><i>You may add files to this job --></i><a href="javascript:pop('/files/upload.jsp?jobId=<%=request.getParameter("jobId")%>',600,300)" class="minderACTION" >Upload 
  File(s)</a> | <a href="/files/AssociateFiles.jsp?jobId=<%=request.getParameter("jobId")%>" class="minderACTION">Associate 
  File(s)- files from another job </a></div>
<br>
<div align="right" class="body"><i>You may download or email selected files from this job --></i> <a href="javascript:downloadFiles()" class="minderACTION">Download 
        File(s)</a> |  <a href="javascript:emailFiles()" class="minderACTION">Email 
        File(s)</a> </div>
<br>
<jsp:include page="/includes/JobDetailHeader.jsp" flush="true">
<jsp:param  name="jobId" value="<%=request.getParameter(\"jobId\")%>" />
</jsp:include>
<%
/*
<!--<p class="body">All files related to this job are included below categorized as 
  Final Files, Working Files and Files for Approval. Many file types (.jpg, .pdf, 
  etc.) may be viewed online by clicking on their filename. </p>
<ul>
  <li class="body"><b>Final Files:</b>&nbsp; &nbsp; Files Delivered in completion of the Job.</li>
  <li class="body"><b>Working Files:</b>&nbsp; &nbsp; Files Supplied by either the Client or Vendor to support 
    work being done on the job.</li>
  <li class="body"> <b>Files for Approval:</b>&nbsp; &nbsp; Work Submitted by Vendor for Client Approval.</li>
</ul>
<p class="body">The Files for Approval section includes all historical approvals and comments 
  made by both parties involved in the job.</p>
<hr noshade size="1" color="red">-->
*/
%><br>
<jsp:include page="/files/includes/ProductionFiles.jsp" flush="true">
<jsp:param  name="jobId" value="<%=request.getParameter(\"jobId\")%>" />
</jsp:include>
<%
   if (((RoleResolver)session.getAttribute("roles")).isVendor()) { 
	%><br /><br /><jsp:include page="/files/includes/PrintFiles.jsp" flush="true">
<jsp:param  name="jobId" value="<%=request.getParameter(\"jobId\")%>" />
</jsp:include>
<%}%>
<jsp:include page="/files/includes/WorkingFiles.jsp" flush="true">
<jsp:param  name="jobId" value="<%=request.getParameter(\"jobId\")%>" />
</jsp:include>
<br>
<taglib:CompFilesTag jobId="<%=request.getParameter(\"jobId\")%>" /> 

<input type="hidden" name="action" value="">
<input type="hidden" name="redirect" value="">
</form>
</body>
</html>
