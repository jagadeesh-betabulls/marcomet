<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%@ include file="/includes/SessionChecker.jsp" %>
<%SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
DecimalFormat nf = new DecimalFormat("#,###");

String siteHostRoot=((request.getParameter("siteHostRoot")==null)?(String)session.getAttribute("siteHostRoot"):request.getParameter("siteHostRoot"));
%>
<html>
<head>
  <title>Create Bill</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="/sitehosts/lms/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<style>.toggle{margin: 0px 20px 0px 20px;display: none;}</style>
</head>
<body onLoad="document.forms[0].jobId.focus();"> 
	<form method-"post" name="myForm" action="/minders/workflowforms/Invoice_FormFromQuick.jsp">
		<p class='title'>Create Bill</p><p class='body'>Create bill for the following job:</p>
		Job ID:<input type='text' name='jobId'><input type=submit value=' CONTINUE '>
	<input type="hidden" name="actionId" value="81">
	</form>
</body>
</html>