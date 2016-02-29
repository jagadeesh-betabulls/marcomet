/**********************************************************************
Description:	This Class will holds and organize user specific information.
**********************************************************************/

package com.marcomet.environment;

import com.marcomet.users.security.PropertySites;
import com.marcomet.users.security.RoleResolver;

public class UserProfile{

	private String userFullName;
	private String contactId;
	private String companyId;
	private String siteNumber;
	private String taxId;
	private String defaultWebsite;
	private RoleResolver roles;
	private PropertySites properties;
	
	public UserProfile(){
	}
	
	public UserProfile(String userFullName, String contactId, String companyId, RoleResolver roles,PropertySites properties){
		this.userFullName = userFullName;
		this.contactId = contactId;
		this.companyId = companyId;
		this.roles = roles;	
		this.properties=properties;
	}

	public final void setUserFullName(String temp){
		userFullName = temp;	
	}
	public final String getUserFullName(){
		return userFullName;
	}	

	public final void setContactId(String temp){
		contactId = temp;	
	}
	public final String getContactId(){
		return contactId;
	}		

	public final void setCompanyId(String temp){
		companyId = temp;	
	}
	public final String getCompanyId(){
		return companyId;
	}		

	public final void setRoles(RoleResolver temp){
		roles = temp;		
	}	
	public final RoleResolver getRoles(){
		return roles;
	}	
	
	public final void setProperties(PropertySites temp){
		properties = temp;		
	}	
	public final PropertySites getProperties(){
		return properties;
	}

	public String getSiteNumber() {
		return siteNumber;
	}

	public void setSiteNumber(String siteNumber) {
		this.siteNumber = siteNumber;
	}

	public String getTaxId() {
		return taxId;
	}

	public void setTaxId(String taxId) {
		this.taxId = taxId;
	}

	public String getDefaultWebsite() {
		return defaultWebsite;
	}

	public void setDefaultWebsite(String defaultWebsite) {
		this.defaultWebsite = defaultWebsite;
	}	

}