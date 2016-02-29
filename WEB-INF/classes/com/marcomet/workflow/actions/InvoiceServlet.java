package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will create an invoice

**********************************************************************/
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Hashtable;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.marcomet.commonprocesses.ProcessARInvoice;
import com.marcomet.commonprocesses.ProcessARInvoiceDetail;
import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;

public class InvoiceServlet  implements ActionInterface  {

	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {	
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
				
		Connection conn = null; 
		int companyId = 0;
		int vendorId;
		int contactId = 0;

		try {
			conn = DBConnect.getConnection();
			//setup customer contactid and companyid
			String contactQuery="SELECT buyer_company_id, buyer_contact_id FROM jobs j, projects p, orders o WHERE j.project_id = p.id AND p.order_id = o.id AND j.id = " + request.getParameter("jobId");
			Statement qs1 = conn.createStatement();
			ResultSet rs1 = qs1.executeQuery(contactQuery);
			if (rs1.next()) {
				contactId = rs1.getInt("buyer_contact_id");
				companyId = rs1.getInt("buyer_company_id");
			}

//			String taxQuery = "insert into sales_tax (entity, rate, tax_shipping, tax_job, buyer_exempt) values ('" + request.getParameter("taxEntity") + "', " + request.getParameter("taxRate") + ", " + request.getParameter("taxShipping") + ", " + request.getParameter("taxJob") + ", " + request.getParameter("buyerExempt") + ")";
//			PreparedStatement insertTax = conn.prepareStatement(taxQuery);
//			insertTax.execute();

			HttpSession session = request.getSession();
			int userId = Integer.parseInt((String)session.getAttribute("contactId"));		
			String messageQuery = "insert into form_messages (job_id, contact_id, form_id, message) values (?,?,?,?)";
			PreparedStatement insertMessage = conn.prepareStatement(messageQuery);
			insertMessage.setInt(1,Integer.parseInt(request.getParameter("jobId")));
			insertMessage.setInt(2,userId);
			insertMessage.setInt(3,3); 
			insertMessage.setString(4,request.getParameter("message"));
			insertMessage.execute();

			String invoiceAmount = request.getParameter("currentInvoiceAmount");
			String purchaseAmount = request.getParameter("billAmount");
			String invoiceMessage = request.getParameter("message");					
			String invoiceNumber=((request.getParameter("invoiceNumber")==null)?"":request.getParameter("invoiceNumber"));
			vendorId=Integer.parseInt((request.getParameter("vendorId")==null?"0":request.getParameter("vendorId")));			
			ProcessARInvoice pari = new ProcessARInvoice();
			pari.setDeposited(0);
			pari.setInvoiceAmount(invoiceAmount);
			pari.setPurchaseAmount(purchaseAmount);	
			pari.setSalesTaxEntityId(request.getParameter("taxEntity"));	
			pari.setInvoiceMessage(invoiceMessage);						
			pari.setShippingAmount(request.getParameter("shipAmount"));
			pari.setSalesTax(request.getParameter("salestaxAmount"));
			pari.setPaymentOption(request.getParameter("paymentOption"));			
			pari.setBillToContactId(contactId);
			pari.setBillToCompanyId(companyId);
			pari.setInvoiceType(2);
			pari.setInvoiceNumber(invoiceNumber);
			pari.setVendorId(vendorId);						
			int invoiceId = pari.insert();

			ProcessARInvoiceDetail parid = new ProcessARInvoiceDetail();
			parid.setJobId(request.getParameter("jobId"));
			parid.setInvoiceId(invoiceId);
			parid.setDeposited(0);
			parid.setPurchaseAmount(purchaseAmount);
			parid.setInvoiceAmount(invoiceAmount);						
			parid.setShippingAmount(request.getParameter("shipAmount"));
			parid.setSalesTax(request.getParameter("salestaxAmount"));
			parid.insert();

			return new Hashtable();	
		//	CalculateJobCosts cjc = new CalculateJobCosts();
		//	cjc.execute(request, response);
			 
		} catch (Exception ex) {
			throw new ServletException("InvoiceServlet exception " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	}
	public Hashtable execute(int jobId, int userId) throws Exception {
		
		Connection conn = null; 
		int companyId = 0;
		int vendorId;
		int contactId = 0;

		try {
			conn = DBConnect.getConnection();
			double invoiceAmount = 0.00;
			String purchaseAmount = "";
			String invoiceMessage = "";					
			String invoiceNumber="";
			String taxEntity="";
			String shipAmount="0";
			String salesTaxAmount="0";
			String paymentOption="2";
			double leftToBill=0.00;
			boolean billThis=false;
			vendorId=0;
			String contactQuery="SELECT j.id,vendor_id,price,if(billable-billed>.1 and billed=0,'true','false') as billThis,(billable-billed) as leftToBill,if(s.entity is null,0,s.entity) as taxEntity,shipping_price,Round(if(s.buyer_exempt=1 or s.tax_shipping is null or s.tax_shipping=0,0,(s.rate/100)*shipping_price),2) as taxShipping,Round(if(s.buyer_exempt=1 or s.tax_job is null or s.tax_job=0,0,(s.rate/100)*price),2) as taxJob,jbuyer_company_id, jbuyer_contact_id FROM jobs j left join sales_tax s on s.job_id=j.id WHERE j.id=" + jobId;
			Statement qs1 = conn.createStatement();
			ResultSet rs1 = qs1.executeQuery(contactQuery);
			if (rs1.next()) {
				contactId = rs1.getInt("jbuyer_contact_id");
				companyId = rs1.getInt("jbuyer_company_id");
				salesTaxAmount=(rs1.getDouble("taxShipping")+rs1.getDouble("taxJob"))+"";
				invoiceAmount = rs1.getDouble("price")+rs1.getDouble("shipping_price")+rs1.getDouble("taxShipping")+rs1.getDouble("taxJob");
				leftToBill=rs1.getDouble("leftToBill");
				invoiceAmount=((invoiceAmount>leftToBill)?leftToBill:invoiceAmount);
				purchaseAmount = rs1.getString("price");	
				taxEntity = rs1.getString("taxEntity");
				vendorId=rs1.getInt("vendor_id");
				shipAmount = rs1.getString("shipping_price");
				billThis=((rs1.getString("billThis").equals("true"))?true:false);
			}
		  if(billThis){
			String queryVendor = "SELECT payment_option FROM vendor_payment_processing WHERE vendor_id = " + vendorId;
			ResultSet rsVendor = qs1.executeQuery(queryVendor);
			if(rsVendor.next()){
				paymentOption=rsVendor.getString("payment_option");
			}
				
			String messageQuery = "insert into form_messages (job_id, contact_id, form_id, message) values (?,?,?,?)";
			PreparedStatement insertMessage = conn.prepareStatement(messageQuery);
			insertMessage.setInt(1,jobId);
			insertMessage.setInt(2,userId);
			insertMessage.setInt(3,3); 
			insertMessage.setString(4,"");
			insertMessage.execute();
			
			ProcessARInvoice pari = new ProcessARInvoice();
			pari.setDeposited(0);
			pari.setInvoiceAmount(invoiceAmount);
			pari.setPurchaseAmount(purchaseAmount);	
			pari.setSalesTaxEntityId(taxEntity);	
			pari.setInvoiceMessage(invoiceMessage);						
			pari.setShippingAmount(shipAmount);
			pari.setSalesTax(salesTaxAmount);
			pari.setPaymentOption(paymentOption);			
			pari.setBillToContactId(contactId);
			pari.setBillToCompanyId(companyId);
			pari.setInvoiceType(2);
			pari.setInvoiceNumber(invoiceNumber);
			pari.setVendorId(vendorId);						
			int invoiceId = pari.insert();

			ProcessARInvoiceDetail parid = new ProcessARInvoiceDetail();
			parid.setJobId(jobId);
			parid.setInvoiceId(invoiceId);
			parid.setDeposited(0);
			parid.setPurchaseAmount(purchaseAmount);
			parid.setInvoiceAmount(invoiceAmount);						
			parid.setShippingAmount(shipAmount);
			parid.setSalesTax(salesTaxAmount);
			parid.insert();
		  }
			return new Hashtable();	
		//	CalculateJobCosts cjc = new CalculateJobCosts();
		//	cjc.execute(request, response);
			 
		} catch (Exception ex) {
			throw new ServletException("InvoiceServlet exception " + ex.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
}
