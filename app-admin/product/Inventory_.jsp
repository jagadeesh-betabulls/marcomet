<%@ page import="java.text.*,java.io.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ page contentType="application/vnd.ms-excel" %>
<html>
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
<body>
<table border=1>
			<tr><td colspan=13>&nbsp;</td></tr>
	<tr><td class='Title' colspan=13>Product Inventory List as of <%
	SimpleDateFormat df = new SimpleDateFormat("MM/dd/yyyy");
	%><%=df.format(new java.util.Date())%></td></tr>
		<tr><td colspan=13>&nbsp;</td></tr>
	<tr><td class='minderheaderleft'>Product ID</td>
	<td class='minderheaderleft'>Status</td>
	<td class='minderheaderleft'>Product Code</td>
	<td class='minderheaderleft'>Product Name</td>
	<td class='minderheaderleft'>Release</td>
	<td class='minderheaderleft'>Brand</td>
	<td class='minderheaderleft'>Company ID</td>
	<td class='minderheaderleft'>Build Type</td>
	<td class='minderheaderleft'>Subvendor ID</td>
	<td class='minderheaderleft'>Inventory Product Flag</td>
	<td class='minderheaderleft'>Inventory Initialized / Date</td>
	<td class='minderheaderleft'>Root Inv ID</td>
	<td class='minderheaderleft'>Amount of Root on Order</td>
	<td class='minderheaderleft'>Amount on Order</td>
	<td class='minderheaderleft'>Amount On Hand</td>
	<td class='minderheaderleft'>Amount Available</td>
	<td class='minderheaderleft'>Per Unit Cost</td>	
	<td class='minderheaderleft'>Per Unit Retail</td>
	<td class='minderheaderleft'>Backorder Flag</td>
	<td class='minderheaderleft'>Backorder Text</td>
	<td class='minderheaderleft'>Last Sales(days) Period For Calc</td>
	<td class='minderheaderleft'>Average Daily Sales</td>
	<td class='minderheaderleft'>Average Monthly Sales</td>
	<td class='minderheaderleft'>Avg Dly Sales of Root Inventory</td>
	<td class='minderheaderleft'>Avg Mthly Sales of Root Inventory</td>
	<td class='minderheaderleft'>First Sales Date</td><%
	//COST - use highest cost from prod_prices
	
	//RETAIL - use highest per unit retail from prod_prices
	//For Report
	//based on average daily sales, predict number of days until we will run out of product based on: (inv_on_order-inventory_amount)/avgDailySales
	//int daysToReorder=( (Integer.parseInt(rsProds.getString("amount_available"))>0) ? Integer.parseInt(rsProds.getString("amount_available"))/avgDailySales :0);

	//calculate the date that the product will need to be reordered based on the number of days till product zero's out and the number of days to restock.
	//	reorderDate.add(DAY_OF_MONTH,daysToReorder);
	%><td class='minderheaderleft'>Days Until 0 Inv</td>
	<td class='minderheaderleft'>Reorder Lead Days</td>
	<td class='minderheaderleft'>Days Until Reorder Necessary</td>
	<td class='minderheaderleft'>Next Reorder Date</td><%
	%><td class='minderheaderleft'>Reorder Amount Trigger</td>
	<td class='minderheaderleft'>Date Reorder Amount Trigger Reached</td>
</tr><%
int x=0;
int y=0;
String productId=((request.getParameter("productId")==null || request.getParameter("productId").equals(""))?"0":request.getParameter("productId"));

//Display products and inventory amounts


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

String productSQL="SELECT *,(inventory_amount-on_order_amount) as inventory_balance from products order by status_id,prod_code";
ResultSet rsProds=st.executeQuery(productSQL);

