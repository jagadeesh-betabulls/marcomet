/********************************************
purpose: insert/update/etc phone

********************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.DBConnect;
import java.sql.*;

public class ProcessSiteFields{
	
	//varables, ensure any added variables here make it to the clear function.
	private int id;
	private int contactId;
	private int sitehostId;
	private String siteField1;
	private String siteField2;
	private String siteField3;

		
	public ProcessSiteFields() {
	}	
	
	public final void setId(int temp){
		id = temp;
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
	}	
		
	public final void setContactId(int temp){
		contactId = temp;
	}
	public final void setContactId(String temp){
		setContactId(Integer.parseInt(temp));
	}
	public final int getContactId(){
		return contactId;
	}



	//for legacy programs that still call this function, will be removed over time
	public final int insertSiteFields() throws Exception {
		return insert();
	}

	//if no connection is sent	
	public final int insert()
	throws SQLException{
					
		return process();	
	
	}	
	
	//share connection from calling object	
	public final int insert(Connection tempConn) throws SQLException, Exception{
		//conn = tempConn;
		int i = process();
		//conn = null;
		return i;		
	}
		
	public final int process() throws SQLException{
				
		String insertSQL = "insert into contact_site_fields(id,contact_id,sitehost_id,site_field_1,site_field_2,site_field_3) values (?,?,?,?,?,?)";


		Statement qs = null;
		Connection conn = null; 

		try {
			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES contact_site_fields WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from contact_site_fields;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}	

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.clearParameters();
			insert.setInt(1,getId());
			insert.setInt(2,getContactId());
			insert.setInt(3,getSitehostId());
			insert.setString(4,getSiteField1());
			insert.setString(5,getSiteField2());
			insert.setString(6,getSiteField3());
			insert.execute();				
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();
	}		

	public final void deleteContactSiteFields() throws SQLException{
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String sql = "delete from contact_site_fields where contact_id = ?";
			PreparedStatement delete = conn.prepareStatement(sql);
			
			delete.clearParameters();
			delete.setInt(1,getContactId());
			delete.execute();		
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
	}	
	
	public final void deleteContactSiteFields(String tempStr,int temp) throws SQLException{
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String sql = "delete from contact_site_fields where contact_id = ? and sitehost_id=?";
			PreparedStatement delete = conn.prepareStatement(sql);
			
			delete.clearParameters();
			delete.setInt(1,getContactId());
			delete.setInt(2,temp);
			delete.execute();		
		} catch (Exception x) {
			System.out.println(x.getMessage());
			throw new SQLException(x.getMessage());
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
	}	
	
	public final void deleteContactSiteFields(int temp) throws SQLException{
		setContactId(temp);
		deleteContactSiteFields();
	}
	
	public final void deleteContactSiteFields(int temp,int shTemp) throws SQLException{
		setContactId(temp);
		deleteContactSiteFields("SiteSpecific",shTemp);
	}
	
	public final void deleteContactPhone(String temp) throws SQLException{
		deleteContactSiteFields(Integer.parseInt(temp));
	}
	
	public final void deleteContactSiteFields(String temp,String shTemp) throws SQLException{
		deleteContactSiteFields(Integer.parseInt(temp),Integer.parseInt(shTemp));
	}
	
	public final void clear() {
		id = 0;
		contactId = 0;
		sitehostId = 0;
		siteField1 = "";
		siteField2 = "";
		siteField3 = "";
	}
	
	
	public final void finalize() {
				
	}

	public int getSitehostId() {
		return sitehostId;
	}

	public void setSitehostId(int sitehostId) {
		this.sitehostId = sitehostId;
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

}