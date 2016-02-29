<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.text.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.tools.*,com.marcomet.workflow.*,com.marcomet.users.security.*;" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
String query = "select last_status_id, price as price from jobs where id = " + request.getParameter("jobId");
	
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(query);
Hashtable rehash = new Hashtable();

while (rs.next()) {
	rehash.put("price", rs.getString("price"));
	rehash.put("laststatusid", rs.getString("last_status_id"));
}

String changeQuery = "select changetypeid, text, reason, price from jobchanges jc, jobchangetypes jct where statusid = 1 and changetypeid = jct.value and jobid = " + request.getParameter("jobId");
ResultSet rs1 = st.executeQuery(changeQuery);
while (rs1.next()) {
	rehash.put("changetypeid", new Integer(rs1.getInt("changetypeid")));
	rehash.put("text", rs1.getString("text"));
	rehash.put("reason", rs1.getString("reason"));
	rehash.put("changePrice", rs1.getString("price"));	
}
%><html>
<head>
  <title>Review Quote</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body class="body" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">
<p class="Title">Review Quote </p>
<jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
<br>
<b>Message/Changes:</b>
<%= rehash.get("reason") %>
<table>
  <tr>
    <td class="label">Quoted Job Cost:</td>
	<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	<td align='right' class='label'><%= formater.getCurrency(Double.parseDouble((String)rehash.get("price")) + Double.parseDouble((String)rehash.get("changePrice"))) %></td>
  </tr>
</table>
<br>
<table>
  <tr>
    <td class="label">Return Comments:</td>
  </tr>
  <tr>
    <td><textarea cols="60" rows=5 name="comments"></textarea></td>
  </tr>
</table>
<br><br>
<table border="0" width="35%" align="center">
  <tr>
<%
	//ResultSet rsJobActions = st.executeQuery("SELECT a.id 'id', a.actionperform 'actionperform', j.id 'jobid' FROM jobflowactions a, jobs j WHERE a.currentstatus = j.status_id AND a.fromstatus = j.last_status_id AND a.whosaction = "+ ((((RoleResolver)session.getAttribute("roles")).isVendor())?"2":"1") +" AND j.id = " + request.getParameter("jobId"));
	ResultSet rsJobActions = st.executeQuery("SELECT a.id 'id', a.actionperform 'actionperform', j.id 'jobid' FROM jobflowactions a, jobs j WHERE a.currentstatus = j.status_id AND a.fromstatus = j.last_status_id AND j.id = " + request.getParameter("jobId"));
	while(rsJobActions.next()) {
		if (((Integer)rehash.get("changetypeid")).intValue() == 1) {
			if (rsJobActions.getString("actionperform").equals("Decline Change")) {

			} else { %>
				</tr></table>

  	<p>&nbsp;</p><table border="0" width="35%" align="center"><tr><td valign="middle"> 
				  <div align="center"><a class="greybutton" href="javascript:moveWorkFlow('<%=rsJobActions.getString("id")%>')"><%= rsJobActions.getString("actionperform") %></a></div>
				</td>
				<td width="3%">&nbsp;</td>
<%  		} 
		} else {
			if (rsJobActions.getString("actionperform").equals("Cancel Job")) {

			} else { %>
				<td valign="middle"> 
				  <div align="center"><a class="greybutton" href="javascript:moveWorkFlow('<%=rsJobActions.getString("id")%>')"><%= rsJobActions.getString("actionperform") %></a></div>
				</td>
				<td width="3%">&nbsp;</td>
<%			}
	    } 
    } %>
  </tr>
</table>

  	<input type="hidden" name="nextStepActionId" value="">  
	<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
</form>
</body>
</html><%st.close();conn.close(); %>
