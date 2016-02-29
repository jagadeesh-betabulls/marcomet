<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.workflow.*,com.marcomet.users.security.*" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
	String[] totfs = {"file0","file1","file2","material0","material1","material2"};
	validator.setThisOrThatFields(totfs);
%><html>
  <head>
    <title>Submit Comp/Proof</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  </head>
<jsp:getProperty name="validator" property="javaScripts" />  
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script>
function adjustStatus() {
	var jobid = <%=request.getParameter("jobId")%>;
	if (document.forms[0].approvalType[0].checked) {
		document.forms[0].stage.value = "interim";
		moveWorkFlow('21');
	} else if (document.forms[0].approvalType[1].checked) {
		document.forms[0].stage.value = "final";
	    	moveWorkFlow('11');
	} else {
		alert('Please indicate the stage of materials to be approved.');
	}
}
</script>
<body class="body">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit" enctype="multipart/form-data">
  <p class="Title">Submit Comp or Proof</p>
  <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
  <p> <b>Instructions: </b>Please attach any work you would like to see approved 
    by the Customer. You may also provide a message with specific instructions. 
    The Customer will be asked to indicate their approval of the work referenced 
    on this form. If multiple choices are available, as in approving a choice 
    of designs, they will only be able to select the one for which they desire 
    to continue processing. </p>
  <p><b>Interim Work Approvals</b>: For projects which require the approval of 
    multiple elements, i.e. - cover designs or print proofs and or copy for a 
    brochure, select Interim Work Approval and submit the elements in categories, 
    i.e.- cover designs, or, copy one at a time, once approved continue and submit 
    other elements for approval until Final Work Approval is required.</p>
  <p> <b>For a Final Work Approval:</b> For projects that only require approval 
    of only one element or when all interim elements have been approved, submit 
    a final file or multiple files for the client approval. Again the client will 
    only be able to approve one of the submitted files and their approval means 
    that they are authorizing the final production or implementation of the project. 
    No further modifications will be permitted, and they will be charged in full 
    for their order. </p>
  <table>
  <tr> 
    <td class="label">Please indicate the stage of materials to be approved:</td>
    <td class="label"><input type="radio" name="approvalType" value="1"> Interim Work Approval </td>
    <td class="label"><input type="radio" name="approvalType" value="2"> Final Work Approval </td>
  </tr>
</table>
<p>
  <span class="label">Sender's Message:</span><br>
  <textarea cols="60" rows=3 name="message"></textarea><br>
</p>
<hr size=1>
<br>
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
<table border="0" width="20%" align="center">
  <tr><%
    ResultSet rsJobActions = st.executeQuery("select a.id 'id', a.actionperform 'actionperform', b.id 'jobid' from jobflowactions a, jobs b where a.currentstatus = b.status_id and a.fromstatus = b.last_status_id and a.whosaction = "+ ((((RoleResolver)session.getAttribute("roles")).isVendor())?"2":"1") +" and b.id = " + request.getParameter("jobId"));
    while(rsJobActions.next()) { %>
    <td class="graybutton" valign="middle">
      <% if ((rsJobActions.getString("actionperform")).equals("Submit Comp/Proof")) { %>
      <div align="center"><a href="javascript:adjustStatus()" ><%= rsJobActions.getString("actionperform") %></a></div>
      <% } else { %>
      <div align="center"><a href="javascript:moveWorkFlow('<%=rsJobActions.getString("id")%>')" ><%= rsJobActions.getString("actionperform") %></a></div>
      <% } %>
    </td>
    <% } %>
  </tr>
</table>
<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
<input type="hidden" name="nextStepActionId" value="">
<input type="hidden" name="redirect" value="<%=(((RoleResolver)session.getAttribute("roles")).isVendor())?"/minders/JobMinderSwitcher.jsp":"/minders/JobMinderSwitcher.jsp"%>">
<input type="hidden" name="status" value="Submitted">
<input type="hidden" name="stage" value="">
<input type='hidden' name="shippingStatus" value="interim">
<input type="hidden" name="category" value="Comp">
</form>
</body>
</html><%st.close();conn.close(); %>
