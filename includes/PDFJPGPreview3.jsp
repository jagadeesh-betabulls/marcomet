<%@page import="javax.servlet.*" %>
<html><head>
</head><body>
<%
String pageNum=((request.getParameter("pageNum")==null)?"0":request.getParameter("pageNum"));
String fileStr=((request.getParameter("fileStr")==null)?"":request.getParameter("fileStr"));
boolean neg=((request.getParameter("reverse")!=null && request.getParameter("reverse").equals("true"))?true:false);

String inStr = "/home/webadmin/marcomet-test.virtual.vps-host.net/html"+fileStr+".pdf";
String outStr = "/home/webadmin/marcomet-test.virtual.vps-host.net/html"+fileStr+".jpg";
if (neg){
	Runtime.getRuntime().exec(new String[] {"convert", "-density", "200x200","-geometry","600x600","-negate", inStr+"["+pageNum+"]", outStr}).waitFor();
}else{
	Runtime.getRuntime().exec(new String[] {"convert", "-density", "200x200", "-geometry","600x600", inStr+"["+pageNum+"]", outStr}).waitFor();
}
%>
<div align="center"><div>Click image to view PDF</div><a href="<%=fileStr+".pdf"%>" target="_blank"><img src="<%=fileStr+".jpg"%>" border=1></a></div></body></html>