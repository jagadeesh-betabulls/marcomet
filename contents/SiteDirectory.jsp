<%@ page contentType="text/html; charset=iso-8859-1" language="java" import="java.sql.*" errorPage="" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Marketing Services Support Center</title>
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/menu_styles.css" type="text/css">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles2.css" type="text/css">
<style>
	li {
	font-family: Arial, Helvetica, Geneva, sans-serif;
	color: #5c5c5c;
	list-style-type: circle;
	list-style-position: outside;
	line-height: 150%;
}
A:hover {
	border-top: 1px solid #52bef1;
	border-bottom: 1px solid #52bef1;
}
</style>
</head>
<body bgcolor="#FFFFFF">
<p class="subtitle">The following sites are currently being managed by Procurement Services, click on the URL go to that site in a new window.</p>
		<table cellpadding=5 cellspacing=0 >
		  <tr>
		    <td class='menuLINK'><b>Brand / Audience</b></td>
		    <td class='menuLINK'><b>Site Name</b></td>
		    <td class='menuLINK'><b>Site Type</b></td>
		    <td class='menuLINK'><b>URL</b></td>
		  </tr>
		  <tr>
		    <td class='lineitems'>Wingate Inns</td>
		    <td class='lineitems'>WinMarketing</td>
		    <td class='lineitems'>Marketing Services</td>
		    <td class='lineitems'><a href="http://www.winmarketing.us" target="_blank" class='subtitle1'>www.winmarketing.us</a></td>
		  </tr>
		  <tr>
		    <td class='lineitems'>Ramada</td>
		    <td class='lineitems'>MarketRamada</td>
		    <td class='lineitems'>Marketing Services</td>
		    <td class='lineitems'><a href="http://www.marketramada.com" target="_blank" class='subtitle1'>www.marketramada.com</a></td>
		  </tr>
<!--		  <tr>
		    <td class='lineitems'>Ramada</td>
		    <td class='lineitems'>BrandRamada</td>
		    <td class='lineitems'>Brand ID</td>
		    <td class='lineitems'><a href="http://www.brandramada.com" target="_blank" class='subtitle1'>www.brandramada.com</a></td>
		  </tr> -->
		  <tr>
		    <td class='lineitems'>Howard Johnson</td>
		    <td class='lineitems'>How2MarketHJ</td>
		    <td class='lineitems'>Marketing Services</td>
		    <td class='lineitems'><a href="http://www.how2markethj.com" target="_blank" class='subtitle1'>www.how2markethj.com</a></td>
		  </tr>
		  <tr>
		    <td class='lineitems'>Travelodge</td>
		    <td class='lineitems'>MarketTheBear</td>
		    <td class='lineitems'>Marketing Services</td>
		    <td class='lineitems'><a href="http://www.marketthebear.com" target="_blank" class='subtitle1'>www.marketthebear.com</a></td>
		  </tr>
		  <tr>
		    <td class='lineitems'>Days Inns</td>
		    <td class='lineitems'>MarketDaysInn</td>
		    <td class='lineitems'>Marketing Services</td>
		    <td class='lineitems'><a href="http://www.marketdaysinn.com" target="_blank" class='subtitle1'>www.marketdaysinn.com</a></td>
		  </tr>
		  <tr>
		    <td class='lineitems'>Wyndham Franchise Sales</td>
		    <td class='lineitems'>ThePowerOfConnection</td>
		    <td class='lineitems'>Marketing Services</td>
		    <td class='lineitems'><a href="http://www.thepowerofconnection.com" target="_blank" class='subtitle1'>www.thepowerofconnection.com</a></td>
		  </tr>
		  <tr>
		    <td class='lineitems'>AmeriHost Inns</td>
		    <td class='lineitems'>InnMarketing - NOTE: Site is phased out, not in use.</td>
		    <td class='lineitems'>Marketing Services</td>
		    <td class='lineitems'>www.innmarketing.us</td>
		  </tr>
		  <tr>
		    <td class='lineitems'>Baymont Inns &amp; Suites</td>
		    <td class='lineitems'>MarketBaymont</td>
		    <td class='lineitems'>Marketing Services</td>
		    <td class='lineitems'><a href="http://www.marketbaymont.com" target="_blank" class='subtitle1'>www.marketbaymont.com</a></td>
		  </tr>
		  <tr>
		    <td class='lineitems'>Baymont Inns &amp; Suites</td>
		    <td class='lineitems'>BrandBaymont</td>
		    <td class='lineitems'>Brand ID</td>
		    <td class='lineitems'><a href="http://www.brandbaymont.com" target="_blank" class='subtitle1'>www.brandbaymont.com</a></td>
		  </tr>
	</table>
		<br /><br />
<%if (1==2){%><p class='subtitle'>Logins for SiteHost Role access:</p>
		<table cellpadding=0 cellspacing=0 %>
		  <tr>
		    <td class='menuLINK' colspan=2>&nbsp;</td>
		    <td class='menuLINK'>WINMARKETING:</td>
		    <td class='menuLINK'>AMERIHOST</td>
		    <td class='menuLINK'>MARKETRAMADA</td>
		    <td class='menuLINK'>HOW2MARKETHJ</td>
		    <td class='menuLINK'>MARKETTHEBEAR</td>
		    <td class='menuLINK'  >MARKETDAYSINN</td>
		    <td  class='menuLINK' >MARKETBAYMONT</td>
		    <td  class='menuLINK'>THEPOWEROFCONNECTION</td>
		 </tr>
		 <tr>
		    <td class='lineitems' colspan=2>username:</td>
		    <td class='lineitems'>winsite</td>
		    <td class='lineitems'>amerisite</td>
		    <td class='lineitems'>ramadasite</td>
		    <td class='lineitems'>hjsite</td>
		    <td class='lineitems'>tlsite</td>
		    <td class='lineitems'>disite</td>
		    <td class='lineitems'>baysite</td>
		    <td class='lineitems'>fransales</td>
		 </tr>
		 <tr>
		    <td class='lineitems'></td>
		    <td class='lineitems'>password:</td>
		    <td class='lineitems'>password</td>
		    <td class='lineitems'>password</td>
		    <td class='lineitems'>password</td>
		    <td class='lineitems'>password</td>
		    <td class='lineitems'>password</td>
		    <td class='lineitems'>password</td>
		    <td class='lineitems'>password</td>
		    <td class='lineitems'>password</td>
		 </tr>
</table><%}%>
</body>
</html>
