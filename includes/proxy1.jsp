<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<%
String proxyId=((request.getParameter("pId")==null)?"":request.getParameter("pId"));
int contactId=Integer.parseInt((request.getParameter("cId")==null)?"0":request.getParameter("cId"));
String sql1 = "SELECT id, firstname,lastname, email, companyid, md5(id) 'cookie encryption' FROM contacts WHERE id = ?";	
	//SimpleConnection sc = new SimpleConnection();
	Connection conn = DBConnect.getConnection();
	PreparedStatement selectContact= conn.prepareStatement(sql1);
	selectContact.setInt(1,contactId);
	ResultSet rs1 = selectContact.executeQuery();	
	
	if(rs1.next()){
		request.getSession().setAttribute("proxyId",proxyId);
		request.getSession().setAttribute("homeNotice","Proxy Order for "+rs1.getString("firstname")+" " + rs1.getString("lastname")+", Proxied by Customer Service Rep ID#"+((session.getAttribute("proxyId")==null)?"NONE":session.getAttribute("proxyId"))+". Please logout and close window when finished. <a href='/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=1009&jobTypeId=9998&serviceTypeId=9999&productId=5324' target='main'>&raquo;Click here to place a custom order for this client.</a>"+((rs1.getString("email").equals(""))?"<br><font color=red>NOTE: No Email on file for this user, please go to User Info and review all contact information with the customer.</font>":""));
		//set login cookie for autologin of proxy
		Cookie c2 =new Cookie("qwerty",rs1.getString("cookie encryption"));
		c2.setPath("/");
		c2.setComment("for Proxy Order");
		c2.setMaxAge(30*24*60*60);
		response.addCookie(c2);
		%><html><head><script language="JavaScript">
			var cu = parent.window.location.href;
			var loc=cu.substring(0,cu.indexOf("/includes"));
			window.location.replace(loc+"/index2.jsp");
		</script></head></html><%
	}else{
	%>No user was found with that ID, please try again.<%	
	}
	rs1.close();
	selectContact.close();
	conn.close();			
%>