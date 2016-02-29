<?
# Collections functions
# Functions to manipulate collections

function get_user_collections($user)
	{
	# Returns a list of user collections.
	# Additionally, if the user hasn't got any collections, then create a default 'My Collection'.
	#$list=sql_query("select c.*,u.username,count(r.resource) count from user u,collection c left outer join collection_resource r on c.ref=r.collection where u.ref=c.user and c.user='$user' group by c.ref union select c.*,u.username,count(r.resource) count from user_collection uc left join collection c on uc.collection=c.ref left outer join collection_resource r on c.ref=r.collection left join user u on c.user=u.ref where uc.user='$user' group by c.ref order by created;");
	$list=sql_query("select * from (select c.*,u.username,count(r.resource) count from user u,collection c left outer join collection_resource r on c.ref=r.collection where u.ref=c.user and c.user='$user' and (length(c.theme)=0 or c.theme is null) group by c.ref union select c.*,u.username,count(r.resource) count from user_collection uc,collection c left outer join collection_resource r on c.ref=r.collection left join user u on c.user=u.ref where uc.collection=c.ref and uc.user='$user' and c.user<>'$user' and (length(c.theme)=0 or c.theme is null) group by c.ref) clist order by name='My Collection' desc,name");
	return $list;
	}

function get_collection($ref)
	{
	# Returns all data for collection $ref
	$return=sql_query("select * from collection where ref='$ref'");
	if (count($return)==0) {return false;} else 
		{
		$return=$return[0];
		if ($return["public"]==0)
			{
			# If private, also return a list of users with access to this collection
			$return["users"]=join(", ",sql_array("select u.username value from user u,user_collection c where u.ref=c.user and c.collection='$ref' order by u.username"));
			}
		return $return;}
	}

function get_collection_resources($collection)
	{
	# Returns all resources in collection
	# For many cases (e.g. when displaying a collection for a user) a search is used instead so permissions etc. are honoured.
	return sql_array("select resource value from collection_resource where collection='$collection' order by date_added desc"); 
	}
	
function add_resource_to_collection($resource,$collection)
	{
	$collectiondata=get_collection($collection);
	global $userref;
	if (($userref==$collectiondata["user"]) || ($collectiondata["allow_changes"]==1) || (checkperm("h")))
		{	
		sql_query("delete from collection_resource where resource='$resource' and collection='$collection'");
		sql_query("insert into collection_resource(resource,collection) values ('$resource','$collection')");
		return true;
		}
	else
		{
		return false;
		}
	}

function remove_resource_from_collection($resource,$collection)
	{
	$collectiondata=get_collection($collection);
	global $userref;
	if (($userref==$collectiondata["user"]) || ($collectiondata["allow_changes"]==1) || (checkperm("h")))
		{	
		sql_query("delete from collection_resource where resource='$resource' and collection='$collection'");
		return true;
		}
	else
		{
		return false;
		}
	}
	
function set_user_collection($user,$collection)
	{
	global $usercollection;
	sql_query("update user set current_collection='$collection' where ref='$user'");
	$usercollection=$collection;
	}
	
function create_collection($userid,$name,$allowchanges=0,$cant_delete=0)
	{
	# Creates a new collection and returns the reference
	sql_query("insert into collection (name,user,created,allow_changes,cant_delete) values ('" . escape_check($name) . "','$userid',now(),'$allowchanges','$cant_delete')");
	return sql_insert_id();
	}	
	
function delete_collection($ref)
	{
	# Deletes the collection with reference $ref
	sql_query("delete from collection where ref='$ref'");
	}
	
function refresh_collection_frame()
	{
	global $headerinsert,$baseurl;
	$headerinsert.="<script language=\"Javascript\">
	top.collections.location.href=\"" . $baseurl . "/collections.php?nc=" . time() . "\";
	</script>";
	}
	
function search_public_collections($search)
	{
	if ($search!="") {$qsearch="and (c.name like '%$search%' or u.username like '%$search%' or c.ref='$search')";} else {$qsearch="";}
	return sql_query("select c.*,u.username from collection c,user u where c.user=u.ref and c.public=1 $qsearch and (length(c.theme)=0 or c.theme is null) order by c.created desc");
	}
	
function add_collection($user,$collection)
	{
	# Add a collection to a user's 'My Collections'
	
	# Remove any existing collection first
	remove_collection($user,$collection);
	# Insert row
	sql_query("insert into user_collection(user,collection) values ('$user','$collection')");
	}

function remove_collection($user,$collection)
	{
	# Remove someone else's collection from a user's My Collections
	sql_query("delete from user_collection where user='$user' and collection='$collection'");
	}

