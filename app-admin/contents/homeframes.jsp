<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>


  <frameset ID=innerFr cols="200,*" frameborder="NO" border="0" framespacing="0" rows="*"> 
    <frame name="toc" scrolling="NO" noresize src="/navs/sbpcontents.jsp">
<%	if(request.getParameter("contents")==null){	%>
<%		
		//this is so that the vendor moves quicker to the job minder
		if(((String)session.getAttribute("vendorid")).equals((String)session.getAttribute("companyid"))){	
%>
			<frame name="homecontents" src="/minders/JobMinderSwitcher.jsp" scrolling="auto" target="main">
<%		}else{	%>
    		<frame name="homecontents" src="/contents/home.jsp" scrolling="auto" target="main">
<%		}
	}else{	%>
    	<frame name="homecontents" src="<%= request.getParameter("contents")%>" scrolling="auto" target="main">
<%	}	%>

  </frameset><noframes></noframes>
<body bgcolor="#FFFFFF" text="#000000"></body>
</html>
