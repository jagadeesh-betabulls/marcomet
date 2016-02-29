<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.tools.*,com.marcomet.workflow.*,com.marcomet.users.security.*;" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<html>
<head>
  <title>Review Final Delivery</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body class="body">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">
  <p class="Title">Review Final Delivery</p><%String valStr=request.getParameter("jobId"); %>
  <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=valStr%>" /></jsp:include>
<br>
  <table border="0" class="body">
    <tr> 
      <td class="tableheader">Material Reference</td>
      <td class="tableheader">Filename</td>
      <td class="tableheader">Description - Sender's Coments</td>
    </tr>
    <tr> 
      <td class="body">&nbsp;</td>
      <td class="body">&nbsp;</td>
      <td class="body"> </td>
    </tr>
  </table>
<p>
<%	Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
	Statement st = conn.createStatement();
	String sql1 = "select message from form_messages where form_id = 4 and job_id =" + request.getParameter("jobId");
	ResultSet rsMessage = st.executeQuery(sql1);
	if(rsMessage.next()){
		;
	}else{
		throw new Exception("Can not find messages");
	}
%>
  <table class="body">
    <tr> 
      <td class="tableheader">Vendor's Message</td>
    </tr>
    <tr> 
      <td><%= rsMessage.getString("message")%></td>
    </tr>
  </table>
<p>
    <b>Shipping Information for Physical Delivery:</b> </p>
<%
	String sql2 = "select * from shipping_data where Ucase(status) = 'FINAL' and job_id = " + request.getParameter("jobId");
	ResultSet rsShipping = st.executeQuery(sql2);
	if(rsShipping.next()){
		;
	}else{
		throw new Exception("Can not find shipping ");
	}		
%>	
  <table class="body">
    <tr> 
      <td class="label">Shipping Date:</td>
    <td><%= formater.formatMysqlDate(rsShipping.getString("date"))%></td>
  </tr>
  <tr> 
      <td><span class="label">Method</span>:</td>
    <td><%= rsShipping.getString("method")%></td>
  </tr>
  <tr> 
      <td class="label">Reference/Tracking #:</td>
    <td><%= rsShipping.getString("reference")%></td>
  </tr>
</table>
<br>
  <table class="body">
    <%	
	String sqlDeclineMessages = "select a.* from form_messages a, lu_forms b where  a.form_id = b.id and b.form_name = 'Final Delivery Resolution' and job_id = "+request.getParameter("jobId")+" order by time_stamp";
	ResultSet rsDeclineMessages = st.executeQuery(sqlDeclineMessages);
	if(rsDeclineMessages.next()){	
%>
    <tr> 
    <td class="tableheader" colspan="2">Previous Decline/Resolution Corespondences:</td>
  </tr>
  <tr> 
    <td><%= formater.formatTimeStamp(rsDeclineMessages.getString("time_stamp"))%></td>
    <td><%= rsDeclineMessages.getString("message") %></td>
  </tr>
<%    while(rsDeclineMessages.next()){	%>
  <tr> 
    <td><%= formater.formatTimeStamp(rsDeclineMessages.getString("time_stamp"))%></td>
    <td><%= rsDeclineMessages.getString("message") %></td>
  </tr>
<%	  } %>
<%  } %>
  <tr> 
     <td class="tableheader" colspan="2">Customer Message(if declined):</td>
  </tr>
  <tr> 
    <td colspan="2"><textarea name="message" cols=50 rows=5></textarea></td>
  </tr>
</table>
<br>
<table border="0" width="65%" align="center">
  <tr><td width=3%>&nbsp;</td>
<%
	ResultSet rsJobActions = st.executeQuery("SELECT a.id 'id', a.actionperform 'actionperform', j.id 'jobId' FROM jobflowactions a, jobs j WHERE a.currentstatus = j.status_id AND a.fromstatus = j.last_status_id AND a.whosaction = "+ ((((RoleResolver)session.getAttribute("roles")).isVendor())?"2":"1") + " and j.id = " + request.getParameter("jobId")+" ORDER BY actionorder");
	while(rsJobActions.next()) { %>			
	    <td class="graybutton"><a href="javascript:moveWorkFlow('<%=rsJobActions.getString("id")%>')"><%= rsJobActions.getString("actionperform")%></a></td>
		<td width=3%>&nbsp;</td>
<% } %>
  </tr>
</table>
<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
<input type="hidden" name="nextStepActionId" value="">  
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
</form>
</body>
</html><%st.close();conn.close(); %>
