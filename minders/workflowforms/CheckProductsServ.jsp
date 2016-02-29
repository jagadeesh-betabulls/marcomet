<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.workflow.actions.*,com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="cjc" class="com.marcomet.workflow.actions.InventoryUpdater" scope="session" />
<html><head><title>Update Product Inventory Changes</title>
<link rel="stylesheet" href="/htdocs/commerce/styles/marcomet.css" type="text/css"></head><body><p class='Title'>Update Product Inventory Changes</p><%
int x=0;
int y=0;
String productId=((request.getParameter("productId")==null || request.getParameter("productId").equals(""))?"0":request.getParameter("productId"));
InventoryUpdater iu = new InventoryUpdater();
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
if (productId.equals("0")){
	iu.calculate();
}else{
	iu.calculate(productId);
	x++;
}
			%>Inv Amounts Updated: Product ID <%=productId%><br><%
			try { st.close(); } catch (Exception e) {}
			try { st2.close(); } catch (Exception e) {}
			try { st3.close(); } catch (Exception e) {}
			try { conn.close(); } catch (Exception e) {}
			
%><hr><%=y%> Inventory records created, <%=x%> products updated.</body></html>