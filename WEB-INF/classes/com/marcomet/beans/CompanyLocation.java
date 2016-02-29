package com.marcomet.beans;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Vector;

import com.marcomet.jdbc.DBConnect;

public class CompanyLocation {

	static final public int SHIPPING_TYPE_ID = 1;
	static final public int BILLING_TYPE_ID = 2;
	static final public int PAYTO_TYPE_ID = 3;
	static final public int WAREHOUSE_TYPE_ID = 4;
		
	private int id = -1; 
	private int company_id = -1; 
	private int location_type_id = 2;
	private String addr1 = null;
	private String addr2 = null;
	private String city = null;
	private String state = null;
	private int state_id = -1;
	private int country_id = 1;
	private String zip = null;
	private String fax = null;
	private String notes = null;
	
	
	public CompanyLocation() {
		super();
	}
	
	public CompanyLocation( int compLocID ) {
		
		setID(compLocID);
		loadCompanyLocation();
	}
	
	private void loadCompanyLocation() {
		
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("SELECT * FROM company_locations WHERE id = ");
			buff.append(getID());
			
			ResultSet result = qs.executeQuery(buff.toString());	
			if ( result.next()) {
				setCompanyID(result.getInt("company_id"));
				setLocationTypeID(result.getInt("lu_location_type_id"));				
				setAddress1(result.getString("address1"));
				setAddress2(result.getString("address2"));
				setCity(result.getString("city"));
				//setState(result.getString("state"));
				setStateNumber(result.getInt("state"));
				setZipcode(result.getString("zip"));
				setCountry(result.getInt("country_id"));
				setFax(result.getString("fax"));
				setNotes(result.getString("notes"));
				
			}
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	static public Vector getCompanyLocations(int companyID) {
		
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();
		Vector vec = new Vector();
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("SELECT * FROM company_locations WHERE company_id = ");
			buff.append(companyID);
			
			ResultSet result = qs.executeQuery(buff.toString());	
			while ( result.next()) {
				vec.add(new CompanyLocation(result.getInt("company_id")));				
			}
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		return vec;
	}
	
	static public CompanyLocation getCompanyLocation(int companyID, int locTypeID) {
		
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();
		CompanyLocation loc = null;
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("SELECT id FROM company_locations WHERE company_id = ");
			buff.append(companyID);
			buff.append(" and lu_location_type_id = ");
			buff.append(locTypeID);			
			
			ResultSet result = qs.executeQuery(buff.toString());	
			if ( result.next()) {
				loc = new CompanyLocation(result.getInt("id"));				
			}
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		return loc;
	}
	
	
	synchronized public boolean addLocation() {
		
		boolean success = false;
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("INSERT into company_locations (id, company_id, lu_location_type_id, ");
			buff.append("address1, address2, city, state, zip, country_id, fax, notes) values (");
			if ( getID() == -1 )
				buff.append(getNextID(qs));
			else
				buff.append(getID());
			
			buff.append(",");
			buff.append(getCompanyID());
			buff.append(",");
			buff.append(getLocationTypeID());
			buff.append(",'");
			buff.append(getAddress1());
			buff.append("','");
			buff.append(getAddress2());
			buff.append("','");
			buff.append(getCity());
			buff.append("',");
			buff.append(getStateNumber());
			buff.append(",'");
			buff.append(getZipcode());
			buff.append("',");
			buff.append(getCountry());
			buff.append(",'");
			buff.append(getFax());
			buff.append("','");
			buff.append(getNotes());
			buff.append("'");
						
			//System.out.println(buff.toString());
			int rows = qs.executeUpdate(buff.toString());	
			
			success = true;
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		return success;
	}
	
	
	private int getNextID(Statement stmt) {
		
		ResultSet result = null;
		int nextID = 0;
		
		try {
			result = stmt.executeQuery("SELECT max(id) as id from company_locations");
			if ( result.next() ) {
				nextID = result.getInt("id") + 1;
			}
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		}
		return nextID;
	}
	
	private void setID( int val ) {
		id = val;
	}	
	public void setCompanyID( int val ) {
		company_id = val;
	}
	public void setLocationTypeID( int val ) {
		location_type_id = val;
	}
	public void setAddress1( String val ) {
		addr1 = val;
	}	
	public void setAddress2( String val ) {
		addr2 = val;
	}	
	public void setCity( String val ) {
		city = val;
	}	
	public void setState( String val ) {
		state = val;
	}	
	public void setStateNumber( int val ) {
		state_id = val;
	}	
	public void setZipcode( String val ) {
		zip = val;
	}	
	public void setCountry( int val ) {
		country_id = val;
	}
	public void setFax( String val ) {
		fax = val;
	}
	public void setNotes( String val ) {
		notes = val;
	}
	
	
	public int getID() {
		return id;
	}	
	public int getCompanyID() {
		return company_id;
	}
	public int getLocationTypeID() {
		return location_type_id;
	}
	public String getAddress1() {
		if ( addr1 == null )
			return "";
		return addr1;
	}	
	public String getAddress2() {
		if ( addr2 == null )
			return "";
		return addr2;
	}	
	public String getCity() {
		if ( city == null )
			return "";
		return city;
	}	
	public String getState() {
		if ( state == null )
			return "";
		return state;
	}	
	public int getStateNumber() {		
		return state_id;
	}	
	public String getZipcode() {
		if ( zip == null )
			return "";
		return zip;
	}	
	public int getCountry() {
		return country_id;
	}
	public String getFax() {
		if ( fax == null )
			return "";
		return fax;
	}
	public String getNotes() {
		if ( notes == null )
			return "";
		return notes;
	}
	
}
