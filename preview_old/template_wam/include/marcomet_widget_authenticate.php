<?
# authenticate user based on cookie
$valid=true;
$anonymous_login="guest";

if (array_key_exists("user",$_COOKIE) || array_key_exists("user",$_GET) || isset($anonymous_login))
    {
    if (array_key_exists("user",$_COOKIE))
    	{
	    $s=explode("|",$_COOKIE["user"]);
	    $username=mysql_escape_string($s[0]);
	    $session_hash=mysql_escape_string($s[1]);
	    }
	elseif (array_key_exists("user",$_GET))
		{
	    $s=explode("|",$_GET["user"]);
        $username=mysql_escape_string($s[0]);
	    $session_hash=mysql_escape_string($s[1]);
		}
	else
		{
		$username=$anonymous_login;
		$session_hash="";
		}

	$hashsql="and u.session='$session_hash'";
	if (isset($anonymous_login) && ($username==$anonymous_login)) {$hashsql="";} # Automatic anonymous login, do not require session hash.
	
    $userdata=sql_query("select u.ref,u.username,g.permissions,g.fixed_theme,g.parent,u.usergroup,u.current_collection,u.last_active,u.email,u.password,u.fullname,g.search_filter from user u,usergroup g where u.usergroup=g.ref and u.username='$username' $hashsql and (u.account_expires is null or u.account_expires='0000-00-00 00:00:00' or u.account_expires>now())");
    if (count($userdata)>0)
        {
        $valid=true;
        $userref=$userdata[0]["ref"];
        $username=$userdata[0]["username"];
        $userpermissions=split(",",$userdata[0]["permissions"]); #create userpermissions array for checkperm() function
        $usergroup=$userdata[0]["usergroup"];
        $usergroupparent=$userdata[0]["parent"];
        $useremail=$userdata[0]["email"];
        $userpassword=$userdata[0]["password"];
        $userfullname=$userdata[0]["fullname"];
        if (!isset($userfixedtheme)) {$userfixedtheme=$userdata[0]["fixed_theme"];} # only set if not set in config.php
        
        $usercollection=$userdata[0]["current_collection"];
        $usersearchfilter=$userdata[0]["search_filter"];
        
        if (strlen(trim($userdata[0]["last_active"]))>0)
        	{
	        $last_active=time()-strtotime($userdata[0]["last_active"]);
	        if ($last_active>(30*60)) # Last active more than 30 mins ago? This is a new session.
	        	{
	        	#Log this
				daily_stat("User session",$userref);
				}
			}
        }
        else {$valid=false;}
    }
if($username==$anonymous_login) {
		$username = getval("widget_user", "");
		if($username=="") {
			echo "<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8' /><title>Wyndham Asset Management Service</title><link href='http://wam.marcomet.com/DigitalAssets/css/Col-whitegry.css' rel='stylesheet' type='text/css' media=screen,projection,print' id='colourcss' /><link href='http://wam.marcomet.com/DigitalAssets/css/wrdsnpics.css' rel='stylesheet' type='text/css' media='screen,projection,print' /></head><body style='margin-top:60px;'><blockquote style='text-align:left;font-size:14;font-weight:bold;'>You are not currently associated with a site that has images available in the Image Library. Please edit your account settings and enter a valid site number.<br><br>If you are associated already with a site please contact customer service at 888-777-9832. We apologize for the inconvenience.<br><br><div align=center><input type='button' value='Continue' onClick='parent.AjaxModalBox.close();'></div></blockquote></body></html>";
			exit;
		}
		$userdata = sql_query("SELECT * FROM user WHERE username='".str_ireplace("'", "\'", $username)."'");
		if(!isset($userdata[0])) {
			echo "<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8' /><title>Wyndham Asset Management Service</title><link href='http://wam.marcomet.com/DigitalAssets/css/Col-whitegry.css' rel='stylesheet' type='text/css' media=screen,projection,print' id='colourcss' /><link href='http://wam.marcomet.com/DigitalAssets/css/wrdsnpics.css' rel='stylesheet' type='text/css' media='screen,projection,print' /></head><body style='margin-top:60px;'><blockquote style='text-align:left;font-size:14;font-weight:bold;'>You are not currently associated with a site that has images available in the Image Library. Please edit your account settings and enter a valid site number.<br><br>If you are associated already with a site please contact customer service at 888-777-9832. We apologize for the inconvenience.<br><br><div align=center><input type='button' value='Continue' onClick='parent.AjaxModalBox.close();'></div></blockquote></body></html>";
			exit;
		}
		
    $userdata=sql_query("select u.ref,u.username,g.permissions,g.fixed_theme,g.parent,u.usergroup,u.current_collection,u.last_active,u.email,u.password,u.fullname,g.search_filter from user u,usergroup g where u.usergroup=g.ref and u.username='$username' and (u.account_expires is null or u.account_expires='0000-00-00 00:00:00' or u.account_expires>now())");
		
       $valid=true;
        $userref=$userdata[0]["ref"];
        $username=$userdata[0]["username"];
        $userpermissions=split(",",$userdata[0]["permissions"]); #create userpermissions array for checkperm() function
        $usergroup=$userdata[0]["usergroup"];
        $usergroupparent=$userdata[0]["parent"];
        $useremail=$userdata[0]["email"];
        $userpassword=$userdata[0]["password"];
        $userfullname=$userdata[0]["fullname"];
        if (!isset($userfixedtheme)) {$userfixedtheme=$userdata[0]["fixed_theme"];} # only set if not set in config.php
        
        $usercollection=$userdata[0]["current_collection"];
        $usersearchfilter=$userdata[0]["search_filter"];
}
?>
