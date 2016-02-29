package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will perform needed actions for the transfer 
				of funds from Marcomet Escrow to Seller accounts, plus
				to pay Marcomet's fee.
				
Notes:			Rather than recalculating what should already recalculated,
				this class doesn't look anywhere else for information on a job
				other than on the jobs table.  So, this class calls calcjobcost before
				and after processing the accounting stuff		

Triggers(Carl):	an AR_Collection Created, or Final Delivery Accepted

Filter(Carl):	Fully Collected(job), and Delivery accepted.
	
**********************************************************************/

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessAPInvoice;
import com.marcomet.commonprocesses.ProcessAPInvoiceDetail;
import com.marcomet.commonprocesses.ProcessARInvoice;
import com.marcomet.commonprocesses.ProcessARInvoiceDetail;
import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;


public class FinalMarcometSettlement implements ActionInterface {

	/*
	1) create an final invoice for customer releasing the escrow, a 0 invoice,
	2) create an account payable from Marcomet escrow to sitehost the markup, markup shipping
	3) create an account payable from Marcomet escrow to vendor cost, s/h	
	3) create an account payable from Marcomet escrow to Marcomet fee, shipping fee.
	*/
		
	//job information
	private String jobId;          //since it's going to be a string from req, and not needed to cast it.
	private double cost;
	private double mu;
	private double fee;
	private double price;
	private double shipping;
	private double salesTax;
	private double escrow;
	private int vendorId;
	private int vendorCompanyId;
	private int vendorContactId;
	private int buyerContactId;
	private int buyerCompanyId;
	private int siteHostContactId;
	private int siteHostCompanyId;
	
	private double shippingCost;
	private double shippingMu;
	private double shippingFee;
	private double shippingPrice;	
	
	public FinalMarcometSettlement(){
			
	}
	
	private boolean checkForFinalStatus(){
		double check = escrow - (price + shipping + salesTax);
		
		if(check <= 0.05 && check >= -0.05){
			return true;
		}else{
			return false;
		}
	}
	private void createTransactions() throws SQLException{
		DateFormat mysqlFormat = new SimpleDateFormat("yyyy-MM-dd");

		//create final invoice for customer 0 balence
		ProcessARInvoice pari = new ProcessARInvoice();
		pari.setPurchaseAmount(price);
		pari.setShippingAmount(shipping);
		pari.setSalesTax(salesTax);
		pari.setBillToContactId(1);
		pari.setBillToCompanyId(1);
		pari.setDeposited(- (escrow));
		pari.setInvoiceAmount(0);
		pari.setInvoiceType(3);        //bad hard coding to reflect that this is a final invoice
		pari.insert();
					
		ProcessARInvoiceDetail parid = new ProcessARInvoiceDetail();
		parid.setJobId(jobId);
		parid.setInvoiceId(pari.getId());
		parid.setPurchaseAmount(price);
		parid.setShippingAmount(shipping);
		parid.setSalesTax(salesTax);
		parid.setDeposited(-(escrow));
		parid.setInvoiceAmount(0);
		parid.insert();
		
		//***create ap for cost,s/h and sales tax to be released from escrow to vendor
		ProcessAPInvoice papi = new ProcessAPInvoice();
		//papi.setVendorId(vendorId);		
		papi.setInvoiceDate(mysqlFormat.format(new java.util.Date()));	
		papi.setInvoiceAmount(cost+shippingCost+salesTax);
		papi.setPayToContactId(vendorContactId);
		papi.setPayToCompanyId(vendorCompanyId);
		papi.insert();

		ProcessAPInvoiceDetail papid = new ProcessAPInvoiceDetail();
		papid.setApInvoiceId(papi.getId());
		papid.setJobId(jobId);
		papid.setAmount(cost+shippingCost+salesTax);
		papid.setApRecipientTypeId(3);
		papid.insert();

		//clear variables
		papi.clear();					
		papid.clear();					
		
		//***create ap for mu to be released from escrow to site host
		//papi.setVendorId(lookUpVendorId(siteHostCompanyId));
		papi.setInvoiceDate(mysqlFormat.format(new java.util.Date()));
		papi.setInvoiceAmount(mu + shippingMu);		
		papi.setPayToContactId(siteHostContactId);
		papi.setPayToCompanyId(siteHostCompanyId);
		papi.insert();

		papid.setApInvoiceId(papi.getId());
		papid.setJobId(jobId);
		papid.setAmount(mu + shippingMu);
		papid.setApRecipientTypeId(2);
		papid.insert();	
		
		//clear variables
		papi.clear();					
		papid.clear();					

		//***create ap for fee to be released from escrow to marcomet
		//Carl wanted to note, that this violates the future many to one relationship for contacts to companies.
		//papi.setVendorId(getMarcometVendorId());
		papi.setInvoiceDate(mysqlFormat.format(new java.util.Date()));
		papi.setInvoiceAmount(fee + shippingFee);		
		//papi.setPayToContactId(getMarcometContactId());
		//papi.setPayToCompanyId(getMarcometCompanyId());
		papi.setPayToContactId("1");
		papi.setPayToCompanyId("1");
		papi.insert();

		papid.setApInvoiceId(papi.getId());
		papid.setJobId(jobId);
		papid.setAmount((price + shipping + salesTax) - (cost+mu+shippingCost+shippingMu+salesTax));  //this makes marcomet assume any loss due to math
		papid.setApRecipientTypeId(1);
		papid.insert();					

	}
	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {
		
		CalculateJobCosts cjc = new CalculateJobCosts();
		
		jobId = mr.getParameter("jobId");
		
		cjc.calculate(jobId);
		processSettlement();
		cjc.calculate(jobId);	
		
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		CalculateJobCosts cjc = new CalculateJobCosts();
		jobId = request.getParameter("jobId");
		cjc.calculate(jobId);		
		processSettlement();
		cjc.calculate(jobId);

		return new Hashtable();
	}
	
