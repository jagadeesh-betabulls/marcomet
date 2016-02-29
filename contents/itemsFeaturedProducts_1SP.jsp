<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*, java.util.*, java.io.*, com.marcomet.tools.*, com.marcomet.users.security.*, com.marcomet.users.admin.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<label>Welcome...</label>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<%
    SiteHostSettings shs = (SiteHostSettings) session.getAttribute("siteHostSettings");

    Connection conn = DBConnect.getConnection();
    Statement st = conn.createStatement();
    Statement st1 = conn.createStatement();

    boolean editor = ((((RoleResolver) session.getAttribute("roles")).roleCheck("editor")) && request.getParameter("editor") == null);
    boolean showInfo = ((session.getAttribute("proxyId") != null || (((RoleResolver) session.getAttribute("roles")).roleCheck("editor"))) ? true : false);

    String siteHostRoot = ((request.getParameter("siteHostRoot") == null) ? (String) session.getAttribute("siteHostRoot") : request.getParameter("siteHostRoot"));
    String sitehostId = ((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostId();
    String ShowInactive = ((request.getParameter("ShowInactive") == null || request.getParameter("ShowInactive").equals("")) ? "" : "&ShowInactive=" + request.getParameter("ShowInactive"));
    String pageName = ((request.getParameter("pageName") == null || request.getParameter("pageName").equals("")) ? " AND pagename='home' " : " AND pagename= '" + request.getParameter("pageName") + "' ");
    String ShowRelease = ((request.getParameter("ShowRelease") == null || request.getParameter("ShowRelease").equals("")) ? "" : "&ShowRelease=" + request.getParameter("ShowRelease"));
%>
<html>
  <head>
    <title>Featured Products Page</title>
    <link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
    <link rel="stylesheet" href="<%=siteHostRoot%>/styles/vendor_styles.css" type="text/css">
    <script language="JavaScript" src="/javascripts/mainlib.js"></script>
    <link rel="stylesheet" href="/styles/misc_styles.css" type="text/css">
  </head>
  <body bgcolor="white">
    <%
    if (editor) {
    %>
    <a href='javascript:pop("/popups/QuickChangeAddFeaturedProduct.jsp?actionId=1&title=Add%20Product",700,150)' class="greybutton"> + Add Product to List </a>
    <a href='javascript:pop("/popups/ViewHistoryFeaturedProduct.jsp",700,150)' class="greybutton"> View History </a>
    <br>
    <%    }

    //String sql = ((prodLineId.equals("")) ? "SELECT fp.* FROM featuredproducts fp, pages p, site_hosts sh WHERE sh.id= " + siteHostId + " AND sh.company_id=pl.company_id AND pl.id = p.prod_line_id " + ShowRelease + ShowInactive + ShowBrand + " GROUP BY pl.id ORDER BY pl.id" : "SELECT * FROM product_lines where  id=" + prodLineId);
    //String sql = "SELECT fp.* FROM featured_products fp, pages p WHERE fp.status_id=2 AND fp.page_id=p.id AND fp.sitehost_id=" + siteHostId + " ORDER BY fp.sequence";

    String sql = "SELECT '' as 'sale_title','' as 'sale_desc','text' as type,fp.target 'target',demo_url as backorder_notes,p.company_id, demo_url as  root_prod_code,demo_url as  variant_code,demo_url as  brand_standard,demo_url as priceper, fp.sequence, print_file_url as orderlink,p.id,p.title prod_name,demo_url as  product_features,demo_url as  prod_code,p.small_picurl,p.body summary FROM featured_products fp, pages p WHERE fp.status_id=2 AND fp.page_id=p.id and sitehost_id=" + sitehostId + pageName + "  group by p.id UNION SELECT vp.title 'sale_title',vp.description 'sale_desc','prod' as type, fp.target 'target', p.backorder_notes,p.company_id,p.root_prod_code,p.variant_code, lbs.presentation_language brand_standard,round(min(pp.price/pp.quantity),2) priceper,fp.sequence,p.id as orderlink,p.id,p.prod_name,p.product_features,p.prod_code,p.small_picurl, p.detailed_description summary FROM lu_brand_std_cat lbs,featured_products fp,products p left join v_promo_prods vp on p.id=vp.prod_id and vp.start_date<=now() and vp.end_date>=now() left join product_prices pp on pp.prod_price_code=p.prod_price_code where fp.status_id=2 and fp.product_id=p.id and sitehost_id=" + sitehostId + pageName + " and lbs.id=p.brand_std_cat group by p.id ORDER BY sequence";
    ResultSet rsProds = st.executeQuery(sql);
    int x = -1;
    while (rsProds.next()) {
      x++;
      String summary = ((rsProds.getString("summary") != null) ? "<span class='body'>" + rsProds.getString("summary") + "</span>" : "");
      String prodName = "<span class='catalogLABEL'>" + rsProds.getString("prod_name") + ((rsProds.getString("prod_code").equals("")) ? "" : "<br />" + rsProds.getString("prod_code")) + "</span><br />";

      if (rsProds.getString("small_picurl") == null || (rsProds.getString("small_picurl").equals(""))) {
        //
      } else {
    %>
    <table border=1 cellpadding=5 cellspacing=0 width=90% align="center">
      <tr style='display:visible'>
        <td valign="top" colspan='2' class="menuLINKText" height="30">
          <div align="left" >
            <strong>&nbsp;&nbsp;</strong>
          </div>
        </td>
      </tr>
      <tr style="displya:visible">
        <td valign="top" width=3%>
          <%
            //String sql1 = "SELECT '' as 'sale_title','' as 'sale_desc','text' as type,fp.target 'target',demo_url as backorder_notes,p.company_id, demo_url as  root_prod_code,demo_url as  variant_code,demo_url as  brand_standard,demo_url as priceper, fp.sequence, print_file_url as orderlink,p.id,p.title prod_name,demo_url as  product_features,demo_url as  prod_code,p.full_picurl,p.body summary FROM featured_products fp, pages p WHERE fp.status_id=2 AND fp.page_id=p.id group by p.id UNION SELECT vp.title 'sale_title',vp.description 'sale_desc','prod' as type, fp.target 'target', p.backorder_notes,p.company_id,p.root_prod_code,p.variant_code, lbs.presentation_language brand_standard,round(min(pp.price/pp.quantity),2) priceper,fp.sequence,p.id as orderlink,p.id,p.prod_name,p.product_features,p.prod_code,p.small_picurl, p.detailed_description summary FROM lu_brand_std_cat lbs,featured_products fp,products p left join v_promo_prods vp on p.id=vp.prod_id and vp.start_date<=now() and vp.end_date>=now() left join product_prices pp on pp.prod_price_code=p.prod_price_code where fp.status_id=2 and fp.product_id=p.id and lbs.id=p.brand_std_cat group by p.id ORDER BY sequence";
            //ResultSet rsProds1 = st1.executeQuery(sql1);
            //rsProds1.absolute(x);
%>
          <%--<a href="javascript:pop('<%=((rsProds1.getString("full_picurl") == null || rsProds1.getString("full_picurl").equals("")) ? "" : "" + siteHostRoot + "/fileuploads/product_images/" + str.replaceSubstring(rsProds1.getString("full_picurl"), " ", "%20"))%>','800','600')" >--%>
          <a href="" >
            <%=((rsProds.getString("small_picurl") == null || rsProds.getString("small_picurl").equals("")) ? "" : "<img src='" + siteHostRoot + "/fileuploads/product_images/" + str.replaceSubstring(str.replaceSubstring(rsProds.getString("small_picurl"), ".jpg", "_TH.jpg"), " ", "%20") + "' border=0>")%>
          </a>
        </td>
        <td valign="top" width="73%" align="left">
          <table width=100% cellpadding=0 cellspacing=0 border=0>
            <%    if (editor) {
            %>
            <tr>
              <td align=right>
                <a href='javascript:pop("/popups/QuickChangeAddFeaturedProduct.jsp?actionId=2&title=Replace%20Product&primaryKeyValue=<%=rsProds.getString("id")%>",700,150)' class=greybutton> REPLACE PRODUCT </a>
                <a href='javascript:pop("/popups/QuickChangeReorderFeaturedProduct.jsp?columnName=sequence&actionId=4&lastSequence=<%=rsProds.getString("sequence")%>&primaryKeyValue=<%=rsProds.getString("id")%>",700,150)' class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
                <a href='javascript:pop("/popups/QuickChangeReorderFeaturedProduct.jsp?columnName=status_id&actionId=3&valueFieldVal=9&primaryKeyValue=<%=rsProds.getString("id")%>",700,150)' class=greybutton> REMOVE PRODUCT </a>
              </td>
            </tr>
            <%    }
            %>
            <tr>
              <td>
                <%     if (showInfo) {
                %>
                <img src='/images/info.gif'>
                <%      }
                %>
                <span align='left' class="catalogLABEL">
                  <%     if (editor) {
                  %>
                  <a href=''>&raquo;</a>&nbsp;
                  <%      }
                  %>
                  <%=prodName%>
                  <br>
                  <%
            if (rsProds.getString("small_picurl") == null || (rsProds.getString("small_picurl").equals(""))) {
            } else {
                  %>
                  <%= summary%>
                  <%
            }
                  %>
                </span>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
    <%    }
    }
    %>
    <div align="center">
      <font size="1">
        Need help? We are here 9am-5pm, M-F, EST. Marketing Specialists<b>:</b> email <a href="mailto:marketingsvcs@marcomet.com"><u>marketingsvcs@marcomet.com</u></a> or
        leave a Voice Message Alert: at 1-888-777-9832, option 2.<br>
        To order by phone call a Customer Service Representative at 1-888-777-9832,
        option 3.<br>
        Technical Support?
        <a href="mailto:techsupport@marcomet.com"><u>techsupport@marcomet.com</u></a> or
        1-888-777-9832 option 4. Comments? Please email us <a href="mailto:comments@marcomet.com"><u>comments@marcomet.com</u></a>
      </font>
    </div>
  </body>
</html>
<%
    st.close();
    st1.close();
    conn.close();
%>