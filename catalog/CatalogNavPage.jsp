<%@ page import="java.util.*" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
<head>
  <title>Catalog Wizard</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">

</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/continueover.gif', '/images/buttons/cancelbtover.gif');populateTitle('<%= (String)request.getAttribute("title")%>')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.catalog.CatalogNavigationServlet">
  <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%" >
    <tr> 
      <td colspan="2" align="center"> 
        <table width="98%">
          <tr> 
            <td class="body"> <%=(request.getAttribute("description") == null) ? "This is where the description would be" : request.getAttribute("description")%> 
            </td>
          </tr>
        </table>
      </td>
    </tr>
    <tr> 
      <td align="center" width="40%" valign="top"><%=(request.getAttribute("picUrl") == null )? "" : request.getAttribute("picUrl")%> 
      </td>
      <td width="60%" class="offeringITEM" valign="top"> <span class="offeringTITLE">&nbsp;</span><br>
        <%=(request.getAttribute("subdescription") == null) ? "" : request.getAttribute("subdescription")%> 
        <%
	  Vector linksVector = (Vector)request.getAttribute("linksVector"); 
%>
        <ul >
          <%
	  for (Enumeration e = linksVector.elements(); e.hasMoreElements(); ) { %>
          <li class="offeringITEM"><%=e.nextElement()%></li>
          <%  
	  } %>
        </ul>
      </td>
    </tr>
    <tr> 
      </tr>
    <tr> 
      <td valign="middle" colspan="2" align="center"><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp')" class="greybutton">Cancel</a>
      </td>
    </tr>
    <tr> 
      </tr>
    <tr> 
      <td valign="bottom" colspan="2"> 
        <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include>
      </td>
    </tr>
  </table>
</form>
</body>
</html>
