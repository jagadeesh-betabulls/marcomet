<?
/*
	Name: drop_parser.php
	Description: This file includes the functions neccessary to parse and add a droppped file.
	Created: 6/23/08
	By: Zachary Cimafonte
	Copyright: Marcomet 2008
*/

// The global debug flag
$debug_enabled = true;

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

function parse_drop_filename($original_filepath, $return_res_id) {
	global $created_by_ref;
	$original_filepath = $original_filepath;
	global $drop_folders_directory;
	$real_file_path = explode($drop_folders_directory, $original_filepath);
	$split_file_path = explode("/", $real_file_path[1]);
	$safe_path = str_replace("\"", "\\\"", str_replace("\\", "\\\\", $original_filepath));
	$original_filename = $split_file_path[count($split_file_path)-1];
	
	if(stripos($original_filename, ".")===false) {	
		// Fix files with no filename
		$format = shell_exec("identify -format %r \"$safe_path\"");
		if(substr($format, 0, 50)!="identify: no decode delegate for this image format") {
			// Append the extension to the file
			rename($original_filepath, $original_filepath.strtolower($format));
			$original_filepath = $original_filepath.strtolower($format);
			$real_file_path = explode($drop_folders_directory, $original_filepath);
			$split_file_path = explode("/", $real_file_path[1]);
			$safe_path = str_replace("\"", "\\\"", str_replace("\\", "\\\\", $original_filepath));
			$original_filename = $split_file_path[count($split_file_path)-1];
		} else {
			return "6";
			exit;
		}
	}
	
	$site_photos = false;
	$filename = $original_filename;
	// The current default values are stored in the image with 'ref' -72. Change $DEFAULT_IMAGE_REF to change it.
	$DEFAULT_IMAGE_REF = -72;
	// Store the original filename to prevent destruction
	$original_filename = $filename;
	// Get the file extension of the file by splitting it up by periods
	$name_extentsion = array(substr($filename, 0, strrpos($filename, ".")), substr($filename, strrpos($filename, ".")+1)); // explode(".", $filename);
	$version = 0;
	// Check if it's a Site Photo
	global $tmpimport;
	if($split_file_path[0]=="Site Photos" || $tmpimport=="no") {
		// Determine if a duplicate site photo exists with the same colorspace
		$colorspace = shell_exec("identify -format %r \"$safe_path\"");
		if(substr(trim($colorspace), -4)=="CMYK") {
			$colorspace = "CMYK";
		} else {
			$colorspace = "RGB";
		}
		
		
		/*if(!$tmpimport=="yes") {
		// Look in the database for duplicates
		$duplicates = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value='".str_replace("'", "\\'", $filename)."' AND resource IN (SELECT resource from resource_data WHERE resource_type_field=67 AND value='$colorspace' OR value='') AND resource IN (SELECT ref from resource WHERE archive<>2)");
		if(isset($duplicates[0])) {
			// A duplicate exists in the database
			$version = sql_query("SELECT * from resource_data WHERE resource_type_field = 68 AND resource IN (SELECT * from resource_data WHERE resource_type_field=67 AND value='$colorspace' OR value='') AND resource IN (SELECT ref from resource WHERE archive<>2)");
			if(isset($version[0])) {
				$version = $version[0]["value"];
				$version += 1;
			} else {
				$version = 1;
			}
			// Archive the old version
			$archive_old_resource = sql_query("UPDATE resource SET archive=2 WHERE ref IN (SELECT resource FROM resource_data WHERE resource_type_field=51 AND value='".str_replace("'", "\\'", $filename)."')");
		}
		}*/
		
		
		$duplicates = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value='".str_replace("'", "\\'", $filename)."' AND resource IN (SELECT resource from resource_data WHERE resource_type_field=67 AND value='$colorspace' OR value='') AND resource IN (SELECT ref from resource WHERE archive<>2)");
		if(isset($duplicates[0])) {
			// A duplicate exists in the database
			// FIXME
			///$version = sql_query("SELECT * from resource_data WHERE resource_type_field = 68 AND resource IN (SELECT * from resource_data WHERE resource_type_field=67 AND value='$colorspace' OR value='') AND resource IN (SELECT ref from resource WHERE archive<>2)");
			if(isset($version[0])) {
				$version = $version[0]["value"];
				$version += 1;
			} else {
				$version = 1;
			}
			// Archive the old version
			$archive_old_resource = sql_query("UPDATE resource SET archive=2 WHERE ref IN (SELECT resource FROM resource_data WHERE resource_type_field=51 AND value='".str_replace("'", "\\'", $filename)."')");
		}
		
		// Take out the extension and split up the filename into an array
		$split_filename = explode("_", $name_extentsion[0]);
		// Parse the site number and look up the site in the properties table
		$site_number = ltrim($split_filename[0], "0");
		if(!($site = sql_query("SELECT * from wyndham_properties WHERE site_number='$site_number'"))) {
			return "2";
			exit;
		}
		
		// Set the beginning of the title
		$title = $site[0]["site_name"].",";
		
		$resource_type = 3;
		// Loop through the codes and complete the title
		for($i=1;$i<count($split_filename);$i++) {
			if(!$name = sql_query("SELECT * from filename_codes WHERE code='".$split_filename[$i]."'")) {
				// return "3";
				// exit;
				$title .= " ".$split_filename[$i];
			} else {
				$title .= " ".$name[0]["name"];
				// Set the resource type
				$resource_type = $name[0]["resource_type"];
			}
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
		$user = sql_query("SELECT * FROM user WHERE username='$site_number'");
		$set_user = sql_query("UPDATE resource SET created_by=\"".$user[0]["ref"]."\" WHERE ref='$resource_ref'");
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
		$resource_keywords = ltrim($site_number, "0")." ".$city_state." ".$brand;
		add_keyword_mappings($resource_ref, $resource_keywords, 1);
		
		$interior = sql_query("SELECT * from resource WHERE ref=$resource_ref");
		$interior = $interior[0]["resource_type"];
		if($interior==1)add_keyword_mappings($resource_ref, "bedroom", 1);
		
		// Set the title
		sql_query("UPDATE resource set title='".str_replace("'", "\\'", $title)."' where ref='$resource_ref'");
		update_field($resource_ref,8,$title);
		
		// Set the caption
		update_field($resource_ref,18,$title);
		
		// Set the property site ID
		update_field($resource_ref,60,$site_number);
		update_field($resource_ref,61,$site_number);
		
		// Set the version
		update_field($resource_ref, 68, $version);
		
		// Set the date
		$date_result = sql_query("UPDATE resource SET creation_date=now() WHERE ref=$resource_ref");
		$date_result = sql_query("SELECT creation_date FROM resource WHERE ref=$resource_ref");
		update_field($resource_ref,12,$date_result[0]["creation_date"]);	
		
		// There are no variants, make this image a master
		update_field($resource_ref,66,"no");
		
		// Fill the colorspace field with the detected colorspace
		$safe_path = str_replace("\"", "\\\"", str_replace("\\", "\\\\", $original_filepath));
		$colorspace = shell_exec("identify -format %r \"$safe_path\"");
		if(substr(trim($colorspace), -4)=="CMYK") {
			update_field($resource_ref, 67, "CMYK");
			$colorspace = "CMYK";
		} else {
			update_field($resource_ref, 67, "RGB");
			$colorspace = "RGB";
		}
		
		// Log this			
		daily_stat("Create resource",$resource_ref);
		resource_log($resource_ref,'c',0);
		
		// Success
		if($return_res_id) return $resource_ref;
		return "1";
		return true;
	}
	
	
	
	
	
	if($split_file_path[0]=="Personnel Photo") {
		// Determine if a duplicate site photo exists with the same colorspace
		$colorspace = shell_exec("identify -format %r \"$safe_path\"");
		if(substr(trim($colorspace), -4)=="CMYK") {
			$colorspace = "CMYK";
		} else {
			$colorspace = "RGB";
		}
		// Look in the database for duplicates
		$duplicates = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value='".str_replace("'", "\\'", $filename)."' AND resource IN (SELECT resource from resource_data WHERE resource_type_field=67 AND value='$colorspace' OR value='') AND resource IN (SELECT ref from resource WHERE archive<>2)");
		if(isset($duplicates[0])) {
			// A duplicate exists in the database
			$version = sql_query("SELECT * from resource_data WHERE resource_type_field = 68 AND resource IN (SELECT resource from resource_data WHERE resource_type_field=67 AND value='$colorspace' OR value='') AND resource IN (SELECT ref from resource WHERE archive<>2)");
			if(isset($version[0])) {
				$version = $version[0]["value"];
				$version += 1;
			} else {
				$version = 1;
			}
			// Archive the old version
			$archive_old_resource = sql_query("UPDATE resource SET archive=2 WHERE ref IN (SELECT resource FROM resource_data WHERE resource_type_field=51 AND value='".str_replace("'", "\\'", $filename)."')");
		}
		
		$site = "na";
		$site_number = "na";
		
		// Parse the filename
		$parsed_filename = split("_", $name_extentsion[0]);
		
		$firstname = ucwords(strtolower($parsed_filename[0]));
		$lastname = ucwords(strtolower($parsed_filename[1]));
		$other = implode(" ", array_slice($parsed_filename, 2));
		
		// Set the begginning of the title
		$title = "$lastname, $firstname";
		
		$resource_type = 6;
		
		// NOTE: The caption is the same as the title for now
		
		// Brand
		$brand = $split_file_path[1];
		
		// Add the image to the photoserver
		
		// Create the resource
		// TODO: Use correct userref by changing it after the copy
		$resource_ref = create_resource($resource_type,0,6902);
		
		// Set the username to the site ID and add the resource to the collection
		$user = "";
		if(isset($created_by_ref)) {
			$user = sql_query("SELECT * FROM user WHERE ref='$created_by_ref'");
			$set_user = sql_query("UPDATE resource SET created_by=\"".$user[0]["ref"]."\" WHERE ref='$resource_ref'");
			$collection = sql_query("SELECT * FROM collection WHERE user=".$user[0]["ref"]);
			$set_collection = sql_query("INSERT into collection_resource(collection, resource, date_added) VALUES (".$collection[0]["ref"].", $resource_ref, now())");
		} else {
			$user = sql_query("SELECT * FROM user WHERE ref=6902");
		}
		
		// Get the path for our resource
		$filepath=get_resource_path($resource_ref,"",true,$name_extentsion[1]);
		// Copy the file into the path and set it's permissions
		copy($original_filepath, $filepath);
		chmod($filepath,0777);
		
		// Set the file extension for the reference in the database
		sql_query("update resource set preview_extension='jpg' where ref='$resource_ref'");
		sql_query("update resource set file_extension='".$name_extentsion[1]."' where ref='$resource_ref'");
		
	
		// Set the first name
		update_field($resource_ref,70,$firstname);
		// Set the last name
		update_field($resource_ref,71,$lastname);
	
		// Set the original filename
		update_field($resource_ref,51,$original_filename);
	
		// Set the brand
		update_field($resource_ref,63,$brand);
		
		// Create the preview images
		create_previews($resource_ref,false,$name_extentsion[1]); //"jpg");
		
		// Ok, the image was added into the imageserver, now we must populate the information
		extract_exif_comment($resource_ref);
		
		// Add the keywords
		$resource_keywords = $brand;
		add_keyword_mappings($resource_ref, $resource_keywords, 1);
		
		// Add the other keywords
		add_keyword_mappings($resource_ref, $other, 1);
		
		// Replace underscores and dashes with spaces in the title
		$title = str_replace("_", " ", $title);
		$title = str_replace("-", " ", $title);
		
		// Set the title
		sql_query("UPDATE resource set title='".str_replace("'", "\\'", $title)."' where ref='$resource_ref'");
		update_field($resource_ref,8,$title);
		
		// Set the caption
		update_field($resource_ref,18,$title);
		
		// Set the Allowable Use and copyright
		$field_defaults = sql_query("SELECT default_text FROM default_text WHERE ref=-1 AND resource_type_field_id=58");
		update_field($resource_ref,58,$field_defaults[0]["default_text"]);
		
		// Set the Copyright
		$field_defaults = sql_query("SELECT default_text FROM default_text WHERE ref=-1 AND resource_type_field_id=59");
		update_field($resource_ref,59,$field_defaults[0]["default_text"]);
		
		// Fill the colorspace field with the detected colorspace
		$safe_path = str_replace("\"", "\\\"", str_replace("\\", "\\\\", $original_filepath));
		$colorspace = shell_exec("identify -format %r \"$safe_path\"");
		if(substr(trim($colorspace), -4)=="CMYK") {
			update_field($resource_ref, 67, "CMYK");
			$colorspace = "CMYK";
		} else {
			update_field($resource_ref, 67, "RGB");
			$colorspace = "RGB";
		}
		
		// Set the version
		update_field($resource_ref, 68, $version);
		
		
		
		// Set the date
		$date_result = sql_query("UPDATE resource SET creation_date=now() WHERE ref=$resource_ref");
		$date_result = sql_query("SELECT creation_date FROM resource WHERE ref=$resource_ref");
		update_field($resource_ref,12,$date_result[0]["creation_date"]);
		$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref  AND resource IN (SELECT ref from resource WHERE archive<>2)");
		// Check to see if this image is a format variant, and if it is label it as such and relate it to the master
		if(count($variants)>0) {
			// Check for a bitmap master or variant
			$bitmap_mv = sql_query("SELECT * FROM resource WHERE file_extension = 'jpg' OR file_extension = 'jpeg' OR file_extension = 'gif' OR file_extension = 'png' OR file_extension = 'tiff' OR file_extension = 'psd' OR file_extension = 'bmp' OR file_extension = 'pdf' AND ref IN (SELECT resource from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref) AND ref IN (SELECT ref from resource WHERE archive<>2)");
			if(isset($bitmap_mv[0])) {
				// Yes a bitmap exists, is our current image a bitmap?
				if($name_extentsion[1]=="jpg" || $name_extentsion[1]=="jpeg") {
					// It's a JPEG, is it CMYK?
					if($colorspace=="CMYK") {
						// Yes it's CMYK, so this image takes precedence over all others
						// This image is not a child variant
						update_field($resource_ref,66,"no");
						// Set the other images as variants
						$set_variants = sql_query("UPDATE resource_data SET value='yes' WHERE resource_type_field=66 AND resource IN (SELECT a.resource FROM (SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref) AS a)");
						// Relate this image as the master to the other images
						$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
						if(count($master)>0) {
							// There are variants of this image, so we must make it related to the master variant
							
							$set_format_variants = sql_query("UPDATE resource_format_variants SET resource=$resource_ref WHERE resource=".$master[0]["resource"]." AND resource IN (SELECT resource from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref)");
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$resource_ref."', '".$master[0]["resource"]."')");
	
						} else {
							// There are variants of this image, so we must make it related to the master variant
							$set_format_variants = sql_query("UPDATE resource_format_variants SET resource=$resource_ref WHERE resource=".$variants[0]["resource"]." AND resource IN (SELECT resource from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref)");
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$resource_ref."', '".$variants[0]["resource"]."')");
						}
					} else {
						// Does a CMYK JPEG exist?
						//echo "CYMK called.";
						$rgb_jpg_exists = sql_query("SELECT * FROM resource_data WHERE value='CMYK' AND resource_type_field=67 AND resource IN (SELECT ref FROM resource WHERE file_extension = 'jpg' OR file_extension = 'jpeg' AND resource IN (SELECT ref from resource WHERE archive<>2) AND ref IN (SELECT resource from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref))");
						if(isset($rgb_jpg_exists[0])) {
							// A CMYK JPEG exists so make this image a variant
							$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
							if(count($master)>0) {
								// There are variants of this image, so we must make it related to the master variant
								$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
							} else {
								// There are variants of this image, so we must make it related to the master variant
								$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
							}
							//echo "here";
							// is_child_variant
							update_field($resource_ref,66,"no");
							
												// Set the other images as variants
						$set_variants = sql_query("UPDATE resource_data SET value='yes' WHERE resource_type_field=66 AND resource IN (SELECT a.resource FROM (SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref) AS a)");
						// Relate this image as the master to the other images
						$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
							
							// Log this
							daily_stat("Create resource",$resource_ref);
							resource_log($resource_ref,'c',0);
							
							// Success
							if($return_res_id) return $resource_ref;
							return "1";
							return true;
							
						} else {
							// Make this image a master
							// This image is not a child variant
							update_field($resource_ref,66,"no");
							// Set the other images as variants
							$set_variants = sql_query("UPDATE resource_data SET value='yes' WHERE resource_type_field=66 AND resource IN (SELECT a.resource FROM (SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref) AS a)");
							// Relate this image as the master to the other images
							$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
							if(count($master)>0) {
								// There are variants of this image, so we must make it related to the master variant
								$set_format_variants = sql_query("UPDATE resource_format_variants SET resource=$resource_ref WHERE resource=".$master[0]["resource"]." AND resource IN (SELECT resource from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref)");
							} else {
								// There are variants of this image, so we must make it related to the master variant
								$set_format_variants = sql_query("UPDATE resource_format_variants SET resource=$resource_ref WHERE resource=".$variants[0]["resource"]." AND resource IN (SELECT resource from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref)");
							}
						}
					}
				}
				if($name_extentsion[1]=="gif") {
					// Is there a jpg variant already?
					$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpg' OR value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpeg' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
					if(isset($variants[0])) {
						// There already is a jpg, make this a variant
						update_field($resource_ref,66,"yes");
						$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
						if(count($master)>0) {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
						} else {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
						}
					} else {
						// Make this a master
						update_field($resource_ref,66,"no");
					}
					
				}
				if($name_extentsion[1]=="png") {
					// Is there a jpg variant already?
					$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpg' OR value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpeg' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
					if(isset($variants[0])) {
						// There already is a jpg, make this a variant
						update_field($resource_ref,66,"yes");
						$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
						if(count($master)>0) {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
						} else {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
						}
					} else {
						// Make this a master
						update_field($resource_ref,66,"no");
					}
					
				}
				if($name_extentsion[1]=="tiff") {
					// Is there a jpg variant already?
					$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpg' OR value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpeg' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
					if(isset($variants[0])) {
						// There already is a jpg, make this a variant
						update_field($resource_ref,66,"yes");
						$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
						if(count($master)>0) {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
						} else {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
						}
					} else {
						// Make this a master
						update_field($resource_ref,66,"no");
					}
					
				}
				if($name_extentsion[1]=="psd") {
					// Is there a jpg variant already?
					$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpg' OR value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpeg' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
					if(isset($variants[0])) {
						// There already is a jpg, make this a variant
						update_field($resource_ref,66,"yes");
						$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
						if(count($master)>0) {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
						} else {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
						}
					} else {
						// Make this a master
						update_field($resource_ref,66,"no");
					}
					
				}
				if($name_extentsion[1]=="bmp") {
					// Is there a jpg variant already?
					$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpg' OR value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpeg' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
					if(isset($variants[0])) {
						// There already is a jpg, make this a variant
						update_field($resource_ref,66,"yes");
						$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
						if(count($master)>0) {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
						} else {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
						}
					} else {
						// Make this a master
						update_field($resource_ref,66,"no");
					}
					
				}
				if($name_extentsion[1]=="pdf") {
					// Is there a jpg variant already?
					$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpg' OR value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpeg' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
					if(isset($variants[0])) {
						// There already is a jpg, make this a variant
						update_field($resource_ref,66,"yes");
						$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
						if(count($master)>0) {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
						} else {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
						}
					} else {
						// Make this a master
						update_field($resource_ref,66,"no");
					}
					
				}
			} else {
				// No bitmap exists
				// Is there a variant already?
				//echo "bad";
				$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
				if(isset($variants[0])) {
					// There already is a master, make this a variant
					update_field($resource_ref,66,"yes");
					$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
					if(count($master)>0) {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
					} else {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
					}
				} else {
					// Make this a master
					update_field($resource_ref,66,"no");
				}
			}
			
			
			$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
			if(count($master)>0) {
				// There are variants of this image, so we must make it related to the master variant
				$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
			} else {
				// There are variants of this image, so we must make it related to the master variant
				$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
			}
			//echo "222";
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
		if($return_res_id) return $resource_ref;
		return "1";
		return true;
	
	}
	
	
	
	
	
	// Determine if a duplicate site photo exists with the same colorspace
	$colorspace = shell_exec("identify -format %r \"$safe_path\"");
	if(substr(trim($colorspace), -4)=="CMYK") {
		$colorspace = "CMYK";
	} else {
		$colorspace = "RGB";
	}
	// Look in the database for duplicates
	$duplicates = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value='".str_replace("'", "\\'", $filename)."' AND resource IN (SELECT resource from resource_data WHERE resource_type_field=67 AND value='$colorspace' OR value='') AND resource IN (SELECT ref from resource WHERE archive<>2)");
	if(isset($duplicates[0])) {
		// A duplicate exists in the database
		$version = sql_query("SELECT * from resource_data WHERE resource_type_field = 68 AND resource IN (SELECT resource from resource_data WHERE resource_type_field=67 AND value='$colorspace' OR value='') AND resource IN (SELECT ref from resource WHERE archive<>2)");
		if(isset($version[0])) {
			$version = $version[0]["value"];
			$version += 1;
		} else {
			$version = 1;
		}
		// Archive the old version
		$archive_old_resource = sql_query("UPDATE resource SET archive=2 WHERE ref IN (SELECT resource FROM resource_data WHERE resource_type_field=51 AND value='".str_replace("'", "\\'", $filename)."')");
	}
	
	$site = "na";
	$site_number = "na";
	
	// Set the begginning of the title
	$title = $name_extentsion[0];
	
	$resource_type = 3;
	if(!($resource_type = sql_query("SELECT * from resource_type WHERE name='".$split_file_path[0]."'"))) {
			// Invalid resource type
			return "4";
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
	$user = "";
	if(isset($created_by_ref)) {
		$user = sql_query("SELECT * FROM user WHERE ref='$created_by_ref'");
		$set_user = sql_query("UPDATE resource SET created_by=\"".$user[0]["ref"]."\" WHERE ref='$resource_ref'");
		$collection = sql_query("SELECT * FROM collection WHERE user=".$user[0]["ref"]);
		$set_collection = sql_query("INSERT into collection_resource(collection, resource, date_added) VALUES (".$collection[0]["ref"].", $resource_ref, now())");
	} else {
		$user = sql_query("SELECT * FROM user WHERE ref=6902");
	}
	
	// Get the path for our resource
	$filepath=get_resource_path($resource_ref,"",true,$name_extentsion[1]);
	// Copy the file into the path and set it's permissions
	copy($original_filepath, $filepath);
	chmod($filepath,0777);
	
	// Set the file extension for the reference in the database
    sql_query("update resource set preview_extension='jpg' where ref='$resource_ref'");
    sql_query("update resource set file_extension='".$name_extentsion[1]."' where ref='$resource_ref'");
	

	// Set the original filename
	update_field($resource_ref,51,$original_filename);

	// Set the brand
	update_field($resource_ref,63,$brand);
	
	// Create the preview images
	create_previews($resource_ref,false,$name_extentsion[1]); //"jpg");
	
	// Ok, the image was added into the imageserver, now we must populate the information
	extract_exif_comment($resource_ref);
	
	// Add the keywords
	$resource_keywords = $brand;
	add_keyword_mappings($resource_ref, $resource_keywords, 1);
	
	// Replace underscores and dashes with spaces in the title
	$title = str_replace("_", " ", $title);
	$title = str_replace("-", " ", $title);
	
	// Add everything in the title as a keyword
	add_keyword_mappings($resource_ref, $title, 1);
	
	// Set the title
    sql_query("UPDATE resource set title='".str_replace("'", "\\'", $title)."' where ref='$resource_ref'");
    update_field($resource_ref,8,$title);
    
    // Set the caption
    update_field($resource_ref,18,$title);
    
	// Set the Allowable Use and copyright
	$field_defaults = sql_query("SELECT default_text FROM default_text WHERE ref=-1 AND resource_type_field_id=58");
	update_field($resource_ref,58,$field_defaults[0]["default_text"]);
	
	// Set the Copyright
	$field_defaults = sql_query("SELECT default_text FROM default_text WHERE ref=-1 AND resource_type_field_id=59");
	update_field($resource_ref,59,$field_defaults[0]["default_text"]);
    
    // Set the property site ID
    if($resource_type==3) {
	    update_field($resource_ref,64,$site_number);
	} else {
	    update_field($resource_ref,65,$site_number);
	}
    
    
    // Fill the colorspace field with the detected colorspace
	$safe_path = str_replace("\"", "\\\"", str_replace("\\", "\\\\", $original_filepath));
	$colorspace = shell_exec("identify -format %r \"$safe_path\"");
	if(substr(trim($colorspace), -4)=="CMYK") {
		update_field($resource_ref, 67, "CMYK");
		$colorspace = "CMYK";
	} else {
		update_field($resource_ref, 67, "RGB");
		$colorspace = "RGB";
	}
	
	// Set the version
	update_field($resource_ref, 68, $version);
    
    
    
    // Set the date
    $date_result = sql_query("UPDATE resource SET creation_date=now() WHERE ref=$resource_ref");
    $date_result = sql_query("SELECT creation_date FROM resource WHERE ref=$resource_ref");
    update_field($resource_ref,12,$date_result[0]["creation_date"]);
	$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref  AND resource IN (SELECT ref from resource WHERE archive<>2)");
	// Check to see if this image is a format variant, and if it is label it as such and relate it to the master
	if(count($variants)>0) {
		// Check for a bitmap master or variant
		$bitmap_mv = sql_query("SELECT * FROM resource WHERE file_extension = 'jpg' OR file_extension = 'jpeg' OR file_extension = 'gif' OR file_extension = 'png' OR file_extension = 'tiff' OR file_extension = 'psd' OR file_extension = 'bmp' OR file_extension = 'pdf' AND ref IN (SELECT resource from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref) AND ref IN (SELECT ref from resource WHERE archive<>2)");
		if(isset($bitmap_mv[0])) {
			// Yes a bitmap exists, is our current image a bitmap?
			if($name_extentsion[1]=="jpg" || $name_extentsion[1]=="jpeg") {
				// It's a JPEG, is it CMYK?
				if($colorspace=="CMYK") {
					// Yes it's CMYK, so this image takes precedence over all others
					// This image is not a child variant
					update_field($resource_ref,66,"no");
					// Set the other images as variants
					$set_variants = sql_query("UPDATE resource_data SET value='yes' WHERE resource_type_field=66 AND resource IN (SELECT a.resource FROM (SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref) AS a)");
					// Relate this image as the master to the other images
					$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
					if(count($master)>0) {
						// There are variants of this image, so we must make it related to the master variant
						
						$set_format_variants = sql_query("UPDATE resource_format_variants SET resource=$resource_ref WHERE resource=".$master[0]["resource"]." AND resource IN (SELECT resource from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref)");
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$resource_ref."', '".$master[0]["resource"]."')");

					} else {
						// There are variants of this image, so we must make it related to the master variant
						$set_format_variants = sql_query("UPDATE resource_format_variants SET resource=$resource_ref WHERE resource=".$variants[0]["resource"]." AND resource IN (SELECT resource from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref)");
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$resource_ref."', '".$variants[0]["resource"]."')");
					}
				} else {
					// Does a CMYK JPEG exist?
					//echo "CYMK called.";
					$rgb_jpg_exists = sql_query("SELECT * FROM resource_data WHERE value='CMYK' AND resource_type_field=67 AND resource IN (SELECT ref FROM resource WHERE file_extension = 'jpg' OR file_extension = 'jpeg' AND resource IN (SELECT ref from resource WHERE archive<>2) AND ref IN (SELECT resource from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref))");
					if(isset($rgb_jpg_exists[0])) {
						// A CMYK JPEG exists so make this image a variant
						$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
						if(count($master)>0) {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
						} else {
							// There are variants of this image, so we must make it related to the master variant
							$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
						}
						//echo "here";
						// is_child_variant
						update_field($resource_ref,66,"no");
						
											// Set the other images as variants
					$set_variants = sql_query("UPDATE resource_data SET value='yes' WHERE resource_type_field=66 AND resource IN (SELECT a.resource FROM (SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref) AS a)");
					// Relate this image as the master to the other images
					$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
						
						// Log this
						daily_stat("Create resource",$resource_ref);
						resource_log($resource_ref,'c',0);
						
						// Success
						if($return_res_id) return $resource_ref;
						return "1";
						return true;
						
					} else {
						// Make this image a master
						// This image is not a child variant
						update_field($resource_ref,66,"no");
						// Set the other images as variants
						$set_variants = sql_query("UPDATE resource_data SET value='yes' WHERE resource_type_field=66 AND resource IN (SELECT a.resource FROM (SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref) AS a)");
						// Relate this image as the master to the other images
						$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
						if(count($master)>0) {
							// There are variants of this image, so we must make it related to the master variant
							$set_format_variants = sql_query("UPDATE resource_format_variants SET resource=$resource_ref WHERE resource=".$master[0]["resource"]." AND resource IN (SELECT resource from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref)");
						} else {
							// There are variants of this image, so we must make it related to the master variant
							$set_format_variants = sql_query("UPDATE resource_format_variants SET resource=$resource_ref WHERE resource=".$variants[0]["resource"]." AND resource IN (SELECT resource from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref)");
						}
					}
				}
			}
			if($name_extentsion[1]=="gif") {
				// Is there a jpg variant already?
				$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpg' OR value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpeg' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
				if(isset($variants[0])) {
					// There already is a jpg, make this a variant
					update_field($resource_ref,66,"yes");
					$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
					if(count($master)>0) {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
					} else {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
					}
				} else {
					// Make this a master
					update_field($resource_ref,66,"no");
				}
				
			}
			if($name_extentsion[1]=="png") {
				// Is there a jpg variant already?
				$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpg' OR value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpeg' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
				if(isset($variants[0])) {
					// There already is a jpg, make this a variant
					update_field($resource_ref,66,"yes");
					$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
					if(count($master)>0) {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
					} else {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
					}
				} else {
					// Make this a master
					update_field($resource_ref,66,"no");
				}
				
			}
			if($name_extentsion[1]=="tiff") {
				// Is there a jpg variant already?
				$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpg' OR value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpeg' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
				if(isset($variants[0])) {
					// There already is a jpg, make this a variant
					update_field($resource_ref,66,"yes");
					$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
					if(count($master)>0) {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
					} else {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
					}
				} else {
					// Make this a master
					update_field($resource_ref,66,"no");
				}
				
			}
			if($name_extentsion[1]=="psd") {
				// Is there a jpg variant already?
				$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpg' OR value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpeg' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
				if(isset($variants[0])) {
					// There already is a jpg, make this a variant
					update_field($resource_ref,66,"yes");
					$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
					if(count($master)>0) {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
					} else {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
					}
				} else {
					// Make this a master
					update_field($resource_ref,66,"no");
				}
				
			}
			if($name_extentsion[1]=="bmp") {
				// Is there a jpg variant already?
				$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpg' OR value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpeg' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
				if(isset($variants[0])) {
					// There already is a jpg, make this a variant
					update_field($resource_ref,66,"yes");
					$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
					if(count($master)>0) {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
					} else {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
					}
				} else {
					// Make this a master
					update_field($resource_ref,66,"no");
				}
				
			}
			if($name_extentsion[1]=="pdf") {
				// Is there a jpg variant already?
				$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpg' OR value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".jpeg' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
				if(isset($variants[0])) {
					// There already is a jpg, make this a variant
					update_field($resource_ref,66,"yes");
					$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
					if(count($master)>0) {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
					} else {
						// There are variants of this image, so we must make it related to the master variant
						$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
					}
				} else {
					// Make this a master
					update_field($resource_ref,66,"no");
				}
				
			}
		} else {
			// No bitmap exists
			// Is there a variant already?
			//echo "bad";
			$variants = sql_query("SELECT * from resource_data WHERE resource_type_field = 51 AND value LIKE '".str_replace("'", "\\'", $name_extentsion[0]).".%' AND resource <> $resource_ref AND resource IN (SELECT ref from resource WHERE archive<>2)");
			if(isset($variants[0])) {
				// There already is a master, make this a variant
				update_field($resource_ref,66,"yes");
				$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
				if(count($master)>0) {
					// There are variants of this image, so we must make it related to the master variant
					$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
				} else {
					// There are variants of this image, so we must make it related to the master variant
					$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
				}
			} else {
				// Make this a master
				update_field($resource_ref,66,"no");
			}
		}
		
		
		$master = sql_query("SELECT * from resource_format_variants where related = ".$variants[0]["resource"]." OR resource = ".$variants[0]["resource"]);
		if(count($master)>0) {
			// There are variants of this image, so we must make it related to the master variant
			$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$master[0]["resource"]."', '$resource_ref')");
		} else {
			// There are variants of this image, so we must make it related to the master variant
			$add_variant = sql_query("INSERT INTO resource_format_variants(resource, related) values ('".$variants[0]["resource"]."', '$resource_ref')");
		}
		//echo "222";
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
	if($return_res_id) return $resource_ref;
	return "1";
	return true;
}
?>