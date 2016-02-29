<%@ page import="java.sql.*, java.text.DecimalFormat;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%
   boolean alt = false;
   String countQuery = "SELECT count(*) AS count FROM file_meta_data fmd, contacts c WHERE c.id = fmd.user_id AND category = 'Final' AND job_id = " + request.getParameter("jobId");
   Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
   Statement st = conn.createStatement();
   Statement st2 = conn.createStatement();
   ResultSet countRS = st.executeQuery(countQuery);
   
   if (countRS.next() && countRS.getInt("count") > 0) {
      String productionQuery = "SELECT fmd.id, file_name, fmd.company_id AS company_id, file_size, description, status, DATE_FORMAT(creation_date,'%m/%d/%y') as creation_date, firstname AS first_name, lastname AS last_name, job_id, project_id, group_id FROM file_meta_data fmd, contacts c WHERE c.id = fmd.user_id AND (category = 'Final' or category='Laser' or category='PrePress') AND job_id = " + request.getParameter("jobId") + " ORDER BY creation_date DESC";
      ResultSet productionRS = st2.executeQuery(productionQuery);
      request.setAttribute("productionRS", productionRS); %>
<P><div class=offeringTITLE>Final Delivered Files:</div> <SPAN 
class=body>These are files submitted by the vendor via either an upload or 
physically shipped as the final delivery file of the project. Note: certain files 
may not be in a viewable format on-line. (i.e. - filename.ai). These files are 
for actual physical production of your project and can be used to print or 
produce your project.</SPAN></P>
<p></p>
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
      <div align="left">Responded on:</div>
    </td>
    <td class="minderheaderleft"> 
      <div align="left">File Description</div>
    </td>
  </tr>
  <iterate:dbiterate name="productionRS" id="i"><%
  double fileSize =  productionRS.getDouble("file_size");
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
        <input type="checkbox" name="fileList" value="<%= productionRS.getString("id") %>">
      </td>
    <td class="lineitemleft<%=(alt)?"alt":""%>">&nbsp<a class="minderLink" href="javascript:pop('/transfers/<$ company_id $>/<$ file_name $>',300,300)"><$ file_name $></a></td>
    <td class="lineitemleft<%=(alt)?"alt":""%>"><%=formattedFileSize%> <%=tag%></td>
    <td class="lineitemleft<%=(alt)?"alt":""%>"><$ last_name $> , <$ first_name $></td>
    <td class="lineitemleft<%=(alt)?"alt":""%>"><%=productionRS.getString("creation_date")%></td>
    <td class="lineitemleft<%=(alt)?"alt":""%>"><%=productionRS.getString("description")%></td>
  </tr><%
  alt = (alt)?false:true;%>
  </iterate:dbiterate>
</table>
<hr size=1 color=red><%
   } 
   conn.close();%>