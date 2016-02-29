<%@ page import="java.sql.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<html>
<head>
  <title>Proxy User Selection</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script>
	function submitProxy(cid){
		document.forms[0].proxyContact.value=cid;
		document.forms[0].submit();
	}
</script>
</head>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<body onLoad="MM_preloadImages('/images/buttons/continueover.gif', '/images/buttons/continuedown.gif', '/images/buttons/cancelbtover.gif', '/images/buttons/cancelbtdown.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<%
  String contactsQuery = "SELECT firstname, lastname, c.id, c.companyid, comp.company_name as compname FROM contacts c, contact_roles cr, companies comp  WHERE c.id = cr.contact_id AND c.companyid=comp.id AND site_host_id = " + ((com.marcomet.environment.SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostId() + " AND c.id != " + ((com.marcomet.environment.UserProfile)session.getAttribute("userProfile")).getContactId() + " ORDER BY comp.company_name ";
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet contactsRS = st.executeQuery(contactsQuery);
  request.setAttribute("contactsRS", contactsRS); %>
<form method="post" action="/servlet/com.marcomet.catalog.ProxyOrderServlet">
  <table width="100%" height="100%"border="0" cellspacing="0" cellpadding="0">
    <tr valign="middle"> 
      <td align="center" height="53"> 
        <p class="catalogTITLE">&nbsp;</p>
        <p class="catalogTITLE">&nbsp;</p>
        <p class="catalogTITLE"><font size="4">Client Proxy Order Selection</font></p>
        <p class="catalogITEM"><span class="catalogLABEL">You may open jobs on 
          your clients behalf. </span></p>
        <p class="catalogITEM"><span class="catalogLABEL">Please choose a client 
          below and click continue to proceed.</span></p>
      </td>
    </tr>
    <tr valign="top"> 
      <td align="center" valign="middle"> 
        <table>
          <tr> 
            <td align="center"><select name="proxyContact"><iterate:dbiterate name="contactsRS" id="i"><option value="<$ id $>:<$ companyid $>" selected><$ compname $> - <$ lastname $>, <$ firstname $></option></iterate:dbiterate> </select></td>
          </tr>
        </table>
        </td>
    </tr>
    <tr valign="top"> 
      <td align="right" height="22%"> 
        <div align="center"><a href="/minders/JobMinderSwitcher.jsp"class="greybutton">Cancel</a>&nbsp;<a href="/popups/ContactLookup.jsp?proxy=Y" target="_blank" class="menuLINK">Contact Lookup</a>&nbsp;<a href="/users/NewUserForm.jsp" class="greybutton">Add New Client</a>&nbsp;<a href="javascript:document.forms[0].submit()"class="greybutton">Continue</a> 
        </div>
      </td>
    </tr>
  </table>
<input type="hidden" name="$$Return" value="[<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp]">
</form>
</body>
</html><%conn.close();%>
