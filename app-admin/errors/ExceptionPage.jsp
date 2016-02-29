<%@ page isErrorPage="true" %>
<%@ page import="java.util.*" %>
<html>
<head>
  <title>Error Page</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<body>
An Error has Occured, sorry for the inconvenience. 
<p>
<a href="javascript:parent.window.parent.window.location.replace('/')">Home</a>
<!--
<b>Error(s):</b><br>
<pre><%= exception.getMessage() %></pre>
<p>
<b>Stack Trace:</b><br>
<pre>
<% 
	 java.io.PrintWriter outstream = new java.io.PrintWriter(out);
         exception.printStackTrace(outstream);
%>
</pre>
<p>

<table>
<tr><td colspan="2"><b>Session Variables</b></td></tr>
<%-- 
	Enumeration varNames = session.getAttributeNames();
	String varValue = "";
	String varName = "";
	if(varNames.hasMoreElements()){
		do{
			varName = (String)varNames.nextElement();
			try{
				if(session.getAttribute(varName) == null){
					varValue="HAS NO VALUE";		
				}else{
					//varValue = (String)session.getAttribute(varName);
					varValue = session.getAttribute(varName).toString();
				}	
			}catch(Exception e){
				varValue="IS AN OBJECT" + ": " + e.getMessage();	
			}
%>
<tr><td><%= varName%></td><td><%= varValue %></td></tr>
<%
		}while(varNames.hasMoreElements());
	}else{
%>
<tr><td colspan="2">No Session Variables</td></tr>
<%	
	}
%>
</table>
<p>
<table>
<tr><td colspan="2"><b>Request Information:</b></td></tr>
<tr><td>JSP Request Method:</td><td><%= request.getMethod() %></td></tr>
<tr><td>Request URI:</td><td><%= request.getRequestURI()  %></td></tr>
<tr><td>Request Protocol:</td><td><%= request.getProtocol() %></td></tr>
<tr><td>Servlet path:</td><td><%= request.getServletPath() %></td></tr>
<tr><td>Path info:</td><td><%= request.getPathInfo() %></td></tr>
<tr><td>Path translated:</td><td><%= request.getPathTranslated() %></td></tr>
<tr><td>Query string:</td><td><%= request.getQueryString() %></td></tr>
<tr><td>Content length:</td><td><%= request.getContentLength() %></td></tr>
<tr><td>Content type:</td><td><%= request.getContentType() %></td></tr>
<tr><td>Server name:</td><td><%= request.getServerName() %></td></tr>
<tr><td>Server port:</td><td><%= request.getServerPort() %></td></tr>
<tr><td>Remote user:</td><td><%= request.getRemoteUser() %></td></tr>
<tr><td>Remote address:</td><td><%= request.getRemoteAddr() %></td></tr>
<tr><td>Remote host:</td><td><%= request.getRemoteHost() %></td></tr>
<tr><td>Authorization scheme:</td><td><%= request.getAuthType() %></td></tr>
</table>
<hr>
The browser you are using is <%= request.getHeader("User-Agent") --%>

-->
</body>
</html>