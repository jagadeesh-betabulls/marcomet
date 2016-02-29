<%@ page import="java.sql.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%
    String sitehostId = ((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostId();
    String jobId = (String) request.getParameter("jobId");
    String carrier = (String) request.getParameter("carrier");
    String method = (String) request.getParameter("method");
    String reference = (String) request.getParameter("reference");
    String shipmentDate = (String) request.getParameter("shipDate");
    String shipmentId = "";
    String shipTo = "";
    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
    String query = "";
	boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")));
    query = "SELECT shipment_id FROM jobs WHERE id=" + jobId;
    ResultSet rs = st.executeQuery(query);
    if (rs.next()) {
      shipmentId = rs.getString("shipment_id");
    }
    rs.close();
    query = "SELECT l.zip 'zipTo' FROM locations l, jobs j WHERE l.locationtypeid=1 AND l.contactid=j.jbuyer_contact_id AND j.id=" + jobId;
    ResultSet rs1 = st.executeQuery(query);
    if (rs1.next()) {
      shipTo = rs1.getString("zipTo");
    }
    rs1.close();
%>
<html>
  <head>
    <title>Packing Slip</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link rel="stylesheet" href="<%=((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
    <link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
    <script language="JavaScript" src="/javascripts/mainlib.js"></script>
  </head>
  <body>
    <p class="Title">Packing Slip</p>
    <table border="0">
      <tr>
        <td class="minderheaderright">Packing Slip for Shipment #<%=shipmentId%></td>
      </tr>
    </table>
    <p></p>
    <table border="0">
      <tr>
        <%
    query = "SELECT body FROM pages WHERE page_name='packing_slip_header' AND (sitehost_id_p=" + sitehostId + " OR sitehost_id_p=0) AND status_id=2";
    ResultSet rs2 = st.executeQuery(query);
    if (rs2.next()) {
        %>
        <td align="right" class="lineitems"><%= rs2.getString("body")%></td>
        <%}
    rs2.close();
        %>
      </tr>
    </table>
    <p></p>
    <table border="0">
      <tr>
        <td class="minderheaderright">Carrier</td>
        <td align="right" class="lineitems"><%=carrier%></td>
      </tr>
      <tr>
        <td class="minderheaderright">Carrier Type</td>
        <td align="right" class="lineitems"><%=method%></td>
      </tr>
      <tr>
        <td class="minderheaderright">Reference/Tracking #</td>
        <td align="right" class="lineitems"><%=reference%></td>
      </tr>
      <tr>
        <td class="minderheaderright">Shipment Date</td>
        <td align="right" class="lineitems"><%=shipmentDate%></td>
      </tr>
      <tr>
        <td align="left" class="lineitems" colspan="2"><jsp:include page="/includes/MailingAddressForm.jsp" flush="true"><jsp:param name="jobId" value="<%=jobId%>" /><jsp:param name="editor" value="<%=editor%>" /></jsp:include></td>
      </tr>
    </table>
    <p></p>
    <table border="0" cellpadding="0" cellspacing="0" width="60%" align="center" class="body">
      <tr>
        <td colspan="2">
          <div class="subtitle">Box Assignments</div>
        </td>
      </tr>
      <tr>
        <td class="planheader1" width="10%" height="9">Box #</td>
        <td class="planheader1" width="10%" height="9">Weight</td>
        <td class="planheader1" width="40%" height="9">Contents</td>
      </tr>
      <%
    query = "SELECT count(*) 'rows' FROM shipment_boxes WHERE shipment_id=" + shipmentId;
    ResultSet rs31 = st.executeQuery(query);
    String rows = "0";
    if (rs31.next()) {
      rows = rs31.getString("rows");
    }
    rs31.close();

    query = "SELECT *, box_weight 'weight', box_contents 'contents' FROM shipment_boxes WHERE shipment_id=" + shipmentId;
    ResultSet rs32 = st.executeQuery(query);
    int count = 0;
    while (rs32.next()) {
      count++;
      %>
      <tr>
        <td class="lineitems" align="right"><%= count%> of <%= rows%></td>
        <td class="lineitems" align="right"><%= rs32.getString("weight")%> lbs</td>
        <td class="lineitems" align="right"><%= rs32.getString("contents")%></td>
      </tr>
      <%}
    rs32.close();
      %>
    </table>
    <%
    query = "SELECT id FROM jobs WHERE shipment_id=" + shipmentId;
    ResultSet rs4 = st.executeQuery(query);
    while (rs4.next()) {
      String jId = rs4.getString("id");
    %>
    <p></p>
    <jsp:include page="/includes/JobDetailHeader.jsp" flush="true">
      <jsp:param name="jobId" value="<%= jId%>" />
    </jsp:include>
    <%}
    rs4.close();
    %>
    <p></p>
    <%
    query = "SELECT body FROM pages WHERE page_name='packing_slip_footer' AND (sitehost_id_p=" + sitehostId + " OR sitehost_id_p=0) AND status_id=2";
    ResultSet rs11 = st.executeQuery(query);
    if (rs11.next()) {
    %>
    <%= rs11.getString("body")%>
    <%}
    rs11.close();
    %>
  </body>
</html>
