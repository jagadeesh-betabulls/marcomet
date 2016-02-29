/**********************************************************************
Description:	This class will dynamicly look up Contact Information

Note:	This object only handles three phone numbers, if more is needed
		code must be added to.
**********************************************************************/

package com.marcomet.beans;

import com.marcomet.tools.*;
import com.marcomet.jdbc.DBConnect;
import java.util.*;
import java.sql.*;


public class SBPContactBean {
	
	
	private int contactId = 0;
	private int titleId;
	private String firstName = "";
	private String lastName = "";
	private String jobTitle = "";
	private String email = "";
	private String siteNumber;
	private String pmSiteNumber;
	private String defaultWebsite;
	
	//Site specific info
	private String sitehostId;
	private String siteField1;
	private String siteField2;
	private String siteField3;
	private String useSitefields;
	
	//login info
	private String loginName = "";

	//Addresses
	private int locationMailId;
	private int locationMailTypeId;
	private String addressMail1 = "";
	private String addressMail2 = "";
	private String cityMail = "";
	private int stateMailId = 0;
	private String zipcodeMail = "";
	private int countryMailId;

	private boolean sameAsAbove = false;         //for matching billing with mailing

	private int locationBillId;
	private int locationBillTypeId;
	private String addressBill1 = "";
	private String addressBill2 = "";
	private String cityBill = "";
	private int stateBillId = 0;
	private String zipcodeBill = "";
	private int countryBillId;

	//company info
	private String companyName = "";
	private int companyId = 0;
	private String companyURL = "";
	private String dba = "";
	private String taxID = "";
	private String attention = "";
	private int billing_entity_id = -1;
	private String compPhone = "";
	private String compFax = "";
	private String creditLimit="";

	//phones
	private int phoneTypeId0 = 1;
	private int phoneTypeId1 = 2;
	private int phoneTypeId2 = 3;
	private String areaCode0 = "";
	private String areaCode1 = "";
	private String areaCode2 = "";
	private String prefix0 = "";
	private String prefix1 = "";
	private String prefix2 = "";
	private String lineNumber0 = "";
	private String lineNumber1 = "";
	private String lineNumber2 = "";
	private String extension0 = "";
	private String extension1 = "";
	private String extension2 = "";

	/*
	commented out; it was thought that it would be used to update/fix contacttypes
	that were changed during the use of the registration tool, but that is generally
	for users(and new ones) not for admins to adjust company information.
	*/
	//private Vector contactTypeIds;        
	
	private String newUserName = "";
	private String newPassword = "";
		
	public SBPContactBean(){
		//contactTypeIds = new Vector();
	}

	public final int getContactId(){
		return contactId;
	}
	public final void setContactId(int temp) throws Exception{
		contactId = temp;
		setContactInfo();		
	}
	public final void setContactId(String temp) throws Exception {
		try {
			setContactId(Integer.parseInt(temp));
		}catch(NumberFormatException npe) {
		}
	
	}

	public final int getTitleId(){
		return titleId;
	}
	public final String getTitleIdString(){
		return titleId + "";
	}	
	public final void setTitleId(int temp) {
			titleId = temp;
	}
	public final void setTitleId(String temp){
		setTitleId(Integer.parseInt(temp));
	}

	public final String getFirstName(){
		if(firstName != null){
			return firstName;
		}else{
			return "";
		}
	}
	public final void setFirstName(String temp){
		firstName = temp;
	}

	public final String getLastName(){
		if(lastName != null){
			return lastName;
		}else{
			return "";
		}
	}
	public final void setLastName(String temp){
		lastName = temp;
	}

	public final String getJobTitle(){
		if(jobTitle != null){
			return jobTitle;
		}else{
			return "";
		}
	}
	public final void setJobTitle(String temp){
		jobTitle = temp;
	}

	public final String getEmail(){
		if(email != null){
			return email;
		}else{
			return "";
		}
	}
	public final void setEmail(String temp){
		email = temp;
	}

	public final String getLoginName(){
		return loginName;
	}	

	//********mailing address....
	public final int getLocationMailId() {
		return locationMailId;
	}
	public final String getLocationMailIdString() {
		return locationMailId + "";
	}
	public final int getLocationMailTypeId() {
		return locationMailTypeId;
	}
	public final String getLocationMailTypeIdString() {
		return locationMailTypeId + "";
	}

