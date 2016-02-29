<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formatter" class="com.marcomet.tools.FormaterTool" scope="page" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="page" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%@ include file="/includes/SessionChecker.jsp" %>
<html>
<head>
  <title>Product Info</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=((SiteHostSettings)session.getAttribute("siteHostSettings")).getSiteHostRoot()%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<style>.toggle{margin: 0px 20px 0px 20px;display: none;}</style>
</head><body><%


Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st1 = conn.createStatement();
Statement st2 = conn.createStatement();

String productId=((request.getParameter("productId")==null || request.getParameter("productId").equals(""))?"0":request.getParameter("productId"));
String formAction=((request.getParameter("formAction")==null || request.getParameter("formAction").equals(""))?"/popups/ProductInfo.jsp":request.getParameter("formAction"));
String productCode=((request.getParameter("productCode")==null || request.getParameter("productCode").equals(""))?"0":request.getParameter("productCode"));
String jobId=((request.getParameter("jobId")==null)?"0":request.getParameter("jobId"));
String quantity=((request.getParameter("quantity")==null)?"0":request.getParameter("quantity"));
String notes=((request.getParameter("notes")==null)?"Manual Adjustment":request.getParameter("notes"));
String query="";
String completeAction="98";
String openAction="99";
boolean editor= (((RoleResolver)session.getAttribute("roles")).roleCheck("editor") && formAction.equals("/popups/ProductInfo.jsp"));


if (!(jobId.equals("0"))){
	query = "Select product_id from jobs where id="+jobId;
	ResultSet rs1 = st.executeQuery(query);
	if (rs1.next()) {
		productId=((rs1.getString("product_id")==null || rs1.getString("product_id").equals(""))?"0":rs1.getString("product_id"));
	}
}

