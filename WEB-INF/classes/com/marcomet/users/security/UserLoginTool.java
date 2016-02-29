package com.marcomet.users.security;

/**********************************************************************
Description:	This Class centralizes the login process into one location.
				Login process is the process of placing needed information into
				session.
				
Notes:			for validating user name and password 
				required fields userName, password				
**********************************************************************/

import com.marcomet.jdbc.*;
import com.marcomet.environment.*;

import java.sql.*;

import javax.servlet.*;
import javax.servlet.http.*;

public class UserLoginTool{

		
	private RoleResolver buildUserRoles(HttpServletRequest request,Connection conn, int contactId) throws SQLException {

		StringBuffer returnValues = new StringBuffer("");

		String sql1 = "SELECT lcr.value FROM contact_roles cr, lu_contact_roles lcr WHERE cr.contact_role_id = lcr.id AND site_host_id = ? AND cr.contact_id = ?";
		PreparedStatement selectRoles = conn.prepareStatement(sql1);

		selectRoles.setInt(1, Integer.parseInt(((SiteHostSettings)request.getSession().getAttribute("siteHostSettings")).getSiteHostId()));
		selectRoles.setInt(2, contactId);
		ResultSet rs1 = selectRoles.executeQuery();

		//this object is used to hold and search for roles.
		RoleResolver rr = new RoleResolver();

		if (rs1.next()) {
			do {
				rr.addRole(rs1.getString("value"));
			} while(rs1.next());
		} else {
			rr.addRole("buyer");                    //patch till all users are registered as buyers.  :)
		}	

		return rr;

	}
	
	private PropertySites buildUserProperties(HttpServletRequest request,Connection conn, int contactId) throws SQLException {

		StringBuffer returnValues = new StringBuffer("");

		String sql1 = "SELECT distinct propery_code,property_id FROM v_contact_properties  WHERE contact_id = ?";
		PreparedStatement selectProperties = conn.prepareStatement(sql1);

		selectProperties.setInt(1, contactId);
		ResultSet rs1 = selectProperties.executeQuery();

		//this object is used to hold and search for roles.
		PropertySites ps = new PropertySites();

		if (rs1.next()) {
			do {
				ps.addSite(rs1.getString("value"));
			} while(rs1.next());
		}	
		return ps;
	}

