<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<%@ include file="/includes/SessionChecker.jsp" %>
<%SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings");
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
<script language="JavaScript" src="/javascripts/mainlib.js"></script><%

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
String productId=((request.getParameter("productId")==null)?"0":request.getParameter("productId"));
String jobId=((request.getParameter("jobId")==null)?"0":request.getParameter("jobId"));
String quantity=((request.getParameter("quantity")==null)?"0":request.getParameter("quantity"));
String notes=((request.getParameter("notes")==null)?"Manual Adjustment":request.getParameter("notes"));
String query="";
String completeAction="98";
String openAction="99";
if (!(jobId.equals("0"))){
	query = "Select product_id from jobs where id="+jobId;
	ResultSet rs1 = st.executeQuery(query);
	if (rs1.next()) {
		productId=((rs1.getString("product_id")==null || rs1.getString("product_id").equals(""))?"0":rs1.getString("product_id"));
	}
}
if (productId.equals("0")){
	%></head><body><div class='title'>No product ID Supplied, cannot continue.</div><%
}else{
	
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
String inv_on_order_amount = "";
String on_order_amount = "";
String inventory_amount = "0";
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
//get product info
query = "select sh.site_host_name as sitehost_name,c.company_name company_name,pl.prod_line_name prodline_name,ip.prod_code, p.*, concat(v.city,', ',vlu.value,' ', v.zip) ds_vendor_address  from companies c,lu_abreviated_states vlu,site_hosts sh,products p left join product_lines pl on pl.id=p.prod_line_id left join products ip on if(p.root_inv_prod_id=0,p.id,p.root_inv_prod_id)=ip.id left join company_locations v  on v.id=p.default_warehouse_id where c.id=p.company_id AND vlu.id=v.state and p.id = "+productId+"  and sh.company_id=p.company_id group by p.id";
ResultSet rs = st.executeQuery(query);
if (rs.next()) {
	prod_line_id = rs.getString("prod_line_id");
	sitehost_name = rs.getString("sitehost_name");
	prodline_name = rs.getString("prodline_name");
	company_name = rs.getString("c.company_name");
	company_id = rs.getString("company_id");
	status_id = rs.getString("status_id");
	prod_code = rs.getString("prod_code");
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
	inv_on_order_amount = rs.getString("inv_on_order_amount");
	on_order_amount = rs.getString("on_order_amount");
	inventory_amount = rs.getString("inventory_amount");
	inventory_initialized = rs.getString("Inventory_initialized");
	
	reorder_trigger = rs.getString("reorder_trigger");
	default_warehouse_id = rs.getString("default_warehouse_id");
	inventory_product_flag = rs.getString("inventory_product_flag");
	backorder_action = rs.getString("backorder_action");
	backorder_notes = rs.getString("backorder_notes");
	std_lead_time = rs.getString("std_lead_time");
	root_inv_prod_id = rs.getString("root_inv_prod_id");
	root_inv_prod_code=rs.getString("ip.prod_code");	
	ds_vendor_address=rs.getString("ds_vendor_address");
	invInitialFlag=((inventory_initialized.equals("0") )?"false":"true");
}
%></head>
<body class="body" onLoad="MM_preloadImages('/images/buttons/submitover.gif','/images/buttons/cancelbtover.gif')" background="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/images/back3.jpg">
<p class="Title">Product Information / Inventory Update for Product#<%=productId%>,<%=prod_name%></p>
<form method="post" action="/minders/workflowforms/InventoryUpdate.jsp"><%
///servlet/com.marcomet.sbpprocesses.ProcessJobSubmit
%><div class="subTitle">Adjust Inventory</div>
	<table border="1" cellpadding="5" cellspacing="0" >
	    <tr> <td class="minderheaderright">Quantity in Stock</td>
	 		<td class="minderheaderright">Quantity on Order</td>
			<td class="minderheader">Amount of Adjustment</td>
			<td class="minderheader">Date of Adjustment</td>
			<td class="minderheader">Adjustment Type</td>
			<td class="minderheader">Reason for Adjustment</td>
		</tr>
		<tr>
			<td align="right" class="lineitems"><div align="right"><%=((inventory_initialized.equals("0"))?"Inventory Count not yet Initialized.":inventory_amount)%></div></td>
			<td align="right" class="lineitems"><div align="right"><%=inv_on_order_amount%></div></td>
	      <td><input class="lineitemsright"  type="text"  onFocus="this.select()" size="8" name="quantity"  value="<%=quantity%>"></td>
			<td class="label" valign='top'><input type="hidden" name="adjdate" id="f_adjdate_d"><img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c"
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
						</script><span class="lineitemsright" id="show_d"></span>
			  </td>
			<td align="right" class="lineitems"><select name=""><option value="+">Increase Quantity</option><option value="-">Decrease Quantity</option></td>
			<td align="right" class="lineitems"><input class="lineitemsright"  type="text"  onFocus="this.select()" size="30" name="notes"  value="<%=notes%>"></td>
	 	</tr>
	<tr><td colspan=6>
<%if (request.getParameter("invAdjust")!=null && request.getParameter("invAdjust").equals("true")){%>		<table border="0" width="70%" align="center">
			  <tr>
			      <td> 
			        <div align="center"><a href="/minders/JobMinderSwitcher.jsp"class="greybutton">Cancel</a></div>
			      </td>
			    <td>&nbsp;</td>
			      <td> <div align="center"><a href="javascript:SubmitForm('<%=completeAction%>')"class="greybutton">Process Inventory Change</a></div></td>
			  </tr>
			</table><%}%></td></tr>
		</table></td></tr>
	</table>
	<input type="hidden" name="root_inv_prod_id" value="<%=root_inv_prod_id%>">
	<input type="hidden" name="root_inv_prod_code" value="<%=root_inv_prod_code%>">
	<input type="hidden" name="adjustment_type_id" value="2">
	<input type="hidden" name="adjustment_action" value="1">
	<input type="hidden" name="inventory_product_flag" value="<%=inventory_product_flag%>">
	<input type="hidden" name="productId" value="<%=productId%>">
	<input type="hidden" name="contactId" value="<%=((UserProfile)session.getAttribute("userProfile")).getContactId()%>">
	<input type="hidden" name="$$Return" value="[/minders/JobMinderSwitcher.jsp]">
	<input type="hidden" name="nextStepActionId" value="">
	</form>
	<br><hr><br>
		  <div class="subTitle">Product Information</div>
		<%=((rs.getString("full_picurl")==null || rs.getString("full_picurl").equals(""))?"":"<a href='/sitehosts/"+sitehost_name+"/fileuploads/product_images/"+ str.replaceSubstring(rs.getString("full_picurl")," ","%20")+"' >" )%><%=((rs.getString("small_picurl")==null || rs.getString("small_picurl").equals(""))?"":"<img src='/sitehosts/"+sitehost_name+"/fileuploads/product_images/"+ str.replaceSubstring(rs.getString("small_picurl")," ","%20") +"' border=0>")%>
<%=((rs.getString("full_picurl")==null || rs.getString("full_picurl").equals(""))?"":"</a>")%><br>
Backorder Message: 	<%
String backorderText="NONE";
String backorderaction="0";
ResultSet rsMinAmount = st.executeQuery("Select min(pp.quantity) from product_prices pp,products p where pp.prod_price_code=p.prod_price_code and  p.id="+productId);
int minAmount=0;
if (rsMinAmount.next()){
	minAmount=Integer.parseInt(rsMinAmount.getString(1));
}
rsMinAmount.close();
if (Integer.parseInt(inventory_amount) - Integer.parseInt(inv_on_order_amount) <= minAmount){ //if product is on backorder
//		backorderaction=backorder_action; //1=show notes and allow order, 2=disable order and show prod not available
		if (backorder_action.equals("2")){
			backorderText="Product Not Currently Available";						
		}else{
			backorderText=((backorder_notes.equals(""))?"Product On Backorder":backorder_notes);
		}
	}
	%><%=backorderText%>
<table border="1" cellpadding="5" cellspacing="0" >
<tr>
	<td class='minderheader'>Product Id</td><td class='lineitems'><%=productId%></td>
	<td class='minderheader'>Product Name</td><td class='lineitems'><%=prod_name%></td>
</tr><tr>
	<td class='minderheader'>Product Line Id</td><td class='lineitems'><%=prod_line_id%></td>
	<td class='minderheader'>Product Line Name</td><td class='lineitems'><%=prodline_name%></td>
</tr><tr>	
	<td class='minderheader'>Company ID</td><td class='lineitems'><%=company_id%></td>
	<td class='minderheader'>Company Name</td><td class='lineitems'><%=company_name%></td>
</tr><tr>
	<td class='minderheader'>Status ID</td><td class='lineitems'><%=status_id%></td>
	<td class='minderheader'>Release</td><td class='lineitems'><%=release%></td>
</tr><tr>	
	<td class='minderheader'>Prod Code</td><td class='lineitems'><%=prod_code%></td>
	<td class='minderheader'>Root Prod Code</td><td class='lineitems'><%=root_prod_code%></td>
</tr><tr>
	<td class='minderheader'>Prod Price Code</td><td class='lineitems'><%=prod_price_code%></td>
	<td class='minderheader'>Taxable Flag</td><td class='lineitems'><%=taxable%></td>
</tr><tr>		
	<td class='minderheader'>Brand Code</td><td class='lineitems'><%=brand_code%></td>
	<td class='minderheader'></td><td class='lineitems'></td>
</tr><tr><td colspan=4></td></tr><tr>
	<td class='minderheader'>Summary</td><td class='lineitems' colspan=3><%=summary%></td>
</tr><tr>
	<td class='minderheader'>Description</td><td class='lineitems' colspan=3><%=detailed_description%></td>
</tr><tr>	
	<td class='minderheader'>Headline</td><td class='lineitems' colspan=3><%=headline%></td>
</tr><tr>	
	<td class='minderheader'>Product Features</td><td class='lineitems' coolspan=3><%=product_features%></td>
</tr><tr>	
	<td class='minderheader'>Application</td><td class='lineitems' colspan=3><%=prodApp%></td>
</tr><tr><td colspan=4></td></tr><tr>		
	<td class='minderheader'>Offering ID</td><td class='lineitems'><%=offering_id%></td>
	<td class='minderheader'>Build Type</td><td class='lineitems'><%=build_type%></td>
</tr><tr>	
	<td class='minderheader'>Sequence in Product Lists</td><td class='lineitems'><%=sequence%></td>
	<td class='minderheader'>Brand Standard Category</td><td class='lineitems'><%=brand_std_cat%></td>
</tr><tr>		
	<td class='minderheader'>Small Pic URL</td><td class='lineitems'><%=small_picurl%></td>
	<td class='minderheader'>Full Pic URL</td><td class='lineitems'><%=full_picurl%></td>
</tr><tr>		
	<td class='minderheader'>Budget Guide</td><td class='lineitems'><%=budget_guide%></td>
	<td class='minderheader'>Price List</td><td class='lineitems'><%=price_list%></td>
</tr><tr>	
	<td class='minderheader'>Demo URL</td><td class='lineitems'><%=demo_url%></td>
	<td class='minderheader'>Print File URL</td><td class='lineitems'><%=print_file_url%></td>
</tr><tr>	
	<td class='minderheader'>Send Sample</td><td class='lineitems'><%=send_sample%></td>
	<td class='minderheader'>Send Literature</td><td class='lineitems'><%=send_literature%></td>
</tr><tr>	
	<td class='minderheader'>Spec Diagram URL</td><td class='lineitems'><%=spec_diagram_picurl%></td>
	<td class='minderheader'>Display Template</td><td class='lineitems'><%=template%></td>
</tr><tr>	
	<td class='minderheader'>Show Manuals</td><td class='lineitems'><%=show_manuals%></td>
	<td class='minderheader'>Show Drivers</td><td class='lineitems'><%=show_drivers%></td>
</tr><tr>
	<td class='minderheader'>Show Sample request</td><td class='lineitems'><%=show_sample_request%></td>
	<td class='minderheader'>Show Support Request</td><td class='lineitems'><%=show_support_request%></td>
</tr><tr><td colspan=4></td></tr><tr>
	<td class='minderheader' colspan=4>Inventory Fields</td>
</tr><tr>
	<td class='minderheader'>Inventory Product Flag</td><td class='lineitems'><%=inventory_product_flag%></td>
	<td class='minderheader'>Root Inventory Product ID</td><td class='lineitems'><%=root_inv_prod_id%></td>
</tr><tr>	
	<td class='minderheader'>Inv On Order Amount</td><td class='lineitems'><%=inv_on_order_amount%></td>
	<td class='minderheader'>On Order Amount</td><td class='lineitems'><%=on_order_amount%></td>
</tr><tr>	
	<td class='minderheader'>Inventory Initialized Flag</td><td class='lineitems'><%=inventory_initialized%></td>	
	<td class='minderheader'>Inventory Amount</td><td class='lineitems'><%=inventory_amount%></td>
</tr><tr>	
	<td class='minderheader'>Default Warehouse ID</td><td class='lineitems'><%=default_warehouse_id%></td>
	<td class='minderheader'>Default Warehouse Location</td><td class='lineitems'><%=ds_vendor_address%></td>	
</tr><tr><td colspan=4></td></tr><tr>
	<td class='minderheader' colspan=4>Backorder Fields</td>
</tr><tr>
	<td class='minderheader'>Backorder Action</td><td class='lineitems'><%=backorder_action%></td>
	<td class='minderheader'>Backorder Notes</td><td class='lineitems'><%=backorder_notes%></td>
</tr><tr>
	<td class='minderheader'>Reorder Trigger</td><td class='lineitems'><%=reorder_trigger%></td>
	<td class='minderheader'>Standard Lead Time</td><td class='lineitems'><%=std_lead_time%></td>
</tr>
</table><%}%>
</body>
</html><%
	st.close();
	conn.close();
	%>