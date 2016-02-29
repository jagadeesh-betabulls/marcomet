/**********************************************************************
Description:	This class will be used to perform actions on Press Releases
**********************************************************************/

package com.marcomet.commonprocesses;

import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.*;
import java.sql.*;

public class ProcessPage{

	FormaterTool fmt= new FormaterTool();
	StringTool str=new StringTool();
	//variables
	private int id;
	private	int	companyId = 0;
	private int	statusId = 0;
	private int contactId = 0;
	private int submitterId = 0;
	private int actionOnExpireId = 0;
	private int pageTypeId = 0;	
	private String dateCreated = "";
	private String html = "";
	private String securityUsername = "";	
	private String securityPassword = "";	
	private String securityBuriedPage = "";	
	private String miscKeywords = "";					
	private String dateExpires = "";
	private String dateToPost = "";
	private String title = "";
	private String isPageOutsideSite = "";
	private String redirectURL = "";
	private String helpPublish = "";
	private String onlyShowHtml = "";
	private	String smallPicURL = "";
	private	String fullPicURL = "";	
	private	String demoURL = "";
	private	String printFileURL = "";		
	private	String body = "";
	private	String summary = "";			
	
	public ProcessPage(){
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
	
	public final void setSubmitterId(int temp){
		submitterId = temp;	
	}
	public final void setSubmitterId(String temp){
		setSubmitterId(Integer.parseInt(temp));
	}
	public final int getSubmitterId(){
		return submitterId;
	}	

	public final void setActionOnExpireId(int temp){
		actionOnExpireId = temp;	
	}
	public final void setActionOnExpireId(String temp){
		setActionOnExpireId(Integer.parseInt(temp));
	}
	public final int getActionOnExpireId(){
		return actionOnExpireId;
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
	
	
	public final void setStatusId(int temp){
		statusId = temp;	
	}
	public final void setStatusId(String temp){
		setStatusId(Integer.parseInt(temp));
	}
	public final int getStatusId(){
		if (statusId==0){
			return 1;
		}else{
			return statusId;
		}		
	}
	
	public final void setPageTypeId(int temp){
		pageTypeId = temp;	
	}
	public final void setPageTypeId(String temp){
		setPageTypeId(Integer.parseInt(temp));
	}
	public final int getPageTypeId(){
		if (pageTypeId==0){
			return 1;
		}else{
			return pageTypeId;
		}		
	}		

	public final void setDateCreated(String temp){
		dateCreated = temp;	
	}
	
	public final String getDateCreated(){
		if (dateCreated==null){
			return "";
		}else{
			return dateCreated;
		}			
	}
	
	public final void setDateExpires(String temp){
		dateExpires = temp;	
	}
	
	public final String getDateExpires(){
		if (dateExpires==null){
			return "";
		}else{
			return dateExpires;
		}			
	}
	
	public final void setDateToPost(String temp){
		dateToPost = temp;	
	}	
	
	public final String getDateToPost(){
		if (dateToPost==null){
			return "";
		}else{
			return dateToPost;
		}			
	}
	
	public final void setHtml(String temp){
		html = temp;	
	}	
	
	public final String getHtml(){
		if (html==null){
			return "";
		}else{
			return html;
		}			
	}

	public final void setSmallPicURL(String temp){
		smallPicURL = temp;	
	}
	public final String getSmallPicURL(){
		if (smallPicURL==null){
			return "";
		}else{
			return smallPicURL;
		}		
	}
	public final void setFullPicURL(String temp){
		fullPicURL = temp;	
	}
	public final String getFullPicURL(){
		if (fullPicURL==null){
			return "";
		}else{
			return fullPicURL;
		}		
	}	

	public final void setDemoURL(String temp){
		demoURL = temp;	
	}
	public final String getDemoURL(){
		if (demoURL==null){
			return "";
		}else{
			return demoURL;
		}		
	}


	public final void setSecurityUsername  (String temp){
		securityUsername   = temp;	
	}
	public final String getSecurityUsername(){
		if (securityUsername==null){
			return "";
		}else{
			return securityUsername;
		}			
	}
	
	public final void setSecurityPassword  (String temp){
		securityPassword   = temp;	
	}
	public final String getSecurityPassword(){
		if (securityPassword==null){
			return "";
		}else{
			return securityPassword;
		}			
	}
	
	public final void setSecurityBuriedPage  (String temp){
		securityBuriedPage   = temp;	
	}
	public final String getSecurityBuriedPage(){
		if (securityBuriedPage==null){
			return "";
		}else{
			return securityBuriedPage;
		}			
	}	
	
	public final void setIsPageOutsideSite  (String temp){
		isPageOutsideSite   = temp;	
	}
	public final String getIsPageOutsideSite(){
		if (isPageOutsideSite==null){
			return "";
		}else{
			return isPageOutsideSite;
		}			
	}	
					
		
	public final void setBody(String temp){
		body = temp;	
	}
	public final String getBody(){
		if (body==null){
			return "";
		}else{
			return body;
		}			
	}
	
	public final void setRedirectURL(String temp){
		redirectURL = temp;	
	}
	public final String getRedirectURL(){
		if (redirectURL==null){
			return "";
		}else{
			return redirectURL;
		}			
	}	
	
	public final void setSummary(String temp){
		summary = temp;	
	}
	public final String getSummary(){
		if (summary==null){
			return "";
		}else{
			return summary;
		}		
	}	
	
	public final void setTitle(String temp){
		title = temp;	
	}
	public final String getTitle(){
		if (title==null){
			return "";
		}else{
			return title;
		}			
	}
	
	public final void setMiscKeywords(String temp){
		miscKeywords = temp;	
	}
	public final String getMiscKeywords(){
		if (miscKeywords==null){
			return "";
		}else{
			return miscKeywords;
		}			
	}
	
	
	
	
	public final void setPrintFileURL(String temp){
		printFileURL = temp;	
	}
	public final String getPrintFileURL(){
		if (printFileURL==null){
			return "";
		}else{
			return printFileURL;
		}			
	}
	public final void setHelpPublish(String temp){
		helpPublish = temp;	
	}
	public final String getHelpPublish(){
		if (helpPublish==null){
			return "";
		}else{
			return helpPublish;
		}			
	}
	public final void setOnlyShowHtml(String temp){
		onlyShowHtml = temp;	
	}
	public final String getOnlyShowHtml(){
		if (onlyShowHtml==null){
			return "";
		}else{
			return onlyShowHtml;
		}			
	}

	
	public final void insert() throws SQLException, Exception{
		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			ResultSet rs = qs.executeQuery("select (IF( max(id) IS NULL, 0, max(id))+1)   as id from pages");
			if (rs.next()){
				setId(Integer.parseInt(rs.getString("id")));			
			}
				
			String insertSQL = "insert into pages (id,title,misc_keywords,company_id,contact_id,date_created,date_to_post,date_expires,action_on_expire_id,submitter_id,summary,body,html,security_username,security_password,security_buriedPage,is_page_outside_site,redirect_URL,small_picURL,full_picURL,print_file_URL,status_id,help_publish,only_show_html,page_type_id,demo_url) ";
			insertSQL+="VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
			PreparedStatement insert = conn.prepareStatement(insertSQL);
			int x=1;
			insert.setInt(x++,getId());
			insert.setString(x++,getTitle());
			insert.setString(x++,getMiscKeywords());
			insert.setInt(x++,getCompanyId());
			insert.setInt(x++,getContactId());		
			insert.setString(x++,str.mysqlFormatDate(getDateCreated()));
			insert.setString(x++,str.mysqlFormatDate(getDateToPost()));
			insert.setString(x++,str.mysqlFormatDate(getDateExpires()));			
			insert.setInt(x++,getActionOnExpireId());
			insert.setInt(x++,getSubmitterId());			
			insert.setString(x++,getSummary());
			insert.setString(x++,getBody());
			insert.setString(x++,getHtml());
			insert.setString(x++,getSecurityUsername());
			insert.setString(x++,getSecurityPassword());
			insert.setString(x++,getSecurityBuriedPage());
			insert.setString(x++,getIsPageOutsideSite());
			insert.setString(x++,getRedirectURL());
			insert.setString(x++,getSmallPicURL());
			insert.setString(x++,getFullPicURL());
			insert.setString(x++,getPrintFileURL());
			insert.setInt(x++,getStatusId());
			insert.setString(x++,getHelpPublish());
			insert.setString(x++,getOnlyShowHtml());
			insert.setInt(x++,getPageTypeId());	
			insert.setString(x++,getDemoURL());								
			insert.execute();		
			
		}finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}		
		return;
	}	
	
	
	
