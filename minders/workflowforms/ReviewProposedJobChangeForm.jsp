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
if(rs1.next()) {
	rehash.put("changetypeid", new Integer(rs1.getInt("changetypeid")));
	rehash.put("text", rs1.getString("text"));
	rehash.put("reason", rs1.getString("reason"));
	rehash.put("changePrice", rs1.getString("price"));	
}

try { st.close(); } catch (Exception e) {}
try { conn.close(); } catch (Exception e) {}
%>

<html>
<head>
  <title>Review Proposed Change</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body class="catalogTITLE" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.workflow.jobchanges.JobChangeUnparker">
  <p class="Title">Review Proposed Change </p>
  <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include> 
    <% if (Integer.parseInt((String)rehash.get("laststatusid")) == 2) { %>
    <!--The following changes are proposed for this job. Please indicate your choice regarding these changes 
    below. At that time we would be pleased to confirm your job.--> 
    <% } else { %>
    <!--The following changes are proposed for this job. Please indicate your choice 
    regarding theses changes below. At that time we would be pleased to continue processing your job.--> 
    <% } %>
    <br>
    <span class="label"> Message / Changes:</span>
    <pre><%= rehash.get("reason") %></pre>
  <p><span class="label"> Necessity of Change:&nbsp;</span><%= rehash.get("text") %>
  
  <table width="45%">
    <tr> 
      <td class='label'>&nbsp;</td>
      <td class="body">&nbsp;</td>
      <td align='right' class="body">&nbsp;</td>
    </tr>
    <tr> 
      <td class='label'>Cost change added to current job:</td>
      <td class="body">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align='right' class="body"><%= formater.getCurrency(Double.parseDouble((String)rehash.get("changePrice"))) %></td>
    </tr>
    <tr> 
      <td class='label'>Revised job cost:</td>
      <td class="body">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align='right' class="TopborderLable"><%= formater.getCurrency(Double.parseDouble((String)rehash.get("price")) + Double.parseDouble((String)rehash.get("changePrice"))) %></td>
    </tr>
  </table>
<br>
<table>
  <tr>
    <td class="label">Return Comments:</td>
  </tr>
  <tr>
    <td><textarea cols="70" rows=3 name="comments"></textarea></td>
  </tr>
</table>
<% //if (!(((RoleResolver)session.getAttribute("roles")).isVendor()) && !(((RoleResolver)session.getAttribute("roles")).isSiteHost())) { %>
<br>

<table border="0" width="40%" align="center">
  <tr>
	<td valign='middle'>
        <div align="center"><a href="javascript:statusChange('1')" class="greybutton">Approve 
          Change</a></div>
      </td>
    <td width="3%">&nbsp;</td>
<%
	if (((Integer)rehash.get("changetypeid")).intValue() == 1) {
%>
    <td valign="middle">
        <div align="center"><a href="javascript:statusChange('3')" class="greybutton">Cancel 
          Job</a></div>
      </td>
<%
	}else{
%>				
	<td valign='middle'>
        <div align="center"><a href="javascript:statusChange('2')" class="greybutton">Decline 
          Change</a></div>
      </td>
<%
	}
%>
  </tr>
</table>
<script language="JavaScript">
	function statusChange(temp){
		document.forms[0].changeStatus.value = temp;
		submitForm();
	}
</script>
<input type="hidden" name="changeStatus" value="">  
<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
<input type="hidden" name="errorPage" value="/minders/workflowforms/ReviewProposedJobChangeForm.jsp">
<% //} %>
</form>
</body>
</html>
