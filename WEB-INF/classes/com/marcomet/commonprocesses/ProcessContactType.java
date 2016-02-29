/**********************************************************************
Description:	This class will be used to hold the neccesary tools to 
				create/update/delete contact_types
**********************************************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.*;

import java.sql.*;


public class ProcessContactType{

	//varables put any new varaibles in the clear function
	private int id;
	private int contactId;
	private int lUContactTypeId;
	
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

	public final void setLUContactTypeId(int temp){
		lUContactTypeId = temp;	
	}
	public final void setLUContactTypeId(String temp){
		setLUContactTypeId(Integer.parseInt(temp));
	}
	public final int getLUContactTypeId(){
		return lUContactTypeId;
	}
	
	//if no connection is sent	
	public final int insert()
	throws SQLException{
					
		return processInsert();
					
	}	
	
	//share connection from calling object	
	public final int insert(Connection tempConn) throws SQLException, Exception{
		//conn = tempConn;
		int i = processInsert();
		//conn = null;
		return i;		
	}
		
	public final int processInsert() throws SQLException{
		
		String insertSQL = "INSERT INTO contact_types(id,contact_id,lu_contact_type_id) VALUES (?,?,?);";
		

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES contact_types WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "SELECT IF( MAX(id) IS NULL, 0, MAX(id))+1 FROM contact_types;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}
			

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.setInt(1,getId());
			insert.setInt(2,getContactId());
			insert.setInt(3,getLUContactTypeId());
			insert.execute();
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();
	}		
	
	public final void clear(){
		id = 0;
		contactId = 0;	
		lUContactTypeId = 0;
	}	

	public final void deleteContactId(int id)
	throws SQLException{
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			setId(id);	
			Statement qs = conn.createStatement();
			String sql = "DELETE FROM contact_types WHERE contact_id =" + getId();
			qs.execute(sql);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		}finally{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}	
	}
	
	public final void deleteCompanyId(int id)
	throws SQLException{
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			//get contact id's
			Statement qs1 = conn.createStatement();
			String sql1 = "SELECT id FROM contacts WHERE companyid =" + id;
			ResultSet rsContacts = qs1.executeQuery(sql1);	
		
			String sql2 = "DELETE FROM contact_types WHERE contact_id = ?";
			PreparedStatement ps1 = conn.prepareStatement(sql2);
		
			while(rsContacts.next()){
				ps1.setInt(1,rsContacts.getInt("id"));
				ps1.execute();
				ps1.clearParameters();		
			}	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}	

	protected void finallize() {
		
	}	
			
}