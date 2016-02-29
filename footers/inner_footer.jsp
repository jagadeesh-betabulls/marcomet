<%@ page errorPage="/errors/ExceptionPage.jsp" %>



<table border="0" cellpadding="0" cellspacing="0" width="100%" height="21">



  <tr align="center"> 



    <td width="70%" style="text-align:center" class="footer" height="20"><font color="#FFFFFF" size="1" face="Arial, Helvetica, sans-serif"><b><font size="2" class="leftnavbaritem"><a href="http://www.marcomet.com" target="_blank" class="footerentry">Site 



      Powered by MarComet, Inc. Copyright &copy; 2000-<%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %> All Rights Reserved.</a></font></b></font></td>



    <td width="19%" style="text-align:center" class="footer" height="20"><a href="javascript:pop('/popups/converter.jsp','140','300')" class="footerentry"> 



      <b>Currency Converter</b></a></td>



    <td width="11%" style="text-align:center" class="footer" height="20"><font color="#FFFFFF" size="1" face="Arial, Helvetica, sans-serif"><b><font size="2" class="leftnavbaritem"><a href="javascript:pop('<%=(String)session.getAttribute("siteHostRoot")%>/contents/contacts.jsp','650','450')" class="footerentry">Contacts 



      </a></font></b></font></td>



  </tr>



</table>



