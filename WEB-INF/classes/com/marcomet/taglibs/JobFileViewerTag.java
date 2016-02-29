package com.marcomet.taglibs;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;

import java.util.Hashtable;
import java.text.DecimalFormat;
import javax.servlet.jsp.tagext.*;
import com.marcomet.jdbc.*;

public class JobFileViewerTag extends TagSupport {

	private String jobId = null;

	public final StringBuffer buildCompHeader() {

		StringBuffer header = new StringBuffer();
		
		header.append("  <tr>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">&nbsp;File Name</div></td>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">File Size</div></td>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">Uploaded By</div></td>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">Upload Date</div></td>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">File Description</div></td>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">Apprvl Status</div></td>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">Submittal Comments</div></td>\n");
		header.append("    <td class=\"minderheader\"><div align=\"left\">Approval Comments</div></td>\n");
		header.append("  </tr>\n");

		return header;
	}
	public final StringBuffer buildHeader(String title) {

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
		header.append("    <td class=\"minderheader\">&nbsp;</td>\n");
		header.append("    <td class=\"minderheader\">&nbsp;</td>\n");
		header.append("    <td class=\"minderheader\">&nbsp;</td>\n");
		header.append("  </tr>\n");

		return header;
	}
	public final int doEndTag() throws JspException {


		Connection conn = null;

		try {

			conn = DBConnect.getConnection();
			StringBuffer production = new StringBuffer();
			StringBuffer working = new StringBuffer();
			StringBuffer comp = new StringBuffer();

			production = this.buildHeader("Final Production Files:");
			working = this.buildHeader("Working Files:");

			boolean printProduction = false;
			boolean printWorking = false;
			boolean printComp = false;
			
			String query = "select fmd.id, file_name, fmd.company_id as companyid, file_size, description, comments, category, status, DATE_FORMAT(creation_date,'%m/%d/%y') as creation_date, firstname, lastname, job_id, project_id, group_id from file_meta_data fmd, contacts c where c.companyid = fmd.company_id and job_id = " + jobId + " order by category desc, creation_date desc";
			Statement st0 = conn.createStatement();
			Statement st1 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query);
			ResultSet rs1;

			int i = 0;
			String category = "";
			String approvalDate = "";
			String submittalDate = "";
			String submittalComments = "";
			String approvalComments = "";
			Hashtable groupIds = new Hashtable();
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
				
				category = rs0.getString("category");
				
				if (category.equals("Final")) {
					production.append("  <tr>\n");
					production.append("    <td class=\"lineitem\">&nbsp;<a href=\"javascript:pop(/transfers/").append(rs0.getString("companyid")).append("/").append(rs0.getString("file_name")).append("',300,300)\" >").append(rs0.getString("file_name")).append("</a></td>");
					production.append("    <td class=\"lineitem\">").append(rs0.getString("file_name")).append("</td>\n");
					production.append("    <td class=\"lineitem\">").append(formattedFileSize).append(" ").append(tag).append("</td>\n");
					production.append("    <td class=\"lineitem\">").append(rs0.getString("lastname")).append(", ").append(rs0.getString("firstname")).append("</td>\n");
					production.append("    <td class=\"lineitem\">").append(rs0.getString("creation_date")).append("</td>\n");
					production.append("    <td class=\"lineitem\">").append(rs0.getString("description")).append("</td>\n");
					production.append("  </tr>\n");

					printProduction = true;
				} else if (category.equals("Working")) {
					working.append("  <tr>\n");
					working.append("    <td class=\"lineitem\">&nbsp;<a href=\"javascript:pop('/transfers/").append(rs0.getString("companyid")).append("/").append(rs0.getString("file_name")).append("',300,300)\" >").append(rs0.getString("file_name")).append("</a></td>");
					working.append("    <td class=\"lineitem\">").append(formattedFileSize).append(" ").append(tag).append("</td>\n");
					working.append("    <td class=\"lineitem\">").append(rs0.getString("lastname")).append(", ").append(rs0.getString("firstname")).append("</td>\n");
					working.append("    <td class=\"lineitem\">").append(rs0.getString("creation_date")).append("</td>\n");
					working.append("    <td class=\"lineitem\">").append(rs0.getString("description")).append("</td>\n");
					working.append("  </tr>\n");

					printWorking = true;
				} else if (category.equals("Comp")) {
					groupId = rs0.getString("group_id");
					String tempGroupId = (String)groupIds.get(groupId);

					if (i == 0 && tempGroupId == null) {
						comp.append("  <tr>\n");
						comp.append("    <td>&nbsp;</td>\n");
						comp.append("  </tr>\n");
						comp.append("  <tr>\n");
						comp.append("    <td colspan=\"8\" class=\"contentstitle\">Comp Files:\n");
						comp.append("      <hr size=1>\n");
						comp.append("    </td>\n");
						comp.append("  </tr>\n");
					}
					
					if (i > 0 && tempGroupId == null) {
						comp.append("  <tr>\n");
						comp.append("    <td>&nbsp;</td>\n");
						comp.append("  </tr>\n");
						comp.append("  <tr>\n");
						comp.append("    <td colspan=\"3\"><b>Responded On:</b>  ").append(approvalDate).append("</td>\n");
						comp.append("  </tr>\n");
						comp.append("  <tr>\n");
						comp.append("    <td colspan=\"3\"><b>General Approval Comments:</b>  ").append(approvalComments).append("</td>\n");
						comp.append("  </tr>\n");
						comp.append("  <tr>\n");
						comp.append("    <td>&nbsp;</td>\n");
						comp.append("  </tr>\n");
						comp.append("  <tr>\n");
						comp.append("    <td colspan=\"8\"><hr size=1></td>\n");
						comp.append("  </tr>\n");
						comp.append("  <tr>\n");
						comp.append("    <td>&nbsp;</td>\n");
						comp.append("  </tr>\n");
						approvalDate = "";
						approvalComments = "";
					}
					
					if (tempGroupId == null) {
						groupIds.put(groupId, groupId);
						rs1 = st1.executeQuery("select message, form_id, DATE_FORMAT(time_stamp,'%m/%d/%y') as creation_date from form_messages where group_id = " + groupId + " order by form_id");
						while (rs1.next()) {
							if (rs1.getString("form_id").equals("1")) {
								submittalComments = rs1.getString("message");
								submittalDate = rs1.getString("creation_date");
							} else if (rs1.getString("form_id").equals("8")) {
								approvalComments = rs1.getString("message");
								approvalDate = rs1.getString("creation_date");	
							}
						}
						if (rs0.getString("status").equals("Submitted")) {
								approvalComments = "<b>Pending</b>";
						}
					}
					
					if (tempGroupId == null && i == 0) {
						comp.append("  <tr>\n");
						comp.append("    <td colspan=\"3\"><b>Submitted On:</b>  ").append(submittalDate).append("</td>\n");
						comp.append("  </tr>\n");
						comp.append("  <tr>\n");
						comp.append("    <td colspan=\"3\"><b>General Submittal Comments:</b>  ").append(submittalComments).append("</td>\n");
						comp.append("  </tr>\n");
						comp.append("  <tr>\n");
						comp.append("    <td>&nbsp;</td>\n");
						comp.append("  </tr>\n");
						comp.append(this.buildCompHeader());
						submittalDate = "";
						submittalComments = "";
					}

					if (i > 0 && tempGroupId == null) {
						comp.append("  <tr>\n");
						comp.append("    <td colspan=\"3\"><b>Submitted On:</b>  ").append(submittalDate).append("</td>\n");
						comp.append("  </tr>\n");
						comp.append("  <tr>\n");
						comp.append("    <td colspan=\"3\"><b>General Submittal Comments:</b>  ").append(submittalComments).append("</td>\n");
						comp.append("  </tr>\n");
						comp.append("  <tr>\n");
						comp.append("    <td>&nbsp;</td>\n");
						comp.append("  </tr>\n");
						comp.append(this.buildCompHeader());
						submittalDate = "";
						submittalComments = "";
					}
					
					comp.append("  <tr>\n");
					comp.append("    <td class=\"lineitem\">&nbsp;<a href=\"javascript:pop('/transfers/").append(rs0.getString("companyid")).append("/").append(rs0.getString("file_name")).append("',300,300)\" >").append(rs0.getString("file_name")).append("</a></td>");
					comp.append("    <td class=\"lineitem\">").append(formattedFileSize).append(" ").append(tag).append("</td>\n");
					comp.append("    <td class=\"lineitem\">").append(rs0.getString("lastname")).append(", ").append(rs0.getString("firstname")).append("</td>\n");
					comp.append("    <td class=\"lineitem\">").append(rs0.getString("creation_date")).append("</td>\n");
					comp.append("    <td class=\"lineitem\">").append(rs0.getString("description")).append("</td>\n");
					comp.append("    <td class=\"lineitem\">").append(rs0.getString("status")).append("</td>\n");
					comp.append("    <td class=\"lineitem\">n/a</td>\n");
					String comments = "";
					if (rs0.getString("comments") == null) {
						comments = "";
					} else {
						comments = rs0.getString("comments");
					}
					comp.append("    <td class=\"lineitem\">").append(comments).append("</td>\n");
					comp.append("  </tr>\n");

					printComp = true;
					i++;
				}

			}

			if (printComp) {
				comp.append("  <tr>\n");
				comp.append("    <td>&nbsp;</td>\n");
				comp.append("  </tr>\n");
				comp.append("  <tr>\n");
				comp.append("    <td colspan=\"3\"><b>Responded On:</b>  ").append(approvalDate).append("</td>\n");
				comp.append("  </tr>\n");
				comp.append("  <tr>\n");
				comp.append("    <td colspan=\"3\"><b>General Approval Comments:</b>  ").append(approvalComments).append("</td>\n");
				comp.append("  </tr>\n");
				comp.append("  <tr>\n");
				comp.append("    <td>&nbsp;</td>\n");
				comp.append("  </tr>\n");
				comp.append("  <tr>\n");
				comp.append("    <td colspan=\"8\"><hr size=1></td>\n");
				comp.append("  </tr>\n");
			}
			
			StringBuffer output = new StringBuffer();

			output.append("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">\n");
			if (!printProduction && !printWorking && !printComp) {
				output.append("  <tr>\n");
				output.append("    <td class=\"contentstitle\"><div align=\"center\">There Are No Files Associated With This Job.</div></td>\n");
				output.append("  </tr>\n");
			} else {
				if (printProduction) {
					production.append("  <tr>\n");
					production.append("    <td>&nbsp;</td>\n");
					production.append("  </tr>\n");
					production.append("  <tr>\n");
					production.append("    <td>&nbsp;</td>\n");
					production.append("  </tr>\n");
					output.append(production);
				}
				if (printWorking) {
					working.append("  <tr>\n");
					working.append("    <td>&nbsp;</td>\n");
					working.append("  </tr>\n");
					working.append("  <tr>\n");
					working.append("    <td>&nbsp;</td>\n");
					working.append("  </tr>\n");
					output.append(working);
				}
				if (printComp) {
					comp.append("  <tr>\n");
					comp.append("    <td>&nbsp;</td>\n");
					comp.append("  </tr>\n");
					comp.append("  <tr>\n");
					comp.append("    <td>&nbsp;</td>\n");
					comp.append("  </tr>\n");
					output.append(comp);
				}
			}
			output.append("</table>");
			
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
	public final void release() {
		super.release();
	}
	public final void setJobId(String jobId) {
		this.jobId = jobId;
	}
}
