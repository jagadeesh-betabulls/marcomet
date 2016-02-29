<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*" %>

<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
Statement st3 = conn.createStatement();
	boolean jobyn = false;
	String sql = "";
	ResultSet rs1;
	jobyn = (request.getParameter("jobId")!=null)?true:false;
%>
<html>
<head>
  <title>Email Form 03-30-03</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>

<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<jsp:getProperty name="validator" property="javaScripts" />
<body onLoad="MM_preloadImages('/images/buttons/checkover.gif','/iamges/buttons/cancelover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.files.FileManagementServlet" enctype="multipart/form-data">
  <p class="Title">Email Correspondence</p>
   <table border="0" width="600">
    <tr> 
      <td class="label">To:</td>
      <td class="body"> 
        <%
   if (jobyn) {
      String target = request.getParameter("target");
	  if (target.equals("vendor")) {
         sql="SELECT conts.* FROM jobs j, contacts conts WHERE j.vendor_contact_id = conts.id  AND j.id = "  + request.getParameter("jobId") + " ORDER BY conts.id DESC";
      } else if (target.equals("client")) {
         sql = "SELECT conts.* FROM orders o, projects p, jobs j, contacts conts WHERE o.buyer_contact_id = conts.id AND p.order_id = o.id AND j.project_id = p.id AND j.id = " + request.getParameter("jobId");
      }
      rs1 = st.executeQuery(sql);
      if (rs1.next() && !rs1.getString("email").equals("")) {
%>
        "<%=rs1.getString("firstname") + " " + rs1.getString("lastname") %>" <%= "&lt" + rs1.getString("email") + "&gt" %> 
        <input type="hidden" name="to" value="<%= rs1.getString("email") %>">
        <%		
      } else {		
         sql = "SELECT a.* FROM contacts a, companies b, contact_types ct WHERE ct.contact_id = a.id AND (ct.lu_contact_type_id = 4 OR ct.lu_contact_type_id = 1) AND b.id = 1 AND b.id = a.companyid ORDER BY ct.lu_contact_type_id DESC";
         rs1 = st2.executeQuery(sql);		
         if (rs1.next() && !rs1.getString("email").equals("")) {
%>
        "<%=rs1.getString("firstname") + " " + rs1.getString("lastname") %>" <%= "&lt" + rs1.getString("email") + "&gt" %> 
        <input type="hidden" name="to" value="<%= rs1.getString("email") %>">
        <%
         } else {
%>
        <input type="text" name="to" value="">
        <%
         }
      }
   } else { %>
        <input type="text" name="to" value="">
        <%
   }
%>
      </td>
    </tr>
    <tr> 
      <td class="label">From:</td>
      <td class="body"> 
        <%
   if (session.getAttribute("contactId")!=null) {
      sql = "select * from contacts where id =" + (String)session.getAttribute("contactId");
      rs1 = st2.executeQuery(sql);
      if (rs1.next()) {
%>
        "<%=(String)session.getAttribute("UserFullName")%>" <%= "&lt" + rs1.getString("email") + "&gt" %> 
        <input type="hidden" name="from" value="<%= rs1.getString("email") %>">
        <%
      }
   } else { %>
        <input type="text" name="from" value="">
        <%
   } %>
      </td>
    </tr>
    <tr> 
      <td class="label">Subject:</td>
      <td class="body"> 
        <input type="text" name="subject" value="" size="40">
      </td>
    </tr>
    <%
   if (jobyn) {
      sql = "SELECT p.order_id AS orderId, p.id AS projectId FROM jobs j, projects p WHERE p.id = j.project_id AND j.id = " + request.getParameter("jobId");
      rs1 = st2.executeQuery(sql);
      rs1.next();																	//fix this in some type of conditional
%>
    <tr> 
      <td class="label">Order Number</td>
      <td class="body"> <%= rs1.getString(1)	%> 
        <input type="hidden" name="orderNumber" value="<%= rs1.getString(1)	%>">
      </td>
    </tr>
    <tr> 
      <td class="label">Job#</td>
      <td class="body"> <%= request.getParameter("jobId") %> 
        <input type="hidden" name="jobId" value="<%= request.getParameter("jobId") %>">
      </td>
    </tr>
    <%
   } else {
      int companyid = Integer.parseInt((String)session.getAttribute("companyId"));

      String jobsQuery = "";
      if (session.getAttribute("roles") != null) {
         if (((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isVendor()) {
            jobsQuery = "SELECT id, job_name FROM jobs WHERE vendor_company_id = " + companyid;
         } else {
            jobsQuery = "SELECT j.id, job_name FROM orders o, projects p, jobs j WHERE p.order_id = o.id AND j.project_id = p.id AND buyer_company_id = " + companyid;
         }
      }

      ResultSet rsJobs = st2.executeQuery(jobsQuery);
%>
    <tr> 
      <td class="label">Job#</td>
      <td class="body"> 
        <select name="jobId">
          <% while (rsJobs.next()) { %>
          <option value="<%= rsJobs.getString("id") %>"><%= rsJobs.getString("id") %> 
          - <%= rsJobs.getString("job_name") %></option>
          <% } %>
        </select>
      </td>
    </tr>
    <%	}	%>
    <tr> 
      <td colspan="2" class="label"><u>Message</u></td>
    </tr>
    <tr> 
      <td colspan="2" class="label"> 
        <textarea name="message" cols="60" rows="5"></textarea>
      </td>
    </tr>
  </table>
  <table>
    <tr> 
      <td class="label" colspan="2"><u>Attachments</u></td>
    </tr>
    <% 	String[] fileIds = null;
	int length = 0;
	String fileName = "";
	String description = "";
	try {
		fileIds = request.getParameterValues("fileList");
		if (fileIds.length >= 1) {
			length = fileIds.length;
			for (int x = 0; x < fileIds.length; x++) {
				ResultSet rsFiles = st3.executeQuery("select file_name, description from file_meta_data where id = " + fileIds[x]); 
				while (rsFiles.next()) {
					fileName = rsFiles.getString("file_name");
					description = rsFiles.getString("description");
				}
%>
    <tr> 
      <td class="body"><%=fileName%> 
        <input type="hidden" name=emailFileName<%=x%> value="<%=fileName%>">
      </td>
      <td class="body"><%=description%> 
        <input type="hidden" name=emailFileDescription<%=x%> value="<%=description%>">
      </td>
    </tr>
    <%
			}
		}
	} catch(Exception ex) {}
%>
    <tr> 
      <td class="body"> 
        <input type="hidden" name="emailFileTotal" value="<%=length %>">
      </td>
    </tr>
  </table>
<jsp:include page="/includes/UploadFilesInclude.jsp" flush="true"/>
<br><br>
<table align="center" width="20%">
  <tr> 
    <td>
        <div align="center"><a href="javascript:document.forms[0].submit()"class="greybutton">Send</a></div>
      </td>
    <td width="3%">&nbsp;</td>	
    <td>
        <div align="center"><a href="javascript:history.back()"class="greybutton">Cancel</a></div>
      </td>
  </tr>
</table>
<input type="hidden" name="email" value="email">
<input type="hidden" name="status" value="Emailed">
<input type="hidden" name="category" value="Working">
<input type="hidden" name="redirect" value="/files/EmailSubmitted.jsp">
</form>
</body>
</html><%conn.close();%>