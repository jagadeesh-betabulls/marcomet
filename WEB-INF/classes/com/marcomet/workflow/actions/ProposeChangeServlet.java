package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This Class submits entered job data prior to redirecting
				to the change form.
**********************************************************************/

import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessJob1;
import com.marcomet.jdbc.DBConnect;


public class ProposeChangeServlet extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

	
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

			//insert internal reference
			ProcessJob1 pj = new ProcessJob1();
			pj.updateJob(Integer.parseInt(request.getParameter("jobId")), "internal_reference_data", request.getParameter("internalReference"));

			RequestDispatcher rd = getServletContext().getRequestDispatcher("/minders/workflowforms/ProposeJobChangeForm.jsp?jobId=" + request.getParameter("jobId"));
			rd.forward(request, response);

		} catch (Exception ex) {
			throw new ServletException("Error in ProposeChange " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	}
}
