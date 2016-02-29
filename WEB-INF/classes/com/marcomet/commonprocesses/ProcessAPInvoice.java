package com.marcomet.commonprocesses;

/**********************************************************************
Description:	This class will be used to hold the neccesary tools to 
				create/update/delete Account Payable invoices
**********************************************************************/

import com.marcomet.jdbc.*;

import java.sql.*;


public class ProcessAPInvoice {
	
	//varables put any new varaibles in the clear function
	private int id;
	private int recNo;
	private int vendorId;
	private String invoiceDate;
	private double invoiceAmount;
	private int payToContactId;
	private int payToCompanyId;
	
	public final void clear(){
		id = 0;
		recNo = 0;
		vendorId = 0;
		invoiceDate = "";
		invoiceAmount = 0;	
	}
	protected void finallize() {
		
	}
	public final int getId(){
		return id;
	}
	public final double getInvoiceAmount(){
		return invoiceAmount;
	}
	public final String getInvoiceDate(){
		return invoiceDate;
	}
	public final int getPayToCompanyId(){
		return payToCompanyId;
	}
	public final int getPayToContactId(){
		return payToContactId;
	}
	public final int getRecNo(){
		return recNo;
	}
	public final int getVendorId(){
		return vendorId;
	}
	//if no connection is sent	
	public final int insert() throws SQLException{
							
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
	
		
		String insertSQL = "insert into ap_invoices(id, rec_no, vendorid, ap_invoice_date, ap_invoice_amount, pay_to_contact_id, pay_to_company_id) values (?, ?, ?, ?, ?, ?, ?);";

		Connection conn = null; 
		Statement qs = null;
		try {			
			conn = DBConnect.getConnection();
			
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES ap_invoices WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from ap_invoices;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}
			
			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.setInt(1,getId());
			insert.setInt(2,getRecNo());
			insert.setInt(3,getVendorId());
			insert.setString(4,getInvoiceDate());
			insert.setDouble(5,getInvoiceAmount());
			insert.setInt(6,getPayToContactId());
			insert.setInt(7,getPayToCompanyId());
			insert.execute();
		} catch (Exception x) {
			throw new SQLException(x.getMessage());	
		}finally {
			try { qs.execute("UNLOCK TABLES");} catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}		

		return getId();
	}
	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final void setInvoiceAmount(double temp){
		invoiceAmount = temp;	
	}
	public final void setInvoiceAmount(String temp){
		setInvoiceAmount(Double.parseDouble(temp));
	}
	public final void setInvoiceDate(String temp){
		invoiceDate = temp;
	}
	public final void setPayToCompanyId(int temp){
		payToCompanyId = temp;	
	}
	public final void setPayToCompanyId(String temp){
		setPayToCompanyId(Integer.parseInt(temp));
	}
	public final void setPayToContactId(int temp){
		payToContactId = temp;	
	}
	public final void setPayToContactId(String temp){
		setPayToContactId(Integer.parseInt(temp));
	}
	public final void setRecNo(int temp){
		recNo = temp;	
	}
	public final void setRecNo(String temp){
		setRecNo(Integer.parseInt(temp));
	}
	public final void setVendorId(int temp){
		vendorId = temp;	
	}
	public final void setVendorId(String temp){
		setVendorId(Integer.parseInt(temp));
	}
}