	public final String getAddressMail1(){
		if(addressMail1 != null){
			return addressMail1;
		}else{
			return "";
		}
	}
	public final String getAddressMail2(){
		if(addressMail2 != null){
			return addressMail2;
		}else{
			return "";
		}
	}
	public final void setAddressMail1(String temp){
		addressMail1 = temp;
	}
	public final void setAddressMail2(String temp){
		addressMail2 = temp;
	}
		
	public final String getCityMail(){
		if(cityMail != null){
			return cityMail;
		}else{
			return "";
		}
	}
	public final void setCityMail(String temp){
		cityMail = temp;
	}

	public final int getStateMailId(){
		return stateMailId;
	}
	public final void setStateMailId(int temp) {
		stateMailId = temp;
	}
	public final void setStateMailId(String temp){
		setStateMailId(Integer.parseInt(temp));
	}

	
	public final String getStateMailIdString() {
		return stateMailId + "";
	}
		
	
	public final String getZipcodeMail(){
		if(zipcodeMail != null){
			return zipcodeMail;
		}else{
			return "";
		}
	}
	public final void setZipcodeMail(String temp){
		zipcodeMail = temp;
	}

	public final int getCountryMailId(){
		return countryMailId;
	}
	public final void setCountryMailId(int temp) {
		countryMailId = temp;
	}
	public final void setCountryMailId(String temp){
		setCountryMailId(Integer.parseInt(temp));
	}

	
	public final String getCountryMailIdString() {
		return countryMailId + "";
	}

//Same as above
	public final boolean getSameAsAbove(){
		return sameAsAbove;
	}
	public final void setSameAsAbove(boolean temp){
		sameAsAbove = temp;
	}
	

//Billing Address
	public final int getLocationBillId() {
		return locationBillId;
	}
	public final String getLocationBillIdString() {
		return locationBillId + "";
	}
	public final int getLocationBillTypeId() {
		return locationBillTypeId;
	}
	public final String getLocationBillTypeIdString() {
		return locationBillTypeId + "";
	}

	public final String getAddressBill1(){
		if(addressBill1 != null){
			return addressBill1;
		}else{
			return "";
		}
	}
	public final void setAddressBill1(String temp){
		addressBill1 = temp;
	}
		
	public final String getAddressBill2(){
		if(addressBill2 != null){
			return addressBill2;
		}else{
			return "";
		}
	}	
	public final void setAddressBill2(String temp){
		addressBill2 = temp;
	}	

	public final String getCityBill(){
		if(cityBill != null){
			return cityBill;
		}else{
			return "";
		}
	}
	public final void setCityBill(String temp){
		cityBill = temp;
	}

	public final int getStateBillId(){
		return stateBillId;
	}
	public final String getStateBillIdString() {
		return stateBillId +"";
	}
	public final void setStateBillId(int temp) {	
		stateBillId = temp;
	}	
	
	public final String getZipcodeBill(){
		return zipcodeBill;
	}	
	public final void setZipcodeBill(String temp){
		zipcodeBill = temp;
	}	
	
	
	public final int getCountryBillId(){
		return countryBillId;
	}
	public final void setCountryBillId(int temp) {
		countryBillId = temp;
	}
	public final void setCountryBillId(String temp){
		setCountryBillId(Integer.parseInt(temp));
	}

	
	public final String getCountryBillIdString() {
		return countryBillId + "";
	}	
		
	public final void setSiteNumber(String temp){
		siteNumber = temp;
	}
	public final String getSiteNumber(){
		return ((siteNumber==null)?"":siteNumber);
	}
	
	public final void setPMSiteNumber(String temp){
		pmSiteNumber = temp;
	}
	public final String getPMSiteNumber(){
		return ((pmSiteNumber==null)?"":pmSiteNumber);
	}
	
	public final void setDefaultWebsite(String temp){
		defaultWebsite = temp;
	}
	public final String getDefaultWebsite(){
		return ((defaultWebsite==null)?"":defaultWebsite);
	}	


//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&	


	public final String getAreaCode(int i){
		switch(i){
			case 0: return getAreaCode0(); 
			case 1: return getAreaCode1(); 
			case 2: return getAreaCode2(); 
		}
		return "";
	}
	public final String getAreaCode0(){
		return areaCode0;
	}
	public final String getAreaCode1(){
		return areaCode1;
	}
	public final String getAreaCode2(){		
		return areaCode2;
	}


