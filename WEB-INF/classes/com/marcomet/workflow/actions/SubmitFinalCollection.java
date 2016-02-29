/**********************************************************************
Description:	This class will process a collection form submittion.

				Check Credit Card
				Update User info if changed
				Insert Collection and Collection Details
				Return if any errors are found.

Note:			Actual Verisign check commented out, remove comments on code with $'s

**********************************************************************/

package com.marcomet.workflow.actions;

import java.sql.SQLException;
import java.util.Hashtable;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessARCollection;
import com.marcomet.commonprocesses.ProcessARCollectionDetail;
import com.marcomet.commonprocesses.ProcessCompany;
import com.marcomet.commonprocesses.ProcessContact;
import com.marcomet.commonprocesses.ProcessLocation;
import com.marcomet.commonprocesses.ProcessPhone;
import com.marcomet.files.MultipartRequest;
import com.marcomet.tools.ProcessCreditCardWithVerisignTool;
import com.marcomet.tools.StringTool;


public class SubmitFinalCollection implements ActionInterface {


//***** Credit Card System *******
	
	String authCode = "bogus";
	String pnRefId = "bogus";

	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {
		return new Hashtable();
	}
	//this section will control the flow and test for errors and updates
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		
		//Process The Credit Card	
		Hashtable returnResult = processOrder(request);

		//check to see if the process was valid/completed
		if (((Boolean)returnResult.get("processed")).booleanValue()) {
			authCode = (String)returnResult.get("authCode");
			pnRefId = (String)returnResult.get("pnRefId");
		}else {
			request.setAttribute("errorMessage",(String)returnResult.get("ccErrorMessage"));
			throw new ActionException();
		}

		//Create a Collection from the Credit Card Process.
		createCollection(request);

		//was there an update to contact info
		if (request.getParameter("formChangedContact").equals("1")) {
			updateContact(request);
		}	
				
		
		//was there an update to locations?
		if (request.getParameter("formChangedLocations").equals("1")) {
			updateLocation(request);
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
	
	private Hashtable processOrder(HttpServletRequest request) {
		//clean up CC number incase user put in spaces and hyphens
		StringTool st = new StringTool();
		String ccnumber = st.replaceSubstring(request.getParameter("ccNumber")," ","");
		ccnumber = st.replaceSubstring(ccnumber,"-","");
		
		//send info to Verisign-Marcomet tool
		ProcessCreditCardWithVerisignTool vProcess = new ProcessCreditCardWithVerisignTool();
		return vProcess.processTransaction(ccnumber, request.getParameter("ccMonth")+request.getParameter("ccYear"), request.getParameter("dollarAmount"),request);					
	}

	//insert a collection and collection detail for this charge
	private void createCollection(HttpServletRequest req) 
	throws ServletException{

		java.text.DateFormat mysqlFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
		ProcessARCollection  parc = new ProcessARCollection();
		parc.setContactId((String)req.getSession().getAttribute("contactId"));
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


	
	private void updateCompany(HttpServletRequest req) throws ServletException {
		ProcessCompany pc = new ProcessCompany();
		
		pc.setId(req.getParameter("companyId"));
		
		try {
			pc.updateCompany("companyname",req.getParameter("companyName"));
			pc.updateCompany("companyurl",req.getParameter("companyURL"));
		}catch(Exception e) {
			throw new ServletException("ProcesscollectionSubmission, updateCompany(), e: " + e.getMessage());
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
	private void updateLocation(HttpServletRequest req) throws ServletException{
		ProcessLocation pl = new ProcessLocation();

		pl.setAddress1(req.getParameter("addressBill1"));
		pl.setAddress2(req.getParameter("addressBill2"));
		pl.setCity(req.getParameter("cityBill"));
		pl.setStateId(req.getParameter("stateBillId"));
		pl.setZipcode(req.getParameter("zipcodeBill"));
		pl.setContactId((String)req.getSession().getAttribute("contactId"));
		pl.setLocationTypeId(req.getParameter("locationBillTypeId"));
		pl.setCompanyId(req.getParameter("companyId"));
		pl.setCountryId(req.getParameter("countryBillId"));
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
