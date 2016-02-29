/**********************************************************************
Description:	This class brokers all of the connections from the 
				ObjectPool

History:
	Date		Author			Description
	----		------			-----------
	6/8/2001	Thomas Dietrich	Created
	6/8/2001	Brian Murphy	Adjusted to account for connection pooling
	10/11/01	td				made functions final

**********************************************************************/

package com.marcomet.jdbc;

import java.sql.*;
import java.util.*;

public class SimpleConnection {

	private Connection conn;
	StaticSimpleConnection ssc;
	
	public SimpleConnection() {
		ssc = new StaticSimpleConnection();
	}
	public final void close() {
		try {
			int i = ssc.close();
		} catch (Exception ex) {
		}
	}
	protected void finalize() {
		ssc.close();
	}
	public final Connection getConnection() {
		try {
			conn = ssc.getConnection();
		} catch(Exception e) {
			System.err.println("SimpleConnection: driver not loaded");
			conn = null;
		}
		
		return conn;
	}
}
