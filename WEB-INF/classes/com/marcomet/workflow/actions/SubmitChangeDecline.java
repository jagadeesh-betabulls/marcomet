package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will recieve/update db for an declined Job Change.
**********************************************************************/

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessJobChange;
import com.marcomet.files.MultipartRequest;
import com.marcomet.tools.StringTool;


public class SubmitChangeDecline implements ActionInterface{

	public SubmitChangeDecline() {
	}
	public Hashtable execute(MultipartRequest mr, HttpServletResponse res) throws Exception {
		return new Hashtable();	
	}
	public Hashtable execute(HttpServletRequest req, HttpServletResponse res) 
	throws Exception{
		
		ProcessJobChange pjc = new ProcessJobChange();
		StringTool st = new StringTool();
		DateFormat mysqlFormat = new SimpleDateFormat("yyyy-MM-dd");
		
		pjc.setJobId(req.getParameter("jobId"));
		pjc.updateJobChangeJobId("comments",req.getParameter("comments"));
		pjc.updateJobChangeJobId("statusid",3);
		pjc.updateJobChangeJobId("customerdate",mysqlFormat.format(new java.util.Date()));
		pjc.updateJobChangeJobId("customerid",(String)req.getSession().getAttribute("contactId"));
		return new Hashtable();
			
	}
}
