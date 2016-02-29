<%@ page import="java.sql.*,com.marcomet.jdbc.*,java.util.*" %>
<% int companyId = Integer.parseInt((String)session.getAttribute("companyId"));
   String jobId = (String)request.getParameter("jobId");
   //String query = "SELECT file_name, fmd.id, description, fmd.project_id FROM file_meta_data fmd, jobs j, projects p, orders o WHERE category != 'Comp' and fmd.job_id = j.id and p.id = j.project_id and o.id = p.order_id and o.buyer_company_id = " + companyId +" GROUP BY file_name";
   String query = "SELECT file_name, fmd.id, description, fmd.project_id FROM file_meta_data fmd WHERE category != 'Comp' AND company_id = " + companyId + " GROUP BY file_name";
  
   Connection conn = DBConnect.getConnection();
   Statement st = conn.createStatement();
   ResultSet rsFiles = st.executeQuery(query);
   st.close();
   conn.close();

if (rsFiles.next()) { %>


<table width="75%">
  <tr>
    <td colspan="10">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="10" class="catalogTITLE">You may also select from the following 
      files from your file archive:</td>
  </tr>
  <tr>
    <td colspan="10">&nbsp;</td>
  </tr>
  <tr>
    <td class="minderheadercenter">Select</td>
    <td class="minderheaderleft">File Name</td>
    <td colspan="2" class="minderheaderleft">Description</td>
  </tr>
  <tr>
    <td>
      <div align="center">
        <input type="checkbox" name="associatedFileList" value="<%= rsFiles.getString("id") %>">
      </div>
    </td>
    <td><a href="javascript:pop('/transfers/<%= companyId %>/<%= rsFiles.getString("file_name") %>',300,300)" class="body"><%= rsFiles.getString("file_name") %></a></td>
    <td colspan="2" class="body"><%= rsFiles.getString("description") %></td>
  </tr><% 
  while (rsFiles.next()) { %>
  <tr>
    <td>
      <div align="center">
        <input type="checkbox" name="associatedFileList" value="<%= rsFiles.getString("id") %>">
      </div>
    </td>
    <td><a href="javascript:pop('/transfers/<%= companyId %>/<%= rsFiles.getString("file_name") %>',300,300)" class="body"><%= rsFiles.getString("file_name") %></a></td>
    <td colspan="2" class="body"><%= rsFiles.getString("description") %></td>
  </tr><%
  } %>
</table>
<% } %>