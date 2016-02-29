<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.users.security.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<%

String reportsDirectory = "/";

if(session.getAttribute("roles") != null){
	if(((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).roleCheck("sitehost_manager")){
			reportsDirectory = "/reports/sitehostmanager/";
			}else	 if(((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isVendor()&&(((RoleResolver)session.getAttribute("roles")).roleCheck("vendor_reports"))){
					reportsDirectory = "/reports/vendors/";
			}else	 if(((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isVendor()&&(((RoleResolver)session.getAttribute("roles")).roleCheck("wh_reports"))){
					reportsDirectory = "/reports/warehouse/";
			}else if(((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isVendor()&&!(((RoleResolver)session.getAttribute("roles")).roleCheck("vendor_reports"))){
					reportsDirectory = "/reports/none/";
			}else if(((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isSiteHost()&&(((RoleResolver)session.getAttribute("roles")).roleCheck("sitehost_reports"))){
					reportsDirectory = "/reports/sitehosts/";
			}else if(((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isSiteHost()&&!(((RoleResolver)session.getAttribute("roles")).roleCheck("sitehost_reports"))){
					reportsDirectory = "/reports/none/";
				}else{
					reportsDirectory = "/reports/buyers/";
				}
		}
%><script language="JavaScript">
	window.location.replace("<%= reportsDirectory %>");
	</script>