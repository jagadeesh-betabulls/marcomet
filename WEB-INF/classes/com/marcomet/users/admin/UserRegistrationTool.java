package com.marcomet.users.admin;

/**********************************************************************
Description:	This Class will drive the process of the registration 
				of a user.
			
Notes:

Required Fields:
				newUserName  (new user)
				newPassword  (new user)
				companyName
				companyURL
				
				firstName
				lastName
				titleId    = from lu_titles
				jobTitle
				email
				
				addressMail1
				addressMail2
				cityMail
				stateMailId = from lu_abbriated states
				zipcodeMail
				countryMailId = from lu_countries
				
				addressBill1
				addressBill2
				cityBill
				stateBillId = from lu_abbreviated states
				zipcodeBill
				countryBillId = from lu_countries
				
				NOTE: x being the number of sets you want.
				phoneTypeId"+x
				areaCode" + x
				prefix"+x
				lineNumber"+x
				extension"+x				
				
				errorPage = where the user is sent if there is an error.		
**********************************************************************/

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Hashtable;
import java.util.StringTokenizer;
import java.util.Vector;
import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.marcomet.beans.SBPContactBean;
import com.marcomet.beans.Store;
import com.marcomet.beans.Company;
import com.marcomet.beans.StoredMessageBean;
import com.marcomet.commonprocesses.*;
import com.marcomet.environment.SiteHostSettings;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.mail.JavaMailer;
import com.marcomet.mail.registration.NewRegistrationMessage;
import com.marcomet.tools.SimpleLookups;
import com.marcomet.tools.StringTool;

public class UserRegistrationTool{	
	private String errorMessage = "";
	
