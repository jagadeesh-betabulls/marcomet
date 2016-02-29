package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will recalculate inventory and on-order amounts for a given product.

**********************************************************************/

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;

public class InventoryUpdater  implements ActionInterface{
	
	
	public InventoryUpdater() {
		
	}

	public void calculate(int productId) throws Exception {
		this.calculate((new Integer(productId)).toString());
	}

		public void calculate() throws Exception{
			Connection conn = null; 

			try {			
				conn = DBConnect.getConnection();
				String productId="";
				String invProductId = "0";
				String prodOnOrderAmt="0";	
				String invOnOrderAmt="0";	
				String invAmt="0";	
				String invAction="0";
				String invInitDate="9999"; 

				Statement st = conn.createStatement();
				Statement st3 = conn.createStatement();

				String productSQL="SELECT * from products where inventory_product_flag=1 and status_id=2";

				ResultSet rsProds=st.executeQuery(productSQL);

				while(rsProds.next()){
				  productId=rsProds.getString("id");
				  invProductId=((rsProds.getString("root_inv_prod_id").equals("0"))?rsProds.getString("id"):rsProds.getString("root_inv_prod_id"));
				  if (!(invProductId.equals("0"))){
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

					if (!(invInitDate.equals("9999"))){
						//Zero out inventory amount values for all inventory transactions prior to the first manual adjustment for the product, put the old values in the notes field
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
					}else{
						String updatePrOr="UPDATE products SET on_order_amount = "+prodOnOrderAmt+" WHERE id = '"+productId+"'";	
						st3.execute(updatePrOr);

						updatePrOr="UPDATE products SET inventory_init_date=if('"+invInitDate+"'='2020-01-01',Null,'"+invInitDate+"'),inv_on_order_amount = "+invOnOrderAmt+", inventory_initialized="+invAction+", inventory_amount = " + ((invAction.equals("0"))?"0":invAmt) + " WHERE root_inv_prod_id = '"+invProductId+"' OR id = '"+invProductId+"'";	
						st3.execute(updatePrOr);
					}
				}
			}
		} catch(Exception ex) {
			throw new Exception("Error in ProcessInventory " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}

	public void calculate(String productId) throws Exception{
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String invProductId = "0";
			String prodOnOrderAmt="0";	
			String invOnOrderAmt="0";	
			String invAmt="0";	
			String invAction="0";
			String invInitDate="9999"; 
			
			Statement st = conn.createStatement();
			Statement st3 = conn.createStatement();

			String productSQL="SELECT * from products where inventory_product_flag=1 and id='"+productId+"'";

			ResultSet rsProds=st.executeQuery(productSQL);
			
			if(rsProds.next()){
			  invProductId=((rsProds.getString("root_inv_prod_id").equals("0"))?rsProds.getString("id"):rsProds.getString("root_inv_prod_id"));
			  if (!(invProductId.equals("0"))){
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
				
				if (!(invInitDate.equals("9999"))){
					//Zero out inventory amount values for all inventory transactions prior to the first manual adjustment for the product, put the old values in the notes field
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
				}else{
					String updatePrOr="UPDATE products SET on_order_amount = "+prodOnOrderAmt+" WHERE id = '"+productId+"'";	
					st3.execute(updatePrOr);

					updatePrOr="UPDATE products SET inventory_init_date=if('"+invInitDate+"'='2020-01-01',Null,'"+invInitDate+"'),inv_on_order_amount = "+invOnOrderAmt+", inventory_initialized="+invAction+", inventory_amount = " + ((invAction.equals("0"))?"0":invAmt) + " WHERE root_inv_prod_id = '"+invProductId+"' OR id = '"+invProductId+"'";	
					st3.execute(updatePrOr);
				}
			}
		}
	} catch(Exception ex) {
		throw new Exception("Error in ProcessInventory " + ex.getMessage());
	} finally {
		try { conn.close(); } catch ( Exception x) { conn = null; }
	}
}

	
	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {
	
		try {

			String productId = mr.getParameter("productId");
			this.calculate(productId);
				
		} catch (Exception ex) {
			throw new Exception("CalculateInventoryAmounts error " + ex.getMessage());
		}

		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
			
		try {
			if(request.getAttribute("productId")!=null){
				String productId = (String)request.getAttribute("orderId");
				this.calculate(productId);
			}else{	
				String productId = request.getParameter("productId");
				this.calculate(productId);
			}	
				
		} catch (Exception ex) {
			throw new Exception("CalculateInventoryAmounts error " + ex.getMessage());
		}

		return new Hashtable();
	}
}
