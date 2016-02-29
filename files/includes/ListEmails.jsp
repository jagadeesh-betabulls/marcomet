<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*" %>
<%
    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
    String sql = "";
    int limit1 = (request.getParameter("limit1") != null) ? Integer.parseInt(request.getParameter("limit1")) : 0;
    int limit2 = (request.getParameter("limit2") != null) ? Integer.parseInt(request.getParameter("limit2")) : 50;
    int pageNo = (limit1 > 0) ? (limit1 / 50) + 1 : 1;
    boolean firstPage = false, lastPage = false;
%>
<div id="divWait" align="center" style="display:none;">
  <h5>Please Wait&nbsp;<br><img src="/images/generic/dotdot.gif" width="72" height="10"></h5>
</div>
<script type="text/javascript">
  function listEmailsRequest(filter,limit1,limit2){
    AjaxModalBox.open($('divWait'), {title: 'Please Wait', width: 190, height: 110, showClose: false});
    
    var ajaxRequest;
    if(window.XMLHttpRequest){
      //Mozilla, Netscape.
      ajaxRequest = new XMLHttpRequest();
    }
    else if(window.ActiveXObject){
      //Internet Explorer.
      ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
    }

    var jobId = document.frmEmails.jobId.value;
    var anyAll;
    for(i=0; i<document.frmEmails.anyAll.length; i++){
      if(document.frmEmails.anyAll[i].checked == true){
        anyAll = document.frmEmails.anyAll[i].value;
        break;
      }
    }
    var fromId = document.frmEmails.fromId.value;
    var toId = document.frmEmails.toId.value;
    var fromEmailAddress = document.frmEmails.fromEmailAddress.value;
    var toEmailAddress = document.frmEmails.toEmailAddress.value;
    var fromSiteNumber = document.frmEmails.fromSiteNumber.value;
    var toSiteNumber = document.frmEmails.toSiteNumber.value;
    var fromDate = document.frmEmails.fromDate.value;
    var toDate = document.frmEmails.toDate.value;

    if(jobId == "" && fromId == "" && toId == "" && fromEmailAddress == "" && toEmailAddress == "" && fromSiteNumber == "" && toSiteNumber == "" && fromDate == "" && toDate == ""){
      filter = false;
    }

    var params = "filter="+filter+"&limit1="+limit1+"&limit2="+limit2+"&anyAll="+anyAll+"&jobId="+jobId+"&fromId="+fromId+"&toId="+toId+"&fromEmailAddress="+fromEmailAddress+"&toEmailAddress="+toEmailAddress+"&fromSiteNumber="+fromSiteNumber+"&toSiteNumber="+toSiteNumber+"&fromDate="+fromDate+"&toDate="+toDate;

    ajaxRequest.open("post", "/files/includes/ListEmailsRequest.jsp?"+params, true);
    ajaxRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
    ajaxRequest.send(null);
    ajaxRequest.onreadystatechange = function(){
      if(ajaxRequest.readyState == 4){
        if(ajaxRequest.status == 200){
          AjaxModalBox.close();
          document.getElementById("divListEmails").innerHTML = ajaxRequest.responseText;
        }
      }
    };
  }
