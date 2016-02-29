package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will process a shipment and apply a deduction from the inventory.

**********************************************************************/

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;

public class InventoryProcessor  implements ActionInterface{
		
	
	public InventoryProcessor() {
		
	}

	public Hashtable execute(MultipartRequest mr, HttpServletResponse res) throws Exception {
		
		return new Hashtable();
		
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception{
		if (!(request.getParameter("cost").equals("")) && !(request.getParameter("cost") == null)) {
			Connection conn = null; 

			try {			
				conn = DBConnect.getConnection();
				HttpSession session = request.getSession();
				String shipId="";
				if (request.getParameter("adjustment_type_id")!=null && request.getParameter("adjustment_type_id").equals("1")){
					String shipSQL="select max(id) from shipping_data where job_id='"+request.getParameter("jobId")+"' and date='"+request.getParameter("adjdate")+"'";
					PreparedStatement st = conn.prepareStatement(shipSQL);
					ResultSet rs = st.executeQuery();
					if (rs.next()){
						shipId=rs.getString(1);
					}
				}
				String userid = (String)session.getAttribute("contactId");
				String quantitySign=((request.getParameter("adjustment_action")!=null && request.getParameter("adjustment_action").equals("1"))?"":"-");
				String query = "insert into inventory (product_id,root_inv_prod_id,root_inv_prod_code,adjustment_type_id,amount,adjustment_date,adjustor_contact_id,warehouse_id,adjustment_action,job_id,ship_id) values (?,?,?,?,?,?,?,?,?,?,?)";
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
				inventory.setString(10, ((request.getParameter("jobId")==null)?"":request.getParameter("jobId")) );
				inventory.setString(11, shipId);
				inventory.execute();
			} catch(Exception ex) {
				throw new Exception("Error in ProcessInventory " + ex.getMessage());
			} finally {
				try { conn.close(); } catch ( Exception x) { conn = null; }
			}
		}
		return new Hashtable();	
	}
	
	public void finalize() {
		
	}
}
