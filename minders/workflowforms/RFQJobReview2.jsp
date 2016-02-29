<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.text.*,java.util.*,com.marcomet.tools.*,com.marcomet.workflow.*,com.marcomet.jdbc.*,com.marcomet.users.security.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
 <%
 Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
 Statement st = conn.createStatement();
String sql;
ResultSet rsOrder;
ResultSet rsJobInfo;
ResultSet rsJobSpecInfo;

String jobId = request.getParameter("jobId");
DecimalFormat df = new DecimalFormat("0.00");  //format the dollars

%><html>
<head>
  <title>RFQ Review</title>
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body class="body" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit">
  <p class="Title">Review RFQ</p>
  
<jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
<br>
<jsp:include page="/includes/ClientInfoInclude.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
<hr size="1" color="red">
  <table border="0" class="body" width="50%">
    <tr> 
      <td><b><u>Job Specs:</u></b></td>
    </tr>
    <% 
    try{
    String specQuery = "SELECT ls.value as label, js.value as value FROM job_specs js, lu_specs ls, catalog_specs cs WHERE ls.id != 88888 AND ls.id != 99999 AND js.cat_spec_id = cs.id AND cs.spec_id = ls.id and js.job_id = " + jobId;
     ResultSet rsSpecs = st.executeQuery(specQuery);
     while (rsSpecs.next()) { %>
    <tr> 
      <td><%= rsSpecs.getString("label") %></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"><%= rsSpecs.getString("value") %></td>
    </tr>
    <% } %>
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <% String fileQuery = "select file_name, description, company_id from file_meta_data where job_id = " + jobId;
     ResultSet rsFiles = st.executeQuery(fileQuery); 
     Vector fileVector = new Vector();
     String companyId="";
     while(rsFiles.next()) {
	 	fileVector.addElement(rsFiles.getString("company_id"));
		fileVector.addElement(rsFiles.getString("file_name"));
		fileVector.addElement(rsFiles.getString("description"));
     }
	 if (fileVector.size() > 0) { %>
    <tr> 
      <td class="label">Supplied Files:</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" class="tableheader">File Name</td>
      <td colspan="2" class="tableheader">Description</td>
    </tr>
    <% for (int i=0; i<fileVector.size(); i=i+3) { %>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="javascript:pop('/transfers/<%= fileVector.get(i) %>/<%= fileVector.get(i+1) %>',300,300)" ><%= fileVector.get(i+1) %></a></td>
      <td colspan="2"><%= fileVector.get(i+2) %></td>
    </tr>
    <% } %>
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <% } %>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td class="tableheader">Est Cost$</td>
      <td class="tableheader">Seller MU</td>
      <td class="tableheader">MC Fee</td>
      <td class="tableheader">Price</td>
      <td>&nbsp;</td>
    </tr>
    <% double totCost = 0; double totFee = 0; double totMu = 0; double totPrice = 0;
     sql = "SELECT ls.value 'specname', js.value 'specvalue',  js.cost 'cost', js.fee 'fee', js.mu 'mu', js.price 'price' FROM job_specs js, lu_specs ls, catalog_specs cs WHERE cs.price_determinant = 1 AND js.cat_spec_id = cs.id AND cs.spec_id = ls.id AND js.job_id = " + jobId + " ORDER BY ls.sequence";
     rsJobSpecInfo = st.executeQuery(sql);
     while(rsJobSpecInfo.next()){
		totCost += rsJobSpecInfo.getDouble("cost");
		totFee += rsJobSpecInfo.getDouble("fee");
		totMu += rsJobSpecInfo.getDouble("mu");
		totPrice += rsJobSpecInfo.getDouble("price"); %>
    <tr> 
      <td><%= rsJobSpecInfo.getString("specname") %>:</td>
      <td></td>
      <td>&nbsp;</td>
      <td align="right">$<%= df.format(rsJobSpecInfo.getDouble("cost")) %></td>
      <td align="right">$<%= df.format(rsJobSpecInfo.getDouble("fee"))%> </td>
      <td align="right">$<%= df.format(rsJobSpecInfo.getDouble("mu"))%></td>
      <td align="right">$<%= df.format(rsJobSpecInfo.getDouble("price")) %></td>
      <td>&nbsp;</td>
    </tr>
    <% }
     sql = "SELECT ls.value 'specname', js.value 'specvalue',  js.cost 'cost', js.fee 'fee', js.mu 'mu', js.price 'price' FROM job_specs js , lu_specs ls WHERE js.cat_spec_id = ls.id AND ls.value = 'Base Price' AND job_id = " + jobId;
	 ResultSet rsBasePrice = st.executeQuery(sql);
	 if (rsBasePrice.next()) {
		totCost += rsBasePrice.getDouble("cost");
		totMu += rsBasePrice.getDouble("mu");
		totFee += rsBasePrice.getDouble("fee");
		totPrice += rsBasePrice.getDouble("price"); %>
    <tr> 
      <td><%= rsBasePrice.getString("specname") %>:</td>
      <td></td>
      <td>&nbsp;</td>
      <td align="right">$<%= df.format(rsBasePrice.getDouble("cost")) %></td>
      <td align="right">$<%= df.format(rsBasePrice.getDouble("mu"))%></td>
      <td align="right">$<%= df.format(rsBasePrice.getDouble("fee"))%> </td>
      <td align="right">$<%= df.format(rsBasePrice.getDouble("price")) %></td>
      <td>&nbsp;</td>
    </tr>
    <% } %>
    <tr> 
      <td><b>Job Total:</b></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right" class="TopborderLable">$<%= df.format(totCost)%></td>
      <td align="right" class="TopborderLable">$<%= df.format(totFee)%> </td>
      <td align="right" class="TopborderLable">$<%= df.format(totMu)%> </td>
      <td align="right" class="TopborderLable">$<%= df.format(totPrice)%></td>
      <td>&nbsp;</td>
    </tr>
    <% boolean changes = false;
	 ResultSet rsJobChanges = st.executeQuery("select * from jobchanges where jobid = " + jobId + " and statusid = 2 order by createddate");
	 while(rsJobChanges.next()){
		totCost += rsJobChanges.getDouble("cost");
		totFee += rsJobChanges.getDouble("fee");
		totMu += rsJobChanges.getDouble("mu");
		totPrice += rsJobChanges.getDouble("price");
		changes = true; %>
    <tr> 
      <td>Job Change:</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right">$<%= rsJobChanges.getString("cost")%></td>
      <td align="right">$<%= rsJobChanges.getString("mu")%></td>
      <td align="right">$<%= rsJobChanges.getString("fee")%></td>
      <td align="right">$<%= rsJobChanges.getString("price")%></td>
      <td>&nbsp;</td>
    </tr>
    <% } 
  if (changes) {%>
    <tr> 
      <td><b>Job Total With Changes:</b></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right" class="TopborderLable">$<%= df.format(totCost)%></td>
      <td align="right" class="TopborderLable">$<%= df.format(totFee)%> </td>
      <td align="right" class="TopborderLable">$<%= df.format(totMu)%> </td>
      <td align="right" class="TopborderLable">$<%= df.format(totPrice)%></td>
      <td>&nbsp;</td>
    </tr>
    <% } %>
    <tr> 
      <td>&nbsp;</td>
    </tr>
  </table>
<br><br><br>

<table border="0" align="center">
	  <tr><td width="3%">&nbsp;</td><%
	ResultSet rsJobActions = st.executeQuery("select a.id 'id', a.actionperform 'actionperform', b.id 'jobId' from jobflowactions a, jobs b where a.currentstatus = b.status_id and a.fromstatus = b.last_status_id and a.whosaction = "+ ((((RoleResolver)session.getAttribute("roles")).isVendor())?"2":"1") +" and b.id = " + jobId + " order by actionorder");
	while(rsJobActions.next()) { %>			
	    <td ><a href="javascript:moveRFQReview('<%=rsJobActions.getString("id")%>')" class="greybutton"><%= rsJobActions.getString("actionperform")%></a></td>
		<td width="3%">&nbsp;</td><% } %></tr>
</table>
<script>
function moveRFQReview(ai){

	if(ai == 42|| ai == 47 | ai == 103|| ai == 104 ){
		window.location.replace("/minders/workflowforms/RFQVendorResponse.jsp?jobId=<%=request.getParameter("jobId")%>");
	}else{	
		moveWorkFlow(ai);
	}	
}
</script>
  	<input type="hidden" name="nextStepActionId" value="">  
  	<input type="hidden" name="nextStepJobId" value="<%= request.getParameter("jobId") %>">
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
	<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
</form>
</body>
</html><%
}catch (Exception e){
%><!-- Error: <%=e%>--><%
}finally{
	st.close();conn.close(); 
}
%>
