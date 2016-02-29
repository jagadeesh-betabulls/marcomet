<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="com.marcomet.users.security.RoleResolver, com.marcomet.environment.SiteHostSettings" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%
    SiteHostSettings shs = (SiteHostSettings) session.getAttribute("siteHostSettings");
    String targetStr=sl.getValue("site_hosts","id",shs.getSiteHostId(),"sh_target");
    if(session.getAttribute("homeNotice")!=null){
    	session.setAttribute("homeNotice",((session.getAttribute("homeNotice")==null)?"":session.getAttribute("homeNotice").toString().replace("target='mainFr'","target='"+targetStr+"'").replace("target='main'","target='"+targetStr+"'")));
    }
%><div class='lineitemsselected' align='center'><span class='subtitle'><%=((session.getAttribute("homeNotice")==null)?"":session.getAttribute("homeNotice").toString())%></span></div>