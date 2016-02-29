<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%
String query = "SELECT buyer_contact_id, vendor_contact_id, site_host_contact_id, site_host_global_markup, marcomet_global_fee FROM jobs j, projects p, orders o WHERE o.id = p.order_id AND p.id = j.project_id AND j.id = " + request.getParameter("jobId");


Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(query);

Hashtable rehash = new Hashtable();

while (rs.next()) {
	rehash.put("buyerContactId", rs.getString("buyer_contact_id"));
	rehash.put("vendorContactId", rs.getString("vendor_contact_id"));
	rehash.put("siteHostContactId", rs.getString("site_host_contact_id"));
	rehash.put("siteHostGlobalMarkup", rs.getString("site_host_global_markup"));
	rehash.put("marcometGlobalFee", rs.getString("marcomet_global_fee"));
}

try { st.close(); } catch (Exception e) {}
try { conn.close(); } catch (Exception e) {}
%>
<html>
<head>
  <title>Interim Shipping</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body class="body" onLoad="MM_preloadImages('/images/buttons/submitover.gif','/images/buttons/cancelbtover.gif')" background="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.InterimShipmentServlet">
  <p class="Title">Interim Shipment </p>
  
  <jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
<p> <span class=label>Description of Shipment / Item(s) shipped:</span><br>
  <textarea cols="60" rows=3 name="description"></textarea><br>
</p>
  <table class="body">
    <tr> 
      <td class="label">Shipped To:</td>
      <td>
        <input type="text" name="shippedTo">
      </td>
    </tr>
    <tr> 
      <td class="label">Shipped From:</td>
      <td>
        <input type="text" name="shippedFrom">
      </td>
    </tr>
    <tr> 
      <td class="label">Shipping Date:</td>
      <td class="label"> <taglib:DropDownDateTag extraCode="onChange=\"popHiddenDateField('shipdate')\"" /> 
        <input type="hidden" name="shipdate" value="2001-01-01">
      </td>
      <td>&nbsp;</td>
      <td colspan="4" class="label">Please enter your shipping cost:</td>
    </tr>
    <tr> 
      <td class="label" >Method:</td>
      <td>
        <input type="text" name="method">
      </td>
      <td>&nbsp;</td>
      <td class="tableheader">Est Cost</td>
      <td class="tableheader">Markup %</td>
      <td class="tableheader">Seller MU</td>
      <td class="tableheader">MC Fee</td>
      <td class="tableheader">Price</td>
    </tr>
    <tr> 
      <td class="label">Reference/Tracking #</td>
      <td>
        <input type="text" name="reference">
      </td>
      <td>&nbsp;</td><%
      if (Integer.parseInt((String)rehash.get("buyerContactId")) == Integer.parseInt((String)rehash.get("siteHostContactId"))) { %>
      <td align="right" class="body">
        <input type="text" size="5" name="cost" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 0, 0, 0)" value="">
      </td>
      <td align="right" class="body">
        <div id="percentage">0</div>
        <input type="hidden" name="percentage" value="0">
      </td>
      <td align="right" class="body">
        <div id="mu">0</div>
        <input type="hidden" name="mu" value="0">
      </td><%
      } else if (Integer.parseInt((String)rehash.get("siteHostContactId")) == Integer.parseInt(((UserProfile)session.getAttribute("userProfile")).getContactId())) { %>
      <td align="right" class="body">
        <input type="text" size="5" name="cost" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 0, 0, 1)" value="">
      </td>
      <td align="right" class="body">
        <input type="text" size="7" name="percentage" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 0, 0, 1)" value="<%= Double.parseDouble((String)rehash.get("siteHostGlobalMarkup")) * 100 %>">
      </td>
      <td align="right" class="body">
        <input type="text" size="7" name="mu" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 0, 1, 1)" value="">
      </td><%
      } else { %>
      <td align="right" class="body">
        <input type="text" size="5" name="cost" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 0, 0, 0)" value="">
      </td>
      <td align="right" class="body">
        <div id="percentage"><%= Double.parseDouble((String)rehash.get("siteHostGlobalMarkup")) * 100 %></div>
        <input type="hidden" name="percentage" value="<%= Double.parseDouble((String)rehash.get("siteHostGlobalMarkup")) * 100 %>">
      </td>
      <td align="right" class="body">
        <div id="mu">0</div>
        <input type="hidden" name="mu" value="0">
      </td><%
      } %>
      <td align="right" class="body"> 
        <div id="fee">0</div>
        <input type="hidden" name="fee" value="0">
      </td>
      <td align="right" class="body"> 
        <div id="price">0</div>
        <input type="hidden" name="price" value="0">
      </td>
    </tr>
  </table>
<br><jsp:include page="/includes/MailingAddressForm.jsp" flush="true"><jsp:param name="formNeeded" value="false" /><jsp:param name="jobId" value="<%=jobId%>" /><jsp:param name="editor" value="<%=editor%>" /></jsp:include>
<table border="0" width="25%" align="center">
  <tr>
      <td> 
        <div align="center"><a href="/minders/JobMinderSwitcher.jsp"class="greybutton">Cancel</a> 
        </div>
      </td>
    <td>&nbsp;</td>
      <td> 
        <div align="center"><a href="javascript:document.forms[0].submit()"class="greybutton">Submit</a> 
        </div>
      </td>
  </tr>
</table>
<input type="hidden" name="jobId" value="<%=request.getParameter("jobId")%>">
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
<input type="hidden" name="shippingStatus" value="interim">
</form>
</body>
</html>