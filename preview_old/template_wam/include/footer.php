
<div class="clearer"></div>
</div><!--End div-CentralSpace-->
<? if (($pagename!="login") && ($pagename!="user_password") && ($pagename!="user_request")) { ?></div><? } ?><!--End div-CentralSpaceContainer-->

<div class="clearer"></div>

<? if (($pagename!="login") && ($pagename!="preview") && ($pagename!="change_language") && ($loginterms==false)) { ?>
<!--Global Footer-->
<div id="Footer">

<script language="Javascript">
function SetCookie(cookieName,cookieValue,nDays) {
 var today = new Date();
 var expire = new Date();
 if (nDays==null || nDays==0) nDays=1;
 expire.setTime(today.getTime() + 3600000*24*nDays);
 document.cookie = cookieName+"="+escape(cookieValue)
                 + ";expires="+expire.toGMTString();
}
function SwapCSS(css)
	{
	document.getElementById('colourcss').href='<?=$baseurl?>/css/Col-' + css + '.css';
	top.collections.document.getElementById('colourcss').href='<?=$baseurl?>/css/Col-' + css + '.css';
	SetCookie("colourcss",css,1000);	
	}
</script>

<? if (getval("k","")=="" && ($showfooter)) { ?>
<div id="FooterNavLeft" class=""><? if (isset($userfixedtheme) && $userfixedtheme=="") { ?><?=$lang["interface"]?>:&nbsp;&nbsp;<a href="#" onClick="SwapCSS('greyblu');return false;"><img src="<?=$baseurl?>/gfx/interface/BlueChip.gif" alt="" width="11" height="11" /></a>&nbsp;<a href="#" onClick="SwapCSS('whitegry');return false;"><img src="<?=$baseurl?>/gfx/interface/WhiteChip.gif" alt="" width="11" height="11" /></a>&nbsp;<a href="#" onClick="SwapCSS('black');return false;"><img src="<?=$baseurl?>/gfx/interface/BlackChip.gif" alt="" width="11" height="11" /></a>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<? } ?>
<? if ($disable_languages==false){?>
<?=$lang["language"]?>: <a href="<?=$baseurl?>/change_language.php"><?=$languages[$language]?></a>
<? } ?>
</div>

<div id="FooterNavRight" class="HorizontalNav HorizontalWhiteNav">
		<ul>
		<li><a href="<?=$baseurl?>/home.php"><?=$lang["home"]?></a></li>
		<li><a href="<?=$baseurl?>/about.php"><?=$lang["aboutus"]?></a></li>
		<li><a href="<?=$baseurl?>/contact.php"><?=$lang["contactus"]?></a></li>
<!--	<li><a href="#">Terms&nbsp;&amp;&nbsp;Conditions</a></li>-->
<!--	<li><a href="#">Team&nbsp;Centre</a></li>-->
		</ul>
</div>
<? } ?>

<div id="FooterNavRight" class="OxColourPale"><?=text("footer")?></div>

<div class="clearer"></div>
</div>
<? } ?>



<!--c<?=$querycount?>, t<?=$querytime?>-->
<br />

<? hook("footerbottom"); ?>
</body>
</html>
	
