<%@ page import="java.sql.*,java.text.DecimalFormat,com.marcomet.jdbc.SimpleConnection,com.marcomet.catalog.*,com.marcomet.environment.*;" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<html>
<head>
  <title>Catalog Wizard</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<%
SimpleConnection sc = new SimpleConnection();
Connection conn = sc.getConnection();
Statement st0 = conn.createStatement();
Statement st1 = conn.createStatement();

String query0 = "SELECT description, use_title_flag,title,page_pic, subdescription FROM catalog_pages WHERE page = 1 and cat_job_id = " + request.getParameter("catJobId");
ResultSet rsCatPages = st0.executeQuery(query0);
String titleString="";
if (rsCatPages.next()){
	titleString=((rsCatPages.getString("use_title_flag") != null && rsCatPages.getString("use_title_flag").equals("1"))?"<td class='title'>"+rsCatPages.getString("title")+"</td></tr><tr>":"");
}

String query1 = "SELECT price, rfq FROM catalog_pages cpa, catalog_prices cpr, catalog_price_definitions cpd WHERE page = 1 AND cpa.cat_job_id = cpd.cat_job_id AND row_number = '99999' AND cpd.id = cpr.catalog_price_definition_id  AND vendor_id = " + request.getParameter("vendorId") + " AND cpa.cat_job_id = " + request.getParameter("catJobId") + " AND price_tier_id = " + request.getParameter("tierId");
ResultSet rsPrices = st1.executeQuery(query1);
%>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/continueover.gif', '/images/buttons/cancelbtover.gif','/images/buttons/cancelbtdown.gif','/images/buttons/continuedown.gif'); populateTitle('<%= (String)request.getAttribute("title")%>')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.catalog.CatalogControllerServlet">
<table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%">
  <tr> 
    <td colspan="2" align="center"> 
      <table width="98%">
        <tr><%=titleString%>
          <td class="body"><%=((rsCatPages.getString("description") != null) ? rsCatPages.getString("description"):"")%></td>
        </tr>
      </table>
    </td>
  </tr>
  <tr> 
    <td align="center" width="40%"> <%=((rsCatPages.getString("page_pic")==null)?"":rsCatPages.getString("page_pic"))%> 
    </td>
      <td class="catalogITEM" width="60%"> <%=((rsCatPages.getString("subdescription")==null)?"":rsCatPages.getString("subdescription"))%> 
        <% if (rsPrices.next() && rsPrices.getString("price") != null) {
        int contactId = -1;
        try {
           contactId = Integer.parseInt((String)session.getAttribute("contactId")); 
        } catch (Exception ex) {}
		boolean proxyEnabled = false;
		try {
           ProxyOrderObject poo = (ProxyOrderObject)session.getAttribute("ProxyOrderObject");
           proxyEnabled = poo.isProxyEnabled();
        } catch (Exception ex) {} %>  
        <table cellpadding="0" cellspacing="0">
          <tr> 
            <td valign="top" class="catalogLABEL"><%=(rsPrices.getInt("rfq") == 0) ? formater.getCurrency(CatalogCalculator.getPrice(rsPrices.getDouble("price"), contactId, Integer.parseInt(((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId()), proxyEnabled)) : ""%></td>
          </tr>
        </table>
        <% } %>
        <div align="center"></div>
    </td>
  </tr>
  <tr> 
    <td valign="bottom" colspan="2" align="center"> 
        <table width="20%">
          <tr> 
            <td colspan="" width="47%"></td>
        </tr>
        <tr> 
            <td align="right" width="47%"><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp')" class="greybuumber = '99999' AND cpd.id = cpr.catalog_price_definition_id  AND vendor_id = " + request.getParameter("vendorId") + " AND cpa.cat_job_id = " + request.getParameter("catJobId") + " AND price_tier_id = " + request.getParameter("tierId");
ResultSet rsPrices = st1.executeQuery(query1);
%>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/continueover.gif', '/images/buttons/cancelbtover.gif','/images/buttons/cancelbtdown.gif','/images/buttons/continuedown.gif'); populateTitle('<%= (String)request.getAttribute("title")%>')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.catalog.CatalogControllerServlet">
<table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%">
  <tr> 
    <td colspan="2" align="center"> 
      <table width="98%">
        <tr><%=titleString%>
          <td class="body"><%=((rsCatPages.getString("description") != null) ? rsCatPages.getString("description"):"")%></td>
        </tr>
      </table>
    </td>
  </tr>
  <tr> 
    <td align="center" width="40%"> <%=((rsCatPages.getString("page_pic")==null)?"":rsCatPages.getString("page_pic"))%> 
    </td>
      <td class="catalogITEM" width="60%"> <%=((rsCatPages.getString("subdescription")==null)?"":rsCatPages.getString("subdescription"))%> 
        <% if (rsPrices.next() && rsPrices.getString("price") != null) {
        int contactId = -1;
        try {
           contactId = Integer.parseInt((String)session.getAttribute("contactId")); 
        } catch (Exception ex) {}
		boolean proxyEnabled = false;
		try {
           ProxyOrderObject poo = (ProxyOrderObject)session.getAttribute("ProxyOrderObject");
           proxyEnabled = poo.isProxyEnabled();
        } catch (Exception ex) {} %>  
        <table cellpadding="0" cellspacing="0">
          <tr> 
            <td valign="top" class="catalogLABEL"><%=(rsPrices.getInt("rfq") == 0) ? formater.getCurrency(CatalogCalculator.getPrice(rsPrices.getDouble("price"), contactId, Integer.parseInt(((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId()), proxyEnabled)) : ""%></td>
          </tr>
        </table>
        <% } %>
        <div align="center"></div>
    </td>
  </tr>
  <tr> 
    <td valign="bottom" colspan="2" align="center"> 
        <table width="20%">
          <tr> 
            <td colspan="" width="47%"></td>
        </tr>
        <tr> 
            <td align="right" width="47%"><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp')" class="greybutton">Cancel</a></td>
            <td width="0%">&nbsp;</td>
            <td align="left" width="53%"><a href="javascript:document.forms[0].submit()" class="greybutton">Continue</a></td>
        </tr>
        <tr> 
          <td colspan="3">&nbsp;</td>
        </tr>
      </table>
    </td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td valign="bottom" colspan="2"> 
      <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include>
    </td>
  </tr>
</table>
<input type="hidden" name="vendorId" value="<%=request.getParameter("vendorId")%>">
<input type="hidden" name="currentCatalogPage" value="<%=request.getAttribute("currentCatalogPage")%>">
<input type="hidden" name="catJobId" value="<%=request.getParameter("catJobId")%>">
<input type="hidden" name="offeringId" value="<%=request.getParameter("offeringId")%>">
<input type="hidden" name="tierId" value="<%=request.getParameter("tierId")%>">
<%
rsCatPages.close();
rsPrices.close();
st0.close();
st1.close();
conn.close();
%></form>
</body>
</html>