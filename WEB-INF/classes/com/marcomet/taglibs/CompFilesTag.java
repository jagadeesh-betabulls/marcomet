package com.marcomet.taglibs;

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.jsp.*;
import java.text.DecimalFormat;
import javax.servlet.jsp.tagext.*;
import com.marcomet.jdbc.*;

public class CompFilesTag extends TagSupport {

	private String jobId = "";

	private class DigitalFileObject {

		private int companyId;
		private double fileSize;
		private String fileName, description, comments, reply, status, creationDate, firstName, lastName;

		public DigitalFileObject(String fileName, int companyId, double fileSize, String description, String comments, String reply, String status, String creationDate, String firstName, String lastName) {
			this.fileName = fileName;
			this.companyId = companyId;
			this.fileSize = fileSize;
			this.description = description;
			this.comments =comments;
			this.reply = reply;
			this.status = status;
			this.creationDate = creationDate;
			this.firstName = firstName;
			this.lastName = lastName;
		}

		public final String getFileName() {
			return fileName;
		}

		public final int getCompanyId() {
			return companyId;
		}

		public final double getFileSize() {
			return fileSize;
		}

		public final String getFormattedFileSize() {

			String tag = "bytes";
			if (fileSize > 1024*1024) {
				fileSize = fileSize / (1024*1024);
				tag = "Mb";
			} else if (fileSize > 1024) {
				fileSize = fileSize / 1024;
				tag = "Kb";
			}
				
			DecimalFormat precisionTwo = new DecimalFormat("0.##");
			String formattedFileSize = precisionTwo.format(fileSize);

			return formattedFileSize + " " + tag;

		}

		public final String getDescription() {
			return ((description==null || description.equals(""))?"&nbsp;":description);
		}

		public final String getComments() {
			return ((comments==null || comments.equals(""))?"&nbsp;":comments);			
		}

		public final String getReply() {
			return ((reply==null || reply.equals(""))?"&nbsp;":reply);				
		}

		public final String getStatus() {
			return status;
		}

		public final String getCreationDate() {
			return creationDate;
		}

		public final String getFirstName() {
			return firstName;
		}

		public final String getLastName() {
			return lastName;
		}

	}

	private class PhysicalFileObject {

		private String fileName, description, comments, reply, status, creationDate, firstName, lastName;

		public PhysicalFileObject(String fileName, String description, String comments, String reply, String status, String creationDate, String firstName, String lastName) {
			this.fileName = fileName;
			this.description = description;
			this.comments =comments;
			this.reply = reply;
			this.status = status;
			this.creationDate = creationDate;
			this.firstName = firstName;
			this.lastName = lastName;
		}

		public final String getFileName() {
			return fileName;
		}

		public final String getDescription() {
			return description;
		}

		public final String getComments() {
			return comments;
		}

		public final String getReply() {
			return reply;
		}

		public final String getStatus() {
			return status;
		}

		public final String getCreationDate() {
			return creationDate;
		}

		public final String getFirstName() {
			return firstName;
		}

		public final String getLastName() {
			return lastName;
		}


	}

	private class CompObject {

		private String submittalComment = "";
		private String submittalDate = "";
		private String approvalComment = "";
		private String approvalDate = "";
		private Vector dfoVector;
		private Vector pfoVector;

		public CompObject() {
			dfoVector = new Vector();
			pfoVector = new Vector();
		}

		public final void addDfo(DigitalFileObject dfo) {
			dfoVector.addElement(dfo);
		}

		public final void addPfo(PhysicalFileObject pfo) {
			pfoVector.addElement(pfo);
		}

		public final void setSubmittalComment(String submittalComment) {
			this.submittalComment = submittalComment;
		}

		public final void setSubmittalDate(String submittalDate) {
			this.submittalDate = submittalDate;
		}

		public final void setApprovalComment(String approvalComment) {
			this.approvalComment = approvalComment;
		}

		public final void setApprovalDate(String approvalDate) {
			this.approvalDate = approvalDate;
		}

