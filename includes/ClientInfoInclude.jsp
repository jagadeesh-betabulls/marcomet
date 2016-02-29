<%@ page import="java.sql.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="page" />
<jsp:useBean id="customer" class="com.marcomet.beans.SBPContactBean" scope="page" />

<% 
String jobId=((request.getParameter("jobId")==null)?"":request.getParameter("jobId"));
String editor=((request.getParameter("editor")==null)?"false":request.getParameter("editor"));
String query = "SELECT o.buyer_contact_id 'contactid' FROM jobs j, projects p, orders o WHERE o.id = p.order_id AND p.id = j.project_id AND j.id = " + jobId;
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(query);
   rs.next();
   customer.setContactId(rs.getString("contactid"));
%>
<hr size="1">
<table class="body">
  <tr> 
    <td class="subtitle1" colspan="7">Client Information:</td>
  </tr>
  <tr> 
    <td class="label">Name:</td>
    <td class="body"><%= customer.getLastName() + ", " + customer.getFirstName()%></td>
    <td>&nbsp;</td>
    <% if (!customer.getPrefix(0).equals("")) { %>
    <td class="label"><taglib:LUTableValueTag table="lu_phone_types" selected="<%= customer.getPhoneTypeIdString(0)%>"/>:</td>
    <td>&nbsp;</td>
    <td class="body"><%= customer.getAreaCode(0)%>-<%= customer.getPrefix(0)%>-<%= customer.getLineNumber(0)%></td>
    <td><span class="label">Ex:</span> <%= customer.getExtension(0)%></td>
    <% } %>
  </tr>
  <tr> 
    <td class="label">Company:</td>
    <td class="body"><%= customer.getCompanyName()%></td>
    <td>&nbsp;</td>
    <% if (!customer.getPrefix(1).equals("")) { %>
    <td class="label"><taglib:LUTableValueTag table="lu_phone_types" selected="<%= customer.getPhoneTypeIdString(1)%>"/>:</td>
    <td>&nbsp;</td>
    <td class="body"><%= customer.getAreaCode(1)%>-<%= customer.getPrefix(1)%>-<%= customer.getLineNumber(1)%></td>
    <td><span class="label">Ex:</span> <%= customer.getExtension(1)%></td>
    <% } %>
  </tr>
  <tr> 
    <td class="label">Email:</td>
    <td class="body"><%= customer.getEmail()%></td>
    <td>&nbsp;</td>
    <% if (!customer.getPrefix(2).equals("")) { %>
    <td class="label"><taglib:LUTableValueTag table="lu_phone_types" selected="<%= customer.getPhoneTypeIdString(0)%>"/>:</td>
    <td>&nbsp;</td>
    <td class="body"><%= customer.getAreaCode(2)%>-<%= customer.getPrefix(2)%>-<%= customer.getLineNumber(2)%></td>
    <td><span class="label">Ex:</span> <%= customer.getExtension(2)%></td>
    <% } %>
  </tr>
  <tr> 
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td class="body"  colspan=3>
    <div class='subtitle'>Bill to:</div>
    <%= customer.getAddressBill1()+((customer.getAddressBill2().equals(""))?"":"<br>")+customer.getAddressBill2()+"<br>"+customer.getCityBill()+", "%><taglib:LUTableValueTag table="lu_abreviated_states" selected="<%= customer.getStateBillId()%>"/>&nbsp;&nbsp;&nbsp;<%= customer.getZipcodeBill()%><br>Country:<taglib:LUTableValueTag table="lu_countries" selected="<%= customer.getCountryBillId()%>"/></td>
    <td>&nbsp;</td>
    <td  colspan=3><jsp:include page="/includes/MailingAddressForm.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /><jsp:param name="editor" value="<%=editor%>" /><jsp:param name="displayClass" value="body" /></jsp:include></td>
  </tr>
</table>
