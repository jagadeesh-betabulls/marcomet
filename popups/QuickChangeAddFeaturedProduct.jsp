<%@ page import="java.io.*,java.sql.*,java.util.*,java.text.*,com.marcomet.tools.*,com.marcomet.users.security.*,com.marcomet.jdbc.*,com.marcomet.environment.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<%
    Connection conn = DBConnect.getConnection();
    Statement st = conn.createStatement();
    Statement st1 = conn.createStatement();
    String query = "";
    String query1 = "";
    String newValue = "";
    boolean closeThis = false;

    if (request.getParameter("submitted") != null && request.getParameter("submitted").equals("true")) {
      String siteHostRoot = ((request.getParameter("siteHostRoot") == null) ? (String) session.getAttribute("siteHostRoot") : request.getParameter("siteHostRoot"));
      String siteHostId = ((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostId();
      String modId = session.getAttribute("contactId").toString();
      newValue = request.getParameter("newValue");
      String actionId = request.getParameter("actionId");

      query = "SELECT * FROM products WHERE id=" + newValue;
      ResultSet rsProd = st.executeQuery(query);
      if (rsProd.next()) {
        if (actionId.equals("1")) { //Add
          query1 = "INSERT INTO featured_products (product_id,sequence,sitehost_id,status_id,mod_id) VALUES (" + rsProd.getString("id") + "," + rsProd.getInt("sequence") + "," + siteHostId + "," + rsProd.getInt("status_id") + ",'" + modId + "')";
        } else if (actionId.equals("2")) {  //Replace
          query1 = "UPDATE featured_products SET product_id=" + rsProd.getString("id") + ", last_product_id=" + request.getParameter("primaryKeyValue") + ", last_action_id=2, mod_id=" + modId + " WHERE product_id=" + request.getParameter("primaryKeyValue");
        }
        st1.executeUpdate(query1);
      }

      try {
        File imageUrl = new File("/home/webadmin/marcomet-test.virtual.vps-host.net/html" + siteHostRoot + "/fileuploads/product_images/" + str.replaceSubstring(str.replaceSubstring(rsProd.getString("small_picurl"), ".jpg", "_TH.jpg"), " ", "%20"));
        if (!imageUrl.exists()) {
          InputStream inStream = new FileInputStream("/home/webadmin/marcomet-test.virtual.vps-host.net/html" + siteHostRoot + "/fileuploads/product_images/" + rsProd.getString("small_picurl"));
          OutputStream outStream = new FileOutputStream("/home/webadmin/marcomet-test.virtual.vps-host.net/html" + siteHostRoot + "/fileuploads/product_images/" + str.replaceSubstring(str.replaceSubstring(rsProd.getString("small_picurl"), ".jpg", "_TH.jpg"), " ", "%20"));
          byte[] b = new byte[1024];
          int len;

          while ((len = inStream.read(b)) > 0) {
            outStream.write(b, 0, len);
          }

          inStream.close();
          outStream.close();
        }
      } catch (IOException e) {
        System.out.println(e);
      }
      closeThis = true;
    } else {
%>
<html>
  <head>
    <title><%=request.getParameter("title")%></title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  </head>
  <script lanugage="JavaScript" src="/javascripts/mainlib.js"></script>
  <body>
    <form method="post" action="/popups/QuickChangeAddFeaturedProduct.jsp?submitted=true">
      <table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
        <tr>
          <td class="lineitems">
            <a href='javascript:window.location.replace(window.location.href+"?showAll=true");' class=menuLINK>Show All</a>
          </td>
        </tr>
        <tr>
          <td class="lineitemscenter">
            <%
  String sitehostId = ((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostId();
  String activeFilter = ((request.getParameter("showAll") == null || !(request.getParameter("showAll").equals("true"))) ? " p.status_id=2 AND " : "");
  //String sql = "SELECT p.id 'value', CONCAT(p.prod_code,':',left(p.prod_name,25),if(length(p.prod_name)>25,'...',''),' [',p.brand_code,'] '" + ((activeFilter.equals("")) ? ",'[',if(p.status_id=1,'Draft',if(p.status_id=2,'Active','On Hold')),']'" : "") + ") 'text' FROM products p,product_lines pl, featured_products fp WHERE " + activeFilter + " sitehost_id=" + sitehostId + " AND (p.brand_code=pl.brand_code or p.brand_code='') group by p.id ORDER BY p.prod_code, p.brand_code";
  String sql = "SELECT p.id 'value', CONCAT(p.prod_code,':',left(p.prod_name,25),if(length(p.prod_name)>25,'...',''),' [',p.brand_code,'] '" + ((activeFilter.equals("")) ? ",'[',if(p.status_id=1,'Draft',if(p.status_id=2,'Active','On Hold')),']'" : "") + ") 'text' FROM products p left join site_hosts sh on p.company_id=sh.company_id WHERE " + activeFilter + " sh.id=" + sitehostId + " ORDER BY p.prod_code, p.brand_code";
            %>
            <formtaglib:SQLDropDownTag dropDownName="newValue" sql="<%= sql %>" />
          </td>
        </tr>
        <tr>
          <td align="center">
            <input type="button" value="Add/Replace" onClick="submit()">
            &nbsp;&nbsp;&nbsp;&nbsp;
            <input type="button" value="Cancel" onClick="self.close()">
          </td>
        </tr>
      </table>
      <input type="hidden" name="actionId" value="<%=request.getParameter("actionId")%>">
      <input type="hidden" name="primaryKeyValue" value="<%=request.getParameter("primaryKeyValue")%>">
      <input type="hidden" name="$$Return" value="<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>">
    </form>
  </body>
</html>
<% }
    st.close();
    st1.close();
    conn.close();
    if (closeThis) {
%>
<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>
<%  }
%>
