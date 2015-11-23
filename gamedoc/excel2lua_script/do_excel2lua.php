<?php



/** Include PHPExcel */
require_once dirname(__FILE__) . '/Classes/PHPExcel.php';
$objPHPExcel = new PHPExcel();
//$reader = PHPExcel_IOFactory::createReader("Excel2007");

function getDictionaryFile($dir, $search) {
	$handler = opendir($dir);
	while (($filename = readdir($handler)) !== false) {
		if ($filename != "." && $filename != ".." && strpos($filename, $search)) {
			$files[] = $filename;
		}
	}
	closedir($handler);
	return $files;
}

//helper function: print key-value
function print_key_val(&$output, $k, $v) {
	$k = "\"$k\"";
	if ($v == "") {$v = 0;}
	if (gettype($v) == "string") {
		$v = "\"$v\"";
	}
	$output .= "\t\t[$k] = $v";
	$output .= ",\n";
}

//helper function: print key-table
function print_key_table(&$output, $k, $table_content) {
	$k = "\"$k\"";
	$output .= "\t[$k] = {\n$table_content\n\t}";
	$output .= ",\n";
}

//helper function: print LUA table define
function print_lua_config(&$output, $configName, $configContent) {
	$output = $output . "local $configName = {\n$configContent\n}";
	$output = $output . "\nreturn $configName\n";
}

//the 1st column must be the ID of each row
function createLUAWithXls($excelFile) {
	echo "--------------".$excelFile."--------------\n";
	$reader = PHPExcel_IOFactory::createReader("Excel2007");
	if (!$reader->canRead($excelFile)) {
		echo "using excel5 now\n";
		$reader = PHPExcel_IOFactory::createReader("Excel5");
		if(!$reader->canRead($excelFile)){						
			echo 'no Excel';
			return ;
		}
	}
	$arr = array('A'=>1,'B'=>2,'C'=>3,'D'=>4,'E'=>5,
	'F'=>6,'G'=>7,'H'=>8,'I'=>9,'J'=>10,
	'K'=>11,'L'=>12,'M'=>13,'N'=>14,'O'=>15,
	'P'=>16,'Q'=>17,'R'=>18,'S'=>19,'T'=>20,
	'U'=>21,'V'=>22,'W'=>23,'X'=>24,'Y'=>25,
	'Z'=>26,'AA'=>27, 'AB'=>28, 'AC'=>29, 'AD'=>30,
	'AE'=>31, 'AF'=>32, 'AG'=>33, 'AH'=>34, 'AI'=>35,
	'AJ'=>36, 'AK'=>37, 'AL'=>38, 'AM'=>39, 'AN'=>40,
	'AO'=>41,'AP'=>42,'AQ'=>43,'AR'=>44,'AS'=>45,'AT'=>46,
	'AU'=>47,'AV'=>48,'AW'=>49,'AX'=>50,'AY'=>51,
	'AZ'=>52,'BA'=>53,'BB'=>54,'BC'=>55,'BD'=>56,'BE'=>57,
	'BF'=>58,'BG'=>59,'BH'=>60,'BI'=>61,'BJ'=>62,'BK'=>63,'BL'=>64,'BM'=>65);

	$start_pos = strrpos($excelFile, "/") + 1;
	$end_pos = strrpos($excelFile, ".xls");
	$lua_class_name = substr($excelFile, $start_pos, $end_pos - $start_pos);

	$excel = PHPExcel_IOFactory::load($excelFile);
	$sheet = $excel->getSheet(0);
	$highestRow = $sheet->getHighestRow();
	$highestColumn = $arr[$sheet->getHighestColumn()];
	//echo $highestRow . "-" . $highestColumn . "\n";
	//echo $highestRow . "-" . $sheet->getHighestColumn() . "\n";

	$key_val_str = "";
	$key_table_str = "";

	for ($row = 2; $row <= $highestRow; $row++) {
		for ($column = 1; $column <= $highestColumn; $column++) {
			$key = $sheet->getCellByColumnAndRow($column, 1)->getValue();
			$val = $sheet->getCellByColumnAndRow($column, $row)->getValue();
			if ($key != "") {
				//$cellVal = iconv("utf-8", "gb2312", $val);
				//echo $key . "-" . $val . "\n";
				print_key_val($key_val_str, $key, $val);
			}
		}
		//id
		$id = $sheet->getCellByColumnAndRow(0, $row)->getValue();
		if ($id != "") {
			print_key_table($key_table_str, $id, $key_val_str);
			$key_val_str = "";
		}
	}
	//echo $key_table_str;
	$configStr = "";
	print_lua_config($configStr, $lua_class_name, $key_table_str);
	//echo $configStr;

	$export_lua_file = fopen("output_lua/$lua_class_name.lua", "w");
	fwrite($export_lua_file, $configStr);
	fclose($export_lua_file);
}

//convert all xls files to lua file
$excelFiles = getDictionaryFile("input_excel", ".xls");
foreach ($excelFiles as $tmpFile) {
	createLUAWithXls("input_excel/$tmpFile");
}

//fgets(STDIN);

?>
