/**********************************************************************
Description:	This Class will crash any calles to the Login Attribute
				this class has no purpose after Login attribut has been
				removed from session.

History:
	Date		Author			Description
	----		------			-----------
	9/5/01		td				created
	
**********************************************************************/

package com.marcomet.tools;


public class LoginBreakerClass{

	public String toString(){
		int xx = 1;
		System.out.println("error in LoginBreakerClass");
		int yy = 0/xx;
	
		return "boob";
	}


}