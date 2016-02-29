package com.marcomet.beans;

import java.sql.*;
import com.marcomet.jdbc.DBConnect;

public class Store {

	private int id = -1;
	private int site = -1;
	private int company_id = -1;
	private String chainCode = null;
	private String mc_client = null;
	private String site_name = null;
	private String addr1 = null;
	private String addr2 = null;
	private String city = null;
	private String state = null;
	private int state_id = -1;
	private String country = null;
	private String zip = null;
	
	public Store( int id ) {
				
		setID( id );
		loadStore();
	}
	
	private void loadStore() {
		
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("SELECT s.*, lus.id as state_number FROM stores s LEFT JOIN lu_abreviated_states lus on ( lus.value = s.state ) WHERE s.id = ");
			buff.append(getID());
			
			ResultSet result = qs.executeQuery(buff.toString());	
			if ( result.next()) {
				setSite(result.getInt("site"));
				setCompanyID(result.getInt("company_id"));
				setChainCode(result.getString("chn"));
				setMcClient(result.getString("mc_client"));
				setSiteName(result.getString("site_name"));
				setAddress1(result.getString("addr1"));
				setAddress2(result.getString("addr2"));
				setCity(result.getString("city"));
				setState(result.getString("state"));
				setStateNumber(result.getInt("state_number"));
				setZipcode(result.getString("zip"));
				setCountry(result.getString("country"));
			}
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public boolean addContact(int contactID) {
		boolean success = false;
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("INSERT into contact_stores (contact_id, store_id, creation_date) values (");
			buff.append(contactID);
			buff.append(",");
			buff.append(getID());
			buff.append(", CURRENT_TIMESTAMP)");
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
	
	static public Store getStore(String chainCode, int siteID) {
			
		Store store = null;
		int id = -1;
		
		try {			
			id = getStoreID(chainCode, siteID);
			store = new Store(id);
			
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} 
		
		return store;
		
	}
	
	static public int getStoreID(String chainCode, int siteID) {
		
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();
		int storeID = -1;
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("SELECT id FROM stores WHERE chn = '");
			buff.append(chainCode);
			buff.append("' and site = ");
			buff.append(siteID);
			//System.out.println(buff.toString());
			
			ResultSet result = qs.executeQuery(buff.toString());	
			if ( result.next()) {
				//System.out.println("x id= " + result.getInt("id") );
				storeID = result.getInt("id");
			}
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return storeID;
		
	}
	
	static public Store getStoreByClient(String mc_client, int siteID) {
		
		Store store = null;
		int id = -1;
		
		try {			
			id = getStoreIDByClient(mc_client, siteID);
			store = new Store(id);
			
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} 
		
		return store;
		
	}
	
static public int getStoreIDByClient(String mc_client, int siteID) {
		
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();
		int storeID = -1;
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("SELECT id FROM stores WHERE mc_client = '");
			buff.append(mc_client);
			buff.append("' and site = ");
			buff.append(siteID);
			//System.out.println(buff.toString());
			
			ResultSet result = qs.executeQuery(buff.toString());	
			if ( result.next()) {
				//System.out.println("x id= " + result.getInt("id") );
				storeID = result.getInt("id");
			}
		} catch (Exception x) {
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return storeID;
		
	}
	
	
	private void setID( int val ) {
		id = val;
	}
	
	public void setSite( int val ) {
		site = val;
	}
	
	public void setCompanyID( int val ) {
		company_id = val;
	}
	
	public void setChainCode( String val ) {
		chainCode = val;
	}
	
	public void setMcClient( String val ) {
		mc_client = val;
	}
	
	public void setSiteName( String val ) {
		site_name = val;
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
	
	public void setCountry( String val ) {
		country = val;
	}
	
	
	public int getID() {
		return id;
	}
	
	public int getSiteID() {
		return site;
	}
	
	public int getCompanyID() {
		return company_id;
	}
	
	public String getChainCode() {
		if ( chainCode == null )
			return "";
		
		return chainCode;
	}
	
	public String getMcClient() {
		if ( mc_client == null )
			return "";
		
		return mc_client;
	}
	
	public String getSiteName() {
		if ( site_name == null )
			return "";
		
		return site_name;
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
	
	public String getCountry() {
		if ( country == null )
			return "";
		
		return country;
	}
		
	
}
