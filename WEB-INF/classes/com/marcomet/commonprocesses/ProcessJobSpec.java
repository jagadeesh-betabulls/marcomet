/**********************************************************************
Description:	This Class handles insert/update/etc jobspec
**********************************************************************/

package com.marcomet.commonprocesses;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.marcomet.jdbc.DBConnect;

public class ProcessJobSpec{

	//variables
	private int id;
	private int catSpecId;
	private String value;
	//private String valueType;
	private int jobId;
	private double escrowPercentage;
	private double cost;
	private double mu;
	private double fee;
	private double price;
	
	public final void setId(int temp){
		id = temp;	
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
	}
	
	public final void setCatSpecId(int temp){
		catSpecId = temp;	
	}
	public final void setCatSpecId(String temp){
		setCatSpecId(Integer.parseInt(temp));
	}
	public final int getCatSpecId(){
		return catSpecId;
	}	
	
	public final void setValue(String temp){
		value = temp;	
	}
	public final String getValue(){
		return value;
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
		

	public final void setEscrowPercentage(double temp){
		escrowPercentage = temp;	
	}
	public final double getEscrowPercentage(){
		return escrowPercentage;
	}

	public final void setCost(double temp){
		cost = temp;	
	}
	public final double getCost(){
		return cost;
	}

	public final void setMu(double temp){
		mu = temp;	
	}
	public final double getMu(){
		return mu;
	}
	
	public final void setFee(double temp){
		fee = temp;	
	}
	public final double getFee(){
		return fee;
	}	
	
	public final void setPrice(double temp){
		price = temp;	
	}
	public final double getPrice(){
		return price;
	}
	
	//for legacy code, will be completely replaced by insert() over time;
	public final int insertJobSpec() throws SQLException{
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
		
		String insertSQL = "insert into job_specs(id,cat_spec_id,value,job_id,escrow_percentage,cost,mu,fee,price) values(?,?,?,?,?,?,?,?,?)";

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES job_specs WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from job_specs;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}	

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.clearParameters();
			insert.setInt(1,getId());
			insert.setInt(2,getCatSpecId());
			insert.setString(3,getValue());
			insert.setInt(4,getJobId());
			insert.setDouble(5,getEscrowPercentage());
			insert.setDouble(6,getCost());
			insert.setDouble(7,getMu());
			insert.setDouble(8,getFee());
			insert.setDouble(9,getPrice());		
			insert.execute();
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();
	}
	
	protected void finallize() {
		
	}		
}