/**********************************************************************
Description:	This class will be used to hold the neccesary tools to 
				create/update/delete collections.
				
**********************************************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;
import java.sql.*;


public class ProcessARCollection {

	//varables 
	private int id;
	private int contactId;
	private String checkDate;
	private String checkNumber;
	private double checkAmount;
	private String depositDate;
	private String checkReference;
	private String checkAuthCode;
	private String paymentType;

	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
	}
	
	public final void setContactId(int temp){
		contactId = temp;	
	}
	public final void setContactId(String temp){
		setContactId(Integer.parseInt(temp));
	}
	public final int getContactId(){
		return contactId;
	}
	
	public final void setCheckDate(String temp){
		checkDate = temp;	
	}
	public final String getCheckDate(){
		return checkDate;
	}

	public final void setCheckNumber(String temp){
		checkNumber = temp;	
	}
	public final String getCheckNumber(){
		return checkNumber;
	}
		
	public final void setCheckAmount(double temp){
		checkAmount = temp;	
	}
	public final void setCheckAmount(String temp){
		setCheckAmount(Double.parseDouble(temp));
	}
	public final double getCheckAmount(){
		return checkAmount;
	}	

	public final void setDepositDate(String temp){
		depositDate = temp;	
	}
	public final String getDepositDate(){
		return depositDate;
	}
	
	public final void setCheckReference(String temp){
		checkReference = temp;	
	}
	public final String getCheckReference(){
		return checkReference;
	}

	public final void setCheckAuthCode(String temp){
		checkAuthCode = temp;	
	}
	public final String getCheckAuthCode(){
		return checkAuthCode;
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
	
		String insertSQL = "insert into ar_collections(id,contactid,check_date,check_number,check_amount,deposit_date,check_reference,check_auth_code,pmt_type)values(?,?,?,?,?,?,?,?,?)";

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES ar_collections WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from ar_collections;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}	

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.setInt(1,getId());
			insert.setInt(2,getContactId());
			insert.setString(3,getCheckDate());
			insert.setString(4,getCheckNumber());
			insert.setDouble(5,getCheckAmount());
			insert.setString(6,getDepositDate());
			insert.setString(7,getCheckReference());
			insert.setString(8,getCheckAuthCode());
			insert.setString(9, getPaymentType());
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
	public String getPaymentType() {
		
		return ((paymentType==null || paymentType.equals(""))?"0":paymentType);
	}
	public void setPaymentType(String paymentType) {
		this.paymentType = paymentType;
	}
}