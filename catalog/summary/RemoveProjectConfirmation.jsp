<%@ page import="java.util.*,com.marcomet.catalog.*,com.marcomet.environment.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%
    int projectId = Integer.parseInt((String) request.getParameter("projectId"));
    boolean confirm = ((request.getParameter("confirm") != null && request.getParameter("confirm").equals("true")) ? true : false);
    boolean submitted = ((request.getParameter("submitted") != null && request.getParameter("submitted").equals("true")) ? true : false);
    String shipmentOption = request.getParameter("shipmentOption");
    SiteHostSettings shs = (SiteHostSettings) session.getAttribute("siteHostSettings");
    ShoppingCart shoppingCart = (ShoppingCart) session.getAttribute("shoppingCart");
    if (shoppingCart != null) {
      Vector projects = shoppingCart.getProjects();
      if (projects.size() == 0) {
      	session.removeAttribute("shoppingCart");
      }
    }
%>
<html>
  <head>
    <title>Confirm Project Deletion</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <%if(submitted){%> <meta http-equiv="REFRESH" content="0;url=/">><%}%>
    <link rel="stylesheet" href="<%=(String) session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
  </head>
  <script language="JavaScript" src="/javascripts/mainlib.js"></script>
  <body  leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/continueover.gif', '/images/buttons/cancelbtover.gif')" background="<%=(String) session.getAttribute("siteHostRoot")%>/images/back3.jpg">
    <form method="post" action="/servlet/com.marcomet.catalog.RemoveProjectServlet">
      <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%" >
        <tr>
          <td height="296">
            <table width="50%" border="0" cellspacing="2" cellpadding="2" align="center">
              <tr>
                <td>
                  <p class="Title">Delete Confirmation</p>
                  <p class="bodyBlack"><!--You are about to remove a job from your shopping
                cart. This job is actually part of a project. In order to remove
                    this job, you must delete the entire project.-->Are you sure you want to remove this job from your shopping cart? <br>
                  </p>
                  <p class="catalogLABEL" align="left">
                  <ul> <%
    //boolean oneProject=false;
    if (shoppingCart != null) {
          Vector projects = shoppingCart.getProjects();
      if (projects.size() > 0) {
        //oneProject=((projects.size()==1)?true:oneProject);
        for (int i = 0; i < projects.size(); i++) {
          ProjectObject po = (ProjectObject) projects.elementAt(i);
          if (projectId == po.getId()) {
            Vector jobs = po.getJobs();
            for (int j = 0; j < jobs.size(); j++) {
              JobObject jo = (JobObject) jobs.elementAt(j);
                    %>
                    <li class="catalogLABEL">Job Id: <%= jo.getId() + ", " + jo.getJobName()%></li>
                    <%
            }
          }
        }
      }else{
      	session.removeAttribute("shoppingCart");
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
      </table>
      <input type="hidden" name="projectId" value="<%= projectId%>">
      <input type="hidden" name="submitted" value="true">
      <input type="hidden" name="shipmentOption" value="<%= shipmentOption%>">
      <%if (confirm) {
      %>
      <input type="hidden" name="$$Return" value="[/catalog/checkout/Checkout.jsp?coStep=step2]">
      <%} else {
      %>
      <input type="hidden" name="$$Return" value="[/catalog/summary/RemoveProjectConfirmation.jsp]">
      <%}%>
    </form>
  </body>
</html>
