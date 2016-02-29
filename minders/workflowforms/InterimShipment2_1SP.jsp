<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%@ include file="/includes/SessionChecker.jsp" %>
<%
boolean shipAdjust=((request.getParameter("actionId").equals("80"))?true:false);
boolean closeOnExit=((request.getParameter("closeOnExit")!=null && request.getParameter("closeOnExit").equals("true"))?true:false);
boolean editor= ((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")));
String invInitialFlag="false";
String completeAction="98";
String openAction="99";
String maxSVHandling="0";
//set the decimal format for field values
DecimalFormat df1 = new DecimalFormat("#,###.00");
Hashtable rehash = new Hashtable();
Hashtable wareHash = new Hashtable();

//get job info 

//Shipping Entities: 
	//shipping_vendor_id=vendor doing the actual shipping; Default to the vendor_id that corresponds to the company the user is associated with. Only editor role should be allowed to change this.
	//shipping_account_vendor_id=id of vendor who's account is being used for shipment; Default to the shipping_account_vendor_id on the vendor record that corresponds to the company the user is associated with. Only editor role should be allowed to change this.
	//subvendor_id=vendor who owns the product being shipped and to whom the payment obligation is accrued. Default to the vendor_id that corresponds to the company the user is associated with. Only editor role should be allowed to change this.

String proxyVendorId=sl.getValue("contacts","id",((UserProfile)session.getAttribute("userProfile")).getContactId(), "proxyvendor");



String query = "";
query = "SELECT distinct j.post_date,j.ship_cost_policy,j.ship_price_policy,j.std_ship_cost,j.std_ship_price,concat(b.city,', ',blu.value,' ', b.zip) buyer_address,concat(v.city,', ',vlu.value,' ', v.zip) vendor_address, jbuyer_contact_id, j.dropship_vendor,j.vendor_contact_id, sales_contact_id site_host_contact_id, site_host_global_markup, marcomet_global_fee, if(quantity is null,'0',quantity) quantity, if(quantity_shipped is null,'0',quantity_shipped) quantity_shipped,j.product_id,j.price,j.jwarehouse_id,w.vendor_id as shipvendorid FROM lu_abreviated_states blu, lu_abreviated_states vlu, locations b, company_locations v,vendors vn, jobs j left join warehouses w on w.id=j.jwarehouse_id WHERE vn.id='"+proxyVendorId+"' and (b.contactid=j.jbuyer_contact_id and b.locationtypeid=1)  and (v.company_id = vn.company_id and v.lu_location_type_id=4) and vlu.id=v.state and blu.id=b.state AND j.id = " + request.getParameter("jobId");

rehash.put("shippingVendorId",((proxyVendorId==null || proxyVendorId.equals(""))?sl.getValue("vendors","company_id",((UserProfile)session.getAttribute("userProfile")).getCompanyId(), "id"):proxyVendorId) );
rehash.put("shippingVendorCompanyId",sl.getValue("vendors","id",(String)rehash.get("shippingVendorId"), "company_id") ) ;
rehash.put("shippingAccountVendorId",sl.getValue("vendors","id",(String)rehash.get("shippingVendorId"), "shipping_account_vendor_id"));
rehash.put("capHandlingFeeFlag",sl.getValue("vendors","id",(String)rehash.get("shippingVendorId"), "cap_handling_fee_flag"));

	rehash.put("buyerContactId", "0");
	rehash.put("shipCostPolicy", "0");
	rehash.put("shipPricePolicy", "0");
	rehash.put("stdShipCost", "0");
	rehash.put("stdShipPrice", "0");
	rehash.put("jobPostDate", "");
	rehash.put("product_id", "");
  rehash.put("jobPrice", "");
	rehash.put("dropship_vendor", "");
	rehash.put("vendorContactId", "");
	rehash.put("siteHostContactId", "");
	rehash.put("siteHostGlobalMarkup", "");
	rehash.put("marcometGlobalFee", "");
	rehash.put("quantity", "");
	rehash.put("quantityShipped", "");	
	rehash.put("buyer_address", "");

Connection conn = DBConnect.getConnection();
Statement st1 = conn.createStatement();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
ResultSet rsv = st1.executeQuery(query);
while (rsv.next()) {

rehash.put("shippingVendorId",((rsv.getString("shipvendorid")==null || rsv.getString("shipvendorid").equals("0"))?proxyVendorId:rsv.getString("shipvendorid")) );
rehash.put("shippingVendorCompanyId",sl.getValue("vendors","id",(String)rehash.get("shippingVendorId"), "company_id") ) ;
rehash.put("shippingAccountVendorId",sl.getValue("vendors","id",(String)rehash.get("shippingVendorId"), "shipping_account_vendor_id"));
rehash.put("capHandlingFeeFlag",sl.getValue("vendors","id",(String)rehash.get("shippingVendorId"), "cap_handling_fee_flag"));

	rehash.put("buyerContactId", "0");
	rehash.put("shipCostPolicy", ((rsv.getString("ship_cost_policy")==null)?"0":rsv.getString("ship_cost_policy")));
	rehash.put("shipPricePolicy", ((rsv.getString("ship_price_policy")==null)?"0":rsv.getString("ship_price_policy")));
	rehash.put("stdShipCost", ((rsv.getString("std_ship_cost")==null)?"0":rsv.getString("std_ship_cost")));
	rehash.put("stdShipPrice", ((rsv.getString("std_ship_price")==null)?"0":rsv.getString("std_ship_price")));
	rehash.put("jobPostDate", ((rsv.getString("post_date")==null)?"0":rsv.getString("post_date")));
	rehash.put("product_id", ((rsv.getString("product_id")==null || rsv.getString("product_id").equals(""))?"0":rsv.getString("product_id")));
	rehash.put("jobPrice", (rsv.getString("price")==null || rsv.getString("price").equals(""))?"0":rsv.getString("price"));
  rehash.put("dropship_vendor", ((rsv.getString("dropship_vendor")==null || rsv.getString("dropship_vendor").equals(""))?"0":rsv.getString("dropship_vendor")));
	rehash.put("vendorContactId", rsv.getString("vendor_contact_id"));
	rehash.put("siteHostContactId", rsv.getString("site_host_contact_id"));
	rehash.put("siteHostGlobalMarkup", rsv.getString("site_host_global_markup"));
	rehash.put("marcometGlobalFee", rsv.getString("marcomet_global_fee"));
	rehash.put("quantity", ((rsv.getString("quantity")==null || rsv.getString("quantity").equals(""))?"0":rsv.getString("quantity")));
	rehash.put("quantityShipped", ((rsv.getString("quantity_shipped")==null || rsv.getString("quantity_shipped").equals(""))?"0":rsv.getString("quantity_shipped")));	
	rehash.put("buyer_address", rsv.getString("buyer_address"));
}

//Commented out -- if uncommented will check whether job product was fully shipped before allowing a shipment. This is now handled by the actionId.
//boolean allShipped = ( ( ((String)rehash.get("quantityShipped")).equals((String)rehash.get("quantity")) && !(((String)rehash.get("quantity")).equals("0") ))?true:false);
//shipAdjust=((shipAdjust)?true:allShipped);


//get product info
if (!((String)rehash.get("product_id")).equals("0")){
query="select max(std_subvendor_hand) max_sv_handling from product_prices pc,products p,jobs j where j.id="+request.getParameter("jobId")+" and j.product_id=p.id and p.prod_price_code=pc.prod_price_code";

ResultSet rs = st.executeQuery(query);

if (rs.next()) {
	maxSVHandling=rs.getString("max_sv_handling");
}

query="select p.inventory_initialized,p.inventory_amount,p.id,if(p.root_inv_prod_id=0,p.id,p.root_inv_prod_id) inv_id, if(p.root_inv_prod_id=0,p.prod_code,ip.prod_code) inv_prod_code,if(pc.id is null,0,pc.std_ship) shipping, if(pc.id is null,sh.default_mc_handling,pc.std_vend_hand) 'vendor_handling',format(if(pc.id is null,0,pc.std_subvendor_hand),2) 'subvendor_handling', if(pc.max_percent_shipprice=0.00,100,pc.max_percent_shipprice) as 'max_percent_shipprice', if(pc.max_percent_jobprice=0.00,100,pc.max_percent_jobprice) as 'max_percent_jobprice', (j.quantity-(if(sd.shipping_quantity is null,0,sd.shipping_quantity))) balance, concat(v.city,', ',vlu.value,' ', v.zip) ds_vendor_address, p.prod_code, p.prod_name, if(j.jwarehouse_id is null || j.jwarehouse_id='0',p.default_warehouse_id=0,j.jwarehouse_id) 'default_warehouse_id', p.inventory_product_flag from site_hosts sh,products p left join product_prices ppc on ppc.prod_price_code=p.prod_price_code left join vendors vn on vn.id='"+proxyVendorId+"'  left join products ip on p.root_inv_prod_id=ip.id, jobs j left join warehouses w on w.id=j.jwarehouse_id left join company_locations v  on v.id=w.location_id left join lu_abreviated_states vlu on  vlu.id=v.state left join shipping_data sd on sd.job_id=j.id left join product_prices pc on j.quantity=pc.quantity where j.jsite_host_id=sh.id and p.id = j.product_id  and p.prod_price_code=pc.prod_price_code AND j.id ="+request.getParameter("jobId")+" group by j.id";

rs = st.executeQuery(query);

if (rs.next()) {
	rehash.put("shipping", ((rs.getString("shipping")==null)?"0":rs.getString("shipping")));
	rehash.put("initialFlag", ((rs.getString("p.inventory_initialized")==null)?"0":rs.getString("p.inventory_initialized")));
	rehash.put("invAmount", rs.getString("p.inventory_amount"));
	rehash.put("root_inv_prod_id", rs.getString("inv_id"));
	rehash.put("root_inv_prod_code", rs.getString("inv_prod_code"));	
	rehash.put("prod_code", rs.getString("p.prod_code"));
	rehash.put("prod_name", rs.getString("prod_name"));
	rehash.put("default_warehouse_id", rs.getString("default_warehouse_id"));
	rehash.put("ds_vendor_address", ((rs.getString("ds_vendor_address") == null)?"0":rs.getString("ds_vendor_address")));
	rehash.put("balance", ((rs.getString("balance")==null)?(String)rehash.get("quantity"):rs.getString("balance")));
	rehash.put("inventory_product_flag", rs.getString("p.inventory_product_flag"));
	rehash.put("vendor_handling", ((rs.getString("vendor_handling")==null)?"0": rs.getString("vendor_handling")));
	rehash.put("subvendor_handling", ((rs.getString("subvendor_handling")==null || rs.getString("subvendor_handling").equals("0.00"))?maxSVHandling: rs.getString("subvendor_handling")));
  rehash.put("max_percent_jobprice", ((rs.getString("max_percent_jobprice")==null || rs.getString("max_percent_jobprice").equals("0"))?"100": rs.getString("max_percent_jobprice")));
  rehash.put("max_percent_shipprice", ((rs.getString("max_percent_shipprice")==null || rs.getString("max_percent_shipprice").equals("0"))?"100": rs.getString("max_percent_shipprice")));
  maxSVHandling= ((rs.getString("subvendor_handling")==null || rs.getString("subvendor_handling").equals("0.00"))?maxSVHandling: rs.getString("subvendor_handling"));

}else{
	rehash.put("shipping", "0");
	rehash.put("initialFlag", "0");
	rehash.put("root_inv_prod_id", "0");
	rehash.put("root_inv_prod_code", "");	
	rehash.put("prod_code", "");
	rehash.put("prod_name", "");
	rehash.put("default_warehouse_id", "");
	rehash.put("ds_vendor_address", "");
	rehash.put("balance", "0");
	rehash.put("inventory_product_flag", "0");
	rehash.put("vendor_handling", "5");
	rehash.put("subvendor_handling", "0");
  rehash.put("max_percent_jobprice", "100");
  rehash.put("max_percent_shipprice", "100");
}
}else{
	rehash.put("shipping", "0");
	rehash.put("initialFlag", "0");
	rehash.put("root_inv_prod_id", "0");
	rehash.put("root_inv_prod_code", "");	
	rehash.put("prod_code", "");
	rehash.put("prod_name", "");
	rehash.put("default_warehouse_id", "");
	rehash.put("ds_vendor_address", "");
	rehash.put("balance", "0");
	rehash.put("inventory_product_flag", "0");
	rehash.put("vendor_handling", "5");
	rehash.put("subvendor_handling", "0");
  rehash.put("max_percent_jobprice", "100");
  rehash.put("max_percent_shipprice", "100");
	
	completeAction="100";
	openAction="101";
}

//get inventory information.
//NOTE: Initialize the amount on hand to the amount at all warehouses for this product. For future: If user chooses a different warehouse need to change the amount on hand.
//check to see if there was ever an initial inventory adjustment, else don't get inventory amount.
try{
if (!((String)rehash.get("product_id")).equals("0")){
	query = "select sum(adjustment_action) invAction from inventory where root_inv_prod_id='"+(String)rehash.get("root_inv_prod_id")+"'";
	ResultSet rsf = st2.executeQuery(query);
	if (rsf.next()) {
		invInitialFlag=((rsf.getString("invAction")==null || rsf.getString("invAction").equals("0"))?"false":"true");
	}
}
}catch(Exception e){
	invInitialFlag="false";
}
//get warehouse info if productid
int invAmount=0;
String warehouseSelect1="";
String warehouseSelect2="";
String warehouseSelect="";
String warehouseSelect2S="";
	query="";	
boolean continueFl=false;
try{	
	continueFl=!(((String)rehash.get("initialFlag")).equals("0"));
}catch (Exception e){
	continueFl=false;
}
if (!((String)rehash.get("product_id")).equals("0")){
	if(continueFl){ //only check for product warehouses if the inventory was initialized
		//Get the warehouse from the inventory record for the product
		query="select  '1' as type, p.id 'product_id', concat(v.city,', ',vlu.value,' ', v.zip) vendor_address,i.warehouse_id warehouse_id, sum(i.amount) balance, concat(c.company_name,',',v.address1,',',v.city,', ',vlu.value,' ', v.zip,': ',sum(i.amount)) warehouse, v.id  from inventory i left join warehouses w on w.id=i.warehouse_id, jobs j,lu_abreviated_states vlu, companies c, company_locations v ,products p where v.id=w.location_id and c.id=v.company_id  and vlu.id=v.state  and i.root_inv_prod_id =if(p.root_inv_prod_id=0,p.id, p.root_inv_prod_id)  and p.id=j.product_id AND j.id ="+request.getParameter("jobId")+" group by j.product_id union ";
	}
	
	//Get the warehouse from the dropship_vendor warehouse location
query+="select '2' as type, p.id 'product_id', concat(v.city,', ',vlu.value,' ', v.zip) vendor_address,w.id warehouse_id, 0 as balance, concat(c.company_name,',',v.address1,',',v.city,', ',vlu.value,' ', v.zip,': N/A') warehouse, v.id  from jobs j,lu_abreviated_states vlu, companies c, company_locations v left join warehouses w on v.id=w.location_id , products p, vendors vn where p.id = j.product_id and (vn.id=j.dropship_vendor) and c.id=vn.company_id  and v.company_id=c.id and vlu.id=v.state  AND j.id ="+request.getParameter("jobId")+"  and v.lu_location_type_id=4 ";

	//Get the warehouse from the warehouse on the product price code record dropship vendor, or the product record
query+=" union select '3' as type, p.id 'product_id', concat(v.city,', ',vlu.value,' ', v.zip) vendor_address,w.id warehouse_id, 0 as balance, concat(c.company_name,',',v.address1,',',v.city,', ',vlu.value,' ', v.zip,': N/A') warehouse, v.id  from jobs j,lu_abreviated_states vlu, companies c, warehouses w left join company_locations v on v.id=w.location_id, products p, vendors vn where if(p.default_warehouse_id<>'0',w.id=p.default_warehouse_id,vn.default_warehouse_id=w.id) and p.id = j.product_id and (vn.id=j.dropship_vendor) and c.id=vn.company_id  and v.company_id=c.id and vlu.id=v.state  AND j.id ="+request.getParameter("jobId")+"  and v.lu_location_type_id=4 ";

	//Get the warehouse from the warehouse on the job record
query+=" union select '4' as type, p.id 'product_id', concat(v.city,', ',vlu.value,' ', v.zip) vendor_address,w.id warehouse_id, 0 as balance, concat(c.company_name,',',v.address1,',',v.city,', ',vlu.value,' ', v.zip,': N/A') warehouse, v.id  from jobs j left join warehouses w on j.jwarehouse_id=w.id left join company_locations v on w.location_id=v.id ,lu_abreviated_states vlu, companies c, products p, product_price_codes ppc,vendors vn where p.id = j.product_id and p.prod_price_code=ppc.prod_price_code and (vn.id=j.vendor_id) and c.id=vn.company_id  and w.company_id=c.id and vlu.id=v.state AND j.id ="+request.getParameter("jobId")+" and v.lu_location_type_id=4 ";


 // Get the warehouse from the proxy vendor warehouse locations (the user currently logged in and shipping the product)
query+=" union select '5' as type, p.id 'product_id', concat(v.city,', ',vlu.value,' ', v.zip) vendor_address,w.id warehouse_id, 0 as balance, concat(c.company_name,',',v.address1,',',v.city,', ',vlu.value,' ', v.zip,': N/A') warehouse, v.id  from jobs j,lu_abreviated_states vlu, companies c, company_locations v left join warehouses w on w.location_id=v.id , products p, product_price_codes ppc,vendors vn where p.id = j.product_id and p.prod_price_code=ppc.prod_price_code and (vn.id='"+proxyVendorId+"') and c.id=vn.company_id  and v.company_id=c.id and vlu.id=v.state AND j.id ="+request.getParameter("jobId")+" and v.lu_location_type_id=4 group by vendor_address order by type ";

ResultSet rs = st.executeQuery(query);
 warehouseSelect1="<select class='lineitems' name='warehouse_select' ><option value='0' >[Choose Warehouse]</option>";
 warehouseSelect2="";
 warehouseSelect="";
 warehouseSelect2S="";
int warehousesFound=0;
String sltStr="";
while (rs.next()) {
  if (rs.getString("warehouse_id")!=null && wareHash.get(rs.getString("warehouse_id"))==null){
	wareHash.put(rs.getString("warehouse_id"),rs.getString("warehouse"));
	if (rs.getString("type").equals("4")){
		sltStr="Selected";
		rehash.put("vendor_address", rs.getString("vendor_address"));
		//rehash.put("ds_vendor_address", rs.getString("vendor_address"));
	}else if  (rs.getString("type").equals("2") && sltStr.equals("")){
		sltStr="Selected";
		rehash.put("vendor_address", rs.getString("vendor_address"));
		//rehash.put("ds_vendor_address", rs.getString("vendor_address"));		
	}else if  (rs.getString("type").equals("3") && sltStr.equals("")){
		sltStr="Selected";
		rehash.put("vendor_address", rs.getString("vendor_address"));
		//rehash.put("ds_vendor_address", rs.getString("vendor_address"));		
	}else{
	sltStr="";	
	}
	warehousesFound++;
	if(warehousesFound==1){
		warehouseSelect2="<option value='"+rs.getString("warehouse_id")+"' "+sltStr+" >"+rs.getString("warehouse")+"</option>";
		warehouseSelect2S="<select class='lineitems' name='warehouse_select' Selected><option value='"+rs.getString("warehouse_id")+"' Selected>"+rs.getString("warehouse")+"</option>";
	}else{
		warehouseSelect+="<option value='"+rs.getString("warehouse_id")+"' "+sltStr+" >"+rs.getString("warehouse")+"</option>";
	}
  }
}
	if (warehousesFound>1){
		warehouseSelect=warehouseSelect1+warehouseSelect2+warehouseSelect;
	}else{
		warehouseSelect=warehouseSelect2S+warehouseSelect;
	}
	warehouseSelect+="</select>";
}

%><html>
<head>
  <title><%=((shipAdjust)?"Shipping Adjustment":"Interim Shipping")%></title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
<script type="text/javascript" src="/javascripts/jscalendar/calendar.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/calendar-setup.js"></script>
<script>
  function calculateHandlingFee() {
<%
if(editor){
%>	if(document.forms[0].byPassMCFeeCheck.checked){
  		updateShipPrices(<%=((shipAdjust)?"0":(String)rehash.get("marcometGlobalFee"))%>, 0, 0, 1);
  		return;
  	}<%
 }%>  	
  	if ( Math.round(document.forms[0].cost.value)== 0) {
    	document.forms[0].handling.value = '0';<%
if(!(editor)){
	%>	document.getElementById("MCFee").innerHTML='.00';<%
}%>
    	updateShipPrices(<%=((shipAdjust)?"0":(String)rehash.get("marcometGlobalFee"))%>, 0, 0, 1);
    	return;
    }
    
    var jobPrice = parseFloat('<%= (String)rehash.get("jobPrice")%>');
    var shipPrice = Math.round(document.forms[0].cost.value * 100)/100;
    var svFee = parseFloat('<%= (String)rehash.get("subvendor_handling")%>');
    var mcFee = parseFloat('<%= (String)rehash.get("vendor_handling")%>');
    var maxPercentJobPrice = parseFloat('<%= (String)rehash.get("max_percent_jobprice")%>');
    var maxPercentShipPrice = parseFloat('<%= (String)rehash.get("max_percent_shipprice")%>');
    var maxJobPrice = jobPrice * (maxPercentJobPrice / 100);
    var mcFee1 = mcFee2 = 0;

    // Test 1 (Total ShipPrice not more than max% of JobPrice due to MCFee)..
    if ((shipPrice + svFee + mcFee) < maxJobPrice) {
      mcFee1 = mcFee;
    }
    else if ((shipPrice + svFee) >= maxJobPrice) {
      mcFee1 = 0;
    }
    else {
      mcFee1 = maxJobPrice - (shipPrice + svFee);
    }

    // Test 2 (MCFee not more than max% of Total ShipPrice)..
    if ((mcFee / (shipPrice + svFee + mcFee)) <= (maxPercentShipPrice / 100)) {
      mcFee2 = mcFee;
    }
    else if ((mcFee / (shipPrice + svFee + mcFee)) > (maxPercentShipPrice / 100)) {
      mcFee2 = (shipPrice + svFee) * ((maxPercentShipPrice / 100) / (1 - (maxPercentShipPrice / 100)));
    }

    var handling = Math.round(Math.min(mcFee1, mcFee2)*100)/100;
    document.forms[0].handling.value = handling;<%
if(!(editor)){
	%>	document.getElementById("MCFee").innerHTML=formatCurrency(handling);<%
}%>
    updateShipPrices(<%=((shipAdjust)?"0":(String)rehash.get("marcometGlobalFee"))%>, 0, 0, 1);
  }

	function updateShipPrices(marcometMarkup, change, markup, edit) {
			var maxSubVendorHandling=parseFloat('<%=(String)rehash.get("subvendor_handling")%>');
		<%if(((String)rehash.get("capHandlingFeeFlag")).equals("1")){
			%>if (document.forms[0].svhandling.value>0 && document.forms[0].svhandling.value > maxSubVendorHandling){
				alert('The maximum allowable handling fee for this shipment is $<%=df1.format(Double.parseDouble(maxSVHandling))%>. Your handling has been adjusted accordingly.');
				document.forms[0].svhandling.value='<%=df1.format(Double.parseDouble(maxSVHandling))%>';
				document.forms[0].svhandling.value.focus;
			}
	        <%}%>var handling = Math.round(document.forms[0].handling.value*100)/100;
	        var svhandling = Math.round(document.forms[0].svhandling.value*100)/100;
	        var price = Math.round(document.forms[0].cost.value * 100)/100 +handling+svhandling;
<%if (shipAdjust){%>if (price>0){
		        	alert("Are you sure you want to enter a positive adjustment? This will increase the shipping cost owed to vendor.");
	        }<%}%>
	        document.getElementById('price').innerHTML= formatCurrency(Math.round(price * 100) / 100);
	        document.forms[0].price.value= roundCurrency(price);

	}	
	
	function SubmitForm(actionId) {
		calculateHandlingFee();
		document.forms[0].nextStepActionId.value = actionId;
		document.forms[0].submit();
	}
</script>
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body class="body" onLoad="MM_preloadImages('/images/buttons/submitover.gif','/images/buttons/cancelbtover.gif');document.forms[0].cost.focus();" background="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/images/back3.jpg">
<form method="post" action="/servlet/com.marcomet.sbpprocesses.ProcessJobSubmit"><%
//<!--form method="post" action="/servlet/com.marcomet.sbpprocesses.InterimShipmentInvServlet"-->
%><p class="Title"><%=((shipAdjust)?"Shipping Adjustment":"Interim Shipping")%></p>
<jsp:include page="/includes/JobDetailHeader.jsp" flush="true"><jsp:param  name="jobId" value="<%=request.getParameter("jobId")%>" /></jsp:include>
<%

String sqlVendorDD = "SELECT id 'value', notes 'text' FROM vendors c  where subvendor=1 ORDER BY notes"; 
if (!editor){%><input type=hidden name="shippingVendorId" value="<%=(String)rehash.get("shippingVendorId")%>"><input type=hidden name="shippingAccountVendorId" value="<%=(String)rehash.get("shippingAccountVendorId")%>" ><input type=hidden name="subvendorId" value="<%=(String)rehash.get("dropship_vendor")%>" ><%

}

if (!(shipAdjust)){%> <table border="1" cellpadding="5" cellspacing="0" >
    <tr> 
		<td class="minderheader">Shipped To:</td><td class="minderheader">Shipped From:</td><td class="minderheader">Shipping Date:</td><td class="minderheader" >Method:</td><td class="minderheader">Reference/Tracking #</td>
	</tr>
	<tr>
      <td><input class="lineitems" type="text"  onFocus="this.select()" name="shippedTo" value="<%=(String)rehash.get("buyer_address")%>"></td>
      <td><input class="lineitems" type="text"  onFocus="this.select()" name="shippedFrom" value="<%=(String)rehash.get("ds_vendor_address")%>"></td>
      <td class="label" valign='top'><input type="hidden" name="adjdate" id="f_adjdate_d"><span class="lineitemsright" id="show_d">Choose Ship Date</span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c"
			     style="cursor: pointer; border: 1px solid red;"
			     title="Date selector"
			     onmouseover="this.style.background='red';"
			     onmouseout="this.style.background=''" />
				<script type="text/javascript">
				    Calendar.setup({
				        inputField     :    "f_adjdate_d",
				        ifFormat       :    "%Y-%m-%d",
				        displayArea    :    "show_d",
				        daFormat       :    "%A, %m-%d-%Y",
				        button         :    "f_trigger_c",
				        align          :    "BR",
				        singleClick    :    true
				    });
					var d=new Date()
					var aweekday=new Array(7)
					aweekday[0]="Sunday"
					aweekday[1]="Monday"
					aweekday[2]="Tuesday"
					aweekday[3]="Wednesday"
					aweekday[4]="Thursday"
					aweekday[5]="Friday"
					aweekday[6]="Saturday"
					document.forms[0].adjdate.value=d.getFullYear()+"-"+ (d.getMonth()+1)+"-"+d.getDate();
					document.getElementById('show_d').innerHTML=aweekday[d.getDay()]+", "+ (d.getMonth()+1)+"-"+d.getDate()+"-"+d.getFullYear();
				</script>
	  </td>
		<td><input class="lineitems" type="text"  onFocus="this.select()" name="method" value="UPS Ground"></td>
		<td><input class="lineitems" type="text"  onFocus="this.select()" name="reference"></td>
	</tr>
</table><%}else{%>
<input type="hidden" name="method" value="">
<input type="hidden" name="reference">
<input type="hidden" name="shippedTo" value="">
<input type="hidden" name="shippedFrom" value="">
<input type="hidden" name="adjdate" id="f_adjdate_d">
<script type="text/javascript">
	var d=new Date();
	document.forms[0].adjdate.value=d.getFullYear()+"-"+ (d.getMonth()+1)+"-"+d.getDate();
</script><%}%>
<br />
<table border="0">
  <tr>
    <td valign='top'>
    <table border="1" cellpadding="5" cellspacing="0" >
      <tr>
        <td colspan=2><div class="subtitle"><%=((shipAdjust)?"Cost Adjustments:":"Shipping Cost:")%></div><span class='body'>
        <%=((rehash.get("shipCostPolicy").toString().equals("1"))?"Note: Shipping Cost Included<br>":"")%>
        <%=((rehash.get("shipCostPolicy").toString().equals("2"))?"Note: Standard Shipping Cost of $"+rehash.get("stdShipCost").toString()+" Applies<br>":"")%>
        </span>
            <table border="1" cellpadding="5" cellspacing="0" width=100%>
              <tr><td class="minderheaderright">Freight/Carrier Cost (e.g. UPS)</td>
                <td align="right" class="body">$
                    <input class="lineitemsright"  type="text"  onFocus="this.select()" size="8" name="cost" onChange="calculateHandlingFee();" value="<%=df1.format(Double.parseDouble((String)rehash.get("shipping")))%>"></td>
           <%if (editor){%>         <td class=lineitems>Reimburse to:<formtaglib:SQLDropDownTag dropDownName="shippingAccountVendorId" sql="<%= sqlVendorDD %>" selected="<%=(String)rehash.get("shippingAccountVendorId")%>"  extraCode="" /><input type=hidden name="subvendorId" value="<%=(String)rehash.get("dropship_vendor")%>"><%}%></td>
              </tr>
               <tr>
                <td class="minderheaderright">Warehouse Handling Fee</td>
                <td align="right" class="body">$<input class="lineitemsright" type="text"  onFocus="this.select()" size="7" name="svhandling" value="<%=((shipAdjust)?"0":df1.format(Double.parseDouble((String)rehash.get("subvendor_handling"))))%>" onChange="updateShipPrices(<%=((shipAdjust)?"0":(String)rehash.get("marcometGlobalFee"))%>, 0, 0, 1)" ></td><%if (editor){%><td class=lineitems>Pay To: <formtaglib:SQLDropDownTag dropDownName="shippingVendorId" sql="<%= sqlVendorDD %>" selected="<%=(String)rehash.get("shippingVendorId")%>"  extraCode="" /></td><%}%>
	              </tr>
              <tr>
                <td class="minderheaderright">Order Processing Fee</td>
                <td align="right" class="body"><%if (editor){%><input class="lineitemsright" type="text"  onFocus="this.select()" size="7" name="handling" value="<%=((shipAdjust)?"0":df1.format(Double.parseDouble((String)rehash.get("vendor_handling"))))%>" onChange="updateShipPrices(<%=((shipAdjust)?"0":(String)rehash.get("marcometGlobalFee"))%>, 0, 0, 1)" readOnly><td class=lineitems><input type="checkbox" name="byPassMCFeeCheck" value="true" onclick="if(this.checked){document.forms[0].handling.readOnly=false;}else{}">Turn off Order Processing Fee Calculation</td> <%}else{%><span id='MCFee'><%=((shipAdjust)?"0":df1.format(Double.parseDouble((String)rehash.get("vendor_handling"))))%></span><input type="hidden"  name="handling" value="<%=((shipAdjust)?"0":df1.format(Double.parseDouble((String)rehash.get("vendor_handling"))))%>" ><%}%></td>
              </tr>
              <tr><%if (rehash.get("shipPricePolicy").toString().equals("1") || rehash.get("shipPricePolicy").toString().equals("2")){
               %><td class="body" colspan=3><%=((rehash.get("shipPricePolicy").toString().equals("1"))?"Note: Shipping Price Included<br>":"")%>
        <%=((rehash.get("shipPricePolicy").toString().equals("2"))?"Note: Standard Shipping Price of $"+rehash.get("stdShipPrice").toString()+" Applies<br>":"")%>
               <div id="price" style="display:none;">0</div>
                    <input type="hidden" name="price" value="0"></td><%
               }else{
               	%><td class="minderheaderright">Total Billable</td>
                <td align="right" class="body"><div id="price">0</div>
                    <input type="hidden" name="price" value="0"></td><%
               }%>
              </tr>
          </table></td>
      </tr>
    </table></td>
<td width=1>&nbsp;&nbsp;&nbsp;</td>
    <td valign="top">
  <%if (editor){
  %></td></tr>
  <tr><td colspan=4><%
  }
          if(!(shipAdjust)){
    %><table border="1" cellpadding="5" cellspacing="0" >
      <tr>
        <td colspan=2><span class="subtitle">Shipping Quantities:</span><%
		if (!((String)rehash.get("product_id")).equals("0")){
            %><table border="1" cellpadding="5" cellspacing="0" width=100%>
              <tr>
                <td class="minderheaderright">Product code:</td>
                <td class="minderheaderright">Product Name:</td>
              </tr>
              <tr>
                <td align="right" class="lineitems"><%=(String)rehash.get("prod_code")%></td>
                <td align="right" class="lineitems"><%=(String)rehash.get("prod_name")%></td>
              </tr>
          </table><%}%></td>
      </tr>
      <tr>
        <td  class="minderheaderright">Quantity Ordered:</td>
        <td align="right" class="lineitems"><%=(String)rehash.get("quantity")%></td>
      </tr>
      <tr>
        <td class="minderheaderright">Balance to Ship:</td>
        <td align="right" class="lineitems"><%=(String)rehash.get("balance")%></td>
      </tr><%
      %><tr>
        <td  class="minderheaderright">Quantity this Shipment:</td>
        <td align="right" class="lineitems"><input type="text"  onFocus="this.select()" name="quantity" value="<%=(String)rehash.get("balance")%>" size=10 class="lineitemsright"></td>
      </tr><%
		if (rehash.get("inventory_product_flag").toString().equals("1")){
      %><tr>
        <td class="minderheaderright">Quantity in Stock:</td>
        <td align="right" class="lineitems"><div align="right"><%=((invInitialFlag.equals("true"))?(String)rehash.get("invAmount"):"Inventory Count not yet Initialized.")%></div></td>
      </tr><%}%>
    </table><%
      }else{
      %><input type=hidden name="quantity" value="0"><%
      }
%></td></tr><%
if (!(shipAdjust) && !((String)rehash.get("product_id")).equals("0")){
%></table><table><tr><td  class="minderheaderright">Ship from warehouse:</td>
    <td align="right" class="lineitems" colspan=2><input type='hidden' name='warehouse_id' value='<%=(String)rehash.get("default_warehouse_id")%>'><%=warehouseSelect%></td>
  </tr><%}else{%><tr><td><input type='hidden' name='warehouse_id' value='0'></td></tr><%}%>
  <tr>
    <td colspan="3"><p><span class="subtitle"><%=((shipAdjust)?"Reason for Adjustment":"Description of Shipment / Item(s) shipped:")%></span><br>
          <textarea class="lineitems" cols="70" rows=3 name="description"><%=((shipAdjust)?"":((((String)rehash.get("product_id")).equals("0"))?"":(String)rehash.get("prod_code")+" / "+(String)rehash.get("prod_name")))%></textarea>
      </p></td>
    </tr>
<tr><td colspan="3"><br /><br />
	  <table border="0" width="70%" align="center">
	  <tr>
	      <td> 
	        <div align="center"><a href="<%=((closeOnExit)?"javascript:window.close();":"/minders/JobMinderSwitcher.jsp")%>"class="greybutton">Cancel</a></div>
	      </td>
	    <td>&nbsp;</td><%if(!shipAdjust){
	     %><td> <div align="center"><a href="javascript:SubmitForm('<%=completeAction%>')"class="greybutton">Process Shipment &amp; Mark Job Complete</a></div></td>
	      <td> <div align="center"><a href="javascript:SubmitForm('<%=openAction%>')"class="greybutton">Process Shipment &amp; Leave Job Open</a></div></td>
	  <%}else{%><td> <div align="center"><a href="javascript:SubmitForm('102')"class="greybutton">Apply Adjustment</a></div></td><%}%></tr></table></td></tr></table>
<input type="hidden" name="root_inv_prod_id" value="<%=(String)rehash.get("root_inv_prod_id")%>">
<input type="hidden" name="root_inv_prod_code" value="<%=(String)rehash.get("root_inv_prod_code")%>">
<input type="hidden" name="adjustment_type_id" value="1">
<input type="hidden" name="adjustment_action" value="0">
<input type="hidden" name="job_post_date" value="<%=(String)rehash.get("jobPostDate")%>" >
<input type="hidden" name="adjustment_flag" value="<%=(( ((String)rehash.get("jobPostDate")).equals("0"))?"0":"1")%>" >
<input type="hidden" name="inventory_product_flag" value="<%=(String)rehash.get("inventory_product_flag")%>">
<input type="hidden" name="jobId" value="<%=request.getParameter("jobId")%>">
<input type="hidden" name="productId" value="<%=(String)rehash.get("product_id")%>">
<input type="hidden" name="contactId" value="<%=((UserProfile)session.getAttribute("userProfile")).getContactId()%>">
<input type="hidden" name="$$Return" value="<%=((!(closeOnExit))?"[/minders/JobMinderSwitcher.jsp]":"<script>"+((request.getParameter("refreshOpener")!=null)?"":"parent.window.opener.location.reload();")+" setTimeout('close()',500);</script>")%>">
<input type="hidden" name="shippingStatus" value="<%=((shipAdjust)?"adjustment":"interim")%>">
<input type="hidden" name="fee" value="0">
<input type="hidden" name="nextStepActionId" value="">
<input type="hidden" name="percentage" value="<%= Double.parseDouble((String)rehash.get("siteHostGlobalMarkup")) * 100 %>">
<input type="hidden" name="mu" value="0">
</form>
<%if (!(shipAdjust)){%><script>updateShipPrices(<%=(String)rehash.get("marcometGlobalFee")%>, 0, 0, 1);</script><%}%>
</body>
</html><%
try { st.close(); } catch (Exception e) {}
try { st1.close(); } catch (Exception e) {}
try { st2.close(); } catch (Exception e) {}
try { conn.close(); } catch (Exception e) {}

%>