	public final int getCompanyId(){
			return companyId;
	}
	public final String getCompanyIdString() {
		return companyId + "";
	}
	public final String getCompanyName(){
		if(companyName != null){
			return companyName;
		}else{
			return "";
		}
	}
	public final String getCompanyURL(){
		if(companyURL != null){
			return companyURL;
		}else{
			return "";
		}
	}
	public final String getDBA(){
		if(dba != null){
			return dba;
		}else{
			return "";
		}
	}
	
	public final String getTaxID(){
		if(taxID != null){
			return taxID;
		}else{
			return "";
		}
	}
	
	public final String getAttention(){
		if(attention == null)
			return "";
	
		return attention;		
	}
	
	public final String getCompPhone(){
		if(compPhone == null)
			return "";
	
		return compPhone;		
	}
	
	public final String getCompFax(){
		if(compFax == null)
			return "";
	
		return compFax;		
	}
	
	public final int getBillingEntityID(){	
		return billing_entity_id;		
	}


	public final String getExtension(int i){
		switch(i){
			case 0: return getExtension0(); 
			case 1: return getExtension1(); 
			case 2: return getExtension2(); 
		}
		return "";
	}
	public final String getExtension0(){
		return extension0;
	}
	public final String getExtension1(){
		return extension1;
	}
	public final String getExtension2(){
		return extension2;
	}



	public final String getLineNumber(int i){
		switch(i){
			case 0: return getLineNumber0(); 
			case 1: return getLineNumber1(); 
			case 2: return getLineNumber2(); 
		}
		return "";
	}
	public final String getLineNumber0(){
		return lineNumber0;
	}
	public final String getLineNumber1(){
		return lineNumber1;
	}
	public final String getLineNumber2(){
		return lineNumber2;
	}
	//Billing address....

	public final String getNewPassword(){
		return newPassword;
	}
	/*
	This section is for a easy solution, this is hard coded for only three 
	phone number, if different, up date the ShoppingCart, the process order
	jsp, and the checkout jsp.  Remind me to fix this or kick my ass for this.
	*/
	public final int getPhoneTypeId(int i){
		switch(i){
			case 0: return getPhoneTypeId0(); 
			case 1: return getPhoneTypeId1(); 
			case 2: return getPhoneTypeId2(); 
		}
		return 0;
	}
	public final int getPhoneTypeId0(){
		return phoneTypeId0;
	}
	public final String getPhoneTypeId0String() {
		return phoneTypeId0 + "";
	}
	public final int getPhoneTypeId1(){
		return phoneTypeId1;
	}
	public final String getPhoneTypeId1String() {
		return phoneTypeId1 + "";
	}
	public final int getPhoneTypeId2(){
		return phoneTypeId2;
	}
	public final String getPhoneTypeId2String() {
		return phoneTypeId2 + "";
	}
	public final String getPhoneTypeIdString(int i){
		switch(i){
			case 0: return getPhoneTypeId0String(); 
			case 1: return getPhoneTypeId1String(); 
			case 2: return getPhoneTypeId2String(); 
		}
		return "";
	}
	public final String getPrefix(int i){
		switch(i){
			case 0: return getPrefix0(); 
			case 1: return getPrefix1(); 
			case 2: return getPrefix2(); 
		}
		return "";
	}
	public final String getPrefix0(){
		return prefix0;
	}
	public final String getPrefix1(){
		return prefix1;
	}
	public final String getPrefix2(){
			return prefix2;
	}



	public final String getNewUserName(){
		return newUserName;
	}



//	public final Vector getContactTypeId(){
//		return contactTypeIds;
//	}	
	


	public final void setAreaCode0(String temp){
		areaCode0 = temp;
	}
	public final void setAreaCode1(String temp){
		areaCode1 = temp;
	}
	public final void setAreaCode2(String temp){
		areaCode2 = temp;
	}


	public final void setCompanyId(int temp) {
		companyId = temp;
	}
	public final void setCompanyId(String temp){
		setCompanyId(Integer.parseInt(temp));
	}
	public final void setCompanyName(String temp){
		companyName = temp;
	}
	public final void setCompanyURL(String temp){
		companyURL = temp;
	}
	public final void setDBA(String temp){
		dba = temp;
	}
	public final void setTaxID(String temp){
		taxID = temp;
	}
	public final void setAttention(String temp){
		attention = temp;
	}
	public final void setPhone(String temp){
		compPhone = temp;
	}
	public final void setFax(String temp){
		compFax = temp;
	}
	public final void setBillingEntityID(int temp){
		billing_entity_id = temp;
	}

