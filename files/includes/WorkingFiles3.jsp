<%@ page import="java.sql.*, java.text.DecimalFormat;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%
   boolean alt = false;
   String countQuery = "SELECT count(*) AS count FROM file_meta_data fmd, contacts c WHERE c.id = fmd.user_id AND category = 'Working' AND job_id = " + request.getParameter("jobId");
   Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
   Statement st = conn.createStatement();
   Statement st2 = conn.createStatement();
   ResultSet countRS = st.executeQuery(countQuery);
   countRS.next();
   if (countRS.getInt("count") > 0) {
      String workingQuery = "SELECT fmd.id, file_name, fmd.company_id AS company_id, file_size, description, status, DATE_FORMAT(creation_date,'%m/%d/%y') AS creation_date, firstname AS first_name, lastname AS last_name, job_id, project_id, group_id FROM file_meta_data fmd, contacts c WHERE c.id = fmd.user_id AND category = 'Working' AND job_id = " + request.getParameter("jobId") + " ORDER BY creation_date DESC";
      ResultSet workingRS = st2.executeQuery(workingQuery);
      //if (workingRS.next()) {
      //workingRS.first();
      request.setAttribute("workingRS", workingRS); %>
<P><SPAN class=offeringTITLE>Working Files:</SPAN> <SPAN class=body>These are 
  files submitted by any party related to the job. They may include samples, supplied 
  design components, photos, text (copy), printable files, etc.</SPAN></P>
<table cellpadding="3" cellspacing="0" width="100%" bordercolor="#000000" style="border-top:1 solid Black;border-bottom:1 solid Black;border-left:1 solid Black;border-right:1 solid Black;">
  <tr> 
    <td width="4%" nowrap class="minderheaderleft">Select&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td class="minderheaderleft"> 
      <div align="left">&nbsp;File Name</div>
    </td>
    <td class="minderheaderleft"> 
      <div align="left">File Size</div>
    </td>
    <td class="minderheaderleft"> 
      <div align="left">Uploaded By</div>
    </td>
    <td class="minderheaderleft"> 
      <div align="left">Upload Date</div>
    </td>
    <td class="minderheaderleft"> 
      <div align="left">File Description</div>
    </td>
  </tr>
  <iterate:dbiterate name="workingRS" id="i"> <%
  double fileSize =  workingRS.getDouble("file_size");
  String tag = "bytes";
  if (fileSize > 1024*1024) {
    fileSize = fileSize / (1024*1024);
    tag = "Mb";
  } else if (fileSize > 1024) {
    fileSize = fileSize / 1024;
    tag = "Kb";
  }
  DecimalFormat precisionTwo = new DecimalFormat("0.##");
  String formattedFileSize = precisionTwo.format(fileSize); %>
  <tr> 
      <td class=lineitem<%=(alt)?"alt":""%> align="left" width="4%"> 
        <input type="checkbox" name="fileList" value="<%= workingRS.getString("id") %>">
      </td>
    <td class="lineitem<%=(alt)?"alt":""%>">&nbsp;<a class="minderLink" href="javascript:pop('/transfers/<$ company_id $>/<$ file_name $>',300,300)"><$ file_name $></a></td>
    <td class="lineitem<%=(alt)?"alt":""%>"><%=formattedFileSize%> <%=tag%></td>
    <td class="lineitem<%=(alt)?"alt":""%>"><$ last_name $> , <$ first_name $></td>
    <td class="lineitem<%=(alt)?"alt":""%>"><%= workingRS.getString("creation_date") %></td>
    <td class="lineitem<%=(alt)?"alt":""%>"><%= workingRS.getString("description") %></td>
  </tr><%
  alt = (alt)?false:true; %>
  </iterate:dbiterate> 
</table>
<hr size=1 color=red><%
//}
   }
   st.close();
   st2.close(); 
   conn.close(); %>