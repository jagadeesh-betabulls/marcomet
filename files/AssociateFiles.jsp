<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*, com.marcomet.jdbc.*,com.marcomet.users.security.*"%> <%  
   int companyid = Integer.parseInt((String)session.getAttribute("companyId"));
   String jobId = (String)request.getParameter("jobId");

  
   Connection conn = DBConnect.getConnection();
   Statement st = conn.createStatement();
	  
   ResultSet rs0 = st.executeQuery("Select project_id from jobs where id = " + jobId);
   String projectId = "";
   while (rs0.next()) {   
	   projectId = rs0.getString("project_id");
   }

   String query = "";
   if(((RoleResolver)session.getAttribute("roles")).isVendor()){
	   query = "SELECT fmd.id, fmd.file_name, fmd.description, fmd.company_id, fmd.project_id FROM file_meta_data fmd, jobs j, vendors v WHERE fmd.job_id = j.id AND j.vendor_id = v.id AND v.company_id = " + session.getAttribute("companyId") + " AND fmd.job_id != " + jobId;
   } else {
       query = "select id, file_name, description, company_id, project_id from file_meta_data where job_id != " + jobId + " and company_id = " + companyid;
   }
   ResultSet rs1 = st.executeQuery(query);
   st.close();
   conn.close();
%>
<html>
  <head>
    <title>Associate Files</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  
</head>
  <script language="JavaScript" src="/javascripts/mainlib.js"></script>
  
<body class="contentstitle" onLoad="MM_preloadImages('/images/buttons/canceldown.gif','/images/buttons/submitdown.gif')">
<form method="post" action="/servlet/com.marcomet.files.FileManagementServlet">
      
  <p class="Title">Associate Files</p>
  <table class="body">
    <tr> 
      <td colspan="5" class="label">Select the files that you would like to associate 
        with job # <%= jobId %></td>
    </tr>
    <tr> 
      <td colspan="10">&nbsp;</td>
    </tr>
    <tr> 
      <td class="tableheader">Select</td>
      <td class="tableheader">File Name</td>
      <td colspan="2" class="tableheader">Description</td>
    </tr>
    <%
int i = 0; 
while (rs1.next()) { 
    i = 1;
%>
    <tr> 
      <td>
        <div align="center">
          <input type="checkbox" name="associatedFileList" value="<%= rs1.getString("id") %>">
        </div>
      </td>
      <td><a href="javascript:pop('/transfers/<%= rs1.getString("company_id") %>/<%= rs1.getString("file_name") %>',300,300)" class="minderLink"><%= rs1.getString("file_name") %></a></td>
      <td colspan="2"><%= rs1.getString("description") %></td>
    </tr>
    <% } 
if (i==0) { %>
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="10">
        <div align="center" class="contentstitle">There are no files for you to 
          associate with this job.</div>
      </td>
    </tr>
    <table align="center">
      <tr> 
        <td>&nbsp;</td>
        <td align="center"><a href="/files/JobFileViewer.jsp?jobId=<%=jobId%>" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('cancel','','/images/buttons/cancelbtover.gif',1)" onMouseDown="MM_swapImage('cancel','','/images/buttons/cancelbtdown.gif',1)"><img name="cancel" border="0" src="/images/buttons/cancelbt.gif" width="74" height="20"></a></td>
        <td>&nbsp;</td>
      </tr>
    </table>
    <% }else{%>
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="2" class="label">The selected file(s) will be attached to the job categorized as:
      <td> 
      <td> 
        <select name="category">
          <option value="Working">Working</option>
        </select>
      </td>
    </tr>
    <tr> 
      <td colspan="10">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="10"> 
        <table align="center">
          <tr> 
            <td><a href="/files/JobFileViewer.jsp?jobId=<%=jobId%>" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('cancel','','/images/buttons/cancelbtover.gif',1)" onMouseDown="MM_swapImage('cancel','','/images/buttons/cancelbtdown.gif',1)"><img name="cancel" border="0" src="/images/buttons/cancelbt.gif" width="74" height="20"></a></td>
            <td width="20">&nbsp;</td>
            <td><a href="javascript:document.forms[0].submit()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('OK','','/images/buttons/submitover.gif',1)" onMouseDown="MM_swapImage('OK','','/images/buttons/submitdown.gif',1)"><img name="OK" border="0" src="/images/buttons/submit.gif" width="74" height="20"></a></td>
          </tr>
        </table>
        <%	}	%>
      </td>
    </tr>
  </table>
      <input type="hidden" name="action" value="associate">
      <input type="hidden" name="jobId" value="<%=jobId%>">
      <input type="hidden" name="projectId" value="<%=projectId%>">
      <input type="hidden" name="redirect" value="/files/fileManager.jsp?jobId=<%=jobId%>">
    </form>
  </body>
</html>
