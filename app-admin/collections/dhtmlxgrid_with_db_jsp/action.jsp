<%@ page language="java" contentType="text/xml; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"
%>
<jsp:useBean id="Test" class="n14.Base">
</jsp:useBean>
<%@ include file="config.jsp" %>
<%
String type= (String)request.getParameter("type");
Test.con(dbName,userName,userPass);
if(type.intern() == "getAuthorsList".intern()){
	Test.getAuthorList(response);
} else if(type.intern() == "createXML".intern()){
	Test.createXML(response);
} else if (type.intern() == "delete".intern()){
	Test.id = request.getParameter("id");
	Test.delete();
	out.println("<status value='ok' oldid='"+request.getParameter("id")+"' rowid='"+Test.id+"'/>");
} else if (type.intern() == "add".intern()){
	Test.init_(request);
	Test.add();
	out.println("<status value='ok' oldid='"+request.getParameter("id")+"' rowid='"+Test.id+"'/>");
} else if (type.intern() == "update".intern()){
	Test.init_(request);
	Test.id = request.getParameter("id");
	Test.update();
	out.println("<status value='ok' oldid='"+request.getParameter("id")+"' rowid='"+Test.id+"'/>");
}else out.println("<status value='ok' oldid='"+request.getParameter("id")+"' rowid='"+Test.id+"'/>");
%>