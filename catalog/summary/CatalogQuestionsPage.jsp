<%@ page import="java.sql.*, com.marcomet.catalog.*,com.marcomet.environment.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<html>
<head>
  <title>Catalog Wizard</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<script>
function makeSelection(x, y) {
	document.forms[0].coordinates.value=x + "," + y;
	document.forms[0].submit();
}
</script>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/continueover.gif', '/images/buttons/cancelbtover.gif');populateTitle('<%= (String)request.getAttribute("title")%>')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.catalog.CatalogControllerServlet"><%
	Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
   String contactId = "0";
   try {
     contactId = (String)session.getAttribute("contactId");
	 if (contactId == null) contactId = "0"; 
   } catch (Exception ex) {
     contactId = "0";
   }
String titleString="";
boolean useRecord = false;
ResultSet rsDescription = st.executeQuery("SELECT description,title,use_title_flag FROM catalog_pages WHERE cat_job_id = " + request.getParameter("catJobId") + " AND page = " + request.getAttribute("currentCatalogPage"));
if (rsDescription.next()){
	titleString=((rsDescription.getString("use_title_flag") != null && rsDescription.getString("use_title_flag").equals("1"))?"<td class='title'>"+rsDescription.getString("title")+"</td></tr>":"");
	useRecord=true;
}%><table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%"><%
   boolean proxyEnabled = false;
   try {
      ProxyOrderObject poo = (ProxyOrderObject)session.getAttribute("ProxyOrderObject");
      proxyEnabled = poo.isProxyEnabled();
   } catch (Exception ex) {}
   
   if (useRecord && (rsDescription.getString("description") != null || !titleString.equals(""))) { %>
  <tr>
    <td align="center">
      <table width="98%">
        <tr><!--CARL--><%=titleString%><!--END CARL-->
          <%=((rsDescription.getString("description")==null)?"":"<tr><td class='body' valign='top'>"+rsDescription.getString("description")+"<br><br></td></tr>")%>
      </table>
    </td>
  </tr><%
  } %>
  <tr>
    <td valign="top" align="center">
        <hr color="red" width="98%" size="1">
        <br><table width="98%">
          <%
   ShoppingCart shoppingCart = (ShoppingCart)request.getSession().getAttribute("shoppingCart");
   String pageNumber = (String)request.getAttribute("currentCatalogPage");
   int tabIndex = 1;
   String sql = "SELECT cs.id, spec_id, ls.value AS spec_title, label, field_type, reset_value, include_pic_url FROM catalog_specs cs, lu_specs ls WHERE cat_job_id = " + request.getParameter("catJobId") + " AND page = " + pageNumber + " AND ls.id = cs.spec_id AND axis = 724 ORDER BY cs.sequence";
   ResultSet rsQuestions = st.executeQuery(sql);
   while (rsQuestions.next()) {
      int fieldType = rsQuestions.getInt("field_type");
      int catSpecId = rsQuestions.getInt("id");
      int specId = rsQuestions.getInt("spec_id");
	  String existingSpecValue = "";
	  JobSpecObject jso = (JobSpecObject)shoppingCart.getJobSpec(specId);
	  if (jso != null && rsQuestions.getInt("reset_value") == 0)
	  	existingSpecValue = (String)jso.getValue();
%>
          <tr> 
            <td class="catalogITEM" valign="top" align="left" width="45%"><%=((rsQuestions.getString("label") != null)?rsQuestions.getString("label"):rsQuestions.getString("spec_title"))%></td>
            <td> 
              <%
      if (fieldType == 716) { //Text
%>
              <input tabindex="<%=tabIndex++%>" type="text" size="40" name="^<%=specId%>^<%=catSpecId%>" value="<%=existingSpecValue%>">
              <%
      } else if (fieldType == 1762) { //Text Input
%>
              <textarea tabindex="<%=tabIndex++%>" cols="65" rows="6" name="^<%=specId%>^<%=catSpecId%>"><%=existingSpecValue%></textarea>
              <%
      } else {
         sql = "SELECT distinct cr.value AS value, cp.pic_url, span FROM catalog_rows AS cr LEFT JOIN catalog_pic_urls AS cp ON (cr.cat_spec_id = cp.cat_spec_id AND cr.value = cp.value) WHERE cr.cat_job_id = " + request.getParameter("catJobId") + " and cr.catalog_page = " + pageNumber + " AND cr.cat_spec_id = " + catSpecId + " GROUP BY cr.value ORDER BY span";
         ResultSet rsQuestionChoices = st.executeQuery(sql);
         String questiontitle=rsQuestions.getString("spec_title");
         if (fieldType == 719) { //Radio Button
            String picUrl="";
            while (rsQuestionChoices.next()) {
               picUrl=((rsQuestionChoices.getString("pic_url")!=null && !rsQuestionChoices.getString("pic_url").equals(""))?"<image src="+rsQuestionChoices.getString("pic_url")+">":"");
               String tempValue = rsQuestionChoices.getString("value");
			   if (tempValue.equals(existingSpecValue)) { %>
              <input tabindex="<%=tabIndex++%>" type="radio" name="^<%=specId%>^<%=catSpecId%>" value="<%=tempValue%>" checked>
              <%= (picUrl == null || picUrl.equals("")) ? tempValue:picUrl %>
              <%
               } else { %>
              <input tabindex="<%=tabIndex++%>" type="radio" name="^<%=specId%>^<%=catSpecId%>" value="<%=tempValue%>">
              <%= (picUrl == null || picUrl.equals("")) ? tempValue:picUrl %>
              <%
               }
            }
         } else if (fieldType == 717) { // Menu
%>
              <select tabindex="<%=tabIndex++%>" name="^<%=specId%>^<%=catSpecId%>">
                <%
            while (rsQuestionChoices.next()) {
              double specPrice = 0;
              String query3 = "SELECT price FROM catalog_prices cp, catalog_price_definitions cpd WHERE price != 0 AND cpd.id = cp.catalog_price_definition_id AND vendor_id = " + request.getParameter("vendorId") + " AND cat_job_id = " + request.getParameter("catJobId") + " AND row_number = " + rsQuestionChoices.getString("span") + " AND price_tier_id = " + request.getParameter("tierId");
              ResultSet rs3 = st2.executeQuery(query3);
              if (rs3.next()) {
                 specPrice = rs3.getDouble("price");
              }
               String tempValue = rsQuestionChoices.getString("value");
			   if (tempValue.equals(existingSpecValue)) { %>
            <option value="<%= rsQuestionChoices.getString("value")%>" selected><%=tempValue%><%=(specPrice == 0) ? "":"  (+" + formatter.getCurrency(CatalogCalculator.getPrice(specPrice, Integer.parseInt(contactId), Integer.parseInt(((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId()), proxyEnabled)) + ")"%></option><%
              } else { %>
            <option value="<%= rsQuestionChoices.getString("value")%>"><%=tempValue%><%=(specPrice == 0) ? "":"  (+" + formatter.getCurrency(CatalogCalculator.getPrice(specPrice, Integer.parseInt(contactId), Integer.parseInt(((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId()), proxyEnabled)) + ")"%></option><%
              }
            }
%>
              </select>
              <%
         } else if (fieldType == 718) { // Check Box %>
              <input type="checkbox" name="^<%=rsQuestions.getString("spec_id")%>^<%=catSpecId%>" value="Yes">
              <%
         }
      }
%>
            </td>
          </tr>
          <%
  }
%>
        </table>
    <hr color="red" width="98%" size="1">
      </td>
  </tr>
  <tr>
    <td>
      <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%">
        <tr>
          <td></td>
        </tr>
        <tr>
          <td align="center">
             <taglib:PricingGridTag catJobId="<%=request.getParameter(\"catJobId\")%>" contactId="<%=contactId%>" vendorId="<%=request.getParameter(\"vendorId\")%>" tierId="<%=request.getParameter(\"tierId\")%>" siteHostId="<%=((SiteHostSettings)session.getAttribute(\"siteHostSettings\")).getSiteHostId()%>" catalogPage="<%=pageNumber%>" proxyEnabled="<%=proxyEnabled%>"/>
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td valign="top" align="center" colspan="2">
      <table width="20%">
        <tr>
          <td colspan="3">&nbsp;</td>
        </tr><%
        if (gridExists.equals("0")) { %>
        <tr>
          <td align="right" width="48%"><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp')" class="greybutton">Cancel</a></td>
          <td width="4%">&nbsp;</td>
          <td align="left" width="48%"><a href="javascript:document.forms[0].submit()" class="greybutton">Continue</a></td>
        </tr><%
		} else { %>
        <tr>
          <td align="center" colspan="3"><a href="javascript:parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp')" class="greybutton">Cancel</a></td>
        </tr><%
		} %>
        <tr>
          <td colspan="3">&nbsp;</td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td valign="bottom" colspan="10">
      <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include>
    </td>
  </tr>
</table>
<input type="hidden" name="coordinates" value="">
<input type="hidden" name="vendorId" value="<%=request.getParameter("vendorId")%>">
<input type="hidden" name="currentCatalogPage" value="<%=request.getAttribute("currentCatalogPage")%>">
<input type="hidden" name="catJobId" value="<%=request.getParameter("catJobId")%>">
<input type="hidden" name="offeringId" value="<%=request.getParameter("offeringId")%>">
<input type="hidden" name="tierId" value="<%=request.getParameter("tierId")%>">
</form>
</body>
</html><%conn.close();%>