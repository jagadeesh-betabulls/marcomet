package com.marcomet.commonprocesses;

/**********************************************************************
Description:	This class will be used to hold the neccesary tools to 
				create/update/delete Account Payable invoice details

**********************************************************************/

import com.marcomet.jdbc.*;

import java.sql.*;


public class ProcessAPInvoiceDetail{
	
	//varables but new varialbes in the clear function
	private int id;
	private int recNo;
	private int apInvoiceId;
	private int jobId;
	private int insertionId;
	private double gross;
	private double net;
	private double amount;
	private int apRecipientTypeId;
	
	public final void clear(){
		id = 0;
		recNo = 0;
		apInvoiceId = 0;
		jobId = 0;
		insertionId = 0;
		gross = 0;
		net = 0;
		amount = 0;			
	}
	protected void finallize() {
		
	}
	public final double getAmount(){
		return amount;
	}
	public final int getApInvoiceId(){
		return apInvoiceId;
	}
	public final int getApRecipientTypeId(){
		return apRecipientTypeId;
	}
	public final double getGross(){
		return gross;
	}
	public final int getId(){
		return id;
	}
	public final int getInsertionId(){
		return insertionId;
	}
	public final int getJobId(){
		return jobId;
	}
	public final double getNet(){
		return net;
	}
	public final int getRecNo(){
		return recNo;
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
		
		Connection conn = null;
		Statement qs = null;
		String insertSQL = "insert into ap_invoice_details(id, recno, ap_invoiceid, jobid, insertionid, gross, net, amount, lu_ap_recipient_type_id) values (?, ?, ?, ?, ?, ?, ?, ?, ?)";

		try {		
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES ap_invoice_details WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from ap_invoice_details;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}
			
			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.setInt(1,getId());
			insert.setInt(2,getRecNo());
			insert.setInt(3,getApInvoiceId());
			insert.setInt(4,getJobId());
			insert.setInt(5,getInsertionId());
			insert.setDouble(6,getGross());
			insert.setDouble(7,getNet());			
			insert.setDouble(8,getAmount());
			insert.setInt(9, apRecipientTypeId);
			insert.execute();
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES");} catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}		

		return getId();
	}
	
	public final void setAmount(double temp){
		amount = temp;
	}
	public final void setAmount(String temp){
		setAmount(Double.parseDouble(temp));
	}
	public final void setApInvoiceId(int temp){
		apInvoiceId = temp;	
	}
	public final void setApInvoiceId(String temp){
		setApInvoiceId(Integer.parseInt(temp));
	}
	public final void setApRecipientTypeId(int temp){
		apRecipientTypeId = temp;
	}
	public final void setGross(double temp){
		gross = temp;
	}
	public final void setGross(String temp){
		setGross(Double.parseDouble(temp));
	}
	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final void setInsertionId(int temp){
		insertionId = temp;	
	}
	public final void setInsertionId(String temp){
		setInsertionId(Integer.parseInt(temp));
	}
	public final void setJobId(int temp){
		jobId = temp;	
	}
	public final void setJobId(String temp){
		setJobId(Integer.parseInt(temp));
	}
	public final void setNet(double temp){
		net = temp;
	}
	public final void setNet(String temp){
		setNet(Double.parseDouble(temp));
	}
	public final void setRecNo(int temp){
		recNo = temp;	
	}
	public final void setRecNo(String temp){
		setRecNo(Integer.parseInt(temp));
	}
}