		public final StringBuffer buildCompHeader() {
			StringBuffer header = new StringBuffer();

			header.append("<table border=\"0\" cellpadding=\"3\" cellspacing=\"0\" width=\"100%\" bordercolor=\"#000000\" style=\"border-top:1 solid Black;border-bottom:1 solid Black;border-left:1 solid Black;border-right:1 solid Black;\">\n");
			header.append("  <tr>\n");
			header.append("    <td class=\"minderheaderleft\"><div align=\"left\">&nbsp;File Name</div></td>\n");
			header.append("    <td class=\"minderheaderleft\"><div align=\"left\">File Size</div></td>\n");
			header.append("    <td class=\"minderheaderleft\"><div align=\"left\">Uploaded By</div></td>\n");
			header.append("    <td class=\"minderheaderleft\"><div align=\"left\">Upload Date</div></td>\n");
			header.append("    <td class=\"minderheaderleft\"><div align=\"left\">File Description</div></td>\n");
			header.append("    <td class=\"minderheaderleft\"><div align=\"left\">Apprvl Status</div></td>\n");
			header.append("    <td class=\"minderheaderleft\"><div align=\"left\">Submittal Comments</div></td>\n");
			header.append("    <td class=\"minderheaderleft\"><div align=\"left\">Approval Comments</div></td>\n");
			header.append("  </tr>\n");

			return header;
		}

		public final StringBuffer returnContents() {

			StringBuffer compOutput = new StringBuffer();
			boolean alt = true;

			compOutput.append("<table  width=\"100%\">\n");
			compOutput.append("  <tr>\n");
			compOutput.append("    <td colspan=\"4\" width=\"35%\"><SPAN class=subtitle1>Work Submittal:</SPAN>&nbsp;&nbsp;<SPAN  class=\"body\">").append(submittalDate).append("</span></td>\n");
			compOutput.append("    <td colspan=\"4\" width=\"55%\"><SPAN class=subtitle1>Comments:</span>  ").append(submittalComment).append("</td>\n");
			compOutput.append("  </tr>\n");
			compOutput.append("  <tr>\n");
			compOutput.append("</table>\n");
			
			compOutput.append(this.buildCompHeader());

			for (Enumeration dfos = dfoVector.elements(); dfos.hasMoreElements(); ) {
				alt = (alt)?false:true;
				DigitalFileObject dfo = (DigitalFileObject)dfos.nextElement();
				compOutput.append("  <tr>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"15%\">&nbsp;<a class=\"minderLink\" href=\"javascript:pop('/transfers/").append(dfo.getCompanyId()).append("/").append(dfo.getFileName()).append("',300,300)\" >").append(dfo.getFileName()).append("</a></td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"10%\">").append(dfo.getFormattedFileSize()).append("</td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"10%\">").append(dfo.getLastName()).append(", ").append(dfo.getFirstName()).append("</td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"10%\"><p align=\"right\">").append(dfo.getCreationDate()).append("</p></td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"15%\">").append(dfo.getDescription()).append("</td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"10%\">").append(dfo.getStatus()).append("</td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"15%\">").append(dfo.getComments()).append("</td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"15%\">").append(dfo.getReply()).append("</td>\n");
				compOutput.append("  </tr>\n");
			}

			for (Enumeration pfos = pfoVector.elements(); pfos.hasMoreElements(); ) {
				alt = (alt)?false:true;
				PhysicalFileObject pfo = (PhysicalFileObject)pfos.nextElement();
				compOutput.append("  <tr>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"15%\">&nbsp;").append(pfo.getFileName()).append("</a></td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"10%\">Shipped Item</td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"10%\">").append(pfo.getLastName()).append(", ").append(pfo.getFirstName()).append("</td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"10%\"><p align=\"right\">").append(pfo.getCreationDate()).append("</p></td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"15%\">").append(pfo.getDescription()).append("</td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"10%\">").append(pfo.getStatus()).append("</td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"15%\">").append(pfo.getComments()).append("</td>\n");
				compOutput.append("    <td class=\"lineitem").append((alt)?"alt":"").append("\" width=\"15%\">").append(pfo.getReply()).append("</td>\n");
				compOutput.append("  </tr>\n");
			}

			compOutput.append("</table>\n");
			compOutput.append("<table width=\"100%\">\n");
			compOutput.append("  <tr>\n");
			compOutput.append("    <td colspan=\"4\" width=\"35%\" class=\"body\"><b>Responded On:</b>&nbsp;&nbsp;"+approvalDate+"</td>");
			compOutput.append("    <td colspan=\"4\" width=\"55%\" class=\"body\"><b>Comments:</b>  ").append(approvalComment).append("</td>\n");
			compOutput.append("  </tr>\n");
			compOutput.append("</table>\n");
			compOutput.append("<hr size=1>\n");

			return compOutput;
		}
	}

