package com.marcomet.taglibs;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;

import java.util.Hashtable;
import java.text.DecimalFormat;
import javax.servlet.jsp.tagext.*;
import com.marcomet.jdbc.*;


public class WorkingFilesTag extends TagSupport {

	private String jobId = null;

	public final StringBuffer buildWorkingHeader(String title) {

		StringBuffer header = new StringBuffer();
		
		header.append("  <tr>\n");
		header.append("    <td colspan=\"5\" class=\"contentstitle\">" + title + "</td>\n");
		header.append("  </tr>\n");
		header.append("  <tr>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">&nbsp;File Name</div></td>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">File Size</div></td>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">Uploaded By</div></td>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">Upload Date</div></td>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">File Description</div></td>\n");
		header.append("  </tr>\n");

		return header;
	}
	public final int doEndTag() throws JspException {

		
		Connection conn = null;

		try {
			conn = DBConnect.getConnection();
			StringBuffer working = new StringBuffer();
			StringBuffer output = new StringBuffer();
			working = this.buildWorkingHeader("Working Files:");

			String query = "select fmd.id, file_name, fmd.company_id as companyid, file_size, description, status, DATE_FORMAT(creation_date,'%m/%d/%y') as creation_date, firstname, lastname, job_id, project_id, group_id from file_meta_data fmd, contacts c where c.id = fmd.user_id and category = 'Working' and job_id = " + jobId + " order by creation_date desc";
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query);
			
			boolean printWorking = false;

			while (rs0.next()) {
				String groupId = "0";
				double fileSize =  rs0.getDouble("file_size");
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

				working.append("  <tr>\n");
				working.append("    <td class=\"lineitem\">&nbsp;<a href=\"javascript:pop('/transfers/").append(rs0.getString("companyid")).append("/").append(rs0.getString("file_name")).append("',300,300)\" >").append(rs0.getString("file_name")).append("</a></td>\n");
				working.append("    <td class=\"lineitem\">").append(formattedFileSize).append(" ").append(tag).append("</td>\n");
				working.append("    <td class=\"lineitem\">").append(rs0.getString("lastname")).append(", ").append(rs0.getString("firstname")).append("</td>\n");
				working.append("    <td class=\"lineitem\">").append(rs0.getString("creation_date")).append("</td>\n");
				working.append("    <td class=\"lineitem\">").append(rs0.getString("description")).append("</td>\n");
				working.append("  </tr>\n");

				printWorking = true;
			}

			if (printWorking) {
				output.append("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"66%\">\n");
				
				working.append("  <tr>\n");
				working.append("    <td>&nbsp;</td>\n");
				working.append("  </tr>\n");
				working.append("  <tr>\n");
				working.append("    <td>&nbsp;</td>\n");
				working.append("  </tr>\n");
				working.append("</table>\n");
			
				output.append(working);
			}
			
			pageContext.getOut().print(output);
					
		} catch (IOException ex) {
			throw new JspException(ex.getMessage());
		} catch (SQLException ex) {
			throw new JspException(ex.getMessage());
		} catch (Exception x) {
			throw new JspException(x.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception x) { conn = null; }
		}

		return EVAL_PAGE;
	}
	public final void setJobId(String jobId) {
		this.jobId = jobId;
	}
}
