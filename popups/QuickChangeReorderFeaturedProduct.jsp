<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*,com.marcomet.tools.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
    Connection conn = DBConnect.getConnection();
    Statement st = conn.createStatement();
    Statement st1 = conn.createStatement();
    String query = "";
    String newValue = "";
    String actionId = "";
    String lastSequence = "";
    boolean closeThis = false;

    if (request.getParameter("submitted") != null && request.getParameter("submitted").equals("true")) {
      newValue = request.getParameter("newValue");
      actionId = request.getParameter("actionId");
      lastSequence = request.getParameter("lastSequence");
      String modId = session.getAttribute("contactId").toString();

      if (actionId.equals("3")) { //Remove
        query = "UPDATE featured_products SET " + request.getParameter("columnName") + "=" + newValue + ", last_action_id=" + actionId + ", mod_id=" + modId + " WHERE product_id=" + request.getParameter("primaryKeyValue");
      } else if (actionId.equals("4")) {  //Reorder
        query = "UPDATE featured_products SET " + request.getParameter("columnName") + "=" + newValue + ", last_action_id=" + actionId + ", mod_id=" + modId + ", last_sequence=" + lastSequence + " WHERE product_id=" + request.getParameter("primaryKeyValue");
      }
      st1.executeUpdate(query);
      closeThis = true;
    } else {
%>
<html>
  <head>
    <title><%= request.getParameter("title")%></title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  </head>
  <script src="/javascripts/mainlib.js"></script>
  <body>
    <form method="post" action="/popups/QuickChangeReorderFeaturedProduct.jsp?submitted=true">
      <table border="0" cellpadding="5" cellspacing="0" align="center" width="100%">
        <tr><td></td></tr>
        <tr>
          <td class="lineitems" align="center">
            <%
  if (request.getParameter("valueFieldVal") == null || request.getParameter("valueFieldVal").equals("")) {
    if (request.getParameter("page") != null && request.getParameter("page").equals("true")) {
      query = "SELECT sequence FROM featured_products fp where fp.page_id=" + request.getParameter("primaryKeyValue");
    } else {
      query = "SELECT sequence FROM featured_products fp where fp.product_id=" + request.getParameter("primaryKeyValue");
    }
    ResultSet rs = st.executeQuery(query);
    if (rs.next()) {
            %>
            <input name="newValue" value="<%=rs.getString(1)%>" size="10">
            <%
              }
            } else {
            %>
            <input type="hidden" name="newValue" value="<%=request.getParameter("valueFieldVal")%>">
            <%}
            %>
          </td>
        </tr>
        <tr>
          <td align="center">
            <input type="button" value="Update" onClick="submit()">
            &nbsp;&nbsp;&nbsp;&nbsp;
            <input type="button" value="Cancel" onClick="self.close()">
          </td>
        </tr>
      </table>
      <input type="hidden" name="columnName" value="<%=request.getParameter("columnName")%>">
      <input type="hidden" name="actionId" value="<%=request.getParameter("actionId")%>">
      <input type="hidden" name="lastSequence" value="<%=request.getParameter("lastSequence")%>">
      <input type="hidden" name="primaryKeyValue" value="<%=request.getParameter("primaryKeyValue")%>">
      <input type="hidden" name="$$Return" value="<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>">
      <script>document.forms[0].newValue.focus();document.forms[0].newValue.select();</script>
    </form>
  </body>
</html>
<%  }
    st.close();
    st1.close();
    conn.close();
    if (closeThis) {
%>
<script>parent.window.opener.location.reload();setTimeout('close()',500);</script>
<%  }
%>