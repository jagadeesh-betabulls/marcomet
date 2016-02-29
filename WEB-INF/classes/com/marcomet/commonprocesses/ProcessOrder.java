/**********************************************************************
Description:	This class will insert/update db for an order.
**********************************************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.DBConnect;
import java.sql.*;


public class ProcessOrder{

	private int id;
	private int buyerContactId;
	private int orderedById=0;
	private int buyerCompanyId;
	private int siteHostId;
	private int siteHostContactId;	 
	private String customerPO;

	public ProcessOrder(){

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

	public final void setBuyerContactId(int temp){
		buyerContactId = temp;	
	}
	public final void setBuyerContactId(String temp){
		setBuyerContactId(Integer.parseInt(temp));
	}
	public final int getBuyerContactId(){
		return buyerContactId;
	}
	
	public final void setOrderedById(int temp){
		orderedById = temp;	
	}
	public final void setOrderedById(String temp){
		setOrderedById(Integer.parseInt(temp));
	}
	public final int getOrderedById(){
		return ((orderedById==0)?buyerContactId:orderedById);
	}

	public final void setBuyerCompanyId(int temp){
		buyerCompanyId = temp;	
	}
	public final void setBuyerCompanyId(String temp){
		setBuyerCompanyId(Integer.parseInt(temp));
	}
	public final int getBuyerCompanyId(){
		return buyerCompanyId;
	}
	
	public final void setSiteHostId(int temp){
		siteHostId = temp;	
	}
	public final void setSiteHostId(String temp){
		setSiteHostId(Integer.parseInt(temp));
	}
	public final int getSiteHostId(){
		return siteHostId;
	}

	public final void setSiteHostContactId(int temp){
		siteHostContactId = temp;	
	}
	public final void setSiteHostContactId(String temp){
		setSiteHostContactId(Integer.parseInt(temp));
	}
	public final int getSiteHostContactId(){
		return siteHostContactId;
	}	
			
	//for legacy code will be removed with time
	public final int insertOrder() throws Exception{
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
		
		String insertSQL = "insert into orders(id,buyer_contact_id,buyer_company_id,site_host_id,site_host_contact_id,ordered_by_contact_id,customer_po) values (?,?,?,?,?,?,?)";

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES orders WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from orders;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}	

			PreparedStatement insert = conn.prepareStatement(insertSQL);
		
			insert.clearParameters();
			insert.setInt(1,getId());
			insert.setInt(2,getBuyerContactId());
			insert.setInt(3,getBuyerCompanyId());
			insert.setInt(4,getSiteHostId());
			insert.setInt(5,getSiteHostContactId());
			insert.setInt(6,getOrderedById());
			insert.setString(7,getCustomerPO());
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

	public String getCustomerPO() {
		return customerPO;
	}

	public void setCustomerPO(String customerPO) {
		this.customerPO = customerPO;
	}


}