	public Hashtable addNewCompanyMemberInformation(HttpServletRequest request, HttpServletResponse response, Hashtable temp) throws Exception{
		
		Hashtable results = temp;    //so that the calling class has needed information passed back to it.	
		int companyId = 0;
		
		HttpSession session = request.getSession();

		try{
			if(!checkLoginClear(request)){
				errorMessage = "There is a user already with your chosen user name and/or password. If you don't remember your username or password you can click here to have it reset and sent to your email address: <a href='/admin/user_password_reset.jsp'>RESET PASSWORD</a> ";
				session.setAttribute("errMsg",errorMessage);
				results.put("errorMessage",errorMessage);
				return results;		
			}
		}catch(Exception e){
			results.put("errorMessage",e.getMessage());
			session.setAttribute("errMsg",errorMessage);
			return results;
		}	
	
		try{	
			companyId = Integer.parseInt((String)request.getSession().getAttribute("companyId"));
		}catch(Exception e){
			results.put("errorMessage",e.getMessage());
			return results;
		}	
			
		int contactId = 0;
		
		try{
			contactId = insertContact(request, companyId);             //if failed delete company
		}catch(Exception e){
			errorMessage ="There was an error: " + e.getMessage();
			cleanUpCompany(companyId);	
		}	

		try{
			insertLogin(request,contactId);							//if failed delete company,contact
			//insertContactType(contactId);
			insertLocations(request, companyId, contactId);			//if failed delete company,contact,login
			insertPhones(request,contactId);						//if failed delete company,contact,login,phones
			insertSiteFields(request,contactId);					//if failed delete company,contact,login,phones
			insertDefaultRole(request,contactId);					//if failed delete company,contact,login,phones,default role
		}catch(Exception e){
			cleanUpCompany(companyId);
			cleanUpContact(contactId);
			cleanUpLocations(contactId, companyId);
			cleanUpLogin(contactId);
			//cleanUpContactTypes(contactId);
			cleanUpPhones(contactId);
			cleanUpSiteFields(contactId);
			cleanUpDefaultRole(contactId);
			errorMessage ="There was an error: " + e.getMessage() + ", contactId: " + contactId + ", companyId" + companyId;
			results.put("errorMessage",errorMessage);
			return results;			
		}	
		
		results.put("contactId",contactId+"");
		results.put("companyId",companyId+"");
		results.put("errorMessage","");
		request.setAttribute("customerId",contactId+"");
		sendEmail(request);
		return results;
			
	}
	public Hashtable addNewUserInformation(HttpServletRequest request, HttpServletResponse response, Hashtable temp) throws Exception{
		
		Hashtable results = temp;               //so that the calling class has needed information passed back to it.	
		int companyId = 0;
		
		try{
			if(!checkLoginClear(request)){
				errorMessage = "There is a user already with your choosen User Name";
				results.put("errorMessage",errorMessage);
				return results;		
			}
		}catch(Exception e){
			results.put("errorMessage",e.getMessage());
			return results;
		}	
	
		try{	
			companyId = insertCompany(request);
		}catch(Exception e){
			results.put("errorMessage",e.getMessage());
			return results;
		}	
			
		int contactId = 0;
		
		try{
			contactId = insertContact(request, companyId);             //if failed delete company
		}catch(Exception e){
			errorMessage ="There was an error: " + e.getMessage();
			cleanUpCompany(companyId);	
		}	

		try{
			insertLogin(request,contactId);							//if failed delete company,contact
			insertContactType(contactId);
			insertLocations(request, companyId, contactId);			//if failed delete company,contact,login
			insertPhones(request,contactId);						//if failed delete company,contact,login,phones
			insertSiteFields(request,contactId);						//if failed delete company,contact,login,phones
			insertDefaultRole(request,contactId);					//if failed delete company,contact,login,phones,default role
		}catch(Exception e){
			cleanUpCompany(companyId);
			cleanUpContact(contactId);
			cleanUpLocations(contactId, companyId);
			cleanUpLogin(contactId);
			cleanUpContactTypes(contactId);
			cleanUpPhones(contactId);
			cleanUpSiteFields(contactId);
			cleanUpDefaultRole(contactId);
			errorMessage ="There was an error: " + e.getMessage() + ", contactId: " + contactId + ", companyId" + companyId;
			results.put("errorMessage",errorMessage);
			return results;			
		}	
		
		results.put("contactId",contactId+"");
		results.put("companyId",companyId+"");
		results.put("errorMessage","");
		request.setAttribute("customerId",contactId+"");
		sendEmail(request);
		return results;
			
	}
	
public Hashtable addNewUserInformationStep1(HttpServletRequest request, HttpServletResponse response, Hashtable temp){
	
	
		Hashtable results = temp;               //so that the calling class has needed information passed back to it.	
		int companyId = 0;
		int allowForRegistration = -1;		
		
		try{
			if(!checkLoginClear(request)){
				errorMessage = StoredMessageBean.getMessage("DUPLICATE_USER_NAME");
				results.put("errorMessage",errorMessage);
				return results;		
			}
		}catch(Exception e){
			e.printStackTrace();
			results.put("errorMessage",e.getMessage());
			return results;
		}			
		
		try {
			allowForRegistration = checkEmailValidation(request);
			if ( allowForRegistration == 0 ) {
				//1.1				
				errorMessage = StringTool.replaceSubstringSt(StoredMessageBean.getMessage("PROBLEM_WITH_REG"),"^PHONE_NUMBER^",StoredMessageBean.getMessage("MARKETING_SERVICES_PHONE_NUMBER"));
				results.put("errorMessage",errorMessage);
				return results;	
			} else {
				//1.2				
				if(!checkEmailClear(request)){				
					//prompt user for a new email address or offer to reset password
					errorMessage = StoredMessageBean.getMessage("DUPLICATE_EMAIL_ADDRESS");
					results.put("errorMessage",errorMessage);
					return results;		
				}
			}
			
		} catch(Exception e){
			e.printStackTrace();
			results.put("errorMessage",e.getMessage());
			return results;
		}	
			
		int useSiteNumbers = 0;
		int validateSiteNumbers = 0;		
		int siteID = 0;
		int bypassValidation = 0;
		int numOfSiteUsers = 0;
		String siteClientRefCode = null;
		String siteMcClient = null;
		SiteHostSettings shs = null;
		
		try {	
			//get site parameters
			shs = (SiteHostSettings)request.getSession().getAttribute("siteHostSettings");
			siteID = Integer.parseInt(shs.getSiteHostId());
			useSiteNumbers = shs.getUseSiteNumbersFlag();
			validateSiteNumbers = shs.getValidateSiteNumberFlag();	
			siteClientRefCode = shs.getSiteClientRefCode();
			siteMcClient = shs.getSiteMcClient();
			
		}catch(Exception e){
			e.printStackTrace();
			results.put("errorMessage",e.getMessage());
			return results;
		}			
		
		
		if ( useSiteNumbers == 0 || validateSiteNumbers == 0 || allowForRegistration == 2 ) {
			//1.2.1			
			if ( allowForRegistration == 2 ) {
				bypassValidation = 1;
			}	
			//1.2.2
			
		} else if ( useSiteNumbers == 1 && validateSiteNumbers == 1 ) {
			//1.2.2.1			
			//get current site users
			Hashtable hash = checkForOtherSiteUsers(siteID);
			String contacts = null;
			try {
				numOfSiteUsers = Integer.parseInt((String)hash.keys().nextElement());
				contacts = (String)hash.get(Integer.toString(numOfSiteUsers));
			} catch (Exception x) {}
			
			//1.2.2.2			
			if ( numOfSiteUsers > 0 ) {				
				if ( contacts.indexOf("*" + request.getParameter("lastName") + "*") > 0 ) {
					//1.2.2.2.1			
					//prompt user for a new email address or offer to reset password					
					errorMessage = StringTool.replaceSubstringSt(StoredMessageBean.getMessage("DUPLICATE_SITE_USER"),"^SITE_ID^", Integer.toString(siteID) );
					results.put("errorMessage", errorMessage);
					return results;	
				} else {
					//1.2.2.2.2	
					errorMessage = StringTool.replaceSubstringSt(StoredMessageBean.getMessage("ANOTHER_SITE_USER_EXISTS"),"^PHONE_NUMBER^",StoredMessageBean.getMessage("MARKETING_SERVICES_PHONE_NUMBER"));
					results.put("errorMessage", errorMessage);
					return results;	
				}
			}
		}
				
		
		//1.2.2.1.1.2
		Company comp = null;
		
		if ( Company.getCompanyID(request.getParameter("taxID")) > -1 )
			comp = Company.getCompanyByTaxID(request.getParameter("taxID"));
		else
			comp = new Company();
		
		//Store all field values to pass to the 2nd step form
		Hashtable form1Fields = new Hashtable();
		form1Fields.put("companyName", request.getParameter("companyName"));
		form1Fields.put("dba", request.getParameter("dba"));
		form1Fields.put("billingEntityId", request.getParameter("billingEntityId"));
		//form1Fields.put("companyURL", request.getParameter("companyURL"));
		form1Fields.put("taxID", request.getParameter("taxID"));
		form1Fields.put("firstName", request.getParameter("firstName"));		
		form1Fields.put("lastName", request.getParameter("lastName"));
		form1Fields.put("titleId", request.getParameter("titleId"));
		form1Fields.put("jobTitle", request.getParameter("jobTitle"));
		form1Fields.put("email", request.getParameter("email"));		
		form1Fields.put("siteNumber", request.getParameter("siteNumber"));
		//form1Fields.put("pmSiteNumber", request.getParameter("pmSiteNumber"));
		form1Fields.put("defaultWebsite", request.getParameter("defaultWebsite"));
		form1Fields.put("newUserName", request.getParameter("newUserName"));
		form1Fields.put("newPassword", request.getParameter("newPassword"));
			
		
		Hashtable hash = checkSiteNumbers(siteMcClient, request.getParameter("siteNumber"));
			
		Vector storeIDs = (Vector) hash.get("storeIDs");
		
		if ( !hash.get("errorMessage").equals("") ) {
			results.put("errorMessage", hash.get("errorMessage"));
			request.setAttribute("form1Fields", form1Fields );
			request.setAttribute("storeIDs", storeIDs );
			request.setAttribute("company", comp );
			return results;	
		}
		
		//results.put("contactId",contactId+"");
		//results.put("companyId",companyId+"");
		//results.put("siteNumbers",request.getParameter("siteNumber"));
		request.setAttribute("form1Fields", form1Fields );
		request.setAttribute("storeIDs", storeIDs );
		request.setAttribute("company", comp );
		results.put("errorMessage","");
		//request.setAttribute("customerId",contactId+"");
		//request.setAttribute("companyId",companyId+"");
		//sendEmail(request);	
		System.err.println("z");
		return results;
			
	}

public Hashtable addNewUserInformationStep2(HttpServletRequest request, HttpServletResponse response, Hashtable temp) throws Exception{
	

	
	Hashtable results = temp;               //so that the calling class has needed information passed back to it.	
	int companyId = -1;		
	int contactId = -1;
	Vector storeIDs = (Vector)request.getAttribute("storeIDs");
	
	try {
		companyId = Integer.parseInt(request.getParameter("companyID"));
	} catch (Exception e ) {}
	
		
	try{	
		// Create company if it does not already exist
		if ( companyId == -1 )
			companyId = insertCompany(request);
	}catch(Exception e){
		e.printStackTrace();
		results.put("errorMessage",e.getMessage());
		return results;
	}	
	
	
	try{
		contactId = insertContact(request, companyId);             //if failed delete company
	}catch(Exception e){
		e.printStackTrace();
		errorMessage ="There was an error: " + e.getMessage();
		cleanUpCompany(companyId);	
	}	

	try{
		insertLogin(request,contactId);							//if failed delete company,contact
		insertContactType(contactId);
		insertLocations(request, companyId, contactId);			//if failed delete company,contact,login
		insertPhones(request,contactId);						//if failed delete company,contact,login,phones,site fields
		insertSiteFields(request,contactId);					//if failed delete company,contact,login,phones,site fields
		insertDefaultRole(request,contactId);					//if failed delete company,contact,login,phones,default role
		
		if ( storeIDs != null ) {
			Enumeration enumX = storeIDs.elements();
			int strID = 0;
			while ( enumX.hasMoreElements() ) {
				strID = Integer.parseInt((String)enumX.nextElement());
				if ( strID > -1 ) {
					System.out.println("stID:" + strID);
					Store store = new Store(strID);
					store.addContact(contactId);
				}				
			}
		} // end if ( storeIDs != null )
		
	}catch(Exception e){
		cleanUpCompany(companyId);
		cleanUpContact(contactId);
		cleanUpLocations(contactId, companyId);
		cleanUpLogin(contactId);
		cleanUpContactTypes(contactId);
		cleanUpPhones(contactId);
		cleanUpSiteFields(contactId);
		cleanUpDefaultRole(contactId);
		e.printStackTrace();
		errorMessage ="There was an error: " + e.getMessage() + ", contactId: " + contactId + ", companyId" + companyId;
		results.put("errorMessage",errorMessage);
		return results;			
	}
	
	results.put("contactId",contactId+"");
	results.put("companyId",companyId+"");
	results.put("errorMessage","");
	request.setAttribute("customerId",contactId+"");
	sendEmail(request);

	return results;
		
}
	
//******************** New user functions *****************************	
	private int checkEmailValidation(HttpServletRequest request)
	throws SQLException{
		ProcessLogin pl = new ProcessLogin();
		
		return pl.getEmailOrDomainFlag(request.getParameter("email"));	
	}
	
