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

//Update products from data in the tmp_products table

String query="Select t.*,p.*,ip.* from tmp_products t, products p,products ip where t.product_id=p.id and if(t.root_inv_prod_id=0,t.product_id,t. root_inv_prod_id)=ip.id and t.posted_date is null "+((productId.equals("0"))?"":" AND t.product_id="+productId);

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
Statement st3 = conn.createStatement();
ResultSet rs = st.executeQuery(query);

while (rs.next()) {

	String tmpProductId=rs.getString("p.id");

	//If there is an inventory amount in the temp record create a manual increment record in the inventory transactions table
	if (rs.getString("t.inventory_amount")!=null) {
		st2 = conn.createStatement();
		query = "insert into inventory set adjustment_notes='Manual Adjustment, inventory update',root_inv_prod_code='"+rs.getString("ip.prod_code")+"',adjustment_type_id='2',adjustment_action='1',product_id='"+rs.getString("p.id") +"',root_inv_prod_id='"+rs.getString("ip.id")+"',amount="+rs.getString("t.inventory_amount")+",adjustor_contact_id ='"+((UserProfile)session.getAttribute("userProfile")).getContactId()+"',adjustment_date='"+rs.getString("t.inventory_init_date")+"',warehouse_id ='"+rs.getString("p.default_warehouse_id")+"'";
		st2.execute(query);
		
		y++;
	}	

// Update the product record with values from the temp table record
// String updateProdFields="UPDATE products p, tmp_products tp SET p.backorder_action=tp.backorder_action, p.backorder_notes=tp.backorder_notes, p.std_lead_time=tp.std_lead_time,p.build_type=tp.build_type,p.inventory_product_flag=tp.inventory_product_flag, p.root_inv_prod_id=tp.root_inv_prod_id,p.inventory_init_date=tp.inventory_init_date,p.days_to_restock=tp.days_to_restock,tp.posted_date=Now()  WHERE  tp.posted_date is null and tp.product_id=p.id and p.id = '"+tmpProductId+"'";	
	String updateProdFields="UPDATE tmp_products tp SET tp.posted_date=Now()  WHERE tp.posted_date is null and tp.id = '"+rs.getString("t.id")+"'";	
	st3.execute(updateProdFields);
	
	//Print out the product id for the updated record
	%>Product <%=x%> Updated from TMP: Product ID <%=rs.getString("t.product_id")%><br><%
	x++;
}


//PRODUCT INVENTORY AMOUNTS UPDATE
//Cycle through all products and update the inventory and on-order amounts
		String invProductId = "0";
		String prodOnOrderAmt="0";	
		String invOnOrderAmt="0";	
		String invAmt="0";	
		String invAction="0";
		String invInitDate="9999"; //Set the init date high

		String productSQL="SELECT * from products where status_id=2 "+((productId.equals("0"))?"":" AND id="+productId);
		
ResultSet rsProds=st.executeQuery(productSQL);
while(rsProds.next()){
		productId=rsProds.getString("id");
			
		invProductId=((rsProds.getString("root_inv_prod_id").equals("0"))?rsProds.getString("id"):rsProds.getString("root_inv_prod_id"));

		//get the inventory init date
		String invInitSQL="SELECT min(adjustment_date) from inventory where root_inv_prod_id='"+invProductId+"' AND adjustment_action='1' ";
		ResultSet rsInvInit=st3.executeQuery(invInitSQL);
		if(rsInvInit.next()){
			invInitDate=rsInvInit.getString(1);
		}else{
			invInitDate="9999";
		}
		
		//Get the on order amount for this product
		String productsOnOrder="SELECT sum(j.quantity-(if(s.shipping_quantity is null,0,s.shipping_quantity)))  FROM jobs j left join shipping_data s on s.job_id=j.id where j.status_id<>9 and j.status_id<>119 and j.status_id<>120 and  j.product_id='"+productId+"' GROUP BY j.product_id";
		ResultSet rsPrOr=st3.executeQuery(productsOnOrder);
		if(rsPrOr.next()){
			prodOnOrderAmt=rsPrOr.getString(1);
		}else{
			prodOnOrderAmt="0";
		}

		//Get the on-order amount for all products sharing the same root inventory id
		String rootProductOnOrder="SELECT sum(j.quantity-(if(s.shipping_quantity is null,0,s.shipping_quantity)))  FROM products p,jobs j left join shipping_data s on s.job_id=j.id where p.id=j.product_id and j.status_id<>9 and j.status_id<>119 and j.status_id<>120 and (p.root_inv_prod_id='"+invProductId+"' or  p.id='"+invProductId+"') ";
		ResultSet rsRtPrOr=st3.executeQuery(rootProductOnOrder);
		if(rsRtPrOr.next()){
			invOnOrderAmt=rsRtPrOr.getString(1);
		}else{
			invOnOrderAmt="0";	
		}
		
		//Zero out inventory amount values for all inventory transactions prior to the first manual adjustment for the product, put the old values in the notes field
	if (!(invInitDate.equals("9999"))){
		String resetInventory="UPDATE inventory SET adjustment_notes = concat(if(adjustment_notes is null,'',concat(adjustment_notes,'; ')),'Old amount=',amount),amount=0 where amount<>0 and root_inv_prod_id='"+invProductId+"' and adjustment_date < '"+invInitDate+"' ";
		st3.execute(resetInventory);
	}
		//Get the inventory amount for the root product
		String invAmount="SELECT sum(amount) amount, sum(adjustment_action) action FROM inventory where root_inv_prod_id='"+invProductId+"' GROUP BY root_inv_prod_id";
		ResultSet rsInvAmt=st3.executeQuery(invAmount);
		if(rsInvAmt.next()){
			invAmt=rsInvAmt.getString(1);
			invAction=rsInvAmt.getString(2);
		}else{
			invAmt="0";
			invAction="0";
		}
		
		//If the inventory has never been initialized (if inventory action=0) then set the inventory amount to 0, else set the actual inventory amount
		if (productId.equals("3379")){ //reset the inventory amount to -1 for the baymont directory of hotels
			String updatePrOr="UPDATE products SET inventory_initialized='1',inventory_amount = '-1' WHERE id = '"+productId+"'";	
			st3.execute(updatePrOr);
			%>InvProdId: <%=invProductId%><br><%	
		}else{
			String updatePrOr="UPDATE products SET on_order_amount = "+prodOnOrderAmt+" WHERE id = '"+productId+"'";	
			st3.execute(updatePrOr);

			updatePrOr="UPDATE products SET inventory_init_date=if('"+invInitDate+"'='2020-01-01',Null,'"+invInitDate+"'),inv_on_order_amount = "+invOnOrderAmt+", inventory_initialized="+invAction+", inventory_amount = " + ((invAction.equals("0"))?"0":invAmt) + " WHERE root_inv_prod_id = '"+invProductId+"' OR id = '"+invProductId+"'";	
			st3.execute(updatePrOr);
			%>InvProdId: <%=invProductId%><br><%
		}
			%>Inv Amounts Updated: Product ID <%=productId%><br><%
}
	try { st.close(); } catch (Exception e) {}
	try { st2.close(); } catch (Exception e) {}
	try { st3.close(); } catch (Exception e) {}
	try { conn.close(); } catch (Exception e) {}
%><hr><%=y%> Inventory records created, <%=x%> products updated.</body></html>