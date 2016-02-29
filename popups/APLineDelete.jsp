<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.jdbc.*,com.marcomet.users.security.*" %>
<jsp:useBean id="conn" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<%
String apidId=((request.getParameter("apidId")==null)?"":request.getParameter("apidId"));
if(apidId.equals("")){
%><script>parent.window.opener.location.reload();setTimeout('close()',500);</script><%
	return;
}else{
	conn.executeQuery("delete from ap_invoice_details where id="+apidId);
}%><script>parent.window.opener.location.reload();setTimeout('close()',500);</script>
