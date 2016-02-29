package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This Class handles the submittion of a proposed job 
				change. 
**********************************************************************/

import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.marcomet.commonprocesses.ProcessJobChange;
import com.marcomet.files.MultipartRequest;


public class SubmitProposedJobChange implements ActionInterface{

	public SubmitProposedJobChange() {
	}
	public Hashtable execute(MultipartRequest mr, HttpServletResponse res) throws Exception {
		return new Hashtable();
	}
	public Hashtable execute(HttpServletRequest req, HttpServletResponse res) 
	throws Exception{
		ProcessJobChange pjc = new ProcessJobChange();
		
		pjc.setJobId(Integer.parseInt(req.getParameter("jobId")));
		pjc.setCreatedById(Integer.parseInt(req.getParameter("contactId")));
		pjc.setChangeTypeId((req.getParameter("changeTypeId").equals(""))?0:Integer.parseInt(req.getParameter("changeTypeId")));				
		pjc.setReason(req.getParameter("proposedChangeReason"));
		pjc.setCost((req.getParameter("cost").equals(""))?0:Double.parseDouble(req.getParameter("cost")));
		pjc.setMu((req.getParameter("mu").equals(""))?0:Double.parseDouble(req.getParameter("mu")));
		pjc.setFee((req.getParameter("fee").equals(""))?0:Double.parseDouble(req.getParameter("fee")));
		pjc.setPrice((req.getParameter("price").equals(""))?0:Double.parseDouble(req.getParameter("price")));
		pjc.setStatusId(1);
		pjc.insertJobChange();
		
		return new Hashtable();
			
	}
}