	public boolean logUserIntoSystem(HttpServletRequest request, HttpServletResponse response, int contactId){
		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			//setup/get userProfile object
			UserProfile userProfile;
			if(request.getSession().getAttribute("userProfile") == null){
				userProfile = new UserProfile();
				request.getSession().setAttribute("userProfile",userProfile);				
			}else{
				userProfile = (UserProfile)request.getSession().getAttribute("userProfile");
			}
			
			String sql1 = "SELECT c.id, firstname, lastname, email, companyid, default_website,default_site_number,taxid, md5(c.id) 'cookie encryption' FROM contacts c left join companies co on co.id=c.companyid WHERE c.id = ?";
			PreparedStatement selectContact= conn.prepareStatement(sql1);
		
			selectContact.setInt(1,contactId);
			ResultSet rs1 = selectContact.executeQuery();	
		
			if(rs1.next()){
				request.getSession().setAttribute("UserFullName",rs1.getString("firstname")+" " + rs1.getString("lastname"));
				request.getSession().setAttribute("companyId",rs1.getString("companyid"));
				request.getSession().setAttribute("Login",new com.marcomet.tools.LoginBreakerClass());
				request.getSession().setAttribute("contactId",rs1.getString("id"));
				request.getSession().setAttribute("roles",buildUserRoles(request,conn,contactId));
				System.out.println("contactId is "+contactId);
				//****** user information object ************
				userProfile.setUserFullName(rs1.getString("firstname")+" " + rs1.getString("lastname"));
				userProfile.setCompanyId(rs1.getString("companyid"));
				userProfile.setDefaultWebsite(rs1.getString("default_website"));
				userProfile.setSiteNumber(rs1.getString("default_site_number"));
				userProfile.setTaxId(rs1.getString("taxid"));
				userProfile.setContactId(contactId+"");
				userProfile.setRoles(buildUserRoles(request,conn,contactId));				
				//*****************
				
/*			
				//set login cookie for users return to site after leaving
				Cookie c1 =new Cookie("contactId",rs1.getString("id"));
				c1.setPath("/");
				c1.setComment("ask Tom");
				c1.setMaxAge(30*24*60*60);
				response.addCookie(c1);
*/				
				//set login cookie for users return to site after leaving
				Cookie c2 =new Cookie("qwerty",rs1.getString("cookie encryption"));
				c2.setPath("/");
				//c2.setDomain("." + (String)request.getSession().getAttribute("domainName"));
				c2.setComment("ask Tom");
				c2.setMaxAge(30*24*60*60);
				response.addCookie(c2);
				
				return true;	
			}else{
				logUserOutOfSystem(request, response);
				return false;	
				
			}	
		}catch(SQLException sqle){
			System.err.println("UserLoginTool,logUserIntoSystem sql failed: " + sqle.getMessage());		
			return false;
		}catch(Exception e){
			System.err.println(e.getMessage());		
			e.printStackTrace();
			return false;
		}finally{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}		
		
	}
	public boolean logUserIntoSystem(HttpServletRequest request, HttpServletResponse response, String encryptedId){	
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
		
			String sqlLUID = "SELECT id FROM contacts WHERE MD5(id) = ?";
			PreparedStatement psLUID = conn.prepareStatement(sqlLUID);
			psLUID.clearParameters();
			psLUID.setString(1,encryptedId);
						
			ResultSet rsLUID = psLUID.executeQuery();
			
			if(rsLUID.next()){
				return logUserIntoSystem(request, response, rsLUID.getInt("id"));
			}else{
				return false;
			}
			
			
			
		}catch(SQLException sqle){
			System.err.println("UserLoginTool,logUserIntoSystem(encrypted version) sql failed: " + sqle.getMessage());		
			return false;
		}catch(Exception e){
			System.err.println(e.getMessage());		
			e.printStackTrace();
			return false;
		}finally{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}		
	}
	
	public void logUserOutOfSystem(HttpServletRequest request, HttpServletResponse response){
		//remove user specific information
		request.getSession().removeAttribute("contactId");
		request.getSession().removeAttribute("companyId");
		request.getSession().removeAttribute("email");
		request.getSession().removeAttribute("UserFullName");	
		
		//remove session 
		// shut down for now, reevaluate if need:  request.getSession().invalidate();

		Cookie c1 =new Cookie("contactId",null);
		//c1.setVersion(1);
		c1.setPath("/");
		c1.setComment("ask Tom");
		c1.setMaxAge(0);
		response.addCookie(c1);
		
		//set login cookie for users return to site after leaving
		Cookie c2 =new Cookie("qwerty",null);
		c2.setPath("/");
		c2.setComment("ask Tom");
		c2.setMaxAge(0);
		response.addCookie(c2);		
	}
	public boolean validateNameAndPasswordAndLogin(HttpServletRequest request, HttpServletResponse response){
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
				
			String sql1 = "SELECT contact_id FROM logins WHERE user_name = ? AND user_password = md5(?)";
			PreparedStatement selectLogin = conn.prepareStatement(sql1);
				
			selectLogin.setString(1,request.getParameter("userName"));
			selectLogin.setString(2,request.getParameter("password"));
			ResultSet rs1 = selectLogin.executeQuery();
		
			if(rs1.next()){
				logUserIntoSystem(request,response,rs1.getInt(1));    //set contactid for logging in user.
				return true;
			}else{
				logUserOutOfSystem(request,response);
				return false;
			}
		} catch(SQLException sqle){
			System.err.println("validateNameAndPasswordAndLogin sqle error: " + sqle.getMessage());
			return false;		
		} catch(Exception e){
			System.err.println(e.getMessage());			
			return false;		
		}finally{
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}		
	}
}
