package com.lw.util;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.json.JSONArray;
import org.json.JSONObject;

import android.content.Context;
import android.os.Environment;
import android.text.TextUtils;

import com.iflytek.cloud.ErrorCode;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechUtility;

/**
 * 功能性函数扩展类
 */
public class FucUtil {
	private static String SDPATH;
	private String FILESPATH;
	private static String TAG="FucUtil";
	public static String VOICE_SRC_DIR = "com.lw.record/voice/source/";
	public static String VOICE_COMPRESS_DIR = "com.lw.record/voice/compress/";

	static {
		try {
			SDPATH = Environment.getExternalStorageDirectory().getPath();
			createDirs(VOICE_SRC_DIR);
			createDirs(VOICE_COMPRESS_DIR);
		} catch (Exception e) {
			// TODO: handle exception
		}
	}

	public static String getSourceFilePath() {
		return SDPATH + "/" + VOICE_SRC_DIR;
	}

	public static String getCompressFilePath() {
		return SDPATH + "/" + VOICE_COMPRESS_DIR;
	}

	public static void createDirs(String dirs) {
		try {
			if (dirs.contains("/")) {
				String[] temps = dirs.split("/");
				String path = SDPATH;
				for (String temp : temps) {
					if (!TextUtils.isEmpty(temp)) {
						File file = new File(path + "/" + temp);
						if (!file.exists()) {
							file.mkdir();
						}
						path = file.getAbsolutePath();
					}
				}
			} else {
				File file = new File(SDPATH + dirs);
				if (!file.exists()) {
					file.mkdir();
				}
			}
		} catch (Exception e) {
			// TODO: handle exception
		}
	}

	/**
	 * 读取asset目录下文件。
	 * 
	 * @return content
	 */
	public static String readFile(Context mContext, String file, String code) {
		int len = 0;
		byte[] buf = null;
		String result = "";
		try {
			InputStream in = mContext.getAssets().open(file);
			len = in.available();
			buf = new byte[len];
			in.read(buf, 0, len);

			result = new String(buf, code);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	/**
	 * 获取语记是否包含离线听写资源，如未包含跳转至资源下载页面 1.PLUS_LOCAL_ALL: 本地所有资源 2.PLUS_LOCAL_ASR:
	 * 本地识别资源 3.PLUS_LOCAL_TTS: 本地合成资源
	 */
	public static String checkLocalResource() {
		String resource = SpeechUtility.getUtility().getParameter(
				SpeechConstant.PLUS_LOCAL_ASR);
		try {
			JSONObject result = new JSONObject(resource);
			int ret = result.getInt(SpeechUtility.TAG_RESOURCE_RET);
			switch (ret) {
			case ErrorCode.SUCCESS:
				JSONArray asrArray = result.getJSONObject("result")
						.optJSONArray("asr");
				if (asrArray != null) {
					int i = 0;
					// 查询否包含离线听写资源
					for (; i < asrArray.length(); i++) {
						if ("iat".equals(asrArray.getJSONObject(i).get(
								SpeechConstant.DOMAIN))) {
							// asrArray中包含语言、方言字段，后续会增加支持方言的本地听写。
							// 如："accent": "mandarin","language": "zh_cn"
							break;
						}
					}
					if (i >= asrArray.length()) {

						SpeechUtility.getUtility().openEngineSettings(
								SpeechConstant.ENG_ASR);
						return "没有听写资源，跳转至资源下载页面";
					}
				} else {
					SpeechUtility.getUtility().openEngineSettings(
							SpeechConstant.ENG_ASR);
					return "没有听写资源，跳转至资源下载页面";
				}
				break;
			case ErrorCode.ERROR_VERSION_LOWER:
				return "语记版本过低，请更新后使用本地功能";
			case ErrorCode.ERROR_INVALID_RESULT:
				SpeechUtility.getUtility().openEngineSettings(
						SpeechConstant.ENG_ASR);
				return "获取结果出错，跳转至资源下载页面";
			case ErrorCode.ERROR_SYSTEM_PREINSTALL:
				// 语记为厂商预置版本。
			default:
				break;
			}
		} catch (Exception e) {
			SpeechUtility.getUtility().openEngineSettings(
					SpeechConstant.ENG_ASR);
			return "获取结果出错，跳转至资源下载页面";
		}
		return "";
	}

	/**
	 * 读取asset目录下音频文件。
	 * 
	 * @return 二进制文件数据
	 */
	public static byte[] readAudioFile(Context context, String filename) {
		try {
			InputStream ins = context.getAssets().open(filename);
			byte[] data = new byte[ins.available()];

			ins.read(data);
			ins.close();

			return data;
		} catch (IOException e) {
			e.printStackTrace();
		}

		return null;
	}

    public static byte[] toByteArray(String filename)  {  
        try {
			File f = new File(filename);  
			if (!f.exists()) {  
			    throw new FileNotFoundException(filename);  
			}  
			ByteArrayOutputStream bos = new ByteArrayOutputStream((int) f.length());  
			BufferedInputStream in = null;  
			try {  
			    in = new BufferedInputStream(new FileInputStream(f));  
			    int buf_size = 1024;  
			    byte[] buffer = new byte[buf_size];  
			    int len = 0;  
			    while (-1 != (len = in.read(buffer, 0, buf_size))) {  
			        bos.write(buffer, 0, len);  
			    }  
			    return bos.toByteArray();  
			} catch (IOException e) {  
			    e.printStackTrace();  
			    throw e;  
			} finally {  
			    try {  
			        in.close();  
			    } catch (IOException e) {  
			        e.printStackTrace();  
			    }  
			    bos.close();  
			}
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}  
        return null;
    }  
    
    /**
     * 将amr转换成wav
     * @param sourcePath
     * @param targetPath
     */
//    public static void amr2wav(String sourcePath, String targetPath) {
//		try {
//			LogUtils.i(TAG, "amr2wav start...");
//			System.out.println("sourcePath: "+sourcePath);
//			System.out.println("targetPath: "+targetPath);
//			File source = new File(sourcePath);
//			File target = new File(targetPath);
//			AudioAttributes audio = new AudioAttributes();
//			Encoder encoder = new Encoder();
//
//			audio.setCodec("pcm_s16le");
//			EncodingAttributes attrs = new EncodingAttributes();
//			attrs.setFormat("wav");
//			attrs.setAudioAttributes(audio);
//
//			encoder.encode(source, target, attrs);
//			LogUtils.i(TAG, "amr2wav end...");
// 
//		} catch (Exception e) {
//			e.printStackTrace(); 
//		}
//		
//	}
    
    /**
     * 将wav转换成amr
     * @param wavFileName
     * @throws IOException
     */
//	public static void wav2amr(String sourcePath, String targetPath) {
//		try {
//			
//			 
//			
//			AmrInputStream aStream = new AmrInputStream(new FileInputStream(new File(sourcePath)));
//
//			File file = new File(targetPath);
//			if (!file.exists()) {
//				file.createNewFile();
//			}
//			
//			OutputStream out = new FileOutputStream(file);
//			byte[] x = new byte[1024];
//			int len;
//			out.write(0x23);
//			out.write(0x21);
//			out.write(0x41);
//			out.write(0x4D);
//			out.write(0x52);
//			out.write(0x0A);
//			while ((len = aStream.read(x)) > 0) {
//				out.write(x, 0, len);
//			}
//
//			out.close();
//			aStream.close();
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
//	}

}
