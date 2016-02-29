<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*,com.marcomet.environment.*,java.util.*,com.marcomet.catalog.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<jsp:useBean id="formater" class="com.marcomet.tools.FormaterTool" scope="page" />
<%
	if(session.getAttribute("lastRow")!=null){session.removeAttribute("lastRow");}
	if(session.getAttribute("lastCol")!=null){session.removeAttribute("lastCol");}
	if(session.getAttribute("selfDesigned")!=null){session.removeAttribute("selfDesigned");}
	if(session.getAttribute("reprintJob")!=null){session.removeAttribute("reprintJob");}
	if(session.getAttribute("priorJobId")!=null){session.removeAttribute("priorJobId");}	
	
    UserProfile up = (UserProfile) session.getAttribute("userProfile");
    DecimalFormat numberFormatter = new DecimalFormat("#,###,###");
    SiteHostSettings shs = (SiteHostSettings) session.getAttribute("siteHostSettings");
    boolean editor = (((RoleResolver) session.getAttribute("roles")).roleCheck("editor"));
    String spPageId = "";
    int co_days = 0;
    Double subtot=0.00;
    int jobId = 0;
    String fileName = "";
    int poId = 0;
    boolean ordersPresent = false;
    ShoppingCart shoppingCart = (ShoppingCart) session.getAttribute("shoppingCart");
    if (shoppingCart != null) {
    	Vector projects = shoppingCart.getProjects();
    	if (projects.size() > 0) {
	    	%><table width="200" align="center" class="body" style="border: 1px gray;"><tr><td colspan="4" class="subtitle"><div align='center'>Your Orders:<br></div></td></tr><tr><td class="planheader1" colspan="2">Item</td><td class="planheader1" >Qty</td><td class="planheader1" >Price</td></tr><%
    		int jobCount = -1;
   	 		int jobNo = (request.getParameter("jobNo") != null) ? Integer.parseInt(request.getParameter("jobNo")) : -1;
        		for (int j = 0; j < projects.size(); j++) {
          			jobCount = j;
          			ProjectObject po = (ProjectObject) projects.elementAt(j);
          			Vector jobs = po.getJobs();
          			for (int k = 0; k < jobs.size(); k++) {
            			JobObject jo = (JobObject) jobs.elementAt(k);
            			double price = jo.getPrice();
            			subtot += jo.getPrice();
            			ordersPresent = true;
				   		%><tr>
			            <td class="lineitems" width="2%"><div align="center"><a href="/catalog/summary/RemoveProjectConfirmation.jsp?projectId=<%= po.getId() + ""%>" class="minderACTION"  style="color:red;font-weight:bold;"><img src="/images/delete.jpg" border="0" alt="Remove this job from your shopping cart."></a></div></td>
			            <td class="lineitems" width="80%"><a href="javascript:pop('/catalog/summary/OrderSummaryJobDetails.jsp?jobId=<%= jo.getId()%>','500','500')" class="minderACTION" style="font-size:8pt;"><%=jo.getProductName()%></a></td>
			            <td class="lineitems" width="9%" ><div align="right"  style="font-size:8pt; padding-left:2px;padding-right:1px;"><%=((jo.getQuantity() == 0) ? "NA" : numberFormatter.format(jo.getQuantity()))%></div></td>
			            <td class="lineitems" width="9%"><div align="right"  style="font-size:8pt; padding-left:2px;padding-right:1px;"><%= (jo.isRFQ()) ? "RFQ" : formater.getCurrency(price)%></div></td>
			          </tr><%
                	}
              	}
              	%><tr><td colspan="3"><div align="right" style="font-size:8pt;" class="subtitle">Subtotal:</div></td><td><div align="right"  class="subtitle" style="font-size:8pt;"><%=formater.getCurrency(subtot)%></div></td></tr><%
		}
     	if (ordersPresent) {
    		%><tr><td valign="bottom" colspan="4" align="center"><br><span id="shipOption1" style="display:inline;">
    		<a target="_top" href="https://<%=(String)session.getAttribute("baseURL")%>/frames/InnerFrameset.jsp?contents=/contents/secureSite.jsp" class="menuLINK"><strong><img src='/images/cart.gif' border='0'>&nbsp;SECURE&nbsp;CHECKOUT</strong></a></span></td></tr></table><hr size=1 color=gray><%
  		}else{
  			shoppingCart=null;
  		}
    }%>