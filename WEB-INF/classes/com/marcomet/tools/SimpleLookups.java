package com.marcomet.tools;

/****************************************
Purpose:  Provide easy way to lookup items
thomas dietrich
****************************************/

import com.marcomet.jdbc.*;
import java.sql.*;


public class SimpleLookups{
	
	Connection conn;

	protected void finalize(){
		try{
			conn.close();
		}catch(Exception e){
		}finally{
			conn = null;
		}	
	}
	
	//**** New Section 19apr2001 for multible tables **************
	public String getValue(String table,String lucolumn,String target, String retcolumn) throws SQLException {
		String temp = "";
		
		try{
			if (conn == null) {				
				conn = DBConnect.getConnection();
			}
		
			String selectValueText = "select " + retcolumn + " from "+table+" where "+lucolumn+" = " + target;
			Statement selectValue = conn.createStatement();
			ResultSet rsValues = selectValue.executeQuery(selectValueText);

			
			if(rsValues.next()){
				temp = rsValues.getString(1);
			}else{
				temp = "";
			}		
			
		}catch(Exception e){
			System.err.println("SLUPS failed, parameters: table: " +  table + ", column: " + lucolumn + ", target: " + target + ", return: " +  retcolumn); 
		}finally{
			try{
				conn.close();
			}catch(Exception ex){
				;
			}finally{
				conn = null;
			}	
		}	
	
		return temp;	
	}

	public ResultSet simpleQuery(String sql) throws SQLException {
	
		ResultSet temp = null;
		
		try{
			if (conn == null) {				
				conn = DBConnect.getConnection();
			}
					
			if (conn.createStatement().execute(sql)){
				temp = conn.createStatement().executeQuery(sql);
			}
			
		}catch(Exception e){
			System.err.println("SLUPS failed, parameters: sql: " +  sql); 
		}finally{
			try{
				conn.close();
			}catch(Exception ex){
				;
			}finally{
				conn = null;
			}	
		}	
	
		return temp;	
	}
	
}
