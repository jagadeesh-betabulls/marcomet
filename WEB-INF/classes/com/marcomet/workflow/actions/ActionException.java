package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This Class is used to isolate errors that occure withing the
				workflow/actions package, this allows the reloading of the 
				submission page with errors.

History:
	Date		Author			Description
	----		------			-----------
	5/11/01		td				created
	
**********************************************************************/

public class ActionException extends Exception {

	public ActionException(){
		super();
	}
	public ActionException(String msg){
		super(msg);
	}
}
