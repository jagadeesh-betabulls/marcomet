/**********************************************************************
Description:	This class will be used to hold the neccesary tools to 
				create/update/delete invoices
**********************************************************************/

package com.marcomet.commonprocesses;


import com.marcomet.jdbc.*;

import java.sql.*;


public class ProcessARInvoiceDetail {
	
	//varables
	private int id;
	private int insertionId;
	private int jobId;
	private int invoiceId;
	private double purchaseAmount;
	private double shippingAmount;
	private double salesTax;
	private double deposited;
	private double invoiceAmount;
	
	public ProcessARInvoiceDetail() {
		
	}
	
	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
	}

	public final void setInsertionId(int temp){
		insertionId = temp;	
	}
	public final void setInsertionId(String temp){
		setInsertionId(Integer.parseInt(temp));
	}
	public final int getInsertionId(){
		return insertionId;
	}		

	public final void setJobId(int temp){
		jobId = temp;	
	}
	public final void setJobId(String temp){
		setJobId(Integer.parseInt(temp));
	}
	public final int getJobId(){
		return jobId;
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

	public final void setPurchaseAmount(double temp){
		purchaseAmount = temp;	
	}
	public final void setPurchaseAmount(String temp){
		setPurchaseAmount(Double.parseDouble(temp));
	}
	public final double getPurchaseAmount(){
		return purchaseAmount;
	}

	public final void setShippingAmount(double temp){
		shippingAmount = temp;	
	}
	public final void setShippingAmount(String temp){
		setShippingAmount(Double.parseDouble(temp));
	}
	public final double getShippingAmount(){
		return shippingAmount;
	}

	public final void setSalesTax(double temp){
		salesTax = temp;	
	}
	public final void setSalesTax(String temp){
		setSalesTax(Double.parseDouble(temp));
	}
	public final double getSalesTax(){
		return salesTax;
	}
	
	public final void setDeposited(double temp){
		deposited = temp;	
	}
	public final void setDeposited(String temp){
		setDeposited(Double.parseDouble(temp));
	}
	public final double getDeposited(){
		return deposited;
	}	
	
	public final void setInvoiceAmount(double temp){
		invoiceAmount = temp;	
	}
	public final void setInvoiceAmount(String temp){
		setInvoiceAmount(Double.parseDouble(temp));
	}
	public final double getInvoiceAmount(){
		return invoiceAmount;
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
		
		String insertSQL = "insert into ar_invoice_details(id,insertionid,jobid,ar_invoiceid,ar_purchase_amount,ar_shipping_amount,ar_sales_tax,deposited,ar_invoice_amount)values(?,?,?,?,?,?,?,?,?)";
		
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES ar_invoice_details WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from ar_invoice_details;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}	

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.setInt(1,getId());
			insert.setInt(2,getInsertionId());
			insert.setInt(3,getJobId());
			insert.setInt(4,getInvoiceId());
			insert.setDouble(5,getPurchaseAmount());
			insert.setDouble(6,getShippingAmount());
			insert.setDouble(7,getSalesTax());
			insert.setDouble(8,getDeposited());		
			insert.setDouble(9,getInvoiceAmount());			
			insert.execute();
			
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) {qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		return getId();
	}
	
	protected void finalize() {
		
	}
}