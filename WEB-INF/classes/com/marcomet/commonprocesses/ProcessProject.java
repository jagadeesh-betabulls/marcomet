/**********************************************
purpose:  insert/update/etc projects

***********************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.*;
import java.sql.*;

public class ProcessProject{

	//varables 
	int id;
	String projectName;
	int orderId;
	
	public ProcessProject(){}
	
	public final void setId(int temp){
		id = temp;
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
	}
	
	public final void setProjectName(String temp){
		projectName = temp;
	}
	public final String getProjectName(){
		return projectName;
	}

	public final void setOrderId(int temp){
		orderId = temp;
	}
	public final void setOrderId(String temp){
		setOrderId(Integer.parseInt(temp));
	}
	public final int getOrderId(){
		return orderId;
	}

	//for legacy code will be phased out over time
	public final int insertProject() throws Exception{
		return insert();
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
		StringTool st = new StringTool();
		
		String insertSQL = "insert into projects(id,project_name,order_id) values (?,?,?)";

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES projects WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from projects;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}

			PreparedStatement insert = conn.prepareStatement(insertSQL);
		
			insert.clearParameters();
			insert.setInt(1,getId());
			insert.setString(2,getProjectName());
			insert.setInt(3,getOrderId());
			insert.execute();	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();						
	}	

	protected void finalize() {
		
	}	
		
}
