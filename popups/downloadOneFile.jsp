<%@page import="java.util.*,javax.servlet.*, com.marcomet.catalog.*, com.pdflib.*,org.jpedal.*,java.io.*,javax.imageio.*,java.awt.Graphics,java.awt.Image,java.awt.image.*,com.marcomet.jdbc.*,java.sql.*" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib80.tld" prefix="do" %> 
<%

ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
String homeDir = bundle.getString("transfersPrefix");

String dlFile=((request.getParameter("dlFile")==null)?"":request.getParameter("dlFile"));
%><html><head><title>File Download</title></head>
<body><%
if (dlFile.equals("")){
	%>File Not Found.<%
}else{
	%>
	<%
	if(request.getParameter("modal")==null){%>
<h2 align="center">File Downloaded.<br>
<br><input type="button" value="Continue" onClick="javascript:window.close();"></h2>
<%}else{
	%><div class='subtitle' align='center'>File Downloaded.<br><br>
	<input type="button" value="Continue" onClick="AjaxModalBox.close()"></div>
<%}%>
	<do:download file="<%=homeDir+dlFile%>"/><%
}%>
</body>
</html>