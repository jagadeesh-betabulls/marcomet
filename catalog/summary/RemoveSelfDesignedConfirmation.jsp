<%@ page import="java.util.*,com.marcomet.catalog.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%
if (request.getParameter("submitted")!=null && request.getParameter("submitted").equals("true")){
		ShoppingCart cart = (ShoppingCart)request.getSession().getAttribute("shoppingCart");
		
		if(cart != null){
			Vector projects = cart.getProjects();
			for(int i = 0; i < projects.size(); i++){
				ProjectObject po = (ProjectObject)projects.elementAt(i);
				if(po.getId() == Integer.parseInt((String)request.getParameter("projectId"))){
					cart.removeProject(i);
					break;
				}	
			}
		}
		if(session.getAttribute("selfDesigned").toString().equals("true")){
			session.removeAttribute("usePreview");
			session.removeAttribute("selfDesigned");
		}
	%><html>
<head>
  <title>Confirm File Deletion</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script>
	parent.window.location.replace('/index.jsp?contents=<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostCommerceIndex.jsp')
	</script>
	</head>
	</html><%
}else{%>
<html>
<head>
  <title>Confirm File Deletion</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
</head>
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
<body  leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="MM_preloadImages('/images/buttons/continueover.gif', '/images/buttons/cancelbtover.gif')" background="<%=(String)session.getAttribute("siteHostRoot")%>/images/back3.jpg">
<form method="post" action="/catalog/summary/RemoveSelfDesignedConfirmation.jsp?submitted=true">
  <table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%" >
    <tr> 
      <td height="296"> 
        <table width="50%" border="0" cellspacing="2" cellpadding="2" align="center">
          <tr> 
            <td> 
              <p class="Title">Delete Confirmation</p>
              <p class="bodyBlack"><!--You are about to remove a job from your shopping 
                cart. This job is actually part of a project. In order to remove 
                this job, you must delete the entire project.-->Are you sure you want to cancel editing this file and delete it from the system?<br>
              </p>
              <p class="catalogLABEL" align="left"> 
              <ul> <%
  //boolean oneProject=false;
  ShoppingCart shoppingCart = (ShoppingCart)session.getAttribute("shoppingCart");
  if (shoppingCart != null) {
     Vector projects = shoppingCart.getProjects();
     if (projects.size() > 0) {
     	//oneProject=((projects.size()==1)?true:oneProject);
        for (int i=0; i<projects.size(); i++) { 
           ProjectObject po = (ProjectObject)projects.elementAt(i);
           if ((Integer.parseInt((String)request.getParameter("projectId")) == po.getId())) {
              Vector jobs = po.getJobs();
              for (int j=0; j<jobs.size(); j++) {
                 JobObject jo = (JobObject)jobs.elementAt(j);			
%>
                <li class="catalogLABEL">Job Id: <%= jo.getId()+", " + jo.getJobName()%></li>
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
            <td align="right"> <a href="javascript:history.go(-1)" class="greybutton">No, let me save the file.</a></td>
            <td width="12%">&nbsp;</td>
            <td align="left"> <a href="javascript:document.forms[0].submit()" class="greybutton">Yes, Cancel and Delete the file</a></td>
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
<input type="hidden" name="projectId" value="<%= request.getParameter("projectId")%>">
<input type="hidden" name="$$Return" value="[<%=(String)session.getAttribute("siteHostRoot")%>/contents/SiteHostIndex.jsp]">
</form>
</body>
</html><%}%>
