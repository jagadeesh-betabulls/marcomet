<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%
String contentPage=((request.getParameter("contentPage")==null)?"":request.getParameter("contentPage")).replace("|","?").replace("~","&");
String subTitle= ((request.getParameter("subTitle")==null)?"":request.getParameter("subTitle")).replace("|","?").replace("~","&");
%>
<html>
<head>
<title>DIY Design Center</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<body style="margin-left:20px;margin-top:10px;">
<%if (!(contentPage.equals(""))){%>
<jsp:include page="/catalog/SHDCHeader.jsp" flush="true" >
	<jsp:param name="subTitle" value="<%=subTitle%>" />
</jsp:include>
<jsp:include page="<%=contentPage%>" flush="true" /><%}%>
</body>
</html>