	private boolean checkEmailClear(HttpServletRequest request)
	throws SQLException{
		ProcessLogin pl = new ProcessLogin();
        SiteHostSettings shs = (SiteHostSettings)request.getSession().getAttribute("siteHostSettings");
        String sitehostid = shs.getSiteHostId();
		return pl.checkEmailClear(request.getParameter("email"),sitehostid);	
	}

	private boolean checkLoginClear(HttpServletRequest request)
	throws SQLException{
		ProcessLogin pl = new ProcessLogin();
        SiteHostSettings shs = (SiteHostSettings)request.getSession().getAttribute("siteHostSettings");
        System.out.println("shs in UserRegistrationTool.java is "+shs);
        String sitehostid = shs.getSiteHostId();
        System.out.println("sitehostid in UserRegistrationTool.java is "+sitehostid);
		System.err.println("check login");
		return pl.checkUserNameEmailClear(request.getParameter("email"),request.getParameter("newUserName"),sitehostid);	
	}
	
	private Hashtable checkForOtherSiteUsers(int siteID) {
		int count = 0;
		Hashtable hash = new Hashtable();
		
		Statement qs = null;
		Connection conn = null; 
		StringBuffer buff = new StringBuffer();
		StringBuffer namesEmails = new StringBuffer();
		
		try {
			buff.append("SELECT c.lastname, c.email from stores s, contact_stores cs, contacts c ");
			buff.append("where cs.store_id = s.id and c.id = cs.contact_id and s.site = ");
			buff.append(Integer.toString(siteID));
			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			ResultSet rs1 = qs.executeQuery(buff.toString());
			while (rs1.next()) {
				//Build a single delimited string of all names and emails
				namesEmails.append("*");
				namesEmails.append(rs1.getString("lastname"));
				namesEmails.append("*");
				namesEmails.append(rs1.getString("email"));
				namesEmails.append("*|");
				count++;
			}
				
			hash.put(Integer.toString(count), namesEmails.toString());
						
		} catch (Exception x) {
			System.err.println("UserRegistrationTool.checkForOtherSiteUsers : error :" + x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return hash;
	}
	
	private Hashtable checkSiteNumbers(String clientCode, String siteNums ) {
		
		Hashtable hash = new Hashtable();
		//System.out.println("nums: " + siteNums);
		Vector vec = new Vector();
		StringBuffer buff = new StringBuffer();
		int id = -1;
		int siteNum = -1;
		String tmp = null;
		try {
			StringTokenizer tok = new StringTokenizer(siteNums, ",");			
			while ( tok.hasMoreElements() ) {
				tmp = (String)tok.nextElement();
				System.out.println("site: " + tmp);
				try {
					id = Store.getStoreIDByClient(clientCode, Integer.parseInt(tmp));
				} catch ( Exception x) {
					System.out.println(x.getMessage());
					id = -1;
				}
				System.out.println("ID: " + id);
				vec.add(Integer.toString(id));
				if ( id == -1 ) {
					if ( buff.length() > 0 )
						buff.append(", ");
					buff.append(tmp);
				}
			}			
		} catch (Exception e) {
			e.printStackTrace();
		}
		//Return a vector of store IDs that match company and site
		hash.put("storeIDs", vec);		
		if ( buff.length() > 0 ) {
			errorMessage = StringTool.replaceSubstringSt(StoredMessageBean.getMessage("INVALID_SITE_NUMBER"),"^SITE_ID^", buff.toString());
			errorMessage = StringTool.replaceSubstringSt(errorMessage,"^PHONE_NUMBER^",StoredMessageBean.getMessage("MARKETING_SERVICES_PHONE_NUMBER"));
					
		} else {
			errorMessage = "";
		}
		
		hash.put("errorMessage", errorMessage);	
		return hash;
	}
	
	//##################### Fix section for broken insertions ##########
	private void cleanUpCompany(int companyId){
		ProcessCompany pc = new ProcessCompany();
		try{
			pc.delete(companyId);	
		}catch(SQLException sqle){
			System.err.println("cleanUpCompany failed to clean up the company: " + companyId + ", error: " + sqle.getMessage());
		}			
	}
	private void cleanUpContact(int contactId){
		ProcessContact pc = new ProcessContact();
		try{
			pc.delete(contactId);	
		}catch(SQLException sqle){
			System.err.println("cleanUpContact failed to clean up, contactId: " + contactId + ", error: " + sqle.getMessage());
		}	
	}
	private void cleanUpContactTypes(int contactId){
		ProcessContactType pct = new ProcessContactType();
		try{
			pct.deleteContactId(contactId);	
		}catch(SQLException sqle){
			System.err.println("cleanUpContactType failed to clean up, contactId: " + contactId + ", error: " + sqle.getMessage());
		}		
	}
	private void cleanUpDefaultRole(int contactId){
		ProcessRole pr = new ProcessRole();
		try{
			pr.delete(contactId);	
		}catch(SQLException sqle){
			System.err.println("cleanUpRole failed to clean up, contactId: " + contactId + ", error: " + sqle.getMessage());
		}		
	}
	private void cleanUpLocations(int contactId, int companyId){
		ProcessLocation pl = new ProcessLocation();
		try{
			pl.delete(contactId, companyId);	
		}catch(SQLException sqle){
			System.err.println("cleanUpLocation failed to clean up, contactId: " + contactId + " and companyId: " + companyId + ", error: " + sqle.getMessage());
		}	
	}
	private void cleanUpLogin(int contactId){
		ProcessLogin pl = new ProcessLogin();
		try{
			pl.deleteContactId(contactId);	
		}catch(SQLException sqle){
			System.err.println("cleanUpLogin failed to clean up, contactId: " + contactId + ", error: " + sqle.getMessage());
		}		
	}
	private void cleanUpPhones(int contactId){
		ProcessPhone pp = new ProcessPhone();
		try{
			pp.deleteContactPhone(contactId);
		}catch(SQLException sqle){
			System.err.println("cleanUpPhones failed to clean up, contactId: " + contactId + ", error: " + sqle.getMessage());
		}		
	}
	private void cleanUpSiteFields(int contactId){
		ProcessSiteFields pp = new ProcessSiteFields();
		try{
			pp.deleteContactSiteFields(contactId);
		}catch(SQLException sqle){
			System.err.println("cleanUpSitefields failed to clean up, contactId: " + contactId + ", error: " + sqle.getMessage());
		}		
	}
	private int insertCompany(HttpServletRequest request)
	throws SQLException{
		
		ProcessCompany pc = new ProcessCompany();
		//Get the max of the credit_limit for all registrations for the current site number
		if(request.getParameter("siteNumber")!=null && !request.getParameter("siteNumber").equals("")){
			try {
				Statement qs = null;
				Connection conn = null; 
				conn = DBConnect.getConnection();
				qs = conn.createStatement();
				
				ResultSet rs1 = qs.executeQuery("Select max(credit_limit) as creditLimit from companies c left join contacts ct on ct.companyid=c.id where ct.default_site_number='"+request.getParameter("siteNumber")+"' and ct.active_flag=1");
				if (rs1.next()) {
					if(rs1.getString("creditLimit")!=null && !rs1.getString("creditLimit").equals("")  && !rs1.getString("creditLimit").equals("0")){
						pc.setCreditLimit(rs1.getDouble("creditLimit"));
					}
				}
				//Check the credit_limit and credit_status on the property to see if it's higher than that of the registrants, or if the property's credit is on hold.
				rs1 = qs.executeQuery("Select max(a.creditLimit) as creditLimit,max(a.creditStatus) as creditStatus from (Select max(credit_limit) as creditLimit,max(credit_status) as creditStatus from credit_status where site_number='"+request.getParameter("siteNumber")+"' union Select max(credit_limit) as creditLimit,max(credit_status) as creditStatus from companies c left join contacts ct on ct.companyid=c.id where ct.default_site_number='" +request.getParameter("siteNumber")+ "' and ct.active_flag<>0) as a");
				if (rs1.next()) {
					if(rs1.getString("creditLimit")!=null && !rs1.getString("creditLimit").equals("")  && !rs1.getString("creditLimit").equals("0")){
						pc.setCreditLimit(rs1.getDouble("creditLimit"));
						System.out.println(pc.getCreditLimit());
					}
					if(rs1.getString("creditStatus")!=null && !rs1.getString("creditStatus").equals("")){
						pc.setCreditStatus(rs1.getString("creditStatus"));
						System.out.println(pc.getCreditStatus());
					}
				}
			} catch (ClassNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		pc.setCompanyName(request.getParameter("companyName"));
		pc.setCompanyURL(request.getParameter("companyURL"));
		pc.setTaxID(request.getParameter("taxID"));
		pc.setDBA(request.getParameter("dba"));
		pc.setAttention(request.getParameter("attention"));
		pc.setBillingEntityID(request.getParameter("billing_entity_id"));
		System.out.println(request.getParameter("billing_entity_id"));
		System.out.println(pc.getBillingEntityID());
		pc.setPhone(request.getParameter("compPhone"));
		pc.setFax(request.getParameter("compFax"));
		SiteHostSettings shs = (SiteHostSettings)request.getSession().getAttribute("siteHostSettings");
		pc.setCreditLimit(shs.getDefaultCreditLimit());
		
		return pc.insert();
			
	}
	private int insertContact(HttpServletRequest request, int companyId)
	throws SQLException{
		ProcessContact pc = new ProcessContact();
		pc.setCompanyId(companyId);
		pc.setFirstName(request.getParameter("firstName"));
		pc.setLastName(request.getParameter("lastName"));
		pc.setTitleId(request.getParameter("titleId"));
		pc.setJobTitle(request.getParameter("jobTitle"));
		pc.setEmail(request.getParameter("email"));	
		pc.setSiteNumber(request.getParameter("siteNumber"));	
		pc.setPMSiteNumber(request.getParameter("pmSiteNumber"));	
		pc.setDefaultWebsite(request.getParameter("defaultWebsite"));	
		return pc.insert();
	}
	private void insertContactType(int contactId)
	throws SQLException{
	
		ProcessContactType pct = new ProcessContactType();		
		pct.setContactId(contactId);
		pct.setLUContactTypeId(1);
		pct.insert();
	}
	private void insertDefaultRole (HttpServletRequest request, int contactId)
	throws SQLException{
		ProcessRole pr = new ProcessRole ();
		pr.setContactId(contactId);
		pr.setSiteHostId(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostId());
		pr.setRoleId(request.getParameter("defaultRoleId"));	
		pr.insert();
	}
	private void insertLocations(HttpServletRequest request, int companyId, int contactId) 
	throws SQLException{
		ProcessLocation pl = new ProcessLocation();
				
		//******** mailing addresss *******
		pl.setAddress1(request.getParameter("addressMail1"));
		pl.setAddress2(request.getParameter("addressMail2"));
		pl.setCity(request.getParameter("cityMail"));
		pl.setStateId(request.getParameter("stateMailId"));
		pl.setZipcode(request.getParameter("zipcodeMail"));
		pl.setContactId(contactId);
		pl.setCompanyId(companyId);
		pl.setCountryId(request.getParameter("countryMailId"));
		
		pl.setLocationTypeId(1);     //hard coded from lu_location_types
		pl.insert();		
		
		pl.clear();
		
		//****** billing address *********
		if(request.getParameter("sameAsAbove")==null){ 
			pl.setAddress1(request.getParameter("addressBill1"));
			pl.setAddress2(request.getParameter("addressBill2"));
			pl.setCity(request.getParameter("cityBill"));		
			pl.setStateId(request.getParameter("stateBillId"));
			pl.setZipcode(request.getParameter("zipcodeBill"));
			pl.setCompFax(request.getParameter("compFax"));			
			pl.setContactId(contactId); 
			pl.setCompanyId(companyId);
			pl.setCountryId(request.getParameter("countryBillId")); 
			
			pl.setLocationTypeId(2);                          //hard coded from lu_location_types
			pl.insert();	
			pl.processCL();
			
		}else{
		 	pl.setAddress1(request.getParameter("addressMail1"));
			pl.setAddress2(request.getParameter("addressMail2"));
			pl.setCity(request.getParameter("cityMail"));
			pl.setStateId(request.getParameter("stateMailId"));
			pl.setZipcode(request.getParameter("zipcodeMail"));
			pl.setCompFax(request.getParameter("compFax"));	
			pl.setContactId(contactId);
			pl.setCompanyId(companyId);
			pl.setCountryId(request.getParameter("countryMailId"));
			
			pl.setLocationTypeId(2);                //hard coded from lu_location_types
			pl.insert();	
			pl.processCL();
		}	
		//System.out.println("locations");
	}
	private void insertLogin(HttpServletRequest request, int contactId)
	throws SQLException{
	
		ProcessLogin pl = new ProcessLogin();		
		pl.setContactId(contactId);
		pl.setUserName(request.getParameter("newUserName"));
		pl.setUserPassword(request.getParameter("newPassword"));
		pl.insert();
	}
	private void insertPhones(HttpServletRequest request, int contactId) 
	throws SQLException{
		ProcessPhone pp = new ProcessPhone();
		int phoneCount = Integer.parseInt(request.getParameter("phoneCount"));
		for(int x=0; x < phoneCount; x++) {
			if (!request.getParameter("prefix"+x).equals("")) {   //check to see if they even inserted a number
				pp.clear();
				pp.setContactId(contactId);
				pp.setPhoneTypeId(request.getParameter("phoneTypeId"+x));
				pp.setAreaCode(request.getParameter("areaCode" + x));
				pp.setPhone1(request.getParameter("prefix"+x));
				pp.setPhone2(request.getParameter("lineNumber"+x));
				pp.setExtension(request.getParameter("extension"+x));
			
				pp.insert();													
			}		
		}
		System.out.println("phones");
	}
	private void insertSiteFields(HttpServletRequest request, int contactId) 
	throws SQLException{
		if (request.getParameter("useSiteFields")==null || request.getParameter("useSiteFields").equals("")) { 
			return;
		}else{
			ProcessSiteFields pp = new ProcessSiteFields();
			pp.clear();
			pp.setContactId(contactId);
			pp.setSitehostId(Integer.parseInt(request.getParameter("siteHostId")));
			pp.setSiteField1(request.getParameter("siteField1"));
			pp.setSiteField2(request.getParameter("siteField2"));
			pp.setSiteField3(request.getParameter("siteField3"));
			pp.insert();														
			System.out.println("SiteFields");
		}
	}
	
	private void restoreCompany(SBPContactBean sbpcb){
		ProcessCompany pc = new ProcessCompany();
		pc.setId(sbpcb.getCompanyId());
		pc.setCompanyName(sbpcb.getCompanyName());
		pc.setCompanyURL(sbpcb.getCompanyURL());
		pc.setAttention(sbpcb.getAttention());
		pc.setBillingEntityID(sbpcb.getBillingEntityID());
		pc.setDBA(sbpcb.getDBA());
		pc.setTaxID(sbpcb.getTaxID());
		pc.setPhone(sbpcb.getCompPhone());
		pc.setFax(sbpcb.getCompFax());
		
		try{
			pc.update();
		}catch(Exception e){
		}	
			
	}
	//********* Clean up updates **********************
	
	private void restoreContact(SBPContactBean sbpcb){
		ProcessContact pc = new ProcessContact();
		pc.setId(sbpcb.getContactId());
		pc.setCompanyId(sbpcb.getCompanyId());
		pc.setFirstName(sbpcb.getFirstName());
		pc.setLastName(sbpcb.getLastName());
		pc.setTitleId(sbpcb.getTitleId());
		pc.setJobTitle(sbpcb.getJobTitle());
		pc.setEmail(sbpcb.getEmail());
		pc.setSiteNumber(sbpcb.getSiteNumber());	
		pc.setPMSiteNumber(sbpcb.getPMSiteNumber());	
		pc.setDefaultWebsite(sbpcb.getDefaultWebsite());
		try{
			pc.update();			
		}catch(Exception e){
		}	
		
	}
	private void restoreLocations(SBPContactBean sbpcb){
		ProcessLocation pl = new ProcessLocation();
				
		//******** mailing addresss *******
		pl.setAddress1(sbpcb.getAddressMail1());
		pl.setAddress2(sbpcb.getAddressMail2());
		pl.setCity(sbpcb.getCityMail());
		pl.setStateId(sbpcb.getStateMailId());
		pl.setZipcode(sbpcb.getZipcodeMail());
		pl.setId(sbpcb.getContactId());
		pl.setCompanyId(sbpcb.getCompanyId());
		pl.setLocationTypeId(1);                               //hard coded from lu_location_types
		try{
			pl.update();		
		}catch(Exception e){
		}

		pl.clear();
		//****** billing address *********
		
		pl.setAddress1(sbpcb.getAddressBill1());
		pl.setAddress2(sbpcb.getAddressBill2());
		pl.setCity(sbpcb.getCityBill());		
		pl.setStateId(sbpcb.getStateBillId());
		pl.setZipcode(sbpcb.getZipcodeBill());
		pl.setId(sbpcb.getContactId()); 
		pl.setCompanyId(sbpcb.getCompanyId()); 
		pl.setLocationTypeId(2);                          //hard coded from lu_location_types
		try{
			pl.update();		
		}catch(Exception e){
		}	
							
	}
	private void restorePhones(SBPContactBean sbpcb){
		ProcessPhone pp = new ProcessPhone();
		int phoneCount = 3;
		try{
			pp.deleteContactPhone(sbpcb.getContactId());													
		}catch(Exception e){
			e.printStackTrace();
		}
		for(int x=0; x < phoneCount; x++){
			if (!sbpcb.getPrefix(x).equals("")) {   //check to see if they even inserted a number
				pp.clear();
				pp.setContactId(sbpcb.getContactId());
				pp.setPhoneTypeId(sbpcb.getPhoneTypeId(x));
				pp.setAreaCode(sbpcb.getAreaCode(x));
				pp.setPhone1(sbpcb.getPrefix(x));
				pp.setPhone2(sbpcb.getLineNumber(x));
				pp.setExtension(sbpcb.getExtension(x));
				try{
					pp.insert();												
				}catch(Exception e){
				}	
			}		
		}	
	}
	private void restoreSiteFields(SBPContactBean sbpcb){
		ProcessSiteFields pp = new ProcessSiteFields();
		if (sbpcb.getUseSitefields().equals("")) { 
			return;
		}else{
			pp.clear();
			pp.setContactId(sbpcb.getContactId());
			System.out.println("sbpcb.getContactId() is "+sbpcb.getContactId());
			pp.setSitehostId(Integer.parseInt(sbpcb.getSitehostId()));
			System.out.println("pp.setSitehostId(Integer.parseInt(sbpcb.getSitehostId())); is "+Integer.parseInt(sbpcb.getSitehostId()));
			pp.setSiteField1(sbpcb.getSiteField1());
			System.out.println("sbpcb.getSiteField1() is "+sbpcb.getSiteField1());
			pp.setSiteField2(sbpcb.getSiteField2());
			System.out.println("sbpcb.getSiteField2() is "+sbpcb.getSiteField2());
			pp.setSiteField3(sbpcb.getSiteField3());
			System.out.println("sbpcb.getSiteField3() is "+sbpcb.getSiteField3());
			try{
				
				pp.insert();													
			}catch(Exception e){
			}	
		}
	}
	//New User so send a nice message
	private void sendEmail(HttpServletRequest request) throws Exception{
			
		NewRegistrationMessage nrm = new NewRegistrationMessage();
		JavaMailer	mail = new JavaMailer();
		
		Hashtable inputs = new Hashtable();
		SimpleLookups slups = new SimpleLookups();		

		mail.setTo(request.getParameter("email"));
		mail.setSubject("New Registration");
		try{
			mail.setFrom(slups.getValue("contacts","companyid",((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostCompanyId(), "email"));		
		}catch(SQLException sqle){
			System.err.println("sendEmail(from section) failed, error: " + sqle.getMessage());
		}	
		try{	
			mail.setBody(nrm.getBody(request));	
		}catch(SQLException sqle){
			System.err.println("sendEmail(body) failed, error: " + sqle.getMessage());
		}	
		try{	
			mail.send();
		}catch(Exception e){
			System.err.println("sendEmail(send section) failed, error: " + e.getMessage());
		}		
	}
	private void updateCompany(HttpServletRequest request)
	throws SQLException{
	
		ProcessCompany pc = new ProcessCompany();
		pc.setId((String)request.getSession().getAttribute("companyId"));
		pc.setCompanyName(request.getParameter("companyName"));
		pc.setCompanyURL(request.getParameter("companyURL"));
		if(request.getParameter("taxId")!=null){pc.setTaxID(request.getParameter("taxId"));};
		if(request.getParameter("dba")!=null){pc.setDBA(request.getParameter("dba"));};
		if(request.getParameter("attention")!=null){pc.setAttention(request.getParameter("attention"));};
		if(request.getParameter("companyPhone")!=null){pc.setPhone(request.getParameter("companyPhone"));};
		if(request.getParameter("companyFax")!=null){pc.setFax(request.getParameter("companyFax"));};
		if(request.getParameter("billing_entity_id")!=null){pc.setBillingEntityID(request.getParameter("billing_entity_id"));};
		if(request.getParameter("creditLimit")!=null && !request.getParameter("creditLimit").equals("")){pc.setCreditLimit(Double.parseDouble(request.getParameter("creditLimit")));};
		pc.processUpdate();
			
	}
	private void updateContact(HttpServletRequest request)
	throws SQLException{
	
		ProcessContact pc = new ProcessContact();
		pc.setId((String)request.getSession().getAttribute("contactId"));
		pc.setCompanyId((String)request.getSession().getAttribute("companyId"));
		pc.setFirstName(request.getParameter("firstName"));
		pc.setLastName(request.getParameter("lastName"));
		pc.setTitleId(request.getParameter("titleId"));
		pc.setJobTitle(request.getParameter("jobTitle"));
		pc.setEmail(request.getParameter("email"));
		pc.setSiteNumber(request.getParameter("siteNumber"));	
		pc.setPMSiteNumber(request.getParameter("pmSiteNumber"));	
		pc.setDefaultWebsite(request.getParameter("defaultWebsite"));
		pc.update();
		
	}
	private void updateLocations(HttpServletRequest request) 
	throws SQLException{
		ProcessLocation pl = new ProcessLocation();

		//******** mailing addresss *******
		pl.setAddress1(request.getParameter("addressMail1"));
		pl.setAddress2(request.getParameter("addressMail2"));
		pl.setCity(request.getParameter("cityMail"));
		pl.setStateId(request.getParameter("stateMailId"));
		pl.setZipcode(request.getParameter("zipcodeMail"));
		pl.setContactId((String)request.getSession().getAttribute("contactId"));
		pl.setCompanyId((String)request.getSession().getAttribute("companyId"));
		pl.setLocationTypeId(1);
		pl.setCountryId(request.getParameter("countryMailId"));
		pl.update();			
		
		pl.clear();
		//****** billing address *********
		if(request.getParameter("sameAsAbove")==null){ 
			pl.setAddress1(request.getParameter("addressBill1"));
			pl.setAddress2(request.getParameter("addressBill2"));
			pl.setCity(request.getParameter("cityBill"));		
			pl.setStateId(request.getParameter("stateBillId"));
			pl.setZipcode(request.getParameter("zipcodeBill"));
			pl.setContactId((String)request.getSession().getAttribute("contactId"));
			pl.setCompanyId((String)request.getSession().getAttribute("companyId"));
			pl.setLocationTypeId(2);
			pl.setCountryId(request.getParameter("countryBillId"));
			pl.update();		
			
		}else{
		 	pl.setAddress1(request.getParameter("addressMail1"));
			pl.setAddress2(request.getParameter("addressMail2"));
			pl.setCity(request.getParameter("cityMail"));
			pl.setStateId(request.getParameter("stateMailId"));
			pl.setZipcode(request.getParameter("zipcodeMail"));
			pl.setContactId((String)request.getSession().getAttribute("contactId"));
			pl.setCompanyId((String)request.getSession().getAttribute("companyId"));
			pl.setLocationTypeId(2);
			pl.setCountryId(request.getParameter("countryMailId"));
			pl.update();		
			
		}					
	}
	private void updatePhones(HttpServletRequest req) 
	throws SQLException{
		ProcessPhone pp = new ProcessPhone();
		
		pp.deleteContactPhone((String)req.getSession().getAttribute("contactId"));
			
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
				pp.insert();
			}		
		}	
	}
	
	
	private void updateSiteFields(HttpServletRequest request) 
	throws SQLException{
		if (request.getParameter("useSiteFields")==null || request.getParameter("useSiteFields").equals("")) { 
			return;
		}else{
			ProcessSiteFields pp = new ProcessSiteFields();
			pp.setContactId(Integer.parseInt((String)request.getSession().getAttribute("contactId")));
			System.out.println("BeforeDelete");
			pp.deleteContactSiteFields((String)request.getSession().getAttribute("contactId"),request.getParameter("siteHostId"));
			System.out.println("AfterDelete");
			pp.clear();
			pp.setContactId((String)request.getSession().getAttribute("contactId"));
			pp.setSitehostId(Integer.parseInt(request.getParameter("siteHostId")));
			pp.setSiteField1(request.getParameter("siteField1"));
			pp.setSiteField2(request.getParameter("siteField2"));
			pp.setSiteField3(request.getParameter("siteField3"));
			System.out.println("BeforeInsert");
			pp.insert();														
			System.out.println("UpdateSiteFields");
		}
	}
	
	//************ Update User Section **************************	
	/************************************************************
	Note it is assumed the person
	updating the information is the person who is actually logged into the
	system.
	************************************************************/
	
	public Hashtable updateUserInformation(HttpServletRequest request, Hashtable temp){
		
		Hashtable results = temp;	
		results.put("errorMessage","");
		
		//initialize a storage place for current information
		SBPContactBean contactInformation = new SBPContactBean();
		try{
			System.out.println("contactId is "+(String)request.getSession().getAttribute("contactId"));
			contactInformation.setContactId((String)request.getSession().getAttribute("contactId"));
		}catch(Exception e){
			
			results.put("errorMessage","Error initally storing orginial information");
			return results;
		}	
		
		try{	
			//was there an update to contact info
			if (request.getParameter("formChangedContact").equals("1")) {
				updateContact(request);
			}						
		
			//was there an update to locations?
			if (request.getParameter("formChangedLocations").equals("1")) {
				updateLocations(request);
			}
					
			//was there an update to Phones?
			if (request.getParameter("formChangedPhones").equals("1")) {
				updatePhones(request);
			}
			
			//was there an update to company?
			if (request.getParameter("formChangedCompany").equals("1")) {
				updateCompany(request);
			}
			if (request.getParameter("formChangedSiteFields").equals("1")) {
				updateSiteFields(request);
			}
			
		}catch(Exception e){		
			
			restoreContact(contactInformation);
			restoreCompany(contactInformation);
			restoreLocations(contactInformation);
			restorePhones(contactInformation);
			restoreSiteFields(contactInformation);
			
			results.put("errorMessage", "Error updating user information, " + e.getMessage());
			return results;
		}
			
		return results;		
	}
}
