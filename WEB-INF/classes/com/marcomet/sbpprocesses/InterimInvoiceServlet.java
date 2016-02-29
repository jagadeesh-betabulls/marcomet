package com.marcomet.sbpprocesses;

/**********************************************************************
Description:	This class will update the status of a job
**********************************************************************/

import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;
import com.marcomet.commonprocesses.*;
import com.marcomet.workflow.actions.*;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.ReturnPageContentServlet;

public class InterimInvoiceServlet extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {

		
		
		int companyId;
		int contactId;

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
		
			//setup customer contactid and companyid
			String contactQuery="SELECT buyer_company_id, buyer_contact_id FROM jobs j, projects p, orders o WHERE j.project_id = p.id AND p.order_id = o.id AND j.id = " + request.getParameter("jobId");
			Statement qs1 = conn.createStatement();
			ResultSet rs1 = qs1.executeQuery(contactQuery);
			contactId = rs1.getInt("buyer_contact_id");
			companyId = rs1.getInt("buyer_company_id");

			String taxQuery = "insert into sales_tax (entity, rate, tax_shipping, tax_job, buyer_exempt) values ('" + request.getParameter("taxEntity") + "', " + request.getParameter("taxRate") + ", " + request.getParameter("taxShipping") + ", " + request.getParameter("taxJob") + ", " + request.getParameter("buyerExempt") + ")";
			PreparedStatement insertTax = conn.prepareStatement(taxQuery);
			insertTax.execute();

			HttpSession session = request.getSession();
			int userId = Integer.parseInt((String)session.getAttribute("contactId"));
						
			String messageQuery = "insert into form_messages (job_id, contact_id, form_id, message) values (" + request.getParameter("jobId") + ", " + userId + ", '3' , '" + request.getParameter("message") + "')";
			PreparedStatement insertMessage = conn.prepareStatement(messageQuery);
			insertMessage.execute();

			String invoiceAmount = "0.00";
			if (request.getParameter("billType").equals("1")) {
				invoiceAmount = request.getParameter("remainder");
			} else {
				invoiceAmount = request.getParameter("amount");
			}

			ProcessARInvoice pari = new ProcessARInvoice();
			pari.setDeposited(invoiceAmount);
			pari.setInvoiceAmount(invoiceAmount);
			//pari.setShippingAmount(request.getParameter("shipping"));
			//pari.setSalesTax(request.getParameter("salesTax"));
			pari.setBillToContactId(contactId);
			pari.setBillToCompanyId(companyId);
			pari.setInvoiceType(2);
			int invoiceId = pari.insert();

			ProcessARInvoiceDetail parid = new ProcessARInvoiceDetail();
			parid.setJobId(request.getParameter("jobId"));
			parid.setInvoiceId(invoiceId);
			parid.setDeposited(invoiceAmount);
			parid.setInvoiceAmount(invoiceAmount);
			//parid.setShippingAmount(request.getParameter("shipping"));
			//parid.setSalesTax(request.getParameter("salesTax"));
			parid.insert();

			ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
			rpcs.printNextPage(this, request, response);
			
			CalculateJobCosts cjc = new CalculateJobCosts();
			cjc.execute(request, response);
			 
		} catch (ServletException ex) {
			throw new ServletException("InterimShipmentServlet servlet exception " + ex.getMessage());
		} catch (Exception ex) {
			throw new ServletException("InterimShipmentServlet exception " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		

	}
}
