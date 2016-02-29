<?
/*
	Name: drop_parser.php
	Description: This file includes the functions neccessary to parse and add a droppped file.
	Created: 6/23/08
	By: Zachary Cimafonte
	Copyright: Marcomet 2008
*/

// The global debug flag
$debug_enabled = false;

/*
	Function Name: DebugEcho
	Description: If debugging is enabled it echos the string.
*/
function DebugEcho($debug_string) {
	global $debug_enabled;
	if($debug_enabled) echo $debug_string;
}


/*
	Function Name: GetStateFullname
	Description: Looks up an abbreviated state in the database to determine it's full name.
*/
function GetStateFullname($state) {
	$result = sql_query("SELECT state_name FROM lu_states WHERE state_abreviation='$state'");
	return $result[0]["state_name"];
}


/*
	Function Name: parse_drop_filename
	Description: Parses the dropped file's filename and adds the image with it's correct information.
	NOTES: $e is a boolean value that determines if debug printing is enabled.
*/


function parse_drop_filename($original_filepath, $e) {
	global $drop_folders_directory;
	$real_file_path = explode($drop_folders_directory, $original_filepath);
	$split_file_path = explode("/", $real_file_path[1]);
	$original_filename = $split_file_path[count($split_file_path)-1];
	$site_photos = false;
	$filename = $original_filename;
	// Set the debug flag
	global $debug_enabled;
	$debug_enabled = $e;
	// Check if it's a Site Photo
	if($split_file_path[0]=="Site Photos") {
		// The current default values are stored in the image with 'ref' 72. Change $DEFAULT_IMAGE_REF to change it.
		$DEFAULT_IMAGE_REF = 72;
		// Store the original filename to prevent destruction
		$original_filename = $filename;
		$filename = ltrim($filename,"0");
		// Get the file extension of the file by splitting it up by periods
		$name_extentsion = explode(".", $filename);
		// Take out the extension and split up the filename into an array
		$split_filename = explode("_", $name_extentsion[0]);
		// Parse the site number and look up the site in the properties table
		$site_number = $split_filename[0];
		if(!($site = sql_query("SELECT * from wyndham_properties WHERE site_number=$site_number"))) {
			echo "2";
			exit;
		}
		
		// Set the begginning of the title
		$title = $site[0]["site_name"].",";
		
		$resource_type = 3;
		// Loop through the codes and complete the title
		for($i=1;$i<count($split_filename);$i++) {
			if(!$name = sql_query("SELECT * from filename_codes WHERE code='".$split_filename[$i]."'")) {
				echo "3";
				exit;
			}
			$title .= " ".$name[0]["name"];
			// Set the resource type
			$resource_type = $name[0]["resource_type"];
		}
		
		// NOTE: The caption is the same as the title for now
		
		// Brand
		$brand = sql_query("SELECT description FROM wyndham_chain_codes WHERE chain_code = '".$site[0]["Chain_code"]."'"); // TODO: Why is Chain_code uppercase?
		// Use the first returned description
		$brand = $brand[0]['description'];
		
		// City, State
		$city_state = $site[0]['city'].", ".GetStateFullname($site[0]["state"])." ".$site[0]["state"];
		
		// Add the image to the photoserver
		
		// Create the resource
		// TODO: Use correct userref by changing it after the copy
		$resource_ref = copy_resource($DEFAULT_IMAGE_REF, $resource_type); //create_resource(1,0,-1);
		
		// Set the username to the site ID and add the resource to the collection
		$user = sql_query("SELECT * FROM user WHERE username=$site_number");
		$set_user = sql_query("UPDATE resource SET created_by=".$user[0]["ref"]);
		$collection = sql_query("SELECT * FROM collection WHERE user=".$user[0]["ref"]);
		$set_collection = sql_query("INSERT into collection_resource(collection, resource, date_added) VALUES (".$collection[0]["ref"].", $resource_ref, now())");
		
		// Get the path for our resource
		$filepath=get_resource_path($resource_ref,"",true,$name_extentsion[1]);
		// Copy the file into the path and set it's permissions
		copy($original_filepath, $filepath);
		chmod($filepath,0777);
		
		// Set the file extension for the reference in the database
		sql_query("update resource set preview_extension='".$name_extentsion[1]."' where ref='$resource_ref'");
		sql_query("update resource set file_extension='".$name_extentsion[1]."' where ref='$resource_ref'");
		
		// Set the original filename
		update_field($resource_ref,51,$original_filename);
	
		// Set the brand
		update_field($resource_ref,63,$brand);
		
		// Create the preview images
		create_previews($resource_ref,false,$name_extentsion[1]);
		
		// Ok, the image was added into the imageserver, now we must populate the information
		extract_exif_comment($resource_ref);
		
		// Add the keywords
		$resource_keywords = $site_number." ".$city_state." ".$brand;
		add_keyword_mappings($resource_ref, $resource_keywords, 1);
		
		// Set the title
		sql_query("UPDATE resource set title='".$title."' where ref='$resource_ref'");
		update_field($resource_ref,8,$title);
		
		// Set the caption
		update_field($resource_ref,18,$title);
		
		// Set the property site ID
		update_field($resource_ref,60,$site_number);
		update_field($resource_ref,61,$site_number);
		
		// Set the date
		$date_result = sql_query("UPDATE resource SET creation_date=now() WHERE ref=$resource_ref");
		$date_result = sql_query("SELECT creation_date FROM resource WHERE ref=$resource_ref");
		update_field($resource_ref,12,$date_result[0]["creation_date"]);	
		
		// There are no variants, make this image a master
		update_field($resource_ref,66,"no");
		
		// Log this			
		daily_stat("Create resource",$resource_ref);
		resource_log($resource_ref,'c',0);
		
		// Success
		echo "1";
		return true;
	}		
	// Store the original filename to prevent destruction
	$original_filename = $filename;
	// Get the file extension of the file by splitting it up by periods
	$name_extentsion = explode(".", $filename);
	
	$site = "na";
	$site_number = "na";
	
	// Set the begginning of the title
	$title = $name_extentsion[0];
	
	$resource_type = 3;
	if(!($resource_type = sql_query("SELECT * from resource_type WHERE name='".$split_file_path[0]."'"))) {
			// Invalid resource type
			echo "4";
			exit;
	}
	$resource_type = $resource_type[0]["ref"];
	
	// NOTE: The caption is the same as the title for now
	
	// Brand
	$brand = $split_file_path[1];
	
	// Add the image to the photoserver
	
	// Create the resource
	// TODO: Use correct userref by changing it after the copy
	$resource_ref = create_resource($resource_type,0,6902);
	
	// Set the username to the site ID and add the resource to the collection
	$user = sql_query("SELECT * FROM user WHERE ref=6902");
	
	// Get the path for our resource
	$filepath=get_resource_path($resource_ref,"",true,$name_extentsion[1]);
	// Copy the file into the path and set it's permissions
	copy($original_filepath, $filepath);
	chmod($filepath,0777);
	
	// Set the file extension for the reference in the database
    sql_query("update resource set preview_extension='".$name_extentsion[1]."' where ref='$resource_ref'");
    sql_query("update resource set file_extension='".$name_extentsion[1]."' where ref='$resource_ref'");
	

	// Set the original filename
	update_field($resource_ref,51,$original_filename);

	// Set the brand
	update_field($resource_ref,63,$brand);
	
	// Create the preview images
	create_previews($resource_ref,false,$name_extentsion[1]);
	
	// Ok, the image was added into the imageserver, now we must populate the information
	extract_exif_comment($resource_ref);
	
	// Add the keywords
	$resource_keywords = $brand;
	add_keyword_mappings($resource_ref, $resource_keywords, 1);
	
	// Set the title
    sql_query("UPDATE resource set title='".$title."' where ref='$resource_ref'");
    update_field($resource_ref,8,$title);
    
    // Set the caption
    update_field($resource_ref,18,$title);
    
    // Set the property site ID
    if($resource_type==3) {
	    update_field($resource_ref,64,$site_number);
	} else {
	    update_field($resource_ref,65,$site_number);
	}
    
    // Set the date
    $date_result = sql_query("UPDATE resource SET creation_date=now() WHERE ref=$resource_ref");
    $date_result = sql_query("SELECT creation_date FROM resource WHERE ref=$resource_ref");
    update_field($resource_ref,12,$date_result[0]["creation_date"]);
	$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '$title.%' AND resource <> $resource_ref");
	// Check to see if this image is a format variant, and if it is label it as such and relate it to the master
	if(count($variants)>0) {
		$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
		if(count($master)>0) {
		// Check to see if this image is CMYK
		//identify -format %r 
			// There are variants of this image, so we must make it related to the master variant
			$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
		} else {
			// There are variants of this image, so we must make it related to the master variant
			$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
		}
		// is_child_variant
		update_field($resource_ref,66,"yes");
	} else {
		// is_child_variant
		update_field($resource_ref,66,"no");
	}
	
	// Log this
	daily_stat("Create resource",$resource_ref);
	resource_log($resource_ref,'c',0);
	
	// Success
	echo "1";
	return true;

}

?>