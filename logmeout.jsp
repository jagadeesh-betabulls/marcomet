<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.util.*"%>
<%@ page import="com.marcomet.jdbc.ConnectionBean"%>

<html>
<head>
<%

//HttpSession session = request.getSession(true);


		//remove session 
		session.invalidate();
				System.out.println("session closed ");
				Cookie c2 =new Cookie("qwerty",null);
				//c.setVersion(1);
				c2.setPath("/");
				c2.setComment("ask Tom");
				c2.setMaxAge(0);
				response.addCookie(c2);
			
%>


<script lanuage="JavaScript">
	parent.window.parent.window.location.replace("/");
</script>
</head>
</html>
