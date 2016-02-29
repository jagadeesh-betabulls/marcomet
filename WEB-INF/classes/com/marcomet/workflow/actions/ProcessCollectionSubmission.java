/**********************************************************************
Description:	This class will process a collection form submission.

				Check Credit Card
				Update User info if changed
				Insert Collection and Collection Details
				Return if any errors are found.
		
**********************************************************************/

package com.marcomet.workflow.actions;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Hashtable;
import java.util.Vector;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.catalog.ShoppingCart;
import com.marcomet.commonprocesses.ProcessARCollection;
import com.marcomet.commonprocesses.ProcessARCollectionDetail;
import com.marcomet.commonprocesses.ProcessARInvoice;
import com.marcomet.commonprocesses.ProcessARInvoiceDetail;
import com.marcomet.commonprocesses.ProcessCompany;
import com.marcomet.commonprocesses.ProcessContact;
import com.marcomet.commonprocesses.ProcessLocation;
import com.marcomet.commonprocesses.ProcessPhone;
import com.marcomet.files.MultipartRequest;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.ProcessCreditCardWithVerisignTool;
import com.marcomet.tools.ProcessACHWithVerisignTool;
import com.marcomet.tools.StringTool;
import com.marcomet.catalog.*;



public class ProcessCollectionSubmission implements ActionInterface{

//***** Credit Card System *******
	
	String authCode = "temp";
	String pnRefId = "temp";
	String bankInfo="";

	//this section will control the flow and test for errors and updates
	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {	
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		//Process The Credit Card	
		Hashtable returnResult = processOrder(request);

		//check to see if the process was valid/completed
		if (((Boolean)returnResult.get("processed")).booleanValue()) {
			authCode = (String)returnResult.get("authCode");
			pnRefId = (String)returnResult.get("pnRefId");
		}else {
			//error present from transaction, return to error page with message
			request.setAttribute("errorMessage",(String)returnResult.get("ccErrorMessage"));
			return new Hashtable();
		}
			
		//Create a Collection from the Credit Card Process.
		createCollection(request);
		
		//was there an update to contact info
		if (request.getParameter("formChangedContact").equals("1")) {
			updateContact(request);
		}					
		
		//was there an update to locations?
		if (request.getParameter("formChangedLocations").equals("1")) {
			updateLocation(request, "Bill");
		}
				
		//was there an update to Phones?
		if (request.getParameter("formChangedPhones").equals("1")) {
			updatePhones(request);
		}
		
		//was there an update to company?
		if (request.getParameter("formChangedCompany").equals("1")) {
			updateCompany(request);
		}
		return new Hashtable();
	}
	
	