if (productId.equals("0") && productCode.equals("0")){
	%>
	<form method-"post" action="<%=formAction%>">
		<p class='title'>Product Information</p><p class='body'>Retrieve Product information for the following product:</p>
		Product ID:<input type='text' name='productId'><br>&nbsp;&nbsp;&nbsp;-or-<br>Product Code:<input type='text' name='productCode'><br><input type=submit value=' CONTINUE '>
	</form><%
}else{
	
String invInitialFlag="false";
String prod_line_id = "";
String company_id = "";
String status_id = "";
String prod_code = "";
String variant_code = "";
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
String download_url = "";
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
String inv_on_order_amount = "0";
String on_order_amount = "0";
String inventory_amount = "0";
String inventory_initialized = "0";
String reorder_trigger = "";
String default_warehouse_id = "";
String product_warehouse_id="";
String vendor_warehouse_id="";
String inventory_product_flag = "";
String backorder_action = "";
String backorder_notes = "";
String std_lead_time = "";
String root_inv_prod_id = "";
String invRootId = "";
String root_inv_prod_code="";
String ds_vendor_address="";
String prodline_name="";
String company_name="";
String sitehost_name="";
String internal_notes="";
String approval="";
String web_graphic_uploaded="";
String print_status="";
String show_in_primary_prod_line="";
String dropship_vendor="";
String dsVendorName="";
String ppcId="";
String ppcNotes="";
String imageComingSoon="";
String catalogText="";
String catalogScript="";
String restock_request_date="";
String backorder_ship_date="";
String default_ship_percentage="";
//get product info
String prodFilter=( (productId.equals("0") )?" p.prod_code = '"+productCode+"' ":" p.id = '"+productId+"' ");

query = "select sh.site_host_name as sitehost_name,p.id id,ppc.id 'ppcId',ppc.notes 'ppcNotes', if(ppc.dropship_vendor is null,'',ppc.dropship_vendor) 'dsVendor',if (vnc.company_name is null,'None',vnc.company_name) 'dsVendorName',c.company_name company_name,pl.prod_line_name prodline_name,ip.prod_code as root_inv_prod_code, p.*,if(p.default_warehouse_id=0,vnd.default_warehouse_id,p.default_warehouse_id) as 'warehouseId',vnd.default_warehouse_id as 'vwarehouse',p.default_ship_percentage, concat(v.city,', ',vlu.value,' ', v.zip) ds_vendor_address, if(DATE_FORMAT(ip.restock_request_date,'%m-%d-%y') is null,'',DATE_FORMAT(ip.restock_request_date,'%m-%d-%y')) 'restockRequestDate' ,if(DATE_FORMAT(ip.backorder_ship_date,'%m-%d-%y') is null,'',DATE_FORMAT(ip.backorder_ship_date,'%m-%d-%y')) 'backorderShipDate'  from companies c,products p left join product_price_codes ppc on ppc.prod_price_code=p.prod_price_code left join products ip on if(p.root_inv_prod_id=0,p.id,p.root_inv_prod_id)=ip.id left join site_hosts sh on sh.company_id=p.company_id left join product_lines pl on pl.id=p.prod_line_id left join vendors vnd on vnd.id=ppc.dropship_vendor left join companies vnc on vnd.company_id=vnc.id left join warehouses wr on wr.id=if(p.default_warehouse_id=0,vnd.default_warehouse_id,p.default_warehouse_id) left join company_locations v on v.id=wr.location_id left join lu_abreviated_states vlu on  vlu.id=v.state where c.id=p.company_id and "+prodFilter+" group by p.id";
%><!--<%=query%>--><%
ResultSet rs = st.executeQuery(query);

if (rs.next()) {
	prod_line_id = rs.getString("prod_line_id");
	default_ship_percentage=rs.getString("default_ship_percentage");
	catalogText = ((rs.getString("catalog_text")==null)?"":rs.getString("catalog_text"));
	catalogScript = ((rs.getString("catalog_script")==null)?"":rs.getString("catalog_script"));
	sitehost_name = rs.getString("sitehost_name");
	productId = rs.getString("id");
	prodline_name = rs.getString("prodline_name");
	show_in_primary_prod_line=rs.getString("show_in_primary_prod_line");
	company_name = rs.getString("c.company_name");
	company_id = rs.getString("company_id");
	status_id = rs.getString("status_id");
	prod_code = rs.getString("prod_code");
	root_prod_code = rs.getString("root_prod_code");
	variant_code = rs.getString("variant_code");
	brand_code = rs.getString("brand_code");
	release = rs.getString("release");
	prod_price_code = rs.getString("prod_price_code");
	taxable = rs.getString("taxable");
	prod_name = rs.getString("prod_name");
	summary = rs.getString("summary");
	detailed_description = rs.getString("detailed_description");
	headline = rs.getString("headline");
	small_picurl = rs.getString("small_picurl");
	download_url = rs.getString("download_url");
	imageComingSoon = rs.getString("image_coming_soon");	
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
	dropship_vendor=rs.getString("dsVendor");
	dsVendorName=rs.getString("dsVendorName");
	reorder_trigger = rs.getString("reorder_trigger");
	default_warehouse_id = rs.getString("warehouseId");
	vendor_warehouse_id = rs.getString("vwarehouse");
	product_warehouse_id = rs.getString("default_warehouse_id");
	inventory_product_flag = rs.getString("inventory_product_flag");
	backorder_action = ((rs.getString("backorder_action")==null)?"0":rs.getString("backorder_action"));
	backorder_notes = ((rs.getString("backorder_notes")==null)?"":rs.getString("backorder_notes"));
	internal_notes = ((rs.getString("internal_notes")==null)?"":rs.getString("internal_notes"));
	approval=((rs.getString("approval")==null)?"":rs.getString("approval"));
	web_graphic_uploaded=((rs.getString("web_graphic_uploaded")==null)?"":rs.getString("web_graphic_uploaded"));
	print_status=((rs.getString("print_status")==null)?"":rs.getString("print_status"));
	ppcId = rs.getString("ppcId");
	ppcNotes=((rs.getString("ppcNotes")==null)?"":rs.getString("ppcNotes"));
	std_lead_time = rs.getString("std_lead_time");
	root_inv_prod_id = rs.getString("root_inv_prod_id");
	invRootId=((rs.getString("root_inv_prod_id").equals("0"))?productId:rs.getString("root_inv_prod_id"));
	root_inv_prod_code=rs.getString("root_inv_prod_code");	
	ds_vendor_address=rs.getString("ds_vendor_address");
	restock_request_date=rs.getString("restockRequestDate");
	backorder_ship_date=rs.getString("backorderShipDate");
	invInitialFlag=((inventory_initialized.equals("0") )?"false":"true");
	
%><table border=0 width=100%><tr><td class="Title" valign=top><%if (editor){%><a href='#'  onClick="parent.window.opener.location.reload();setTimeout('close()',500);" class=greybutton> Return </a><%}%>&nbsp;Product Information for <span style="color:red"><%=prod_code%></span>, Product #<span style="color:red"><%=productId%></span>, <%=prod_name%><table border=0>	<tr><td></td></tr><tr>
		<td class='minderheader'>Summary</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Product%20Summary&primaryKeyValue=<%=productId%>&columnName=summary&tableName=products&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%><%=summary%></td>
	</tr><tr>
		<td class='minderheader'>Description</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Product%20Description&primaryKeyValue=<%=productId%>&columnName=detailed_description&tableName=products&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%><%=detailed_description%></td>
	</tr><tr>	
		<td class='minderheader'>Headline</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=2&question=Change%20Product%20Headline&primaryKeyValue=<%=productId%>&columnName=headline&tableName=products&valueType=string",500,100)'>&raquo;</a>&nbsp;<%}%><%=headline%></td>
	</tr><tr>	
		<td class='minderheader'>Product Features</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=2&question=Change%20Product%20Features&primaryKeyValue=<%=productId%>&columnName=product_features&tableName=products&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%><%=product_features%></td>
	</tr><tr>	
		<td class='minderheader'>Application</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Product%20Application&primaryKeyValue=<%=productId%>&columnName=application&tableName=products&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%><%=prodApp%></td>
	</tr><tr>	
		<td class='minderheader'>Catalog-Only Text</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Product%20Catalog%20Only%20Text&primaryKeyValue=<%=productId%>&columnName=catalog_text&tableName=products&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%><%=catalogText%></td>
	</tr>
	<tr>	
		<td class='minderheader'>Catalog-Only Javascript</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Product%20Catalog%20Only%20Javascript&primaryKeyValue=<%=productId%>&columnName=catalog_script&tableName=products&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%><%=catalogScript%></td>
	</tr>
	<tr><td></td></tr></table></td><td><%=((rs.getString("full_picurl")==null || rs.getString("full_picurl").equals(""))?"":"<a href='/sitehosts/"+sitehost_name+"/fileuploads/product_images/"+ str.replaceSubstring(rs.getString("full_picurl")," ","%20")+"' >" )%><%=((rs.getString("small_picurl")==null || rs.getString("small_picurl").equals(""))?"":"<img src='/sitehosts/"+sitehost_name+"/fileuploads/product_images/"+ str.replaceSubstring(rs.getString("small_picurl")," ","%20") +"' border=0>")%><%=((rs.getString("full_picurl")==null || rs.getString("full_picurl").equals(""))?"":"</a>")%></td></tr></table><%
String backorderText="NONE";
String backorderaction="0";
ResultSet rsMinAmount = st2.executeQuery("Select min(pp.quantity) from product_prices pp,products p where pp.prod_price_code=p.prod_price_code and  p.id="+productId);
int minAmount=0;
if (rsMinAmount.next()){
	minAmount=Integer.parseInt(((rsMinAmount.getString(1)==null)?"0":rsMinAmount.getString(1)));
}
rsMinAmount.close();
//if (Integer.parseInt(inventory_amount) - Integer.parseInt(inv_on_order_amount) <= minAmount){ //if product is on backorder
//		backorderaction=backorder_action; //1=show notes and allow order, 2=disable order and show prod not available
		if (backorder_action.equals("2")){
			backorderText="Product Not Currently Available [Default]";						
		}else if (backorder_action.equals("1")){
			backorderText=((backorder_notes.equals(""))?"Product On Backorder [Default]":backorder_notes);
		}
//	}%><table border="1" cellpadding="5" cellspacing="0" width=100%>
<tr>
	<td class='minderheader'>Product Id</td><td class='lineitems'><%=productId%></td>
	<td class='minderheader'>Product Name</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=6&question=Change%20Product%20Name&primaryKeyValue=<%=productId%>&columnName=prod_name&tableName=products&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%><%=prod_name%></td>
</tr><tr>
	<td class='minderheader'>Product Line Id</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeProdLinesDropDown.jsp?question=Change%20Product%20Line&primaryKeyValue=<%=productId%>&columnName=prod_line_id&valueFieldVal=<%=prod_line_id%>&tableName=products&brandCode=<%=brand_code%>&companyId=<%=company_id%>&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%><%=prod_line_id%></td>
	<td class='minderheader'>Show in Primary Prod Line</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeDropDown.jsp?cols=4&rows=1&question=Display%20In%20Primary%20Product%20Line&valueField=id&textField=value&valueFieldVal=<%=show_in_primary_prod_line%>&luTableName=lu_show_in_prodline&compField=1&compValue=1&orderBy=sequence&primaryKeyValue=<%=productId%>&columnName=show_in_primary_prod_line&tableName=products&valueType=int",650,150)'>&raquo;</a>&nbsp;<%}%><%=((show_in_primary_prod_line==null)?"":sl.getValue("lu_show_in_prodline","id",show_in_primary_prod_line, "value")+"["+show_in_primary_prod_line+"]")%></td></tr>
	<tr>
	<td class='minderheader'>Product Line Name</td><td class='lineitems'><%=prodline_name%></td>
</tr><td></td><tr>	
	<td class='minderheader'>Company ID</td><td class='lineitems'><%=company_id%></td>
	<td class='minderheader'>Company Name</td><td class='lineitems'><%=company_name%></td>
</tr><tr>
	<td class='minderheader'>Product Status</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeDropDown.jsp?cols=4&rows=1&question=Change%20Product%20Status&valueField=id&textField=value&valueFieldVal=<%=status_id%>&luTableName=lu_product_status&compField=1&compValue=1&orderBy=sequence&primaryKeyValue=<%=productId%>&columnName=status_id&tableName=products&valueType=int",650,150)'>&raquo;</a>&nbsp;<%}%><%=((status_id==null)?"":sl.getValue("lu_product_status","id",status_id, "value"))%></td>
	<td class='minderheader'>Release</td><td class='lineitems'><%=release%></td>
</tr><tr>	
	<td class='minderheader'>Prod Code</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=20&rows=1&question=Change%20Product%20Code&primaryKeyValue=<%=productId%>&columnName=prod_code&tableName=products&valueType=string",500,100)'>&raquo;</a>&nbsp;<%}%><%=prod_code%></td>
	<td class='minderheader'>Root Prod Code</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=4&rows=1&question=Change%20Product%20Root%20Prod%20Code&primaryKeyValue=<%=productId%>&columnName=root_prod_code&tableName=products&valueType=string",500,100)'>&raquo;</a>&nbsp;<%}%><%=root_prod_code%></td>
</tr><tr>
	<td class='minderheader'>Prod Price Code</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=20&rows=1&question=Change%20Product%20Price%20Code&primaryKeyValue=<%=productId%>&columnName=prod_price_code&tableName=products&valueType=string",500,100)'>&raquo;</a>&nbsp;<%}%><%=prod_price_code%></td>
	<td class='minderheader'>Variant Code</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=20&rows=1&question=Change%20Product%20Variant%20Code&primaryKeyValue=<%=productId%>&columnName=variant_code&tableName=products&valueType=string",500,100)'>&raquo;</a>&nbsp;<%}%><%=variant_code%></td>
</tr><tr>
	<td class='minderheader'>Brand Code</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=20&rows=1&question=Change%20Product%20Brand%20Code&primaryKeyValue=<%=productId%>&columnName=brand_code&tableName=products&valueType=string",500,100)'>&raquo;</a>&nbsp;<%}%><%=brand_code%></td>
	<td class='minderheader'>Taxable Flag</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=4&rows=1&question=Change%20Product%20Taxability&primaryKeyValue=<%=productId%>&columnName=taxable&tableName=products&valueType=string",500,100)'>&raquo;</a>&nbsp;<%}%><%=taxable%></td>
</tr><tr>		
	<td class='minderheader'>Offering ID</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Offering%20ID&primaryKeyValue=<%=productId%>&columnName=offering_id&tableName=products&valueType=string",500,100)'>&raquo;</a>&nbsp;<%}%><%=offering_id%></td>
	<td class='minderheader'>Build Type</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeDropDown.jsp?cols=4&rows=1&question=Change%20Product%20Build%20Type&valueField=id&textField=value&valueFieldVal=<%=build_type%>&luTableName=lu_build_types&compField=1&compValue=1&orderBy=sequence&primaryKeyValue=<%=productId%>&columnName=build_type&tableName=products&valueType=int",500,100)'>&raquo;</a>&nbsp;<%}%><%=((build_type==null)?"":sl.getValue("lu_build_types","id",build_type, "value"))%> [<%=build_type%>]</td>
</tr><tr>
	<td class='minderheader'>Sequence in Product Lists</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Sequence%20In%20Product%20Items&primaryKeyValue=<%=productId%>&columnName=sequence&tableName=products&valueType=string",500,100)'>&raquo;</a>&nbsp;<%}%><%=sequence%></td>
	<td class='minderheader'>Brand Standard Category</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=2&question=Change%20Product%20Brand%20Standard%20Category&primaryKeyValue=<%=productId%>&columnName=brand_std_cat&tableName=products&valueType=string",500,150)'>&raquo;</a>&nbsp;<%}%><%=brand_std_cat%></td>
</tr><tr>		
	<td class='minderheader'>Small Pic URL</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=2&question=Change%20Product%20Small%20Pic%20URL&primaryKeyValue=<%=productId%>&columnName=small_picurl&tableName=products&valueType=string",500,150)'>&raquo;</a>&nbsp;<%}%><%=small_picurl%></td>
	<td class='minderheader'>Full Pic URL</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=2&question=Change%20Product%20Large%20Pic%20URL&primaryKeyValue=<%=productId%>&columnName=full_picurl&tableName=products&valueType=string",500,150)'>&raquo;</a>&nbsp;<%}%><%=full_picurl%></td>
</tr><tr>		
	<td class='minderheader'>Use "Coming Soon" Graphic</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeDropDown.jsp?cols=60&rows=2&question=Use%20Coming%20Soon%20Graphic&valueField=id&textField=value&valueFieldVal=<%=imageComingSoon%>&luTableName=lu_no_yes&compField=1&compValue=1&orderBy=sequence&primaryKeyValue=<%=productId%>&columnName=image_coming_soon&tableName=products&valueType=int",500,150)'>&raquo;</a>&nbsp;<%}%><%=((imageComingSoon==null)?"":sl.getValue("lu_no_yes","id",imageComingSoon, "value")+"["+imageComingSoon+"]")%></td>
	<td class='minderheader'>Download File URL</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=2&question=Change%20Product%20Download%20File%20URL&primaryKeyValue=<%=productId%>&columnName=download_url&tableName=products&valueType=string",500,150)'>&raquo;</a>&nbsp;<%}%><%=download_url%></td>
</tr><tr>		
	<td class='minderheader'>Budget Guide</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=4&rows=1&question=Change%20Product%20Budget%20Guide%20File&primaryKeyValue=<%=productId%>&columnName=budget_guide&tableName=products&valueType=string",500,100)'>&raquo;</a>&nbsp;<%}%><%=budget_guide%></td>
	<td class='minderheader'>Price List</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=4&rows=1&question=Change%20Product%20Price%20List%20File&primaryKeyValue=<%=productId%>&columnName=price_list&tableName=products&valueType=string",500,100)'>&raquo;</a>&nbsp;<%}%><%=price_list%></td>
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
	<td class='minderheader'>Inventory Product Flag</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=20&rows=1&question=Change%20Inventory%20Product%20Flag&primaryKeyValue=<%=productId%>&columnName=inventory_product_flag&tableName=products&valueType=string",450,150)'>&raquo;</a>&nbsp;<%}%><%=inventory_product_flag%></td>
	<td class='minderheader'>Root Inventory Product ID</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=20&rows=1&question=Change%20Root%20Inventory%20Product%20ID&primaryKeyValue=<%=productId%>&columnName=root_inv_prod_id&tableName=products&valueType=string",450,150)'>&raquo;</a>&nbsp;<%}%><%=root_inv_prod_id%></td>
</tr><tr>	
	<td class='minderheader'>Inv On Order Amount</td><td class='lineitems'><%=inv_on_order_amount%></td>
	<td class='minderheader'>On Order Amount</td><td class='lineitems'><%=on_order_amount%></td>
</tr><tr>	
	<td class='minderheader'>Inventory Initialized Flag</td><td class='lineitems'><%=inventory_initialized%></td>	
	<td class='minderheader'>Inventory Amount</td><td class='lineitems'><%=inventory_amount%></td>
</tr><tr>	
	<td class='minderheader'>Override Vendor Warehouse ID</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Override%20WarehouseID&primaryKeyValue=<%=productId%>&columnName=default_warehouse_id&tableName=products&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%>Override Warehouse:<%=product_warehouse_id%> [Vendor Warehouse:<%=vendor_warehouse_id%>]</td>
	<td class='minderheader'>Shipping Warehouse Location</td><td class='lineitems'><%=ds_vendor_address%>  [ID #<%=default_warehouse_id%>]</td>	
</tr><tr><td colspan=4></td></tr>
<tr>	
	<td class='minderheader'>Default Shipping %</td><td class='lineitems' colspan="3"><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Default%20Shipping%20Percentage&primaryKeyValue=<%=productId%>&columnName=default_ship_percentage&tableName=products&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%><%=default_ship_percentage%></td>
</tr><tr><td colspan=4></td></tr>
<tr>
	<td class='minderheader' colspan=4>Backorder Fields</td>
</tr><tr>
	<td class='minderheader'>Backorder Action</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeDropDown.jsp?cols=4&rows=1&question=Change%20Product%20Backorder%20Action&valueField=id&textField=value&valueFieldVal=<%=backorder_action%>&luTableName=lu_backorder_actions&compField=1&compValue=1&orderBy=sequence&primaryKeyValue=<%=productId%>&columnName=backorder_action&tableName=products&valueType=int",650,150)'>&raquo;</a>&nbsp;<%}%><%=((backorder_action==null)?"":sl.getValue("lu_backorder_actions","id",backorder_action, "value")+"["+backorder_action+"]")%></td>
	<td class='minderheader'>Backorder Notes / Message</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=2&question=Change%20Product%20Backorder%20Notes&primaryKeyValue=<%=productId%>&columnName=backorder_notes&tableName=products&valueType=string",500,200)'>&raquo;</a>&nbsp;<%}%><%=backorder_notes+((backorderText.equals(backorder_notes))?"":((backorder_notes.equals(""))?"":backorder_notes+"/")+backorderText)%></td>
</tr><tr>
	<td class='minderheader'>Reorder Trigger</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=4&rows=1&question=Change%20Product%20Reorder%20Trigger&primaryKeyValue=<%=productId%>&columnName=reorder_trigger&tableName=products&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=reorder_trigger%></td>
	<td class='minderheader'>Standard Lead Time</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=1&question=Change%20Product%20Standard%20Lead%20Time&primaryKeyValue=<%=productId%>&columnName=std_lead_time&tableName=products&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=std_lead_time%></td>
</tr>
<tr>
	<td class='minderheader'>Date Root Inv Requested</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=4&rows=1&question=Change%20Product%20Date%20Requested&primaryKeyValue=<%=productId%>&columnName=restock_request_date&tableName=products&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=restock_request_date%></td>
	<td class='minderheader'>Date Root Inv Shipping</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=1&question=Change%20Product%20Backorder%20Ship%20Date&primaryKeyValue=<%=productId%>&columnName=backorder_ship_date&tableName=products&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=backorder_ship_date%></td>
</tr>
<tr><td colspan=4></td></tr><tr>
	<td class='minderheader' colspan=4>Internal Production Notes</td>
</tr>
<tr>
	<td class='minderheader'>Internal Notes</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=70&rows=10&question=Change%20Product%20Reorder%20Trigger&primaryKeyValue=<%=productId%>&columnName=internal_notes&tableName=products&valueType=string",600,500)'>&raquo;</a>&nbsp;<%}%><%=internal_notes%></td>
	<td class='minderheader'>Client Approval</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=20&rows=1&question=Change%20Product%20Approval<br><u>Pending or Approved or Rejected</u>&primaryKeyValue=<%=productId%>&columnName=approval&tableName=products&valueType=string",450,150)'>&raquo;</a>&nbsp;<%}%><%=approval%></td>
</tr>

<tr>
	<td class='minderheader'>Web Graphic Uploaded</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=70&rows=10&question=Has%20Product%20Web%20Graphics%20Been%20Uploaded&primaryKeyValue=<%=productId%>&columnName=web_graphic_uploaded&tableName=products&valueType=string",600,500)'>&raquo;</a>&nbsp;<%}%><%=web_graphic_uploaded%></td>
	<td class='minderheader'>Print Status</td><td class='lineitems'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=20&rows=1&question=Change%20Product%20Print%20Status&primaryKeyValue=<%=productId%>&columnName=print_status&tableName=products&valueType=string",450,150)'>&raquo;</a>&nbsp;<%}%><%=print_status%></td>
</tr>

</table><%
if (editor){
	String ppSQL="select id,rfq,offerid,if(grid_label is null,'',grid_label) as grid_label,qty_minimum,quantity,qty_type,format(price,2) price,format(po_cost,2) po_cost,format(std_cost,2) std_cost ,format(inventory_cost,2) inventory_cost,format(MC_est_labor_cost,2) MC_est_labor_cost,price_per,non_billable_flag,if(weight=0,0,format(weight,2)) weight,weight_per,format(std_ship,2) std_ship,format(std_vend_hand,2) std_vend_hand,format(std_subvendor_hand,2) std_subvendor_hand,width,length,height,weight_per_box,number_of_boxes,units_per_box,format(std_ship_price,2) std_ship_price,pp_default_ship_percentage,format(std_ship_cost,2) std_ship_cost,ship_price_policy,ship_cost_policy from product_prices where prod_price_code='"+prod_price_code+"' and active=1 order by quantity";
	ResultSet rsPP = st1.executeQuery(ppSQL);
	%><hr><table border="1" cellpadding="5" cellspacing="0" >
	<tr>
		<td class='billheader' colspan=21><span style="font-size:15"><%=prod_price_code%>:[<%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Dropship%20Vendor%20On%20Price%20Code%20Record&primaryKeyValue=<%=ppcId%>&columnName=dropship_vendor&tableName=product_price_codes&valueType=string",400,150)' class='TitleStr'>&raquo;</a>&nbsp;<%}%>Dropship Vendor:#<%=dropship_vendor%>,<%=dsVendorName%>]</span> Product Pricing (NOTE: Price changes here will be reflected in pricing for ALL products using this price code.)<div align='left'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeHTMLForm.jsp?cols=60&rows=5&question=Change%20ProdPrice%20Notes%20On%20Price%20Code%20Record&primaryKeyValue=<%=ppcId%>&columnName=notes&tableName=product_price_codes&valueType=string",600,600)' class='TitleStr'>&raquo;</a>&nbsp;<%}%>Product Price Notes: <%=ppcNotes%></div></td>
	</tr><%
String tabHead="<tr><td class='billheader' colspan=5 ><div align='center'>PRICE / PRESENTATION</div></td><td class='billheader' colspan=4 ><div align='center'>COST</div></td><td class='billheader' colspan=12 ><div align='center'>SHIPPING</div></td></tr><tr><td class='minderheader'>Product Price Code</td><td class='minderheader'>Quantity</td><td class='minderheader'>Grid&nbsp;Label (Blank to Show Quantity)</td><td class='minderheader'>Price</td><td class='minderheader'>RFQ?</td><td class='minderheader'>PO Cost</td><td class='minderheader'>Std Cost</td><td class='minderheader'>Inv Cost</td><td class='minderheader'>MC Labor Cost</td><td class='minderheader'>Max SV Handling</td><td class='minderheader'>Max MC Handling</td><td class='minderheader'>Ship Cost Policy</td><td class='minderheader'>Std Ship Cost</td><td class='minderheader'>Ship Price Policy</td><td class='minderheader'>Std Ship Price</td><td class='minderheader'>Default Ship %</td><td class='minderheader'>Weight Per Pack</td><td class='minderheader'>Units Per Pack </td><td class='minderheader'># of Packs</td><td class='minderheader'>Pack Length</td><td class='minderheader'>Pack Width</td><td class='minderheader'>Pack Height</td></tr>";
int x=0;
	while (rsPP.next()){
		if (x==0){%><%=tabHead%><%}x++;%><tr>
		<td class='lineitemsright'><%=prod_price_code%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pricing%20Quantity&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=quantity&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("quantity")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=30&rows=1&question=Change%20Product%20Pricing%20Grid%20Label&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=grid_label&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("grid_label")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Price&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=price&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("price")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=5&rows=1&question=Change%20Pricing%20RFQ%20Flag%20ID&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=rfq&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("rfq")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20PO%20Cost&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=po_cost&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("po_cost")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Std%20Cost&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=std_cost&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("std_cost")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Inventory%20Cost&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=inventory_cost&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("inventory_cost")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20MC%20Labor%20Cost&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=MC_est_labor_cost&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("MC_est_labor_cost")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pricing%20MaximumSubvendorHandlingFee%20Id&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=std_subvendor_hand&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("std_subvendor_hand")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pricing%20MaximumMarCometHandlingFee%20Id&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=std_vend_hand&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("std_vend_hand")%></td>

		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pricing%20ShipCostPolicy%20Id&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=ship_cost_policy&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("ship_cost_policy")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pricing%20StandardShipCost%20Id&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=std_ship_cost&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("std_ship_cost")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pricing%20ShipPricePolicy%20Id&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=ship_price_policy&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("ship_price_policy")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pricing%20StandardShipPrice%20Id&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=std_ship_price&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("std_ship_price")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pricing%20StandardShipPercent%20Id&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=pp_default_ship_percentage&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("pp_default_ship_percentage")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pricing%20ShippingWeightPerPack%20Id&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=weight_per_box&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("weight_per_box")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pricing%20UnitsPerPack%20Id&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=units_per_box&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("units_per_box")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pricing%20NumberOfPacks%20Id&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=number_of_boxes&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("number_of_boxes")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pack%20Length&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=length&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("length")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Pack%20Width&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=width&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("width")%></td>
		<td class='lineitemsright'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Product%20Std%20Pack%20Height&primaryKeyValue=<%=rsPP.getString("id")%>&columnName=height&tableName=product_prices&valueType=string",400,150)'>&raquo;</a>&nbsp;<%}%><%=rsPP.getString("height")%></td></tr><%
	}
	if (x==0){
	%>	<tr>
			<td class='lineitems' colspan=17>No Pricing Records Found; product will be presented as an RFQ Job.</td>
		</tr><%	
	}%></table>
	<span id='filtertoggle' ></span><div id='filters' class='toggle'>
	<jsp:include page="/includes/InventoryTransactionList.jsp" flush="true">
		<jsp:param  name="rootInvProdId" value="<%=invRootId%>" />
	</jsp:include><!-- <%=invRootId%> --></div>
<script>
		function toggleLayer(whichLayer){
			var style2 = document.getElementById(whichLayer).style;
			style2.display = style2.display=="block"? "none":"block";
		}
		function togglefilters(category,el,layer){
			var style2 = document.getElementById(layer).style;
			if (style2.display=="block"){
				document.getElementById(el).innerHTML="<br><br><a href='javascript:togglefilters(\""+category+"\",\""+el+"\",\""+layer+"\")' class=greybutton> + Show "+category+"</a>";
			}else{
				document.getElementById(el).innerHTML="<br><br><a href='javascript:togglefilters(\""+category+"\",\""+el+"\",\""+layer+"\")' class=greybutton> + Hide "+category+"</a>";
			}
			toggleLayer(layer);
		}
		document.getElementById('filtertoggle').innerHTML="<a href='javascript:togglefilters(\"Inventory Transactions\",\"filtertoggle\",\"filters\")' class=greybutton> + Show Inventory Transactions</a></div>"
		
</script>
	<%
}

}else{%><form method-"post" action="<%=formAction%>">
			<p class='title'>Product Information</p><p class='body' style="color:Red">Product not found, please check information and try again:</p>
			Product ID:<input type='text' name='productId' value='<%=((productId.equals("0"))?"":productId)%>'><br>&nbsp;&nbsp;&nbsp;-or-<br>Product Code:<input type='text' name='productCode' value='<%=((productCode.equals("0"))?"":productCode)%>'><br><input type=submit value=' CONTINUE '>
		</form><%
}
}%>
</body>
</html><%
	st.close();
	st1.close();
	st2.close();
	conn.close();
	%>