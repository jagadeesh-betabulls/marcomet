<%@ page errorPage="/errors/ExceptionPage.jsp" %><%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.users.security.*;" %><%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %><%@ include file="/includes/SessionChecker.jsp" %><jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" /><jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" /><%    boolean editor = ((((RoleResolver) session.getAttribute("roles")).roleCheck("editor")) && request.getParameter("editor") == null);
    boolean editable = ((editor && request.getParameter("edit") != null && request.getParameter("edit").equals("true")) ? true : false);
%><%=((editable)?"<html><head>":"")%>
<link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/styles/misc_styles.css" type="text/css">
<link rel="stylesheet" href="/styles/modalbox.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script type="text/javascript" src="/javascripts/prototype1.js"></script>
<script type="text/javascript" src="/javascripts/scriptaculous1.js"></script>
<script type="text/javascript" src="/javascripts/modalbox1.js"></script>
<%=((editable)?"</head><body>":"")%>
<%
    String siteHostRoot = ((request.getParameter("siteHostRoot") == null) ? (String) session.getAttribute("siteHostRoot") : request.getParameter("siteHostRoot"));
    String ShowInactive = ((request.getParameter("ShowInactive") == null || request.getParameter("ShowInactive").equals("")) ? "" : "&ShowInactive=" + request.getParameter("ShowInactive"));
    String pageName = ((request.getParameter("pageName") == null || request.getParameter("pageName").equals("")) ? " AND pagename='home' " : " AND pagename= '" + request.getParameter("pageName") + "' ");
    String ShowRelease = ((request.getParameter("ShowRelease") == null || request.getParameter("ShowRelease").equals("")) ? "" : "&ShowRelease=" + request.getParameter("ShowRelease"));
    String sitehostId = ((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostId();

    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
    Statement st1 = conn.createStatement();
    Statement st2 = conn.createStatement();
    Statement st3 = conn.createStatement();

    if (editor) {
%>
<div align="left" width="98%">
  <%
  if (editable) {
    String activeFilter = ((request.getParameter("showAll") == null || !(request.getParameter("showAll").equals("true"))) ? " p.status_id=2 AND " : "");
    String sql = "SELECT p.id 'value', CONCAT(p.prod_code,':',left(p.prod_name,25),if(length(p.prod_name)>25,'...',''),' [',p.brand_code,'] '" + ((activeFilter.equals("")) ? ",'[',if(p.status_id=1,'Draft',if(p.status_id=2,'Active','On Hold')),']'" : "") + ") 'text' FROM products p left join site_hosts sh on p.company_id=sh.company_id WHERE " + activeFilter + " sh.id=" + sitehostId + " ORDER BY p.prod_code, p.brand_code";
  %>
  <div id="divAdd" style="background-color: #fffccc; border: 2px solid black; display: none;">
    &nbsp;&nbsp;&nbsp;&nbsp;
    <a href="#" target="_self" onclick="" class="menuLINK"> Show All </a>
    <br><br>
    &nbsp;&nbsp;&nbsp;&nbsp;
    <%--<formtaglib:SQLDropDownTag dropDownName="addNewValue" sql="<%= sql %>" />--%>
    <select id="addNewValue">
      <%
    ResultSet rs11 = st2.executeQuery(sql);
    while (rs11.next()) {
      %>
      <option value="<%= rs11.getString("value")%>"><%= rs11.getString("text")%>
      <%}
    rs11.close();
      %>
    </select>
    <br><br>
    &nbsp;&nbsp;&nbsp;&nbsp;
    <input type="button" value="Update" onClick="AjaxModalBox.submit({newValue: $('addNewValue').value})">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type="button" value="Cancel" onClick="AjaxModalBox.close()">
  </div>
  <div id="divHistory" style="background-color: #fffccc; border: 2px solid black; display: none;">
    <table border="1" cellpadding="5" cellspacing="0" align="center" width="100%">
      <tr>
        <td align="center" width="10%" class="menuLINKText">Date Of Change</td>
        <td align="center" width="10%" class="menuLINKText">Action</td>
        <td align="center" width="15%" class="menuLINKText">Product/Page</td>
        <td align="center" width="15%" class="menuLINKText">Made By</td>
      </tr>
      <%
    String query = "SELECT DISTINCT fp.modification_date 'date of change', lfp.id 'action id', lfp.value 'action', fp.last_sequence 'last sequence', fp.last_product_id 'last product id', prd.id 'product id', prd1.prod_name 'last product name', prd.prod_name 'product name', prd1.prod_code 'last product code', prd.prod_code 'product code', c.id 'contact id', c.firstname, c.lastname FROM featured_products fp left join products prd1 on fp.last_product_id=prd1.id, products prd, lu_featured_products_actions lfp, contacts c WHERE fp.sitehost_id=29 AND fp.pagename='home' AND fp.product_id=prd.id AND fp.last_action_id=lfp.id AND fp.mod_id=c.id order by fp.modification_date";
    ResultSet rs = st1.executeQuery(query);
    while (rs.next()) {
      %>
      <tr>
        <td valign="top" width="20%"><%=rs.getString("date of change")%></td>
        <%
        if (rs.getInt("action id") == 2) {
        %>
        <td valign="top" width="30%"><%=rs.getString("action")%> -- Last Product Id : #<%=rs.getString("last product id")%>, <%=rs.getString("last product name")%> - <%=rs.getString("last product code")%></td>
        <%} else if (rs.getInt("action id") == 4) {
        %>
        <td valign="top" width="30%"><%=rs.getString("action")%> -- Last Sequence : <%=rs.getString("last sequence")%></td>
        <%} else {
        %>
        <td valign="top" width="30%"><%=rs.getString("action")%></td>
        <%}
        %>
        <td valign="top" width="30%">#<%=rs.getString("product id")%>, <%=rs.getString("product name")%> - <%=rs.getString("product code")%></td>
        <td valign="top" width="20%">#<%=rs.getString("contact id")%>, <%=rs.getString("firstname")%> <%=rs.getString("lastname")%></td>
        <%    }
        %>
      </tr>
    </table>
  </div>
  <a href='#' target="_self" onclick="AjaxModalBox.open($('divAdd'), {title: 'Add New Product to the Grid', width: 500, method: 'post', params: {actionId: 1}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'})" class="greybutton"> + Add Product to List </a>
  <a href='#' target="_self" onclick="AjaxModalBox.open($('divHistory'), {title: 'View History', width: 1000, height: 300})" class="greybutton"> View History </a>
  <a href='<%=siteHostRoot%>/contents/SiteHostIndex.jsp' class="greybutton">Preview Page</a>
  <br>
  <%  } else {
  %>
  <a href="/includes/featuredProducts.jsp?edit=true" target="_self" class="greybutton"> Edit Featured Products </a>
</div>
<br />
<%    }
    }
%>
<table width="98%" border="0" cellspacing="0" cellpadding="0">
  <%
    String sql = "SELECT  '' as 'sale_title','' as 'sale_desc','text' as type,fp.target 'target',demo_url as backorder_notes,p.company_id, demo_url as  root_prod_code,demo_url as  variant_code,demo_url as  brand_standard,demo_url as priceper, fp.sequence, print_file_url as orderlink,p.id,p.title prod_name,demo_url as  product_features,demo_url as  prod_code,p.small_picurl,p.body summary FROM  featured_products fp,pages p  where fp.status_id=2 and fp.page_id=p.id and sitehost_id=" + sitehostId + pageName + "  group by p.id UNION SELECT vp.title 'sale_title',vp.description 'sale_desc','prod' as type, fp.target 'target', p.backorder_notes,p.company_id,p.root_prod_code,p.variant_code, lbs.presentation_language brand_standard,round(min(pp.price/pp.quantity),3) priceper,fp.sequence,p.id as orderlink,p.id,p.prod_name,p.product_features,p.prod_code,p.small_picurl, p.detailed_description summary FROM lu_brand_std_cat lbs,featured_products fp,products p left join v_promo_prods vp on p.id=vp.prod_id and vp.start_date<=now() and vp.end_date>=now() left join product_prices pp on pp.prod_price_code=p.prod_price_code where fp.status_id=2 and fp.product_id=p.id and sitehost_id=" + sitehostId + pageName + " and lbs.id=p.brand_std_cat group by p.id  ORDER BY sequence";
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
        order = ((orderLink.equals("")) ? "" : ((rsProds.getString("priceper") != null && !(rsProds.getString("priceper").equals(""))) ? "<div class='catalogLABEL' style='text-align: right;' >As low as $" + rsProds.getString("priceper") + "&nbsp;each</div>" : "") + "<br><br><a href=" + orderLink + " class='menuLINK' >ORDER&nbsp;INFO&nbsp;&raquo;</a>");
      } else {
        orderLink = ((rsProds.getString("orderlink") == null || rsProds.getString("orderlink").equals("")) ? "" : "\"" + rsProds.getString("orderlink") + "\"");
        smallPicURL = ((rsProds.getString("small_picurl") == null || rsProds.getString("small_picurl").equals("")) ? "" : "<a href=" + orderLink + " target='mainFr'><img src='" + (String) session.getAttribute("siteHostRoot") + "/fileuploads/product_images/" + str.replaceSubstring(str.replaceSubstring(rsProds.getString("small_picurl"), ".jpg", "_TH.jpg"), " ", "%20") + "' border=0 style='border-color: gray' align='" + ((x == 1 || x == 2 || x == 5 || x == 6) ? "left" : "right") + "'></a>");
        order = ((orderLink.equals("")) ? "" : ((rsProds.getString("priceper") != null && !(rsProds.getString("priceper").equals(""))) ? "<div class='catalogLABEL' style='text-align: right;' >As low as $" + rsProds.getString("priceper") + "&nbsp;each</div>" : "") + "<br><br><a href=" + orderLink + " class='menuLINK' target='" + target + "'>ORDER&nbsp;INFO&nbsp;&raquo;</a>");
      }
      String summary = ((rsProds.getString("summary") != null) ? "<span class='body'>" + rsProds.getString("summary") + "</span>" : "");
      String prodName = "<span class='catalogLABEL'>" + rsProds.getString("prod_name") + ((rsProds.getString("prod_code").equals("")) ? "" : "<br />" + rsProds.getString("prod_code")) + "</span><br />";
      String brandStandard = ((rsProds.getString("brand_standard") != null) ? "<span class='subtitle'>" + rsProds.getString("brand_standard") + "</span><br />" : "");
      String features = "";
      //((rsProds.getString("product_features")!=null)?"<span class='subtitle'>"+rsProds.getString("product_features")+"</span><br />":"");
      String pricePer = ((rsProds.getString("priceper") == null) ? "&nbsp;" : "<span class='catalogPRICE'>As low as $" + rsProds.getString("priceper") + "&nbsp;each.</span>");

      String activeFilter = ((request.getParameter("showAll") == null || !(request.getParameter("showAll").equals("true"))) ? " p.status_id=2 AND " : "");
      String sql1 = "SELECT p.id 'value', CONCAT(p.prod_code,':',left(p.prod_name,25),if(length(p.prod_name)>25,'...',''),' [',p.brand_code,'] '" + ((activeFilter.equals("")) ? ",'[',if(p.status_id=1,'Draft',if(p.status_id=2,'Active','On Hold')),']'" : "") + ") 'text' FROM products p left join site_hosts sh on p.company_id=sh.company_id WHERE " + activeFilter + " sh.id=" + sitehostId + " ORDER BY p.prod_code, p.brand_code";
  %>
  <div id="divReplace" style="background-color: #fffccc; border: 2px solid black; display: none;">
    &nbsp;&nbsp;&nbsp;&nbsp;
    <a href="#" target="_self" onclick="" class="menuLINK"> Show All </a>
    <br><br>
    &nbsp;&nbsp;&nbsp;&nbsp;
    <%--<formtaglib:SQLDropDownTag dropDownName="replaceNewValue" sql="<%= sql1 %>" />--%>
    <select id="replaceNewValue">
      <%
    ResultSet rs12 = st3.executeQuery(sql1);
    while (rs12.next()) {
      %>
      <option value="<%= rs12.getString("value")%>"><%= rs12.getString("text")%>
      <%}
    rs12.close();
      %>
    </select>
    <br><br>
    &nbsp;&nbsp;&nbsp;&nbsp;
    <input type="button" value="Update" onClick="AjaxModalBox.submit({newValue: $('replaceNewValue').value})">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type="button" value="Cancel" onClick="AjaxModalBox.close()">
  </div>
  <div id="divReorder" style="background-color: #fffccc; border: 2px solid black; display: none;">
    <br>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input id="newValue" name="newValue" value="" size="7">
    <br><br>
    &nbsp;&nbsp;&nbsp;&nbsp;
    <input type="button" value="Update" onClick="AjaxModalBox.submit({newValue: $('newValue').value})">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type="button" value="Cancel" onClick="AjaxModalBox.close()">
  </div>
  <div id="divRemove" style="background-color: #fffccc; border: 2px solid black; display: none;">
    <br>
    Are You Sure You Want To Remove This Product?
    <br><br>
    &nbsp;&nbsp;&nbsp;&nbsp;
    <input type="button" value="Update" onClick="AjaxModalBox.submit()">
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type="button" value="Cancel" onClick="AjaxModalBox.close()">
  </div>

  <%
    if (x == 1) {
  %>
  <tr>
    <td width="48%" class='borderAboveLeft<%=((y == 0) ? "Intro" : "")%>'>
      <%if (editable) {
      if (smallPicURL.equals("")) {
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right" width="98%">
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divReorder'), {title: 'Change Sequence', width: 200, height: 150, method: 'post', params: {newValue: '', page: 'true', primaryKeyValue: <%=rsProds.getString("id")%>, columnName: 'sequence', actionId: 4, lastSequence: <%=rsProds.getString("sequence")%>}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'}); document.getElementById('newValue').value=<%= rsProds.getString("sequence")%>; document.getElementById('newValue').select();" class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
            <br>
          </td>
        </tr>
      </table>
      <%} else {
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right" width="98%">
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divReplace'), {title: 'Replace Product', width: 500, method: 'post', params: {primaryKeyValue: <%=rsProds.getString("id")%>, actionId: 2}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'})" class="greybutton"> Replace Product </a>
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divReorder'), {title: 'Change Sequence', width: 200, height: 150, method: 'post', params: {newValue: '', primaryKeyValue: <%=rsProds.getString("id")%>, columnName: 'sequence', actionId: 4, lastSequence: <%=rsProds.getString("sequence")%>}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'}); document.getElementById('newValue').value=<%= rsProds.getString("sequence")%>; document.getElementById('newValue').select();" class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divRemove'), {title: 'Remove Product', width: 200, height: 150, params: {primaryKeyValue: <%=rsProds.getString("id")%>, columnName: 'status_id', actionId: 3, newStatus: 9}, method: 'post', servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'})" class=greybutton> REMOVE PRODUCT </a>
            <br>
          </td>
        </tr>
      </table>
      <%}
    }

      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="98%" valign="top">
            <%if (editable && rsProds.getString("type").equals("text")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Title&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;
            <%}
            %>
            <%=prodName%><%=smallPicURL%><%=brandStandard%><%=features%>
            <%if (editable && rsProds.getString("type").equals("text")) {
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
      <%if (editable) {
      if (smallPicURL.equals("")) {
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right" width="98%">
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divReorder'), {title: 'Change Sequence', width: 200, height: 150, method: 'post', params: {newValue: '', page: 'true', primaryKeyValue: <%=rsProds.getString("id")%>, columnName: 'sequence', actionId: 4, lastSequence: <%=rsProds.getString("sequence")%>}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'}); document.getElementById('newValue').value=<%= rsProds.getString("sequence")%>; document.getElementById('newValue').select();" class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
            <br>
          </td>
        </tr>
      </table>
      <%} else {
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right" width="98%">
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divReplace'), {title: 'Replace Product', width: 500, method: 'post', params: {primaryKeyValue: <%=rsProds.getString("id")%>, actionId: 2}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'})" class="greybutton"> Replace Product </a>
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divReorder'), {title: 'Change Sequence', width: 200, height: 150, method: 'post', params: {newValue: '', primaryKeyValue: <%=rsProds.getString("id")%>, columnName: 'sequence', actionId: 4, lastSequence: <%=rsProds.getString("sequence")%>}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'}); document.getElementById('newValue').value=<%= rsProds.getString("sequence")%>; document.getElementById('newValue').select();" class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divRemove'), {title: 'Remove Product', width: 200, height: 150, params: {primaryKeyValue: <%=rsProds.getString("id")%>, columnName: 'status_id', actionId: 3, newStatus: 9}, method: 'post', servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'})" class=greybutton> REMOVE PRODUCT </a>
            <br>
          </td>
        </tr>
      </table>
      <%}
    }
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
        <tr>
          <td width="98%" valign="top">
            <%if (editable && rsProds.getString("type").equals("text")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Title&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;
            <%}
            %>
            <%=prodName%><%=smallPicURL%><%=brandStandard%><%=features%>
            <%if (editable && rsProds.getString("type").equals("text")) {
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
      <%if (editable) {
      if (smallPicURL.equals("")) {
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right" width="98%">
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divReorder'), {title: 'Change Sequence', width: 200, height: 150, method: 'post', params: {newValue: '', page: 'true', primaryKeyValue: <%=rsProds.getString("id")%>, columnName: 'sequence', actionId: 4, lastSequence: <%=rsProds.getString("sequence")%>}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'}); document.getElementById('newValue').value=<%= rsProds.getString("sequence")%>; document.getElementById('newValue').select();" class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
            <br>
          </td>
        </tr>
      </table>
      <%} else {
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right" width="98%">
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divReplace'), {title: 'Replace Product', width: 500, method: 'post', params: {primaryKeyValue: <%=rsProds.getString("id")%>, actionId: 2}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'})" class="greybutton"> Replace Product </a>
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divReorder'), {title: 'Change Sequence', width: 200, height: 150, method: 'post', params: {newValue: '', primaryKeyValue: <%=rsProds.getString("id")%>, columnName: 'sequence', actionId: 4, lastSequence: <%=rsProds.getString("sequence")%>}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'}); document.getElementById('newValue').value=<%= rsProds.getString("sequence")%>; document.getElementById('newValue').select();" class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divRemove'), {title: 'Remove Product', width: 200, height: 150, params: {primaryKeyValue: <%=rsProds.getString("id")%>, columnName: 'status_id', actionId: 3, newStatus: 9}, method: 'post', servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'})" class=greybutton> REMOVE PRODUCT </a>
            <br>
          </td>
        </tr>
      </table>
      <%}
    }
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td rowspan="2" width="1%"  valign="top" ></td>
          <td width="1%" rowspan="2" valign="top"><img name="" src="" width="8px" height="1" alt="" /></td>
          <td width="98%" valign="top">
            <%if (editable && rsProds.getString("type").equals("text")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Title&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;
            <%}
            %>
            <%=prodName%><%=smallPicURL%><%=brandStandard%><%=features%>
            <%if (editable && rsProds.getString("type").equals("text")) {
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
      <%if (editable) {
      if (smallPicURL.equals("")) {
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right" width="98%">
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divReorder'), {title: 'Change Sequence', width: 200, height: 150, method: 'post', params: {newValue: '', page: 'true', primaryKeyValue: <%=rsProds.getString("id")%>, columnName: 'sequence', actionId: 4, lastSequence: <%=rsProds.getString("sequence")%>}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'}); document.getElementById('newValue').value=<%= rsProds.getString("sequence")%>; document.getElementById('newValue').select();" class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
            <br>
          </td>
        </tr>
      </table>
      <%} else {
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right" width="98%">
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divReplace'), {title: 'Replace Product', width: 500, method: 'post', params: {primaryKeyValue: <%=rsProds.getString("id")%>, actionId: 2}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'})" class="greybutton"> Replace Product </a>
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divReorder'), {title: 'Change Sequence', width: 200, height: 150, method: 'post', params: {newValue: '', primaryKeyValue: <%=rsProds.getString("id")%>, columnName: 'sequence', actionId: 4, lastSequence: <%=rsProds.getString("sequence")%>}, servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'}); document.getElementById('newValue').value=<%= rsProds.getString("sequence")%>; document.getElementById('newValue').select();" class=greybutton> SET ORDER [<%=rsProds.getString("sequence")%>] </a>
            <a href='#' target="_self" onclick="AjaxModalBox.open($('divRemove'), {title: 'Remove Product', width: 200, height: 150, params: {primaryKeyValue: <%=rsProds.getString("id")%>, columnName: 'status_id', actionId: 3, newStatus: 9}, method: 'post', servletUrl: '/servlet/com.marcomet.products.UpdateFeaturedProduct'})" class=greybutton> REMOVE PRODUCT </a>
            <br>
          </td>
        </tr>
      </table>
      <%}
    }
      %>
      <table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%"><tr>
          <td rowspan="2" width="1%" valign="top"></td>
          <td width="1%" rowspan="2" valign="top"><img name="" src="" width="8px" height="1" alt="" /></td>
          <td width="98%" valign="top">
            <%if (editable && rsProds.getString("type").equals("text")) {
            %>
            <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Title&primaryKeyValue=<%=rsProds.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,200)'>&raquo;</a>&nbsp;
            <%}
            %>
            <%=prodName%><%=smallPicURL%><%=brandStandard%><%=features%><%if (editable && rsProds.getString("type").equals("text")) {
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
  <td width="4%" >&nbsp;</td>
  <td width="48%" class='borderAboveLeft'>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
      <tr>
        <td rowspan="2" width="1%">&nbsp;</td>
        <td width="1%" rowspan="2" valign="top"><img name="" src="" width="8px" height="1" alt="" /></td>
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
    st1.close();
    st2.close();
    st3.close();
    conn.close();
  %>
</table>
<%=((editable)?"</body></html>":"")%>