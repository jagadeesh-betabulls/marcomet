<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%@ include file="/includes/SessionChecker.jsp" %>
<%SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
DecimalFormat nf = new DecimalFormat("#,###");

String siteHostRoot=((request.getParameter("siteHostRoot")==null)?(String)session.getAttribute("siteHostRoot"):request.getParameter("siteHostRoot"));
%><html>
<head>
  <title>Update Inventory</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link rel="stylesheet" href="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
<script type="text/javascript" src="/javascripts/jscalendar/calendar.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/calendar-setup.js"></script>
<script type="text/javascript" src="/javascripts/mainlib.js"></script>
<style>.toggle{margin: 0px 20px 0px 20px;display: none;}</style>
<%

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
String productId=((request.getParameter("productId")==null || request.getParameter("productId").equals(""))?"0":request.getParameter("productId"));
String productCode=((request.getParameter("productCode")==null)?"":request.getParameter("productCode"));
String productFilter=((productId.equals("0"))?" p.prod_code='"+productCode+"' ":" p.id="+productId);
String jobId=((request.getParameter("jobId")==null)?"0":request.getParameter("jobId"));
String quantity=((request.getParameter("quantity")==null)?"0":request.getParameter("quantity"));
String notes=((request.getParameter("notes")==null)?"Manual Adjustment":request.getParameter("notes"));
String adjType=((request.getParameter("amount")==null || request.getParameter("amount").equals(""))?"0":request.getParameter("amount"));
String adjDate=((request.getParameter("adjdate")==null)?"":request.getParameter("adjdate"));
String adjDateStr = ((request.getParameter("amount")==null || request.getParameter("amount").equals(""))?"Now()":"'"+request.getParameter("amount")+"'");
String whId=((request.getParameter("amount")==null || request.getParameter("amount").equals(""))?"0":request.getParameter("amount"));

