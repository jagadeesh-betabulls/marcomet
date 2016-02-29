/**********************************************************************
Description:	This class will insert/update/etc credti transactions for stored account info
								
**********************************************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.*;

import java.util.Hashtable;
import java.util.Vector;
import java.sql.*;
import java.text.*;

public class ProcessCreditTransaction{

	DateFormat mysqlFormat = new SimpleDateFormat("yyyy-MM-dd");
	

	//please ensure these lower variables make it into the clear function
	private int id;
	private String contactId;
	private String acctType;
	private String maskedNum;
	private String lastref;
	private String pastref;
	private String bankName;
	private String bankCity;
	private String bankState;
	private String txType;
	private String expDate;
	

	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
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
		Statement qs = null;
		Connection conn = null; 
		try {
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//if a pastref is passed in lookup the previous transaction's values and use them to populate the current one.
			if(getPastref()!=null && !getPastref().equals("") && !getPastref().equals("NEW")){
			      String query = "SELECT * FROM cred_tx WHERE lastref='"+getPastref()+"'";
			      ResultSet rs = qs.executeQuery(query);
			      if (rs.next()) {
			  			setContactId(rs.getString("contact_id"));
						setAcctType(rs.getString("acct_type"));
						setMaskedNum(rs.getString("masked_num"));
						setBankName(rs.getString("bank_name"));
						setBankCity(rs.getString("bank_city"));
						setBankState(rs.getString("bank_state"));
						setTxType(rs.getString("tx_type"));
						setExpDate(rs.getString("exp_date"));
			      }
			}
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		
		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES cred_tx WRITE");	
			String insertSQL = "INSERT INTO cred_tx(contact_id,acct_type,masked_num,lastref,bank_name,bank_city,bank_state,tx_type,exp_date) VALUES (?,?,?,?,?,?,?,?,?)";
			PreparedStatement insert = conn.prepareStatement(insertSQL);
		
			insert.clearParameters();
			insert.setString(1,getContactId());
			insert.setString(2,getAcctType());
			insert.setString(3,getMaskedNum());
			insert.setString(4,getLastref());
			insert.setString(5,getBankName());
			insert.setString(6,getBankCity());
			insert.setString(7,getBankState());
			insert.setString(8,getTxType());
			insert.setString(9,getExpDate());
			System.out.println("Before execute.");
			insert.execute();
		} catch (Exception x) {
			System.out.println(x.getMessage());
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();
	}	
	
	//for old code will be replaced with the simple update()
	public final void updateCompany() throws Exception{
		update();
	}		
	
	//if no connection is sent	
	public final void update()
	throws SQLException{
		
	}	
	
	//share connection from calling object	
	public final void update(Connection tempConn) throws SQLException, Exception{
		//conn = tempConn;
		processUpdate();
		//conn = null;
	}	

	public final void processSelect() throws SQLException{

		Connection conn = null; 
		Hashtable hRes=new Hashtable();
		try {			
			conn = DBConnect.getConnection();
	
			String sql = "Select * from cred_tx where contact_id=?";
			PreparedStatement selTrans = conn.prepareStatement(sql);
	
			selTrans.clearParameters();		
			selTrans.setString(1,getContactId());
			ResultSet rsTrans=selTrans.executeQuery();
			while(rsTrans.next()){
				hRes.put("","");
			}
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void processUpdate() throws SQLException{

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
	
			String sql = "UPDATE cred_tx SET lastref=? where leftref=?";
			PreparedStatement update = conn.prepareStatement(sql);
	
			update.clearParameters();		
			update.setString(1,getLastref());
			update.setString(2,getPastref());
			update.execute();
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	

	public final void updateCredTx(String column, String value)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "UPDATE cred_tx SET " + column + " = \'" + value + "\' WHERE id = " + getId();
			qs.execute(sql);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void updateCredTx(int id, String column, String value) throws SQLException{
		setId(id);
		updateCredTx(column,value);	
	}	
	
	public final void updateCredTx(String column, int value)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "UPDATE cred_tx SET " + column + " = " + value + " WHERE id = " + getId();
			qs.execute(sql);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	public final void updateCredTx(int id, String column, int value) throws SQLException{
		setId(id);
		updateCredTx(column,value);	
	}

	public final void delete(int credId)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			setId(credId);	
			String sql = "DELETE FROM cred_tx WHERE id = " + getId();
			qs.execute(sql);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}	

	protected void finalize() {
		
	}
	public String getContactId() {
		return contactId;
	}
	public void setContactId(String contactId) {
		this.contactId = contactId;
	}
	public String getMaskedNum() {
		return maskedNum;
	}
	public void setMaskedNum(String maskedNum) {
		this.maskedNum = maskedNum;
	}
	public String getLastref() {
		return lastref;
	}
	public void setLastref(String lastref) {
		this.lastref = lastref;
	}
	public String getBankName() {
		return bankName;
	}
	public void setBankName(String bankName) {
		this.bankName = bankName;
	}
	public String getBankCity() {
		return bankCity;
	}
	public void setBankCity(String bankCity) {
		this.bankCity = bankCity;
	}
	public String getBankState() {
		return bankState;
	}
	public void setBankState(String bankState) {
		this.bankState = bankState;
	}
	public String getTxType() {
		return txType;
	}
	public void setTxType(String txType) {
		this.txType = txType;
	}
	public String getExpDate() {
		return expDate;
	}
	public void setExpDate(String expDate) {
		this.expDate = expDate;
	}
	public String getAcctType() {
		return acctType;
	}
	public void setAcctType(String acctType) {
		this.acctType = acctType;
	}
	public String getPastref() {
		return pastref;
	}
	public void setPastref(String pastref) {
		this.pastref = pastref;
	}	
}