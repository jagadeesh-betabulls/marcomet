<%@ page import="java.text.*,java.io.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*,com.marcomet.tools.*, com.marcomet.environment.*;" %>
<%
response.reset();
response.setHeader("Content-type","application/xls");
response.setHeader("Content-disposition","inline; filename=inventory.xls");%><html>
	<head>
		<title>Product Inventory Changes</title>
<style>
	<style>
		.Title {
			font-family: Helvetica, Arial, sans-serif;
			font-size: 12pt;
			color: black;
			font-weight: bold;
			border-bottom: thin solid;
			font-variant: normal;
		}
		.minderheaderleft {
			font-family: Arial;
			font-size: 10pt;
			font-weight: bolder;
			color: White;
			background-color: #A5A5A5;
			text-decoration: none;
			text-align: left;
			margin-top: 0px;
			margin-right: 0;
			margin-bottom: 0px;
			margin-left: 0px;
			letter-spacing: 0px;
		}
		.minderheadercenter {
			font-family: Arial;
			font-size: 10pt;
			font-weight: bolder;
			color: White;
			background-color: #A5A5A5;
			text-decoration: none;
			text-align: center;
			margin-top: 0px;
			margin-right: 0;
			margin-bottom: 0px;
			margin-left: 0px;
			letter-spacing: 0px;
		}
		.minderheaderright {
			font-family: Arial;
			font-size: 10pt;
			font-weight: bolder;
			color: White;
			background-color: #A5A5A5;
			text-decoration: none;
			text-align: right;
			margin-top: 0px;
			margin-right: 0;
			margin-bottom: 0px;
			margin-left: 0px;
			letter-spacing: 0px;
		}

		.lineitem {
			color: black;
			font-size: 10pt;
			font-weight: normal;
			font-family: Arial, Verdana, Geneva;
			text-align: left;
		}
		.lineitemcenter {
			color: black;
			font-size: 10pt;
			font-weight: normal;
			font-family: Arial, Verdana, Geneva;
			text-align: center;
		}

		.lineitemright {
			color: black;
			font-size: 10pt;
			font-weight: normal;
			font-family: Arial, Verdana, Geneva;
			text-align: right;
		}

		.lineitemleftalt {
			color: black;
			font-size: 10pt;
			font-weight: normal;
			font-family: Arial, Verdana, Geneva;
			background: #CCCCCC;
			text-align: left;
		}

		A.lineitemleftalt:hover {
			color: Red;
		}

		A.lineitemleftalt:link {
			color: black;
		}

		A.lineitemleftalt:active {
			color: black;
		}

		.lineitemcenteralt {
			color: black;
			font-size: 10pt;
			font-weight: normal;
			font-family: Arial, Verdana, Geneva;
			background: #CCCCCC;
			text-align: center;
		}

		.lineitemrightalt {
			color: black;
			font-size: 10pt;
			font-weight: normal;
			font-family: Arial, Verdana, Geneva;
			text-align: right;
		}
</style>
	</head>
<body><%

StringTool str=new StringTool();
String asapFilter="";
String activeFilter="";
String inventoryFilter="";
String initFilter="";
String activeStr="Active";

if ( request.getParameter("asap")==null || request.getParameter("asap").equals("") ){
	activeFilter=((request.getParameter("active")==null || request.getParameter("active").equals(""))?"":((request.getParameter("active").equals("true"))?" AND status_id=2 ":" AND status_id <> 2 "));

	inventoryFilter=((request.getParameter("inventory")==null || request.getParameter("inventory").equals(""))?"":((request.getParameter("inventory").equals("true"))?" AND inventory_product_flag>0 ":" AND inventory_product_flag=0 "));

	initFilter=((request.getParameter("initialized")==null || request.getParameter("initialized").equals(""))?"":((request.getParameter("initialized").equals("true"))?" AND inventory_initialized>0 ":" AND inventory_initialized=0 "));
	
}else if(request.getParameter("asap").equals("true")){
	asapFilter=" AND inventory_product_flag=1 AND status_id=2 AND ((inventory_amount<0 and inventory_initialized>0) OR (inventory_initialized=0) OR (avg_inv_per_day_sales>0 AND  (((inventory_amount-inv_on_order_amount)/avg_inv_per_day_sales)-days_to_restock)<=1 AND  inventory_initialized> 0)) " ;
}
	initFilter=((request.getParameter("initialized")==null || request.getParameter("initialized").equals(""))?"":((request.getParameter("initialized").equals("true"))?" AND inventory_initialized>0 ":" AND inventory_initialized=0 "));
