package com.marcomet.jdbc;

import java.sql.*;
import java.util.ResourceBundle;

import javax.sql.*;
import javax.naming.*;

public class DBConnect {

	
	static private boolean useAppServerResource = false;
	static private DBConnect instance;	
    static final int initialConnections = 5;
    static final int maxConnections = 100;
    
    static private String connectType = "?";
    static private String jdbcname = null;
    static private Context ctx = null;
    static private Context envCtx = null;
    static private DataSource ds = null;


	 /**
     * Returns the single instance, creating one if it's the
     * first time this method is called.
     *
     * @return DBConnectionManager The single instance.
     */
    static synchronized public DBConnect getInstance() {
        if (instance == null) {
            instance = new DBConnect();
        }
        
        return instance;
    }

	/**
     * A private constructor since this is a Singleton
     */
	private DBConnect() {
		init();
	}
	
	/**
     * Loads properties and initializes the instance with its values.
     */
    private void init() {
        
		try {	
			ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
			jdbcname = bundle.getString("DbDataSourceName");
			System.err.println("jdbcname = " + jdbcname);
			ctx = new InitialContext();
			envCtx = (Context)ctx.lookup("java:comp/env");
			ds = (DataSource)envCtx.lookup(jdbcname);			
			
		} catch (Exception e) {			
			System.err.println("DBConnect : Fail to establish a database connection.");
			System.err.println(e.getMessage());
			e.printStackTrace();			
		}		
    }
    
    	
	public static Connection getConnection() throws ClassNotFoundException, Exception, SQLException {
				
		if (instance == null) {
            DBConnect.getInstance();
        }        
		
		return ds.getConnection();		
		
	}	
	
	
}