</script>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Emails</title>
    <link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  </head>
  <link rel="stylesheet" href="/styles/modalbox.css" type="text/css">
  <script language="JavaScript" src="/javascripts/mainlib.js"></script>
  <script type="text/javascript" src="/javascripts/prototype1.js"></script>
  <script type="text/javascript" src="/javascripts/scriptaculous1.js"></script>
  <script type="text/javascript" src="/javascripts/modalbox.js"></script>
  <body>
    <form action="" name="frmEmails">
      <div id="divEmailDetail" style="display: none;">
        <br>
        <div align="center">
          <a href="#" class="greybutton" onclick="AjaxModalBox.open($('divReplyForward'), {title: 'Email Detail', width: 1000, height: 500}); document.getElementById('divReplyForward').innerHTML = '<p><div align=\'center\'><a href=\'#\' onclick=\'AjaxModalBox.close();\' class=\'greybutton\'>Cancel</a></div></p><iframe id=\'frmReplyForward\' height=\'100%\' width=\'100%\' scrolling=\'auto\' src=\'/files/useremailform.jsp?emailrf=respond&target=client&jobId=' + document.getElementById('emailJob').innerHTML + '\'></iframe><br><br>';">&nbsp;Respond To&nbsp;</a>
          <a href="#" class="greybutton" onclick="AjaxModalBox.open($('divReplyForward'), {title: 'Email Detail', width: 1000, height: 500}); document.getElementById('divReplyForward').innerHTML = '<p><div align=\'center\'><a href=\'#\' onclick=\'AjaxModalBox.close();\' class=\'greybutton\'>Cancel</a></div></p><iframe id=\'frmReplyForward\' height=\'100%\' width=\'100%\' scrolling=\'auto\' src=\'/files/useremailform.jsp?emailrf=forward&target=client&jobId=' + document.getElementById('emailJob').innerHTML + '\'></iframe><br><br>';">&nbsp;Forward&nbsp;</a>
          <a href="#" onclick="AjaxModalBox.close();" class="greybutton">&nbsp;Cancel&nbsp;</a>
        </div>
        <br><br>
        <p id="emailSubject" align="center" style="background-color: #fffccc; border: 2px solid black; font-size:small; font-weight:bold;"></p>
        <label class="label" style="height:8px;">From:&nbsp;</label><label id="emailFrom"></label>
        <br>
        <label class="label" style="height:8px;">To:&nbsp;</label><label id="emailTo"></label>
        <br>
        <label class="label" style="height:8px;">Sent On:&nbsp;</label><label id="emailSent"></label>
        <br>
        <label class="label" style="height:8px;">Job #:&nbsp;</label><a id="emailJob" target="_blank"></a>
        <br>
        <label class="label" style="height:8px;">Attachments:&nbsp;</label><span id="emailAttachment"></span>
        <br><br>
        <div id="emailBody" style="border: 1px solid gray;" align="center"></div>
        <br><br>
      </div>
      <div id="divReplyForward" style="display: none;"></div>
      <p class="Title">Email Listings</p>
      <p>
        <h4>[Filters]</h4>
        <a href="#" name="filter" class="greybutton" onclick="listEmailsRequest(true,<%=limit1%>,<%=limit2%>); ">&nbsp;Filter&nbsp;</a>
        <%--<input type="submit" value=" Filter " class="greybutton">--%>
        <br><br>
        <table border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td align="right">Job ID:&nbsp;</td><td><input type="text" name="jobId" id="jobId" value="">&nbsp;&nbsp;</td>
            <td>&nbsp;</td><td>&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td><td>&nbsp;</td>
            <td>&nbsp;</td><td>&nbsp;</td>
          </tr>
          <tr>
            <td colspan="2" align="center" style="font-size:12px;">&nbsp;--OR--&nbsp;(Clear the Job ID to use filters below)</td>
            <td>&nbsp;</td><td>&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td><td>&nbsp;</td>
            <td>&nbsp;</td><td>&nbsp;</td>
          </tr>
          <tr>
            <td align="right"><input type="radio" name="anyAll" value="ANY" checked>&nbsp;ANY&nbsp;</td><td><input type="radio" name="anyAll" value="ALL">&nbsp;ALL&nbsp;&nbsp;</td>
            <td>&nbsp;</td><td>&nbsp;</td>
          </tr>
          <tr>
            <td align="right">Sent From ID:&nbsp;</td><td><input type="text" name="fromId" id="fromId" value="">&nbsp;&nbsp;</td>
            <td align="right">Sent To ID:&nbsp;</td><td><input type="text" name="toId" id="toId" value="">&nbsp;&nbsp;</td>
          </tr>
          <tr>
            <td align="right">Sent From Email Address:&nbsp;</td><td><input type="text" name="fromEmailAddress" id="fromEmailAddress" value="">&nbsp;&nbsp;</td>
            <td align="right">Sent To Email Address:&nbsp;</td><td><input type="text" name="toEmailAddress" id="toEmailAddress" value="">&nbsp;&nbsp;</td>
          </tr>
          <tr>
            <td align="right">Sent From Site Number:&nbsp;</td><td><input type="text" name="fromSiteNumber" id="fromSiteNumber" value="">&nbsp;&nbsp;</td>
            <td align="right">Sent To Site Number:&nbsp;</td><td><input type="text" name="toSiteNumber" id="toSiteNumber" value="">&nbsp;&nbsp;</td>
          </tr>
          <tr>
            <td align="right">Date Sent From:&nbsp;</td><td><input type="text" name="fromDate" id="fromDate" value="">&nbsp;&nbsp;</td>
            <td align="right">To:&nbsp;</td><td><input type="text" name="toDate" id="toDate" value="">&nbsp;&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td><td align="center">&nbsp;(yyyy-mm-dd)&nbsp;</td>
            <td>&nbsp;</td><td align="center">&nbsp;(yyyy-mm-dd)&nbsp;</td>
          </tr>
        </table>
      </p>
      <div id="divListEmails">
        <table border="1" cellpadding="1" cellspacing="1">
          <tr>
            <td class="minderheaderleft">&nbsp;JobId</td>
            <td class="minderheaderleft">&nbsp;From</td>
            <td class="minderheaderleft">&nbsp;To</td>
            <td class="minderheaderleft">&nbsp;Subject</td>
            <td class="minderheaderleft">&nbsp;Sent On</td>
          </tr>
          <%
    int totalRows = 0;
    String from = "", to = "", where = "";
    sql = "SELECT esh.id, esh.job_id, esh.email_from, esh.email_to, esh.subject, CONCAT(LEFT(esh.subject,25),IF(LENGTH(esh.subject)>25,'...','')) 'short_subject', REPLACE(esh.body,'\\r','') 'body', esh.attachments, esh.sent, c_to.*, c_from.* FROM email_sent_histories esh LEFT JOIN contacts c_from ON esh.email_from_id=c_from.id LEFT JOIN contacts c_to ON esh.email_to_id=c_to.id WHERE esh.sent<>'0' AND esh.job_id<>0 LIMIT " + limit1 + "," + limit2;
    ResultSet rs1 = st.executeQuery(sql);
    while (rs1.next()) {
      boolean hasAttachment = false;
      String attach = rs1.getString("attachments");
      String[] attachments = {""}, attachFile = null, attachPath = null;
      String attachment = "";
      //StringBuilder attachment = new StringBuilder("");
      if (attach != null && !(attach.equals(""))) {
        hasAttachment = true;
        attachments = attach.split(",");
        attachFile = new String[attachments.length];
        attachPath = new String[attachments.length];
        for (int i = 0; i < attachments.length; i++) {
          attachPath[i] = attachments[i].substring(0, attachments[i].lastIndexOf("/") + 1);
          attachFile[i] = attachments[i].substring(attachments[i].lastIndexOf("/") + 1, attachments[i].length());
          //if (i > 0) {
          //  attachment.append(", ");
          //}
          //attachment.append(attachFile[i]);
          if (i > 0) {
            attachment += ", ";
          }
          attachment += "<a href=\\\'" + attachPath[i] + attachFile[i] + "\\\' target=\\\'_blank\\\'>" + attachFile[i] + "</a>";
        }
      }
      //String jobId = "<a href=\\\'/popups/JobDetailsPage.jsp?jobId=" + Integer.parseInt(rs1.getString("job_id")) + "\\\' target=\\\'_blank\\\'>" + Integer.parseInt(rs1.getString("job_id")) + "</a>";
          %>
          <tr>
            <td class="" height="2" align="left">&nbsp;<%= Integer.parseInt(rs1.getString("job_id"))%></td>
            <td class="" height="2" align="left">&nbsp;<%= rs1.getString("email_from")%></td>
            <td class="" height="2" align="left">&nbsp;<%= rs1.getString("email_to")%></td>
            <td class="" height="2" align="left"><a href="#" onclick="AjaxModalBox.open($('divEmailDetail'), {title: 'Email Detail', width: 1000, height: 500}); document.getElementById('emailSubject').innerHTML = '<%= rs1.getString("subject")%>'; document.getElementById('emailFrom').innerHTML = '<%= rs1.getString("email_from")%>'; document.getElementById('emailTo').innerHTML = '<%= rs1.getString("email_to")%>'; document.getElementById('emailSent').innerHTML = '<%= rs1.getString("sent")%>'; document.getElementById('emailJob').href= '/popups/JobDetailsPage.jsp?jobId=<%= Integer.parseInt(rs1.getString("job_id"))%>'; document.getElementById('emailJob').innerHTML = '<%= Integer.parseInt(rs1.getString("job_id"))%>'; if(<%= hasAttachment%>){document.getElementById('emailAttachment').innerHTML = '<%= attachment%>';} else{document.getElementById('emailAttachment').innerHTML = '';} document.getElementById('emailBody').innerHTML = '<%= rs1.getString("body").toString().replace("\n", "").replace("\'", "").replace("\"", "\\\'")%>';">&nbsp;<%= rs1.getString("short_subject")%></a></td>
            <td class="" height="2" align="left">&nbsp;<%= rs1.getString("sent")%></td>
          </tr>
          <%}
    rs1.close();
          %>
        </table>
        <br>
        <%
    sql = "SELECT COUNT(*) 'totalRows' FROM email_sent_histories esh LEFT JOIN contacts c_from ON esh.email_from_id=c_from.id LEFT JOIN contacts c_to ON esh.email_to_id=c_to.id WHERE esh.sent<>'0' AND esh.job_id<>0";
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
        %>
        <%--<a href="#" class="greybutton" onclick="javascript:window.location.replace('/files/includes/ListEmails.jsp?limit1=<%= limit1 - 50%>&limit2=<%= limit1%>');">Previous</a>--%>
        <a id="prevEmail" href="#" class="greybutton" onclick="javascript:listEmailsRequest(false, <%=limit1%> - 50, 50);">Previous</a>
        <%}
    if (!lastPage) {
        %>
        <br>
        <%--<a href="#" class="greybutton" onclick="javascript:window.location.replace('/files/includes/ListEmails.jsp?limit1=<%= limit2%>&limit2=<%= limit2 + 50%>');">Next</a>--%>
        <a id="nextEmail" href="#" class="greybutton" onclick="javascript:listEmailsRequest(false, <%=limit1%> + 50, 50);">Next</a>
        <%}
        %>
      </div>
    </form>
  </body>
</html><% st.close();
    conn.close();%>