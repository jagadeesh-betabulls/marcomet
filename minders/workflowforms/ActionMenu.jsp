<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.workflow.*,com.marcomet.users.security.*" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<html>
<head>
  <title>Action Menu</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/htdocs/commerce/sitehosts/agency/styles/vendor_styles.css" type="text/css">
</head>  
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script>
function SubmitForm(actionId) {
  document.forms[0].nextStepActionId.value = actionId;
  document.forms[0].submit();
}
function none(){
	alert('<%=((session.getAttribute("demo")==null)?"You are not authorized to perform this action.":"This is a demo site; job actions are disabled.")%>')
}
</script>
<body background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<p class="body"></p>
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">
<table border="0" cellspacing="0" cellpadding="0" height="100%" width="100%">
  <tr valign="top">
    <td>
      <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
    </td>
  </tr>
  <tr valign="middle">
    <td align="center">
        <table width="85%" class="body" align="center">
          <%
boolean showAction=false;
	if (session.getAttribute("roles") != null && session.getAttribute("demo")==null) {
		if (((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isVendor()) {
			if (((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isSiteHost()) {
				showAction=true;
			} else {
				showAction=true;
			}	
		} else if (((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isSiteHost()) {
			showAction=false;
		} else {
			showAction=false;
		}
	}else{
		showAction=false;
	}
String link="";
  String actionQuery = "SELECT job_flow_action_id AS action_id, action_definition as definition, action_title AS title, action_description AS description, sequence FROM jobs j, jobflowstates jfs, job_flow_action_menu jfam WHERE jfs.id = j.status_id AND jfs.id = jfam.job_flow_state_id AND j.id = " + request.getParameter("jobId") + " ORDER BY sequence";
  Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
  Statement st = conn.createStatement();
  ResultSet actionRS = st.executeQuery(actionQuery);
  while (actionRS.next()) { 
     String definition = actionRS.getString("definition"); 
%><tr><%
          if (definition.endsWith(".jsp") == true) { 
			link=((showAction)?definition+"?jobId="+request.getParameter("jobId")+"&actionId="+actionRS.getString("action_id"):"javascript:none();");
//			link=definition+"?jobId="+request.getParameter("jobId")+"&actionId="+actionRS.getString("action_id");
	%><td width="10%" valign="top"> 
              <div align="right"><a href="<%=link%>" class="greybutton"><%=actionRS.getString("title")%></a></div>
            </td><%
          } else { 
			link=((showAction)?"javascript:SubmitForm('"+actionRS.getString("action_id")+"')":"javascript:none();");
//			link="javascript:SubmitForm('"+actionRS.getString("action_id")+"')";
	%><td width="10%" valign="top"> 
              <div align="right"><a href="<%=link%>" class="greybutton"><%=actionRS.getString("title")%></a> 
              </div>
            </td><%
          } %><td width="5%"></td>
            <td width="70%"> <%= actionRS.getString("description")%></td>
          </tr>
          <tr> 
            <td width="5%" height="25"> 
              <div align="left">&nbsp;</div>
            </td>
          </tr><%
  } %></table>
    </td>
  </tr>
</table>
<input type="hidden" name="jobId" value="<%=request.getParameter("jobId")%>">
<input type="hidden" name="nextStepActionId" value="">
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
<input type="hidden" name="redirect" value="<%=(((RoleResolver)session.getAttribute("roles")).isVendor())?"/minders/JobMinderSwitcher.jsp":"/minders/JobMinderSwitcher.jsp"%>">
</form>
</body>
</html><%conn.close();%>