<%@ page import="java.util.*,com.marcomet.catalog.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<html>
  <head>
    <title>Confirm Job Deletion</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  </head>
  <script language="JavaScript" src="/javascripts/mainlib.js"></script>
  <body  leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/continueover.gif', '/images/buttons/cancelbtover.gif')" background="<%=(String) session.getAttribute("siteHostRoot")%>/images/back3.jpg">
    <form method="post" action="/servlet/com.marcomet.catalog.RemoveJobServlet">
      <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%" >
        <tr>
          <td height="296">
            <table width="50%" border="0" cellspacing="2" cellpadding="2" align="center">
              <tr>
                <td>
                  <p class="Title">Delete Confirmation</p>
                  <p class="bodyBlack">Are you sure you want to remove this job from your shopping cart? <br>
                  </p>
                  <p class="catalogLABEL" align="left">
                  <ul>
                    <%
    ShoppingCart shoppingCart = (ShoppingCart) session.getAttribute("shoppingCart");
    if (shoppingCart != null) {
      Vector shipments = shoppingCart.getShipments();
      if (shipments.size() > 0) {
        for (int i = 0; i < shipments.size(); i++) {
          ShipmentObject so = (ShipmentObject) shipments.elementAt(i);
          Vector jobs = so.getJobs();
          for (int j = 0; j < jobs.size(); j++) {
            JobObject jo = (JobObject) jobs.elementAt(j);
            if (jo.getId() == Integer.parseInt((String) request.getParameter("jobId"))) {
                    %>
                    <li class="catalogLABEL">Job Id: <%= jo.getId() + ", " + jo.getJobName()%></li>
                    <%
            }
          }
        }
      }
    }
                    %>
                  </ul>
                </td>
              </tr>
            </table>

          </td>
        </tr>
        <tr>
          <td>
            <table align="center">
              <tr>
                <td align="right"> <a href="javascript:history.go(-1)" class="greybutton">Cancel</a></td>
                <td width="12%">&nbsp;</td>
                <td align="left"> <a href="javascript:document.forms[0].submit()" class="greybutton">Delete</a></td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td valign="bottom">
            <jsp:include page="/footers/inner_footer.jsp" flush="true"></jsp:include>
          </td>
        </tr>
      </table>
      <input type="hidden" name="jobId" value="<%= request.getParameter("jobId")%>">
      <input type="hidden" name="$$Return" value="[/]">
    </form>
  </body>
</html>