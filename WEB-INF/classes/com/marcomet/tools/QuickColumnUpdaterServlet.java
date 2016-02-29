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
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.jdbc.DBConnect;


public class QuickColumnUpdaterServlet extends HttpServlet{
	
	public void doPost(HttpServletRequest request, HttpServletResponse response)
	throws ServletException{
	
		StringBuffer sqlUpdate = new StringBuffer();
		sqlUpdate.append("UPDATE ");
		sqlUpdate.append(request.getParameter("tableName"));
		sqlUpdate.append(" SET ");
		sqlUpdate.append(request.getParameter("columnName"));
		
		if(request.getParameter("valueType").equalsIgnoreCase("string")){
			sqlUpdate.append(" = '");
		}else{
			sqlUpdate.append(" = ");
		}	
		
		sqlUpdate.append(request.getParameter("newValue"));
		
		if(request.getParameter("valueType").equalsIgnoreCase("string")){
			sqlUpdate.append("' WHERE id = ");
		}else{
			sqlUpdate.append(" WHERE id = ");
		}
		
		sqlUpdate.append(request.getParameter("primaryKeyValue"));
				
		Connection conn = null;
		
		try{		
			
			conn = DBConnect.getConnection();
			Statement qsUpdate = conn.createStatement();
			
			qsUpdate.executeUpdate(sqlUpdate.toString());		
		
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