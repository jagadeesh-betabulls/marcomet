<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.marcomet.jdbc.*,java.io.*;" %>
<%
    Connection conn = DBConnect.getConnection();
    Statement st = conn.createStatement();
    String sql = "";

    PrintWriter writer = response.getWriter();

    boolean filter = (request.getParameter("filter") != null && request.getParameter("filter").equals("true")) ? true : false;
    boolean firstPage = false, lastPage = false, success = false;
    int limit1 = (request.getParameter("limit1") != null) ? Integer.parseInt(request.getParameter("limit1")) : 0;
    int limit2 = (request.getParameter("limit2") != null) ? Integer.parseInt(request.getParameter("limit2")) : 50;
    String jobId = request.getParameter("jobId") != null ? request.getParameter("jobId") : "";
    String anyAll = request.getParameter("anyAll") != null ? request.getParameter("anyAll") : "";
    String fromId = request.getParameter("fromId") != null ? request.getParameter("fromId") : "";
    String toId = request.getParameter("toId") != null ? request.getParameter("toId") : "";
    String fromEmailAddress = request.getParameter("fromEmailAddress") != null ? request.getParameter("fromEmailAddress") : "";
    String toEmailAddress = request.getParameter("toEmailAddress") != null ? request.getParameter("toEmailAddress") : "";
    String fromSiteNumber = request.getParameter("fromSiteNumber") != null ? request.getParameter("fromSiteNumber") : "";
    String toSiteNumber = request.getParameter("toSiteNumber") != null ? request.getParameter("toSiteNumber") : "";
    String fromDate = request.getParameter("fromDate") != null ? request.getParameter("fromDate") : "";
    String toDate = request.getParameter("toDate") != null ? request.getParameter("toDate") : "";
    boolean anyFrom = (!fromId.equals("")) || (!fromEmailAddress.equals("")) || (!fromSiteNumber.equals(""));
    boolean anyTo = (!toId.equals("")) || (!toEmailAddress.equals("")) || (!toSiteNumber.equals(""));

    writer.write("<table border=\"1\" cellpadding=\"1\" cellspacing=\"1\">");
    writer.write("<tr><td class=\"minderheaderleft\">&nbsp;JobId</td>");
    writer.write("<td class=\"minderheaderleft\">&nbsp;From</td>");
    writer.write("<td class=\"minderheaderleft\">&nbsp;To</td>");
    writer.write("<td class=\"minderheaderleft\">&nbsp;Subject</td>");
    writer.write("<td class=\"minderheaderleft\">&nbsp;Sent On</td></tr>");

    int totalRows = 0;
    String from = "", to = "", where = "";
    if (filter) {
      if (!jobId.equals("")) {
        from += " esh.email_from_id=c_from.id";
        to += " esh.email_to_id=c_to.id";
        where += " esh.job_id=" + jobId;
      } else {
        // check FROM fields..
        if (!fromId.equals("")) {
          from += " esh.email_from_id=c_from.id AND c_from.id=" + fromId;
        }
        if (!fromEmailAddress.equals("")) {
          if (!from.equals("")) {
            from += " AND";
          }
          from += " c_from.email=esh.email_from AND esh.email_from_id=c_from.id AND c_from.email='" + fromEmailAddress + "'";
        }
        if (!fromSiteNumber.equals("")) {
          if (!from.equals("")) {
            from += " AND";
          }
          from += " esh.email_from_id=c_from.id AND c_from.default_site_number=" + fromSiteNumber;
        }
        if (from.equals("")) {
          from += " esh.email_from_id=c_from.id";
        }

        // check TO fields..
        if (!toId.equals("")) {
          to += " esh.email_to_id=c_to.id AND c_to.id=" + toId;
        }
        if (!toEmailAddress.equals("")) {
          if (!to.equals("")) {
            to += " AND";
          }
          to += " c_to.email=esh.email_to AND esh.email_to_id=c_to.id AND c_to.email='" + toEmailAddress + "'";
        }
        if (!toSiteNumber.equals("")) {
          if (!to.equals("")) {
            to += " AND";
          }
          to += " esh.email_to_id=c_to.id AND c_to.default_site_number=" + toSiteNumber;
        }
        if (to.equals("")) {
          to += " esh.email_to_id=c_to.id";
        }

        // WHERE condition..
        if (anyFrom) {
          where += " c_from.id IS NOT NULL";
        }
        if (anyTo) {
          if (!where.equals("")) {
            if (anyAll.equalsIgnoreCase("ANY")) {
              where += " OR";
            } else if (anyAll.equalsIgnoreCase("ALL")) {
              where += " AND";
            }
          }
          where += " c_to.id IS NOT NULL";
        }
        if (!fromDate.equals("") && !toDate.equals("")) {
          if (!where.equals("")) {
            if (anyAll.equalsIgnoreCase("ANY")) {
              where += " OR";
            } else if (anyAll.equalsIgnoreCase("ALL")) {
              where += " AND";
            }
          }
          where += " (esh.timestamp >= '" + fromDate + "' AND esh.timestamp <= '" + toDate + "')";
        }
      }
      sql = "SELECT esh.id, esh.job_id, esh.email_from, esh.email_to, esh.subject, CONCAT(LEFT(esh.subject,25),IF(LENGTH(esh.subject)>25,'...','')) 'short_subject', REPLACE(esh.body,'\\r','') 'body', esh.attachments, esh.sent, c_to.*, c_from.* FROM email_sent_histories esh LEFT JOIN contacts c_from ON" + from + " LEFT JOIN contacts c_to ON" + to + " WHERE esh.sent<>'0' AND esh.job_id<>0";
      if (where.equals("")) {
        sql += " LIMIT " + limit1 + "," + limit2;
      } else {
        sql += " AND (" + where + ") LIMIT " + limit1 + "," + limit2;
      }
    } else {
      sql = "SELECT esh.id, esh.job_id, esh.email_from, esh.email_to, esh.subject, CONCAT(LEFT(esh.subject,25),IF(LENGTH(esh.subject)>25,'...','')) 'short_subject', REPLACE(esh.body,'\\r','') 'body', esh.attachments, esh.sent, c_to.*, c_from.* FROM email_sent_histories esh LEFT JOIN contacts c_from ON esh.email_from_id=c_from.id LEFT JOIN contacts c_to ON esh.email_to_id=c_to.id WHERE esh.sent<>'0' AND esh.job_id<>0 LIMIT " + limit1 + "," + limit2;
    }

    ResultSet rs1 = st.executeQuery(sql);
    while (rs1.next()) {
      success = true;
      boolean hasAttachment = false;
      String attach = rs1.getString("attachments");
      String[] attachments = null, attachFile = null, attachPath = null;
      String attachment = "";
      //String attachment = "";
      if (attach != null && !(attach.equals(""))) {
        hasAttachment = true;
        attachments = attach.split(",");
        attachFile = new String[attachments.length];
        attachPath = new String[attachments.length];
        for (int i = 0; i < attachments.length; i++) {
          attachPath[i] = attachments[i].substring(attachments[i].indexOf("/transfers"), attachments[i].lastIndexOf("/") + 1);
          attachFile[i] = attachments[i].substring(attachments[i].lastIndexOf("/") + 1, attachments[i].length());
          //if (i > 0) {
          //  attachment += ", ";
          //}
          //attachment += attachFile[i];
          if (i > 0) {
            attachment += ", ";
          }
          attachment += "<a href=\\\'" + attachPath[i] + attachFile[i] + "\\\' target=\\\'_blank\\\'>" + attachFile[i] + "</a>";
        }
      }
      //String jbId = "<a href=\\\'/popups/JobDetailsPage.jsp?jobId=" + Integer.parseInt(rs1.getString("job_id")) + "\\\' target=\\\'_blank\\\'" + Integer.parseInt(rs1.getString("job_id")) + "</a>";
      //String jbId = "<a href=\\\'/popups/JobDetailsPage.jsp?jobId=" + Integer.parseInt(rs1.getString("job_id")) + "\\\' target=\\\'_blank\\\'>" + Integer.parseInt(rs1.getString("job_id")) + "</a>";

      writer.write("<tr><td height=\"2\" align=\"left\">&nbsp;" + Integer.parseInt(rs1.getString("job_id")) + "</td>");
      writer.write("<td height=\"2\" align=\"left\">&nbsp;" + rs1.getString("email_from") + "</td>");
      writer.write("<td height=\"2\" align=\"left\">&nbsp;" + rs1.getString("email_to") + "</td>");
      writer.write("<td height=\"2\" align=\"left\"><a href=\"#\" onclick=\"AjaxModalBox.open($(\'divEmailDetail\'), {title: \'Email Detail\', width: 1000, height: 500}); document.getElementById(\'emailSubject\').innerHTML = \'" + rs1.getString("subject") + "\'; document.getElementById(\'emailFrom\').innerHTML = \'" + rs1.getString("email_from") + "\'; document.getElementById(\'emailTo\').innerHTML = \'" + rs1.getString("email_to") + "\'; document.getElementById(\'emailSent\').innerHTML = \'" + rs1.getString("sent") + "\'; document.getElementById(\'emailJob\').href = \'/popups/JobDetailsPage.jsp?jobId=" + Integer.parseInt(rs1.getString("job_id")) + "\'; document.getElementById(\'emailJob\').innerHTML = \'" + Integer.parseInt(rs1.getString("job_id")) + "\'; if(" + hasAttachment + "){document.getElementById(\'emailAttachment\').innerHTML = \'" + attachment + "\';} else{document.getElementById('emailAttachment').innerHTML = \'\';} document.getElementById(\'emailBody\').innerHTML = \'" + rs1.getString("body").toString().replace("\n", "").replace("\'", "").replace("\"", "\\\'") + "\';\">&nbsp;" + rs1.getString("short_subject") + "</a></td>");
      writer.write("<td height=\"2\" align=\"left\">&nbsp;" + rs1.getString("sent") + "</td></tr>");
    }
    rs1.close();
    if (!success) {
      writer.write("<tr><td colspan=\"5\">&nbsp;No records to display..&nbsp;</td></tr>");
    }

    writer.write("</table>");
    writer.write("<br>");

    if (filter) {
      sql = "SELECT COUNT(*) 'totalRows' FROM email_sent_histories esh LEFT JOIN contacts c_from ON" + from + " LEFT JOIN contacts c_to ON" + to + " WHERE esh.sent<>'0' AND job_id<>0";
      if (!where.equals("")) {
        sql += " AND (" + where + ")";
      }
    } else {
      sql = "SELECT COUNT(*) 'totalRows' FROM email_sent_histories esh LEFT JOIN contacts c_from ON esh.email_from_id=c_from.id LEFT JOIN contacts c_to ON esh.email_to_id=c_to.id WHERE esh.sent<>'0' AND esh.job_id<>0";
    }
    ResultSet rs = st.executeQuery(sql);
    if (rs.next()) {
      totalRows = Integer.parseInt(rs.getString("totalRows"));
    }
    rs.close();

    if (limit1 == 0) {
      firstPage = true;
    }
    if (limit2 >= totalRows) {
      limit2 = totalRows;
      lastPage = true;
    }

    if (!firstPage) {
      int lmt1 = limit1 - 50;
      writer.write("<a id=\"prevEmail\" href=\"#\" class=\"greybutton\" onclick=\"javascript:listEmailsRequest(" + filter + "," + lmt1 + ",50);\">Previous</a>");
    }
    if (!lastPage) {
      int lmt1 = limit1 + 50;
      writer.write("<br>");
      writer.write("<a id=\"nextEmail\" href=\"#\" class=\"greybutton\" onclick=\"javascript:listEmailsRequest(" + filter + "," + lmt1 + ",50);\">Next</a>");
    }

    st.close();
    conn.close();
%>