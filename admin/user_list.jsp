<%@ include file="/includes/SessionChecker.jsp" %>
<%@ page import="java.sql.*,java.text.*,java.util.*,com.marcomet.tools.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>

<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="fmt" class="com.marcomet.tools.FormaterTool" scope="session" />
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="session" />
<%String siteHostId=session.getAttribute("siteHostId").toString();
String editFlag=((request.getParameter("editFlag")==null)?"":request.getParameter("editFlag"));

String companyId="";
String contactId="";
String sql = "";
int x=0;
int y=0;
Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
if (request.getParameter("delete")!=null && request.getParameter("delete").equals("yes")){
	for(x=-1;x<Integer.parseInt(((request.getParameter("contactnums")==null || request.getParameter("contactnums").equals(""))?"0":request.getParameter("contactnums")));x++){
	if (request.getParameter("contact"+x)!=null){
		if (!request.getParameter("contact"+x).equals("")){
			contactId=request.getParameter("contact"+x);
			sql = "Select companyid from contacts where id="+contactId;
			ResultSet rsComp = st.executeQuery(sql);
			if (rsComp.next()){
				companyId=rsComp.getString("companyid");
			}
			st2.executeUpdate("Delete from companies where id="+contactId);
			st2.executeUpdate("Delete from contacts where id="+contactId);
			st2.executeUpdate("Delete from locations where contactid="+contactId);
			st2.executeUpdate("Delete from phones where contactid="+contactId);
			st2.executeUpdate("Delete from logins where contact_id="+contactId);
			st2.executeUpdate("Delete from contact_roles where contact_id="+contactId);
		}
	}
	}
}
%><html>
<head>
<title>User List</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" type="text/css" href="/styles/calendar.css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<script language="JavaScript" src="/javascripts/calendarcode.js"></script>
<script language="javascript">
function sortBy(column){
	document.forms[0].action="/admin/user_list.jsp?doSearch=yes&orderBy="+column;
	document.forms[0].submit();
}
function deleteContacts(){
if (confirm("Are you sure you wish to delete the selected Contacts? There will be no way to retrieve them once deleted!")){
	document.forms[0].action="/admin/user_list.jsp?doSearch=yes&delete=yes";
	document.forms[0].submit();
	
}
}
function HighlightRow( checkbox,rowNumber )
{
    var targetRow = eval( "document.all.row" + rowNumber );
    if(checkbox.checked){
		targetRow.className = "selectedRow";
	}else{
		targetRow.className = "unselectedRow";	
	}

}

var date = new Date();
var d  = date.getDate();
var day = (d < 10) ? '0' + d : d;
var m = date.getMonth() + 1;
var month = (m < 10) ? '0' + m : m;
var yy = date.getYear();
var year = (yy < 1000) ? yy + 1900 : yy;
var today=(month + "/" + day + "/" + year);
var nextYear=(month + "/" + day + "/" + (year+1));
var lastYear=(month + "/" + day + "/" + (year-1));
function dateToToday(tempDate){
	if (tempDate==""){
	  return today;
	}else{
		return tempDate;
	}
}
function dateToNextYear(tempDate){
	if (tempDate==""){
	  return nextYear;
	}else{
		return tempDate;
	}
}
var cal1=new ctlSpiffyCalendarBox("cal1", "edit", "startDate","btnDate1",("<%=((request.getParameter("startDate")!=null && !request.getParameter("startDate").equals(""))?request.getParameter("startDate"):"")%>"),scBTNMODE_CALBTN);
var cal2=new ctlSpiffyCalendarBox("cal2", "edit", "endDate","btnDate2",("<%=((request.getParameter("endDate")!=null) && !request.getParameter("endDate").equals("")?request.getParameter("endDate"):"")%>"),scBTNMODE_CALBTN);
</script>

