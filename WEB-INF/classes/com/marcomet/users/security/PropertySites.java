/**********************************************************************
Description:	This class is used for storing the property site(s) a person 
				is related to.
**********************************************************************/

package com.marcomet.users.security;

import java.util.*;

public class PropertySites{

	private Hashtable<String, String> properties;

	public PropertySites(){
		properties = new Hashtable<String, String>();
	}
	@SuppressWarnings("unchecked")
	public PropertySites(Hashtable temp){
		properties = temp;
	}
	public final void addSite(String temp){
		properties.put(temp, "");
	}
	public final boolean propertyCheck(String propId){
		return properties.containsKey(propId);
	}
	
}
