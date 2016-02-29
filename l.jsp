<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%
		//remove session 
		session.invalidate();
				
				Cookie c2 =new Cookie("qwerty",null);
				//c.setVersion(1);
				c2.setPath("/");
				c2.setComment("ask Tom");
				c2.setMaxAge(0);
				response.addCookie(c2);
			
%>

<html>
<head>
<jsp:include page="/includes/LoadSiteHostInformation.jsp" flush="true"/>
<script lanuage="JavaScript">
	parent.window.parent.window.location.replace("/");
</script>
</head>
</html>
