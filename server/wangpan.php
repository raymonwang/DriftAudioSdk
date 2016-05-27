<?php
define('UPLOAD_DIR',dirname(__FILE__).DIRECTORY_SEPARATOR.'upload'.DIRECTORY_SEPARATOR);
/*检查和建立上传文件夹的逻辑*/
if(!file_exists(UPLOAD_DIR))
{
        mkdir(UPLOAD_DIR);//建立文件夹
        touch(UPLOAD_DIR.'index.html');
}
/*建立二级目录和确定文件名的逻辑*/
$dirname = date('YmdH').DIRECTORY_SEPARATOR;//二级目录，当前小时分文件夹
if(!file_exists(UPLOAD_DIR.$dirname))
{
        mkdir(UPLOAD_DIR.$dirname);//建立文件夹
        touch(UPLOAD_DIR.$dirname.DIRECTORY_SEPARATOR.'index.html');
}
$dest_file = $dirname.date('is').substr(md5(microtime(true)),0,8);


/*上传文件逻辑*/
if(!isset($_FILES["file"])) die("no file uploaded,plz POST file to this URL");
if ($_FILES["file"]["error"]>0) {
        echo "Error:".$_FILES["file"]["error"]."<br/>";
} else {
        move_uploaded_file($_FILES["file"]["tmp_name"],UPLOAD_DIR.$dest_file);
        echo 'http://'.$_SERVER['HTTP_HOST'].'/upload/'.str_replace(DIRECTORY_SEPARATOR, '/', $dest_file);
}
