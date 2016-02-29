/**********************************************'
puppose: insert/update/etc user roles
	
**********************************************************************/

package com.marcomet.commonprocesses;
import com.marcomet.jdbc.DBConnect;
import java.sql.*;

public class ProcessRole{
	
	private int id;
	private int siteHostId;
	private int roleId;
	private int contactId;
	private String companyName="";
	private String userName="";
	private String contactName="";
	private String roleCheckBoxes="";
	
	public ProcessRole(){
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
	
	public final void setCompanyName(String temp){
		companyName=temp;
	}
	public final String getCompanyName(){
		return companyName;
	}
		
	public final void setUserName(String temp){
		userName=temp;
	}
	public final String getUserName(){
		return userName;
	}	
	public final void setContactName(String temp){
		contactName=temp;
	}
	public final String getContactName(){
		return contactName;
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
	public final String getRoleCheckBoxes(){
		return roleCheckBoxes;
	}
	public final void setRoleId(int temp){
		roleId = temp;	
	}
	public final void setRoleId(String temp){
		setRoleId(Integer.parseInt(temp));
	}
	public final int getRoleId(){
		return roleId;
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


	public final int insert() throws SQLException{
		
		String insertSQL = "INSERT INTO contact_roles(id,contact_id,contact_role_id,site_host_id) VALUES (?,?,?,?)";

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES contact_roles WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from contact_roles";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}	

			PreparedStatement insert = conn.prepareStatement(insertSQL);		
			insert.clearParameters();
			insert.setInt(1,getId());
			insert.setInt(2,getContactId());
			insert.setInt(3,getRoleId());
			insert.setInt(4,getSiteHostId());			
			insert.execute();
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();
	}

	//share connection from calling object	
	public final int insert(Connection tempConn) throws SQLException, Exception{
		//conn = tempConn;
		int i = insert();
		//conn = null;
		return i;		
	}	
	

	
	public final void delete(int roleId)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			setId(roleId);			
			String sql = "DELETE FROM contact_roles WHERE id = " + getId();
			qs.execute(sql);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}	

	public final void selectContact(int contactId,int siteHostId)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			setContactId(contactId);
			setSiteHostId(siteHostId);			
			String sql = "Select ct.id, com.company_name,lg.user_name,concat(ct.firstname,\" \",ct.lastname) as fullname from contacts ct left join logins lg on lg.contact_id=ct.id left join companies com on com.id=ct.companyid WHERE ct.id = " + getContactId();
			ResultSet rs = qs.executeQuery(sql);	
			if (rs.next()){
				companyName=rs.getString("com.company_name");
				userName=rs.getString("lg.user_name");
				contactName=rs.getString("fullname");
				sql="Select * from lu_contact_roles lu, site_host_roles_bridge br  left join contact_roles cr on cr.contact_role_id=lu.id and  cr.contact_id="+rs.getString("id")+" where lu.id=br.role_id and br.site_host_id="+siteHostId;						
				ResultSet rl = qs.executeQuery(sql);
				while (rl.next()){
					roleCheckBoxes+="<input type=\"checkbox\" name=\"role_"+rl.getString("lu.id")+"\" value=\"yes\" "+((rl.getString("cr.id")!=null)?"checked":"")+">"+rl.getString("lu.value")+"<br>";
				
				}
			}
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}		

	protected void finalize() {
	
	}	
}