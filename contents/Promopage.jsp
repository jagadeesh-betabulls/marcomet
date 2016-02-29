<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="session" /><%
//SimpleConnection sc = new SimpleConnection();
String cookieFound="false";
String campaignFound="false";
Connection conn = DBConnect.getConnection();
int campaignId=((request.getParameter("cId1")==null || request.getParameter("cId1").equals(""))?0:Integer.parseInt(request.getParameter("cId1")));

Cookie c2 = new Cookie("mcpr",Integer.toString(campaignId));
Cookie[] cookies = request.getCookies();
if (campaignId!=0){
//check to see if this visitor has been to this page previously, if not record it and place a cookie. If so, do nothing.
	if(cookies != null){
		for(int i = 0; i < cookies.length; i++){
			if(cookies[i].getName().equals("mcpr"+campaignId)){	
				cookieFound="true";		
			}
		}	
	}

	if(cookieFound.equals("false")){
		//put down a cookie to track whether this user has been to this page
		c2.setPath("/");
		c2.setComment("MC: Promo #"+campaignId);
		c2.setMaxAge(30*24*60*60);
		response.addCookie(c2);
		String updateSQL="update email_campaigns set number_of_views=number_of_views+1 where id="+campaignId;
		PreparedStatement upD = conn.prepareStatement(updateSQL);
		upD.execute();
	}

	String sql="select html from email_campaigns where id="+campaignId;
	PreparedStatement campaign1 = conn.prepareStatement(sql);
	ResultSet rs = campaign1.executeQuery();
	if (rs.next()){
		%><%=rs.getString("html")%><%
		campaignFound="true";
	}
	rs.close();
	campaign1.close();
	
}
if (campaignFound.equals("false")){%>
<html>
	<head>
		<title>Email Promotion Not Found</title>
	</head>
	<body><p>This is an invalid promotion reference, or this promotion has expired. Please click here to continue to the marketing home page: <a href="/" class='menuLINK'>HOME</a></p></body>
	</html><%}%>
<%		
	conn.close();%>
