package com.marcomet.workflow.actions;

/**********************************************************************
Description:	This class will update the status of a job
**********************************************************************/

import java.util.Hashtable;

import javax.servlet.http.HttpServletResponse;

import com.marcomet.files.MultipartRequest;

public class MultipartMoveStatus extends AbstractMoveStatus implements ActionInterface {

	public Hashtable execute(MultipartRequest mr, HttpServletResponse response) {

		int jobId = Integer.parseInt(mr.getParameter("nextStepJobId"));
		int actionId = 0;

		try {
			int approvalType = Integer.parseInt(mr.getParameter("approvalType"));

			if (approvalType == 1) {
				// SmallBizPromoter has caused me to hard code this value.  I shall toil in the plight
				// of my botchery like all the hard coders before me....
				actionId = 21;
			} else if (approvalType == 2) {
				actionId = 11;
			}
		} catch (Exception ex) {
		}
		

		Hashtable hash = null;
		try {
			if (actionId == 0) {
				hash = super.execute(mr, response);
			} else {
				super.updateStatus(jobId, actionId);
			}
		} catch(Exception ex) {
		}

		if (hash == null) {
			return new Hashtable();
		} else {
			return hash;
		}

	}
}
