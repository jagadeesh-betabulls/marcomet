<%@ page import="com.marcomet.users.security.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<p />
<taglib:JobStatusSmallTableTag jobId="<%= request.getParameter(\"jobId\")%>" isVendor="<%= ((RoleResolver)session.getAttribute(\"roles\")).isVendor()%>" />