String paramStr=((activeFilter.equals(""))?"":"  |  Active = "+request.getParameter("active"));
paramStr+=((inventoryFilter.equals(""))?"":"  |  Inventoriable = "+request.getParameter("inventory"));
paramStr+=((initFilter.equals(""))?"":"  |  Initialized = "+request.getParameter("initialized"));
paramStr+=((asapFilter.equals(""))?"":"Products Needing Inventory Action ASAP");

String productId=((request.getParameter("productId")==null || request.getParameter("productId").equals(""))?"0":request.getParameter("productId"));
String prodIdFilter=((request.getParameter("productId")==null || request.getParameter("productId").equals(""))?"":" AND id= '"+request.getParameter("productId")+"'");

String filters=prodIdFilter+activeFilter+inventoryFilter+initFilter+asapFilter;
SimpleDateFormat df = new SimpleDateFormat("MM/dd/yyyy");
%><table border=1>
			<tr><td colspan=13>&nbsp;</td></tr>
	<tr><td class='Title' colspan=13>Product Inventory List as of <%=df.format(new java.util.Date())%><br><%=paramStr%></td></tr>
		<tr><td colspan=13>&nbsp;</td></tr>
	<tr><td class='minderheaderleft'>Product ID</td>
	<td class='minderheaderleft'>Root Inv Product ID</td>
	<td class='minderheaderleft'>Status</td>
	<td class='minderheaderleft'>Product Code</td>
	<td class='minderheaderleft'>Product Name</td>
	<td class='minderheaderleft'>Release</td>
	<td class='minderheaderleft'>Brand</td>
	<td class='minderheaderleft'>Company ID</td>
	<td class='minderheaderleft'>Build Type</td>
	<td class='minderheaderleft'>Subvendor ID</td>
	<td class='minderheaderleft'>Inv Product Flag</td>
	<td class='minderheaderleft'>Inv Initialized</td>
	<!-- <td class='minderheaderleft'>Root Inv ID</td> -->
	<td class='minderheaderleft'>Min Order Amount</td>
	<td class='minderheaderleft'>Amt on Order</td>
	<td class='minderheaderleft'>Amt Sold &lth; 30 Days</td>
	<td class='minderheaderleft'>Amt Sold &gth; 30 &amp; &lth; 60 Days</td>
	<td class='minderheaderleft'>Amt Sold &gth; 60 &amp; &lth; 90 Days</td>
	<td class='minderheaderleft'>Amt of Root on Order</td>
	<td class='minderheaderleft'>Amt On Hand</td>
	<td class='minderheaderleft'>Amt Available</td>
	<td class='minderheaderleft'># of Orders Remaining</td>	
	<td class='minderheaderleft'>Per Unit Cost</td>	
	<td class='minderheaderleft'>Per Unit Retail</td>
	<td class='minderheaderleft'>Backorder Flag</td>
	<td class='minderheaderleft'>Backorder Text</td>
	<td class='minderheaderleft'>Sales Lookback</td>
	<td class='minderheaderleft'>Avg Daily Sales</td>
	<td class='minderheaderleft'>Avg Monthly Sales</td>
	<td class='minderheaderleft'>Avg Dly Sales of Root</td>
	<td class='minderheaderleft'>Avg Mthly Sales of Root</td>
	<td class='minderheaderleft'>First Date Avail</td><%
	//COST - use highest cost from prod_prices
	
	//RETAIL - use highest per unit retail from prod_prices
	//For Report
	//based on average daily sales, predict number of days until we will run out of product based on: (inv_on_order-inventory_amount)/avgDailySales
	//int daysToReorder=( (Integer.parseInt(rsProds.getString("amount_available"))>0) ? Integer.parseInt(rsProds.getString("amount_available"))/avgDailySales :0);

	//calculate the date that the product will need to be reordered based on the number of days till product zero's out and the number of days to restock.
	//	reorderDate.add(DAY_OF_MONTH,daysToReorder);
	%><td class='minderheaderleft'>Days Until 0 Inv</td>
	<td class='minderheaderleft'>Reorder Lead Days</td>
	<td class='minderheaderleft'>Days Until Reorder</td>
	<td class='minderheaderleft'>Next Reorder Date</td>
	<td class='minderheaderleft'>Days on Backorder</td>
	<td class='minderheaderleft'>Reorder Floor</td>
	<td class='minderheaderleft'>Date Reorder Floor</td>
	<td class='minderheaderleft'>Date Requested</td>
	<td class='minderheaderleft'>Date Shipping</td>
	<td class='minderheaderleft'>Activity</td>
	<td class='minderheaderleft'>Internal Notes</td>
</tr><%
int x=0;
int y=0;
//Display products and inventory amounts

