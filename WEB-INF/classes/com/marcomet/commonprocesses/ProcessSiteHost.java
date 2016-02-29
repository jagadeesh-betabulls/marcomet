/**********************************************'
Description:	This class will be used to hold the neccesary tools to 
				create/update/delete site hosts.
				
Note:  			No application insertion for new sitehosts has been built;
				so this class is for updates.  Time will most likey come to 
				an automated site host creation tool, so when that comes, fix the
				insertion.
	
**********************************************************************/


package com.marcomet.commonprocesses;

import com.marcomet.jdbc.DBConnect;
import java.sql.*;


public class ProcessSiteHost {

	//varables put any new varaibles in the clear function
	private int id;
	
	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
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
		
		String insertSQL = "INSERT INTO site_hosts(id)values(?);";		

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES site_hosts WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "SELECT IF( MAX(id) IS NULL, 0, MAX(id))+1  from ap_invoices;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}
			

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.setInt(1,getId());
			
			
			insert.execute();
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();
	}		
	
	public final void updateValue(String column, String value)
	throws SQLException{

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "UPDATE site_hosts SET " + column + " = \'" + value + "\' where id = " + getId();
			qs.execute(sql);
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
			
	}
	
	public final void updateValue(int id, String column, String value) 
	throws SQLException{
		setId(id);
		updateValue(column,value);	
	}	
	
	public final void updateValue(String column, int value)
	throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "UPDATE site_hosts SET " + column + " = " + value + " where id = " + getId();
			qs.execute(sql);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}

	public final void updateValue(int id, String column, int value) 
	throws SQLException{
		setId(id);
		updateValue(column,value);	
	}

	
	public final void clear(){
		id = 0;
	}	

	protected void finallize() {
		
	}
	
		
			
}

