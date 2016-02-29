<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.users.security.*;" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/styles/misc_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<%
    boolean editor = ((((RoleResolver) session.getAttribute("roles")).roleCheck("editor")) && request.getParameter("editor") == null);
    if (editor) {
%>
<div align="left" width="98%">
  <%
  if (request.getParameter("submitted") != null && request.getParameter("submitted").equals("true")) {
  %>
  <a href='javascript:pop("/popups/QuickChangeAddFeaturedProduct.jsp?actionId=1&title=Add%20Product",700,150)' class="greybutton"> + Add Product to List </a>
  <a href='javascript:pop("/popups/ViewFeaturedProductHistory.jsp",1000,400)' class="greybutton"> View History </a>
  <br>
  <%  } else {
  %>
  <%--<a class="greybutton" href="/contents/itemsFeaturedProducts.jsp"> Edit Featured Products </a>--%>
  <%--<input type="button" value="Edit Featured Products" onClick="submit()">--%>
  <a href="/includes/editFeaturedProducts.jsp?submitted=true" target="_self" class="greybutton"> Edit Featured Products </a>
</div>
<br />
<%    }
    }
%>
<table width="98%" border="0" cellspacing="0" cellpadding="0">
  <%
    String ShowInactive = ((request.getParameter("ShowInactive") == null || request.getParameter("ShowInactive").equals("")) ? "" : "&ShowInactive=" + request.getParameter("ShowInactive"));
    String pageName = ((request.getParameter("pageName") == null || request.getParameter("pageName").equals("")) ? " AND pagename='home' " : " AND pagename= '" + request.getParameter("pageName") + "' ");
    String ShowRelease = ((request.getParameter("ShowRelease") == null || request.getParameter("ShowRelease").equals("")) ? "" : "&ShowRelease=" + request.getParameter("ShowRelease"));
    String sitehostId = ((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostId();
    String sql = "SELECT  '' as 'sale_title','' as 'sale_desc','text' as type,fp.target 'target',demo_url as backorder_notes,p.company_id, demo_url as  root_prod_code,demo_url as  variant_code,demo_url as  brand_standard,demo_url as priceper, fp.sequence, print_file_url as orderlink,p.id,p.title prod_name,demo_url as  product_features,demo_url as  prod_code,p.small_picurl,p.body summary FROM  featured_products fp,pages p where fp.status_id=2 and fp.page_id=p.id and sitehost_id=" + sitehostId + pageName + "  group by p.id UNION SELECT vp.title 'sale_title',vp.description 'sale_desc','prod' as type, fp.target 'target', p.backorder_notes,p.company_id,p.root_prod_code,p.variant_code, lbs.presentation_language brand_standard,round(min(pp.price/pp.quantity),2) priceper,fp.sequence,p.id as orderlink,p.id,p.prod_name,p.product_features,p.prod_code,p.small_picurl, p.detailed_description summary FROM lu_brand_std_cat lbs,featured_products fp,products p left join v_promo_prods vp on p.id=vp.prod_id and vp.start_date<=now() and vp.end_date>=now() left join product_prices pp on pp.prod_price_code=p.prod_price_code where fp.status_id=2 and fp.product_id=p.id and sitehost_id=" + sitehostId + pageName + " and lbs.id=p.brand_std_cat group by p.id  ORDER BY sequence";
    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
    ResultSet rsProds = st.executeQuery(sql);
    int x = 0;
    int y = 0;
    while (rsProds.next()) {
      x++;
      String orderLink = "";
      String target = ((rsProds.getString("target") == null) ? "" : rsProds.getString("target"));
      String smallPicURL = "";
      String order = "";
      if (rsProds.getString("type").equals("prod")) {
        orderLink = "\"/contents/logos.jsp?pcompanyId=" + ((rsProds.getString("company_id") != null) ? rsProds.getString("company_id") : "") + ShowRelease + ShowInactive + "&rootProdCode=" + ((rsProds.getString("root_prod_code") != null) ? rsProds.getString("root_prod_code") : "") + "&variant=" + ((rsProds.getString("variant_code") != null) ? rsProds.getString("variant_code") : "") + "\"";
        smallPicURL = ((rsProds.getString("small_picurl") == null || rsProds.getString("small_picurl").equals("")) ? "&nbsp;" : "<a href=" + orderLink + "><img src='" + (String) session.getAttribute("siteHostRoot") + "/fileuploads/product_images/" + str.replaceSubstring(str.replaceSubstring(rsProds.getString("small_picurl"), ".jpg", "_TH.jpg"), " ", "%20") + "' border=0 style='border-color: gray' align='" + ((x == 1 || x == 2 || x == 5 || x == 6) ? "left" : "right") + "'></a>");
        order = ((orderLink.equals("")) ? "" : "<br><br><a href=" + orderLink + " class='menuLINK'>ORDER&nbsp;INFO&nbsp;&raquo;</a>");
      } else {
        orderLink = ((rsProds.getString("orderlink") == null || rsProds.getString("orderlink").equals("")) ? "" : "\"" + rsProds.getString("orderlink") + "\"");
        smallPicURL = ((rsProds.getString("small_picurl") == null || rsProds.getString("small_picurl").equals("")) ? "" : "<a href=" + orderLink + " target='mainFr'><img src='" + (String) session.getAttribute("siteHostRoot") + "/fileuploads/product_images/" + str.replaceSubstring(str.replaceSubstring(rsProds.getString("small_picurl"), ".jpg", "_TH.jpg"), " ", "%20") + "' border=0 style='border-color: gray' align='" + ((x == 1 || x == 2 || x == 5 || x == 6) ? "left" : "right") + "'></a>");
        order = ((orderLink.equals("")) ? "" : "<br><br><a href=" + orderLink + " class='menuLINK' target='" + target + "'>ORDER&nbsp;INFO&nbsp;&raquo;</a>");
      }
      String summary = ((rsProds.getString("summary") != null) ? "<span class='body'>" + rsProds.getString("summary") + "</span>" : "");
      //String prodName = "<span class='catalogLABEL'>" + rsProds.getString("prod_name") + ((rsProds.getString("prod_code").equals("")) ? "" : "<br />" + rsProds.getString("prod_code")) + "</span><br />";
      String prodName = "<span class='catalogLABEL'>" + rsProds.getString("prod_name") + ((rsProds.getString("prod_code").equals("")) ? "" : "<br />" + rsProds.getString("prod_code")) + "</span>";
      String brandStandard = ((rsProds.getString("brand_standard") != null) ? "<span class='subtitle'>" + rsProds.getString("brand_standard") + "</span><br />" : "");
      String features = "";
      //((rsProds.getString("product_features")!=null)?"<span class='subtitle'>"+rsProds.getString("product_features")+"</span><br />":"");
      String pricePer = ((rsProds.getString("priceper") == null) ? "&nbsp;" : "<span class='catalogPRICE'>As low as $" + rsProds.getString("priceper") + " each.</span>");
      if (x == 1) {
  %>
  <tr>
    <td width="48%" class='borderAboveLeft<%=((y == 0) ? "Intro" : "")%>'>
      <%if (y != 0) {
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right" width="98%">
            <%if (request.getParameter("submitted") != null && request.getParameter("submitted").equals("true")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeAddFeaturedProduct.jsp?actionId=2&title=Replace%20Product&primaryKeyValue=<%=rsProds.getString("id")%>",700,150)' class=greybutton> REPLACE PRODUCT </a>
            <a href='javascript:pop("/popups/QuickChangeReorderFeaturedProduct.jsp?primaryKeyValue=<%=rsProds.getString("id")%>&columnName=sequence&actionId=4&title=Set%20Order&lastSequence=<%=rsProds.getString("sequence")%>",700,150)' class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
            <a href='javascript:pop("/popups/QuickChangeReorderFeaturedProduct.jsp?primaryKeyValue=<%=rsProds.getString("id")%>&columnName=status_id&actionId=3&title=Remove%20Product&valueFieldVal=9",700,150)' class=greybutton> REMOVE PRODUCT </a>
            <br>
            <%}
            %>
          </td>
        </tr>
      </table>
      <%}
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="98%" valign="top">
            <%if (editor && rsProds.getString("type").equals("text")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Title&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;
            <%}
            %>
            <%=prodName%><%=smallPicURL%><%=brandStandard%><%=features%>
            <%if (editor && rsProds.getString("type").equals("text")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Text&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=body&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;
            <%}
            %>
            <%=summary%><%=((rsProds.getString("sale_title") != null && !rsProds.getString("sale_title").equals("")) ? "<div class='saleLINK'><span class='saleLINKTitle'>" + rsProds.getString("sale_title") + "</span><br>" + rsProds.getString("sale_desc") + order + "<br /></div>" : order)%>
          </td>
        </tr>
      </table>
    </td>
    <%
      y++;
    } else if (x == 2) {
    %>
    <td width="4%" >&nbsp;</td>
    <td width="48%"  class='borderAboveRight'>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="98%" valign="top" align="right">
            <%if (request.getParameter("submitted") != null && request.getParameter("submitted").equals("true")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeAddFeaturedProduct.jsp?actionId=2&title=Replace%20Product&primaryKeyValue=<%=rsProds.getString("id")%>",700,150)' class=greybutton> REPLACE PRODUCT </a>
            <a href='javascript:pop("/popups/QuickChangeReorderFeaturedProduct.jsp?primaryKeyValue=<%=rsProds.getString("id")%>&columnName=sequence&actionId=4&title=Set%20Order&lastSequence=<%=rsProds.getString("sequence")%>",700,150)' class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
            <a href='javascript:pop("/popups/QuickChangeReorderFeaturedProduct.jsp?primaryKeyValue=<%=rsProds.getString("id")%>&columnName=status_id&actionId=3&title=Remove%20Product&valueFieldVal=9",700,150)' class=greybutton> REMOVE PRODUCT </a>
            <br>
            <%}
            %>
          </td>
          <td width="1%" rowspan="2" valign="top">
            <img name="" src="" width="8px" height="1" alt="" />
          </td>
          <td rowspan="2" width="1%"  valign="top"></td>
        </tr>
      </table>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="98%" valign="top">
            <%if (editor && rsProds.getString("type").equals("text")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Title&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;
            <%}
            %>
            <%=prodName%><%=smallPicURL%><%=brandStandard%><%=features%>
            <%if (editor && rsProds.getString("type").equals("text")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Text&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=body&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;
            <%}
            %>
            <%=summary%><%=((rsProds.getString("sale_title") != null && !rsProds.getString("sale_title").equals("")) ? "<div class='saleLINK'><span class='saleLINKTitle'>" + rsProds.getString("sale_title") + "</span><br>" + rsProds.getString("sale_desc") + order + "<br /></div>" : order)%>
          </td>
          <td width="1%" rowspan="2" valign="top">
            <img name="" src="" width="8px" height="1" alt="" />
          </td>
          <td rowspan="2" width="1%"  valign="top"></td>
        </tr>
      </table>
    </td>
  </tr>
  <%
    } else if (x == 3) {
  %>
  <tr>
    <td width="48%"  class='borderAboveRight'>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td rowspan="2" width="1%"  valign="top" ></td>
          <td width="1%" rowspan="2" valign="top">
            <img name="" src="" width="8px" height="1" alt="" />
          </td>
          <td width="98%" valign="top" align="right">
            <%if (request.getParameter("submitted") != null && request.getParameter("submitted").equals("true")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeAddFeaturedProduct.jsp?actionId=2&title=Replace%20Product&primaryKeyValue=<%=rsProds.getString("id")%>",700,150)' class=greybutton> REPLACE PRODUCT </a>
            <a href='javascript:pop("/popups/QuickChangeReorderFeaturedProduct.jsp?primaryKeyValue=<%=rsProds.getString("id")%>&columnName=sequence&actionId=4&title=Set%20Order&lastSequence=<%=rsProds.getString("sequence")%>",700,150)' class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
            <a href='javascript:pop("/popups/QuickChangeReorderFeaturedProduct.jsp?primaryKeyValue=<%=rsProds.getString("id")%>&columnName=status_id&actionId=3&title=Remove%20Product&valueFieldVal=9",700,150)' class=greybutton> REMOVE PRODUCT </a>
            <br>
            <%}
            %>
          </td>
        </tr>
      </table>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td rowspan="2" width="1%"  valign="top" ></td>
          <td width="1%" rowspan="2" valign="top">
            <img name="" src="" width="8px" height="1" alt="" />
          </td>
          <td width="98%" valign="top">
            <%if (editor && rsProds.getString("type").equals("text")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Title&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;
            <%}
            %>
            <%=prodName%><%=smallPicURL%><%=brandStandard%><%=features%>
            <%if (editor && rsProds.getString("type").equals("text")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Text&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=body&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;
            <%}
            %>
            <%=summary%><%=((rsProds.getString("sale_title") != null && !rsProds.getString("sale_title").equals("")) ? "<div class='saleLINK'><span class='saleLINKTitle'>" + rsProds.getString("sale_title") + "</span><br>" + rsProds.getString("sale_desc") + order + "<br /></div>" : order)%>
          </td>
        </tr>
      </table>
    </td>
    <%
    } else if (x == 4) {
    %>
    <td width="4%" >&nbsp;</td>
    <td width="48%" class='borderAboveLeft'>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td rowspan="2" width="1%" valign="top"></td>
          <td width="1%" rowspan="2" valign="top">
            <img name="" src="" width="8px" height="1" alt="" />
          </td>
          <td width="98%" valign="top" align="right">
            <%if (request.getParameter("submitted") != null && request.getParameter("submitted").equals("true")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeAddFeaturedProduct.jsp?actionId=2&title=Replace%20Product&primaryKeyValue=<%=rsProds.getString("id")%>",700,150)' class=greybutton> REPLACE PRODUCT </a>
            <a href='javascript:pop("/popups/QuickChangeReorderFeaturedProduct.jsp?primaryKeyValue=<%=rsProds.getString("id")%>&columnName=sequence&actionId=4&title=Set%20Order&lastSequence=<%=rsProds.getString("sequence")%>",700,150)' class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
            <a href='javascript:pop("/popups/QuickChangeReorderFeaturedProduct.jsp?primaryKeyValue=<%=rsProds.getString("id")%>&columnName=status_id&actionId=3&title=Remove%20Product&valueFieldVal=9",700,150)' class=greybutton> REMOVE PRODUCT </a>
            <br>
            <%}
            %>
          </td>
        </tr>
      </table>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td rowspan="2" width="1%" valign="top"></td>
          <td width="1%" rowspan="2" valign="top">
            <img name="" src="" width="8px" height="1" alt="" />
          </td>
          <td width="98%" valign="top">
            <%if (editor && rsProds.getString("type").equals("text")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Title&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;
            <%}
            %>
            <%=prodName%><%=smallPicURL%><%=brandStandard%><%=features%>
            <%if (editor && rsProds.getString("type").equals("text")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Text&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=body&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;
            <%}
            %>
            <%=summary%><%=((rsProds.getString("sale_title") != null && !rsProds.getString("sale_title").equals("")) ? "<div class='saleLINK'><span class='saleLinkTitle'>" + rsProds.getString("sale_title") + "</span><br>" + rsProds.getString("sale_desc") + order + "<br /></div>" : order)%>
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <%
        x = 0;
      }
    }
    if (x == 1 || x == 3) {
  %>
  <td width="4%">&nbsp;</td>
  <td width="48%" class='borderAboveLeft'>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
      <tr>
        <td rowspan="2" width="1%">&nbsp;</td>
        <td width="1%" rowspan="2" valign="top">
          <img name="" src="" width="8px" height="1" alt="" />
        </td>
        <td width="98%" valign="top">&nbsp;</td>
      </tr>
      <tr>
        <td valign="bottom">&nbsp;</td>
      </tr>
    </table>
  </td>
  </tr>
  <%    }
    rsProds.close();
    st.close();
    conn.close();
  %>
</table>