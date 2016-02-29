<%@ page import="com.marcomet.environment.SiteHostSettings;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
  <title>Catalog Wizard</title>
</head>
<frameset  ID=innerFr  framespacing="0" border="0" rows="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getInnerFrameSetHeight()%>,23,*,0" frameborder="0" cols="*"> 
  <frame name="header" scrolling="no" noresize target="main" src="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/headers/topmast_inner.jsp">
  <frame name="title" scrolling="no" noresize target="main" src="/headers/InnerTitle.jsp"><%  // Note for the record that I hate frames!
  String queryString = (String)request.getQueryString();
  int splitMark = (queryString).indexOf('=')  + 1;
  String source =  queryString.substring(splitMark);%><frame name="contents" src="<%=source%>" target="_self" scrolling="yes" noresize>
  <frame name="refresher" scrolling="no" noresize src="/contents/TimedRefreshPage.jsp">
<frame src="UntitledFrame-23"></frameset>
<noframes>
 <body>
   <p>This page uses frames, but your browser doesn't support them.</p>
 </body>
</noframes>
</html>