	//insert a collection and collection detail for this charge
	private void createCollection(HttpServletRequest req) 
	throws ServletException{
		int jobCount=0;
		int jobId=0;

        String orderId=((req.getAttribute("orderId")==null || req.getAttribute("orderId").toString().equals(""))?"":req.getAttribute("orderId").toString());
        
		//if this is being called from a process that wants to pay the entire order, check to see if there are invoices for the jobs in the order already, if not create them.
		if (!orderId.equals("")){
				//gather the job info from the jobs in the order
				try {
					Connection conn = DBConnect.getConnection();
					Statement qs1 = conn.createStatement();
					ResultSet rs1 = qs1.executeQuery("Select j.id 'jobId',shipping_price,price,sales_tax, shipping_price+price+sales_tax 'jobTotal',vendor_id,jbuyer_contact_id,jbuyer_company_id,entity from jobs j left join sales_tax st on st.job_id=j.id,projects p where p.order_id='"+orderId+"' and p.id=j.project_id");
					while (rs1.next()){
						//create the invoice header
						String invoiceAmount = rs1.getString("jobTotal");
						String purchaseAmount = rs1.getString("price");
						String invoiceMessage = "New Order";					
						String invoiceNumber="";
						int vendorId=rs1.getInt("vendor_id");			
						ProcessARInvoice pari = new ProcessARInvoice();
						pari.setDeposited(0);
						pari.setInvoiceAmount(invoiceAmount);
						pari.setPurchaseAmount(purchaseAmount);	
						pari.setSalesTaxEntityId(rs1.getString("entity"));	
						pari.setInvoiceMessage(invoiceMessage);						
						pari.setShippingAmount(rs1.getString("shipping_price"));
						pari.setSalesTax(rs1.getString("sales_tax"));
						pari.setPaymentOption("1");	
						pari.setBillToContactId(rs1.getString("jbuyer_contact_id"));
						pari.setBillToCompanyId(rs1.getString("jbuyer_company_id"));
						pari.setInvoiceType(2);
						pari.setInvoiceNumber(invoiceNumber);
						pari.setVendorId(vendorId);	
						int invoiceId=0;
						try{
							invoiceId = pari.insert();
						}catch(SQLException sqle) {
							throw new ServletException("ProcessCollectionSubmission, Insertion of Invoice Header Failed" + sqle.getMessage());	
						}
						//create the invoice detail records
					    ProcessARInvoiceDetail parid = new ProcessARInvoiceDetail();
					    parid.setJobId(rs1.getString("jobId"));
					    parid.setInvoiceId(invoiceId);
					    parid.setDeposited(0);
					    parid.setPurchaseAmount(purchaseAmount);
					    parid.setInvoiceAmount(invoiceAmount);						
					    parid.setShippingAmount(rs1.getString("shipping_price"));
					    parid.setSalesTax(rs1.getString("sales_tax"));
					    try{
					    	parid.insert();
					    }catch(SQLException sqle) {
					    	throw new ServletException("ProcessCollectionSubmission, Insertion of Invoice Detail failed: " + sqle.getMessage());	
					    }
						String payType=((req.getParameter("pay_type")==null || req.getParameter("pay_type").equals(""))?"0":req.getParameter("pay_type"));
						payType=((payType.equals("cc"))?"1":payType);
						payType=((payType.equals("ach"))?"4":payType);
						java.text.DateFormat mysqlFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
						ProcessARCollection  parc = new ProcessARCollection();
						parc.setContactId(rs1.getString("jbuyer_contact_id"));
						parc.setCheckNumber(req.getParameter("ccType"));
						parc.setPaymentType(payType);
						parc.setCheckAmount(invoiceAmount);
						parc.setDepositDate(mysqlFormat.format(new java.util.Date()));
						parc.setCheckReference(pnRefId);
						parc.setCheckAuthCode(authCode+bankInfo);

						try {	
							parc.insert();
						}catch(SQLException sqle) {
							throw new ServletException("ProcessCollectionSubmission, Insertion of Collection Failed" + sqle.getMessage());	
						}
								
						ProcessARCollectionDetail parcd = new ProcessARCollectionDetail();
						parcd.setCollectionId(parc.getId());
						parcd.setInvoiceId(invoiceId);
						parcd.setPaymentAmount(invoiceAmount);
						try {
							parcd.insert();	
						}catch(SQLException sqle) {
							throw new ServletException("ProcessCollectionSubmission, Insertion of Collection Detail failed" + sqle.getMessage());	
						}
					}
				} catch (ClassNotFoundException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}else{
				
				java.text.DateFormat mysqlFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
				ProcessARCollection  parc = new ProcessARCollection();
				parc.setContactId( (String)req.getSession().getAttribute("contactId"));
				parc.setCheckNumber(req.getParameter("ccType"));
				parc.setCheckAmount(req.getParameter("dollarAmount"));
				parc.setDepositDate(mysqlFormat.format(new java.util.Date()));
				parc.setCheckReference(pnRefId);
				parc.setCheckAuthCode(authCode);

				try {	
					parc.insert();
				}catch(SQLException sqle) {
					throw new ServletException("ProcessCollectionSubmission, Insertion of Collection Failed" + sqle.getMessage());	
				}
						
				ProcessARCollectionDetail parcd = new ProcessARCollectionDetail();
				parcd.setCollectionId(parc.getId());
				parcd.setInvoiceId(req.getParameter("invoiceId"));
				parcd.setPaymentAmount(req.getParameter("dollarAmount"));
				try {
					parcd.insert();	
				}catch(SQLException sqle) {
					throw new ServletException("ProcessCollectionSubmission, Insertion of Collection Detail failed" + sqle.getMessage());	
				}
				
			}

	}

	private Hashtable processOrder(HttpServletRequest request) {
		//clean up CC number incase user put in spaces and hyphens
		StringTool st = new StringTool();
		String orderId="";
		//if this is being called from an order process get the orderid
		if(request.getParameter("jobId")==null){
			Statement qs = null;
			Connection conn = null; 

			try {			
				conn = DBConnect.getConnection();
				qs = conn.createStatement();
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))  from orders;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				orderId=rs1.getString(1);
			} catch (Exception x) {
				try {
					throw new SQLException(x.getMessage());
				} catch (SQLException e) {
					e.printStackTrace();
				}
			} finally {
				try { conn.close(); } catch ( Exception x) { conn = null; }
			}
		}
		
