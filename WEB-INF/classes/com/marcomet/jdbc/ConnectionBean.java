/**********************************************************************
Description:	This provides a means for jsp's to query the db

History:
	Date		Author			Description
	----		------			-----------
	??/??/????	Thomas Dietrich	Created
	10/11/01	td				made functions final

**********************************************************************/

package com.marcomet.jdbc;

import java.util.*;
import java.sql.*;
import javax.servlet.http.*;

public class ConnectionBean /* implements HttpSessionBindingListener*/{
	
	public ConnectionBean(){
	}
	public final ResultSet executeQuery(String sql) throws SQLException{
		
		Connection conn = null;
		Statement statement = null;		
		
		try{		
			
			conn = DBConnect.getConnection();
			statement = conn.createStatement();
			
			return statement.executeQuery(sql);
			
		}catch(SQLException sqle) {
			//System.err.println("ConnectionBean, time: " + new java.util.Date() + " query failed sqle: " + sqle.getMessage());
			throw new SQLException("Connection Bean, you threw a SQLException\n The Query you used:\n\t " + sql +  "\n\nThe message received:\n\t" + sqle.getMessage());
		}catch(NullPointerException npe){
			System.err.println("ConnectionBean, time: " + new java.util.Date() + " npe: " + npe.getMessage());			
		}catch(Exception e){
			System.err.println("ConnectionBean, time: " + new java.util.Date() + " e: " + e.getMessage());
		}finally{
			try { statement.close(); } catch ( Exception x) { statement = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	
		return null;	
	}
}