while(rsProds.next()){
	String costSQL="SELECT max(pp.std_cost/pp.quantity) maxcost,max(pp.price/pp.quantity) maxretail from products p,product_prices pp where p.prod_price_code=pp.prod_price_code and p.id="+rsProds.getString("id");
		ResultSet rsCosts=st3.executeQuery(costSQL);
		if(rsCosts.next()){
			cost=rsCosts.getString(1);
			retail=rsCosts.getString(2);
		}else{
			cost="0";
			retail="0";
		}
%><tr><%
	%><td class='lineitem'><%=rsProds.getString("id")%></td><%
	%><td class='lineitem'><%=rsProds.getString("status_id")%></td><%
	%><td class='lineitem'><%=rsProds.getString("prod_code")%></td><%
	%><td class='lineitem'><%=rsProds.getString("prod_name")%></td><%
	%><td class='lineitem'><%=rsProds.getString("release")%></td><%
	%><td class='lineitem'><%=rsProds.getString("brand_code")%></td><%
	%><td class='lineitem'><%=rsProds.getString("company_id")%></td><%
	%><td class='lineitem'><%=rsProds.getString("build_type")%></td><%
	%><td class='lineitem'><%=((rsProds.getString("default_subvendor")==null)?"NONE":rsProds.getString("default_subvendor"))%></td><%
	%><td class='lineitem'><%=rsProds.getString("inventory_product_flag")%></td><%
	%><td class='lineitemcenter'><%=((rsProds.getString("inventory_initialized").equals("0"))?"NO":"YES: "+((rsProds.getString("inventory_init_date")==null)?"":rsProds.getString("inventory_init_date")))%></td><%
	%><td class='lineitem'><%=rsProds.getString("root_inv_prod_id")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("inv_on_order_amount")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("on_order_amount")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("inventory_amount")%></td><%
	%><td class='lineitemright'><%=((Integer.parseInt(rsProds.getString("inventory_balance"))<0 )?"0":rsProds.getString("inventory_balance"))%></td><%
	%><td class='lineitem'><%=cost%></td><%
	%><td class='lineitem'><%=retail%></td><%
	%><td class='lineitem'><%=rsProds.getString("backorder_action")%></td><%
	%><td class='lineitem'><%=rsProds.getString("backorder_notes")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("last_period_used")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("avg_per_day_sales")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("avg_per_month_sales")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("avg_inv_per_day_sales")%></td><%
	%><td class='lineitemright'><%=rsProds.getString("avg_inv_per_month_sales")%></td><%
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
		daysToZero=0; 
	}
	int daysToReorder=daysToZero-reorderLeadDays;
	now.add(Calendar.DAY_OF_MONTH, ((daysToReorder<0)?0:daysToReorder) );	
	String nextReorderDate = ( (daysToReorder>0)? Integer.toString(now.get(Calendar.MONTH)+1) +"/"+Integer.toString(now.get(Calendar.DAY_OF_MONTH))+"/"+Integer.toString(now.get(Calendar.YEAR)):"ASAP");
	double reorderAmountTrigger=Double.parseDouble( ((rsProds.getString("reorder_trigger")==null || rsProds.getString("reorder_trigger").equals(""))?"0":rsProds.getString("reorder_trigger")));
	GregorianCalendar reorderTriggerDate = new GregorianCalendar(); 
	double reordertriggerdays =  ((invOnHand-reorderAmountTrigger<0)?0:((avgSales>0)?(invOnHand-reorderAmountTrigger)/avgSales:0));
	reorderTriggerDate.add(Calendar.DAY_OF_MONTH,(int)reordertriggerdays);	
	String dateToReorderTrigger = Integer.toString(now.get(Calendar.MONTH))+"/"+Integer.toString(now.get(Calendar.DAY_OF_MONTH))+"/"+Integer.toString(now.get(Calendar.YEAR));

	%><td class='lineitemright'><%=((daysToZero<0)?"-1":Integer.toString(daysToZero) )%></td><%
	%><td class='lineitemright'><%=reorderLeadDays%></td><%
	%><td class='lineitemright'><%=((daysToReorder<0)?"-1":Integer.toString(daysToReorder))%></td><%
	%><td class='lineitemright'><%=((daysToReorder<0)?"ASAP":nextReorderDate)%></td><%
%><td class='lineitemright'><%=Double.toString(reorderAmountTrigger)%></td><%
	%><td class='lineitemright'><%=((reorderAmountTrigger==0)?"N/A":dateToReorderTrigger )%></td><%
	}else{
		%><td class='minderheadercenter' >N/A</td><td class='minderheadercenter' >N/A</td><td class='minderheadercenter' >N/A</td><td class='minderheadercenter' >N/A</td><td class='minderheadercenter' >N/A</td><td class='minderheadercenter' >N/A</td><%
	
	}
%></tr><%
}
	st.close();
	st2.close();
	st3.close();
	conn.close();
%></table></body></html>