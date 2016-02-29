<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="com.marcomet.mail.*, com.marcomet.files.*, java.sql.*, java.text.DecimalFormat, com.marcomet.jdbc.*,com.marcomet.users.security.*" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%
boolean submitted=((request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true"))?true:false);
String dateFrom=((!submitted || request.getParameter("dateFrom")==null)?"":request.getParameter("dateFrom"));
String dateTo=((!submitted || request.getParameter("dateTo")==null)?"":request.getParameter("dateTo"));
String jobId=((!submitted || request.getParameter("jobId")==null)?"":request.getParameter("jobId"));
String status=((!submitted || request.getParameter("status")==null)?"":request.getParameter("status"));
String category=((!submitted || request.getParameter("category")==null)?"":request.getParameter("category"));
int companyId = Integer.parseInt((String)session.getAttribute("companyId"));
int contactId = Integer.parseInt((String)session.getAttribute("contactId"));
String dateFilter=((!jobId.equals("") || dateFrom.equals("") || dateTo.equals(""))?"":" AND fmd.creation_date>='" + dateFrom + " 00:00:00' AND fmd.creation_date<='" + dateTo + " 23:59:59' ");
String fmtDateFrom="";
String fmtDateTo="";
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
String query="";

%><html>
<head>
  <title>File Manager</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
<script type="text/javascript" src="/javascripts/jscalendar/calendar.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/calendar-setup.js"></script>
<script language="javascript" src="/javascripts/mainlib.js"></script>
<script language="javascript">
<!--
  function emailFiles() {
    var noFileChecked = true;
  	if (document.forms[1].fileList != null) {
		for(x = 0; x < document.forms[1].fileList.length;x++){
			if(document.forms[1].fileList[x].checked){
				document.forms[1].redirect.value="/files/useremailform.jsp";
				document.forms[1].submit();
				noFileChecked = false;
			}
		}
        if (document.forms[1].fileList.checked) {
            document.forms[1].redirect.value="/files/useremailform.jsp";
            document.forms[1].submit();
            noFileChecked = false;
        }
		if (noFileChecked) {
			alert("You have no files selected for Emailing!");
		}	
	} 
  }
  function downloadFiles() {
  	var noFileChecked = true;
  	if (document.forms[1].fileList != null) {
		for(x = 0; x < document.forms[1].fileList.length;x++){
			if(document.forms[1].fileList[x].checked){
				document.forms[1].submit();
				noFileChecked = false;
			}
		}
		if (document.forms[1].fileList.checked) {
                document.forms[1].submit();
                noFileChecked = false;
		}
		if (noFileChecked) {
			alert("You have no files selected for download!");
		}	
	} 
  }
//-->
function popHiddenDateField2(fieldName){
	var month = document.forms[0].dateMonth2[document.forms[0].dateMonth2.selectedIndex].value;
	var day = document.forms[0].dateDay2[document.forms[0].dateDay2.selectedIndex].value;
	var year = document.forms[0].dateYear2[document.forms[0].dateYear2.selectedIndex].value;
	eval("document.forms[1]."+ fieldName + ".value = '" + year + "-" + month + "-" + day+"'");
}
</script>
</head>
<body>
<form method="post" action=""><input type="hidden" name="submitted" value="true"><%
	boolean selfDesigned=((request.getParameter("shdc")!=null && request.getParameter("shdc").equals("true"))?true:false);
%><table border="0" cellpadding="3" cellspacing="0" width="100%">
<tr><td valign="bottom" width="10%"><div class="subtitle">File&nbsp;Manager<br><%=((selfDesigned)?"Self-Help Designed":"Uploaded")%>&nbsp;Files </div>
<%

//BEGIN FILE FILTERS 

%></td><td valign="bottom" width="90%" ><div align="left" style="align:bottom;float:right;"><span class="bodyBlack"><b>Filter Files:</b>&nbsp;&nbsp;<%

//JOB NUMBER
%>Job #&nbsp;<input type="text" name="jobId" size=11 value="<%=jobId%>" class="lineitems"><br><span class="subtitle">-or-&nbsp;&nbsp;</span><%

//DATE FROM
%>&nbsp;&nbsp;Date From:
      <input type="hidden" name="dateFrom" id="f_datefrom_d"><span class="lineitemsselected" id="show_d"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c" style="cursor: pointer; border: 1px solid red;" title="Date selector" onmouseover="this.style.background='red';" onmouseout="this.style.background=''" />
<script type="text/javascript">
 Calendar.setup({
 inputField: "f_datefrom_d", ifFormat: "%Y-%m-%d",displayArea: "show_d",daFormat: "%m-%d-%Y", button:"f_trigger_c", align: "BR", singleClick: true}); 
 var d=new Date();
 document.forms[0].dateFrom.value='<%=((dateFrom.equals(""))?"":dateFrom)%>'; 
 document.getElementById('show_d').innerHTML='<%=((dateFrom.equals(""))?"-Select-":dateFrom)%>';
</script>&nbsp;<%

//DATE TO
%>&nbsp;&nbsp;Date To:&nbsp;<input type="hidden" name="dateTo" id="f_dateto_d"><span class="lineitemsselected" id="show_d2"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c2" style="cursor: pointer; border: 1px solid red;" title="Date selector" onmouseover="this.style.background='red';" onmouseout="this.style.background=''" />
<script type="text/javascript">
Calendar.setup({
	inputField: "f_dateto_d", ifFormat : "%Y-%m-%d", displayArea : "show_d2", daFormat : "%m-%d-%Y", button : "f_trigger_c2", align: "BR", singleClick : true });
	var d=new Date();
	document.forms[0].dateTo.value='<%=((dateTo.equals(""))?"":dateTo)%>'; 
	document.getElementById('show_d2').innerHTML=<%=((dateTo.equals(""))?"'-Select-'":"'"+dateTo+"'")%>;
</script>&nbsp;&nbsp;<%

//FILE CATEGORY
%>|&nbsp;&nbsp;File Category:&nbsp;<select name="category" class="lineitems"><option value="" <%=((category.equals(""))?"selected":"")%>>-Select-</option><%
  
  if (((RoleResolver)session.getAttribute("roles")).isVendor()) {
     query = "SELECT distinct fmd.category as category FROM file_meta_data fmd, contacts c, jobs j, vendors v WHERE "+((selfDesigned)?"source=2 AND ":"")+" c.id = fmd.user_id AND fmd.job_id = j.id AND j.vendor_id = v.id AND v.company_id = " + companyId+dateFilter+((jobId.equals(""))?"":" AND j.id="+jobId)+" and fmd.category is not null and fmd.category<>'' order by fmd.category";
  } else {
     query = "SELECT distinct fmd.category as category FROM file_meta_data fmd, contacts c, jobs j, projects p, orders o WHERE "+((selfDesigned)?"source=2 AND ":"")+" category<>'Print' and user_id = c.id AND j.id = fmd.job_id AND fmd.project_id = p.id AND o.id = p.order_id AND (j.jbuyer_contact_id = "+contactId+" or j.jbuyer_company_id = " + companyId+") "+dateFilter+((jobId.equals(""))?"":" AND j.id="+jobId) +"  and fmd.category is not null and fmd.category<>''  order by fmd.category";
  }
  ResultSet rs = st.executeQuery(query);
  while (rs.next()) {
		%><option value="<%=rs.getString("category")%>" <%=((category.equals(rs.getString("category")))?"selected":"")%> ><%=rs.getString("category")%></option><%}%>
</select>&nbsp;&nbsp;<%

//FILE STATUS
%>|&nbsp;&nbsp;File Status:&nbsp;<select name="status" class="lineitems"><option value="" <%=((status.equals(""))?"selected":"")%>>-Select-</option><%

  if (((RoleResolver)session.getAttribute("roles")).isVendor()) {
     query = "SELECT distinct fmd.status FROM file_meta_data fmd, contacts c, jobs j, vendors v WHERE "+((selfDesigned)?"source=2 AND ":"")+" c.id = fmd.user_id AND fmd.job_id = j.id AND j.vendor_id = v.id AND v.company_id = " + companyId+dateFilter+((jobId.equals(""))?"":" AND j.id="+jobId)+"  and fmd.status is not null and fmd.status<>''  order by fmd.status";
  } else {
     query = "SELECT distinct fmd.status FROM file_meta_data fmd, contacts c, jobs j, projects p, orders o WHERE "+((selfDesigned)?"source=2 AND ":"")+" category<>'Print' and user_id = c.id AND j.id = fmd.job_id AND fmd.project_id = p.id AND o.id = p.order_id AND (j.jbuyer_contact_id = "+contactId+" or j.jbuyer_company_id = " + companyId+") "+dateFilter+((jobId.equals(""))?"":" AND j.id="+jobId) +"  and fmd.status is not null and fmd.status <>''  order by fmd.status";
  }
  rs = st.executeQuery(query);
  while (rs.next()) {
		%><option value="<%=rs.getString("status")%>" <%=((status.equals(rs.getString("status")))?"selected":"")%>><%=rs.getString("status")%></option><%}%>
</select>&nbsp;&nbsp;<%

//SUBMIT
%><input type="button" onclick="javascript:document.forms[0].submitted.value='false';document.forms[0].submit();" class="minderLink" value="Clear Filters&nbsp;&raquo;">&nbsp;&nbsp;<input type="submit" class="minderLink" value="Apply Filters&nbsp;&raquo;"></span></div>
</div></td></tr><%

//END FILE FILTERS
%>
    <tr> 
      <td colspan="2"><hr size=1 color=gray>
        <p class="body"><%if (selfDesigned){%>All files which have been designed by you in the Self-Help Design Center are included below. <%}else{%>All files associated to your jobs are included below categorized as Final Files, Working Files and Files for Approval.<%}%> Many of the file types (.jpg, .pdf, etc.) may be viewed online by clicking on their filename.</p>
      </td></tr>
      </table>
</form>
    <%
  if (((RoleResolver)session.getAttribute("roles")).isVendor()) {
     query = "SELECT count(fmd.id) as files FROM file_meta_data fmd, contacts c, jobs j, vendors v WHERE "+((selfDesigned)?"source=2 AND ":"")+" c.id = fmd.user_id AND fmd.job_id = j.id AND j.vendor_id = v.id AND v.company_id = " + companyId+dateFilter+((jobId.equals(""))?"":" AND j.id="+jobId)+((category.equals(""))?"":" AND fmd.category='"+category+"'")+((status.equals(""))?"":" AND fmd.status='"+status+"'");
  } else {
     query = "SELECT count(fmd.id) as files FROM file_meta_data fmd, contacts c, jobs j, projects p, orders o WHERE "+((selfDesigned)?"source=2 AND ":"")+" category<>'Print' and user_id = c.id AND j.id = fmd.job_id AND fmd.project_id = p.id AND o.id = p.order_id AND (j.jbuyer_contact_id = "+contactId+" or j.jbuyer_company_id = " + companyId+") "+dateFilter+((jobId.equals(""))?"":" AND j.id="+jobId) +((category.equals(""))?"":" AND fmd.category='"+category+"'")+((status.equals(""))?"":" AND fmd.status='"+status+"'");
  }

  rs = st.executeQuery(query);
  if (rs.next()) {
  	submitted=((rs.getInt("files")<100)?true:submitted);
  }

  if (submitted){
  %><form method="post" action="/servlet/com.marcomet.files.FileManagementServlet">    
    <table>
    <tr> 
      <td align="left" colspan="2"><div class="bodyBlack" style="margin-bottom:5px;">Check the box next to the file(s) you wish to send/download, then click the Email or Download link</div></td></tr>
      <tr><td align="left" colspan=2><div class="bodyBlack" style="margin-bottom:5px;margin-top:1px;"><a href="javascript:emailFiles()" class="minderLink">&raquo;&nbsp;Email File(s)</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:downloadFiles()" class="minderLink">&raquo;&nbsp;Download File(s)</a> <%if(!selfDesigned){%>&nbsp;&nbsp;or&nbsp;&nbsp;<a href="javascript:pop('/files/upload.jsp',600,300)" class="minderLink" >&raquo;&nbsp;Upload New File(s)</a><%}%></div></td>
    </tr>
  </table>
  <table cellpadding="3" cellspacing="0" width="100%" bordercolor="#000000" style="border-top:1 solid Black;border-bottom:1 solid Black;border-left:1 solid Black;border-right:1 solid Black;">
    <tr> 
      <td width="2%" nowrap class="minderheaderleft">Select&nbsp;</td><%
      if(selfDesigned){
      %><td width="2%" nowrap class="minderheaderleft">&nbsp;</td><%}%>
      <td class="minderheaderleft" width="12%" nowrap> 
        <div align="left">File Name</div>
      </td>
      <td class="minderheaderleft" width="5%" nowrap> 
        <div align="left">File Size</div>
      </td>
      <td class="minderheaderleft" width="4%" nowrap> 
        <div align="left"><%=((selfDesigned)?"Created By":"Uploaded by")%></div>
      </td>
      <td class="minderheaderleft" width="4%" nowrap> 
        <div align="left">Created on</div>
      </td>
      <%if(!selfDesigned){%><td class="minderheaderleft" width="12%"> 
        <div align="left">Job </div>
      </td>
      <td class="minderheaderleft" width="6%" nowrap> 
        <div align="left">Category</div>
      </td>
      <td class="minderheaderleft" width="6%" nowrap> 
        <div align="left">Appvl Status</div>
      </td><%}else{%><td class="minderheaderleft" width="11%" nowrap> 
        <div align="left">File Description</div>
      </td><%}%>
      <td class="minderheaderleft" width="15%" nowrap> 
        <div align="left">Comments</div>
      </td>
    </tr><%
  double fileSize;
	
  if (((RoleResolver)session.getAttribute("roles")).isVendor()) {
     query = "SELECT fmd.id, file_name, fmd.company_id AS companyid, file_size, fmd.description, reply, category, status, DATE_FORMAT(fmd.creation_date,'%m/%d/%y') AS creation_date, firstname, lastname, job_id, j.project_id,j.job_name FROM file_meta_data fmd, contacts c, jobs j, vendors v WHERE "+((selfDesigned)?"source=2 AND ":"")+" c.id = fmd.user_id AND fmd.job_id = j.id AND j.vendor_id = v.id AND v.company_id = " + companyId+dateFilter+((jobId.equals(""))?"":" AND j.id="+jobId)+((category.equals(""))?"":" AND fmd.category='"+category+"'")+((status.equals(""))?"":" AND fmd.status='"+status+"'")+" order by fmd.creation_date";
  } else {
     query = "SELECT fmd.id, file_name, fmd.company_id AS companyid, file_size, fmd.description, reply, category, status, DATE_FORMAT(fmd.creation_date,'%m/%d/%y') AS creation_date, job_id, j.project_id, firstname, lastname,j.job_name FROM file_meta_data fmd, contacts c, jobs j, projects p, orders o WHERE "+((selfDesigned)?"source=2 AND ":"")+" category<>'Print' and user_id = c.id AND j.id = fmd.job_id AND fmd.project_id = p.id AND o.id = p.order_id AND (j.jbuyer_contact_id = "+contactId+" or j.jbuyer_company_id = " + companyId+") "+dateFilter+((jobId.equals(""))?"":" AND j.id="+jobId) +((category.equals(""))?"":" AND fmd.category='"+category+"'")+((status.equals(""))?"":" AND fmd.status='"+status+"'")+" order by fmd.creation_date";
  }

  rs = st.executeQuery(query);
  boolean alt = true;
  while (rs.next()) {
     fileSize =  rs.getDouble("file_size");
     alt = (alt)?false:true; 
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
%>
    <tr> 
      <td class=lineitem<%=(alt)?"alt":""%> align="left" width="4%"> 
        <input type="checkbox" name="fileList" value="<%= rs.getString("id") %>">
      </td><%
      if(selfDesigned){
      %><td class=lineitem<%=(alt)?"alt":""%> align="left" width="4%"> 
        <a href="/catalog/reprintJobsFromFile.jsp?jobId=<%= rs.getString("job_id") %>" class='minderLink'>Reprint / New&nbsp;Version&nbsp;&raquo;</a>
    </td><%}%>
      <td class=lineitem<%=(alt)?"alt":""%> ><a href="javascript:pop('/downloads.jsp?dlFile=/transfers/<%= rs.getString("companyid") %>/<%= rs.getString("file_name") %>',300,300)" class="minderLink" ><%= rs.getString("file_name") %></a></td>
      <td class=lineitem<%=(alt)?"alt":""%> width="5%"><%= formattedFileSize %> 
        <%= tag %></td>
      <td class=lineitem<%=(alt)?"alt":""%> ><%= rs.getString("lastname") + ", " + rs.getString("firstname") %></td>
      <td class=lineitem<%=(alt)?"alt":""%> ><%= rs.getString("creation_date") %></td><%if(!selfDesigned){%>
      <td class=lineitem<%=(alt)?"alt":""%> ><a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%= rs.getString("job_id")%>','700','600')" class="minderLink"><%= rs.getString("job_id")%></a>, <%=rs.getString("job_name") %></td>
      <td class=lineitem<%=(alt)?"alt":""%> ><%= rs.getString("category") %></td>
      <td class=lineitem<%=(alt)?"alt":""%> ><%= rs.getString("status") %></td><%}else{%>
      <td class=lineitem<%=(alt)?"alt":""%> ><%= rs.getString("job_name")%>, Job #<a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%= rs.getString("job_id")%>','700','600')" class="minderLink"><%=rs.getString("job_id") %></a><%}%>
      <td class=lineitem<%=(alt)?"alt":""%> ><%= rs.getString("description") %>&nbsp;</td>
    </tr>
    <% } %>
  </table>
  <br>
  <input type="hidden" name="action" value="">
  <input type="hidden" name="redirect" value="">
</form><%}else{%><hr>
<div class="catalobLabel">There are over 100 files found -- Please narrow the range of files to be displayed using the filters above.</div>
<%}%></body>
</html>
