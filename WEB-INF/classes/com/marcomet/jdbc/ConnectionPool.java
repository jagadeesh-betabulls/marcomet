/**********************************************************************
Description:	This class brokers all of the connections from the 
				ObjectPool

History:
	Date		Author			Description
	----		------			-----------
	6/8/2001	Brian Murphy	Created
	10/11/01	td				made functions final

**********************************************************************/

package com.marcomet.jdbc;

import java.sql.*;
import java.util.*;

public class ConnectionPool extends ObjectPool {

	ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
	String jdbcdriver = bundle.getString("jdbcdriver");
	String jdbcuser = bundle.getString("jdbcuser"); 
	String jdbcpassword = bundle.getString("jdbcpassword");
	String jdbcurl  = bundle.getString("jdbcurl");

	public ConnectionPool() {
		try {
			Class.forName(jdbcdriver).newInstance();
			int i = super.initializeConnections();
		} catch(Exception ex) {
			ex.printStackTrace(); 
		}
	}
	public final Connection borrowConnection() throws SQLException {
		return((Connection) super.checkOut());
	}
	Object create() throws SQLException {
		try {
			return(DriverManager.getConnection(jdbcurl, jdbcuser, jdbcpassword));
		} catch(SQLException ex) {
			ex.printStackTrace();
			return(null);
		}
	}
	int expire(Object o) {
		try {
			((Connection)o).close();
		} catch(SQLException ex) {
			ex.printStackTrace();
		}
		
		return 1;
	}
	// Make this void is we move away from Solaris	
	public final int returnConnection(Connection c) {
		int i = super.checkIn(c);
		return i;
	}
	boolean validate(Object o)  { 
		try {
			return( !((Connection)o).isClosed() );
		} catch(SQLException ex) {
			ex.printStackTrace();
			return(false);
		}
	}
}
