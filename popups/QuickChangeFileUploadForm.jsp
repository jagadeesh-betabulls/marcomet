<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.users.security.*" %>
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
  <table class="body"><%
if (error != null) { 
	%><tr> 
        <td class=label colspan="2"><%= error %></td>
    </tr>
    <tr> <%
    	} 
     %><td class=label><a href="javascript:popUpHelp('fup_File')" class=label>Select file to upload:</a></td>
      <td class=label>
        <input type="file" name="file0" size="40"><input type="hidden" name="description0" value='ROC File'>
<input type="hidden" name="jobId" value='0'>
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
  </table><%
String tableName = ((request.getParameter("tableName")==null)?"":request.getParameter("tableName"));
String idField = ((request.getParameter("idField")==null)?"":request.getParameter("idField"));
String idFieldValue = ((request.getParameter("idFieldValue")==null)?"":request.getParameter("idFieldValue"));
String fileNameField = ((request.getParameter("fileNameField")==null)?"":request.getParameter("fileNameField"));	
String fileDirectory = ((request.getParameter("fileDirectory")==null)?"":request.getParameter("fileDirectory"));
String fileDirectoryStr = ((request.getParameter("fileDirectoryStr")==null)?"":request.getParameter("fileDirectoryStr"));	
String customMetadata = ((tableName.equals(""))?"false":"true");

session.setAttribute("tempUpload",fileDirectoryStr);

//usage: tableName=&idField=&idFieldValue=&fileNameField=&fileDirectory=

%><input type="hidden" name="category" value="ROC">
<input type="hidden" name="tableName" value="<%=tableName%>">
<input type="hidden" name="idField" value="<%=idField%>">
<input type="hidden" name="idFieldValue" value="<%=idFieldValue%>">
<input type="hidden" name="fileNameField" value="<%=fileNameField%>">
<input type="hidden" name="fileDirectory" value="<%=fileDirectory%>">
<input type="hidden" name="fileDirectoryStr" value="<%=fileDirectoryStr%>">
<input type="hidden" name="customMetadata" value="<%=customMetadata%>">
</form>
</body>
</html>