/**********************************************************************
Description:	This class will be used to hold the neccesary tools to 
				create/update/delete Account Payable Payments
**********************************************************************/


package com.marcomet.commonprocesses;

import com.marcomet.jdbc.*;

import java.sql.*;


public class ProcessAPPayment{

	private int id;
	private String acctgSysRef;
	private int paidContactId;
	private int paidCompanyId;
	private String paymentDate;
	private int pmtTypeId;
	private int refNo;
	
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
	
	public final void setPaidContactId(int temp){
		paidContactId = temp;	
	}
	public final void setPaidContactId(String temp){
		setPaidContactId(Integer.parseInt(temp));
	}
	public final int getPaidContactId(){
		return paidContactId;
	}		

	public final void setPaidCompanyId(int temp){
		paidCompanyId = temp;	
	}
	public final void setPaidCompanyId(String temp){
		setPaidCompanyId(Integer.parseInt(temp));
	}
	public final int getPaidCompanyId(){
		return paidCompanyId;
	}		
	
	public final void setPmtTypeId(int temp){
		pmtTypeId = temp;	
	}
	public final void setPmtTypeId(String temp){
		setPmtTypeId(Integer.parseInt(temp));
	}
	public final int getPmtTypeId(){
		return pmtTypeId;
	}	
	
	public final void setRefNo(int temp){
		refNo = temp;	
	}
	public final void setRefNo(String temp){
		setRefNo(Integer.parseInt(temp));
	}
	public final int getRefNo(){
		return refNo;
	}				

	public final void setPaymentDate(String temp){
		paymentDate = temp;
	}
	public final String getPaymentDate(){
		return paymentDate;
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
		String insertSQL = "INSERT INTO ap_payments(id, acctg_sys_ref, paid_contact_id, paid_company_id, payment_type_id, ref_no, payment_date) VALUES (?,?,?,?,?,?,?)";

		try {	
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES ap_payments WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "SELECT IF( max(id) IS NULL, 0, max(id))+1 FROM ap_payments;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}

			PreparedStatement insert = conn.prepareStatement(insertSQL);
		
			insert.clearParameters();
			insert.setInt(1,getId());
			insert.setString(2, getAcctgSysRef());
			insert.setInt(3, getPaidContactId());
			insert.setInt(4, getPaidCompanyId());
			insert.setInt(5, getPmtTypeId());
			insert.setInt(6, getRefNo());
			insert.setString(7, getPaymentDate());
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