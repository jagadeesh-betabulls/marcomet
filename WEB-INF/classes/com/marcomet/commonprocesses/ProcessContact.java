/********************************
purpose: insert/update/etc contact
**********************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.*;

import java.sql.*;

public class ProcessContact{

	//always ensure all these variables are in the clear function
	private int id;
	private int companyId;
	private String firstName;
	private String middleInitial;
	private String lastName;
	private int titleId;
	private String jobTitle;
	private String email;
	private String siteNumber;
	private String pmSiteNumber;
	private String defaultWebsite;
	private int bypass_site_number_validation_flag = 0;
	private int active_flag = 1;
	private String contact_notes = null;
	
	public final void setId(int temp){
		id = temp;
	}
	public final void setId(String temp){
		setId(Integer.parseInt(temp));
	}
	public final int getId(){
		return id;
	}	

	public final void setCompanyId(int temp){
		companyId = temp;
	}
	public final void setCompanyId(String temp){
		setCompanyId(Integer.parseInt(temp));
	}
	public final int getCompanyId(){
		return companyId;
	}

	public final void setFirstName(String temp){
		firstName = temp;
	}
	public final String getFirstName(){
		return firstName;
	}
	public final int getBypassSiteNumberValidationFlag() {
		return bypass_site_number_validation_flag;
	}
	public final void setBypassSiteNumberValidationFlag( int temp ) {
		bypass_site_number_validation_flag = temp;
	}
	public final int getActiveFlag() {
		return active_flag;
	}
	public final void setActiveFlag(int temp) {
		active_flag = temp;
	}
	public final String getContactNotes() {
		return contact_notes;
	}
	public final void setContactNotes( String temp ) {
		contact_notes = temp;
	}

	public final void setMiddleInitial(String temp){
		middleInitial = temp;
	}
	public final String getMiddleInitial(){
		return middleInitial;
	}

	public final void setLastName(String temp){
		lastName = temp;
	}
	public final String getLastName(){
		return lastName;
	}

	public final void setTitleId(int temp){
		titleId = temp;
	}
	public final void setTitleId(String temp){
		setTitleId(Integer.parseInt(temp));
	}
	public final int getTitleId(){
		return titleId;
	}
	
	public final void setJobTitle(String temp){
		jobTitle = temp;
	}
	public final String getJobTitle(){
		return jobTitle;
	}

	public final void setEmail(String temp){
		email = temp;
	}
	public final String getEmail(){
		return email;
	}
	
	public final void setSiteNumber(String temp){
		siteNumber = temp;
	}
	public final String getSiteNumber(){
		return ((siteNumber==null)?"":siteNumber);
	}
	
	public final void setPMSiteNumber(String temp){
		pmSiteNumber = temp;
	}
	public final String getPMSiteNumber(){
		return ((pmSiteNumber==null)?"":pmSiteNumber);
	}
	
	public final void setDefaultWebsite(String temp){
		defaultWebsite = temp;
	}
	public final String getDefaultWebsite(){
		return ((defaultWebsite==null)?"":defaultWebsite);
	}	
	
	//for legacy code, will be replaced by insert() over time
	public final int insertContact() throws SQLException {
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

		
		String insertSQL = "INSERT INTO contacts(id,companyid,firstname,mi,lastname,titleid,jobtitle,email,default_site_number,default_pm_site_number,default_website,bypass_site_number_validation_flag,active_flag,contact_notes) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			//lock table
			qs.execute("LOCK TABLES contacts WRITE");	
					
			//set id if it is 0/null
			if(getId() <= 0){
				String getNextIdSQL = "SELECT IF( MAX(id) IS NULL, 0, MAX(id))+1 FROM contacts;";
				ResultSet rs1 = qs.executeQuery(getNextIdSQL);
				rs1.next(); 
				setId(rs1.getInt(1));
			}	

			PreparedStatement insert = conn.prepareStatement(insertSQL);
			insert.clearParameters();
			insert.setInt(1,getId());
			insert.setInt(2,getCompanyId());
			insert.setString(3,getFirstName());
			insert.setString(4,getMiddleInitial());
			insert.setString(5,getLastName());
			insert.setInt(6,getTitleId());
			insert.setString(7,getJobTitle());
			insert.setString(8,getEmail());
			insert.setString(9,getSiteNumber());
			insert.setString(10,getPMSiteNumber());
			insert.setString(11,getDefaultWebsite());
			insert.setInt(12, getBypassSiteNumberValidationFlag());
			insert.setInt(13, getActiveFlag());
			insert.setString(14, getContactNotes());
			insert.execute();
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.execute("UNLOCK TABLES"); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return getId();
	}	
	
	//for older classes will be replaced with the update()	
	public final void updateContact() throws Exception{	
		update();
	}

	//share connection from calling object	
	public final void update(Connection tempConn) throws Exception{
		//conn = tempConn;
		update();
		//conn = null;
		return;		
	}
	
	public final void update() throws SQLException{
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			String sql = "UPDATE contacts SET companyid = ?,firstname = ?, mi = ?,lastname = ?,titleid = ?,jobtitle = ?, email = ?,default_site_number=?,default_pm_site_number=?,default_website=?,bypass_site_number_validation_flag=?,active_flag=?,contact_notes=? WHERE id =?";
			PreparedStatement update = conn.prepareStatement(sql);
			
			update.clearParameters();
			update.setInt(1,getCompanyId());
			update.setString(2,getFirstName());
			update.setString(3,getMiddleInitial());
			update.setString(4,getLastName());
			update.setInt(5,getTitleId());
			update.setString(6,getJobTitle());
			update.setString(7,getEmail());
			update.setString(8,getSiteNumber());
			update.setString(9,getPMSiteNumber());
			update.setString(10,getDefaultWebsite());
			update.setInt(11,getId());
			update.setInt(12, getBypassSiteNumberValidationFlag());
			update.setInt(13, getActiveFlag());
			update.setString(14, getContactNotes());
			update.execute();	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {			
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void updateContact(String column, String value)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "UPDATE contacts SET " + column + " = \'" + value + "\' WHERE id = " + getId();
			qs.execute(sql);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void updateContact(int id, String column, String value) throws SQLException{
		setId(id);
		updateContact(column,value);	
	}	
	
	public final void updateContact(String column, int value)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			String sql = "UPDATE contacts SET " + column + " = " + value + " WHERE id = " + getId();
			qs.execute(sql);	
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void updateContact(int id, String column, int value) throws SQLException{
		setId(id);
		updateContact(column,value);	
	}	

	public final void delete(int contactId)throws SQLException{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			setId(contactId);		
			String sql = "DELETE FROM contacts WHERE id = " + getId();
			qs.execute(sql);
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	
	public final void clear() {
		id = 0;
		companyId = 0;
		firstName = "";
		middleInitial = "";
		lastName = "";
		titleId = 0;
		jobTitle = "";
		email = "";	
		bypass_site_number_validation_flag = 0;
		active_flag = 1;
		contact_notes = "";		
	}

	protected void finalize() {
		
	}
}