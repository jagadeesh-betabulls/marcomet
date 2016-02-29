<%@ page import="java.lang.*;" %><%
/***
USE:	<jsp:include page="/includes/DatePicker.jsp" ><jsp:param name="fieldName" value="fieldName" /><jsp:param name="className" value="className" /><jsp:param name="defaultDate" value="{today | tomorrow | yearBegin | mm-dd-yyyy}" /></jsp:include> or
	<jsp:include page="/includes/DatePicker.jsp?fieldName=fieldName&class=className&defaultDate=today" />
****/
%><link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
<script type="text/javascript" src="/javascripts/jscalendar/calendar.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/calendar-setup.js"></script><%

String formNum=((request.getParameter("formNum")==null || request.getParameter("formNum").equals(""))?"0":request.getParameter("formNum"));
String fieldNum=((request.getParameter("fieldNum")==null || request.getParameter("fieldNum").equals(""))?"0":request.getParameter("fieldNum"));
String fieldName=((request.getParameter("fieldName")==null || request.getParameter("fieldName").equals(""))?"dateField":request.getParameter("fieldName"));
String className=((request.getParameter("className")==null || request.getParameter("className").equals(""))?"lineitems":request.getParameter("className"));
String defaultDate=((request.getParameter("defaultDate")==null || request.getParameter("defaultDate").equals(""))?"today":request.getParameter("defaultDate"));
String defaultDateStr="";

if(defaultDate.equals("today")){
	defaultDateStr="d.getFullYear()+'/'+ (d.getMonth()+1)+'/'+(d.getDate());document.getElementById('show_d_"+fieldName+"').innerHTML=(d.getMonth()+1)+'/'+(d.getDate())+'/'+d.getFullYear()";
}else if(defaultDate.equals("tomorrow")){	
	defaultDateStr="d.getFullYear()+'/'+ (d.getMonth()+1)+'/'+(d.getDate()+1);document.getElementById('show_d_"+fieldName+"').innerHTML=(d.getMonth()+1)+'/'+(d.getDate()+1)+'/'+d.getFullYear()";
}else if(defaultDate.equals("yearBegin")){
	defaultDateStr="d.getFullYear()+'/'+ 01+'/'+01; document.getElementById('show_d_"+fieldName+"').innerHTML=(01)+'/'+01+'/'+d.getFullYear()";
}else{
	defaultDateStr="'"+defaultDate+"'; document.getElementById('show_d_"+fieldName+"').innerHTML='"+defaultDate.substring(5,7)+"/"+defaultDate.substring(8,10)+"/"+defaultDate.substring(0,4)+"'";
}
%><input type="hidden" name="<%=fieldName%>" id="f_<%=fieldName%>_d"><span class="lineitemsselected" id="show_d_<%=fieldName%>"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c<%=fieldNum%>" style="cursor: pointer; border: 1px solid red;" title="Date selector" onmouseover="this.style.background='red';" onmouseout="this.style.background=''" />
<script type="text/javascript">Calendar.setup({inputField:"f_<%=fieldName%>_d",ifFormat:"%Y-%m-%d",displayArea:"show_d_<%=fieldName%>",daFormat:"%m/%d/%Y",button:"f_trigger_c<%=fieldNum%>",align:"BR",singleClick:true});var d=new Date();document.forms[<%=formNum%>].<%=fieldName%>.value=<%=defaultDateStr%>;</script>