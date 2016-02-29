/******************************************
purpose: insert/update/etc logins
*********************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.DBConnect;
import java.sql.*;


public class ProcessLogin{
		
	//varables;
	private int id;
	private int contactId;
	private String userName;
	private String userPassword;
	
	public ProcessLogin(){
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

	public final void setContactId(int temp){
		contactId = temp;	
	}
	public final void setContactId(String temp){
		setContactId(Integer.parseInt(temp));
	}
	public final int getContactId(){
		return contactId;
	}

	public final void setUserName(String temp){
		userName = temp;	
	}
	public final String getUserName(){
		return userName;
	}

	public final void setUserPassword(String temp){
		userPassword = temp;	
	}
	public final void setPassword(String temp){
		userPassword = temp;
	}
	public final String getUserPassword(){
		return userPassword;
	}

	//for legacy code will be phased out over time	
	public final int insertLogin() throws Exception{
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

		
		String insertSQL = "insert into logins(id,contact_id,user_name,user_password) values (?,?,?,md5(?))";

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES logins WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "select IF( max(id) IS NULL, 0, max(id))+1  from logins;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}	

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.clearParameters();
			insert.setInt(1,getId());
			insert.setInt(2,getContactId());
			insert.setString(3,getUserName());
			insert.setString(4,getUserPassword());
			insert.execute();;
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();
	}
	
	public final boolean checkUserNameClear(String userName)
	throws SQLException{
	
		System.out.println("chkUsrNmClr=" + userName);
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM logins WHERE user_name= ?");
			
			ps.setString(1,userName);
			
			ResultSet check = ps.executeQuery();
			check.next();
			if(check.getInt(1) > 0){
				return false;
			}else{
				return true;
			}	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}	
	
	public final boolean checkEmailClear(String email)
	throws SQLException{
	
		System.out.println("chkEmlClr=" + email);
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM contacts WHERE email = ?");
			
			ps.setString(1,email);
			
			ResultSet check = ps.executeQuery();
			check.next();
			if(check.getInt(1) > 0){
				return false;
			}else{
				return true;
			}	
		} catch (Exception x) {
			System.err.println(x.getMessage());
			throw new SQLException(x.getMessage());
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}	
	
	public final boolean checkEmailClear(String email,String sitehostId)
	throws SQLException{
	
		System.out.println("chkEmlClr=" + email);
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			PreparedStatement ps = conn.prepareStatement("SELECT count(*) FROM contacts c left join reg_group_bridge r on default_website=r.sitehost_id left join reg_group_bridge r1 on r1.sitehost_id=? and r.group_id=r1.group_id  WHERE email = ? and r1.id is not null");
			
			ps.setString(1,sitehostId);
			ps.setString(2,email);
			
			ResultSet check = ps.executeQuery();
			check.next();
			if(check.getInt(1) > 0){
				return false;
			}else{
				return true;
			}	
		} catch (Exception x) {
			System.err.println(x.getMessage());
			throw new SQLException(x.getMessage());
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}	

    public final boolean checkUserNameEmailClear(String email,String userName)
    throws SQLException{

	System.out.println("chkUsrNmEmlClr=" + email + "/" + userName);
    	Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();

            PreparedStatement ps = conn.prepareStatement("select count(*) from contacts ct left join logins l on ct.id=l.contact_id  where email=? or l.user_name=?");
            ps.setString(1,email);
            ps.setString(2,userName);

            ResultSet check = ps.executeQuery();
            check.next();
            if(check.getInt(1) > 0){
                    return false;
            }else{
                    return true;
            }
		} catch (Exception x) {
			System.err.println(x.getMessage());
			throw new SQLException(x.getMessage());
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
    }
    public final boolean checkUserNameEmailClear(String email,String userName,String sitehostId)
    throws SQLException{

	System.out.println("chkUsrNmEmlClr=" + email + "/" + userName+"/"+sitehostId);
    	Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();

            PreparedStatement ps = conn.prepareStatement("select count(*) from contacts c left join reg_group_bridge r on default_website=r.sitehost_id left join reg_group_bridge r1 on r1.sitehost_id=? and r.group_id=r1.group_id left join logins l on c.id=l.contact_id  where (email=? and r1.id is not null) or l.user_name=?");
            ps.setString(1,sitehostId);
            ps.setString(2,email);
            ps.setString(3,userName);
            ResultSet check = ps.executeQuery();
            check.next();
            System.out.println(check.getString("count(*)"));
            String count=check.getString("count(*)");
            if(count.equals("0")){
                    return true;
            }else{
                    return false;
            }
            
		} catch (Exception x) {
			System.err.println(x.getMessage());
			throw new SQLException(x.getMessage());
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
    }
        
    public final int getEmailOrDomainFlag(String email) throws SQLException{

    	System.out.println("getEmlOrDmnFlg=" + email);
    	
    	Connection conn = null; 
    	Statement st = null;
    	StringBuffer buff = new StringBuffer();
    	ResultSet results = null;
    	int pos = 0;
     	
		try {			
			conn = DBConnect.getConnection();
			st = conn.createStatement();
			
			//Check the specific email address first
			buff.append("select allow_for_registration_flag from email_address_validation where email_address = '");
            buff.append(email);
            buff.append("'");
            
            results = st.executeQuery(buff.toString());
            
            
            if(results.next()){
                   //email address is found
            	return results.getInt(1);
            }else{
            	//email address was not found
            	//check for domain name
                buff.delete(0, buff.length());
                buff.append("select allow_for_registration_flag from email_address_validation where email_domain = '");
                pos = email.indexOf('@');
                buff.append(email.substring(pos+1));
                buff.append("'");
                
                results = st.executeQuery(buff.toString());
                if(results.next()){
                    //domain is found
                	return results.getInt(1);
                } else {
                	//no record exists
                	return -1;
                }
            }
		} catch (Exception x) {
			System.err.println(x.getMessage());
			throw new SQLException(x.getMessage());
		} finally {			
			try { st.close(); } catch ( Exception x) { st = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
    }

	public final void delete(int id)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			setId(id);	
			
			String sql = "DELETE FROM logins WHERE id =" + getId();
			qs.execute(sql);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void deleteContactId(int contactId)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			setContactId(contactId);		
			String sql = "DELETE FROM logins WHERE contact_id =" + getContactId();
			qs.execute(sql);
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void updatePW() throws SQLException{
		
		String updateSQL = "update logins set user_password=md5(?) where contact_id=?";

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES logins WRITE");		
			PreparedStatement update = conn.prepareStatement(updateSQL);
			update.clearParameters();
			update.setString(1,getUserPassword());
			update.setInt(2,getContactId());
			update.execute();;
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}		
	
	protected void finalize() {
		
	}	
}
