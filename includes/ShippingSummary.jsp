<%@ page import="com.marcomet.users.security.*" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<hr size="1">
<div class="subtitle1">Job Shipping Detail:</div>
<taglib:JobShippingDetailTag tableWidth="100%" jobId="<%= request.getParameter(\"jobId\")%>" isVendor="<%= ((RoleResolver)session.getAttribute(\"roles\")).isVendor()%>" />