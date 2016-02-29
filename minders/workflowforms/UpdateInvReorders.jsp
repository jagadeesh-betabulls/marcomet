<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="cjc" class="com.marcomet.workflow.actions.InventoryUpdater" scope="session" />
<html><head><title>Update Product Inventory Changes</title>
<link rel="stylesheet" href="/htdocs/commerce/styles/marcomet.css" type="text/css"></head><body><p class='Title'>Update Product Inventory Changes</p><%
int x=0;
int y=0;
String productId=((request.getParameter("productId")==null || request.getParameter("productId").equals(""))?"0":request.getParameter("productId"));
String rootInvProdId="0";

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
Statement st3 = conn.createStatement();

//PRODUCT INVENTORY AMOUNTS UPDATE
//Cycle through all products

double totSales = 0;
double avgDailySales = 0.000000;
double avgInvDailySales = 0.000000;
double avgMonthlySales=0.000000;
double avgInvMonthlySales=0.000000;
long period=90;
long period1=0;
long period2=0;


String productSQL="SELECT *,(inv_on_order_amount-inventory_amount) as amount_available,first_sales_date,YEAR(first_sales_date) as firstSalesYear,MONTH(first_sales_date)-1 as firstSalesMONTH, dayofmonth(first_sales_date) as firstSalesDay from products where status_id=2 "+((productId.equals("0"))?"":" AND id="+productId)+" order by root_inv_prod_id";
		
