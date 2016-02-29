/**********************************************************************
Description:	This class is maintained to make sure that all connecitons
				utilize the same static objects. It was created to avoid 
				recompiles during testing and should be romoved later.

History:
	Date		Author			Description
	----		------			-----------
	6/8/2001	Brian Murphy	Created
	10/11/01	td				made function final

**********************************************************************/

package com.marcomet.jdbc;

import java.sql.*;
import java.util.*;

public class StaticSimpleConnection {

	private Connection conn;
	private static ConnectionPool cp;

	// Make this void is we move away from Solaris
	public final int close() {
		try {
			int i = cp.returnConnection(conn);
		} catch (Exception ex) {
		}
		return 1;
	}
	public final Connection getConnection() {
	
		if (cp == null) {
			cp = new ConnectionPool();
		}
		
		try {
			// Destroy this as soon as we are free of the 30 connection limitation
			while ((cp.getAvailablePoolSize() < 1) && (cp.getPoolSize() > 12)) {
				try {
					com.marcomet.tools.MessageLogger.logMessage("Sleeping; the pool size is " + cp.getPoolSize() );
					Thread.sleep(500);
				} catch (Exception ex) {
				}
			}
			conn = cp.borrowConnection();
		} catch(SQLException e) {
			System.err.println("SimpleConnection: driver not loaded");
			conn = null;
		}
		
		return conn;
	}
}
