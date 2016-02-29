<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.jdbc.*, com.marcomet.users.security.RoleResolver, com.marcomet.environment.SiteHostSettings" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%
    session.setAttribute("currentSession", "true");
%>
<link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
<link rel="stylesheet" href="/styles/modalbox.css" type="text/css">
<script type="text/javascript" src="/javascripts/prototype1.js"></script>
<script type="text/javascript" src="/javascripts/scriptaculous1.js"></script>
<script type="text/javascript" src="/javascripts/modalbox.js"></script>
<%
    String siteHostRoot = ((request.getParameter("siteHostRoot") == null) ? (String) session.getAttribute("siteHostRoot") : request.getParameter("siteHostRoot"));
    SiteHostSettings shs = (SiteHostSettings) session.getAttribute("siteHostSettings");
    String pageName = request.getParameter("pageName");
    String sitehostId = ((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostId();
    String lastModId = session.getAttribute("contactId").toString();
    boolean editor = ((((RoleResolver) session.getAttribute("roles")).roleCheck("editor")) && request.getParameter("editor") == null);
    boolean editable = (editor && request.getParameter("edit") != null && request.getParameter("edit").equals("true"));
    String ShowInactive = ((request.getParameter("ShowInactive") == null || request.getParameter("ShowInactive").equals("")) ? "" : request.getParameter("ShowInactive"));

    Connection conn = DBConnect.getConnection();
    Statement st = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
    Statement st1 = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);

    if (editable) {
      String sql1 = "SELECT id, value FROM lu_link_targets ORDER BY sequence";
      String sql2 = "SELECT id, link_text 'value', sequence FROM nav_menus WHERE page_name='" + pageName + "' AND sitehost_id=" + sitehostId + " AND status_id=2";

      String sql7 = "SELECT DISTINCT release_code FROM product_releases ORDER BY release_date";
      ResultSet rs7 = st.executeQuery(sql7);
      rs7.last();
      String release = rs7.getString("release_code");
      rs7.close();
%>
<div id="divAddLink" style="background-color: #fffccc; border: 2px solid black; display: none;">
  <br>
  Link Type         :&nbsp;
  <select id="ddLinkType" onchange="javascript:toggleLinkType($('ddLinkType').options[$('ddLinkType').selectedIndex].value)">
    <option value="">Select Link Type..
    <%
  String sql = "SELECT id, value from lu_navmenu_link_types ORDER BY sequence";
  ResultSet rs = st.executeQuery(sql);
  while (rs.next()) {
    %>
    <option value="<%= rs.getString("id")%>"><%= rs.getString("value")%>
    <%}
  rs.close();
    %>
  </select>
  <br><br>
</div>
<div id="divExternalLink" style="background-color: #fffccc; border: 2px solid black; display: none;">
  <div id="divELBack" align="right" style="display: '';">
    &nbsp;&nbsp;<a href="#" target="_self" class="menuLink" onclick="AjaxModalBox.open($('divAddLink'), {title: 'Add Link', width: 300})"> BACK </a>
  </div>
  <br>
  Link Address      :&nbsp;<input id="ELLinkAddress" size="60" value="http://">
  <br>
  Target            :&nbsp;
  <select id="ELTarget">
    <%
  ResultSet rs11 = st.executeQuery(sql1);
  while (rs11.next()) {
    %>
    <option value="<%= rs11.getString("id")%>"><%= rs11.getString("value")%>
    <%}
  rs11.close();
    %>
  </select>
  <br>
  Menu Parent       :&nbsp;
  <select id="ELMenuParent" onchange="javascript:setSequence(this.options[this.selectedIndex].value, 'ELSequence')">
    <option value="0">NONE
    <%
  ResultSet rs21 = st.executeQuery(sql2);
  while (rs21.next()) {
    %>
    <option value="<%= rs21.getString("id")%>"><%= rs21.getString("value")%>
    <%}
  rs21.close();
    %>
  </select>
  <br>
  <%
  String sql81 = "SELECT sequence FROM nav_menus WHERE page_name='" + pageName + "' AND sitehost_id=" + sitehostId + " ORDER BY sequence";
  ResultSet rs81 = st.executeQuery(sql81);
  rs81.last();
  %>
  Sequence          :&nbsp;<input id="ELSequence" size="7" value="<%= rs81.getInt("sequence") + 10%>">
  <%
  rs81.close();
  %>
  <br>
  Link Display Text :&nbsp;<input id="ELLinkText" size="60" value="">
  <br><br><br>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Update" onclick="AjaxModalBox.submit({action: 'insert', link: targetLink($('ELTarget').options[$('ELTarget').selectedIndex].text, $('ELLinkAddress').value), target: (($('ELTarget').options[$('ELTarget').selectedIndex].text == 'pop(URL,height,width)') ? '' : $('ELTarget').options[$('ELTarget').selectedIndex].text), menuParent: $('ELMenuParent').options[$('ELMenuParent').selectedIndex].value, sequence: $('ELSequence').value, linkText: $('ELLinkText').value})">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Cancel" onclick="AjaxModalBox.close()">
  <br>
</div>
<div id="divHTMLPageLink" style="background-color: #fffccc; border: 2px solid black; display: none;">
  <div id="divELBack" align="right" style="display: '';">
    &nbsp;&nbsp;<a href="#" target="_self" class="menuLink" onclick="AjaxModalBox.open($('divAddLink'), {title: 'Add Link', width: 300})"> BACK </a>
  </div>
  <br>
  Page              :&nbsp;
  <select id="HTMLPage" onchange="javascript:document.getElementById('HTMLPageName').value = this.options[this.selectedIndex].value;">
    <option value="">New Page
    <%
  String sql3 = "SELECT DISTINCT p.page_name 'pagename', p.title FROM pages p, site_hosts sh WHERE (p.company_id=sh.company_id OR p.company_id=1066) AND sh.id=" + sitehostId + " ORDER BY p.page_name";
  ResultSet rs3 = st.executeQuery(sql3);
  while (rs3.next()) {
    String title = rs3.getString("title");
    if (title == null) {
      title = "";
    }
    %>
    <option value="<%= rs3.getString("pagename")%>"><%= title%>&nbsp;[<%= rs3.getString("pagename")%>]
    <%}
  rs3.close();
    %>
  </select>
  <br>
  Page Name         :&nbsp;<input id="HTMLPageName" size="60" value="">
  <br>
  Target            :&nbsp;
  <select id="HTMLTarget">
    <%
  ResultSet rs12 = st.executeQuery(sql1);
  while (rs12.next()) {
    %>
    <option value="<%= rs12.getString("id")%>"><%= rs12.getString("value")%>
    <%}
  rs12.close();
    %>
  </select>
  <br>
  Menu Parent       :&nbsp;
  <select id="HTMLMenuParent" onchange="javascript:setSequence(this.options[this.selectedIndex].value, 'HTMLSequence')">
    <option value="0">NONE
    <%
  ResultSet rs22 = st.executeQuery(sql2);
  while (rs22.next()) {
    %>
    <option value="<%= rs22.getString("id")%>"><%= rs22.getString("value")%>
    <%}
  rs22.close();
    %>
  </select>
  <br>
  <%
  String sql82 = "SELECT sequence FROM nav_menus WHERE page_name='" + pageName + "' AND sitehost_id=" + sitehostId + " ORDER BY sequence";
  ResultSet rs82 = st.executeQuery(sql82);
  rs82.last();
  %>
  Sequence          :&nbsp;<input id="HTMLSequence" size="7" value="<%= rs82.getInt("sequence") + 10%>">
  <%
  rs82.close();
  %>
  <br>
  Link Display Text :&nbsp;<input id="HTMLLinkText" size="60" value="">
  <br><br><br>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Update" onClick="AjaxModalBox.submit({action: 'insert', page: $('HTMLPage').options[$('HTMLPage').selectedIndex].text, newPageName: $('HTMLPageName').value, link: targetLink($('HTMLTarget').options[$('HTMLTarget').selectedIndex].text, '/contents/page.jsp?pageName=' + $('HTMLPageName').value), target: (($('HTMLTarget').options[$('HTMLTarget').selectedIndex].text == 'pop(URL,height,width)') ? '' : $('HTMLTarget').options[$('HTMLTarget').selectedIndex].text), menuParent: $('HTMLMenuParent').options[$('HTMLMenuParent').selectedIndex].value, sequence: $('HTMLSequence').value, linkText: $('HTMLLinkText').value})">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Cancel" onClick="AjaxModalBox.close()">
  <br>
</div>
<div id="divBRANDIDPageLink" style="background-color: #fffccc; border: 2px solid black; display: none;">
  <div id="divELBack" align="right" style="display: '';">
    &nbsp;&nbsp;<a href="#" target="_self" class="menuLink" onclick="AjaxModalBox.open($('divAddLink'), {title: 'Add Link', width: 300})"> BACK </a>
  </div>
  <br>
  Page              :&nbsp;
  <select id="BRANDIDPage" onchange="javascript:document.getElementById('BRANDIDPageName').value = this.options[this.selectedIndex].value;">
    <option value="">New Page
    <%
  String sql4 = "SELECT DISTINCT p.page_name 'pagename', p.title FROM pages p, site_hosts sh WHERE (p.company_id=sh.company_id OR p.company_id=1066) AND sh.id=" + sitehostId + " ORDER BY p.page_name";
  ResultSet rs4 = st.executeQuery(sql4);
  while (rs4.next()) {
    String title = rs4.getString("title");
    if (title == null) {
      title = "";
    }
    %>
    <option value="<%= rs4.getString("pagename")%>"><%= title%>&nbsp;[<%= rs4.getString("pagename")%>]
    <%}
  rs4.close();
    %>
  </select>
  <br>
  Page Name         :&nbsp;<input id="BRANDIDPageName" size="60" value="">
  <br>
  Target            :&nbsp;
  <select id="BRANDIDTarget">
    <%
  ResultSet rs13 = st.executeQuery(sql1);
  while (rs13.next()) {
    %>
    <option value="<%= rs13.getString("id")%>"><%= rs13.getString("value")%>
    <%}
  rs13.close();
    %>
  </select>
  <br>
  Menu Parent       :&nbsp;
  <select id="BRANDIDMenuParent" onchange="javascript:setSequence(this.options[this.selectedIndex].value, 'BRANDIDSequence')">
    <option value="0">NONE
    <%
  ResultSet rs23 = st.executeQuery(sql2);
  while (rs23.next()) {
    %>
    <option value="<%= rs23.getString("id")%>"><%= rs23.getString("value")%>
    <%}
  rs23.close();
    %>
  </select>
  <br>
  <%
  String sql83 = "SELECT sequence FROM nav_menus WHERE page_name='" + pageName + "' AND sitehost_id=" + sitehostId + " ORDER BY sequence";
  ResultSet rs83 = st.executeQuery(sql83);
  rs83.last();
  %>
  Sequence          :&nbsp;<input id="BRANDIDSequence" size="7" value="<%= rs83.getInt("sequence") + 10%>">
  <%
  rs83.close();
  %>
  <br>
  Link Display Text :&nbsp;<input id="BRANDIDLinkText" size="60" value="">
  <br><br><br>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Update" onClick="AjaxModalBox.submit({action: 'insert', page: $('BRANDIDPage').options[$('BRANDIDPage').selectedIndex].text, newPageName: $('BRANDIDPageName').value, link: targetLink($('BRANDIDTarget').options[$('BRANDIDTarget').selectedIndex].text, '/contents/brandSpecPage.jsp?pageName=' + $('BRANDIDPageName').value), target: (($('BRANDIDTarget').options[$('BRANDIDTarget').selectedIndex].text == 'pop(URL,height,width)') ? '' : $('BRANDIDTarget').options[$('BRANDIDTarget').selectedIndex].text), menuParent: $('BRANDIDMenuParent').options[$('BRANDIDMenuParent').selectedIndex].value, sequence: $('BRANDIDSequence').value, linkText: $('BRANDIDLinkText').value})">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Cancel" onClick="AjaxModalBox.close()">
  <br>
</div>
<div id="divProductLineListLink" style="background-color: #fffccc; border: 2px solid black; display: none;">
  <div id="divELBack" align="right" style="display: '';">
    &nbsp;&nbsp;<a href="#" target="_self" class="menuLink" onclick="AjaxModalBox.open($('divAddLink'), {title: 'Add Link', width: 300})"> BACK </a>
  </div>
  <br>
  Product Line      :&nbsp;
  <select id="PLProductLine">
    <%
  String sql5 = "SELECT DISTINCT pl.prod_line_name 'productlinename', left(pl.id,6) 'id' FROM product_lines pl, site_hosts sh WHERE pl.company_id=sh.company_id AND pl.status_id=2 AND sh.id=" + sitehostId + " ORDER BY pl.prod_line_name";
  ResultSet rs5 = st.executeQuery(sql5);
  while (rs5.next()) {
    %>
    <option value="<%= rs5.getString("id")%>"><%= rs5.getString("productlinename")%>
    <%}
  rs5.close();
    %>
  </select>
  <br>
  Release           :&nbsp;
  <select id="PLRelease">
    <%
  String sql6 = "SELECT DISTINCT pr.release_code 'value', CONCAT(pr.display_title,IF(LENGTH(pr.description)>0,CONCAT(':',left(pr.description,25)),''),IF(LENGTh(pr.description)>25,'...','')) 'text' FROM product_releases pr, site_hosts sh WHERE pr.company_id=sh.company_id AND sh.id=" + sitehostId + " ORDER BY pr.release_date";
  ResultSet rs6 = st.executeQuery(sql6);
  while (rs6.next()) {
    %>
    <option value="<%= rs6.getString("value")%>"><%= rs6.getString("text")%>
    <%}
  rs6.close();
    %>
  </select>
  <br>
  Target            :&nbsp;<input id="PLTarget" size="10" value="mainFr" readonly onclick="javascript:this.removeAttribute('readOnly');">
  <br>
  Menu Parent       :&nbsp;
  <select id="PLMenuParent" onchange="javascript:setSequence(this.options[this.selectedIndex].value, 'PLSequence')">
    <option value="0">NONE
    <%
  ResultSet rs24 = st.executeQuery(sql2);
  while (rs24.next()) {
    %>
    <option value="<%= rs24.getString("id")%>"><%= rs24.getString("value")%>
    <%}
  rs24.close();
    %>
  </select>
  <br>
  <%
  String sql84 = "SELECT sequence FROM nav_menus WHERE page_name='" + pageName + "' AND sitehost_id=" + sitehostId + " ORDER BY sequence";
  ResultSet rs84 = st.executeQuery(sql84);
  rs84.last();
  %>
  Sequence          :&nbsp;<input id="PLSequence" size="7" value="<%= rs84.getInt("sequence") + 10%>">
  <%
  rs84.close();
  %>
  <br>
  Link Display Text :&nbsp;<input id="PLLinkText" size="60" value="">
  <br><br><br>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Update" onClick="AjaxModalBox.submit({action: 'insert', prodLineId: $('PLProductLine').options[$('PLProductLine').selectedIndex].value, release: $('PLRelease').options[$('PLRelease').selectedIndex].value, target: $('PLTarget').value, menuParent: $('PLMenuParent').options[$('PLMenuParent').selectedIndex].value, sequence: $('PLSequence').value, linkText: $('PLLinkText').value})">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Cancel" onClick="AjaxModalBox.close()">
  <br>
</div>
<div id="divInternalLink" style="background-color: #fffccc; border: 2px solid black; display: none;">
  <div id="divELBack" align="right" style="display: '';">
    &nbsp;&nbsp;<a href="#" target="_self" class="menuLink" onclick="AjaxModalBox.open($('divAddLink'), {title: 'Add Link', width: 300})"> BACK </a>
  </div>
  <br>
  Link Address      :&nbsp;<input id="ILLinkAddress" size="60" value="">
  <br>
  Target            :&nbsp;
  <select id="ILTarget">
    <%
  ResultSet rs14 = st.executeQuery(sql1);
  while (rs14.next()) {
    %>
    <option value="<%= rs14.getString("id")%>"><%= rs14.getString("value")%>
    <%}
  rs14.close();
    %>
  </select>
  <br>
  Menu Parent       :&nbsp;
  <select id="ILMenuParent" onchange="javascript:setSequence(this.options[this.selectedIndex].value, 'ILSequence')">
    <option value="0">NONE
    <%
  ResultSet rs25 = st.executeQuery(sql2);
  while (rs25.next()) {
    %>
    <option value="<%= rs25.getString("id")%>"><%= rs25.getString("value")%>
    <%}
  rs25.close();
    %>
  </select>
  <br>
  <%
  String sql85 = "SELECT sequence FROM nav_menus WHERE page_name='" + pageName + "' AND sitehost_id=" + sitehostId + " ORDER BY sequence";
  ResultSet rs85 = st.executeQuery(sql85);
  rs85.last();
  %>
  Sequence          :&nbsp;<input id="ILSequence" size="7" value="<%= rs85.getInt("sequence") + 10%>">
  <%
  rs85.close();
  %>
  <br>
  Link Display Text :&nbsp;<input id="ILLinkText" size="60" value="">
  <br><br><br>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Update" onclick="AjaxModalBox.submit({action: 'insert', link: targetLink($('ILTarget').options[$('ILTarget').selectedIndex].text, $('ILLinkAddress').value), target: (($('ILTarget').options[$('ILTarget').selectedIndex].text == 'pop(URL,height,width)') ? '' : $('ILTarget').options[$('ILTarget').selectedIndex].text), menuParent: $('ILMenuParent').options[$('ILMenuParent').selectedIndex].value, sequence: $('ILSequence').value, linkText: $('ILLinkText').value})">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Cancel" onclick="AjaxModalBox.close()">
  <br>
</div>

<script type="text/javascript">
  function toggleLinkType(linkType){
    //var selectedLinkType = linkType.options[linkType.selectedIndex].value;

    if(linkType == "1"){
      AjaxModalBox.open($('divExternalLink'), {title: 'Add External Link', width: 600, height: 300, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {pageName: '<%= pageName%>', linkType: linkType, siteHostId: <%= sitehostId%>, prodLineId: 0, linkPage: '', statusId: 2, release: '<%= release%>', lastModId: <%= lastModId%>}});
    } else if(linkType == "2"){
      AjaxModalBox.open($('divHTMLPageLink'), {title: 'Add HTML Page Link', width: 600, height: 300, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {pageName: '<%= pageName%>', linkType: linkType, siteHostId: <%= sitehostId%>, prodLineId: 0, linkPage: '', statusId: 2, release: '<%= release%>', lastModId: <%= lastModId%>}});
    } else if(linkType == "3"){
      AjaxModalBox.open($('divBRANDIDPageLink'), {title: 'Add BRAND ID Page Link', width: 600, height: 300, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {pageName: '<%= pageName%>', linkType: linkType, siteHostId: <%= sitehostId%>, prodLineId: 0, linkPage: '', statusId: 2, release: '<%= release%>', lastModId: <%= lastModId%>}});
    } else if(linkType == "4"){
      AjaxModalBox.open($('divProductLineListLink'), {title: 'Add Product Line Listing Link', width: 600, height: 300, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {pageName: '<%= pageName%>', linkType: linkType, siteHostId: <%= sitehostId%>, link: '', linkPage: 'logos.jsp', statusId: 2, lastModId: <%= lastModId%>}});
      $('PLRelease').selectedIndex = $('PLRelease').options.length - 1;
    } else if(linkType == "5" ){
      AjaxModalBox.open($('divInternalLink'), {title: 'Add Internal Link', width: 600, height: 300, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {pageName: '<%= pageName%>', linkType: linkType, siteHostId: <%= sitehostId%>, prodLineId: 0, linkPage: '', statusId: 2, release: '<%= release%>', lastModId: <%= lastModId%>}});
    }
  }

  function targetLink(target, linkaddress){
    var link;
    if(target == 'pop(URL,height,width)'){
      link = 'javascript:pop(\\\'' + linkaddress + '\\\', 640, 480)';
    }
    else{
      link = linkaddress;
    }
    return link;
  }

  function setSequence(menuparent, sequence){
    var ajaxRequest;
    if(window.XMLHttpRequest){
      //Mozilla, Netscape.
      ajaxRequest = new XMLHttpRequest();
    }
    else if(window.ActiveXObject){
      //Internet Explorer.
      ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
    }

    var params = "MenuParentSequence=true&menuParent="+menuparent+"&sequence="+sequence+"&pageName=<%= pageName%>&siteHostId=<%= sitehostId%>";

    ajaxRequest.open("post", "/servlet/com.marcomet.commonprocesses.ProcessNavMenu", true);
    ajaxRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
    ajaxRequest.send(params);
    ajaxRequest.onreadystatechange = function(){
      if(ajaxRequest.readyState == 4){
        if(ajaxRequest.status == 200){
          eval(ajaxRequest.responseText);
        }
      }
    };
  }
</script>

<div align="left">
  <%
  if (editable) {
  %>
  &nbsp;&nbsp;<a href="#" target="_self" onclick="AjaxModalBox.open($('divAddLink'), {title: 'Add Link', width: 300, method: 'post', servletUrl: '/servlet/com.marcomet.commonprecesses.ProcessNavMenu'})" class="graybutton">&nbsp;ADD LINK&nbsp;</a>
  <%
    if (ShowInactive.equals("")) {
  %>
  &nbsp;&nbsp;<a href="/contents/SiteMap.jsp?pageName=<%= pageName%>&edit=true&ShowInactive=true" class="graybutton">&nbsp;SHOW DISABLED&nbsp;</a>
  <%} else if (ShowInactive.equals("true")) {
  %>
  &nbsp;&nbsp;<a href="/contents/SiteMap.jsp?pageName=<%= pageName%>&edit=true" class="graybutton">&nbsp;HIDE DISABLED&nbsp;</a>
  <%}
  %>
  &nbsp;&nbsp;<a href="<%=siteHostRoot%>/contents/SiteHostIndex.jsp" class="graybutton">&nbsp;PREVIEW PAGE&nbsp;</a>
  <br>
  <%  } else {
  %>
  <a href="/contents/SiteMap.jsp?pageName=<%= pageName%>&edit=true" target="main" class="graybutton">&nbsp;EDIT&nbsp;</a>
  <br>
  <%  }
  %>
</div>
<%}
%>
<html>
  <head>
    <title>Site Map</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
  </head>
  <script language="JavaScript" src="/javascripts/mainlib.js"></script>
  <body leftmargin="20" topmargin="10">
    <div class='title'>Site Map for <%=shs.getDomainName()%></div>
    <jsp:include page="/includes/topNav.jsp" flush="true" >
      <jsp:param name="pageName" value="<%= pageName%>" />
      <jsp:param name="isTopNav" value="false" />
      <jsp:param name="ShowInactive" value="<%= ShowInactive%>" />
      <jsp:param name="editable" value="<%= editable%>" />
    </jsp:include>
  </body>
</html>
<%
    st.close();
    st1.close();
    conn.close();
%>