<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<%@ page import="com.marcomet.users.security.*,java.sql.*,java.util.*" %>
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
boolean print = ((request.getParameter("print")==null || !(request.getParameter("print").equals("true")))?false:true);
String actingRole = request.getParameter("actingRole");
String ioNumber=((request.getParameter("ioNumber")==null)?"":request.getParameter("ioNumber"));
String subvendor="";
String jobId=request.getParameter("jobId");
String valStr=request.getParameter("jobId");
boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) && !(print));
boolean sitehost= ((((RoleResolver)session.getAttribute("roles")).isSiteHost()) );
%><html>
<head> 
  <title>Insertion Order</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head> 
<body>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<div class="Title">Insertion Order #<%=ioNumber%></div><br /><br /><%
   %>Insertion Order here.
</body>
</html><%st.close();conn.close();%>