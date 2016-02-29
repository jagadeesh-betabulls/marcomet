<html>
<head>
<title>System Administration</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body bgcolor="#FFFFFF" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back.jpg" leftmargin="0" topmargin="1" onLoad="MM_preloadImages('../images/buttons/helpbtover.gif')">
<%=((session.getAttribute("roles")==null)?"<script language = javascript> window.location.replace(\"/admin/no_rights.jsp\") </script>":((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).roleCheckRedirect("admin","/admin/no_rights.jsp") )%>
<p class="maintitle"> Administration Menu&nbsp;&nbsp;&nbsp;&nbsp;<a href="/pages/page.jsp?pageName=prodQuickStart" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('help','','/images/buttons/helpbtover.gif',1)" onMouseDown="MM_swapImage('help','','/images/buttons/helpbtdown.gif',1)"><img name="help" border="0" src="/images/buttons/helpbt.gif" width="50" height="20" align="absmiddle"></a></p> 
<blockquote>
  <p>Welcome to the Administration Page for your website. From here you can control 
    and manage the Web Site, its pages, documents and files, maintain corporate 
    information, and other features.</p>
</blockquote>
<ul>
  <li><a href="/common/users/AccountInformationPage.jsp" class="prodSumProductLinks"><span class="prodSumProductLinks">Company's 
    Settings</span> </a><span class=body><br>
    &nbsp;&nbsp;&nbsp;&nbsp; Change default settings for your organization.</span></li>
  <br><br>
  <li><a href="/products/productline_list.jsp" class="prodSumProductLinks"><span class="prodSumProductLinks">Add/Edit 
    Product Lines and Products</span> </a><span class=body><br>
    &nbsp;&nbsp;&nbsp;&nbsp; Manage Product Lines.
    </span> </li>
  <br><br>
  <li><a href="/press_releases/pressrelease_list.jsp?editFlag=true" class="prodSumProductLinks"><span class="prodSumProductLinks">Add/Edit 
    Press Releases</span> </a><span class=body><br>
    &nbsp;&nbsp;&nbsp;&nbsp; Manage the News and Press Releases.</span> </li>
  <br>
  <br>
  <li><a href="/pages/page_list.jsp?editFlag=true" class="prodSumProductLinks"><span class="prodSumProductLinks">Manage 
    Events and Pages</span> </a><span class=body><br>
    &nbsp;&nbsp;&nbsp;&nbsp; Maintain the links that appear on your 'Events' Pages, 
    as well as the misc 'html' type pages throughout the site.</span><br>
  </li>
  <br>
  <li><a href="/jobs/job_list.jsp?editFlag=true" class="prodSumProductLinks"><span class="prodSumProductLinks">Manage 
    Job Listings</span> </a><span class=body><br>
    &nbsp;&nbsp;&nbsp;&nbsp; Add or edit job listings.</span></li>
  <br>
  <br>
  <li><a href="/files/support_page.jsp?editFlag=true" class="prodSumProductLinks"><span class="prodSumProductLinks">Manage/Upload 
    Files</span> </a><span class=body><br>
    &nbsp;&nbsp;&nbsp;&nbsp; Add or modify files available for download..</span></li>
  <br>
  <br>
  <li><a href="/admin/user_list.jsp?editFlag=true" class="prodSumProductLinks"><span class="prodSumProductLinks">Manage 
    Users</span> </a><span class=body><br>
    &nbsp;&nbsp;&nbsp;&nbsp; Add or edit the roles for users of the system</span></li>
  <br>
  <br>
  <li><a href="/files/email_list.jsp?editFlag=true" class="prodSumProductLinks"><span class="prodSumProductLinks">Manage 
    Email/Requests</span> </a><span class=body><br>
    &nbsp;&nbsp;&nbsp;&nbsp; View email log, forward emails,etc.</span> </li>
  <br>
  <br>
  <li><a href="http://starmicronics.marcomet.com/reports/" class="prodSumProductLinks"><span class="prodSumProductLinks">View Usage Statistics</span> </a><span class=body><br>
    &nbsp;&nbsp;&nbsp;&nbsp; View email log, forward emails,etc.</span> (username 
    starmicronics, password starmicronics)</li>	
</ul>
<p>&nbsp;</p>
<p>&nbsp;</p>
