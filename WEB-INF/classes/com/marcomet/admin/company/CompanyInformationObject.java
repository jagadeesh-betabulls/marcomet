package com.marcomet.admin.company;

/**********************************************************************
Description:	This class will hold/retrieve company information

History:
	Date		Author			Description
	----		------			-----------
	10/18/01	Thomas Dietrich		Created
	10/31/01  	td 				Adding change to incorporate ed's country id.
	

**********************************************************************/

import com.marcomet.jdbc.DBConnect;
import java.sql.*;

public class CompanyInformationObject {

	private int companyId;
	private String companyName;
	private String companyURL;

	private String billToAddress1;
	private String billToAddress2;
	private String billToCity;
	private String billToState;
	private int billToStateId;
	private String billToZipcode;
	private int billToCountryId;

	private String payToAddress1;
	private String payToAddress2;
	private String payToCity;
	private String payToState;
	private int payToStateId;
	private String payToZipcode;
	private int payToCountryId;

	private String primaryContactId;
	private String primaryContact;
	private String billToContactId;
	private String billToContact;
	private String payToContactId;
	private String payToContact;
	private String workFlowContactId;
	private String workFlowContact;

	public CompanyInformationObject(int companyId)
	throws SQLException{
		setCompanyId(companyId);
		loadValues();
	}
	public CompanyInformationObject(String companyId)
	throws SQLException{
		setCompanyId(companyId);
		loadValues();		
	}
	public final String getBillToAddress1(){
		return billToAddress1;
	}
	public final String getBillToAddress2(){
		return billToAddress2;
	}
	public final String getBillToCity(){
		return billToCity;
	}
	public final String getBillToContact(){
		return billToContact;
	}
	public final String getBillToContactId(){
		return billToContactId;
	}
	public final int getBillToCountryId(){
		return billToCountryId;
	}
	public final String getBillToState(){
		return billToState;
	}
	public final int getBillToStateId(){
		return billToStateId;
	}
	public final String getBillToZipcode(){
		return billToZipcode;
	}
	public final String getCompanyName(){
		return companyName;
	}
	public final String getCompanyURL(){
		return companyURL;
	}
	public final String getPayToAddress1(){
		return payToAddress1;	
	}
	public final String getPayToAddress2(){
		return payToAddress2;
	}
	public final String getPayToCity(){
		return payToCity;
	}
	public final String getPayToContact(){
		return payToContact;	
	}
	public final String getPayToContactId(){
		return payToContactId;
	}
	public final int getPayToCountryId(){
		return payToCountryId;
	}
	public final String getPayToState(){
		return payToState;
	}
	public final int getPayToStateId(){
		return payToStateId;
	}
	public final String getPayToZipcode(){
		return payToZipcode;
	}
	public final String getPrimaryContact(){
		return primaryContact;
	}
	public final String getPrimaryContactId(){
		return primaryContactId;
	}
	public final String getWorkFlowContact(){
		return workFlowContact;
	}
	public final String getWorkFlowContactId(){
		return workFlowContactId;
	}
	private final void loadValues()
	throws SQLException{
		String sqlCompanyInfo = 
			"SELECT company_name, company_url FROM companies WHERE id = ?";
		String sqlCompanyLocation = 
			"SELECT l.address1 'address1', l.address2 'address2', l.city 'city', luas.value 'state',l.zip 'zipcode', l.country_id 'countryid', l.state 'stateid' FROM company_locations l, lu_abreviated_states luas WHERE l.state = luas.id AND l.lu_location_type_id = ? AND l.company_id = ?";
		String sqlContactInfo = 
			"SELECT c.id 'id', CONCAT(c.lastname,', ',c.firstname) 'contactname' FROM contacts c, contact_types ct WHERE ct.contact_id = c.id AND (ct.lu_contact_type_id = ? OR ct.lu_contact_type_id = 1) AND c.companyid = ? ORDER BY ct.lu_contact_type_id DESC ";	
			
		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
		
			//get company info from companies table
			PreparedStatement companyInfo = conn.prepareStatement(sqlCompanyInfo);
			companyInfo.setInt(1, companyId);
			ResultSet rsInfo = companyInfo.executeQuery();
			
			if(rsInfo.next()){
				companyName = rsInfo.getString("company_name");
				companyURL = rsInfo.getString("company_url");
			}	
					
			//get locations		
			PreparedStatement companyLocation = conn.prepareStatement(sqlCompanyLocation);
			
			//get Bill to location
			companyLocation.setInt(1,2);
			companyLocation.setInt(2,companyId);
			ResultSet rsLocation = companyLocation.executeQuery();
			
			if(rsLocation.next()){
				billToAddress1 = rsLocation.getString("address1");
				billToAddress2 = rsLocation.getString("address2");
				billToCity = rsLocation.getString("city");
				billToState = rsLocation.getString("state");
				billToStateId = rsLocation.getInt("stateid");
				billToZipcode= rsLocation.getString("zipcode");
				billToCountryId = rsLocation.getInt("countryid");
			}	
			
			//get Pay to location
			companyLocation.clearParameters();
			companyLocation.setInt(1,3);
			companyLocation.setInt(2,companyId);
			rsLocation = companyLocation.executeQuery();
			
			if(rsLocation.next()){
				payToAddress1 = rsLocation.getString("address1");
				payToAddress2 = rsLocation.getString("address2");
				payToCity = rsLocation.getString("city");
				payToState = rsLocation.getString("state");
				payToStateId = rsLocation.getInt("stateid");
				payToZipcode= rsLocation.getString("zipcode");			
				payToCountryId = rsLocation.getInt("countryid");
			}	
			
			//get contacts
			PreparedStatement contactInfo = conn.prepareStatement(sqlContactInfo);
			
			//get primary contact
			contactInfo.setInt(1,1);
			contactInfo.setInt(2,companyId);
			
			ResultSet rsContact = contactInfo.executeQuery();
			
			if(rsContact.next()){
				primaryContactId = rsContact.getString("id");
				primaryContact = rsContact.getString("contactname");
			}		
		
			//get bill to contact id
			contactInfo.clearParameters();
			contactInfo.setInt(1,2);
			contactInfo.setInt(2,companyId);
			
			rsContact = contactInfo.executeQuery();
			
			if(rsContact.next()){
				billToContactId = rsContact.getString("id");
				billToContact = rsContact.getString("contactname");
			}
				
			//get pay to contact id
			contactInfo.clearParameters();
			contactInfo.setInt(1,3);
			contactInfo.setInt(2,companyId);
			
			rsContact = contactInfo.executeQuery();
			
			if(rsContact.next()){
				payToContactId = rsContact.getString("id");
				payToContact = rsContact.getString("contactname");
			}	
		
			//get workflow contact id
			contactInfo.clearParameters();
			contactInfo.setInt(1,4);
			contactInfo.setInt(2,companyId);
			
			rsContact = contactInfo.executeQuery();
			
			if(rsContact.next()){
				workFlowContactId = rsContact.getString("id");
				workFlowContact = rsContact.getString("contactname");
			}	
		
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		}finally{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	
	}
	public final void setCompanyId(int id){
		this.companyId = id;
	}
	public final void setCompanyId(String id){
		this.companyId = Integer.parseInt(id);			
	}
}
