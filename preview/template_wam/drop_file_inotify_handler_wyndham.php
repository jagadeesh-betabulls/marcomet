#!/usr/bin/php
<?
/*
	Name: drop_file_inotify_handler.php
	Description: This file is executed by the inotify daemon to check for new files in the drop folder and parse them.
	Created: 6/25/08
	By: Zachary Cimafonte
	Copyright: Marcomet 2008
*/

// no noodles
global $tmpimport;
$tmpimport = "no noodles";
global $dropfile_server;
$dropfile_server="wam.marcomet.com";
// Include the image server functions
include "include/db.php";
include "include/general.php";
include "include/resource_functions.php";
include "include/collections_functions.php";
include "include/image_processing.php";

// Include the parsing functions
include "drop_parser.php";

// Get the path to the file from the command line arguement
if($argc>1){
	try {
		echo parse_drop_filename($argv[1], false);
	} catch(Exception $e) {
		echo "5";
	}
}else {
	echo "No arguement.";
}

?>