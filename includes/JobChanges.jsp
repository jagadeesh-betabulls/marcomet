<%@ page import="java.sql.*;"%>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<%Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement(); 
ResultSet changesRS = st.executeQuery("SELECT DATE_FORMAT(jc.createddate,'%m/%d/%y') 'created_date', jct.text 'change_type', ljcs.value 'status', DATE_FORMAT(jc.customerdate,'%m/%d/%y') 'customer_date', jc.reason 'reason', jc.comments, jc.price 'price' FROM jobchanges jc, jobchangetypes jct, lu_job_change_statuses ljcs WHERE jc.statusid = ljcs.id AND jc.changetypeid = jct.id AND jc.jobid = " + request.getParameter("jobId") + " order by createddate");
   request.setAttribute("changesRS", changesRS); %>
<hr size="1">
<table width=100% class="body">
  <tr> 
    <td class="subtitle1">Quotes&nbsp;/&nbsp;Job Change History:</td>
    </tr>
</table>
<table border="0" width="100%">
  <iterate:dbiterate name="changesRS" id="i">
  <tr>
    <td><u><span class="label">Proposed:</span></u> <span class="body"><%= changesRS.getString("created_date") %></span> <span class="label">as</span> <span class="body"><$ change_type$>&nbsp;&nbsp;<span class="label"><%=formatter.getCurrency(changesRS.getDouble("price"))%></span></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="label"><$ status $></span> <%= (changesRS.getString("status").equals("Pending")) ? "":": <span class=\"body\">" + changesRS.getString("customer_date") + "</span>"%></td>
  </tr>
  <tr>
    <td><u><span class="label">Description:</span></u>&nbsp;<span class="body"><pre><%= changesRS.getString("reason") %></pre></span></td>
  </tr>
  <tr>
    <td><u><span class="label">Return Comments:</span></u>&nbsp;<span class="body"><pre><%= changesRS.getString("comments") %></pre></span></td>
  </tr>
  <tr>
    <td colspan="11">&nbsp;</td>
  </tr>
  </iterate:dbiterate>
</table>