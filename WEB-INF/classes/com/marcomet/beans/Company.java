package com.marcomet.beans;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Date;
import java.util.Vector;

import com.marcomet.jdbc.DBConnect;

public class Company {

	private int id = -1; 
	private String company_name = null;
	private String company_url = null;
	private java.util.Date date_created = null;
	private java.util.Date date_last_modified = null;
	private int buyer_view = 0;
	private int credit_status = 0;
	private int tax_exempt = 0;
	private String taxid = null;
	private String dba = null;
	private String attention = null;
	private int billing_entity_id = 1;
	private String phone = null;
	private String fax = null;
	private Vector locations = null;
	private CompanyLocation shippingLoc = null;
	private CompanyLocation billingLoc = null;
	private CompanyLocation payToLoc = null;
	private CompanyLocation warehouseLoc = null;
	
	
	public Company() {
		super();
	}
	
	public Company( int compID ) {
		
		setID( compID );
		if ( loadCompany() ){
			//locations = CompanyLocation.getCompanyLocations(compID);
			shippingLoc = CompanyLocation.getCompanyLocation(compID, CompanyLocation.SHIPPING_TYPE_ID);
			billingLoc = CompanyLocation.getCompanyLocation(compID, CompanyLocation.BILLING_TYPE_ID);
			payToLoc = CompanyLocation.getCompanyLocation(compID, CompanyLocation.PAYTO_TYPE_ID);
			warehouseLoc = CompanyLocation.getCompanyLocation(compID, CompanyLocation.WAREHOUSE_TYPE_ID);		
		} 
	}
	
	private boolean loadCompany() {
		
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();
		boolean success = false;
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("SELECT * FROM companies WHERE id = ");
			buff.append(getID());
			
			ResultSet result = qs.executeQuery(buff.toString());	
			if ( result.next()) {
				setCompanyName(result.getString("company_name"));
				setCompanyURL(result.getString("company_url"));
				setBuyerView(result.getInt("buyer_view"));
				setCreditStatus(result.getInt("credit_status"));
				setTaxExempt(result.getInt("tax_exempt"));
				setBillingEntityID(result.getInt("billing_entity_id"));				
				setTaxID(result.getString("taxid"));
				setDBA(result.getString("dba"));
				setAttention(result.getString("attention"));
				setPhone(result.getString("phone"));
				setFax(result.getString("fax"));
				setDateCreated(result.getDate("date_created"));				
				setDateLastModified(result.getDate("date_last_modified"));
				//company record found
				success = true;
			}
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return success;
	}
	
		
	static public Company getCompanyByTaxID(String compTaxID) {
		
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();
		Company comp = null;
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("SELECT id FROM companies WHERE taxid = '");
			buff.append(compTaxID);
			buff.append("'");			
			//System.out.println(buff.toString());
			
			ResultSet result = qs.executeQuery(buff.toString());	
			if ( result.next()) {
				//System.out.println("x id= " + result.getInt("id") );
				comp = new Company(result.getInt("id"));
			}
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return comp;
		
	}
	
	static public int getCompanyID(String compTaxID) {
		
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();
		int compID = -1;
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("SELECT id FROM companies WHERE taxid = '");
			buff.append(compTaxID);
			buff.append("'");			
			//System.out.println(buff.toString());
			
			ResultSet result = qs.executeQuery(buff.toString());	
			if ( result.next()) {
				//System.out.println("x id= " + result.getInt("id") );
				compID = result.getInt("id");
			}
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return compID;
		
	}
	
	
	static public String getBillingEntityName(int entityID){
		String name = "";
		
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();		
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("SELECT value FROM lu_billing_entity WHERE id = ");
			buff.append(entityID);
			
			ResultSet result = qs.executeQuery(buff.toString());	
			if ( result.next()) {
				name = result.getString("value");				
			}
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return name;
	}

	
	private void setID(int val) {
		id = val;
	}
	public void setCompanyName(String val) {
		company_name = val;
	}
	public void setCompanyURL(String val) {
		company_url = val;		
	}
	private void setDateCreated( java.util.Date val){
		date_created = val;
	}
	private void setDateLastModified(java.util.Date val) {
		date_last_modified = val;
	}
	public void setBuyerView(int val){
		buyer_view = val;
	}
	public void setCreditStatus(int val){
		credit_status = val;
	}
	public void setTaxExempt(int val){
		tax_exempt = val;
	}
	public void setBillingEntityID(int val){
		billing_entity_id = val;
	}
	public void setTaxID(String val) {
		taxid = val;		
	}
	public void setDBA(String val) {
		dba = val;		
	}
	public void setAttention(String val) {
		attention = val;		
	}
	public void setPhone(String val) {
		phone = val;		
	}
	public void setFax(String val) {
		fax = val;		
	}
	
	
	public int getID() {
		return id;
	}
	public String getCompanyName() {
		if ( company_name == null)
			return "";
		return company_name;
	}
	public String getCompanyURL() {
		if ( company_url == null)
			return "";
		return company_url;		
	}
	public java.util.Date getDateCreated(){
		if ( date_created == null)
			return new Date();
		return date_created;
	}
	public java.util.Date getDateLastModified() {
		if ( date_last_modified == null)
			return getDateCreated();
		return date_last_modified;
	}
	public int getBuyerView(){
		return buyer_view;
	}
	public int getCreditStatus(){
		return credit_status;
	}
	public int getTaxExempt(){
		return tax_exempt;
	}
	public int getBillingEntityID(){
		return billing_entity_id;
	}
	public String getTaxID() {
		if ( taxid == null)
			return "";
		return taxid;		
	}
	public String getDBA() {
		if ( dba == null)
			return "";
		return dba;		
	}
	public String getAttention() {
		if ( attention == null)
			return "";
		return attention;		
	}
	public String getPhone() {
		if ( phone == null)
			return "";
		return phone;		
	}
	public String getFax() {
		if ( fax == null)
			return "";
		return fax;		
	}
	public CompanyLocation getShippingLocation() {
		return shippingLoc;
	}
	public CompanyLocation getBillingLocation() {
		return billingLoc;
	}
	public CompanyLocation getPayToLocation() {
		return payToLoc;
	}
	public CompanyLocation getWarehouseLocation() {
		return warehouseLoc;
	}
	
	public CompanyLocation getShippingLocationEmptyIfNull() {
		if ( shippingLoc == null)
			return new CompanyLocation();
		return shippingLoc;
	}
	public CompanyLocation getBillingLocationEmptyIfNull() {
		if ( billingLoc == null)
			return new CompanyLocation();
		return billingLoc;
	}
	public CompanyLocation getPayToLocationEmptyIfNull() {
		if ( payToLoc == null)
			return new CompanyLocation();
		return payToLoc;
	}
	public CompanyLocation getWarehouseLocationEmptyIfNull() {
		if ( warehouseLoc == null)
			return new CompanyLocation();
		return warehouseLoc;
	}
	
	
}