//SimpleConnection sc = new SimpleConnection();
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
Statement st3 = conn.createStatement();
String invProductId = "0";
String prodOnOrderAmt="0";	
String invOnOrderAmt="0";	
String invAmt="0";	
String invAction="0";
String invInitDate="9999"; //Set the init date high
String cost="0";
String retail="0";
String minQuantity="0";
Double invRemaining=0.0;
String productSQL="SELECT products.*,ppc.dropship_vendor as 'dsvendor', REPLACE(REPLACE(internal_notes, '\r', '   |   '), '\n', '   |   ') 'internalNotes',date_format(backorder_ship_date,'%m/%d/%Y') shipdate,date_format(restock_request_date,'%m/%d/%Y') requestdate,format(round(avg_per_day_sales),0) avgperdaysales, format(round(avg_per_month_sales,2),0) avgpermonthsales, format(round(avg_inv_per_day_sales),0) avginvperdaysales, format(round(avg_inv_per_month_sales),0) avginvpermonthsales, (inventory_amount - inv_on_order_amount) as inventory_balance from products left join product_price_codes ppc on ppc.prod_price_code=products.prod_price_code  "+((filters.equals(""))?"":" where "+filters)+" order by status_id,prod_code";
%><!-- <%=productSQL%> --><%
ResultSet rsProds=st.executeQuery(productSQL);

