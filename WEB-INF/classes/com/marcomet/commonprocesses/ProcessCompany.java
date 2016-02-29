/**********************************************************************
Description:	This class will insert/update/etc companies
								
**********************************************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.*;


import java.sql.*;
import java.text.*;

public class ProcessCompany{

	DateFormat mysqlFormat = new SimpleDateFormat("yyyy-MM-dd");

	//please ensure these lower variables make it into the clear function
	private int id;
	private String companyName;
	private String companyURL;
	private String creditStatus;
	private String taxid = null;
	private String dba = null;
	private String attention = null;
	private String phone = null;
	private String fax = null;
	private int billing_entity_id = -1;
	private double creditLimit;


	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
	}	

	public final void setCompanyName(String temp){
		companyName = temp;	
	}
	public final String getCompanyName(){
		return companyName;
	}

	public final void setCompanyURL(String temp){
		companyURL = temp;	
	}
	public final String getCompanyURL(){
		return companyURL;
	}
	
	public final void setTaxID(String temp){
		taxid = temp;	
	}
	public final String getTaxID(){
		return taxid;		
	}
	
	public final void setDBA(String temp){
		dba = temp;	
	}
	public final String getDBA(){
		return dba;		
	}
	
	public final void setAttention(String temp){
		attention = temp;	
	}
	public final String getAttention(){
		return attention;		
	}
	
	public final void setPhone(String temp){
		phone = temp;	
	}
	public final String getPhone(){
		return phone;		
	}
	
	public final void setFax(String temp){
		fax = temp;	
	}
	public final String getFax(){
		return fax;		
	}
	
	public final void setBillingEntityID(int temp){
		billing_entity_id = temp;	
	}
	public final void setBillingEntityID(String temp){
		try {
			billing_entity_id = Integer.parseInt(temp);
		} catch (Exception e){
			System.err.println("error parsing billing_entity_id : " + temp);
		}
	}
	public final int getBillingEntityID(){
		return billing_entity_id;		
	}
	


	//for legacy code, will be replaced by insert() over time
	public final int insertCompany() throws SQLException {
		return insert();
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
		
		String insertSQL = "INSERT INTO companies(id,company_name,company_url,date_created,date_last_modified,taxid,dba,attention,phone,fax,billing_entity_id,credit_limit,credit_status) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES companies WRITE");	
					
			//set id if it is 0/null
			System.out.println(getId());
			if(getId() <= 0){
				String getNextIdSQL = "SELECT IF( MAX(id) IS NULL, 0, MAX(id))+1 FROM companies;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}	

			PreparedStatement insert = conn.prepareStatement(insertSQL);
		
			insert.clearParameters();
			System.out.println("getId() si "+getId());
			insert.setInt(1,getId());
			System.out.println("getCompanyName() si "+getCompanyName());
			insert.setString(2,getCompanyName());
			System.out.println("getCompanyURL() si "+getCompanyURL());
			insert.setString(3,getCompanyURL());
			System.out.println("mysqlFormat.format(new java.util.Date()) si "+mysqlFormat.format(new java.util.Date()));
			insert.setString(4,mysqlFormat.format(new java.util.Date()));
			System.out.println("mysqlFormat.format(new java.util.Date()) si "+mysqlFormat.format(new java.util.Date()));
			insert.setString(5,mysqlFormat.format(new java.util.Date()));
			System.out.println("getTaxID() si "+getTaxID());
			insert.setString(6,getTaxID());
			System.out.println("getDBA() si "+getDBA());
			insert.setString(7,getDBA());
			System.out.println("getAttention() si "+getAttention());
			insert.setString(8,getAttention());
			System.out.println("getPhone() si "+getPhone());
			insert.setString(9,getPhone());
			System.out.println("getFax() si "+getFax());
			insert.setString(10,getFax());
			System.out.println("getBillingEntityID() si "+getBillingEntityID());
			insert.setInt(11,getBillingEntityID());
			System.out.println("getCreditLimit() si "+getCreditLimit());
			insert.setDouble(12,getCreditLimit());
			System.out.println("getCreditStatus() si "+getCreditStatus());
			insert.setString(13,getCreditStatus());
			insert.execute();
		} catch (Exception x) {
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

	
	public final void processUpdate() throws SQLException{

		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
	
			String sql = "UPDATE companies SET company_name = ?, company_url = ?, date_last_modified = ?, taxid = ?, dba = ?, attention = ?, phone = ?, fax = ?, billing_entity_id = ? WHERE id = ?";
			PreparedStatement update = conn.prepareStatement(sql);
	
			update.clearParameters();		
			update.setString(1,getCompanyName());
			update.setString(2,getCompanyURL());
			update.setString(3,mysqlFormat.format(new java.util.Date()));
			update.setString(4,getTaxID());
			update.setString(5,getDBA());
			update.setString(6,getAttention());
			update.setString(7,getPhone());
			update.setString(8,getFax());
			update.setInt(9,getBillingEntityID());
			update.setInt(10,getId());
			update.execute();
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	

	public final void updateCompany(String column, String value)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "UPDATE companies SET " + column + " = \'" + value + "\', date_last_modified = \'" +mysqlFormat.format(new java.util.Date())+ "\' WHERE id = " + getId();
			qs.execute(sql);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void updateCompany(int id, String column, String value) throws SQLException{
		setId(id);
		updateCompany(column,value);	
	}	
	
	public final void updateCompany(String column, int value)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "UPDATE companies SET " + column + " = " + value + ", date_last_modified = \'"+mysqlFormat.format(new java.util.Date())+"\' WHERE id = " + getId();
			qs.execute(sql);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	public final void updateCompany(int id, String column, int value) throws SQLException{
		setId(id);
		updateCompany(column,value);	
	}

	public final void delete(int companyId)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			setId(companyId);	
			String sql = "DELETE FROM companies WHERE id = " + getId();
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
	public double getCreditLimit() {
		return creditLimit;
	}
	public void setCreditLimit(double creditLimit) {
		this.creditLimit = creditLimit;
	}
	public String getCreditStatus() {
		return creditStatus;
	}
	public void setCreditStatus(String creditStatus) {
		this.creditStatus = creditStatus;
	}	
}