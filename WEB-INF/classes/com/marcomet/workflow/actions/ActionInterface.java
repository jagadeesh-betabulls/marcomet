package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This Class handles the dynamic calling of classes. 

History:
	Date		Author			Description
	----		------			-----------
	4/12/01		Tom dietrich	created
	4/16/01		Brian			Added method to handle multipart requests
	
**********************************************************************/


import java.util.*;
import javax.servlet.http.*;
import com.marcomet.files.MultipartRequest;

public interface ActionInterface{

	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) throws Exception;
	public Hashtable execute(HttpServletRequest request, HttpServletResponse response) throws Exception;
}
