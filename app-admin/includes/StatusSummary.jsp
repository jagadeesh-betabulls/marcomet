<%@ page import="com.marcomet.users.security.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<p />
<taglib:JobStatusSmallTableTag tableWidth="50%" jobId="<%= request.getParameter(\"jobId\")%>" isVendor="<%= ((RoleResolver)session.getAttribute(\"roles\")).isVendor()%>" />