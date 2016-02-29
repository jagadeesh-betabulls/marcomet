package com.marcomet.jdbc;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ResourceBundle;

public class DBConnectDirect {

	
	static private DBConnectDirect instance;	
    static final int initialConnections = 5;
    static final int maxConnections = 100;
    
    static private String urlString = null;
    static private String userName = null;  
    static private String driverString = null;  
    static private String pword = null;    
	 /**
     * Returns a direct connection to the database. To be used for standalone, command-line interface to servlets
     */
    static synchronized public DBConnectDirect getInstance() {
        if (instance == null) {
            instance = new DBConnectDirect();
        }
        
        return instance;
    }

	/**
     * A private constructor since this is a Singleton
     */
	private DBConnectDirect() {
		init();
	}
    private void init() {
        
		try {	
			ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
			driverString = bundle.getString("jdbcdriver");
			urlString = bundle.getString("jdbcurl");
			userName = bundle.getString("jdbcuser");
			pword = bundle.getString("jdbcpassword");			
		} catch (Exception e) {			
			System.err.println("DBConnectDirect : Fail to establish a database connection.");
			System.err.println(e.getMessage());
			e.printStackTrace();			
		}		
    }

	public static Connection getConnection() throws ClassNotFoundException, Exception, SQLException {
		if (instance == null) {
            DBConnectDirect.getInstance(); 
        }   
		Class.forName(driverString).newInstance();
		return DriverManager.getConnection(urlString,userName,pword);			
	}		
}
