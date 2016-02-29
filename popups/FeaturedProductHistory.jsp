<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*,com.marcomet.tools.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
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
    <title>View History</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  </head>
  <script src="/javascripts/mainlib.js"></script>
  <body>
    <table border="1" cellpadding="5" cellspacing="0" align="center" width="75%">
      <tr>
        <td align="center" width="10%" class="menuLINKText">Date Of Change</td>
        <td align="center" width="10%" class="menuLINKText">Action</td>
        <td align="center" width="15%" class="menuLINKText">Product/Page</td>
        <td align="center" width="15%" class="menuLINKText">Made By</td>
      </tr>
      <%
    //String query = "SELECT fp.modification_date 'date of change', lfp.value 'action', prd.id 'product id', prd.prod_name 'product name', prd.prod_code 'product code', c.id 'contact id', c.firstname, c.lastname FROM featured_products fp, products prd, lu_featured_products_actions lfp, contacts c WHERE sitehost_id=29 AND pagename='home' AND fp.product_id=prd.id AND fp.last_action_id=lfp.id AND fp.mod_id=c.id ORDER BY fp.modification_date";
    //String query = "SELECT fp.modification_date 'date of change', lfp.id 'action id', lfp.value 'action', fp.last_sequence 'last sequence', fp.last_product_id 'last product id', prd.id 'product id', prd.prod_name 'product name', prd.prod_code 'product code', c.id 'contact id', c.firstname, c.lastname FROM featured_products fp, products prd, lu_featured_products_actions lfp, contacts c WHERE sitehost_id=29 AND pagename='home' AND fp.product_id=prd.id AND fp.last_action_id=lfp.id AND fp.mod_id=c.id ORDER BY fp.modification_date";
    String query = "SELECT fp.modification_date 'date of change', lfp.id 'action id', lfp.value 'action', fp.last_sequence 'last sequence', fp.last_product_id 'last product id', prd.id 'product id', prd.prod_name 'product name', prd.prod_code 'product code', c.id 'contact id', c.firstname, c.lastname FROM featured_products fp, products prd, lu_featured_products_actions lfp, contacts c WHERE sitehost_id=29 AND fp.product_id=prd.id AND fp.last_action_id=lfp.id AND fp.mod_id=c.id ORDER BY fp.modification_date";
    ResultSet rs = st.executeQuery(query);
    while (rs.next()) {
      %>
      <tr>
        <td valign="top" width="17%"><%=rs.getString("date of change")%></td>
        <%
        if (rs.getInt("action id") == 2) {
        %>
        <td valign="top" width="16%"><%=rs.getString("action")%> -- Last Product Id : #<%=rs.getString("last product id")%></td>
        <%} else if (rs.getInt("action id") == 4) {
        %>
        <td valign="top" width="16%"><%=rs.getString("action")%> -- Last Sequence : <%=rs.getString("last sequence")%></td>
        <%} else {
        %>
        <td valign="top" width="16%"><%=rs.getString("action")%></td>
        <%}
        %>
        <td valign="top" width="21%">#<%=rs.getString("product id")%>, <%=rs.getString("product name")%> - <%=rs.getString("product code")%></td>
        <td valign="top" width="21%">#<%=rs.getString("contact id")%>, <%=rs.getString("firstname")%> <%=rs.getString("lastname")%></td>
        <%    }
        %>
      </tr>
    </table>
  </body>
</html>
<%
    st.close();
    st1.close();
    conn.close();
%>