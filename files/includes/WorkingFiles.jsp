<%@ page import="java.util.*,java.text.DecimalFormat,java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.users.admin.*,com.marcomet.users.security.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%
   boolean alt = false;
   boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) || (request.getParameter("editor")!=null && request.getParameter("editor").equals("true")));

   String countQuery = "SELECT count(*) AS count FROM file_meta_data fmd, contacts c WHERE c.id = fmd.user_id AND (category = 'Working' or category='Laser' or category='PrePress') AND job_id = " + request.getParameter("jobId");
   Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
   Statement st = conn.createStatement();
   Statement st2 = conn.createStatement();
   ResultSet countRS = st.executeQuery(countQuery);
   if (countRS.next() && countRS.getInt("count") > 0) {
      String workingQuery = "SELECT fmd.id, file_name, fmd.company_id AS company_id, file_size, description, status, DATE_FORMAT(creation_date,'%m/%d/%y') AS creation_date, firstname AS first_name, lastname AS last_name, job_id, project_id, group_id FROM file_meta_data fmd, contacts c WHERE c.id = fmd.user_id AND category = 'Working' AND job_id = " + request.getParameter("jobId") + " ORDER BY creation_date DESC";
      ResultSet workingRS = st2.executeQuery(workingQuery);
      request.setAttribute("workingRS", workingRS); %>
<P><SPAN class=offeringTITLE>Working Files:</SPAN> <SPAN class=body><%if (editor){%><a href='javascript:pop("/popups/QuickChangeHTMLForm.jsp?cols=60&rows=3&question=Change%20Intro%20Text&primaryKeyValue=<%=sl.getValue("pages","page_name","'workingFilesIntro'","id")%>&columnName=body&tableName=pages&valueType=string",500,350)'>&raquo;</a>&nbsp;<%}%><%=sl.getValue("pages","page_name","'workingFilesIntro'","body")%></SPAN></P>
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
   } 
   conn.close(); %>