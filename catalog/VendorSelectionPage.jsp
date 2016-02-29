<%@ page import="java.util.*" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<html>
<head>
  <title>Catalog Wizard</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/cancelbtover.gif'); populateTitle('Vendor Selection')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%">
  <tr valign="center">
    <td>
      <table width="98%" align="center">
        <%
  Vector vendorChoices = (Vector)request.getAttribute("vendorChoices");
  if (vendorChoices.size() < 2) { %>
        <tr> 
          <td class="catalogLABEL" align="center">There are no vendors to choose 
            from for this catalog.</td>
        </tr>
        <%
  } else { %>
        <tr> 
          <td class="catalogLABEL" align="center">You may choose from any of the 
            following vendors to supply your <taglib:LUTableValueTag table="lu_job_types" selected="<%= request.getParameter(\"jobTypeId\")%>"/> 
            <taglib:LUTableValueTag table="lu_service_types" selected="<%= request.getParameter(\"serviceTypeId\") %>"/>.</td>
        </tr>
        <tr> 
          <td class="catalogLABEL" align="center">Please click on a listed vendor 
            to continue.</td>
        </tr>
        <tr> 
          <td class="catalogITEM">&nbsp;</td>
        </tr>
        <%
     for (int i=0; i<vendorChoices.size(); i=i+4) { %>
        <tr> 
          <td align="center"><a href=/servlet/com.marcomet.catalog.CatalogControllerServlet?catJobId=<%=vendorChoices.elementAt(i)%>&vendorId=<%=vendorChoices.elementAt(i+1)%>&offeringId=<%=request.getParameter("offeringId")%>&newProject=<%=request.getAttribute("newProject")%>&newJob=<%=request.getAttribute("newJob")%>&tierId=<%=vendorChoices.elementAt(i+3)%> class="minderACTION"><%=vendorChoices.elementAt(i+2)%></a></td>
        </tr>
        <%
     }
  }%>
      </table>
      <p class="catalogITEM">&nbsp;</p>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="2">
      <a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp')" class="greybutton">Cancel</a>
    </td>
  </tr>
  <tr>
    <td valign="bottom" colspan="10">
      <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include>
    </td>
  </tr>
</table>
</body>
</html>
