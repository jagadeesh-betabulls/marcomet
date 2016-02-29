<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.users.security.*,java.util.*,java.util.Vector, com.marcomet.catalog.*;" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%
	SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); 
    boolean useSavedBrand=((sl.getValue("site_hosts","id",shs.getSiteHostId(),"keep_last_brand_choice").equals("1"))?true:false);
    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
    
	String lastBrandCode=((useSavedBrand)?sl.getValue("contacts","id",(String)session.getAttribute("contactId"),"last_brand_chosen"):"");
    
    
    String lastSHID=sl.getValue("contacts","id",(String)session.getAttribute("contactId"),"last_sitehost_id");
	if(lastBrandCode!=null && !lastBrandCode.equals("")){
		session.setAttribute("brandCode",lastBrandCode);	
		if(shs.getSiteType().equals("aggregator") && lastSHID!=null && !lastSHID.equals("")){
			String shQuery = "SELECT sh.*,sh1.site_type as siteType from site_hosts sh,site_hosts sh1 where sh1.id="+shs.getSiteHostId()+" and sh.id="+lastSHID;
			ResultSet shRS = st.executeQuery(shQuery); 
			if (shRS.next()) { 
				session.setAttribute("tmpSHRoot","/sitehosts/"+shRS.getString("site_host_name"));
				session.setAttribute("tmpSHCompanyId",shRS.getString("company_id"));
				session.setAttribute("tmpSHId",lastSHID);
				session.setAttribute("isAggregator",((shRS.getString("siteType")!= null && shRS.getString("siteType").equals("aggregator"))?"true":"false"));
			}
			shRS.close();
		}else{
			String shQuery = "SELECT * from brands where brand_code='"+lastBrandCode+"'";
			ResultSet shRS = st.executeQuery(shQuery); 
			if (shRS.next()) { 
				session.setAttribute("tmpPLSegment",shRS.getString("prod_line_segment"));
				session.setAttribute("brandCode",lastBrandCode);
			}
			shRS.close();
		}
	}

	String shTarget="mainFr";
    ShoppingCart cart = (ShoppingCart) session.getAttribute("shoppingCart");
    Vector projects = null;
    boolean isOrder = false;
    if (cart != null) {
      projects = cart.getProjects();
      if (projects.size() > 0) {
        isOrder = true;
      }
    } else {
      projects = new Vector();
    }

    boolean editor = (((RoleResolver) session.getAttribute("roles")).roleCheck("editor") && request.getParameter("isTopNav") != null);
    boolean isTopNav = ((request.getParameter("isTopNav") == null || request.getParameter("isTopNav").equals("true") || request.getParameter("isTopNav").equals("")) ? true : false);
    boolean useWelcome = ((request.getParameter("noName") == null || request.getParameter("noName").equals("false") || request.getParameter("noName").equals("")) ? true : false);
    String ShowRelease = ((request.getParameter("ShowRelease") == null || request.getParameter("ShowRelease").equals("")) ? "" : " AND nav_menus.release='" + request.getParameter("ShowRelease") + "' ");
    String sitehostId = ((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostId();
    String ShowInactive = ((request.getParameter("ShowInactive") == null || request.getParameter("ShowInactive").equals("")) ? " AND status_id=2 " : "");
    boolean editable = ((request.getParameter("editable") != null && request.getParameter("editable").equals("true")) ? true : false);

    String pageName = ((request.getParameter("pageName") == null || request.getParameter("pageName").equals("")) ? " AND page_name='home' " : " AND page_name= '" + request.getParameter("pageName") + "' ");
	String sh_target="mainFr";
    String lastModId = session.getAttribute("contactId").toString();

    String sql2 = "SELECT id, link_text 'value', sequence FROM nav_menus WHERE page_name='" + request.getParameter("pageName") + "' AND sitehost_id=" + sitehostId + " AND status_id=2";
    String shSQL = "SELECT sh_target FROM site_hosts WHERE id=" + sitehostId;
    ResultSet rsSH = st.executeQuery(shSQL);
    if (rsSH.next()) {
    	shTarget=((rsSH.getString("sh_target")==null || rsSH.getString("sh_target").equals("sh_target"))?"mainFr":rsSH.getString("sh_target"));
    }

    if (isTopNav) {
%>
<link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script src="/javascripts/prototype1.js" type="text/javascript"></script>
<script src="/javascripts/scriptaculous1.js" type="text/javascript"></script>
<script src="/javascripts/menu.js" type="text/javascript"></script>
<%}

if(editable){
%>
<script type="text/javascript">
  function editLink(primaryKeyValue){
    var ajaxRequest;
    if(window.XMLHttpRequest){
      //Mozilla, Netscape.
      ajaxRequest = new XMLHttpRequest();
    }
    else if(window.ActiveXObject){
      //Internet Explorer.
      ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
    }

    var params = "primaryKeyValue="+primaryKeyValue+"&editLink=true";

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

<div id="divReorderLink" style="background-color: #fffccc; border: 2px solid black; display: none;">
  <br>
  Menu Parent       :&nbsp;
  <select id="ReorderLinkMenuParent">
    <option value="0">NONE
    <%
    ResultSet rs111 = st.executeQuery(sql2);
    while (rs111.next()) {
    %>
    <option value="<%= rs111.getString("id")%>"><%= rs111.getString("value")%>
    <%}
    rs111.close();
    %>
  </select>
  <br>
  Sequence          :&nbsp;<input id="ReorderLinkSequence" size="7" value="">
  <br><br><br>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Update" onclick="AjaxModalBox.submit({menuParent: $('ReorderLinkMenuParent').options[$('ReorderLinkMenuParent').selectedIndex].value, sequence: $('ReorderLinkSequence').value})">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Cancel" onclick="AjaxModalBox.close()">
  <br>
</div>
<div id="divEnableLink" style="background-color: #fffccc; border: 2px solid black; display: none;">
  <br>
  This will Add the Link into the current Nav Menu, Are you sure you want to continue?
  <br><br><br>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Update" onclick="AjaxModalBox.submit({statusId: 2})">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Cancel" onclick="AjaxModalBox.close()">
  <br>
</div>
<div id="divDisableLink" style="background-color: #fffccc; border: 2px solid black; display: none;">
  <br>
  This will Remove the Link from the current Nav Menu, Are you sure you want to continue?
  <br><br><br>
  &nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Update" onclick="AjaxModalBox.submit({statusId: 9})">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <input type="button" value="Cancel" onclick="AjaxModalBox.close()">
  <br>
</div><%} //if editable%>
<div id="menu">
<ul class="level1" id="root"><%
	String qryString1="SELECT  distinct nav_menus.id,nav_menus.menu_parent,if(nav_menus.sitehost_id="+sitehostId+",nav_menus.sequence,nav_menus.sequence_on_market_site) as 'sequence',nav_menus.page_name,nav_menus.link,nav_menus.link_text,nav_menus.link_type,nav_menus.target,nav_menus.sitehost_id,nav_menus.prodline_id,nav_menus.link_page,nav_menus.status_id,nav_menus.`release`,nav_menus.brand_code,nav_menus.last_mod_id,nav_menus.date_created,nav_menus.date_modified,nav_menus.hide_from_aggregators,nav_menus.use_on_market_site FROM nav_menus left join sitehost_brandid_bridge on sitehost_brandid_bridge.sitehost_id="+ sitehostId +"  where (nav_menus.sitehost_id=" + sitehostId + " or (nav_menus.sitehost_id=sitehost_brandid_bridge.brandid_sitehost_id and sitehost_brandid_bridge.show_brandmenu=1 and nav_menus.use_on_market_site=1)) " + pageName + ShowInactive + ShowRelease + " ORDER BY sequence";

    %><!--qryStr=<%=qryString1%> --><%
    ResultSet rs = st.executeQuery(qryString1);
    int x = 1;
    int y = 1;
    int level = 1;
    String lastMenu = "";
    String lastId = "";
    String levelStr = "level1";
    Hashtable hMenus = new Hashtable<String, Integer>();
    Hashtable hDD1 = new Hashtable<String, String>();
    Hashtable hDD2 = new Hashtable<String, String>();

    while (rs.next()) {

      String target = ((rs.getString("target").equals("")) ? "main" : rs.getString("target"));

      if (rs.getString("menu_parent").equals(rs.getString("id"))) { //if this is a top level Menu
        hMenus.put(rs.getString("id"), 1);
        while (level-- > 1) {
  %></li></ul><%      }
      y = 0;
      level = 1;
%><%=((x++ > 1) ? "</li>" : "")%><li><%
if (rs.getInt("status_id") == 9) {
  %><a href="<%=rs.getString("link")%>" target='<%=target%>' id='l<%=rs.getString("id")%>' style="background-color: #fffaaa" ><%=rs.getString("link_text")%></a><%
 } else {
  %><a href="<%=rs.getString("link")%>" target='<%=target%>' id='l<%=rs.getString("id")%>' ><%=rs.getString("link_text")%></a><%
 }

if (editable) {
  %>&nbsp;&nbsp;--&nbsp;&nbsp;
  <a href="#" target="_self" onclick="javascript:editLink(<%= rs.getString("id")%>)" class="graybutton">&nbsp;EDIT LINK&nbsp;</a>
  &nbsp;&nbsp;<a href="#" target="_self" onclick="AjaxModalBox.open($('divReorderLink'), {title: 'Change Sequence', width: 400, height: 200, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {action: 'reorder', primaryKeyValue: <%= rs.getString("id")%>, lastModId: <%= lastModId%>}}); if(<%= rs.getString("id")%> == <%= rs.getString("menu_parent")%>){$('ReorderLinkMenuParent').selectedIndex = 0;} else{for(i=1;i<$('ReorderLinkMenuParent').options.length; i++){if($('ReorderLinkMenuParent').options[i].value == '<%= rs.getString("menu_parent")%>'){$('ReorderLinkMenuParent').selectedIndex = i; break;}}} document.getElementById('ReorderLinkSequence').value=<%= rs.getString("sequence")%>;" class="graybutton">&nbsp;REORDER LINK&nbsp;</a>
  <%if (rs.getInt("status_id") == 9) {
  %>
  &nbsp;&nbsp;<a href="#" target="_self" onclick="AjaxModalBox.open($('divEnableLink'), {title: 'Disable the Link', width: 400, height: 200, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {action : 'enable_disable', primaryKeyValue: <%= rs.getString("id")%>, lastModId: <%= lastModId%>}})" class="graybutton">&nbsp;ENABLE LINK&nbsp;</a>
  <%} else {
  %>
  &nbsp;&nbsp;<a href="#" target="_self" onclick="AjaxModalBox.open($('divDisableLink'), {title: 'Disable the Link', width: 400, height: 200, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {action : 'enable_disable', primaryKeyValue: <%= rs.getString("id")%>, lastModId: <%= lastModId%>}})" class="graybutton">&nbsp;DISABLE LINK&nbsp;</a><%
  }
}
} else { //if this is a secondary level menu

      if (rs.getString("menu_parent").equals(lastId)) { //if this is the first of the next level submenu
        if (level == 1) {
          hDD1.put(lastId, rs.getString("menu_parent"));
        } else {
          hDD2.put(lastId, rs.getString("menu_parent"));
        }
        level++; //increase the level
%><ul class='level<%=level%>'><%
          if (hMenus.get(rs.getString("menu_parent")) == null) { //if this menu hasn't been logged yet, add it to the mix.
            hMenus.put(rs.getString("id"), level);
          }

        } else if (hMenus.get(rs.getString("menu_parent")) != null && !(rs.getString("menu_parent").equals(lastMenu))) { //if this level menu has been used before
          //level--;
          while (level-- > (Integer.parseInt(hMenus.get(rs.getString("menu_parent")).toString())) + 1) {
  %></li></ul><%    }
          level = Integer.parseInt(hMenus.get(rs.getString("menu_parent")).toString()) + 1;

        } else { //if this is a new submenu item
%></li><%  }
%><li><%
if (rs.getInt("status_id") == 9) {
  	%><a href="<%=rs.getString("link")%>" target='<%=target%>' id='l<%=rs.getString("id")%>' style="background-color: #fffaaa" ><%=rs.getString("link_text")%></a><%
  	
} else {
  %><a href="<%=rs.getString("link")%>" target='<%=target%>' id='l<%=rs.getString("id")%>' ><%=rs.getString("link_text")%></a><%
 }
if (editable) {
  %>&nbsp;&nbsp;--&nbsp;&nbsp;
  <a href="#" target="_self" onclick="javascript:editLink(<%= rs.getString("id")%>)" class="graybutton">&nbsp;EDIT LINK&nbsp;</a>
  &nbsp;&nbsp;<a href="#" target="_self" onclick="AjaxModalBox.open($('divReorderLink'), {title: 'Change Sequence', width: 400, height: 200, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {action: 'reorder', primaryKeyValue: <%= rs.getString("id")%>, lastModId: <%= lastModId%>}}); if(<%= rs.getString("id")%> == <%= rs.getString("menu_parent")%>){$('ReorderLinkMenuParent').selectedIndex = 0;} else{for(i=0;i<$('ReorderLinkMenuParent').options.length; i++){if($('ReorderLinkMenuParent').options[i].value == '<%= rs.getString("menu_parent")%>'){$('ReorderLinkMenuParent').selectedIndex = i; break;}}} document.getElementById('ReorderLinkSequence').value=<%= rs.getString("sequence")%>;" class="graybutton">&nbsp;REORDER LINK&nbsp;</a>
  <%if (rs.getInt("status_id") == 9) {
  %>
  &nbsp;&nbsp;<a href="#" target="_self" onclick="AjaxModalBox.open($('divEnableLink'), {title: 'Disable the Link', width: 400, height: 200, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {action : 'enable_disable', primaryKeyValue: <%= rs.getString("id")%>, lastModId: <%= lastModId%>}})" class="graybutton">&nbsp;ENABLE LINK&nbsp;</a><%
  } else {
  %>&nbsp;&nbsp;<a href="#" target="_self" onclick="AjaxModalBox.open($('divDisableLink'), {title: 'Disable the Link', width: 400, height: 200, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {action : 'enable_disable', primaryKeyValue: <%= rs.getString("id")%>, lastModId: <%= lastModId%>}})" class="graybutton">&nbsp;DISABLE LINK&nbsp;</a>
  <%}
}

}
      lastMenu = rs.getString("menu_parent");
      lastId = rs.getString("id");
}
  %></li><%
//If 
    if (isOrder) {
%><li>
  <a href="http://<%=(String)session.getAttribute("baseURL")%>/frames/InnerFrameset.jsp?contents=/contents/secureSite.jsp" target="_top" ><strong><img src='/images/cart.gif' border='0'>&nbsp;SECURE&nbsp;CHECKOUT</strong></a>
</li><%    }
    if (((RoleResolver) session.getAttribute("roles")).roleCheck("editor") && !editable) {
%><li>
  <a href="/contents/SiteMap.jsp?pageName=<%= request.getParameter("pageName")%>&edit=true" class="graybutton">&nbsp;EDIT&nbsp;</a>
</li><%}
%>
</ul><%

if (isTopNav && useWelcome) {
	%><span id='menuText'>&nbsp; &nbsp; &nbsp; &nbsp; WELCOME <%= session.getAttribute("UserFullName")%>!</span><%
}
%></div>
<script>
  <%
    Vector v1 = new Vector(hDD1.keySet());
    Iterator e = v1.iterator();
    Vector v2 = new Vector(hDD2.keySet());
    Iterator f = v2.iterator();
    int c = 0;
    while (e.hasNext()) {
  %>
    var x=document.getElementById("l<%=(String) e.next()%>").className='parent';
<%
    }
    while (f.hasNext()) {
  %>
    var x=document.getElementById("l<%=(String) f.next()%>").className='parent';
  <%
    }
  %>
</script>
<%
    rs.close();
    st.close();
    conn.close();
%>