function save_collection($ref)
	{
	$theme=getvalescaped("theme","");
	if (getval("newtheme","")!="") {$theme=getvalescaped("newtheme","");}
	$allow_changes=(getval("allow_changes","")!=""?1:0);
	
	# Next line disabled as it seems incorrect to override the user's setting here. 20071217 DH.
	#if ($theme!="") {$allow_changes=0;} # lock allow changes to off if this is a theme
	
	# Update collection with submitted form data
	sql_query("update collection set
				name='" . getvalescaped("name","") . "',
				public='" . getvalescaped("public","") . "',
				theme='" . $theme . "',
				allow_changes='" . $allow_changes . "'
	where ref='$ref'");
	
	# Reset archive status if specified
	if (getval("archive","")!="")
		{
		sql_query("update resource set archive='" . getvalescaped("archive",0) . "' where ref in (select resource from collection_resource where collection='$ref')");
		}
		
	# If 'users' is specified (i.e. access is private) then rebuild users list
	$users=getvalescaped("users",false);
	if ($users!==false)
		{
		sql_query("delete from user_collection where collection='$ref'");
		if (($users)!="")
			{
			# Build a new list and insert
			$ulist=array_unique(trim_array(explode(",",$users)));
			$urefs=sql_array("select ref value from user where username in ('" . join("','",$ulist) . "')");
			sql_query("insert into user_collection(collection,user) values ($ref," . join("),(" . $ref . ",",$urefs) . ")");
			}
		}
		
	# Relate all resources?
	if (getval("relateall","")!="")
		{
		$rlist=get_collection_resources($ref);
		for ($n=0;$n<count($rlist);$n++)
			{
			for ($m=0;$m<count($rlist);$m++)
				{
				if ($rlist[$n]!=$rlist[$m]) # Don't relate a resource to itself
					{
					sql_query("insert into resource_related (resource,related) values ('" . $rlist[$n] . "','" . $rlist[$m] . "')");
					}
				}
			}
		}
	
	
	# Remove all resources?
	if (getval("removeall","")!="")
		{
		sql_query("delete from collection_resource where collection='$ref'");
		}
		
	# Delete all resources?
	if (getval("deleteall","")!="")
		{
		$resources=do_search("!collection" . $ref);
		for ($n=0;$n<count($resources);$n++)
			{
			if (checkperm("e" . $resources[$n]["archive"]))
				{
				delete_resource($resources[$n]["ref"]);	
				}
			}
		}
	}

function get_theme_headers()
	{
	# Return a list of theme headers, i.e. theme categories
	#return sql_array("select theme value,count(*) c from collection where public=1 and length(theme)>0 group by theme order by theme");
		
	$return=array();
	$themes=sql_query("select * from collection where public=1 and theme is not null and length(theme)>0 order by theme");
	for ($n=0;$n<count($themes);$n++)
		{
		if ((!in_array($themes[$n]["theme"],$return)) && (checkperm("j*") || checkperm("j" . $themes[$n]["theme"]))) {$return[]=$themes[$n]["theme"];}
		}
	return $return;
	}

function get_themes($header)
	{
	return sql_query("select * from collection where theme='" . escape_check($header) . "' and public=1 order by name");
	}

function email_collection($collection,$collectionname,$fromusername,$userlist,$message)
	{
	# Attempt to resolve all users in the string $userlist to user references.
	# Add $collection to these user's 'My Collections' page
	# Send them an e-mail linking to this collection
	global $baseurl,$email_from,$applicationname,$lang;
	
	if (trim($userlist)=="") {return ($lang["mustspecifyoneusername"]);}
	$ulist=trim_array(explode(",",$userlist));
	$emails=array();
	$key_required=array();
	
	for ($n=0;$n<count($ulist);$n++)
		{
		$uname=$ulist[$n];
		$email=sql_value("select email value from user where username='" . escape_check($uname) . "'",'');
		if ($email=='')
			{
			# Not a recognised user, if @ sign present, assume e-mail address specified
			if (strpos($uname,"@")===false) {return($lang["couldnotmatchallusernames"]);}
			$emails[$n]=$uname;
			$key_required[$n]=true;
			}
		else
			{
			# Add e-mail address from user accunt
			$emails[$n]=$email;
			$key_required[$n]=false;
			}
		}

	# Add the collection to the user's My Collections page
	$urefs=sql_array("select ref value from user where username in ('" . join("','",$ulist) . "')");
	if (count($urefs)>0) {sql_query("insert into user_collection(collection,user) values ($collection," . join("),(" . $collection . ",",$urefs) . ")");}
		
	# Send an e-mail to each resolved user

	$subject="$applicationname: $collectionname";
	if ($message!="") {$message="\n\n" . $lang["message"] . ": " . str_replace(array("\\n","\\r","\\"),array("\n","\r",""),$message);}
	for ($n=0;$n<count($emails);$n++)
		{
		$key="";
		# Do we need to add an external access key for this user (e-mail specified rather than username)?
		if ($key_required[$n])
			{
			$k=substr(md5(time()),0,10);
			$r=get_collection_resources($collection);
			for ($m=0;$m<count($r);$m++)
				{
				# Add the key to each resource in the collection
				sql_query("insert into external_access_keys(resource,access_key) values ('" . $r[$m] . "','$k');");
				}
			$key="&k=". $k;
			}
		$body="$fromusername " . $lang["emailcollectionmessage"] . "$message\n\n" . $lang["clicklinkviewcollection"] . "\n\n" . $baseurl . 	"/index.php?c=" . $collection . $key;
		send_mail($emails[$n],$subject,$body);
		}
		
	# Return an empty string (all OK).
	return "";
	}

function get_saved_searches($collection)
	{
	return sql_query("select * from collection_savedsearch where collection='$collection' order by created");
	}

function add_saved_search($collection)
	{
	sql_query("insert into collection_savedsearch(collection,search,restypes,archive) values ('$collection','" . getvalescaped("addsearch","") . "','" . getvalescaped("restypes","") . "','" . getvalescaped("archive","") . "')");
	}

function remove_saved_search($collection,$search)
	{
	sql_query("delete from collection_savedsearch where collection='$collection' and ref='$search'");
	}

function add_saved_search_items($collection)
	{
	$results=do_search(getvalescaped("addsearch",""), getvalescaped("restypes",""), "relevance", getvalescaped("archive",""));
	for ($n=0;$n<count($results);$n++)
		{
		$resource=$results[$n]["ref"];
		sql_query("delete from collection_resource where resource='$resource' and collection='$collection'");
		sql_query("insert into collection_resource(resource,collection) values ('$resource','$collection')");
 		}
	}

function allow_multi_edit($collection)
	{
	# Returns true or false, can this collection be edited as a multi-edit?
	# All the resources must be of the same type and status for this to work.
	
	# Updated: 2008-01-21: Edit all now supports multiple types, so always return true.
	return (true);
	
	/*
	$types=sql_query("select distinct r.resource_type from collection_resource c left join resource r on c.resource=r.ref where c.collection='$collection'");
	if (count($types)!=1) {return false;}
	
	$status=sql_query("select distinct r.archive from collection_resource c left join resource r on c.resource=r.ref where c.collection='$collection'");
	if (count($status)!=1) {return false;}	
	
	return true;
	*/
	}

function get_theme_image($theme)
	{
	$image=sql_value("select r.ref value from collection c join collection_resource cr on c.ref=cr.collection join resource r on cr.resource=r.ref where c.theme='" . escape_check($theme) . "' and r.has_image=1 order by r.hit_count desc limit 1",0);
	if ($image==0) {return false;} else {return get_resource_path($image,"col",false);}
	}

function swap_collection_order($resource1,$resource2,$collection)
	{
	# Swaps the position of two resources within a collection.
	$pos1=sql_value("select date_added value from collection_resource where collection='$collection' and resource='$resource1'",0);
	$pos2=sql_value("select date_added value from collection_resource where collection='$collection' and resource='$resource2'",0);

	sql_query("update collection_resource set date_added='$pos2' where resource='$resource1' and collection='$collection'");
	sql_query("update collection_resource set date_added='$pos1' where resource='$resource2' and collection='$collection'");

	}

function get_collection_resource_comment($resource,$collection)
	{
	$data=sql_query("select * from collection_resource where collection='$collection' and resource='$resource'","");
	return $data[0];
	}
	
function save_collection_resource_comment($resource,$collection,$comment,$rating)
	{
	sql_query("update collection_resource set comment='$comment',rating='$rating' where resource='$resource' and collection='$collection'");
	return true;
	}

function relate_to_collection($ref,$collection)	
	{
	# Relates every resource in $collection to $ref
		$colresources = get_collection_resources($collection);
		sql_query("delete from resource_related where resource='$ref' and related in ('" . join("','",$colresources) . "')");  
		sql_query("insert into resource_related(resource,related) values ($ref," . join("),(" . $ref . ",",$colresources) . ")");
	}	
	
function get_mycollection_name($userref)
	{
	# Fetches the next name for a new My Collection for the given user (My Collection 1, 2 etc.)
	global $lang;
	for ($n=2;$n<500;$n++)
		{
		$name=$lang["mycollection"] . " " . $n;
		$ref=sql_value("select ref value from collection where user='$userref' and name='$name'",0);
		if ($ref==0)
			{
			# No match!
			return $name;
			}
		}
	# Tried nearly 500 names(!) so just return a standard name 
	return $lang["mycollection"];
	}
?>
