
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/formTagLib.tld" prefix="formtaglib" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%String companyId=session.getAttribute("companyId").toString();
String contactId=session.getAttribute("contactId").toString();
%>
<html>
<head>
<META HTTP-EQUIV="pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Pragma-directive" CONTENT="no-cache">
<META HTTP-EQUIV="cache-directive" CONTENT="no-cache">
<title>Filters</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/javascripts/jscalendar/calendar-win2k-1.css" type="text/css">
<script type="text/javascript" src="/javascripts/jscalendar/calendar.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/lang/calendar-en.js"></script>
<script type="text/javascript" src="/javascripts/jscalendar/calendar-setup.js"></script>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
</head>
<body bgcolor="#FFFFFF" text="#000000" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/reports/buyers/orderHistory.jsp">
  <p class="TITLE">Order History Report Generator 
    <input type="hidden" name="companyId" value="<%=companyId%>">
    <input type="hidden" name="contactId" value="<%=contactId%>">
  </p>
  <p></p>
  <blockquote><div align="center" style="width:400px;border:1 solid;"><br>
          By: <select name="reportType"  >
          <option value="1">By Date</option>
          <option value="2">By Root Product</option>
        </select><br><br>
&nbsp;&nbsp;Order Date From:&nbsp;<input type="hidden" name="dateFrom" id="f_datefrom_d"><span class="lineitemsselected" id="show_d"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c"
				     style="cursor: pointer; border: 1px solid red;"
				     title="Date selector"
				     onmouseover="this.style.background='red';"
				     onmouseout="this.style.background=''" />
					<script type="text/javascript">
					    Calendar.setup({
					        inputField     :    "f_datefrom_d",
					        ifFormat       :    "%Y-%m-%d",
					        displayArea    :    "show_d",
					        daFormat       :    "%m-%d-%Y",
					        button         :    "f_trigger_c",
					        align          :    "BR",
					        singleClick    :    true
					    });
						var d=new Date();
						document.forms[0].dateFrom.value=d.getFullYear()+"-01-01";
document.getElementById('show_d').innerHTML="01-01-"+d.getFullYear();
					</script>
				<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Order Date To:&nbsp;</span>
					<input type="hidden" name="dateTo" id="f_dateto_d">
					<span class="lineitemsselected" id="show_dt"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c2"
							     style="cursor: pointer; border: 1px solid red;"
							     title="Date selector"
							     onmouseover="this.style.background='red';"
							     onmouseout="this.style.background=''" />
								<script type="text/javascript">
								    Calendar.setup({
								        inputField     :    "f_dateto_d",
								        ifFormat       :    "%Y-%m-%d",
								        displayArea    :    "show_dt",
								        daFormat       :    "%m-%d-%Y",
								        button         :    "f_trigger_c2",
								        align          :    "BR",
								        singleClick    :    true
								    });
									var d=new Date()
									document.forms[0].dateTo.value=d.getFullYear()+"-"+ (d.getMonth()+1)+"-"+d.getDate();									document.getElementById('show_dt').innerHTML=(d.getMonth()+1)+"-"+d.getDate()+"-"+d.getFullYear();
								</script><br><br>
<br><a href="/reports/buyers/" class='greybutton'>&nbsp;EXIT&nbsp;</a>&nbsp;&nbsp;&nbsp;<a href="javascript:document.forms[0].submit();" class='greybutton'>&nbsp;CREATE REPORT&nbsp;</a><br>&nbsp;</div>
</blockquote>
<input type="hidden" name="siteHostCompanyFromText" value="">
<input type="hidden" name="siteHostCompanyToText" value="">
<input type="hidden" name="buyerCompanyFromText" value="">
<input type="hidden" name="buyerCompanyToText" value="">
</form>
</body>
</html>
