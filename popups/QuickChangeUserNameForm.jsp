<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
String newContactId="";
String tableName=((request.getParameter("tableName")==null || request.getParameter("tableName").equals(""))?"jobs":request.getParameter("tableName"));
String newValue=request.getParameter("newValue");
String titleText="Change User Name";

if(newValue!=null && newValue.equals("") ){
	titleText="Change User Name: Error - No User Name supplied";
}else if (request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true")){
//check to see if the username already exists and isn't this user
	String newValSQL="Select contact_id from logins where user_name='"+newValue+"'";
	ResultSet rsNV=st.executeQuery(newValSQL);
	if (rsNV.next()){
		newContactId=rsNV.getString("contact_id");
	}
	if ( !(newContactId.equals("")) && !(newContactId.equals(request.getParameter("primaryKeyValue")))){
		titleText="This user name already exists in our system, please choose another.";
	}else{
		String updateSQL = "Update logins set user_name=? where contact_id=?";
		PreparedStatement update = conn.prepareStatement(updateSQL);
		update.clearParameters();
		update.setString(1, request.getParameter("newValue"));
		update.setString(2, request.getParameter("primaryKeyValue"));
		update.executeUpdate();
		titleText="";
	}
}

if (titleText.equals("")){
%><html><head><script>parent.window.opener.location.reload();setTimeout('close()',500);</script></head><body></body></html><%
}else{
%><html>
<head>
  <title><%= titleText %></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body>
<form method="post" action="/popups/QuickChangeUserNameForm.jsp">
<table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
  <tr><td class="tableheader"><%=titleText%></td></tr>
  <tr><td class="lineitems" align="center">
      <textarea name="newValue" cols="<%=request.getParameter("cols")%>" rows="<%=request.getParameter("rows")%>"><%
      if(newValue==null){
		  java.sql.ResultSet rs = st.executeQuery("SELECT " + request.getParameter("columnName") + " FROM "+request.getParameter("tableName")+" j WHERE j.contact_id = " + request.getParameter("primaryKeyValue"));
		  if (rs.next()) { 
			%><%=rs.getString(1)%><%
		  } 
      }else{
      	%><%=newValue%><%
      }
      %></textarea></td></tr>
<tr><td align="center">
<input type="submit" value="Update" >&nbsp;&nbsp;<input type="button" value="Cancel" onClick="self.close()" ></td></tr>
</table>
<input type="hidden" name="submitted" value="true">
<input type="hidden" name="columnName" value="<%=request.getParameter("columnName")%>">
<input type="hidden" name="valueType" value="<%=request.getParameter("valueType")%>">
<input type="hidden" name="primaryKeyValue" value="<%=request.getParameter("primaryKeyValue")%>">
<input type="hidden" name="tableName" value="<%=request.getParameter("tableName")%>">
<input type="hidden" name="$$Return" value="<script><%=((request.getParameter("refreshOpener")!=null)?"":"parent.window.opener.location.reload();")%>setTimeout('close()',500);</script>">
<%=((request.getParameter("autosubmit")!=null && request.getParameter("autosubmit").equals("true"))?"<script>document.forms[0].submit()</script>":"")%>
</form></body>
</html><%
}
st.close();conn.close();%>