while(rsProds.next()){
String boNotes=((rsProds.getString("backorder_notes")==null)?"":rsProds.getString("backorder_notes"));
	String costSQL="SELECT max(pp.std_cost/pp.quantity) maxcost,max(pp.price/pp.quantity) maxretail, min(pp.quantity) minQuantity from products p,product_prices pp where p.prod_price_code=pp.prod_price_code and p.id="+rsProds.getString("id");
		ResultSet rsCosts=st3.executeQuery(costSQL);
		if(rsCosts.next()){
			cost=rsCosts.getString(1);
			retail=rsCosts.getString(2);
			minQuantity=rsCosts.getString("minQuantity");
			invRemaining=(rsProds.getDouble("inventory_balance") / rsCosts.getDouble("minQuantity"));
			
		}else{
			cost="0";
			retail="0";
			minQuantity="0";
			invRemaining=0.0;
		}
%><tr><%
	%><td class='lineitem'><%=rsProds.getString("id")%></td><%
	%><td class='lineitem'><%=rsProds.getString("Root_Inv_Prod_ID")%></td><%
	%><td class='lineitem'><%=rsProds.getString("status_id")%></td><%
	%><td class='lineitem'><%=rsProds.getString("prod_code")%></td><%
	%><td class='lineitem'><%=rsProds.getString("prod_name")%></td><%
	%><td class='lineitem'><%=rsProds.getString("release")%></td><%
	%><td class='lineitem'><%=rsProds.getString("brand_code")%></td><%
	%><td class='lineitem'><%=rsProds.getString("company_id")%></td><%
	%><td class='lineitem'><%=rsProds.getString("build_type")%></td><%
	%><td class='lineitem'><%=((rsProds.getString("dsvendor")==null)?"NONE":rsProds.getString("dsvendor"))%></td><%
	%><td class='lineitem'><%=rsProds.getString("inventory_product_flag")%></td><%
	%><td class='lineitemcenter'><%=((rsProds.getString("inventory_initialized").equals("0"))?"NO":"YES")%></td><%
	%><!-- <td class='lineitem'><%=rsProds.getString("root_inv_prod_id")%></td> --><%
	%><td class='lineitemright'><%=minQuantity%></td><%
	%><td class='lineitemright'><%=rsProds.getString("on_order_amount")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("quantity_sold_30_days")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("quantity_sold_31_to_60_days")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("quantity_sold_61_to_90_days")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("inv_on_order_amount")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("inventory_amount")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("inventory_balance")%></td><%
	%><td class='lineitemright'><%=invRemaining%></td><%
	%><td class='lineitem'><%=cost%></td><%
	%><td class='lineitem'><%=retail%></td><%
	%><td class='lineitem'><%=rsProds.getString("backorder_action")%></td><%
	%><td class='lineitem'><%=str.replaceSubstring(boNotes,"<br>"," ")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("last_period_used")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("avgperdaysales")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("avgpermonthsales")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("avginvperdaysales")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("avginvpermonthsales")%></td><%
	%><td class='lineitem'><%=rsProds.getString("first_sales_date")%></td><%
	if(rsProds.getString("status_id").equals("2") && !(rsProds.getString("inventory_product_flag").equals("0")) && !(rsProds.getString("inventory_initialized").equals("0"))){
//For Trigger Report
//based on average daily sales, predict number of days until we will run out of product based on: (inv_on_order-inventory_amount)/avgDailySales
//int daysToReorder=( (Integer.parseInt(rsProds.getString("amount_available"))>0) ? Integer.parseInt(rsProds.getString("amount_available"))/avgDailySales :0);

//calculate the date that the product will need to be reordered based on the number of days till product zero's out and the number of days to restock.
	double avgSales=Double.parseDouble( ((rsProds.getString("avg_inv_per_day_sales")==null || rsProds.getString("avg_inv_per_day_sales").equals("") )?"0":rsProds.getString("avg_inv_per_day_sales") ) );
	int invOnHand=Integer.parseInt( ((rsProds.getString("inventory_balance")==null || rsProds.getString("inventory_balance").equals("") )?"0":rsProds.getString("inventory_balance")));
	int reorderLeadDays=Integer.parseInt( ((rsProds.getString("days_to_restock")==null || rsProds.getString("days_to_restock").equals(""))?"0":rsProds.getString("days_to_restock")));
	int daysToZero=0;
	GregorianCalendar now = new GregorianCalendar();
	if(Double.parseDouble(rsProds.getString("avg_inv_per_day_sales"))>0.0){
		daysToZero= new Double((Double.parseDouble(rsProds.getString("inventory_balance"))/Double.parseDouble(rsProds.getString("avg_inv_per_day_sales")) )).intValue();
	}else{
		daysToZero=((invOnHand>0 && avgSales==0)?999:0); 
	}
	int daysToReorder=((invOnHand>0 && avgSales==0)?999:daysToZero-reorderLeadDays);
	now.add(Calendar.DAY_OF_MONTH, ((daysToReorder<0)?0:daysToReorder) );	
	String nextReorderDate = ( (daysToReorder>0)? Integer.toString(now.get(Calendar.MONTH)+1) +"/"+Integer.toString(now.get(Calendar.DAY_OF_MONTH))+"/"+Integer.toString(now.get(Calendar.YEAR)):"ASAP");
	double reorderAmountTrigger=Double.parseDouble( ((rsProds.getString("reorder_trigger")==null || rsProds.getString("reorder_trigger").equals(""))?"0":rsProds.getString("reorder_trigger")));
	GregorianCalendar reorderTriggerDate = new GregorianCalendar(); 
	double reordertriggerdays =  ((invOnHand-reorderAmountTrigger<0)?0:((avgSales>0)?(invOnHand-reorderAmountTrigger)/avgSales:0));
	reorderTriggerDate.add(Calendar.DAY_OF_MONTH,(int)reordertriggerdays);	
	String dateToReorderTrigger = Integer.toString(now.get(Calendar.MONTH))+"/"+Integer.toString(now.get(Calendar.DAY_OF_MONTH))+"/"+Integer.toString(now.get(Calendar.YEAR));
	activeStr=((invOnHand==0 && avgSales==0)?"Inactive":"Active");
	String daysOnBackorder="0";
	if (invOnHand<0){
		String backorderSQL="SELECT DateDiff( Now(),(min(order_date))) as boDays from jobs where status_id<119 and status_id<>9 and product_id="+rsProds.getString("id");
		ResultSet rsBO=st3.executeQuery(backorderSQL);
		while(rsBO.next()){
			daysOnBackorder=rsBO.getString("boDays");	
		}		
	}
	%><td class='lineitemright'><%=((daysToZero<0)?"0":Integer.toString(daysToZero) )%></td><%
	%><td class='lineitemright'><%=reorderLeadDays%></td><%
	%><td class='lineitemright'><%=((daysToReorder<0)?"0":Integer.toString(daysToReorder))%></td><%
	%><td class='lineitemright'><%=((daysToReorder<0)?"ASAP":nextReorderDate)%></td><%
	%><td class='lineitemright'><%=daysOnBackorder%></td><%
	%><td class='lineitemright'><%=Double.toString(reorderAmountTrigger)%></td><%
	%><td class='lineitemright'><%=((reorderAmountTrigger==0)?"N/A":dateToReorderTrigger )%></td><%
	}else{
		%><td class='minderheadercenter' >N/A</td><td class='minderheadercenter' >N/A</td><td class='minderheadercenter' >N/A</td><td class='minderheadercenter' >N/A</td><td class='minderheadercenter' >N/A</td><td class='minderheadercenter' >N/A</td><td class='minderheadercenter' >N/A</td><%
	
	}
	%><td class='lineitemright'><%=rsProds.getString("requestdate")%></td><%	
	%><td class='lineitemright'><%=rsProds.getString("shipdate")%></td><%
%><td class='lineitemright' ><%=activeStr%></td><td class='lineitemright' ><%=rsProds.getString("internalNotes")%></td>
</tr><%
}
	st.close();
	st2.close();
	st3.close();
	conn.close();
%></table></body></html>