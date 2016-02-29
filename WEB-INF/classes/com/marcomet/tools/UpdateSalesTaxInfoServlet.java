/**********************************************************************
Description:	This class is used for a quick update and recalculate of 
				sales tax information for a job.
**********************************************************************/

package com.marcomet.tools;

import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.jdbc.DBConnect;
import com.marcomet.workflow.actions.CalculateJobCosts;

public class UpdateSalesTaxInfoServlet extends HttpServlet{

	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
	
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
			
		} catch (Exception ex) {
			throw new ServletException("Error in ConfirmOrder.execute " + ex.getMessage());
		}finally{
			try{
				conn.close();
			}catch(Exception e){
				;
			}
			conn = null;					
		}
	
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this,request,response);	
		
	}

}