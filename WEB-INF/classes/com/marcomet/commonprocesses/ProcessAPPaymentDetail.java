/**********************************************************************
Description:	This class will be used to hold the neccesary tools to 
				create/update/delete Account Payable Payment Details
**********************************************************************/


package com.marcomet.commonprocesses;

import com.marcomet.jdbc.*;

import java.sql.*;


public class ProcessAPPaymentDetail{

	private int id;
	private String acctgSysRef;
	private int apPaymentId;
	private int apInvoiceId;
	private double amount;
	
	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
	}
	
	public final void setAcctgSysRef(String temp){
		acctgSysRef = temp;	
	}
	public final String getAcctgSysRef(){
		return acctgSysRef;
	}
	
	public final void setApPaymentId(int temp){
		apPaymentId = temp;	
	}
	public final void setApPaymentId(String temp){
		setApPaymentId(Integer.parseInt(temp));
	}
	public final int getApPaymentId(){
		return apPaymentId;
	}		
		
	public final void setApInvoiceId(int temp){
		apInvoiceId = temp;	
	}
	public final void setApInvoiceId(String temp){
		setApInvoiceId(Integer.parseInt(temp));
	}
	public final int getApInvoiceId(){
		return apInvoiceId;
	}	
	
	public final void setAmount(double temp){
		amount = temp;	
	}
	public final void setAmount(String temp){
		setAmount(Integer.parseInt(temp));
	}
	public final double getAmount(){
		return amount;
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
		
		Connection conn = null; 
		Statement qs = null;
		String insertSQL = "INSERT INTO ap_payment_details(id,acctg_sys_ref,ap_payment_id,ap_invoice_id,amount) values (?,?,?,?,?)";

		try {	
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES ap_payment_details WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "SELECT IF( max(id) IS NULL, 0, max(id))+1  from ap_payment_details;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}

			PreparedStatement insert = conn.prepareStatement(insertSQL);
		
			insert.clearParameters();
			insert.setInt(1,getId());
			insert.setString(2, getAcctgSysRef());
			insert.setInt(3, getApPaymentId());
			insert.setInt(4, getApInvoiceId());
			insert.setDouble(5, getAmount());
			insert.execute();	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		}finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }			
		}		

		return getId();						
	}	

	protected void finalize() {
		
	}	
		
}