String query="";
if (!(jobId.equals("0"))){
	query = "Select product_id from jobs where id="+jobId;
	ResultSet rs1 = st.executeQuery(query);
	if (rs1.next()) {
		productId=((rs1.getString("product_id")==null || rs1.getString("product_id").equals(""))?"0":rs1.getString("product_id"));
	}
}
if (productId.equals("0") && productCode.equals("") ){
	
	%></head><body><div class='title'>Enter Product ID or Code</div><%
}else{
	//If this is a submission process the inventory transaction 
		if (request.getParameter("submitted")!=null && request.getParameter("submitted").equals("yes")){
			if (!(request.getParameter("quantity").equals("")) && !(request.getParameter("quantity") == null)) {
				try {
					if (conn == null) {						
						conn = DBConnect.getConnection();
						st = conn.createStatement();
					}
					String shipId="";
					if (request.getParameter("adjustment_type_id")!=null && request.getParameter("adjustment_type_id").equals("1")){
						String shipSQL="select max(id) from shipping_data where job_id='"+request.getParameter("jobId")+"' and date='"+request.getParameter("adjdate")+"'";
						ResultSet rs = st.executeQuery(shipSQL);
						if (rs.next()){
							shipId=rs.getString(1);
						}
					}
					String userid = (String)session.getAttribute("contactId");
					String quantitySign=((request.getParameter("adjustment_type_id")!=null && request.getParameter("adjustment_type_id").equals("2"))?"":"-");
					query = "insert into inventory (product_id,root_inv_prod_id,root_inv_prod_code,adjustment_type_id,amount,adjustment_date,adjustor_contact_id,warehouse_id,adjustment_action,adjustment_notes,job_id,ship_id) values (?,?,?,?,?,?,?,?,?,?,?,?)";
					PreparedStatement inventory = conn.prepareStatement(query);
					inventory.clearParameters();
					inventory.setString(1, request.getParameter("productId"));
					inventory.setString(2, request.getParameter("root_inv_prod_id"));
					inventory.setString(3, request.getParameter("root_inv_prod_code"));
					inventory.setString(4, request.getParameter("adjustment_type_id"));
					inventory.setString(5, quantitySign+request.getParameter("quantity"));
					inventory.setString(6, request.getParameter("adjdate"));
					inventory.setString(7, request.getParameter("contactId"));
					inventory.setString(8, request.getParameter("warehouse_id"));
					inventory.setString(9, request.getParameter("adjustment_action"));
					inventory.setString(10, request.getParameter("notes"));
					inventory.setString(11, ((request.getParameter("jobId")==null)?"":request.getParameter("jobId")) );
					inventory.setString(12, shipId);
					inventory.executeUpdate();
					%><jsp:include page="/minders/workflowforms/CheckProducts.jsp" >
						<jsp:param name="productId" value="<%=productId%>" />
					</jsp:include><%
				} catch(Exception ex) {
					throw new Exception("Error in ProcessInventory " + ex.getMessage());
				} finally {
					
				}
			}
		}
	
String invInitialFlag="false";
String prod_line_id = "";
String company_id = "";
String status_id = "";
String prod_code = "";
String root_prod_code = "";
String brand_code = "";
String release = "";
String prod_price_code = "";
String taxable = "";
String prod_name = "";
String summary = "";
String detailed_description = "";
String headline = "";
String small_picurl = "";
String full_picurl = "";
String spec_diagram_picurl = "";
String product_features = "";
String demo_url = "";
String print_file_url = "";
String send_sample = "";
String send_literature = "";
String prodApp = "";
String template = "";
String show_manuals = "";
String show_drivers = "";
String show_sample_request = "";
String show_support_request = "";
String offering_id = "";
String budget_guide = "";
String price_list = "";
String sequence = "";
String build_type = "";
String brand_std_cat = "";
double inv_on_order_amount = 0;
double on_order_amount = 0;
double inventory_amount = 0;
String inventory_initialized = "0";
String reorder_trigger = "";
String default_warehouse_id = "";
String inventory_product_flag = "";
String backorder_action = "";
String backorder_notes = "";
String std_lead_time = "";
String root_inv_prod_id = "";
String root_inv_prod_code="";
String ds_vendor_address="";
String prodline_name="";
String company_name="";
String sitehost_name="";
String foundFlag="false";
String adjAction="0";
//get product info

query = "select sum(i.adjustment_action) adj_action, sh.site_host_name as sitehost_name,c.company_name company_name,pl.prod_line_name prodline_name,ip.prod_code, p.*, concat(v.city,', ',vlu.value,' ', v.zip) ds_vendor_address  from companies c,lu_abreviated_states vlu,site_hosts sh,products p  left join inventory i on i.root_inv_prod_id=p.id left join product_lines pl on pl.id=p.prod_line_id left join products ip on if(p.root_inv_prod_id=0,p.id,p.root_inv_prod_id)=ip.id left join product_prices pp on p.prod_price_code=pp.prod_price_code left join vendors vn on vn.id=pp.ds_vendor left join warehouses w on w.id=if(p.default_warehouse_id=0,if(vn.default_warehouse_id is null,66,vn.default_warehouse_id),p.default_warehouse_id) left join company_locations v on v.id=w.location_id where c.id=p.company_id AND vlu.id=v.state and "+productFilter+" and sh.company_id=p.company_id group by p.id";

//query = "select sum(i.adjustment_action) adj_action, sh.site_host_name as sitehost_name,c.company_name company_name,pl.prod_line_name prodline_name,ip.prod_code, p.*, concat(v.city,', ',vlu.value,' ', v.zip) ds_vendor_address  from companies c,lu_abreviated_states vlu,site_hosts sh,products p  left join inventory i on i.root_inv_prod_id=p.id left join product_lines pl on pl.id=p.prod_line_id left join products ip on if(p.root_inv_prod_id=0,p.id,p.root_inv_prod_id)=ip.id left join company_locations v  on v.id=p.default_warehouse_id where c.id=p.company_id AND vlu.id=v.state and "+productFilter+"  and sh.company_id=p.company_id group by p.id";

ResultSet rs = st.executeQuery(query);
if (rs.next()) {
	prod_line_id = rs.getString("prod_line_id");
	productId = rs.getString("id");
	sitehost_name = rs.getString("sitehost_name");
	prodline_name = rs.getString("prodline_name");
	company_name = rs.getString("c.company_name");
	company_id = rs.getString("company_id");
	status_id = rs.getString("status_id");
	prod_code = rs.getString("prod_code");
	productCode = rs.getString("prod_code");
	root_prod_code = rs.getString("root_prod_code");
	brand_code = rs.getString("brand_code");
	release = rs.getString("release");
	prod_price_code = rs.getString("prod_price_code");
	taxable = rs.getString("taxable");
	prod_name = rs.getString("prod_name");
	summary = rs.getString("summary");
	detailed_description = rs.getString("detailed_description");
	headline = rs.getString("headline");
	small_picurl = rs.getString("small_picurl");
	full_picurl = rs.getString("full_picurl");
	spec_diagram_picurl = rs.getString("spec_diagram_picurl");
	product_features = rs.getString("product_features");
	demo_url = rs.getString("demo_url");
	print_file_url = rs.getString("print_file_url");
	send_sample = rs.getString("send_sample");
	send_literature = rs.getString("send_literature");
	prodApp = rs.getString("application");
	template = rs.getString("template");
	show_manuals = rs.getString("show_manuals");
	show_drivers = rs.getString("show_drivers");
	show_sample_request = rs.getString("show_sample_request");
	show_support_request = rs.getString("show_support_request");
	offering_id = rs.getString("offering_id");
	budget_guide = rs.getString("budget_guide");
	price_list = rs.getString("price_list");
	sequence = rs.getString("sequence");
	build_type = rs.getString("build_type");
	brand_std_cat = rs.getString("brand_std_cat");
	inv_on_order_amount = rs.getDouble("inv_on_order_amount");
	on_order_amount = rs.getDouble("on_order_amount");
	inventory_amount = rs.getDouble("inventory_amount");
	inventory_initialized = rs.getString("Inventory_initialized");
	
	reorder_trigger = rs.getString("reorder_trigger");
	default_warehouse_id = rs.getString("default_warehouse_id");
	inventory_product_flag = rs.getString("inventory_product_flag");
	backorder_action = rs.getString("backorder_action");
	backorder_notes = rs.getString("backorder_notes");
	std_lead_time = rs.getString("std_lead_time");
	root_inv_prod_id = ((rs.getString("root_inv_prod_id").equals("0"))?rs.getString("id"):rs.getString("root_inv_prod_id"));
	adjAction = ((rs.getString("adj_action")==null || rs.getString("adj_action").equals("0"))?"1":"0");	
	root_inv_prod_code=rs.getString("ip.prod_code");	
	ds_vendor_address=rs.getString("ds_vendor_address");
	invInitialFlag=((inventory_initialized.equals("0") )?"false":"true");
	foundFlag="true";
}
if (foundFlag.equals("true")){
%></head>
<body class="body" onLoad="MM_preloadImages('/images/buttons/submitover.gif','/images/buttons/cancelbtover.gif')" background="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/images/back3.jpg">
<p class="Title">Product Information / Inventory Update for Product#<%=productId%>,<%=prod_name%></p>
<form method="post" action="/minders/workflowforms/InventoryUpdateForm.jsp"><%
///servlet/com.marcomet.sbpprocesses.ProcessJobSubmit
%><div class="subTitle">Adjust Inventory</div>
	<table border="1" cellpadding="5" cellspacing="0" >
	    <tr> <td class="minderheaderright" width=12%>Quantity in Stock</td>
	 		<td class="minderheaderright" width=6%>Quantity on Order</td>
	 		<td class="minderheaderright" width=6%>Quantity Available</td>
			<td class="minderheader" width=5%>Amount of Adjustment</td>
			<td class="minderheader" width=20%>Date<br>&nbsp;of&nbsp;Adjustment&nbsp;&nbsp;</td>
			<td class="minderheader" width=11%>Adjustment Type</td>
			<td class="minderheader" width=20%>Reason for Adjustment</td>
			<td class="minderheader" width=20%>Warehouse</td>
		</tr>
		<tr>
			<td align="right" class="lineItemsright"><div class="lineItems" align='right'><%=((inventory_initialized.equals("0"))?"Inventory Count not yet Initialized.":nf.format(inventory_amount))%></div></td>
			<td align="right" class="lineItemsright"><div align="right" class='lineItems'><%=nf.format(inv_on_order_amount)%></div></td>
			<td align="right" class="lineItemsright"><div align="right" class='lineItems'><%=nf.format(inventory_amount-inv_on_order_amount)%></div></td>
	      <td><input class="lineItemsright"  type="text"  onFocus="this.select()" size="8" name="quantity"  value="<%=quantity%>"></td>
			<td class="label" valign='top'><input type="hidden" name="adjdate" id="f_adjdate_d"><img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c"
					     style="cursor: pointer; border: 1px solid red;"
					     title="Date selector"
					     onmouseover="this.style.background='red';"
					     onmouseout="this.style.background=''" /><span class="lineItems" id="show_d"></span>
						<script type="text/javascript">
						    Calendar.setup({
						        inputField     :    "f_adjdate_d",
						        ifFormat       :    "%Y-%m-%d",
						        displayArea    :    "show_d",
						        daFormat       :    "%m-%d-%Y",
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
							document.getElementById('show_d').innerHTML=(d.getMonth()+1)+"-"+d.getDate()+"-"+d.getFullYear();
						</script>
			  </td>
			<td align="right" class="lineItemsright"><select name="adjustment_type_id"><option value="2" selected>Increase Quantity</option><option value="3">Decrease Quantity</option></td>
			<td align="left" class="lineItems"><input class="lineItems"  type="text"  onFocus="this.select()" size="40" name="notes"  value="<%=notes%>"></td>
			<td align="left" class="lineItems"><span class='lineItems'><select name="warehouse_id" class='otherminder'><%
	String sql = "SELECT id 'warehouse_id', warehouse_name 'warehousename' FROM warehouses ORDER BY warehouse_name";
	ResultSet rsWa = st.executeQuery(sql);
	while (rsWa.next()) {
		if (default_warehouse_id.equals(rsWa.getString("warehouse_id"))) { %><option selected value="<%=rsWa.getString("warehouse_id")%>" ><%=rsWa.getString("warehousename")%></option><% } else { %><option value="<%=rsWa.getString("warehouse_id")%>"><%=rsWa.getString("warehousename")%></option><% }
	}  //end loop of warehouses
	%></span></td>
	 	</tr>
	<tr><td colspan=8>
		<table border="0" width="70%" align="center">
			  <tr>
			      <td> 
			        <div align="center"><a href="javascript:popw('/popups/RecalcInventory.jsp?prodId=<%=productId%>',200,200)" class="greybutton"> Recalc Inventory Info </a></div>
			      </td>
			    <td>&nbsp;</td>			      <td> 
			        <div align="center"><a href="/minders/workflowforms/InventoryUpdateForm.jsp"class="greybutton"> Cancel / New Request </a></div>
			      </td>
			    <td>&nbsp;</td>
			      <td> <div align="center"><a href="javascript:document.forms[0].submit()"class="greybutton"> Process Inventory Change </a></div></td>
			  </tr>
			</table></td></tr>
		</table></td></tr>
	</table>
	<input type="hidden" name="root_inv_prod_id" value="<%=root_inv_prod_id%>">
	<input type="hidden" name="productId" value="<%=productId%>">
	<input type="hidden" name="productCode" value="<%=productCode%>">
	<input type="hidden" name="root_inv_prod_code" value="<%=root_inv_prod_code%>">
	<input type="hidden" name="adjustment_action" value="<%=adjAction%>">
	
	<input type="hidden" name="submitted" value="yes">
	<input type="hidden" name="inventory_product_flag" value="<%=inventory_product_flag%>">
	<input type="hidden" name="productId" value="<%=productId%>">
	<input type="hidden" name="contactId" value="<%=((UserProfile)session.getAttribute("userProfile")).getContactId()%>">
	<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
	<input type="hidden" name="nextStepActionId" value="">
	</form><span id='filtertoggle' ></span><div id='filters' class='toggle'>
	<jsp:include page="/includes/InventoryTransactionList_d.jsp" flush="true">
		<jsp:param  name="rootInvProdId" value="<%=root_inv_prod_id%>" />
	</jsp:include>
	</div>
<span id='productToggle' ></span><div id='products' class='toggle'><%
}
}%>
<jsp:include page="/popups/ProductInfo.jsp" >
		<jsp:param name="productId" value="<%=productId%>" />
		<jsp:param name="formAction" value="/minders/workflowforms/InventoryUpdateForm_d.jsp" />
</jsp:include>
<%if (productId.equals("0") && productCode.equals("")) {}else{%></div>
	<script>
		function toggleLayer(whichLayer){
			var style2 = document.getElementById(whichLayer).style;
			style2.display = style2.display=="block"? "none":"block";
		}
		function togglefilters(category,el,layer){
			var style2 = document.getElementById(layer).style;
			if (style2.display=="block"){
				document.getElementById(el).innerHTML="<a href='javascript:togglefilters(\""+category+"\",\""+el+"\",\""+layer+"\")' class=greybutton> + Show "+category+"</a>";
			}else{
				document.getElementById(el).innerHTML="<a href='javascript:togglefilters(\""+category+"\",\""+el+"\",\""+layer+"\")' class=greybutton> + Hide "+category+"</a>";
			}
			toggleLayer(layer);
		}
		document.getElementById('filtertoggle').innerHTML="<a href='javascript:togglefilters(\"Inventory Transactions\",\"filtertoggle\",\"filters\")' class=greybutton> + Show Inventory Transactions</a></div>"
		document.getElementById('productToggle').innerHTML="<a href='javascript:togglefilters(\"Product Info\",\"productToggle\",\"products\")' class=greybutton> + Show Product Info</a></div>"
	</script><%}%>
<!-- Updated 5/5/08 --></body>
</html><%
	st.close();
	st2.close();
	conn.close();
	%>