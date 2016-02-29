package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will recieve/update db for a submited Final Invoice.

**********************************************************************/

import com.marcomet.jdbc.*;
import com.marcomet.files.*;
import com.marcomet.commonprocesses.*;

import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;

public class SubmitFinalInvoice implements ActionInterface {


	
	public SubmitFinalInvoice() {
		
	}
	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {
	
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
	
		//contact information
		int contactId;
		int companyId;
		

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();

			//setup customer contactid and companyid
			String contactQuery="SELECT o.buyer_company_id 'companyid', o.buyer_contact_id 'contactid' FROM jobs j, projects p, orders o WHERE j.project_id = p.id AND p.order_id = o.id AND j.id = " + request.getParameter("jobId");
			Statement qs1 = conn.createStatement();
			ResultSet rs1 = qs1.executeQuery(contactQuery);
			rs1.next();
			
			contactId = rs1.getInt("contactid");
			companyId = rs1.getInt("companyid");
			
			String taxQuery = "UPDATE sales_tax SET entity = ?, rate = ?, tax_shipping = ?, tax_job = ?, buyer_exempt = ? WHERE job_id = ?";		
		
		
			PreparedStatement updateTax = conn.prepareStatement(taxQuery);
			updateTax.setInt(1,Integer.parseInt(request.getParameter("taxEntity")));
			updateTax.setDouble(2, Double.parseDouble(request.getParameter("taxRate")));
			updateTax.setInt(3,Integer.parseInt(request.getParameter("taxShipping")));
			updateTax.setInt(4,Integer.parseInt(request.getParameter("taxJob")));
			updateTax.setInt(5,Integer.parseInt(request.getParameter("buyerExempt")));
			updateTax.setInt(6,Integer.parseInt(request.getParameter("jobId")));
			updateTax.execute();

			HttpSession session = request.getSession();
			int userId = Integer.parseInt((String)session.getAttribute("contactId"));
						
			//String messageQuery = "insert into form_messages (job_id, contact_id, form_id, message) values (" + request.getParameter("jobId") + ", " + userId + ", '3' , '" + request.getParameter("message") + "')";
			String messageQuery = "INSERT INTO form_messages (job_id, contact_id, form_id, message) VALUES (?,?,?,?)";
			
			PreparedStatement insertMessage = conn.prepareStatement(messageQuery);
			insertMessage.setInt(1,Integer.parseInt(request.getParameter("jobId")));
			insertMessage.setInt(2,userId);
			insertMessage.setInt(3,3);
			insertMessage.setString(4,request.getParameter("message"));
			
			
			insertMessage.execute();

			ShippedMaterialsProcessor smp = new ShippedMaterialsProcessor();
			smp.execute(request, response);
			
			String invoiceAmount = request.getParameter("remainder");

			ProcessARInvoice pari = new ProcessARInvoice();
			pari.setDeposited(invoiceAmount);
			pari.setInvoiceAmount(invoiceAmount);
//			pari.setShippingAmount(request.getParameter("shipping"));
//			pari.setSalesTax(request.getParameter("salesTax"));
			pari.setBillToContactId(contactId);
			pari.setBillToCompanyId(companyId);
			pari.setInvoiceType(3);
			int invoiceId = pari.insert();

			ProcessARInvoiceDetail parid = new ProcessARInvoiceDetail();
			parid.setJobId(request.getParameter("jobId"));
			parid.setInvoiceId(invoiceId);
			parid.setDeposited(invoiceAmount);
			parid.setInvoiceAmount(invoiceAmount);
//			parid.setShippingAmount(request.getParameter("shipping"));
//			parid.setSalesTax(request.getParameter("salesTax"));
			parid.insert();
			
			CalculateJobCosts cjc = new CalculateJobCosts();
			cjc.execute(request, response);
			 
		} catch (ServletException ex) {
			throw new ServletException("SubmitFinalInvoice exception " + ex.getMessage());
		} catch (Exception ex) {
			throw new ServletException("SubmitFinalInvoice exception " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	
		return new Hashtable();
		
	}
	public void finalize() {
		
	}
}