	protected void finalize() {
		
	}
	private void getJobInformation()throws SQLException{
		

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
		
			// get job info	
			String sql1 = "SELECT j.cost, j.mu, j.fee, j.price, j.shipping_price, j.sales_tax, j.escrow_amount, j.vendor_id, v.company_id 'vendor_company_id', j.vendor_contact_id, o.buyer_contact_id, o.buyer_company_id, o.site_host_contact_id, sh.company_id 'site_host_company_id' FROM jobs j, vendors v, site_hosts sh, projects p, orders o WHERE o.id = p.order_id AND p.id = j.project_id AND sh.id = o.site_host_id AND v.id = j.vendor_id AND j.id = " + jobId;	
			Statement qs1 = conn.createStatement();
			ResultSet rs1 = qs1.executeQuery(sql1);		
			if(rs1.next()){
				cost = rs1.getDouble("cost");
				mu = rs1.getDouble("mu");
				fee = rs1.getDouble("fee");
				price = rs1.getDouble("price");
				shipping = rs1.getDouble("shipping_price");
				salesTax = rs1.getDouble("sales_tax");
				escrow = rs1.getDouble("escrow_amount");		
				vendorId = rs1.getInt("vendor_id");
				vendorCompanyId = rs1.getInt("vendor_company_id");
				vendorContactId = rs1.getInt("vendor_contact_id"); 
				buyerContactId = rs1.getInt("buyer_contact_id");
				buyerCompanyId = rs1.getInt("buyer_company_id");
				siteHostCompanyId = rs1.getInt("site_host_company_id");
				siteHostContactId = rs1.getInt("site_host_contact_id");
				
			}else{
				throw new SQLException("FMS couldn't find job: " + jobId);
			}
		
			
			//must add any job changes since calcjob costs doesn't update cost,mu,fee in jobs from approved job changes.	
			String qChanges = "SELECT SUM(jc.cost) 'cost', SUM(jc.mu) 'mu', SUM(jc.fee) 'fee', SUM(jc.price) AS changes FROM jobchanges jc, lu_job_change_statuses ljcs WHERE UCASE(ljcs.value) = 'APPROVED' AND ljcs.id = jc.statusid AND jc.jobid = " + jobId;
			Statement qsChanges = conn.createStatement();
			ResultSet rsChanges = qsChanges.executeQuery(qChanges);
			if(rsChanges.next()){
				cost += rsChanges.getDouble("cost");
				mu += rsChanges.getDouble("mu");
				fee += rsChanges.getDouble("fee");		
			}
			
			
			//get shipping information, to include fees no 		
			String sql2 = "SELECT SUM(cost) 'cost', SUM(mu) 'mu', SUM(fee) 'fee', SUM(price) 'price' FROM shipping_data WHERE job_id = " + jobId;	
			Statement qs2 = conn.createStatement();
			ResultSet rs2 = qs2.executeQuery(sql2);		
			if(rs2.next()){		
				shippingCost = rs2.getDouble("cost");
				shippingMu = rs2.getDouble("mu");
				shippingFee = rs2.getDouble("fee");
				shippingPrice = rs2.getDouble("price");		
			}
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
/*	
	private String getMarcometCompanyId() throws SQLException{
		if (conn == null) {
			if (sc ==null) {
				sc = new SimpleConnection();
			}	
			conn = sc.getConnection();
		}
		String sql = "SELECT v.company_id FROM vendors v, companies c WHERE c.id = v.company_id and c.company_name like '%marcomet%'";	
		Statement qs = conn.createStatement();
		ResultSet rs1 = qs.executeQuery(sql);		
		if(rs1.next()){	
			return rs1.getString(1);	
		}else{
			throw new SQLException("couldn't find marcomet company id");
		}	
	}
	private String getMarcometContactId() throws SQLException{
		if (conn == null) {
			if (sc ==null) {
				sc = new SimpleConnection();
			}	
			conn = sc.getConnection();
		}
		String sql = "SELECT con.id FROM vendors v, companies c, contacts con WHERE c.id = con.companyid AND c.id = v.company_id AND c.company_name LIKE '%marcomet%'";	
		Statement qs = conn.createStatement();
		ResultSet rs1 = qs.executeQuery(sql);		
		if(rs1.next()){	
			return rs1.getString(1);	
		}else{
			throw new SQLException("couldn't find marcomet contact id");
		}	
	}
*/	
	private String getMarcometVendorId() throws SQLException{

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String sql = "SELECT v.id FROM vendors v WHERE v.company_id = 1";	
			Statement qs = conn.createStatement();
			ResultSet rs1 = qs.executeQuery(sql);		
			if(rs1.next()){	
				return rs1.getString(1);	
			}else{
				throw new SQLException("couldn't find marcomet vendor id");
			}
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	
	private void processSettlement() throws SQLException{

		getJobInformation();

		if(checkForFinalStatus()){
			createTransactions();
			updateJobPayable();
		}else{
			throw new SQLException("false: escrow: " + escrow + ", price: " + price + ", shipping: " + shipping);
		}			
	}
	
	private void updateJobPayable() throws SQLException{

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String payableQuery = "SELECT SUM(aid.amount) FROM ap_invoices ai, ap_invoice_details aid, jobs j WHERE aid.ap_invoiceid = ai.id AND j.vendor_id = ai.vendorid AND j.id = aid.jobid AND aid.jobid = " + jobId;	
			ResultSet rs1 = qs.executeQuery(payableQuery);		
			if(rs1.next()){	
				String insertPayable = "update jobs set payable = " + rs1.getDouble(1) + " where id = " + jobId;	
				qs.execute(insertPayable);	
			}
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
}
