/**********************************************************************
Description:	This class will be used to hold the neccesary tools to 
				create/update/delete collectiondetails.
				**********************************************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.*;

import java.sql.*;


public class ProcessARCollectionDetail {

	//variables
	private int id;
	private int collectionId;
	private int invoiceId;
	private double paymentAmount;
	
	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
	}

	public final void setCollectionId(int temp){
		collectionId = temp;	
	}
	public final void setCollectionId(String temp){
		setCollectionId(Integer.parseInt(temp));
	}
	public final int getCollectionId(){
		return collectionId;
	}

	public final void setInvoiceId(int temp){
		invoiceId = temp;	
	}
	public final void setInvoiceId(String temp){
		setInvoiceId(Integer.parseInt(temp));
	}
	public final int getInvoiceId(){
		return invoiceId;
	}

	public final void setPaymentAmount(double temp){
		paymentAmount = temp;	
	}
	public final void setPaymentAmount(String temp){
		setPaymentAmount(Double.parseDouble(temp));
	}
	public final double getPaymentAmount(){
		return paymentAmount;
	}

	//if no connection is sent	
	public final int insert()
	throws SQLException{	
			
		return processInsert();	
	}	
	
	//share connection from calling object	
	public final int insert(Connection tempConn) throws SQLException, Exception{
		//conn = tempConn;
		int i = processInsert();
		//conn = null;
		return i;		
	}
		
	public final int processInsert() throws SQLException{
		
		
		String insertSQL = "insert into ar_collection_details(id,ar_collectionid,ar_invoiceid,payment_amount)values(?,?,?,?)";
		
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES ar_collection_details WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from ar_collection_details;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}	

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.setInt(1,getId());
			insert.setInt(2,getCollectionId());
			insert.setInt(3,getInvoiceId());
			insert.setDouble(4,getPaymentAmount());
			insert.execute();
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();
	}	
	
	protected void finalize() {
		
	}
}