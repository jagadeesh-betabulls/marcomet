<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.jdbc.*,com.marcomet.workflow.*,com.marcomet.users.security.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();

Hashtable rehash = new Hashtable();

String shippingQuery = "SELECT reference, method, DATE_FORMAT(date,'%m') 'shipmonth',  DATE_FORMAT(date,'%d') 'shipday',  DATE_FORMAT(date,'%Y') 'shipyear',DATE_FORMAT(date,'%Y-%m-%d') as shipdate FROM shipping_data WHERE status = 'final' and job_id = " + request.getParameter("jobId");
ResultSet rs1 = st.executeQuery(shippingQuery);
while (rs1.next()) {
	rehash.put("reference", rs1.getString("reference"));
	rehash.put("method", rs1.getString("method"));
	rehash.put("shippingDate", rs1.getString("shipdate"));
	rehash.put("shipMonth", rs1.getString("shipmonth"));
	rehash.put("shipDay", rs1.getString("shipday"));
	rehash.put("shipYear", rs1.getString("shipyear"));
}

try { st.close(); } catch (Exception e) {}
try { conn.close(); } catch (Exception e) {}
%>

<html>
<head>
  <title>Final Delivery</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<jsp:getProperty name="validator" property="javaScripts" />
<script language="JavaScript" src="/javascripts/mainlib.js"></script>

<body class="label">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit" enctype="multipart/form-data">
  <p class="Title">Final Delivery</p><p> <b>Instructions:</b> <span class="body">You must submit this delivery notification 
    regardless of whether you’re your work product is being delivered as an online 
    file upload, or as a physical shipment. It is a formal requirement to our 
    releasing of Customer escrowed funds to make your payment. Any physical shipping 
    costs must be included within this submittal to be reimbursed by the Customer, 
    and must be verifiable by hard copy of shipper's invoice with matching dollar 
    amount. (All handling charges are included in the job price, therefore all 
    shipping is billable as out of pocket only.) </span></p>
	
  <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
  
<p>
  <span class=label>Sender's Message:</span><br>
  <textarea cols="60" rows=3 name="message"></textarea><br>
</p>

<hr size=1>

<br>
  <table width="40%">
    <tr> 
      <td class="contentstitle">File Upload</td>
    </tr>
    <tr> 
      <td class="body"> 
        <jsp:include page="/includes/UploadFilesInclude.jsp" flush="true"/>
      </td>
    </tr>
    <tr> 
      <td class="body">&nbsp;</td>
    </tr>
    <tr> 
      <td class="contentstitle">Physical Shipment Info</td>
    </tr>
    <tr> 
      <td> 
        <table>
          <tr> 
            <td class="label"> 
              <div align="right">Shipping Date:</div>
            </td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td class="body"> <taglib:DropDownDateTag extraCode="onChange=\"popHiddenDateField('shipdate')\"" selectedDay="<%=(String)rehash.get("shipDay")%>" selectedMonth="<%=(String)rehash.get("shipMonth")%>" selectedYear="<%=(String)rehash.get("shipYear")%>" /> 
              <input type="hidden" name="shipdate" value="<%=(String)rehash.get("shippingDate")%>">
            </td>
          </tr>
          <tr> 
            <td class="label"> 
              <div align="right">Method:</div>
            </td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td class="body"> 
              <input type="text" name="method" value=<%= (String)rehash.get("method") %> >
            </td>
          </tr>
          <tr> 
            <td class="label"> 
              <div align="right">Reference/Tracking #:</div>
            </td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td class="body"> 
              <input type="text" name="reference" value=<%= (String)rehash.get("reference") %> >
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
<br>
<table border="0" width="20%" align="center">
  <tr>
    <%
	ResultSet rsJobActions = st.executeQuery("SELECT a.id 'id', a.actionperform 'actionperform', j.id 'jobid' FROM jobflowactions a, jobs j WHERE a.currentstatus = j.status_id and a.fromstatus = j.last_status_id and a.whosaction = "+ ((((RoleResolver)session.getAttribute("roles")).isVendor())?"2":"1") +" and j.id = " + request.getParameter("jobId"));
	while(rsJobActions.next()) { %>
       <td class="graybutton" valign="middle"> 
         <div align="center"><a href="javascript:moveWorkFlow('<%=rsJobActions.getString("id")%>')" ><%= rsJobActions.getString("actionperform") %></a></div>
       </td>
    <% } %>
  </tr>
</table>

<input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>" >
<input type="hidden" name="nextStepActionId" value="">  
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
<input type="hidden" name="redirect" value="<%=(((RoleResolver)session.getAttribute("roles")).isVendor())?"/minders/JobMinderSwitcher.jsp":"/minders/JobMinderSwitcher.jsp"%>">
<input type="hidden" name="status" value="Final">
<input type="hidden" name="category" value="Final">

</form>
</body>
</html><%conn.close(); %>