<body bgcolor="#FFFFFF" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg" leftmargin="0" topmargin="1" onLoad="MM_preloadImages('/images/buttons/editover.gif','/images/buttons/editdown.gif')">
<br><p class="maintitle"><%=((editFlag.equals("true"))?"Edit ":"")%> Users and Roles</p>
<%if(editFlag.equals("true")){%>
<%}%>
<form name="edit" method="post" action="/admin/user_list.jsp?doSearch=yes">
<div class="label">Search for users (Enter all that apply, leave blank for all) <br>
Last Name: 
<input type="text" name="lastName" value="<%=((request.getParameter("lastName")==null)?"":request.getParameter("lastName"))%>">
    Email: 
    <input type="text" name="email" value="<%=((request.getParameter("email")==null)?"":request.getParameter("email"))%>">
    Username: 
    <input type="text" name="userName" size="30" value="<%=((request.getParameter("userName")==null)?"":request.getParameter("userName"))%>">
<br>
  <br>
  Date Ranges:<br><%String dateRange=((request.getParameter("dateRange")==null)?"":request.getParameter("dateRange"));%>
    Find contacts entered in the last: <taglib:LUCustomDropDownTag  key="days" orderbyField = "sequence" valueField="value" dropDownName="dateRange" table="lu_timeframes" selected="<%=dateRange%>"/><i><b>-or-</b></i> Find Contacts entered 
    between: 
    <script language="javascript">cal1.writeControl();</script>
