<html>
<head>
<title>MarketBaymont</title>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/menu_styles.css" type="text/css">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/styles/vendor_styles.css" type="text/css">
<style type="text/css">
<!--
.style2 {
color: #FFFFFF;
font-weight: bold;
}
.style6 {color: #FF0000}
.style7 {color: black; font-weight: bold; font-family: Arial, Helvetica, sans-serif;}
-->
</style>
</head>
<script>
function toggleIt(whichEl){
whichEl.style.display = (whichEl.style.display == "none" ) ? "" : "none";
}
function expandIt(whichEl){
whichEl.style.display =  "";
}
function collapseIt(whichEl){
whichEl.style.display = "none";
}
function collapseAll(){
var divs = document.all.tags('table');
for (var d = 0; d < divs.length; d++){
if (divs[d].id.substring(0,7)=='subMenu'){
divs[d].style.display = 'none';
}
}
// whichEl.style.display = "none";
}
</script>
<body bgcolor="#FFFFFF" leftmargin="0" topmargin="20">
<table width="100%" cellspacing="0" cellpadding="0" height="0">
<tr>
<td valign="top" width="21%"> 
<table align="top" cellpadding=0 cellspacing=0 width=93%>
<tr> 
<td width=100% class="leftNavBarTitle" height=30 align="center" bgcolor="#174076"> 
<div align="left"><font color="#FFFFFF"> <b>&nbsp;&nbsp;Marketing 
&nbsp;Services</b></font></div>
</td>
</tr>
<!--Subs for Custom Marketing -->
<td height="223"> 
<table id="subMenu0" style="display:all" width=100% cellspacing=0 cellpadding=0>
<tr> 
<!--<td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cms1lnk0.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cms1lnk0.className='leftNavBarItem2'" height="30"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/collateral-jd.jsp" class="leftNavBarItem2"  id='cms1lnk0' target="main">J.D. 
Powers Materials</a></td>-->
</tr>
<tr> 
<td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cms1lnk1.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cms1lnk1.className='leftNavBarItem2'" height="30"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/items.jsp?prodLineId=26150200" class="leftNavBarItem2"  id='cms1lnk1' target="main">Post 
Card Mailers</a><font color="#FF0000"><b><font size="1" face="Arial, Helvetica, sans-serif"> 
</font></b></font></td>
</tr>
<td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cms1lnk2.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cms1lnk2.className='leftNavBarItem2'" height="30"> 
<a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/items.jsp?prodLineId=26151011"  id='cms1lnk2' target="main">Posters 
&amp; Signage</a> <font color="#FF0000"><b><font size="1" face="Arial, Helvetica, sans-serif"> 
</font></b></font></td>
<!--<a href="#"   class="leftNavBarItem2"  id='cms1lnk2' target="main">Email Broadcasts</a></td>-->
</tr>
<tr> 
<td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cms1lnk3.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cms1lnk3.className='leftNavBarItem2'" height="30"> 
<a href="#"   class="leftNavBarItem2"  id='cms1lnk3' target="main">Sales 
Letter Mailings</a> <font color="#FF0000"><b><font size="1" face="Arial, Helvetica, sans-serif"> 
- soon</font></b></font></td>
</tr>
<tr> 
<td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cms1lnk4.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cms1lnk4.className='leftNavBarItem2'" height="30"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/advertisements.jsp" class="leftNavBarItem2"  id='cms1lnk4' target="main">Print 
Advertising</a></td>
</tr>
<tr> 
<td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cms1lnk5.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cms1lnk5.className='leftNavBarItem2'" height="30"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/collateral.jsp" class="leftNavBarItem2"  id='cms1lnk5' target="main">Brochures, 
Stationery</a></td>
</tr>
<tr> 
<td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cms1lnk6.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cms1lnk6.className='leftNavBarItem2'" height="30"><a href="#" class="leftNavBarItem2"  id='cms1lnk6' target="main">Logo 
Items/ Gifts</a> <font color="#FF0000"><b><font size="1" face="Arial, Helvetica, sans-serif"> 
- soon</font></b></font></td>
</tr>
<tr> 
<td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cms1lnk7.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cms1lnk7.className='leftNavBarItem2'" height="30"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/gsd.jsp"   class="leftNavBarItem2"  id='cms1lnk7' target="main">Guest 
Services Directories</a></td>
</tr>
<tr> 
<td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cms1lnk8.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cms1lnk8.className='leftNavBarItem2'" height="30"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/items.jsp?prodLineId=26150903""   class="leftNavBarItem2"  id='cms1lnk8' target="main">Holiday Cards</a></td>
</tr>
<tr> 
<td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cms1lnk9.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cms1lnk9.className='leftNavBarItem2'" height="30"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/items.jsp?prodLineId=26150901""   class="leftNavBarItem2"  id='cms1lnk9' target="main">Other 
Items</a></td>
</tr>
<!-- <tr> 
<td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cms1lnk8.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cms1lnk8.className='leftNavBarItem2'" height="30"> 
<a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/items.jsp?prodLineId=244" class="leftNavBarItem2"  id='cms1lnk8' target="main">Holiday Cards</a></td>
</tr> -->
</table>
<table width="100%" height="191" border="0" cellpadding="1" cellspacing="1">
<tr> 
<td height="29">
<div align="center"><a href="javascript:pop('/popups/help.jsp','650','550')" class="innerfooter">Need 
Help? Click Here</a> </div>
</td>
</tr>
<tr> 
<td bgcolor="#E8F3FF" valign="top" > 
<jsp:include page="/includes/ClientARSummary.jsp" flush="true"/>
</td>
</tr>
<tr> 
<td bgcolor="#E8F3FF" valign="top" > 
<jsp:include page="/includes/ClientAppvlSummary.jsp" flush="true"/>
</td>
</tr>
<!--            <tr> 
<td valign="top" bgcolor="#E8F3FF"> <br>
<div align="center"> 
<p><b><font size="1">Tech Support:</font></b><font size="1"> 
Email<br>
<a href="mailto:techsupport@marcomet.com"><u>techsupport@marcomet.com</u></a><br>
or call <b>888-777-9832 option 4</b><br>
<br>
<b>Feedback &amp; Comments:</b><br>
<a href="mailto:comments@marcomet.com"><u>comments@marcomet.com</u></a><br>
<br>
<b>To Change Your User Name:</b> <a href="mailto:newusername@marcomet.com"><u>newusername@marcomet.com</u></a> 
</font></p>
</div>
</td>
</tr>
-->
</table>
</td>
</tr>
<!--Subs for Custom Marketing-->
<!--  <tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk9.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk9.className='leftNavBarItem'" height="14"> 
<a href="#"   class="leftNavBarItem"  id='lnk9'>Lending 
Services </a> </td>
</tr>
<tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk10.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk10.className='leftNavBarItem'" height="16"> 
<a href="#"   class="leftNavBarItem"  id='lnk10'>Managed 
Money </a> </td>
</tr>
<tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk11.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk11.className='leftNavBarItem'" height="14"> 
<a href="#"   class="leftNavBarItem"  id='lnk11'>Mutual 
Funds </a> </td>
</tr>
<tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk12.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk12.className='leftNavBarItem'" height="14"> 
<a href="national_home.htm" target="_parent"  class="leftNavBarItem"  id='lnk12'>National 
Sales </a> </td>
</tr>
<tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk13.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk13.className='leftNavBarItem'" height="14"> 
<a href="#"   class="leftNavBarItem"  id='lnk13'>PruFN/Online 
Account Access</a> </td>
</tr>
<tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk14.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk14.className='leftNavBarItem'" height="14"> 
<a href="#"   class="leftNavBarItem"  id='lnk14'>Portfolio 
Management </a> </td>
</tr>
<tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk15.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk15.className='leftNavBarItem'" height="14"> 
<a href="#"   class="leftNavBarItem"  id='lnk15'>Prestige</a> 
</td>
</tr>
<tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk16.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk16.className='leftNavBarItem'" height="14"> 
<a href="#"   class="leftNavBarItem"  id='lnk16'>Prudential 
Advisor </a> </td>		
</tr>
<tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk17.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk17.className='leftNavBarItem'" height="14"> 
<a href="#"   class="leftNavBarItem"  id='lnk17'>PruArray</a> 
</td>		
</tr>
<tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk18.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk18.className='leftNavBarItem'" height="14"> 
<a href="#"   class="leftNavBarItem"  id='lnk18'>Prudential 
Alliance </a> </td>		
</tr>
<tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk19.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk19.className='leftNavBarItem'" height="14"> 
<a href="#"   class="leftNavBarItem"  id='lnk19'>Retirement 
Services</a> </td>		
</tr>
<tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk20.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk20.className='leftNavBarItem'" height="14"> 
<a href="#"   class="leftNavBarItem"  id='lnk20'>Tax 
Services </a> </td>		
</tr>
<tr>			
<td class="leftNavBarItem" onMouseover="this.className='leftNavBarItemOver';lnk21.className='leftNavBarItemHover'" onMouseout="this.className='leftNavBarItem';lnk21.className='leftNavBarItem'" height="14"> 
<a href="#"   class="leftNavBarItem"  id='lnk21'>Unit 
Investment Trust</a> </td>		
</tr>
-->
</table>
</td>
<td width="79%" valign="top" height="356"> 
<table width="100%" border="0" cellspacing="0" cellpadding="0" align="left" height="319">
<tr> 
<td align="left" valign="bottom" height="2" width="49%"> 
<table width="95%" cellspacing="0" cellpadding="0">
<tr> 
<td class="homeTitles" valign="middle">&nbsp;Welcome to MarketBaymont! </td>
</tr>
</table>
</td>
<td align="left" valign="top" height="2" width="51%"> 
<table width="95%" cellspacing="0" cellpadding="0">
<tr> 
<td class="homeTitles" valign="middle">&nbsp;</td>
</tr>
</table>
</td>
</tr>
<tr> 
<td align="left" valign="top" height="270" class="bodyBlack" width="49%"><table width="100%" cellspacing="2" cellpadding="8">
<tr>
<td width="41%" height="28" valign="middle"><p align="center" class="style7"><font color="#CC3300" face="Arial, Helvetica, sans-serif"><b><font face="Arial, Helvetica, sans-serif"><b><font color="#000000">Folio Folders</font></b></font></b></font>              
<p class="bodyBlack" align="center">
<font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><a href="http://marketbaymont.marcomet.com/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=1001&jobTypeId=1&serviceTypeId=0&productId=3340" target="_top"><img src="<%=(String)session.getAttribute("siteHostRoot")%>/fileuploads/product_images/ST127-BMIS-2.jpg" alt="folio" border="0"></a></font></b></font>
<p align="center"><font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><a href="http://marketbaymont.marcomet.com/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=1001&jobTypeId=1&serviceTypeId=0&productId=3340" class="greybutton" target="_top">Order 
Now!</a></font></b></font> </p></td>
<td width="59%" height="28" valign="middle"><p align="center" class="style7"><font color="#CC3300" face="Arial, Helvetica, sans-serif"><b><font face="Arial, Helvetica, sans-serif"><b><font color="#000000">Sales Folders</font></b></font></b></font></p>
<p align="center"><font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><a href="http://marketbaymont.marcomet.com/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=1001&jobTypeId=1&serviceTypeId=0&productId=3351" target="_top"><img src="<%=(String)session.getAttribute("siteHostRoot")%>/fileuploads/product_images/BR106-BMIS-2.jpg" alt="KCH" border="0"></a></font></b></font></p>
<p align="center"><font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><a href="http://marketbaymont.marcomet.com/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=1001&jobTypeId=1&serviceTypeId=0&productId=3351" class="greybutton" target="_top">Order Now!</a></font></b></font><font size="1"> </font></p></td>
</tr>
<tr>
<td valign="middle" height="68"><p align="center" class="style7"><font color="#CC3300" face="Arial, Helvetica, sans-serif"><b><font face="Arial, Helvetica, sans-serif"><b><font color="#000000">Key Card Holders</font></b></font></b></font></p>
<p align="center"><font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><a href="http://marketbaymont.marcomet.com/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=1001&jobTypeId=1&serviceTypeId=0&productId=3322" target="_top"><img src="<%=(String)session.getAttribute("siteHostRoot")%>/fileuploads/product_images/BR100-BMIS-2.jpg" alt="KCH" border="0"></a></font></b></font></p>
<p align="center"><font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><a href="http://marketbaymont.marcomet.com/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=1001&jobTypeId=1&serviceTypeId=0&productId=3322" class="greybutton" target="_top">Order Now!</a></font></b></font><font size="1"> </font></p></td>
<td valign="middle" height="68"><p align="center" class="style7"><span class="style6"><font face="Arial, Helvetica, sans-serif"><b><font face="Arial, Helvetica, sans-serif"><b>NEW</b></font></b></font></span><font color="#CC3300" face="Arial, Helvetica, sans-serif"><b><font face="Arial, Helvetica, sans-serif"><b><font color="#000000"> Keys</font></b></font></b></font></p>
<p align="center"><font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><a href="http://marketbaymont.marcomet.com/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=1005&jobTypeId=1&serviceTypeId=0&productId=3352" target="_top"><img src="<%=(String)session.getAttribute("siteHostRoot")%>/fileuploads/product_images/BR119-BMIS-2.jpg" alt="KCH" border="0"></a></font></b></font></p>
<p align="center"><font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><a href="http://marketbaymont.marcomet.com/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=1005&jobTypeId=1&serviceTypeId=0&productId=3352" target="_top" class="greybutton" >Order 
Now!</a></font></b></font><font size="1"> </font></p></td>
</tr>
<tr>
<td height="18" colspan="2" valign="middle"><hr align="center"></td>
</tr>
</table></td>
<td align="left" valign="top" height="270" class="bodyBlack" width="51%"> 
<table width="100%" cellspacing="2" cellpadding="8">
<tr>
<td height="192" align="center" valign="middle"><p align="center" class="offeringITEM"><font face="Arial, Helvetica, sans-serif"><b><font face="Arial, Helvetica, sans-serif"><b><span class="style6">NEW</span></b></font></b><font color="#CC3300" face="Arial, Helvetica, sans-serif"><b><b><font color="#000000"><br>
In-Room Guest Services Directories</font></b></b></font></font></p>
<p align="center"><font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/gsd.jsp" target="main" class="greybutton">Click Here!</a></font></b></font></p></td>
<td valign="middle" height="192"><p align="center" class="offeringITEM"><font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/gsd.jsp" target="main"><img src="<%=(String)session.getAttribute("siteHostRoot")%>/images/BMIS-GSD-thumb-sm.jpg" alt="GSD" border="0"></a></font></b></font> </p>                </td>
</tr>
<tr> 
<td valign="middle" height="192" width="41%"> 
<p class="bodyBlack" align="center"><font size="1"> </font><font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/TG.jsp target="_self"></a></font></b></font><font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><img src="<%=(String)session.getAttribute("siteHostRoot")%>/images/bm.jpg" border="0"></font></b></font>                </td>
<td valign="middle" height="192" width="59%"> 
<p align="center" class="offeringITEM"><font color="#CC3300" face="Arial, Helvetica, sans-serif"><font face="Arial, Helvetica, sans-serif"><font color="#000000">Welcome<br>
New Baymont Inn &amp; Suites<br>
Hotel Locations</font></font></font></p>
<p align="center"><font color="#CC3300" face="Arial, Helvetica, sans-serif" size="3"><b><font size="2"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/TG.jsp" target="_self" class="greybutton"> 
Click Here!</a></font></b></font><font size="1"> </font></p>                </td>
</tr>
<tr> 
<td valign="top" height="37" colspan="2"> 
<br> <hr align="center"></td>
</tr>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>
</body>
</html>