		Hashtable returnResults = new Hashtable();
		String payType=((request.getParameter("pay_type")==null || request.getParameter("pay_type").equals(""))?"cc":request.getParameter("pay_type"));
		if(payType.equals("cc")){
			String ccnumber = st.replaceSubstring(request.getParameter("ccNumber")," ","");
			ccnumber = st.replaceSubstring(ccnumber,"-","");
			//send info to Verisign-Marcomet tool
			ProcessCreditCardWithVerisignTool vProcess = new ProcessCreditCardWithVerisignTool();
			vProcess.setOrderId(orderId);
			String trType=((request.getSession().getAttribute("lastCCRef")!=null && !request.getSession().getAttribute("lastCCRef").toString().equals(""))?"D":"S");
		
			returnResults= vProcess.processTransaction(ccnumber, request.getParameter("ccMonth")+request.getParameter("ccYear"), request.getParameter("dollarAmount"),trType,request);					
		}else if(payType.equals("ach")){
		    String accountNumber=((request.getParameter("accountNumber")==null)?"":request.getParameter("accountNumber"));
		    accountNumber  = st.replaceSubstring(accountNumber," ","");
		    accountNumber = st.replaceSubstring(accountNumber,"-","");
			
			String acctType=request.getParameter("acct_type");
			String firstName=((request.getParameter("accountName")==null)?"":request.getParameter("accountName"));
		    String bankName=((request.getParameter("bankName")==null)?"":request.getParameter("bankName"));
		    String aba=((request.getParameter("routingNumber")==null)?"":request.getParameter("routingNumber"));
		    String bankCity=((request.getParameter("bankCity")==null)?"":request.getParameter("bankCity"));
		    String bankState=((request.getParameter("bankState")==null)?"":request.getParameter("bankState"));
		    String bankInfo="Bank:"+bankName+";City:"+bankCity+";State:"+bankState;
	
			//send info to Verisign-Marcomet tool
			ProcessACHWithVerisignTool vProcess = new ProcessACHWithVerisignTool();
			vProcess.setOrderId(orderId);
			String trType="S";
			String preNote="N";
			returnResults= vProcess.processTransaction(preNote, firstName, aba, accountNumber,  acctType,  bankName, bankCity, bankState, request.getParameter("dollarAmount"),  trType,  request);			
		}
		return returnResults;
	}

	private void updateCompany(HttpServletRequest req) throws ServletException {
		ProcessCompany pc = new ProcessCompany();
		
		pc.setId(req.getParameter("companyId"));
		
		try {
			pc.updateCompany("companyname",req.getParameter("companyName"));
			pc.updateCompany("companyurl",req.getParameter("companyURL"));
		}catch(Exception e) {
			throw new ServletException("ProcesscollectionSubmission, updateCompany() changed, e: " + e.getMessage());
		}
			
		
	}
	private void updateContact(HttpServletRequest req) throws ServletException{
		ProcessContact pc = new ProcessContact();
		
		pc.setId((String)req.getSession().getAttribute("contactId"));		
		try {
			pc.updateContact("firstname",req.getParameter("firstName"));	
			pc.updateContact("lastname",req.getParameter("lastName"));
			pc.updateContact("titleid",req.getParameter("titleId"));
			pc.updateContact("jobtitle",req.getParameter("jobTitle"));
			pc.updateContact("email",req.getParameter("email"));	
		}catch(SQLException sqle) {
			throw new ServletException("ProcessCollectionSubmission, updateContact, sqle: " + sqle.getMessage());
		}	
	}
	private void updateLocation(HttpServletRequest req, String type) throws ServletException{
		ProcessLocation pl = new ProcessLocation();

		pl.setAddress1(req.getParameter("address" + type + "1"));
		pl.setAddress2(req.getParameter("address"+type+"2"));
		pl.setCity(req.getParameter("city" + type));
		pl.setStateId(req.getParameter("state"+type+"Id"));
		pl.setZipcode(req.getParameter("zipcode"+type));
		pl.setContactId((String)req.getSession().getAttribute("contactId"));
		pl.setLocationTypeId(req.getParameter("location"+type+"TypeId"));
		pl.setCompanyId(req.getParameter("companyId"));
		try {
			pl.update();		
		}catch(Exception e) {
			throw new ServletException("ProcessCollectionSubmission, updateLocation, e: " + e.getMessage());
		}
	}
	private void updatePhones(HttpServletRequest req) throws ServletException{
		ProcessPhone pp = new ProcessPhone();
		try {
			pp.deleteContactPhone((String)req.getSession().getAttribute("contactId"));
		}catch(Exception e) {
			throw new ServletException("ProcessCollectinSubmittion, delete phones failed: " + e.getMessage());
		}
		
		int phoneCount = Integer.parseInt(req.getParameter("phoneCount"));
		for(int x=0; x < phoneCount; x++) {
			if (!req.getParameter("prefix"+x).equals("")) {   //check to see if they even inserted a number
				pp.clear();
				pp.setContactId((String)req.getSession().getAttribute("contactId"));
				pp.setPhoneTypeId(req.getParameter("phoneTypeId"+x));
				pp.setAreaCode(req.getParameter("areaCode" + x));
				pp.setPhone1(req.getParameter("prefix"+x));
				pp.setPhone2(req.getParameter("lineNumber"+x));
				pp.setExtension(req.getParameter("extension"+x));
				try {
					pp.insert();
				}catch(Exception sqle) {
					throw new ServletException("ProcessCollectionsSubmission, insert phone failed, sqle: " + sqle.getMessage());	
				}
			}		
		}	
	}
}
