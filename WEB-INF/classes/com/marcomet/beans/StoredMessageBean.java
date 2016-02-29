package com.marcomet.beans;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Vector;

import com.marcomet.jdbc.DBConnect;

public class StoredMessageBean {

	static public String getMessage( String key ) {
		
		String msg = null;
		
		Connection conn = null; 
		Statement qs = null;
		StringBuffer buff = new StringBuffer();
		Vector vec = new Vector();
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			
			buff.append("SELECT message FROM display_messages WHERE message_key = '");
			buff.append(key);
			buff.append("'");
			
			ResultSet result = qs.executeQuery(buff.toString());	
			if ( result.next()) {
				msg = result.getString("message");				
			} else {
				System.err.println("Missing message in display_messages table. Key = " + key);
			}
		} catch (Exception x) {
			
			System.err.println(x.getMessage());
			x.printStackTrace();
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return msg;
		
	}
	
}
