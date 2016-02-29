<%@ include file="/includes/SessionChecker.jsp" %><%@ page errorPage="/errors/ExceptionPage.jsp" %><%@ page import="com.marcomet.users.security.*,com.marcomet.users.security.RoleResolver, com.marcomet.environment.SiteHostSettings" %><% 
session.setAttribute("currentSession","true");
 if (session.getAttribute("contactId") == null) { 
 %><script language="JavaScript">
	window.location.replace("/app-admin/AdminLogin.jsp"); 
   </script><%
    } 
   %><jsp:include page="/app-admin/includes/LoadSiteHostInformation.jsp" flush="true"/><%
    if( request.getParameter("site") != null) request.getSession().setAttribute("siteHostRoot", "/sitehosts/" + request.getParameter("site")); 
    %><html>
<head>
  <title>Marcomet Site Administration</title>
  <meta http-equiv="pragma" content="no-cache">
  <meta http-equiv="Pragma-directive" content="no-cache">
  <meta http-equiv="cache-directive" content="no-cache">
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
  <br /><blockquote><div class="title">Marcomet Site Administration Tools</div>
  <ul class='list'><%
            if (session.getAttribute("roles") != null) {
              if (((RoleResolver)session.getAttribute("roles")).isSiteHost() || ((RoleResolver)session.getAttribute("roles")).isVendor()) { 
              	%><li class='list'><a class='lineitems' href="/app-admin/companyinfo/CompanyInformationPage.jsp">Company Information</a></li>
              <li><a class='lineitems' href="/app-admin/users/CompanyMembersList.jsp">Members</a></li><%
			  }
              if (((RoleResolver)session.getAttribute("roles")).isVendor()) { 
                %><li class='list'><a class='lineitems' href="/admin/collections/EntryForm.jsp">Enter Check Collections</a></li>
<li class='list'><a class='lineitems' href="/app-admin/contents/CollectionsForm.jsp">Enter Credit Card Collections</a></li>
<li class='list'><a class='lineitems' href="/app-admin/collections/ViewListForm.jsp">View Collections</a></li>
<li class='list'><a class='lineitems' href="/app-admin/payments/APAddEntry.jsp" target='_blank'>Manage Payables</a></li>
<li><a href="/minders/workflowforms/InventoryUpdateForm.jsp"  class='subtitle1' target='_blank'>Update Inventory</a></li>
<!--              <a class='lineitems' href="/app-admin/CatalogSelection.jsp">Catalog Management</a><br> --> <%
              }
              if (((RoleResolver)session.getAttribute("roles")).isSiteHost()) { 
              %><!--<a class='lineitems' href="/app-admin/OfferingSelection.jsp">Offering Management</a><br>-->
			  <li class='list'><a class='lineitems' href="/app-admin/sitesetup/SiteSetup.jsp">Site Management</a></li><%
              }
            } else {
         		%>No roles?<%  
            } %></ul></blockquote>
            </body>
</html>
