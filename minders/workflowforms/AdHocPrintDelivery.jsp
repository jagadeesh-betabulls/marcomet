<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.workflow.*,com.marcomet.users.security.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<html>
<head>
  <title>Final Delivery</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body onLoad="MM_preloadImages('/images/buttons/continueover.gif','/images/buttons/cancelbtover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit" enctype="multipart/form-data">
<p class="Title">Upload Printable File to Subvendor</p><p> <b>Instructions:</b> <span class="body">Use this form to deliver a file for print production.</span></p>
<jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
<!--<p>
  <span class=label>Sender's Message:</span><br>
  <textarea cols="60" rows=3 name="message"></textarea><br></p>-->
<input type=hidden name="message">
<table width="40%">
  <tr> 
    <td class="contentstitle"><br /><br />File Upload</td>
  </tr>
  <tr> 
    <td class="body"> 
      <jsp:include page="/includes/UploadFilesInclude.jsp" flush="true"/>
    </td>
  </tr>
</table>
  <br>
<table border="0" width="25%" align="center">
  <tr>
      <td width="48%"> 
        <div align="center"><a href="/minders/JobMinderSwitcher.jsp" class="greybutton">Cancel</a></div>
      </td>
      <td width="4%">&nbsp;</td>
      <td width="48%"> 
       <div align="center"><a href="javascript:document.forms[0].submit()" class="greybutton">Continue</a></div>
      </td>
  </tr>
</table>
<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
<input type="hidden" name="nextStepActionId" value="<%=request.getParameter("actionId")%>">  
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
<input type="hidden" name="redirect" value="<%=(((RoleResolver)session.getAttribute("roles")).isVendor())?"/minders/JobMinderSwitcher.jsp":"/minders/JobMinderSwitcher.jsp"%>">
<input type="hidden" name="status" value="Final">
<input type="hidden" name="category" value="Print">
</form>
</body>
</html>