ResultSet rsProds=st.executeQuery(productSQL);
while(rsProds.next()){
		productId=rsProds.getString("id");
		rootInvProdId=((rsProds.getString("root_inv_prod_id").equals("0") )?rsProds.getString("id"):rsProds.getString("root_inv_prod_id"));
		if (!(rootInvProdId.equals("0"))){
		//Calculate the total sales for a given period divided by number of days in the period
		
		//For start date for analysis use the later of (Today - history_period) or first_sales_date.  if history_period is null or 0 use first_sales_date.
		
		//For end date use Today
		
		//For number of days use end date - start date.
		
		//If first sales date is null, fill it with the first order date for that product
		GregorianCalendar firstSalesDate=new GregorianCalendar(); //Calendar.getInstance();
		firstSalesDate.add(Calendar.DAY_OF_MONTH,-1);
		
		if (rsProds.getString("first_sales_date")==null || rsProds.getString("first_sales_date").equals("")){
			String salesSql="select min(order_date) as order_date_min,YEAR(min(order_date)) as firstsalesyear,MONTH(min(order_date))-1 as firstsalesmonth, dayofmonth(min(order_date)) as firstsalesday from jobs where product_id="+productId;
			ResultSet rsSale=st2.executeQuery(salesSql);
			String setSalesDate="update products set first_sales_date=now() where id="+productId;
			if(rsSale.next()){
				setSalesDate="update products set first_sales_date='"+rsSale.getString("order_date_min")+"' where id="+productId;
				firstSalesDate.set( Integer.parseInt(((rsSale.getString("firstSalesYear")==null)?"2006":rsSale.getString("firstSalesYear"))),Integer.parseInt(((rsSale.getString("firstSalesMonth")==null)?"01":rsSale.getString("firstSalesMonth"))),Integer.parseInt(((rsSale.getString("firstSalesDay")==null)?"01":rsSale.getString("firstSalesDay"))));
			}else{
				setSalesDate="update products set first_sales_date=Now() where id="+productId;	
			}
			st2.executeQuery(setSalesDate);
		}else{
			firstSalesDate.set( Integer.parseInt(((rsProds.getString("firstSalesYear")==null)?"2006":rsProds.getString("firstSalesYear"))),Integer.parseInt(((rsProds.getString("firstSalesMonth")==null)?"00":rsProds.getString("firstSalesMonth"))),Integer.parseInt(((rsProds.getString("firstSalesDay")==null)?"01":rsProds.getString("firstSalesDay"))));
		}
		
		GregorianCalendar now = new GregorianCalendar(); //Calendar.getInstance();
		GregorianCalendar startDate = new GregorianCalendar(); //Calendar.getInstance();
		GregorianCalendar reorderDate = new GregorianCalendar(); //Calendar.getInstance();		

		String monthStr = String.valueOf(now.get(Calendar.MONTH)+1);
		String yearStr =  String.valueOf(now.get(Calendar.YEAR));
		String dayStr =  String.valueOf(now.get(Calendar.DAY_OF_MONTH));	
		
		String todayStr=yearStr+'-'+monthStr+"-"+dayStr;	
		
		startDate.add(Calendar.DAY_OF_MONTH,-1 * (1+Integer.parseInt(((rsProds.getString("history_period")==null || rsProds.getString("history_period").equals("") || rsProds.getString("history_period").equals("0"))?"90":rsProds.getString("history_period")))) );
	//	if (firstSalesDate.getTime().getTime() < startDate.getTime().getTime() ) {
		//	long differenceInMillis = ;
			period1 = (now.getTime().getTime() - startDate.getTime().getTime())/(24*60*60*1000);
			period2 = (now.getTime().getTime() - firstSalesDate.getTime().getTime())/(24*60*60*1000);
			if (period2<period1){
				startDate=firstSalesDate;
				period=period2;
			}else{
				period=period1;
			}%>Period:<%=period%>,Period1:<%=period1%>,Period2:<%=period2%><br><%
		monthStr =  String.valueOf(startDate.get(Calendar.MONTH)+1);
		yearStr =  String.valueOf(startDate.get(Calendar.YEAR));
		dayStr =  String.valueOf(startDate.get(Calendar.DAY_OF_MONTH));
		
		String startDateStr=yearStr+'-'+monthStr+"-"+dayStr;
	
		String totSalesSql="SELECT sum(quantity) from jobs where product_id='"+productId+"' AND order_date >'"+startDateStr+"' AND order_date<='"+todayStr+"' ";
		ResultSet rsTotSales=st3.executeQuery(totSalesSql);
		if(rsTotSales.next()){
			totSales=Double.parseDouble(rsTotSales.getString(1));
		}else{
			totSales=0;
		}
		
		avgDailySales=((totSales<=0)?0.000000:totSales/period);
		avgMonthlySales=avgDailySales*30;
		
		String updatePrOr="UPDATE products SET last_period_used='"+period+"', avg_per_day_sales='"+avgDailySales+"',avg_per_month_sales='"+avgMonthlySales+"' WHERE id = '"+productId+"'";
		%><%=updatePrOr%>;<%	
		  st3.executeQuery(updatePrOr);
		String totInvSalesSql="select sum(avg_per_day_sales),sum(avg_per_month_sales) from products where root_inv_prod_id='"+rootInvProdId+"' or id='"+rootInvProdId+"'";
		ResultSet rsTotInvSales=st3.executeQuery(totInvSalesSql);
		if(rsTotInvSales.next()){
			avgInvDailySales=Double.parseDouble(rsTotInvSales.getString(1));
			avgInvMonthlySales=Double.parseDouble(rsTotInvSales.getString(2));
		}else{
			avgInvDailySales=0;
			avgInvMonthlySales=0;
		}
		updatePrOr="UPDATE products SET avg_inv_per_day_sales='"+avgInvDailySales+"',avg_inv_per_month_sales='"+avgInvMonthlySales+"' WHERE root_inv_prod_id='"+rootInvProdId+"' or id = '"+rootInvProdId+"'";	
		  st3.executeQuery(updatePrOr);	
		%><%=updatePrOr%><hr><%
		}
}
try { st.close(); } catch (Exception e) {}
try { st2.close(); } catch (Exception e) {}
try { st3.close(); } catch (Exception e) {}
try { conn.close(); } catch (Exception e) {}
%></body></html>