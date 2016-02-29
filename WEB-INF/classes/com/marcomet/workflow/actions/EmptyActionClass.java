package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This Class handles the blank classes in the table for later. 

History:
	Date		Author			Description
	----		------			-----------
	4/16/01		Tom dietrich	created
	
**********************************************************************/

import java.util.*;
import javax.servlet.http.*;
import com.marcomet.files.MultipartRequest;

public class EmptyActionClass implements ActionInterface{

	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception {
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		return new Hashtable();
	}
}