	public final void select(int key)throws SQLException{

		Statement qs = null;
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			qs = conn.createStatement();
			setId(key);			
			String sql = "select * from pages where id= " + id;
			ResultSet rs = qs.executeQuery(sql);
			if (rs.next()){		
				companyId = rs.getInt("company_id");
				statusId = rs.getInt("status_id");
				contactId = rs.getInt("contact_id");
				submitterId = rs.getInt("submitter_id");
				actionOnExpireId = rs.getInt("action_on_expire_id");
				pageTypeId = rs.getInt("page_type_id");
				html = rs.getString("html");
				securityUsername = rs.getString("security_username");
				securityPassword = rs.getString("security_password");
				securityBuriedPage = rs.getString("security_buriedpage");
				miscKeywords = rs.getString("misc_keywords");
				dateToPost  = rs.getString("date_to_post");				
				try{ dateToPost  = fmt.formatMysqlDate(rs.getString("date_ to_post"));		
				 	}catch(Exception e){}
				
				dateCreated  = rs.getString("date_created");				
				try{ dateCreated  = fmt.formatMysqlDate(rs.getString("date_created"));		
				 	}catch(Exception e){}
					
				dateExpires= rs.getString("date_expires");				
				try{ dateExpires = fmt.formatMysqlDate(rs.getString("date_expires"));		
				 	}catch(Exception e){}
				title = rs.getString("title");
				isPageOutsideSite = rs.getString("is_page_outside_site");
				redirectURL = rs.getString("redirect_url");
				helpPublish = rs.getString("help_publish");
				onlyShowHtml = rs.getString("only_show_html");
				smallPicURL = rs.getString("small_picurl");
				fullPicURL = rs.getString("full_picurl");
				demoURL = rs.getString("demo_url");
				printFileURL = rs.getString("print_file_url");
				body = rs.getString("body");
				summary = rs.getString("summary");
			
			}
		} catch (Exception x) {
			throw new SQLException(x.getMessage());
		} finally {
			try { qs.close(); } catch ( Exception x) { qs = null; }
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}
	}
	
	public final void select(String key) throws SQLException{
		setId(key);
		select(id);	
	}		
		
			
	
	protected void finalize() {
		
	}
}
