<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%
String default_warehouse_id="";
String inventory_amount="0";
String productId=((request.getParameter("productId")==null)?"0":request.getParameter("productId"));

String query = "Select sum(amount) inventory_amount,if( p.default_warehouse_id=0,if(v.default_warehouse_id is null,105,v.default_warehouse_id), p.default_warehouse_id) default_warehouse_id  from inventory i,products p left join product_price_codes pp on p.prod_price_code=pp.prod_price_code left join vendors v on v.id=pp.dropship_vendor where p.id=i.product_id and p.id="+productId+" group by p.id";

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(query);

Hashtable rehash = new Hashtable();

	while (rs.next()) {
		default_warehouse_id=rs.getString("default_warehouse_id");
		inventory_amount=rs.getString("inventory_amount");
	}

query = "select  if(w.id is null,105,w.id)  warehouse_id, concat(c.company_name,',',v.address1,',',v.city,', ',vlu.value,' ', v.zip) warehouse   FROM lu_abreviated_states vlu, companies c, company_locations v left join warehouses w on w.location_id=v.id where c.id=v.company_id   and vlu.id=v.state and v.lu_location_type_id=4  group by v.id";
	
	rs = st.executeQuery(query);


String warehouseSelect1="<select class='lineitems' name='warehouse_id'><option value='' >[Choose Warehouse]</option>";
String warehouseSelect1s="<select class='lineitems' name='warehouse_id' Selected><option value='' >[Choose Warehouse]</option>";
String warehouseSelect2="";
String warehouseSelect="";
String warehouseSelect2S="";
String selected="";

int warehousesFound=0;
	while (rs.next()) {
		warehousesFound++;
		selected=((rs.getString("warehouse_id").equals(default_warehouse_id)) ? "Selected":"");
		if(warehousesFound==1){
			warehouseSelect2="<option value='"+rs.getString("warehouse_id")+"' "+selected+">"+rs.getString("warehouse")+"</option>";
			warehouseSelect2S="<select class='lineitems' name='warehouse_id' Selected><option value='"+rs.getString("warehouse_id")+"' Selected>"+rs.getString("warehouse")+"</option>";
		}else{
			warehouseSelect+="<option value='" + rs.getString("warehouse_id") + "' " + selected + ">" + rs.getString("warehouse") + "</option>";
		}
	}
	if (warehousesFound>1){
		if (default_warehouse_id.equals("")){
			warehouseSelect=warehouseSelect1s+warehouseSelect2+warehouseSelect;
		}else{
			warehouseSelect=warehouseSelect1+warehouseSelect2+warehouseSelect;			
		}
	}else{
		warehouseSelect=warehouseSelect2S+warehouseSelect;
	}
	warehouseSelect+="</select>";	
	
	st.close();
	conn.close();
%>
<html>
<head>
<title>Interim Shipping</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script language="JavaScript">
	var oldAmount=<%=inventory_amount%>*1;
	function updateAmount(){
		var adjAmount=document.forms[0].quantity.value*1;
		if (document.forms[0].stock_action[0].checked){
			newAmount=oldAmount+adjAmount;
		}else{
			newAmount=oldAmount-adjAmount;
		}
		document.getElementById("newAmount").innerHTML=newAmount;
	}
	function submitForm(){
		document.forms[0].action="/servlet/com.marcomet.sbpprocesses.AdjustInventory";
		document.forms[0].submit;
	}
</script>
</head>
<body class="body" onLoad="MM_preloadImages('/images/buttons/submitover.gif','/images/buttons/cancelbtover.gif')" background="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/images/back3.jpg">
<form method="post" action="/minders/workflowforms/InventoryAdjustment.jsp">
          <p class="Title">Inventory Control</p>
  <blockquote>
    <blockquote>
      <blockquote>
        <blockquote>
		          <p class="subTitle">Adjustments to Inventory  </p>
  <table border="0" cellpadding="5" cellspacing="0" >
      <tr>
         <td colspan="2" class="minderheaderleft" >Choose Product:</td>
      </tr>
      <tr>
         <td colspan="2" class="lineitems"><select name="productId" class='lineitems' onChange="document.forms[0].submit();"><option <%=((productId.equals("0"))?"Selected":"")%> value="0">[Select Product]</option><%
				String sql = "SELECT id, prod_code, prod_name FROM products WHERE inventory_product_flag=1 ORDER BY prod_code";
				ResultSet rsRP = st.executeQuery(sql);
				while (rsRP.next()) {
					%><option value="<%=rsRP.getString("id")%>" <%=((productId.equals(rsRP.getString("id")))?"Selected":"")%>  ><%=rsRP.getString("prod_code")%> - <%=rsRP.getString("prod_name")%></option><%}%></select></td>
      </tr>
<tr>
	<td colspan="2" class="minderheaderleft">Restock/Remove from warehouse:</td>
	</tr>
	<tr>
		<td colspan="2" class="lineitems">
          <input type='hidden' name='warehouse_id' class='lineitems'><%=warehouseSelect%></td>
	</tr>
	<tr>
       <td class="minderheaderleft" >Stock Action:</td>
       <td class="minderheaderleft" >Adjustment Reason:</td>
	</tr>
    <tr>
       <td class="lineitems"><input name="stock_action" type="radio" value="add" checked onChange="updateAmount()">Increase<input name="stock_action" type="radio" value="subtract" onChange="updateAmount()">Decrease</td>
	   <td class="lineitems"><select name="adjustment_type_id"  class='lineitems' >
         <option value="1" selected>Stock Replenishment</option>
         <option value="2">Manual Adjustment</option>
         <option value="3">Product Shipped</option>
       </select></td>
    </tr>
	<tr>
       <td colspan="2" align=right>
  		<table border="1" cellpadding="5" cellspacing="0" >
      		<tr>
        		<td class="minderheaderright">Amount in Stock </td>
        <td align="right" class="lineitems"><%=inventory_amount%></td>
      </tr>
      <tr>
        <td  class="minderheaderright">Quantity this Adjustment:</td>
        <td align="right" class="lineitems"><input name="quantity" size=10 class="lineitemsright" onChange="updateAmount(this)">
            </td>
      </tr>
	<tr>
        <td class="minderheaderright">New Stock Quantity </td>
        <td align="right" class="lineitems"><span align="right" id="newAmount"><%=inventory_amount%></span></td>
      </tr>
  </table>       </td>
	</tr>
	<tr>
	        <td colspan="2" class="minderheaderleft">Notes on Adjustment:</td>
	</tr>
	<tr>
		<td colspan="2">
            <textarea class="lineitems" cols="70" rows=3 name="description"> </textarea></td></tr>
<tr><td colspan="2">
	<table border="0" width="100%">
	  <tr>
	      <td> 
	        <div align="center"><a href="/minders/JobMinderSwitcher.jsp"class="greybutton">Cancel</a></div>	      </td>
	    <td>&nbsp;</td>
	      <td> 
	        <div align="center"><a href="javascript:submitForm()"class="greybutton">Submit</a>	        </div>	      </td>
	  </tr>
	</table>
</tr><tr><td colspan="2"></td>
</table>
        </blockquote>
	    </blockquote>
	  </blockquote>
  </blockquote>
<input type="hidden" name="contactId" value="<%=((UserProfile)session.getAttribute("userProfile")).getContactId()%>">
<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
<input type="hidden" name="shippingStatus" value="interim">
</form>
</body>
</html><%conn.close();%>