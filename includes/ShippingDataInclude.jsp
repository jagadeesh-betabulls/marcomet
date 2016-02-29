<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.jdbc.*, com.marcomet.users.security.RoleResolver, com.marcomet.environment.UserProfile;" %>
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
%>
<table width="100%" border="0" cellspacing="2" cellpadding="2">
  <tr>
    <td class="contentstitle">Shipping Method &amp; Costs
      <hr width="100%" size="1">
    </td>
  </tr>
</table>
<table width="100%">
  <tr> 
    <td class="label">Shipping Date:</td>
    <td class="label"> <taglib:DropDownDateTag extraCode="onChange=\"popHiddenDateField('shipdate')\"" /> 
      <input type="hidden" name="shipdate" value="2001-01-01">
    </td>
    <td>&nbsp;</td>
    <td colspan="4" class='label'>Please enter your shipping cost:</td>
  </tr>
  <tr> 
    <td class="label" height="7" >Method:</td>
    <td height="7"> 
      <input type="text" name="method">
    </td>
    <td height="7">&nbsp;</td>
    <td class="tableheader" width="100"> 
      <div align="right">Est Cost$</div>
    </td>
    <td class="tableheader" width="100"> 
      <div align="right">Markup %</div>
    </td>
    <td class="tableheader" width="100"> 
      <div align="right">Markup $</div>
    </td>
    <td class="tableheader" width="100"> 
      <div align="right">MC Fee</div>
    </td>
    <td class="tableheader" width="100"> 
      <div align="right">Price</div>
    </td>
  </tr>
  <tr> 
    <td class="label">Reference/Tracking #</td>
    <td>
      <input type="text" name="reference">
    </td>
    <td>&nbsp;</td><%
      if (Integer.parseInt((String)rehash.get("buyerContactId")) == Integer.parseInt((String)rehash.get("siteHostContactId"))) { %>
    <td align="right">
      <input type="text" size="7" name="cost" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 0, 0, 0)" value="">
    </td>
    <td align="right">
      <div id="percentage">0</div>
      <input type="hidden" name="percentage" value="0">
    </td>
    <td align="right">
      <div id="mu">0</div>
      <input type="hidden" name="mu" value="0">
    </td><%
      } else if (Integer.parseInt((String)rehash.get("siteHostContactId")) == Integer.parseInt(((UserProfile)session.getAttribute("userProfile")).getContactId())) { %>
    <td align="right">
      <input type="text" size="7" name="cost" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 0, 0, 1)" value="">
    </td>
    <td align="right">
      <input type="text" size="7" name="percentage" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 0, 0, 1)" value="<%= Double.parseDouble((String)rehash.get("siteHostGlobalMarkup")) * 100 %>">
    </td>
    <td align="right">
      <input type="text" size="7" name="mu" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 0, 1, 1)" value="">
    </td><%
      } else { %>
    <td align="right">
      <input type="text" size="7" name="cost" onChange="updatePrices(<%=(String)rehash.get("marcometGlobalFee")%>, 0, 0, 0)" value="">
    </td>
    <td align="right">
      <div id="percentage"><%= Double.parseDouble((String)rehash.get("siteHostGlobalMarkup")) * 100 %></div>
      <input type="hidden" name="percentage" value="<%= Double.parseDouble((String)rehash.get("siteHostGlobalMarkup")) * 100 %>">
    </td>
    <td align="right">
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

<%
rs.close();
st.close();
conn.close();
%>
