/**********************************************************************
Description:	This Class Sends out a email to vendors grouping their jobs
				together
	
**********************************************************************/

package com.marcomet.workflow.actions;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessJob1;
import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;


public class ConfirmOrder implements ActionInterface {

	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {
		if (1==1) {
			throw new Exception("Error in ConfirmOrder.execute: In the Multipart execute");
		}
		
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		Connection conn = null;
	
		try {			
			conn = DBConnect.getConnection();
			
			//delete any other taxes for this job, since there should be a one to one relation ship
			String deleteTaxQuery = "DELETE FROM sales_tax WHERE job_id = ?";
			PreparedStatement deleteTax = conn.prepareStatement(deleteTaxQuery);
			deleteTax.setInt(1,Integer.parseInt(request.getParameter("jobId")));
			deleteTax.execute();
			
			//insert tax information
			String taxQuery = "INSERT INTO sales_tax(job_id, entity, rate, tax_shipping, tax_job, buyer_exempt) VALUES (?,?,?,?,?,?)";    
			PreparedStatement insertTax = conn.prepareStatement(taxQuery);
			
			insertTax.setInt(1,Integer.parseInt(request.getParameter("jobId")));
			insertTax.setInt(2,Integer.parseInt(request.getParameter("taxEntity")));
			insertTax.setDouble(3,Double.parseDouble(request.getParameter("taxRate")));
			insertTax.setInt(4,Integer.parseInt(request.getParameter("taxShipping")));
			insertTax.setInt(5,Integer.parseInt(request.getParameter("taxJob")));
			insertTax.setInt(6,Integer.parseInt(request.getParameter("buyerExempt")));
			
			insertTax.execute();

			CalculateJobCosts cjc = new CalculateJobCosts();
			cjc.execute(request, response);
			
			//insert internal reference
			ProcessJob1 pj = new ProcessJob1();
			pj.updateJob(Integer.parseInt(request.getParameter("jobId")), "internal_reference_data", request.getParameter("internalReference"));
			
		} catch (Exception ex) {
			throw new Exception("Error in ConfirmOrder.execute " + ex.getMessage());
		}finally{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return new Hashtable();
	}
}
