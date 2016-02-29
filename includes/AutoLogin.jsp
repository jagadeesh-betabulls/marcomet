<%
	if(session.getAttribute("contactId") == null){
		Cookie[] cookies = request.getCookies();

		//if no cookies are found, you don't get an array of zero length but a null object
		if(cookies != null){
			//loop through the cookies for the proper one for our site
			for(int i = 0; i < cookies.length; i++){
				if(cookies[i].getName().equals("qwerty")){
%>
<script language="JavaScript">
	var cu = parent.window.location.href;
	window.location.replace("/servlet/com.marcomet.users.security.LoginUserServlet?$$Return=["+cu.substring(cu.indexOf("/index.jsp"))+"]");
</script>
<%				
				}	
			}	
		}
	}	
%>
