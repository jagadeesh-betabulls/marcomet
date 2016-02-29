package com.marcomet.taglibs;

/**********************************************************************
Description:	This class will a table for the sbpcontents menu.

History:
	Date		Author			Description
	----		------			-----------
	7/16/2001	Thomas Dietrich	Created
	10/23/01	Ed Cimafotne	Modified to reflect needs of enhanced styling and mouseovers

**********************************************************************/

import com.marcomet.jdbc.*;
import com.marcomet.tools.*;

import java.io.*;
import java.sql.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class SiteVendorOfferingsTag extends TagSupport {

	private String siteHostId;
	private String tableWidth = "100%";
	private String cellHeight = "14";

	public final  int doEndTag() throws JspException {
		
		Connection conn = null;
		int x=0;
		try {
			conn = DBConnect.getConnection();
			FormaterTool formater = new FormaterTool();
			String query0 = "SELECT sho.id AS site_host_offering_id, title FROM site_host_offerings sho WHERE active = 1 AND sho.site_host_id = " + siteHostId + " ORDER BY sho.sequence";
			Statement st0 = conn.createStatement();
			ResultSet rs0 = st0.executeQuery(query0);

			StringBuffer output = new StringBuffer("");
			while (rs0.next()){
				output.append("  <tr>\n");
				output.append("    <td class=\"leftNavBarItem\" onMouseover=\"this.className=\'leftNavBarItemOver\';lnk"+(x)+".className='leftNavBarItemHover'\" onMouseout=\"this.className='leftNavBarItem';lnk"+(x)+".className='leftNavBarItem'\" height=\"").append(cellHeight).append("\">\n");
				output.append("      <a href=\"/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogOfferingServlet?siteHostOfferingId=");
				output.append(rs0.getString("site_host_offering_id")).append("\" target=\"_parent\" class=\"leftNavBarItem\"  id='lnk"+(x)+"'>").append(rs0.getString("title")).append("</a>\n");
				output.append("    </td>\n");
				output.append("  </tr>\n");
				x++;
			}
			
			output.append("    <td class=\"leftNavBarTitle\"><br><a href=\"/frames/InnerFrameset.jsp?contents=/catalog/rfq/RFQJobCreationForm.jsp\" target=\"_parent\" class=\"leftNavBartitle\">Custom Quotes &amp; Projects</a>\n");
			output.append("  </tr>\n");
//			output.append("</table");

			pageContext.getOut().print(output);

		} catch (IOException ex) {
			throw new JspException(ex.getMessage());
		} catch (SQLException ex) {
			throw new JspException(ex.getMessage());
		} catch (Exception e) {
			throw new JspException(e.getMessage());
		} finally {
			try { conn.close(); } catch ( Exception cx) { conn = null; }
		}

		return EVAL_PAGE;
	}
	public final  void release() {
		super.release();
	}
	public final  void setCellHeight(String temp) {
		this.cellHeight = temp;
	}
	public final  void setSiteHostId(String temp) {
		this.siteHostId = temp;
	}
	public final  void setTableWidth(String temp) {
		this.tableWidth = temp;
	}
}
