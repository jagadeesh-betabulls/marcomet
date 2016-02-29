<%@ page isErrorPage="true" %>
<%@ page errorPage="/users/ChangePasswordForm.jsp" %>
<%@ page import="java.util.*,java.sql.*,com.marcomet.jdbc.*,com.marcomet.environment.SiteHostSettings;" %>
<% SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); %>
<jsp:useBean id="validator" class="com.marcomet.tools.FieldValidationBean" scope="page" />
<%

Connection conn = DBConnect.getConnection();
String contactId=(session.getAttribute("contactId")==null)?"0":(String)session.getAttribute("contactId"); 
String newPassword = request.getParameter("newPassword");
String sql1 = "SELECT contact_id,user_name FROM logins WHERE contact_id=?";
String errMessage="";
PreparedStatement selectLogin =  null;
try {
	selectLogin = conn.prepareStatement(sql1);
	selectLogin.setString(1,contactId);
	ResultSet rs1 = selectLogin.executeQuery();
	if (rs1.next() || (request.getParameter("proxyId")!=null && !request.getParameter("proxyId").equals(""))) {
		Statement st = conn.createStatement();
		String updateSQL = "update logins set user_password=md5(?) where contact_id=?";
		try {

			//lock table
			st.execute("LOCK TABLES logins WRITE");
			PreparedStatement updatePassword = conn.prepareStatement(updateSQL);
			updatePassword.clearParameters();
			updatePassword.setString(1, newPassword);
			updatePassword.setInt(2, rs1.getInt("contact_id"));
			updatePassword.execute();
			request.setAttribute("returnMessage", "Password updated");

		} finally {
			st.execute("UNLOCK TABLES");
			st.close();
		}		
	} else {
		errMessage="There was a problem updating the password -- please be sure you're logged in as the user with a valid proxy ID.";
	}
} catch(SQLException sqle) {
	%>FAILED: <%=errMessage%><%
	throw new ServletException("SQL Error: " + sqle.getMessage());
} finally {
	selectLogin.close();
	conn.close();
}
%><html>
<head>
  <title>Change Password</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=shs.getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body leftmargin="40" topmargin="100" text="#000000">
<div class='Title'><%=errMessage%>Password changed to: <%=newPassword%></div><br><br><div class='subtitle'>Please be sure to notify the contact!</div>
</body>
</html>