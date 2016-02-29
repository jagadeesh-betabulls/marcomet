package com.marcomet.commonprocesses;

/**********************************************************************
Description:	This class will create/update/delete/etc Job Changes....

**********************************************************************/

import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.*;

import java.sql.*;


public class ProcessJobChange {

	//variables.
	private int id;
	private int jobId;
	private int createdById;
	private int changeTypeId;
	private String reason;
	private String comments;
	private double cost;
	private double mu;
	private double fee;	
	private double price;
	private int statusId;
	private int customerId;
	private String customerDate;
	
	protected void finalize() {
		
	}
	public final int getChangeTypeId(){
		return changeTypeId;
	}
	public final String getComments(){
		return comments;
	}
	public final double getCost(){
		return cost;
	}
	public final int getCreatedById(){
		return createdById;
	}
	public final String getCustomerDate(){
		return customerDate;
	}
	public final int getCustomerId(){
		return customerId;
	}
	public final double getFee(){
		return fee;
	}
	public final int getId(){
		return id;
	}
	public final int getJobId(){
		return jobId;
	}
	public final double getMu(){
		return mu;
	}
	public final double getPrice(){
		return price;
	}
	public final String getReason(){
		return reason;
	}
	public final int getStatusId(){
		return statusId;
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
	
	//form legacy code, will be replaced with just insert()	
	public final int insertJobChange() throws Exception{
		return insert();	
	}
	
	public final int processInsert() throws SQLException{
			
		StringTool st = new StringTool();		
		String insertSQL = "insert into jobchanges(id,jobid,createdbyid,changetypeid,reason,cost,mu,fee,price,statusid,customerid,customerdate, comments)values(?,?,?,?,?,?,?,?,?,?,?,Now(),?)";

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES jobchanges WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from jobchanges;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.setInt(1,getId());
			insert.setInt(2,getJobId());
			insert.setInt(3,getCreatedById());
			insert.setInt(4,getChangeTypeId());
			insert.setString(5,getReason());
			insert.setDouble(6,getCost());
			insert.setDouble(7,getMu());
			insert.setDouble(8,getFee());
			insert.setDouble(9,getPrice());
			insert.setInt(10,getStatusId());
			insert.setInt(11,getCustomerId());
//			insert.setString(12,st.mysqlFormatDate(getCustomerDate()));
			insert.setString(12,getComments());
			insert.execute();
		}catch(Exception e){
			throw new SQLException(e.getMessage());
		}finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
		
		return getId();	
	}
	public final void setChangeTypeId(int temp){
		changeTypeId = temp;	
	}
	public final void setChangeTypeId(String temp){
		setChangeTypeId(Integer.parseInt(temp));
	}
	public final void setComments(String temp){
		comments = temp;	
	}
	public final void setCost(double temp){
		cost = temp;	
	}
	public final void setCost(String temp){
		setCost(Double.parseDouble(temp));
	}
	public final void setCreatedById(int temp){
		 createdById = temp;	
	}
	public final void setCreatedById(String temp){
		setCreatedById(Integer.parseInt(temp));
	}
	public final void setCustomerDate(String temp){
		customerDate = temp;
	}
	public final void setCustomerId(int temp){
		customerId = temp;	
	}
	public final void setCustomerId(String temp){
		setCustomerId(Integer.parseInt(temp));
	}
	public final void setFee(double temp){
		fee = temp;	
	}
	public final void setFee(String temp){
		setFee(Double.parseDouble(temp));
	}
	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final void setJobId(int temp){
		jobId = temp;	
	}
	public final void setJobId(String temp){
		setJobId(Integer.parseInt(temp));
	}
	public final void setMu(double temp){
		mu = temp;	
	}
	public final void setMu(String temp){
		setMu(Double.parseDouble(temp));
	}
	public final void setPrice(double temp){
		price = temp;	
	}
	public final void setPrice(String temp){
		setPrice(Double.parseDouble(temp));
	}
	public final void setReason(String temp){
		reason = temp;	
	}
	public final void setStatusId(int temp){
		statusId = temp;	
	}
	public final void setStatusId(String temp){
		setStatusId(Integer.parseInt(temp));
	}
	public final void updateJobChange(int id, String column, int value) throws SQLException{
		setId(id);
		updateJobChange(column,value);	
	}
	public final void updateJobChange(int id, String column, String value) throws SQLException{
		setId(id);
		updateJobChange(column,value);	
	}
	public final void updateJobChange(String column, int value)throws SQLException{
		
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "update jobchanges set " + column + " = " + value + " where id = " + getId();
			qs.execute(sql);
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	public final void updateJobChange(String column, String value)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "update jobchanges set " + column + " = \'" + value + "\' where id = " + getId();
			qs.execute(sql);
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	public final void updateJobChangeJobId(int jobId, String column, int value) throws SQLException{
		setJobId(jobId);
		updateJobChangeJobId(column,value);	
	}
	public final void updateJobChangeJobId(String column, int value)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "update jobchanges set " + column + " = " + value + " where customerid <= 0 and jobid = " + getJobId();
			qs.execute(sql);			
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	public final void updateJobChangeJobId(String column, String value)throws SQLException{
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			PreparedStatement updateChanges = conn.prepareStatement("update jobchanges set " + column + " = ? where customerid <= 0 and jobid = ?");
			updateChanges.clearParameters();
			updateChanges.setString(1, value);
			updateChanges.setInt(2, getJobId());
			updateChanges.execute();
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
}
