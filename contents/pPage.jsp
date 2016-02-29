<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.net.*,java.io.*,java.text.*,java.sql.*,com.marcomet.environment.*,com.marcomet.jdbc.*,com.marcomet.users.security.*" %>
<html><head>
<%
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
boolean editor=(((RoleResolver)session.getAttribute("roles")).roleCheck("editor"));
String id=((request.getParameter("id")==null)?"":request.getParameter("id"));
ResultSet rs = st.executeQuery("SELECT portal_page_url url,context FROM portal_pages WHERE id="+id);
%><%
if (rs.next()){
	int charsRead=0;
	StringBuffer outStr = new StringBuffer(); 
	URL url = new URL(rs.getString("url")); 
	URLConnection con = url.openConnection(); 
	con.setRequestProperty("context",rs.getString("context"));
	con.connect(); 
	String encoding = con.getContentEncoding(); 
	BufferedReader in = null; 
	if (encoding == null) { 
		in = new BufferedReader(new InputStreamReader(url.openStream())); 
	} else { 
		in = new BufferedReader(new InputStreamReader(url.openStream(), encoding));
	}
	char[] buf = new char[4 * 1024]; // 4Kchar buffer int charsRead; 
	while ((charsRead = in.read(buf)) != -1) { 
		outStr.append(buf,0, charsRead); 
	}	 
	%><BASE HREF="<%=rs.getString("context")%>"></head><%= outStr.toString() %></html><%  
}
rs.close();
st.close();
conn.close();%>