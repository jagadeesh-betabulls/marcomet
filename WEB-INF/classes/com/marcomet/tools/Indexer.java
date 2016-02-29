/**********************************************************************
Description:	This Class will return a fresh unused number for table entries.
**********************************************************************/

package com.marcomet.tools;

import com.marcomet.jdbc.*;
import java.sql.*;

public class Indexer{
	
	public Indexer(){
	}

	public static synchronized int getNextId(String tableName, Connection conn) 
	throws SQLException{
			//inits
			int returnValue = 0;
			Statement qs1 = conn.createStatement();
			String lockTable = "LOCK TABLES index_keeper WRITE";			
			PreparedStatement getLastUniqueNumber = conn.prepareStatement("SELECT last_unique_number FROM index_keeper WHERE table_name = ?");
			PreparedStatement updateUsedNumber = conn.prepareStatement("UPDATE index_keeper SET last_unique_number = ? WHERE table_name = ?");
			String unlockTable = "UNLOCK TABLES";
	
			try{
				//lock and get last used number
				qs1.execute(lockTable);
			
				getLastUniqueNumber.setString(1,tableName);
				ResultSet rs1 = getLastUniqueNumber.executeQuery();
			
				//increment the number for this call
				if(rs1.next()){
					returnValue = rs1.getInt(1);
					returnValue += 1;
			
					//update table
					updateUsedNumber.setInt(1,returnValue);
					updateUsedNumber.setString(2,tableName);
					updateUsedNumber.executeUpdate();
				}else{
					throw new SQLException("indexer failed");
				}	
			
			}finally{
				//unlock tables
				qs1.execute(unlockTable);
			}	
				
			return returnValue;
	}	

	public static int getNextId(String tableName) throws SQLException{		
	
		Connection conn = null;
			
		try{				
			
			conn = DBConnect.getConnection();
			
			return getNextId(tableName,conn);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());			
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
