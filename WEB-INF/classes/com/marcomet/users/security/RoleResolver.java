/**********************************************************************
Description:	This class is used for for testing a person's roles.

History:
	Date		Author			Description
	----		------			-----------
	7/17/01		Thomas Dietrich	Created
	7/18/01 	tom dietrich	added search functions
	?/??/??		??????			added roleCheckRedirect(String rolename,String redirectPage)
	10/15/01	td				changed functions to final modifier
	
**********************************************************************/

package com.marcomet.users.security;

import java.util.*;

public class RoleResolver{

	private Hashtable roles;

	public RoleResolver(){
		roles = new Hashtable();
	}
	public RoleResolver(Hashtable temp){
		roles = temp;
	}
	public final void addRole(String temp){
		roles.put(temp, "");
	}
	public final boolean isBuyer(){
		return roles.containsKey("buyer");		
	}
	public final boolean isSiteHost(){
		return roles.containsKey("site host");
	}
	public final boolean isVendor(){
		return roles.containsKey("vendor");
	}
	public final boolean roleCheck(String rolename){
		return roles.containsKey(rolename);
	}

	
	public final String roleCheckRedirect(String rolename,String redirectPage){
		String redirectString="";
		if (!roles.containsKey(rolename)){
			redirectString="<script language = javascript> window.location.replace(\""+redirectPage+"\")";
			redirectString+="</script>";			
		}
		return redirectString;
	}	
	
}