	private void setContactInfo()throws Exception{
		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
		
			SimpleLookups slups = new SimpleLookups();
			ResultSet rs;
	
			PreparedStatement selectContact;
			PreparedStatement selectCompany;
			PreparedStatement selectLocation;
			PreparedStatement selectPhones;
	//		PreparedStatement selectContactTypes;
			PreparedStatement selectLoginInfo;
	
			String selectContactText = "SELECT * FROM contacts WHERE id = ?";
			String selectCompanyText = "SELECT * FROM companies WHERE id = ?";
			String selectLocationText = "SELECT * FROM locations WHERE contactid = ? AND companyid = ? AND locationtypeid = ?";
			String selectPhonesText = "SELECT * FROM phones WHERE contactid = ? ORDER BY phonetype";
			String selectLoginInfoText = "SELECT user_name FROM logins WHERE contact_id = ?";
	//		String selectContactTypesText = "SELECT contact_type_id FROM contact_types WHERE contact_id = ?";
	
	
			//get contact info
			selectContact = conn.prepareStatement(selectContactText);
			selectContact.clearParameters();
			selectContact.setInt(1,contactId);	
			rs = selectContact.executeQuery();
	
			if(rs.next()){	
				titleId = rs.getInt("titleid");
				firstName = rs.getString("firstname");
				lastName = rs.getString("lastname");
				jobTitle = rs.getString("jobtitle");
				email = rs.getString("email");
				companyId = rs.getInt("companyid");
				siteNumber = rs.getString("default_site_number");
				pmSiteNumber = rs.getString("default_pm_site_number");
				defaultWebsite = rs.getString("default_website");
			}
	
			//get Mailing Address
			selectLocation = conn.prepareStatement("SELECT * FROM locations WHERE contactid = ? AND companyid = ? AND locationtypeid = ?");
			selectLocation.clearParameters();
			selectLocation.setInt(1,contactId);
			selectLocation.setInt(2,companyId);
			selectLocation.setInt(3,1);													//hard coded, from lu_location_types
			rs = selectLocation.executeQuery();
	
			if(rs.next()){
				locationMailId = rs.getInt("id");
				locationMailTypeId = rs.getInt("locationtypeid");
				addressMail1 = rs.getString("address1");
				addressMail2 = rs.getString("address2");
				cityMail = rs.getString("city");
				stateMailId = rs.getInt("state");
				zipcodeMail = rs.getString("zip");
				countryMailId = rs.getInt("country_id");
			}
	
			//get Billing Address
			selectLocation.setInt(3,2);                              //hard coded, from lu_location_types	
			rs = selectLocation.executeQuery();
	
			if(rs.next()){
				locationBillId = rs.getInt("id");
				locationBillTypeId = rs.getInt("locationtypeid");
				addressBill1 = rs.getString("address1");
				addressBill2 = rs.getString("address2");
				cityBill = rs.getString("city");
				stateBillId = rs.getInt("state");
				zipcodeBill = rs.getString("zip");
				countryBillId = rs.getInt("country_id");
			}
	
			//get Company Info
			selectCompany = conn.prepareStatement(selectCompanyText);
			selectCompany.setInt(1,companyId);
			rs = selectCompany.executeQuery();
	
			if(rs.next()){
				companyName = rs.getString("company_name");
				companyURL = rs.getString("company_url");
				dba = rs.getString("dba");
				taxID = rs.getString("taxid");
				attention = rs.getString("attention");
				compPhone = rs.getString("phone");
				compFax = rs.getString("fax");
				billing_entity_id = ((rs.getString("billing_entity_id")==null)?-1:rs.getInt("billing_entity_id"));
			}
	
			//get Phones
			selectPhones = conn.prepareStatement(selectPhonesText);
			selectPhones.setInt(1,contactId);
			rs = selectPhones.executeQuery();
	
			if(rs.next()){
				phoneTypeId0 = rs.getInt("phonetype");           //should be phonetypeid, but mistake in db is used everywhere.
				areaCode0 = rs.getString("areacode");
				prefix0 = rs.getString("phone1");
				lineNumber0 = rs.getString("phone2");
				extension0 = rs.getString("extension");
			}else{
				phoneTypeId0 = 0;
				areaCode0 = "";
				prefix0 = "";
				lineNumber0 = "";
				extension0 = "";		
			}
	
			if(rs.next()){
				phoneTypeId1 = rs.getInt("phonetype");           //should be phonetypeid, but mistake in db is used everywhere.
				areaCode1 = rs.getString("areacode");
				prefix1 = rs.getString("phone1");
				lineNumber1 = rs.getString("phone2");
				extension1 = rs.getString("extension");			
			}else{
				phoneTypeId1 = 0;
				areaCode1 = "";
				prefix1 = "";
				lineNumber1 = "";
				extension1 = "";		
			}		
	
			if(rs.next()){
				phoneTypeId2 = rs.getInt("phonetype");           //should be phonetypeid, but mistake in db is used everywhere.
				areaCode2 = rs.getString("areacode");
				prefix2 = rs.getString("phone1");
				lineNumber2 = rs.getString("phone2");
				extension2 = rs.getString("extension");
			}else{
				phoneTypeId2 = 0;
				areaCode2 = "";
				prefix2 = "";
				lineNumber2 = "";
				extension2 = "";		
			}
		
		
			selectLoginInfo = conn.prepareStatement(selectLoginInfoText);
			selectLoginInfo.clearParameters();
			selectLoginInfo.setInt(1,getContactId());	
			rs = selectLoginInfo.executeQuery();
			
			if(rs.next()){
				loginName = rs.getString("user_name");	
			}
			
			String selectSitehostFields = "SELECT * FROM contact_site_fields WHERE contact_id = ? and sitehost_id=?";
			//get sitehost-specific fields
			if(sitehostId!=null && !sitehostId.equals("")){
				selectContact = conn.prepareStatement(selectSitehostFields);
				selectContact.clearParameters();
				selectContact.setInt(1,contactId);
				selectContact.setInt(2,Integer.parseInt(sitehostId));
				rs = selectContact.executeQuery();
		
				if(rs.next()){	
					siteField1 = rs.getString("site_Field_1");
					siteField2 = rs.getString("site_Field_2");
					siteField3 = rs.getString("site_Field_3");
				}
			}
			//get contact types
			
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	

	public final void setExtension0(String temp){
		extension0 = temp;
	}
	public final void setExtension1(String temp){
		extension1 = temp;
	}
	public final void setExtension2(String temp){
		extension2 = temp;
	}



	public final void setLineNumber0(String temp){
		lineNumber0 = temp;
	}
	public final void setLineNumber1(String temp){
		lineNumber1 = temp;
	}
	public final void setLineNumber2(String temp){
		lineNumber2 = temp;
	}
	public final void setNewPassword(String temp){
		newPassword = temp;
	}
	public final void setPhoneTypeId0(int temp) {
		phoneTypeId0 = temp;
	}
	//********phones**********	
	public final void setPhoneTypeId0(String temp){
		setPhoneTypeId0(Integer.parseInt(temp));
	}
	public final void setPhoneTypeId1(int temp) {
		phoneTypeId1 = temp;
	}
	public final void setPhoneTypeId1(String temp){
		setPhoneTypeId1(Integer.parseInt(temp));
	}
	public final void setPhoneTypeId2(int temp){
		phoneTypeId2 = temp;
	}
	public final void setPhoneTypeId2(String temp){
		setPhoneTypeId2(Integer.parseInt(temp));
	}
	public final void setPrefix0(String temp){
		prefix0 = temp;
	}
	public final void setPrefix1(String temp){
		prefix1 = temp;
	}
	public final void setPrefix2(String temp){
		prefix2 = temp;
	}


	//*********** State  Bill *********
	public final void setStateBillId(String temp){
		setStateBillId(Integer.parseInt(temp));
	}

	//********* login section *******
	public final void setNewUserName(String temp){
		newUserName = temp;
	}
	//********* Zipcode Bill ************

	//******** Zipcode *********


	protected void finalize() {
		
	}

	public String getSiteField1() {
		return siteField1;
	}

	public void setSiteField1(String siteField1) {
		this.siteField1 = siteField1;
	}

	public String getSiteField2() {
		return siteField2;
	}

	public void setSiteField2(String siteField2) {
		this.siteField2 = siteField2;
	}

	public String getSiteField3() {
		return siteField3;
	}

	public void setSiteField3(String siteField3) {
		this.siteField3 = siteField3;
	}

	public String getSitehostId() {
		return sitehostId;
	}

	public void setSitehostId(String sitehostId) {
		this.sitehostId = sitehostId;
	}

	public String getUseSitefields() {
		return ((useSitefields == null)?"":useSitefields);
	}

	public void setUseSitefields(String useSitefields) {
		this.useSitefields = useSitefields;
	}

	public String getCreditLimit() {
		return creditLimit;
	}

	public void setCreditLimit(String creditLimit) {
		this.creditLimit = creditLimit;
	}

}
