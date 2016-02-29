/********************************************
purpose: insert/update/etc phone

********************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.DBConnect;
import java.sql.*;

public class ProcessPhone{
	
	//varables, ensure any added varables here make it to the clear function.
	private int id;
	private int contactId;
	private int phoneTypeId;
	private String areaCode;
	private String phone1;
	private String phone2;
	private String extension;
		
	public ProcessPhone() {
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

	public final void setPhoneTypeId(int temp){
		phoneTypeId = temp;
	}
	public final void setPhoneTypeId(String temp){
		setPhoneTypeId(Integer.parseInt(temp));
	}
	public final int getPhoneTypeId(){
		return phoneTypeId;
	}

	public final void setAreaCode(String temp){
		areaCode = temp;
	}
	public final String getAreaCode(){
		return areaCode;
	}

	public final void setPhone1(String temp){
		phone1 = temp;
	}
	public final String getPhone1(){
		return phone1;
	}

	public final void setPhone2(String temp){
		phone2 = temp;
	}
	public final String getPhone2(){
		return phone2;
	}	
	
	public final void setExtension(String temp){
		extension = temp;
	}
	public final String getExtension(){
		return extension;
	}	

	//for legacy programs that still call this function, will be removed over time
	public final int insertPhone() throws Exception {
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
				
		String insertSQL = "insert into phones(id,contactid,phonetype,areacode,phone1,phone2,extension) values (?,?,?,?,?,?,?)";


		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES phones WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from phones;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}	

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.clearParameters();
			insert.setInt(1,getId());
			insert.setInt(2,getContactId());
			insert.setInt(3,getPhoneTypeId());
			insert.setString(4,getAreaCode());
			insert.setString(5,getPhone1());
			insert.setString(6,getPhone2());
			insert.setString(7,getExtension());
			insert.execute();				
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();
	}		
	
	public final int update() throws SQLException{
		
		String insertSQL = "UPDATE phones SET id=?,contactid=?,phonetype=?,areacode=?,phone1=?,phone2=?,extension=? where contactid="+getContactId();


		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES phones WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from phones;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}	

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.clearParameters();
			insert.setInt(1,getId());
			insert.setInt(2,getContactId());
			insert.setInt(3,getPhoneTypeId());
			insert.setString(4,getAreaCode());
			insert.setString(5,getPhone1());
			insert.setString(6,getPhone2());
			insert.setString(7,getExtension());
			insert.execute();				
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();
	}

	public final void deleteContactPhone() throws SQLException{
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String sql = "delete from phones where contactid = ?";
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
	public final void deleteContactPhone(int temp) throws SQLException{
		setContactId(temp);
		deleteContactPhone();
	}	
	public final void deleteContactPhone(String temp) throws SQLException{
		deleteContactPhone(Integer.parseInt(temp));
	}
	
	public final void clear() {
		id = 0;
		contactId = 0;
		phoneTypeId = 0;
		areaCode = "";
		phone1 = "";
		phone2 = "";
		extension = "";	
	}
	
	
	public final void finalize() {
				
	}

	

}