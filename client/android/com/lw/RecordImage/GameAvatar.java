package com.lw.RecordImage;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.widget.Toast;

import com.example.driftaudiosdk.MainActivity;
import com.lw.util.LogUtils;

public class GameAvatar {
	private static final String TAG = "GameAvatar";
	private static GameAvatar instance = null; 
	private static Activity mActivity = null;
	
	public String UploadFileURL = "http://uploadchat.ztgame.com.cn:10000/wangpan.php";

	private final String IMAGE_CACHE_DIR = "picture";
	
	private String cloudfileUrl = null;
	
	public GameAvatar(Activity activity) {
		mActivity = activity;
		
	}
	
	//单例
	public static GameAvatar GetIntance(Activity activity) {
		if (instance == null) {
			instance = new GameAvatar(activity);
		}
		LogUtils.i(TAG, "GameAvatar instace ...");
		return instance;
	}
	
	/**
	 * 设置头像的结果回调, Java调C++函数，该函数在C++中已实现
	 * @param isok
	 * @param result
	 */
	public native void setAvaterCallback(boolean isok, String result);
	
	/**
	 * c++ 调用该接口实现设置头像
	 * 
	 * @param uid
	 * @param type
	 */
	public static void setAvaterWithUid(int uid,int type)
	{
		selectPicFromAlbums();
	}
	
	public static final int MESSAGE_UPLOAD_FAILURE = 10;
    public static final int MESSAGE_UPLOAD_SUCCESS = 20;
	
	private Handler mUiHandler = new Handler() {
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            JSONObject result = new JSONObject();
            if (msg.what == MESSAGE_UPLOAD_FAILURE) {
                //Toast.makeText(mActivity, "上传失败",Toast.LENGTH_SHORT).show();
                setAvaterCallback(false, "");
            }
            else if (msg.what == MESSAGE_UPLOAD_SUCCESS) {
            	//Toast.makeText(mActivity, "上传成功",Toast.LENGTH_SHORT).show();
            	
            	try {
					result.put("url", cloudfileUrl);
					setAvaterCallback(true, result.toString());
				} catch (JSONException e) {
					e.printStackTrace();
				}
            }
        }
    };

    
	
	
	private static void selectPicFromAlbums() {       
    	Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("image/*");
        mActivity.startActivityForResult(intent, 2);
    }
	
	/**
	 * 从相册取到照片，返回图片显示
	 * 
	 * @param data
	 */
	public void takePictureFromAlbumsResult(Intent data){
		if (data == null)
            return;
        Uri originalUri = data.getData();
        String path = originalUri.toString();
        String[] projection = {MediaStore.Images.Media.DATA};
        Cursor cursor = mActivity.managedQuery(originalUri, projection, null, null,
                null);
        if (cursor != null) {
            int column_index = cursor
                    .getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
            cursor.moveToFirst();
            // 最后根据索引值获取图片路径
            path = cursor.getString(column_index);
            try {
                if (Integer.parseInt(Build.VERSION.SDK) < 14) {
                    cursor.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        File temp = new File(path);
        startPhotoZoom(Uri.fromFile(temp));
	}
	
	/**
	 * 缩放图片结果
	 * 
	 * @param data
	 */
	public void zoomPicureResult(Intent data){
		if (data != null) {
            savePicData(data);
        }
	}
	
	String photoPath = "";

    /**
     * 保存裁剪之后的图片数据到SDCARD中
     *
     * @param picdata
     */
    private void savePicData(Intent picdata) {
        try {
            Bundle extras = picdata.getExtras();
            if (extras != null) {
                Bitmap photo = extras.getParcelable("data");
                String photoName = String.valueOf(System.currentTimeMillis());
                String fileName = getDirectory("") + "/" + photoName + ".png";
                File file = new File(fileName);
                if (file.exists()) {
                    file.delete();
                }
                file.createNewFile();
                OutputStream outStream = new FileOutputStream(file);
                photo.compress(Bitmap.CompressFormat.JPEG, 80, outStream);
                outStream.flush();
                outStream.close();

                //上传修改的头像
                updatePhoto(fileName);
                // upLoadImage(photo);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String getDirectory(String filename) {

        String extStorageDirectory = Environment.getExternalStorageDirectory().toString();

        String dirPath = extStorageDirectory + "/gameUserPhoto/" + IMAGE_CACHE_DIR;
        File dirFile = new File(dirPath);
        if (!dirFile.exists())
            dirFile.mkdirs();

        dirPath = dirPath + "/dat0";
        dirFile = new File(dirPath);
        if (!dirFile.exists())
            dirFile.mkdir();
        return dirPath;
    }


    /**
     * 裁剪图片方法实现
     *
     * @param uri
     */
    private void startPhotoZoom(Uri uri) {
        Intent intent = new Intent("com.android.camera.action.CROP");
        intent.setDataAndType(uri, "image/*");
        intent.putExtra("crop", "true");
        intent.putExtra("aspectX", 1);
        intent.putExtra("aspectY", 1);
        intent.putExtra("outputX", 90);
        intent.putExtra("outputY", 90);
        intent.putExtra("return-data", true);
        mActivity.startActivityForResult(intent, 3);
    }
    

    //更新用户头像
    private void updatePhoto(final String filepath) {
        File file = new File(filepath);
        if(!file.exists()){
        	return;
        }
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("avatar", file);

        
        
        Thread postthred = new Thread(new Runnable() {

			@Override
			public void run() {
				cloudfileUrl = new UrlFileHelper().post("http://uploadchat.ztgame.com.cn:10000/wangpan.php", null,
						filepath);
				
				if(!TextUtils.isEmpty(cloudfileUrl)){
					mUiHandler.sendEmptyMessage(MESSAGE_UPLOAD_SUCCESS);
				}else{
					mUiHandler.sendEmptyMessage(MESSAGE_UPLOAD_FAILURE);
				}
			}
		});
        
        postthred.start();
    }
}
