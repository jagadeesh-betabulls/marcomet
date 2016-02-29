/**********************************************************************
Description:	This class will be used to update single columns in tables.
Form fields:

				table              	(required)
				columnName        	(required)
				newValue		   	(required)
				primaryKeyValue 	(required)	  
				valueType 
				
note: 			Assumes primary key column for table is 'id'
**********************************************************************/

package com.marcomet.tools;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.jdbc.DBConnect;


public class QuickUpdaterServlet extends HttpServlet{
	
	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
	
		String sqlUpdate = "UPDATE " + request.getParameter("tableName") + " SET "+ request.getParameter("columnName")+" = ? WHERE id = ?";

		Connection conn = null;
		
		try{
			conn = DBConnect.getConnection();
			PreparedStatement insert = conn.prepareStatement(sqlUpdate);
			
			insert.clearParameters();
			insert.setString(1,request.getParameter("newValue"));
			insert.setString(2,request.getParameter("primaryKeyValue"));
			insert.execute();
		
			ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
			rpcs.printNextPage(this,request,response);
		
		}catch(SQLException sqle){
			System.err.println(sqle.getMessage());
			sqle.printStackTrace();
		}catch(Exception e){
			System.err.println(e.getMessage());
			e.printStackTrace();
		}finally{
			try{
				conn.close();
			}catch(Exception e){
				;
			}finally{
				conn = null;			
			}
		}
			
	
	
	
	}
}