&amp; 
<script language="javascript">cal2.writeControl();</script>
            <a href="javascript:document.forms[0].submit()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('search','','/images/buttons/searchover.gif',1)" onMouseDown="MM_swapImage('search','','/images/buttons/searchdown.gif',1)" ><img name="search" border="0" src="/images/buttons/search.gif"  width="50" height="20" align="absmiddle"></a>
  </div><hr size=1 color=red>
  <%  if(request.getParameter("doSearch")!=null && request.getParameter("doSearch").equals("yes")){%>
  <table border=0 cellpadding=0 cellspacing=0 width=100% align="center">
    <tr> 
    <td class="tableheader" width="3%" >
        <a href="javascript:deleteContacts()" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('delete','','/images/buttons/deleteover.gif',1)" onMouseDown="MM_swapImage('delete','','/images/buttons/deletedown.gif',1)" ><img name="delete" border="0" src="/images/buttons/delete.gif"  width="50" height="20" align="absmiddle"></a>
      </td>
	    <td class="tableheader" width="3%" >&nbsp;</td>
    <td class="tableheader" width=9%><a href="javascript:sortBy('ct.date_created')" class="tableheader">Date 
      Created</a></td>
    <td class="tableheader" width=10%><a href="javascript:sortBy('ct.lastname')" class="tableheader">User 
      Name </a></td>	  	  
    <td class="tableheader" width=8%><a href="javascript:sortBy('username')" class="tableheader">Login 
      Name </a></td>
    <td class="tableheader" width=8%><a href="javascript:sortBy('ct.jobtitle')" class="tableheader">Title</a></td>	  
    <td class="tableheader" width=10%><a href="javascript:sortBy('ct.email')" class="tableheader">Email</a></td>
    <td class="tableheader" width=10%><a href="javascript:sortBy('com.company_name')" class="tableheader">Company</a></td>		
    <td class="tableheader" width="25%">Role(s)</td>	
    <%if(editFlag.equals("true")){%>
    <%}%>
  </tr>
  <%
String lastnameFilter=((request.getParameter("lastName")==null)?"":" and ct.lastname like \"%"+request.getParameter("lastName")+"\" ");
String emailFilter=((request.getParameter("email")==null)?"":" and ct.email like \"%"+request.getParameter("email")+"\" ");
String usernameFilter=((request.getParameter("userName")==null)?"":" and lg.user_name like \"%"+request.getParameter("userName")+"\" ");
String startDate="";
String endDate="";
if (request.getParameter("dateRange")!=null && !request.getParameter("dateRange").equals("0") ){
	Calendar calend = Calendar.getInstance();
	Calendar calstart = Calendar.getInstance();	
	calend.add(Calendar.DATE,-(Integer.parseInt(request.getParameter("dateRange"))));
	SimpleDateFormat formatter = new SimpleDateFormat("MM/dd/yyyy");
	startDate = formatter.format(calend.getTime());
	endDate=formatter.format(calstart.getTime());
}else{
	startDate=((request.getParameter("startDate")==null)?"":request.getParameter("startDate"));
	endDate=((request.getParameter("endDate")==null)?"":request.getParameter("endDate"));
}
String dateFilter=((startDate.equals(""))?"":" and ((ct.date_created >= '"+str.mysqlFormatDate(startDate)+"') and (ct.date_created <= '"+str.mysqlFormatDate(endDate)+"')) ");
sql = "SELECT distinct ct.jobtitle,ct.date_created,ct.id, com.company_name,concat(ct.firstname,\" \",ct.lastname) fullname,ct.email,lg.user_name username FROM  contact_roles rl , contacts ct left join logins lg on lg.contact_id=ct.id left join companies com on com.id=ct.companyid  WHERE rl.contact_id=ct.id  "+lastnameFilter+emailFilter+usernameFilter+dateFilter+" and rl.site_host_id="+ session.getAttribute("siteHostId")+"  order by "+((request.getParameter("orderBy")==null)?"ct.lastname":request.getParameter("orderBy"));
ResultSet rs = st.executeQuery(sql);	
while (rs.next()){
	%>
    <tr id="row<%=rs.getString("ct.id")%>" class="unselectedRow" bordercolor="#000000" > 
      <td  class="lineitemunselected" width="3%" > 
        <input type="checkbox" onClick="HighlightRow(this,'<%=rs.getString("ct.id")%>')" name="contact<%=y++%>"  value="<%=rs.getString("ct.id")%>">
      </td>
      <td  class="lineitemunselected" valign="top" width="3%"> <a href="/admin/user_roles_form.jsp?contactId=<%=rs.getString("ct.id")%>" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('edit<%=x%>','','/images/buttons/editover.gif',1)" ><img name="edit<%=x++%>" border="0" src="/images/buttons/edit.gif" width="34" height="21" align="absmiddle"></a>&nbsp; 
      </td>
      <td  class="lineitemunselected" valign="top" width="9%"> <%=fmt.formatTimeStamp(rs.getString("ct.date_created"))%></td>
      <td  class="lineitemunselected" valign="top" width="10%" ><a href="javascript:popw('/users/AccountInformationPage.jsp?editFlag=false&userId=<%=rs.getString("id")%>',600,400)"><%=((rs.getString("fullname")==null)?"&nbsp;":rs.getString("fullname"))%></a></td>
      <td  class="lineitemunselected" valign="top" width="8%" ><%=((rs.getString("username")==null)?"&nbsp;":rs.getString("username"))%></td>	
      <td  class="lineitemunselected" valign="top" width="8%" ><%=((rs.getString("ct.jobtitle")==null || rs.getString("ct.jobtitle").equals(""))?"&nbsp;":rs.getString("ct.jobtitle"))%></td>	
      <td  class="lineitemunselected" valign="top" width="10%" ><%=((rs.getString("ct.email")==null)?"&nbsp;":rs.getString("ct.email"))%></td>
      <td  class="lineitemunselected" valign="top" width="10%" ><%=((rs.getString("com.company_name")==null)?"&nbsp;":rs.getString("com.company_name"))%></td>
      <td  class="lineitemunselected" valign="top" width="50%" > 
        <%
	sql="Select * from contact_roles cr left join lu_contact_roles lu on cr.contact_role_id=lu.id where cr.contact_id="+rs.getString("ct.id");
	ResultSet rl = st2.executeQuery(sql);
	while (rl.next()) {
		%>
        <%=((rl.getString("lu.value")==null)?"&nbsp;":rl.getString("lu.value"))%>; 
        <% 
	}
	%>
      </td>

  </tr>
  <%
}
%>
</table>
Number of Contacts found: <%=y%>
<%}%>

<input type="hidden" name="contactnums" value="<%=y+1%>">
</form>
<div id="spiffycalendar" class="text">&nbsp;</div>
</body>
</html><%conn.close(); %>