	public final StringBuffer assembleOutput(Hashtable compsByGroupId) {

		StringBuffer output = new StringBuffer();
		Enumeration groupIds = compsByGroupId.keys();

		if (compsByGroupId.size() > 0) {

			output.append("<P><SPAN class=offeringTITLE>Files for Approval:</SPAN> <SPAN class=body>These files represent work submitted for Client approval during the course of the job. Each approval section contains the files, approvals, and comments submitted by all parties as a history of the approval process. Note: Many file types (.jpg, .pdf, etc.) may be viewed online by clicking on their filename. </SPAN></P>");

			for (int i=0; i<compsByGroupId.size(); i++) {
				CompObject co = (CompObject)compsByGroupId.get((String)groupIds.nextElement());
				output.append(co.returnContents());
			}

		}
		
		return output;
	}
	public final int doEndTag() throws JspException {

		Hashtable compsByGroupId = this.extractData();
		StringBuffer output = this.assembleOutput(compsByGroupId);
		try {
			pageContext.getOut().print(output);
		} catch (IOException ex) {
			throw new JspException("doEndTag error: " + ex.getMessage());
		}

		return EVAL_PAGE;
	}
	public final Hashtable extractData() throws JspException {
		
		Connection conn = null; 

		try {			
			conn = DBConnect.getConnection();
			Statement st0 = conn.createStatement();
			Statement st1 = conn.createStatement();
			Statement st2 = conn.createStatement();

			Hashtable compsByGroupId = new Hashtable();
			
			// Grap all of the digital comp files from the database
			String query0 = "SELECT file_name, company_id, file_size, description, comments, reply, status, DATE_FORMAT(creation_date,'%m/%d/%y') AS creation_date, DATE_FORMAT(creation_date,'%m/%d/%y %h:%m:%s') AS comp_date, firstname, lastname, group_id FROM file_meta_data fmd, contacts c WHERE c.id = fmd.user_id AND category = 'For Appvl' AND job_id = " + jobId + " ORDER BY comp_date ASC";
			ResultSet rs0 = st0.executeQuery(query0);
			while (rs0.next()) {
				DigitalFileObject dfo = new DigitalFileObject(rs0.getString("file_name"), rs0.getInt("company_id"), rs0.getDouble("file_size"), rs0.getString("description"), rs0.getString("comments"), rs0.getString("reply"), rs0.getString("status"), rs0.getString("creation_date"), rs0.getString("firstname"), rs0.getString("lastname"));
				String groupId = rs0.getString("group_id");
				CompObject co = (CompObject)compsByGroupId.get(groupId);
				if (co == null) {
					co = new CompObject();
					compsByGroupId.put(groupId, co);
				}
				co.addDfo(dfo);
			}

			// Grab all of the physically shipped files from the database
			String query1 = "SELECT file_name, mmd.description, mmd.comments, reply, mmd.status, DATE_FORMAT(date,'%m/%d/%y') AS creation_date, DATE_FORMAT(date,'%m/%d/%y %h:%m:%s') AS comp_date, firstname, lastname, group_id FROM material_meta_data mmd, shipping_data sd, contacts c WHERE c.id = mmd.user_id AND mmd.shipping_data_id = sd.id AND mmd.job_id = " + jobId + " ORDER BY comp_date ASC";
			ResultSet rs1 = st1.executeQuery(query1);
			while (rs1.next()) {
				PhysicalFileObject pfo = new PhysicalFileObject(rs1.getString("file_name"), rs1.getString("description"), rs1.getString("comments"), rs1.getString("reply"), rs1.getString("status"), rs1.getString("creation_date"), rs1.getString("firstname"), rs1.getString("lastname"));
				String groupId = rs1.getString("group_id");
				CompObject co = (CompObject)compsByGroupId.get(groupId);
				if (co == null) {
					co = new CompObject();
					compsByGroupId.put(groupId, co);
				}
				co.addPfo(pfo);
			}

			// Grab all the dates and messages by groupId and throw em in the appropriate comp object
			for (Enumeration e = compsByGroupId.keys(); e.hasMoreElements(); ) {
				String groupId = (String)e.nextElement();
				CompObject co = (CompObject)compsByGroupId.get(groupId);
				String query2 = "SELECT message, form_id, DATE_FORMAT(time_stamp,'%m/%d/%y') AS creation_date FROM form_messages WHERE group_id = " + groupId + " ORDER BY form_id";
				ResultSet rs2 = st2.executeQuery(query2);
				while (rs2.next()) {
					if ((rs2.getInt("form_id") == 1) || (rs2.getInt("form_id") == 2)) {
						co.setSubmittalComment(rs2.getString("message"));
						co.setSubmittalDate(rs2.getString("creation_date"));
					} else {
						co.setApprovalComment(rs2.getString("message"));
						co.setApprovalDate(rs2.getString("creation_date"));
					}
				}
			}

			return compsByGroupId;

		} catch (SQLException ex) {
			throw new JspException(ex.getMessage());
		} catch (Exception x) {
			throw new JspException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

	}
	public final void setJobId(String jobId) {
		this.jobId = jobId;
	}
}
