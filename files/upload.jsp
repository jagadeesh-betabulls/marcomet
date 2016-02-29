<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.users.security.*" %>
<%@ page import="com.marcomet.jdbc.*" %>
<html>
<head>
  <title>File Upload</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<% String error = (String)request.getAttribute("uploaderror"); %>
<body class="Title">
<form method="post" action="/servlet/com.marcomet.files.FileManagementServlet" enctype="multipart/form-data">
  <p class="Title">Upload a file </p>
  
  <table class="body">
    <% if (error != null) { %>
    <tr>    
      <td class=label colspan="2"><%= error %></td>
    </tr>
    <tr> 
      <%	} %>
      <td class=label><a href="javascript:popUpHelp('fup_File')" class=label>Select 
        file to upload:</a></td>
      <td class=label>
        <input type="file" name="file0" size="40">
      </td>
    </tr>
    <tr> 
      <td class=label>Enter a brief description:</td>
      <td class=label>
        <input type="text" name="description0" size="30">
      </td>
    </tr>
    <tr> 
      <td class="label">Job:</td>
      <td class="body"> 
        <%
		String jobId = request.getParameter("jobId");
		boolean specificJob = (jobId != null) ? true:false;
		int companyId = Integer.parseInt((String)session.getAttribute("companyId"));
		//REMOVED BY TOM: int vendorid = Integer.parseInt((String)session.getAttribute("vendorid"));
		String query = "";
		if (specificJob) {
			query = "select id, job_name from jobs where id = " + jobId;
		} else {
			query = "SELECT j.id, j.job_name FROM orders o, projects p, jobs j, vendors v WHERE j.vendor_id = v.id AND j.project_id = p.id AND p.order_id = o.id AND ((j.vendor_id = v.id AND v.company_id = " + companyId + ") OR ( o.buyer_company_id = " + companyId + ")) ORDER BY j.id DESC";
		}
		
		Connection conn = DBConnect.getConnection();
		Statement st = conn.createStatement();
		ResultSet rs = st.executeQuery(query);
		
		if (specificJob) { %>
        <input type="hidden" name="jobId" value=<%= jobId %> >
        <% if (rs.next()) { %>
        <%=rs.getInt("id")%> <span class="body">- <%=rs.getString("job_name")%> 
        <% } %>
        <% } else { %>
        </span> 
        <select name="jobId">
          <% while (rs.next()) { %>
          <option value=<%=rs.getInt("id")%>><%=rs.getInt("id")%> - <%=rs.getString("job_name")%></option>
          <% } %>
        </select>
        <% } %>
      </td>
    </tr>
    <% if (error != null) { %>
    <tr> 
      <td class=label> Select one of the following: </td>
      <td class=label> 
        <input type="radio" name="write" value="replace">
        Replace 
        <input type="radio" name="write" value="rename">
        Rename </td>
    </tr>
    <tr> 
      <td class=label>Enter a new name for the file:</td>
      <td class=label>
        <input type="text" name="newFileName">
      </td>
    </tr>
    <%	} %>
    <tr> 
      <td colspan="2"align="center">
        <input type="button" value="Cancel" onClick="window.close()">
		&nbsp;
		<input type="submit" value="Upload">
      </td>
    </tr>
  </table>
  <input type="hidden" name="category" value="Working">
  
</form>
</body>
</html>

<%
	st.close();
	conn.close();
%>
